list.of.packages <- c("readr", "tictoc", "lubridate")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

## Testing the time required by the code below--- install.packages("tictoc") if necessary
library(tictoc)
library(lubridate)

tic("everything")

rm(list=ls())
setwd("~/Desktop/P card reporting project")
# copy and paste the following command to the console: install.packages("readr")
# setwd("~/Documents/Random R/p card")
library(readr)
data <- read.csv("cta_historical.csv")
data$FIN.TRANSACTION.AMOUNT <- parse_number(data$FIN.TRANSACTION.AMOUNT)
data$ACC.LAST.NAME <- as.character(data$ACC.LAST.NAME)
data$FIN.POSTING.DATE <- as.Date(data$FIN.POSTING.DATE, format = "%m/%d/%Y")
data$FIN.TRANSACTION.DATE <- as.Date(data$FIN.TRANSACTION.DATE, format = "%m/%d/%Y")

dates_fy17 <- as.Date(c("2016/09/01","2016/10/01","2016/11/01","2016/12/01",
                "2017/01/01","2017/02/01","2017/03/01","2017/04/01",
                "2017/05/01","2017/06/01","2017/07/01","2017/08/01",
                "2017/09/01"))
dates_fy18 <- as.Date(c("2017/09/01","2017/10/01","2017/11/01","2017/12/01",
                        "2018/01/01","2018/02/01","2018/03/01","2018/04/01",
                        "2018/05/01","2018/06/01","2018/07/01","2018/08/01",
                        "2018/09/01"))
dates_fy19 <- as.Date(c("2018/09/01","2018/10/01","2018/11/01","2018/12/01",
                        "2019/01/01","2019/02/01","2019/03/01","2019/04/01",
                        "2019/05/01","2019/06/01","2019/07/01","2019/08/01",
                        "2019/09/01"))

data_dates_fy17 <- data.frame(monthly.transaction.amount = numeric())
for (i in 1:12) {
  new_data <- subset(data, data$FIN.POSTING.DATE >= dates_fy17[i] &
                       data$FIN.POSTING.DATE < dates_fy17[i+1])
  new_sum <- sum(new_data$FIN.TRANSACTION.AMOUNT)
  data_dates_fy17[i,] <- as.numeric(new_sum)
}

data_dates_fy18 <- data.frame(monthly.transaction.amount = numeric())
for (i in 1:12) {
  new_data <- subset(data, data$FIN.POSTING.DATE >= dates_fy18[i] &
                       data$FIN.POSTING.DATE < dates_fy18[i+1])
  new_sum <- sum(new_data$FIN.TRANSACTION.AMOUNT)
  data_dates_fy18[i,] <- as.numeric(new_sum)
}

# Combining data.frames above in two columns ----

final_comparison_data <- data.frame(fy18.monthly.transactions = data_dates_fy18$monthly.transaction.amount,
                                    fy17.monthly.transactions = data_dates_fy17$monthly.transaction.amount)
months_names <- c("Sept","Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun","Juls","Aug")
rownames(final_comparison_data) <- months_names
colnames(final_comparison_data) <- c("FY18","FY17")

# Producing graph ----
png("months_aggr/monthly_cta_aggr_spending_comparison.png", width = 800, height = 600, units = 'px', res=110)
op <- par(mar=c(4,4,4,2)) 
ylim <- c(0, 1.2*max( max(final_comparison_data$FY18),
                      max(final_comparison_data$FY17) ))
yoy_comparisons_plot <- barplot(t(final_comparison_data),
                                names.arg = row.names(final_comparison_data),
                                horiz = FALSE,las=2, ylim = ylim,
                                main = "Monthly Comparison of Aggregated Spending on CTA",
                                col=c("light blue","yellow"), beside = TRUE )
legend("topright", 
       legend = c("FY18","FY17"),
       ncol = 2,
       fill=c("light blue","yellow"), 
       cex = 0.75)
rm(op)
dev.off()

# Combining data.frames above in one column, named continuously -----

(final_aggr_data <- c(data_dates_fy17$monthly.transaction.amount, data_dates_fy18$monthly.transaction.amount) )
(final_aggr_data <- as.data.frame(final_aggr_data))
(date_year <- seq(as.Date("2016/09/01"), by = "month", length.out = 24))
(rownames(final_aggr_data) <- date_year )
(colnames(final_aggr_data) <- "monthly.transaction.amount")

png("months_aggr/monthly_cta_aggr_spending.png", width = 800, height = 600, units = 'px', res=110)
op <- par(mar=c(7,4,4,2)) 
ylim <- c(0, 1.2*max(final_aggr_data$monthly.transaction.amount))
yoy_comparisons_plot <- barplot(final_aggr_data$monthly.transaction.amount,
                                names.arg = row.names(final_aggr_data),
                                horiz = FALSE,las=2, ylim = ylim,
                                main = "Aggregated Spending on CTA Per Month",
                                col=c("light blue"), beside = TRUE )
rm(op)
dev.off()


ggplot(data, aes(x=FIN.POSTING.DATE, y=FIN.TRANSACTION.AMOUNT)) +
  geom_point(shape=1) +
  geom_smooth(method=lm, se=TRUE, col="blue") +
  labs(x="Date", y="Dollar Amount", title="Spending Patterns since September 2015, CTA")
ggsave("months_aggr/cta_aggr_reg.png", width = 6, height = 4)


# Final output tables in .csv ----
write.csv(final_comparison_data, file = "months_aggr/month_cta_comp_yoy.csv")
write.csv(final_aggr_data, file = "months_aggr/aggr_month_cta_tm_series.csv")

toc()