### Libraries

require(quantR)
library(xts)
library(tseries)
library(quadprog) # replace with modopt.matlab!
library(modopt.matlab)

### Data

data(djia2013w)
scenario.set <- djia2013w

### Analyse scenarios

scenarios <- dim(scenario.set)[1]
assets <- dim(scenario.set)[2]
asset_mean <- colMeans(scenario.set)
asset_sd <- apply(scenario.set, 2, sd)

### Analyse asset covariance structure

covariance <- cov(scenario.set)

cov_assets <- 8
result <- portfolio.optim(scenario.set)
portfolio.tseries <- result$pw

barplot(round(portfolio.tseries, 2), names.arg = names(scenario.set))

# draw a random portfolio (and compute the budget normalization)
random <- runif(assets)
portfolio.random <- random/sum(random) 

# compute the loss function (portfolio times scenario set) 
# and its variance
loss <- as.numeric( t(portfolio.random) %*% t(scenario.set) )
var.r1 <- var(loss)

# compute the variance using the QP objective function way
var.r2 <- as.numeric( t(portfolio.random) %*% covariance %*% portfolio.random )

# check the difference
print(all.equal(var.r1, var.r2))

### Manual Markowitz Minimum Variance Portfolio (MVP) computation

Q <- cov(scenario.set)   # Quadratic part of the objective function
f <- rep(0, assets)      # Linear part of the objective function
A <- NULL                # Linear inequality constraint (left-hand)
b <- NULL                # Linear inequality constraint (right-hand)
Aeq <- rep(1, assets)    # Linear equality constraint (left-hand)
beq <- 1                 # Linear equality constraint (right-hand)
lb <- rep(0, assets)     # Lower Bounds
ub <- rep(1, assets)     # Upper Bounds

solution <- quadprog(Q, f, NULL, NULL, Aeq, beq, lb, ub)
portfolio.manual <- round(solution$x, 2)

barplot(round(matrix(c(portfolio.tseries, portfolio.manual), nrow=2, byrow=TRUE), 2),
        beside=TRUE, names.arg = names(scenario.set))

filename <- paste0(path.package("quantR"), "/markowitz.R")
cat( readLines( filename ) , sep = "\n" )

x1 <- portfolio.optim(scenario.set, pm=mean(asset_mean)/2)$pw
x2 <- markowitz(scenario.set, mu=mean(asset_mean)/2)
print(all.equal(x1, x2))

### Compute efficient frontier

frontier_size <- 20 + 2
frontier <- seq(min(asset_mean), max(asset_mean), length.out=frontier_size)

# Compute frontier using a loop
frontier_mean <- c()
frontier_sd <- c()
for(i in 2:(length(frontier)-1)) {
  portfolio <- portfolio.optim(scenario.set, pm=frontier[i])
  loss <- scenario.set %*% round(portfolio$pw, 2)
  frontier_mean <- c(frontier_mean, mean(loss))
  frontier_sd <- c(frontier_sd, sd(loss))
}

# Compute frontier using apply
minimum_mean <- frontier[2:(length(frontier)-1)]
portfolio <- lapply(minimum_mean, function(x) { portfolio.optim(scenario.set, pm=x) })
loss <- lapply(portfolio, function(x) { scenario.set %*% round(x$pw, 2) })
frontier_mean <- sapply(loss, mean)
frontier_sd <- sapply(loss, sd)

### Plot efficient frontier

plot(frontier_sd, frontier_mean, main="Efficient Frontier", 
     xlab="Risk / Standard Deviation", ylab="Reward / (Expected) Return")
grid(lwd=2)
lines(frontier_sd, frontier_mean)
points(asset_sd, asset_mean)
text(asset_sd, asset_mean, names(scenario.set), pos=1)

### Compute tangency portfolio

risk.free <- 0.0005
excess_return <- asset_mean - risk.free

# QP formulation
result <- quadprog(cov(scenario.set), 
                   rep(0, assets),
                   -diag(1, assets), -rep(0, assets),
                   -excess_return, -1,
                   rep(0, assets),
                   rep(1, assets))

x_tangency <- round(result$x/sum(result$x), 2)

### Plot tangency portfolio

# Start with the Efficient Frontier
plot(frontier_sd, frontier_mean, main="Efficient Frontier", 
     xlab="Risk (Standard Deviation)", ylab="Expected Return")
grid(lwd=2)
lines(frontier_sd, frontier_mean)
points(asset_sd, asset_mean)
text(asset_sd, asset_mean, names(scenario.set), pos=1)

# Tangency
loss <- scenario.set %*% round(x_tangency, 4)
points(sd(loss), mean(loss), col="red", pch=16)
segments(0, risk.free, sd(loss), mean(loss), col="red")

### Replot tangency portfolio with scaled axes

# Frontier scaled to include the risk-free asset (xlim to 0),
# tangency portfolio and tangency line
plot(frontier_sd, frontier_mean, main="Efficient Frontier", 
     xlab="Risk (Standard Deviation)", ylab="Expected Return",
     xlim=c(0, max(asset_sd)), ylim=c(min(asset_mean), max(asset_mean)))
grid(lwd=2)
lines(frontier_sd, frontier_mean)
points(asset_sd, asset_mean)
text(asset_sd, asset_mean, names(scenario.set), pos=1)
points(sd(loss), mean(loss), col="red", pch=16)
segments(0, risk.free, sd(loss), mean(loss), col="red")

