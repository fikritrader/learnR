########## Finance with R - http://finance-r.com/
########## (c)2012-2018 Ronald Hochreiter <ronald@algorithmic.finance>

##### Portfolio Optimization with Stocks and Cryptocurrencies
##### Combined Cryptofolios - What Markowitz (Optimization) would have told us about Cryptocurrencies in 2018

##### Please find the complete tutorial online at http://tutorial.finance-r.com/1

### Libraries

library(quantmod)
library(tseries)

### Data

load(url("https://s3.amazonaws.com/finance-r/2018/ib.crypto.stock.rda"))

scenario.set <- ib.crypto.stock
symbols <- names(scenario.set)
n_cryptos <- which(symbols == "ZEC")

symbols[1:n_cryptos]

### Static Portfolio Optimization

timeframe <- "2017"
portfolio <- round(portfolio.optim(scenario.set[timeframe])$pw, 2)

symbols[which(portfolio > 0)]
portfolio[which(portfolio > 0)]

symbols[which(portfolio[1:n_cryptos] > 0)]
portfolio[which(portfolio[1:n_cryptos] > 0)]

eps <- 0.03
pie(portfolio[which(portfolio > eps)], 
    labels=symbols[which(portfolio > eps)],
    col=rainbow(length(which(portfolio > eps))))

### Rolling Horizon Portfolio Optimization

n_total <- nrow(scenario.set)
n_2017 <- nrow(scenario.set["2017"])

crypto_sum <- numeric()
portfolios <- matrix(ncol=n_cryptos, nrow=0)
for(current.pos in (n_2017+1):(n_total-1)) {
  portfolio <- round(portfolio.optim(scenario.set[(current.pos-n_2017):(current.pos), ])$pw, 2)
  portfolios <- rbind(portfolios, portfolio[1:n_cryptos])
  crypto_sum <- c(crypto_sum, sum(portfolio[1:n_cryptos]))
}

df.crypto.portfolio <- data.frame(portfolios)
names(df.crypto.portfolio) <- names(scenario.set[,1:n_cryptos])
head(df.crypto.portfolio)

plot(xts(crypto_sum, order.by=index(scenario.set[(n_2017+1):(n_total-1)])),
     ylim=c(0,0.03), main="Crypto Weight in Portfolio")
