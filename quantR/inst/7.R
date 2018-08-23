# Libraries
library(quantmod)
library(PerformanceAnalytics)
library(magrittr)
library(ROI)

# Libraries
library(quantR)

portfolio.pie <- function(portfolio, scenario.set, main="Portfolio") {
  pie_labels <- names(scenario.set)
  pie_labels[which(portfolio == 0)] <- NA
  pie(portfolio, labels=pie_labels, main=main)
}

### Monthly Hedge Fund Stragegy Data from EDHEC

data(hedgefund)
scenario.set <- hedgefund

assets <- ncol(scenario.set)
scenarios <- nrow(scenario.set)

cat(paste0(names(scenario.set), "\n"))

# Check out the performace of the Event Driven Strategy
chart.Bar(scenario.set$Event.Driven)
charts.PerformanceSummary(scenario.set$Event.Driven)

### Portfolio Optimization Shade One: tseries

library(tseries)

### Easy Markowitz Portfolio Optimization

timeframe <- "2003/2007" # Examples: "2003/2007" | "2007/2010"

portfolio <- round(portfolio.optim(scenario.set[timeframe])$pw, 2)
portfolio.pie(portfolio, scenario.set)

# Using the magrittr pipe for readability and usability
portfolio <- scenario.set[timeframe] %>% portfolio.optim() %>% .$pw %>% round(2)

### Easy Portfolio Strategy Backtesting

window <- 5 * 12 # 5 years rolling window (5 times 12 months, monthly data)

# Portfolio optimization backtesting in one line or a short loop!

# apply (a one-liner!)
strategy.return <- sapply((window+1):scenarios, function(x) { sum(round(portfolio.optim(scenario.set[(x-window):(x-1)])$pw, 2) * scenario.set[x]) })

# loop (almost one line)
strategy.return <- vector()
for (pos in (window+1):scenarios) 
  strategy.return <- c(strategy.return, sum(round(portfolio.optim(scenario.set[(pos-window):(pos-1)])$pw, 2) * scenario.set[pos]))

# Create a xts time series object and plot the performance of backtesting
backtesting <- as.xts(strategy.return, order.by=index(scenario.set[(window+1):scenarios]))
charts.PerformanceSummary(backtesting)

### fPortfolio

library(fPortfolio)

# convert time series format
scenario.ts <- as.timeSeries(scenario.set)

# specification: solver and efficient fronier 
spec <- portfolioSpec()
setSolver(spec) <- "solveRquadprog"
setNFrontierPoints(spec) <- 20

# constraints
constraints <- c('LongOnly')
#portfolioConstraints(scenario.ts, spec, constraints)

# optimization
frontier <- portfolioFrontier(scenario.ts, spec, constraints)
#print(frontier)

# plotting
tailoredFrontierPlot(frontier)
weightsPlot(frontier) 
#weightsPlot(frontier, col=rainbow(ncol(scenario.set))) 

# adding and changing constraints
constraints <- c('minW[1:assets]=0', 'maxW[1:assets]=0.5')
#portfolioConstraints(scenario.ts, spec, constraints)
frontier <- portfolioFrontier(scenario.ts, spec, constraints)
weightsPlot(frontier) 

### PortfolioAnalytics

library(PortfolioAnalytics)

# initialize portfolio
init.portfolio <- portfolio.spec(assets = colnames(scenario.set))
print.default(init.portfolio)

# adding constraints
init.portfolio <- add.constraint(portfolio = init.portfolio, type = "full_investment")
init.portfolio <- add.constraint(portfolio = init.portfolio, type = "long_only")

# objeective: different risk measures
minSD.portfolio <- add.objective(portfolio=init.portfolio, type="risk", name="StdDev")
meanES.portfolio <- add.objective(portfolio=init.portfolio, type="risk", name="ES")

# optimization
minSD.opt <- optimize.portfolio(R = scenario.set, portfolio = minSD.portfolio, optimize_method = "ROI", trace = TRUE)
meanES.opt <- optimize.portfolio(R = scenario.set, portfolio = meanES.portfolio, optimize_method = "ROI", trace = TRUE)

# check and plot results
print(minSD.opt)
print(meanES.opt)
portfolio.pie(round(minSD.opt$weights,2), scenario.set)
portfolio.pie(round(meanES.opt$weights,2), scenario.set)

### scenportopt

library(scenportopt)

### A. Comparison of risk measures

markowitz <- model <- optimal.portfolio(scenario.set)

# Expected Shortfall/CVaR with alpha=95% and alpha=90%
cvar95 <- optimal.portfolio(objective(model, "expected.shortfall"))
cvar90 <- optimal.portfolio(alpha(model, 0.1))

# Mean Absolute Deviation (MAD)
mad <- optimal.portfolio(objective(model, "mad"))

# Plot Comparison
compare <- matrix(c(x(markowitz), x(mad), x(cvar95), x(cvar90)), nrow=nasset(model), byrow=FALSE)
barplot(t(compare), beside=TRUE, col=rainbow(4), las=3, names.arg=names(scenario.set), legend=c("Markowitz", "MAD", "CVaR (95%)", "CVaR (90%)"))

# Add upper bounds (0.15) and repeat optimizations
markowitz <- model <- optimal.portfolio(upper.bound(portfolio.model(scenario.set), 0.15))
cvar95 <- optimal.portfolio(objective(model, "expected.shortfall"))
cvar90 <- optimal.portfolio(alpha(model, 0.1))
mad <- optimal.portfolio(objective(model, "mad"))
compare <- matrix(c(x(markowitz), x(mad), x(cvar95), x(cvar90)), nrow=nasset(model), byrow=FALSE)
barplot(t(compare), beside=TRUE, col=rainbow(4), las=3, names.arg=names(scenario.set), legend=c("Markowitz", "MAD", "CVaR (95%)", "CVaR (90%)"))

### B. Natural fit into contemporary R coding styles (piping)

x(optimal.portfolio(scenario.set))

scenario.set %>% optimal.portfolio %>% x
scenario.set %>% portfolio.model %>% objective("expected.shortfall") %>% alpha(0.1) %>% optimal.portfolio %>% x

### C. Active-extension portfolios ("130/30")

model <- optimal.portfolio(scenario.set)
model <- active.extension(model, 130, 30)
cvar13030 <- optimal.portfolio(objective(model, "expected.shortfall"))
mad13030 <- optimal.portfolio(objective(model, "mad"))
barplot(matrix(c(x(cvar13030), x(mad13030)), nrow=2, byrow=TRUE), las=3, names.arg=names(scenario.set), beside=TRUE, col=topo.colors(2))

