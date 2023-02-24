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

# Define paths and formats
sdISO <- stamp_date("2018-09-26", quiet = TRUE)
localDBPath <- "data/nyc.sqlite3"

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