jsHeader <- JS("function(settings, json) {",
               "$(this.api().table().header()).css({'background-color': '#3E3F3A', 'color': '#FFF0F5'});",
               "}")

writeQueryForFlightsWithFilters <- function(aFlight = NULL,
                                            origins = character(0)) {
  
  # Write base select statement with no clauses
  baseQuery <- "SELECT flight_id, time_hour, dep_time, sched_dep_time, dep_delay, arr_time,
  sched_arr_time, arr_delay, carrier, flight, origin, dest, distance FROM flights"

  # Check whether flight filter is being applied
  needsFlightFilter <- !is.na(aFlight)
  
  # Check whether origins filter is being given
  needsOriginFilter <- !identical(character(0), origins)
  
  if(needsOriginFilter) {
    # Write each origin in a quoted list for SQL to understand it
    origins <- sprintf("(%s)", toString(sprintf("'%s'", origins)))
  }
  
  whereClause <- writeWhereClause(needsFlightFilter, needsOriginFilter)
  query <- paste0(baseQuery, whereClause)
  
  # Decide how to insert the query parameters
  if(needsFlightFilter & needsOriginFilter) {
    sqlInterpolate(ANSI(), query, .dots = list(flight = aFlight, origins = SQL(origins)))
  } else if (needsFlightFilter & !needsOriginFilter) {
    sqlInterpolate(ANSI(), query, flight = aFlight)
  } else if (!needsFlightFilter & needsOriginFilter) {
    sqlInterpolate(ANSI(), query, origins = SQL(origins))
  } else {
    query
  }

}


writeWhereClause <- function(needsFlightFilter,
                             needsOriginFilter) {
  
  case_when(
    needsFlightFilter & needsOriginFilter ~ " WHERE flight = ?flight AND origin IN ?origins;",
    needsFlightFilter & !needsOriginFilter ~ " WHERE flight = ?flight;",
    !needsFlightFilter & needsOriginFilter ~ " WHERE origin IN ?origins;",
    TRUE ~ ";"
  )
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

