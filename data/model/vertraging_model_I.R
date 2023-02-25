#-------------------------------------------------------------------------------
# Requirements
#-------------------------------------------------------------------------------
require(randomForest)
require(dplyr)
require(DBI)
require(RSQLite)
require(lubridate)

#-------------------------------------------------------------------------------
# Function to fetch data
#-------------------------------------------------------------------------------
fetchData <- function() {
  conn <- dbConnect(RSQLite::SQLite(), dbname = 'app/data/nyc.sqlite3')
  data <- dbGetQuery(conn, 
                     "SELECT origin, sched_dep_time, arr_delay, p.tailnum, month, distance, dest, carrier, time_hour, wind_speed, wind_dir, visib, temp, dewp, humid, precip, pressure, manufacturer, seats
                      FROM
                      (
                      SELECT f.origin, sched_dep_time, arr_delay, f.tailnum, f.month, f.distance, dest, carrier, f.time_hour, wind_speed, wind_dir, visib, w.temp, dewp, humid, precip, pressure
                      FROM flights f 
                      INNER JOIN weather w ON w.time_hour = f.time_hour
                      ) j
                      INNER JOIN planes p ON j.tailnum = p.tailnum;  ")
  dbDisconnect(conn)
  
  return(data)
}

#-------------------------------------------------------------------------------
# Load data
#-------------------------------------------------------------------------------
dataFlights <- fetchData()

#-------------------------------------------------------------------------------
# Pre-processing
#-------------------------------------------------------------------------------

# Feature selection
flightsDataset <- dataFlights %>%
  transmute(origin = as.factor(origin),
            month, 
            sched_dep_time,
            distance, 
            carrier = as.factor(carrier), 
            wind_speed,
            wind_dir,
            visib,
            temp,
            dewp,
            humid, 
            precip,
            pressure,
            manufacturer = as.factor(manufacturer),
            seats,
            arr_delay) %>%
  na.omit()

# Take a small sample of the data to go quicker - at the expense of quality obviously...
mask <- runif(n = 8000, min = 1, max = 336776) %>% unique() %>% as.integer()
flightsDataset <- flightsDataset[mask,] %>% na.omit()


# Double-check no rows has NA values 
for(i in 1:ncol(flightsDataset)) {
  
  thisValue <- sum(!complete.cases(flightsDataset[[i]]))
  
  if(thisValue > 0) {
    print(paste0("Variable ", 
                 names(flightsDataset)[[i]], 
                 " has ", 
                 thisValue,
                 " NA values"))
  }
}
#-------------------------------------------------------------------------------
# Fit
#-------------------------------------------------------------------------------
# Make this example reproducible
set.seed(1)

# Fit the random forest model
vertraging_model <- randomForest(
  formula = arr_delay ~ .,
  data = flightsDataset
)

#-------------------------------------------------------------------------------
# Export importance
#-------------------------------------------------------------------------------

write.csv2(vertraging_model$importance, "app/data/importance_model_I.csv")
