#--------#
# set up #
#--------#

# load packages
library(sf)
library(sp)
library(tidyverse)
library(leaflet)
library(mapview)


#' tidyverse = includes dplyr primary data processing packages in R
#' sf = simple features; basically just a dataframe with a geometry column, can use all dplyr functions on it
#' sfc = column of geometries
#' sfg = simple feature geometry (simple geometry)
#' types of sfg = points, polygons, etc.
#' crs = coordinate reference system (each geometry needs a CRS)
#' https://docs.qgis.org/2.8/en/docs/gentle_gis_introduction/coordinate_reference_systems.html
#' #' https://r-spatial.github.io/sf/articles/sf1.html

#' leaflet = a javascript interactive mapping "program"
#' https://rstudio.github.io/leaflet/ 

#' import EAs
#' read_sf = read in simple features - works with shapefiles, csvs, etc.
hotspots <- read_sf(dsn = "data", layer = "enumeration_areas")
str(hotspots)
head(hotspots)

#' look at CRS
st_crs(hotspots)
hotspots <- st_set_crs(hotspots, 4326) # example of estting to lat lon CRS

#' import survey data and convert it to a sf object
survey <- read.csv("data/survey.csv")
head(survey)
class(survey)

#' convert survey to sf
survey_sf <- survey %>%
  st_as_sf(coords = c("gps_lat", "gps_lon"), crs = 4326)

# create basemap
extent <- st_bbox(hotspots) # the x and y axis limits to the graphs
print(extent)

basemap <- leaflet() %>%
  addTiles(group = "OSM (default)") %>%
  fitBounds(
    lng1 = extent[[1]], 
    lat1 = extent[[2]], 
    lng2 = extent[[3]], 
    lat2 =  extent[[4]])

print(basemap)

# chack that things look ok
basemap %>%
  addPolygons(
    data = hotspots,
    weight = 1) %>%
  addCircles(
    data = survey_sf,
    color = "red",
    weight = 2,
    radius = 10)

#----------------------------#
# check if survey is in a EA #
#----------------------------#
# join the survey data with the EA; if EA info is NA then the survey is outside of a EA
survey_hs <- survey_sf %>%
  st_join(hotspots, left = TRUE) %>%
  mutate(in_ea = if_else(is.na(hs_name), "No", "Yes"))

#' alternative method
# library(matrixStats)
# dist <- st_distance(survey_sf, hotspots) %>%
#   rowMins()
# survey_hs <- cbind(survey_sf, dist) %>%
#   mutate(in_ea = if_else(dist > 0, "No", "Yes"))


# final map
survey_color <- colorFactor(c("Red", "Green"), domain = c("No", "Yes")) 

# create map for each city and save
m_final <- basemap %>%
    addPolygons(
      data = hotspots,
      weight = 1) %>%
    addCircles(
      data = survey_hs,
      color = ~survey_color(in_ea),
      weight = 2,
      radius = 300,
      fillOpacity = 1) %>%
  addLegend(
    data = survey_hs,
    pal = survey_color,
    values = c("No", "Yes"),
    title = "In EA?")
  
# save maps
mapshot(
  m_final,
  "output/map.html")
