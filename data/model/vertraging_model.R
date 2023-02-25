#-------------------------------------------------------------------------------
# Requirements
#-------------------------------------------------------------------------------
require(randomForest)
require(dplyr)
require(DBI)
require(RSQLite)

#-------------------------------------------------------------------------------
# Custom functions
#-------------------------------------------------------------------------------
fetchData <- function() {
  conn <- dbConnect(RSQLite::SQLite(), dbname = 'app/data/nyc.sqlite3')
  data <- dbGetQuery(conn, 
                     "SELECT origin, sched_dep_time, dep_delay, arr_delay, p.tailnum, month, distance, dest, carrier, time_hour, wind_speed, wind_dir, visib, temp, dewp, humid, precip, pressure, manufacturer, seats
                      FROM
                      (
                      SELECT f.origin, sched_dep_time, dep_delay, arr_delay, f.tailnum, f.month, f.distance, dest, carrier, f.time_hour, wind_speed, wind_dir, visib, w.temp, dewp, humid, precip, pressure
                      FROM flights f 
                      INNER JOIN weather w ON w.time_hour = f.time_hour
                      ) j
                      INNER JOIN planes p ON j.tailnum = p.tailnum;  ")
  dbDisconnect(conn)
  
  return(data)
}

reduceDataset <- function(aDataset, aSample) {
  mask <- runif(n = aSample, min = 1, max = nrow(aDataset)) %>% unique() %>% as.integer()
  reducedDataset <- aDataset[mask,] %>% na.omit()
  
  return(reducedDataset)
}


#-------------------------------------------------------------------------------
# Load data
#-------------------------------------------------------------------------------
dataFlights <- fetchData()

#-------------------------------------------------------------------------------
# Pre-processing
#-------------------------------------------------------------------------------

# Feature selection model I
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
flightsDataset <- reduceDataset(flightsDataset, 8000)


# Feature selection model II - LGA
LGADataset <- dataFlights %>%
  filter(origin == 'LGA') %>%
  transmute(month, 
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
            dep_delay
            ) %>%
  na.omit()

LGADataset <- reduceDataset(LGADataset, 8000)

# Feature selection model II - JFK
JFKDataset <- dataFlights %>%
  filter(origin == 'JFK') %>%
  transmute(month, 
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
            dep_delay
  ) %>%
  na.omit()

JFKDataset <- reduceDataset(JFKDataset, 8000)

# Feature selection model II - EWR
EWRDataset <- dataFlights %>%
  filter(origin == 'EWR') %>%
  transmute(month, 
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
            dep_delay
  ) %>%
  na.omit()

EWRDataset <- reduceDataset(EWRDataset, 8000)


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

vertraging_model_lga <- randomForest(
  formula = dep_delay ~ .,
  data = LGADataset
)

vertraging_model_jfk <- randomForest(
  formula = dep_delay ~ .,
  data = JFKDataset
)

vertraging_model_ewr <- randomForest(
  formula = dep_delay ~ .,
  data = EWRDataset
)
#-------------------------------------------------------------------------------
# Export importance
#-------------------------------------------------------------------------------

write.csv2(vertraging_model$importance, "app/data/importance_model_I.csv")

write.csv2(vertraging_model_lga$importance, "app/data/importance_model_II_lga.csv")
write.csv2(vertraging_model_jfk$importance, "app/data/importance_model_II_jfk.csv")
write.csv2(vertraging_model_ewr$importance, "app/data/importance_model_II_ewr.csv")
