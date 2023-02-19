writeFlightsQuery <- function(aFlight) {
  
  if(is.na(aFlight)) {
    whereStatement <- ";"
  } else {
    whereStatement <- paste0(" WHERE flight = ", aFlight,";")
  }
  
  
  paste0("SELECT month, day, dep_time, sched_dep_time, dep_delay, arr_time,
sched_arr_time, arr_delay, carrier, flight FROM flights",
whereStatement)
  
}