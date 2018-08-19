#' @title Open a specific finance-r.com tutorial code
#'
#' @description
#' \code{tutorial} opens the R script of a given tutorial code within RStudio
#'
#' @param tutorial id of the tutorial to open
#'
#' @author Ronald Hochreiter, \email{ronald@@algorithmic.finance}
#'
#' @export
tutorial <- function(tutorial=0) {
  if(tutorial > 0) { 
    df.tutorials <- read.csv(paste0(path.package("financeR"), "/tutorials.csv"), sep=";", header=FALSE)
    names(df.tutorials) <- c("id", "order", "short", "updated", "version", "title", "description", "status")
    
    pos.tutorial <- which(df.tutorials$id == tutorial)  
    if (length(pos.tutorial) == 1) {
      short <- df.tutorials$short[pos.tutorial]
      url <- paste0("https://s3.amazonaws.com/finance-r.com/tutorial/", tutorial ,".R")
      destfile <- paste0(tempdir(), "/", short, ".R")
      download.file(url, destfile, quiet=TRUE)
      file.edit(destfile, title=paste0(short, ".R"))
    } else {
      warning(paste0("Unfortunately, Tutorial #", tutorial, " is not available!"))
      return(FALSE)
    }
  } else {
    warning("Please enter a valid tutorial id!")
    return(FALSE)
  }
  return(TRUE)
}
