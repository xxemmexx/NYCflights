computeOccupancy <- function(aDate, numberOfSeats) {
  case_when(
    aDate < ymd('2013-06-29') ~ floor(.75*numberOfSeats),
    aDate > ymd('2013-09-01') ~ floor(.75*numberOfSeats),
    TRUE ~ numberOfSeats
  )
}

interpolateFlightsQuery <- function(aQuery,
                                    needsFlightFilter,
                                    aFlight,
                                    needsOriginFilter,
                                    origins) {
  
  # Decide how to insert the query parameters
  if(needsFlightFilter & needsOriginFilter) {
    
    sqlInterpolate(ANSI(), aQuery, .dots = list(flight = aFlight, origins = SQL(origins)))
    
  } else if (needsFlightFilter & !needsOriginFilter) {
    
    sqlInterpolate(ANSI(), aQuery, flight = aFlight)
    
  } else if (!needsFlightFilter & needsOriginFilter) {
    
    sqlInterpolate(ANSI(), aQuery, origins = SQL(origins))
    
  } else {
    
    aQuery
  }
}

jsHeader <- JS("function(settings, json) {",
               "$(this.api().table().header()).css({'background-color': '#2F4F4F', 'color': '#FFF0F5'});",
               "}")

writeQueryForDestinations <- function(anOrigin) {
  
  query <- "SELECT faa, name, lat, lon
  FROM airports 
  WHERE faa IN 
  (
    SELECT DISTINCT dest 
    FROM
    (
      SELECT * 
        FROM flights 
      WHERE origin = ?origin
    ));"
  
  
  sqlInterpolate(ANSI(), query, origin = anOrigin)
}

writeQueryForFlightsWithFilters <- function(aFlight, origins) {
  
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
  
  query %>%
    interpolateFlightsQuery(needsFlightFilter, aFlight, needsOriginFilter, origins)

}

writeQueryForOrigins <- function() {
  "SELECT faa, name, lat, lon
  FROM airports 
  WHERE faa IN 
  (
  SELECT DISTINCT origin 
  FROM flights
  );"
}

writeQueryForSeats <- function(aDate1, aDate2) {
  query <- "SELECT *
  FROM (
  SELECT f.tailnum, origin, time_hour, seats 
  FROM flights f
  INNER JOIN planes p ON f.tailnum = p.tailnum
  )
  WHERE time_hour BETWEEN date(?date1) AND date(?date2);"
  
  sqlInterpolate(ANSI(), query, .dots = list(date1 = aDate1, date2 = aDate2))
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

