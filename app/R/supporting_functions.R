computeOccupancy <- function(aDate, numberOfSeats) {
  case_when(
    aDate == ymd('2013-01-31') | aDate == ymd('2013-02-06') ~ floor(.88*numberOfSeats),
    aDate == ymd('2013-02-01') | aDate == ymd('2013-02-05') ~ floor(.95*numberOfSeats),
    aDate == ymd('2013-02-02') | aDate == ymd('2013-02-04') ~ numberOfSeats,
    aDate == ymd('2013-02-03') ~ floor(.45*numberOfSeats),
    aDate < ymd('2013-06-29') ~ floor(.75*numberOfSeats),
    aDate > ymd('2013-09-01') & aDate < ymd('2013-12-15') ~ floor(.75*numberOfSeats),
    aDate > ymd('2013-12-14') & aDate < ymd('2013-12-25') ~ floor(.92*numberOfSeats),
    aDate == ymd('2013-12-25') ~ floor(.55*numberOfSeats),
    aDate > ymd('2013-12-25') & aDate < ymd('2014-01-01') ~ floor(.87*numberOfSeats),
    TRUE ~ numberOfSeats
  )
}

defineColours <- function(aNumber) {
  case_when(
    aNumber > 1000000 ~ "#8B0000",
    aNumber < 1000000 & aNumber > 550000 ~ "#CD853F",
    TRUE ~ "#6B8E23"
  )
  
}

generateImportancePlot <- function(aDataset) {
  aDataset %>%
    ggplot(aes(x = parameter, y = importance)) +
    geom_bar(stat = "identity", fill = defineColours(aDataset$importance)) +
    ggtitle("Wat in hoever vertraging bepaald") +
    xlab("") + ylab("") +
    theme(plot.title = element_text(size = 18, face = "bold", hjust = 0.5)) +
    theme(axis.title.x = element_text(size = 16, face = "bold")) +
    theme(axis.title.y = element_text(size = 16, face = "bold")) +
    theme(axis.text.x= element_blank()) +
    theme(axis.text.y= element_text(face = "bold", size = 12, angle = 15)) +
    coord_flip()
}

getPathForOrigin <- function(aCode) {
  case_when(
    aCode == 'EWR' ~ pathToEWRDataModelII,
    aCode == 'JFK' ~ pathToJFKDataModelII,
    aCode == 'LGA' ~ pathToLGADataModelII,
    TRUE ~ pathToEWRDataModelII
  )
}

getTitleForPlot <- function(type = c("occupancy", "capacity"), anOrigin, fromDate, toDate) {
  type <- match.arg(type)
  
  head <- switch(type,
         "occupancy" = "Aantal passagiers per dag vanaf ",
         "capacity" = "% van totale capaciteit in ")
  
  paste0(head, anOrigin, "\n",
         "(Periode: ", fromDate, " t/m ", toDate, ")")
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
               "$(this.api().table().header()).css({'background-color':'#2F4F4F','color': '#FFF0F5'});",
               "}")


readAndFormatData <- function(aPathToDataset) {
  read.csv(aPathToDataset, 
           header = TRUE, 
           sep = ";", 
           dec = ",",
           stringsAsFactors = FALSE) %>%
    as_tibble() %>%
    transmute(parameter = X %>% as.factor(),
              importance = IncNodePurity) %>%
    mutate(parameter = reorder(parameter, importance))
}

writeDestinationDisplayName <- function(aLookUpTable, aCode) {
  
  if_else(is.na(unname(aLookUpTable[aCode])),
          aCode,
          paste0(unname(aLookUpTable[aCode]), " (", aCode, ")")
          )
}

writeQueryForAirpots <- function() {
  "SELECT faa, name 
  FROM airports;"
}

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
  sched_arr_time, arr_delay, carrier, tailnum, flight, origin, dest, distance FROM flights"

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

writeQueryForSeats <- function(anOrigin, aDate1, aDate2) {
  query <- "SELECT *
  FROM (
  SELECT f.tailnum, origin, time_hour, seats 
  FROM flights f
  INNER JOIN planes p ON f.tailnum = p.tailnum
  )
  WHERE origin = ?origin AND time_hour BETWEEN date(?date1) AND date(?date2);"
  
  sqlInterpolate(ANSI(), query, .dots = list(origin = anOrigin, date1 = aDate1, date2 = aDate2))
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

