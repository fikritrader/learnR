### Libraries

library(dplyr)
library(ROI)
library(ROI.plugin.glpk)
library(ompr)
library(ompr.roi)
library(CVXR)
library(modopt.matlab)

### Manual solution - using ROI

lp <- OP(objective = c(120, 130), 
         L_constraint(L = matrix(c(2, 1, 2, 3), nrow = 2, byrow=TRUE),
                      dir = c("<=", "<="),
                      rhs = c(500, 800)), 
         maximum = TRUE,
         bounds = V_bound(li=c(1:2), lb=c(0, 0), ui=c(1:2), ub=c(220, 180)))
sol <- ROI_solve(lp, solver = "glpk")
print(sol$solution)

### Using modeling languages - ompr

result <- MIPModel() %>%
  add_variable(full, type = "continuous", lb = 0, ub=220) %>%
  add_variable(compact, type = "continuous", lb = 0, ub=180) %>%
  set_objective(120*full + 130*compact, "max") %>%
  add_constraint(2*full + 1*compact <= 500) %>%
  add_constraint(2*full + 3*compact <= 800) %>%
  solve_model(with_ROI(solver = "glpk")) 
get_solution(result, full)
get_solution(result, compact)

### Using modeling languages - CVXR

full <- Variable(1)
compact <- Variable(1)
p_full <- Variable(1)
p_compact <- Variable(1)

objective <- Maximize(full*(p_full - 150) + compact*(p_compact - 100))
constraints <- list(2*full + compact <= 500,
                    2*full + 3*compact <= 800,
                    full <= 490 - p_full,
                    compact <= 640 - 2*p_compact,
                    full >= 0, compact >= 0, p_full >= 0, p_compact >= 0)
magnetron <- Problem(objective, constraints)
# solution <- solve(magnetron)

## print("Missing")

