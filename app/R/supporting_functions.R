writeQueryForFlightsWithFilters <- function(aFlight) {
  
  if(is.na(aFlight)) {
    whereStatement <- ";"
  } else {
    whereStatement <- paste0(" WHERE flight = ?flight;")
  }
  
  query <- paste0(
  "SELECT flight_id, time_hour, dep_time, sched_dep_time, dep_delay, arr_time,
  sched_arr_time, arr_delay, carrier, flight, origin, dest, distance FROM flights",
  whereStatement)
  
  sqlInterpolate(ANSI(), query, flight = aFlight)
}

writeQueryForOrigins <- function() {
  "SELECT DISTINCT origin FROM flights;"
}

writeQueryForDestinations <- function(anOrigin) {
  query <- paste0(
  "SELECT DISTINCT dest FROM (
  SELECT *
  FROM flights 
  WHERE origin = ?origin
  );")
  
  sqlInterpolate(ANSI(), query, origin = anOrigin)
}

