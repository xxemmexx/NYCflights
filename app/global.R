require(shiny)
require(shinydashboard)
require(shinycssloaders)
require(shinyFeedback)
require(lubridate)
require(dplyr)
require(DT)
require(DBI)
require(RSQLite)
require(leaflet)
require(ggplot2)
require(purrr)

# Define paths and formats
sdISO <- stamp_date("2018-09-26", quiet = TRUE)
localDBPath <- "data/nyc.sqlite3"
pathToDataModelI <- "data/importance_model_I.csv"
pathToLGADataModelII <- "data/importance_model_II_lga.csv"
pathToJFKDataModelII <- "data/importance_model_II_jfk.csv"
pathToEWRDataModelII <- "data/importance_model_II_ewr.csv"
linkSuperBowl <- "https://en.wikipedia.org/wiki/Super_Bowl_XLVII"
linkBlizzard <- "https://en.wikipedia.org/wiki/February_2013_North_American_blizzard"
linkNZa <- "http://www.nza.nl"

# Connect to database when app is launched
conn <- dbConnect(RSQLite::SQLite(), dbname = localDBPath)

# Close database connection when app is closed
shiny::onStop(function() {
  dbDisconnect(conn)
})

# Turn off scientific notation
options(scipen = 999)

# Set spinner type (for loading)
options(spinner.type = 4, spinner.color = '#2F4F4F')