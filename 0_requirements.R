#' @details = install requirements

# read in packages and functions
package_list <- c(
  "tidyverse", 
  "leaflet", 
  "mapview", 
  "sf",
  "sp")

# install packages
install.packages(package_list)
