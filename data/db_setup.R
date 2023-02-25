#-------------------------------------------------------------------------------
# Requirements
#-------------------------------------------------------------------------------
require(nycflights13)
require(dplyr)
require(DBI)
require(RSQLite)

#-------------------------------------------------------------------------------
# Queries
#-------------------------------------------------------------------------------

drop_airlines_query <- "DROP TABLE IF EXISTS airlines"
drop_airports_query <- "DROP TABLE IF EXISTS airports"
drop_flights_query <- "DROP TABLE IF EXISTS flights"
drop_planes_query <- "DROP TABLE IF EXISTS planes"
drop_weather_query <- "DROP TABLE IF EXISTS weather"

#-------------------------------------------------------------------------------
# Extract
#-------------------------------------------------------------------------------

dataAirlines <- nycflights13::airlines
dataAirports <- nycflights13::airports
dataFlights <- nycflights13::flights
dataPlanes <- nycflights13::planes
dataWeather <- nycflights13::weather

#-------------------------------------------------------------------------------
# Transform 
#-------------------------------------------------------------------------------

dfWeather <- dataWeather %>%
  mutate(time_hour = as.character(time_hour))

ids <- tibble(flight_id = seq(from = 1, to = nrow(dataFlights)))

dfFlights <- ids %>%
  bind_cols(dataFlights) %>%
  mutate(time_hour = as.character(time_hour)) 


#-------------------------------------------------------------------------------
# Load 
#-------------------------------------------------------------------------------
conn <- dbConnect(RSQLite::SQLite(), dbname = "nyc.sqlite3")

dbExecute(conn, drop_weather_query)
dbWriteTable(conn, "weather", dfWeather)

dbExecute(conn, drop_planes_query)
dbWriteTable(conn, "planes", dataPlanes)

dbExecute(conn, drop_flights_query)
dbWriteTable(conn, "flights", dfFlights)

dbExecute(conn, drop_airports_query)
dbWriteTable(conn, "airports", dataAirports)

dbExecute(conn, drop_airlines_query)
dbWriteTable(conn, "airlines", dataAirlines)

dbDisconnect(conn)
