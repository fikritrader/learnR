########## Decision Optimization with R - http://opt-r.com/
########## (c)2017-2018 Ronald Hochreiter <ronald@algorithmic.finance>

##### Decision Optimization 101
##### Never take a wrong decision again - simply compute your optimal decisions by modeling the reality correctly

##### Please find the complete tutorial online at http://opt-r.com/1

### Libraries

library(magrittr)
library(ROI)
library(ROI.plugin.glpk)
library(ompr)
library(ompr.roi)
library(CVXR)
library(modopt.matlab)

### Manual solution - using modopt.matlab

sol <- linprog(f=-c(0.13, 0.1),
               A=matrix(c(1.5, 1, 1, 1, 0.3, 0.5), nrow = 3, byrow=TRUE),
               b=c(27000, 21000, 9000),
               lb=c(0, 0),
               ub=c(15000, 16000))

solution <- round(sol$x)
print(solution)

### Manual solution - using ROI

lp <- OP(objective = c(0.13, 0.1), 
         L_constraint(L = matrix(c(1.5, 1, 1, 1, 0.3, 0.5), nrow = 3, byrow=TRUE),
                      dir = c("<=", "<=", "<="),
                      rhs = c(27000, 21000, 9000)), 
         maximum = TRUE,
         bounds = V_bound(li=c(1:2), lb=c(0, 0), ui=c(1:2), ub=c(15000, 16000)))

sol <- ROI_solve(lp, solver = "glpk")

### Using modeling languages - CVXR

wrench <- Variable(1)
pliers <- Variable(1)

objective <- Maximize(0.13*wrench + 0.10*pliers)
constraints <- list(1.5*wrench + 1.0*pliers <= 27000,
                    1.0*wrench + 1.0*pliers <= 21000,
                    0.3*wrench + 0.5*pliers <= 9000,
                    wrench >= 0, pliers >= 0,
                    wrench <= 15000, pliers <= 16000)
gtc <- Problem(objective, constraints)
solution <- solve(gtc)

solution$getValue(wrench)
solution$getValue(pliers)

rm(wrench, pliers)

### Using modeling languages - ompr

result <- MIPModel() %>%
  add_variable(wrench, type = "continuous", lb = 0, ub=15000) %>%
  add_variable(pliers, type = "continuous", lb = 0, ub=16000) %>%
  set_objective(0.13*wrench + 0.10*pliers, "max") %>%
  add_constraint(1.5*wrench + 1.0*pliers <= 27000) %>%
  add_constraint(1.0*wrench + 1.0*pliers <= 21000) %>%
  add_constraint(0.3*wrench + 0.5*pliers <= 9000) %>%
  solve_model(with_ROI(solver = "glpk")) 
get_solution(result, wrench)
get_solution(result, pliers)
