########## Become a Quant with R - http://quant-r.com/
########## (c)2017-2018 Ronald Hochreiter <ronald@algorithmic.finance>

##### The Magic of Markowitz
##### A sensational idea that is really worth the Nobel prize - visualized with two stocks

##### Please find the complete tutorial online at http://quant-r.com/3

library(quantmod)
library(scenportopt)

# select the ticker symbols of two assets for our analysis
ticker1 <- "MSFT"
ticker2 <- "GE"

# select a timeframe
timeframe <- '2017'

# retrive financial data from Yahoo! Finance (not auto-assigned)
data1 <- getSymbols(ticker1, auto.assign=FALSE)
data2 <- getSymbols(ticker2, auto.assign=FALSE)

# compute crude weekly returns
return_lag <- 5 # 1 ... daily / 5 ... crude weekly / 20 ... (very) crude monthly
ret1 <- as.vector(na.omit(ROC(Ad(data1[timeframe]), return_lag)))
ret2 <- as.vector(na.omit(ROC(Ad(data2[timeframe]), return_lag)))

# obtain y axis limits for barplots of returns
ret_min <- min(c(ret1, ret2)) 
ret_max <- max(c(ret1, ret2)) 

# obtain y axis limits for histograms of loss functions
h1 <- hist(ret1, plot=FALSE)
h2 <- hist(ret2, plot=FALSE)
hist_max <- max(h1$counts, h2$counts)

# Plot
op <- par(mfrow=c(2, 2))
barplot(ret1, ylim=c(ret_min, ret_max), main=ticker1)
barplot(ret2, ylim=c(ret_min, ret_max), main=ticker2)
hist(ret1, xlim=c(ret_min, ret_max), ylim=c(0, hist_max), main=ticker1, xlab="")
hist(ret2, xlim=c(ret_min, ret_max), ylim=c(0, hist_max), main=ticker2, xlab="")

par(op)

epsilon <- 0.05 # manual portfolio grid-size
lambda <- seq(0, 1, by=epsilon)
portfolio_loss <- lapply(lambda, function(x) { x * ret1 + (1-x) * ret2 } )

portfolio_mean <- unlist(lapply(portfolio_loss, mean))
portfolio_sd <- unlist(lapply(portfolio_loss, sd))

alpha <- 0.05 # Value-at-Risk alpha
portfolio_varisk <- unlist(lapply(portfolio_loss, quantile, alpha))

risk_report <- data.frame(lambda, 1-lambda, portfolio_mean, portfolio_sd, portfolio_varisk)
names(risk_report) <- c(ticker1, ticker2, "Mean", "SD", "VaR(95%)")

# plot mean (linear combination)
plot(portfolio_mean, xlab="Portfolio", ylab="Mean")
lines(portfolio_mean)
grid(lwd=2)

# Plot minimum risk function for two assets
plot_minrisk <- function(portfolios, opt, asset1, ticker1, ticker2, main="", ylab="") {
  subtitle<- paste("Optimal portfolio: ", asset1*100, "% of ", ticker1, " and ", (1-asset1)*100 ,"% of ", ticker2, sep="")
  plot(portfolios, main=main, xlab="", ylab=ylab, sub=subtitle)
  lines(portfolios)
  grid(lwd=2)
  points(portfolios, pch=1)
  points(opt, portfolios[opt], col="red", pch=16)
}

# Plot for various risk measures (Markowitz and VaR)
opt_sd <- which(portfolio_sd == min(portfolio_sd))
plot_minrisk(portfolio_sd, opt_sd, lambda[opt_sd], ticker1, ticker2, main="Minimize Standard Deviation", ylab="Standard Deviation")

opt_varisk <- which(portfolio_varisk == max(portfolio_varisk))
plot_minrisk(portfolio_varisk, opt_varisk, lambda[opt_varisk], ticker1, ticker2, main="Maximize Value-at-Risk (95%)", ylab="Value-at-Risk (95%)")

# Risk-Return plots
plot(portfolio_sd, portfolio_mean, type="l", main="Mean/Risk - Standard Deviation", xlab="Standard Deviation", ylab="Mean")
points(portfolio_sd[opt_sd], portfolio_mean[opt_sd], col="red", pch=16)
points(portfolio_sd, portfolio_mean)
grid(lwd=2)

plot(portfolio_varisk, portfolio_mean, type="l", main="Mean/Risk - Value-at-Risk (95%)", xlab="Value-at-Risk (95%)", ylab="Mean")
points(portfolio_varisk[opt_varisk], portfolio_mean[opt_varisk], col="red", pch=16)
points(portfolio_varisk, portfolio_mean)
grid(lwd=2)

print(round(x(optimal.portfolio(data.frame(ret1, ret2))), 2))
