#' @details = install requirements

# read in packages and functions
package_list <- c(
  "tidyverse", 
  "leaflet", 
  "mapview", 
  "sf",
  "sp")

# install packages
invisible(lapply(package_list, function(x){
  print(x)
  install.packages(x)
  })
)