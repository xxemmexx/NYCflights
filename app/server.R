server <- function(input, output, session) {
  #-----------------------------------------------------------------------------
  # Vliegvelddrukte
  #-----------------------------------------------------------------------------
  
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
                randomPassengers = floor(runif(n = lengthSeats, min = -10, max = 10)),
                variance = if_else(seats < 56, 0, randomPassengers),
                nettoOccupancy = occupancy + variance) %>%
      group_by(dayOfYear) %>%
      summarise(`netto` = sum(nettoOccupancy)/100, 
                date = date) %>%
      ungroup()
    
  })
  
  # output$occupancy_table <- renderDT({
  #   
  #   lengthSeats <- nrow(seats())
  #   
  #   seats() %>%
  #     transmute(origin,
  #               date = ymd_hms(time_hour) %>% as.Date(),
  #               dayOfYear = yday(date),
  #               occupancy = computeOccupancy(date, as.numeric(seats)),
  #               randomPassengers = floor(runif(n = lengthSeats, min = -6, max = 6)),
  #               variance = if_else(seats < 56, 0, randomPassengers),
  #               nettoOccupancy = occupancy + variance) %>%
  #     datatable(rownames = FALSE,
  #               colnames = c('Van', 'Datum', 'Day Index', 'Seats', 'Ran', 'netto'),
  #               selection = "none",
  #               class = "compact",
  #               options = list(scrollX = TRUE,
  #                              dom = 'tp'
  #               )
  #     )
  # })
  
  output$occupancy_plot <- renderPlot({
    actualOccupancy() %>%
      ggplot(aes(x = date, y = `netto`)) +
      geom_point() + geom_line() +
      ggtitle(getTitleForOccupancyPlot(selectedOrigin()$name, input$date_zoom[1], input$date_zoom[2])) +
      xlab("") + ylab("Aantal passagieren (x100)") +
      theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5)) +
      theme(axis.title.x = element_text(size = 12, face = "bold")) +
      theme(axis.title.y = element_text(size = 12, face = "bold")) +
      theme(axis.text.x= element_text(face = "bold", size = 12)) +
      theme(axis.text.y= element_text(face = "bold", size = 12))
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
    origins <- origins()$faa
    mask <- c(input$origin_jfk, input$origin_ewr, input$origin_lga)
    
    origins[mask]
  })
  
  flights <- reactive({
    preFiltersQuery <- writeQueryForFlightsWithFilters(aFlight = input$flight_number,
                                                        origins = originsFilter())
    
      dbGetQuery(conn, preFiltersQuery) %>%
        filter(between(as.Date(ymd_hms(time_hour)), 
                   ymd(input$date_of_interest[1]), 
                   ymd(input$date_of_interest[2])))
  })
  
  
  output$flights_table <- renderDT({
    
    flights() %>%
      transmute(flight, origin, dest, sdISO(ymd_hms(time_hour))) %>%
      datatable(rownames = FALSE,
                colnames = c('Vlucht', 'Van', 'Naar', 'Datum'),
                selection = "single",
                class = "compact stripe row-border nowrap",
                #escape = -1,  # Escape the HTML in all except 1st column (which has the buttons)
                options = list(scrollX = TRUE,
                               dom = 'ftp',
                               pageLength = 10,
                               initComplete = jsHeader,
                               language = list(emptyTable = "Geen vlucht gevonden",
                                               zeroRecords = "Geen vlucht gevonden",
                                               paginate = list(`next` = 'Volgende',
                                                               previous = 'Vorige'),
                                               search = 'Zoeken: ')
                               )
                ) 
    
  })
}