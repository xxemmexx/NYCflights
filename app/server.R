server <- function(input, output, session) {
  #-----------------------------------------------------------------------------
  # Vliegvelddrukte
  #-----------------------------------------------------------------------------
  observeEvent(input$date_zoom, {
    if (input$date_zoom[1] > input$date_zoom[2]) {
      showFeedbackDanger("date_zoom",
                         text = "Let op: de volgorde van de daten klopt niet!")
    } else {
      hideFeedback("date_zoom")
    }
  })
  
  observeEvent(input$date_zoom, {
    if (input$date_zoom[1] < ymd('2013-01-01') | input$date_zoom[2] > ymd('2013-12-01')) {
      showFeedbackDanger("date_zoom",
                         text = "Let op: alleen data voor het jaar 2013 beschikbaar!")
    } else {
      hideFeedback("date_zoom")
    }
  })
  
  seats <- reactive({
    conn %>%
      dbGetQuery(writeQueryForSeats(selectedOrigin()$faa, 
                                    as.character(input$date_zoom[1]),
                                    as.character(input$date_zoom[2])))
  })
  
  actualOccupancy <- reactive({
    lengthSeats <- nrow(seats())
    
    seats() %>%
      transmute(origin,
                date = ymd_hms(time_hour) %>% as.Date(),
                dayOfYear = yday(date),
                occupancy = computeOccupancy(date, as.numeric(seats)),
                randomPassengers = floor(runif(n = lengthSeats, min = -85, max = 85)),
                variance = if_else(seats < 100, 0, randomPassengers),
                nettoOccupancy = occupancy + variance,
                percentageCapacity = round(nettoOccupancy/seats*100)) %>%
      group_by(dayOfYear) %>%
      summarise(date = date,
                netto = sum(nettoOccupancy)/100, 
                capacity = mean(percentageCapacity)) %>%
      ungroup()
    
  })
  
  output$occupancy_plot <- renderPlot({
    req(actualOccupancy(), selectedOrigin())
    
    actualOccupancy() %>%
      ggplot(aes(x = date, y = netto)) +
      geom_point() + geom_line() +
      ggtitle(getTitleForPlot("occupancy",
                              selectedOrigin()$name, 
                              input$date_zoom[1], 
                              input$date_zoom[2])) +
      xlab("") + ylab("Aantal passagieren (x100)") +
      theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5)) +
      theme(axis.title.x = element_text(size = 12, face = "bold")) +
      theme(axis.title.y = element_text(size = 12, face = "bold")) +
      theme(axis.text.x= element_text(face = "bold", size = 12)) +
      theme(axis.text.y= element_text(face = "bold", size = 12))
  })
  
  output$capacity_plot <- renderPlot({
    req(actualOccupancy(), selectedOrigin())
    
    actualOccupancy() %>%
      distinct() %>%
      ggplot(aes(x = date, y = capacity)) +
      geom_bar(stat='identity') +
      ggtitle(getTitleForPlot("capacity",
                              selectedOrigin()$name, 
                              input$date_zoom[1], 
                              input$date_zoom[2])) +
      xlab("") + ylab("% capaciteit") +
      theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5)) +
      theme(axis.title.x = element_text(size = 12, face = "bold")) +
      theme(axis.title.y = element_text(size = 12, face = "bold")) +
      theme(axis.text.x= element_text(face = "bold", size = 12)) +
      theme(axis.text.y= element_text(face = "bold", size = 12))
  })
  
  #-----------------------------------------------------------------------------
  # Vertraging
  #-----------------------------------------------------------------------------
  output$importance_I <- renderPlot({
    
    pathToDataModelI %>%
      readAndFormatData() %>%
      generateImportancePlot()
  })
  
  output$importance_II <- renderPlot({
    req(input$origin)
    
    input$origin %>%
      getPathForOrigin() %>%
      readAndFormatData() %>%
      generateImportancePlot()
  })
  
  #-----------------------------------------------------------------------------
  # Destinaties
  #-----------------------------------------------------------------------------
  origins <- reactive({
    conn %>%
      dbGetQuery(writeQueryForOrigins())
  })
  
  observe({
    updateSelectInput(session, 
                      "origin",
                      choices = c(origins()$faa))
  })
  
  destinations <- reactive({
    conn %>%
      dbGetQuery(writeQueryForDestinations(anOrigin = input$origin))
  })
  
  selectedOrigin <- reactive({
    origins() %>%
      filter(faa == input$origin)
  })
  
  output$destinations_map <- renderLeaflet({
    req(selectedOrigin(), destinations())
    
    leaflet() %>%
      addTiles() %>%
      addCircleMarkers(lng = selectedOrigin()$lon, 
                       lat = selectedOrigin()$lat,
                       radius = 5,
                       selectedOrigin()$name,
                       color = '#B22222',
                       popup = selectedOrigin()$name) %>%
      addCircleMarkers(lng = destinations()$lon, 
                       lat = destinations()$lat,
                       radius = 5,
                       destinations()$name,
                       color = '#2F4F4F',
                       popup = destinations()$name)
      
    
  })
  
  #-----------------------------------------------------------------------------
  # Vluchtinformatie
  #-----------------------------------------------------------------------------
  originsFilter <- reactive({
    origins <- origins()$faa %>% sort()
    mask <- c(input$origin_ewr, input$origin_jfk, input$origin_lga)
    
    origins[mask]
  })
  
  observeEvent(input$date_of_interest, {
    if (input$date_of_interest[1] > input$date_of_interest[2]) {
      showFeedbackDanger("date_of_interest",
                         text = "Let op: de volgorde van de daten klopt niet")
    } else {
      hideFeedback("date_of_interest")
    }
  })
  
  observeEvent(input$date_of_interest, {
    if (input$date_of_interest[1]  < ymd('2013-01-01') | input$date_of_interest[2] > ymd('2013-12-01')) {
      showFeedbackDanger("date_of_interest",
                         text = "Let op: alleen data voor het jaar 2013 beschikbaar!")
    } else {
      hideFeedback("date_of_interest")
    }
  })
  
  flights <- reactive({
    preFilteredQuery <- writeQueryForFlightsWithFilters(aFlight = input$flight_number,
                                                        origins = originsFilter())
    
    dbGetQuery(conn, preFilteredQuery) %>%
      filter(between(as.Date(ymd_hms(time_hour)), 
                     ymd(input$date_of_interest[1]), 
                     ymd(input$date_of_interest[2])))
  })
  
  airports <- reactive({
    
    airportLookUpTable <- dbGetQuery(conn, writeQueryForAirpots())
    
    airports <- airportLookUpTable$name
    
    names(airports) <- airportLookUpTable$faa
    
    airports
  })
  
  flights_table_display <- reactiveVal(NULL)
  
  observeEvent(flights(), {
    
    ids <- flights()$flight_id
    
    actions <- purrr::map_chr(ids, function(id_) {
      paste0('<div class="btn-group" style="width: 75px;" role="group">
              <button class="btn btn-primary btn-sm edit_btn" data-toggle="tooltip" data-placement="top" title="Vluchtinfo" id = ', id_, 
              ' style="margin:0;background:#2F4F4F;color:#FFE4B5;"><i class="fa fa-circle-info"></i></button></div>')
    })
    
    flightsTable <- flights() %>%
      transmute(sdISO(ymd_hms(time_hour)),
                flight,
                tailnum,
                origin = unname(airports()[origin]),
                destination = writeDestinationDisplayName(airports(), dest))
    
    flightsTable <- cbind(tibble(" " = actions), flightsTable)
    
    flights_table_display(flightsTable)
    
  })
  
  output$flights_table <- renderDT({
    req(flights_table_display())
    
    flights_table_display() %>%
      datatable(rownames = FALSE,
                colnames = c('Datum', 'Vluchtnr.', 'Kenteken', 'Van', 'Naar'),
                selection = "single",
                class = "compact stripe row-border nowrap",
                escape = -1,  
                options = list(scrollX = TRUE,
                               dom = 'ftp',
                               columnDefs = list(list(targets = 0, orderable = FALSE)),
                               pageLength = 10,
                               initComplete = jsHeader,
                               language = list(emptyTable = "Geen vlucht gevonden",
                                               zeroRecords = "Geen vlucht gevonden",
                                               paginate = list(`next` = 'Volgende',
                                                               previous = 'Vorige'),
                                               search = 'Zoeken: ')
                               ) # Close options list
                ) # Close datatable 
    
  })
  
  flight <- eventReactive(input$flight_id, {
    
    flights() %>%
      filter(flight_id == input$flight_id)
    
  })
  
  flightDetailModuleServer("show_details",
                           modalTitle = "Vluchtoverzicht",
                           flight = flight,
                           airports = airports(),
                           modalTrigger = reactive({input$flight_id})
                           )
}