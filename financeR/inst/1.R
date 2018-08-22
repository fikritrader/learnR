########## Preliminaries

### Set your Alpha Vantage API key

apikey.alphavantage <- "your.api.key" 
apikey.alphavantage <- "GC35PPJPP9K7VQ51" 
Sys.setenv(AV_APIKEY=apikey.alphavantage)

### Required packages - install if not yet installed

install.packages(htmltab)
install.packages(dplyr)
install.packages(zeallot)
install.packages(quantmod)
install.packages(tseries)

########## Part I - Create a list of Cryptocurrencies

### Libraries

library(htmltab)
library(dplyr)

currency_digital <- read.csv2(url("https://www.alphavantage.co/digital_currency_list/"), sep=",")

url <- "https://coinmarketcap.com/"
coinmarketcap <- htmltab(doc = url, which = "//th[text() = 'Name']/ancestor::table")

### Process Input


ticker <- unlist(sapply(strsplit(coinmarketcap$`Circulating Supply`, " "),
                        function(x) { gsub("[^[:alpha:]]","", x[1]) }))

volume_usd <- as.numeric(unlist(sapply(coinmarketcap$`Volume (24h)`,
                                function(x) { gsub("[^[:alnum:]]","", x) })))

ticker.volume <- data.frame(ticker, volume_usd)
names(ticker.volume) <- c("currency.code", "volume.usd")

crypto.list.temp <- currency_digital %>% filter(currency.code %in% ticker)
crypto.list <- merge(crypto.list.temp, ticker.volume, by="currency.code")

save(crypto.list, file="crypto-list.rda")

########## Part II - Download Data from Alpha Vantage

### Libraries

library(quantmod)
library(zeallot)

### Data

load("crypto-list.rda")

### Download Data

market <- "USD"

c(values, index) %<-% sort(crypto.list$volume.usd, decreasing = TRUE, index.return=TRUE)
ticker.list <- sort(as.character(crypto.list$currency.code[index[1:20]]))

crypto.data <- list()

options(warn=-1)
for (symbol in ticker.list) {
  url <- paste0("https://www.alphavantage.co/query?function=DIGITAL_CURRENCY_DAILY&symbol=", symbol,
                "&market=", market,
                "&apikey=", Sys.getenv("AV_APIKEY"),
                "&datatype=csv")

  data.current <- read.csv2(url(url), sep=",")
  if(ncol(data.current) > 1) {
    data.xts <- xts(data.current[,2:ncol(data.current)],
                    order.by=as.Date(data.current[,1], "%Y-%m-%d"))

    crypto.data[[symbol]] <- data.xts
  }
  Sys.sleep(1)
}
options(warn=0)

save(crypto.data, file="crypto-data.rda")

########## Part III - Compute an optimal cryptofolio

### Libraries

library(xts)
library(tseries)

### Data

load("crypto-data.rda")

### Generate Scenario Set (Returns on Close Values)

timeframe <- "2018"
df.close <- crypto.data[[names(crypto.data)[1]]][,4][timeframe]

for(symbol in names(crypto.data)[2:length(names(crypto.data))]) {
  current.close <- crypto.data[[symbol]][,4][timeframe]
  df.close <- merge(df.close, current.close)
}

names(df.close) <- names(crypto.data)
df.close <- na.omit(df.close[,-which(is.na(df.close[1,]))])

df.return <- apply(df.close, 2, 
                   function(x) { ROC(as.numeric(x), na.pad=FALSE) } )
df.return <- na.spline(df.return)

### Compute and plot the Markowitz optimal portfolio 

portfolio <- round(portfolio.optim(df.return)$pw, 2)
barplot(portfolio, names.arg = names(df.close))
