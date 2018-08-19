#' @title Install required non-CRAN packages from GitHub and elsewhere for the tutorials
#'
#' @description
#' \code{setup} installs all required non-CRAN packages from GitHub and elsewhere
#'
#' @author Ronald Hochreiter, \email{ronald@@algorithmic.finance}
#'
#' @export
setup <- function() {
  # First do an update
  financeR::update()
  
  # Install Packages from CRAN
  for(package in packages.cran) {
    if(!(package %in% rownames(installed.packages()))) { install.packages(package) }
  }
  
  # Install Packages from GitHub
  for(package in packages.github) {
    if(!(package %in% rownames(installed.packages()))) { devtools::install_github(package) }
  }
  
  # Return TRUE whatever happens...
  return(TRUE)  
}
