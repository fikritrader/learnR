### Libraries

library(dplyr)
library(CVXR)
library(ROI)
library(ROI.plugin.glpk)
library(ompr)
library(ompr.roi)
library(modopt.matlab)

### Modeling approach - CVXR

stock <- Variable()
bond <- Variable()
option <- Variable()

objective <- Maximize( 4 * stock + 10 * bond + 0 * option )

constraints <- list(20 * stock + 90 * bond + 1000 * option <= 20000,
                    -50 <= option,
                    option <= 50, 
                    bond >= 0, stock >= 0)

problem <- Problem(objective, constraints)

result <- solve(problem)

result$getValue(stock)
result$getValue(bond)
result$getValue(option)

# Remove some variables from environment to avoid confusion between packages
rm(stock, bond, option)

### Modeling approach - ompr

result <- MIPModel() %>%
  add_variable(stock, type = "continuous", lb = 0, ub=Inf) %>%
  add_variable(bond, type = "continuous", lb = 0, ub=Inf) %>%
  add_variable(option, type = "continuous", lb = -50, ub=50) %>%
  set_objective(4 * stock + 10 * bond + 0 * option, "max") %>%
  add_constraint(20 * stock + 90 * bond + 1000 * option <= 20000) %>%
  solve_model(with_ROI(solver = "glpk")) 

get_solution(result, stock)
get_solution(result, bond)
get_solution(result, option)

### Manual solution - modopt.matlab

f <- c(4, 10, 0)
Aeq <- matrix(c(20, 90, 1000), nrow=1)
beq <- c(20000);
lb <- c(0, 0, -50)
ub <- c(Inf, Inf, 50)

solution <- linprog(-f, NULL, NULL, Aeq, beq, lb, ub)
solution$x

### Manual solution - ROI

lp <- OP(objective = c(4, 10, 0), 
         L_constraint(L = matrix(c(20, 90, 1000), nrow=1, byrow=TRUE),
                      dir = c("<="),
                      rhs = c(20000)), 
         maximum = TRUE,
         bounds = V_bound(li=c(1:3), lb=c(0, 0, -50), ui=c(1:3), ub=c(Inf, Inf, 50)))

sol <- ROI_solve(lp, solver = "glpk")

sol$solution

