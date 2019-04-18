# current source folder
# improved version of
# https://stackoverflow.com/a/36777602
# returns getwd() if no path
csf <- function() {
  if (!require(knitr)) {
    install.packages("knitr")
    require(knitr)
  }
  if (!require("rstudioapi")){
    install.packages("rstudioapi")
    require(rstudioapi)
  }
  # http://stackoverflow.com/a/32016824/2292993
  cmdArgs = commandArgs(trailingOnly = FALSE)
  needle = "--file="
  match = grep(needle, cmdArgs)
  if (length(match) > 0) {
    # Rscript via command line
    return(dirname(normalizePath(sub(needle, "", cmdArgs[match]))))
  } else {
    ls_vars = ls(sys.frames()[[1]])
    if ("fileName" %in% ls_vars) {
      # Source'd via RStudio
      return(dirname(normalizePath(sys.frames()[[1]]$fileName)))
    } else {
      if (!is.null(sys.frames()[[1]]$ofile)) {
        # Source'd via R console
        return(dirname(normalizePath(sys.frames()[[1]]$ofile)))
      } else {
        # RStudio Run Selection
        # http://stackoverflow.com/a/35842176/2292993
        if (requireNamespace("knitr") && !is.null(knitr::current_input())) {
          # this fork is inspired by https://github.com/krlmlr/kimisc/blob/master/R/thisfile.R
          return (dirname(knitr::current_input()))
        } else {
          if(nchar(rstudioapi::getActiveDocumentContext()$path)>0) {
            return(dirname(normalizePath(rstudioapi::getActiveDocumentContext()$path)))
          } else { #console
            return(getwd());
          }
        }
      }
    }
  }
}