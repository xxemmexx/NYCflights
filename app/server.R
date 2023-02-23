server <- function(input, output, session) {
  #-----------------------------------------------------------------------------
  # Vliegvelddrukte
  #-----------------------------------------------------------------------------
  
  seats <- reactive({
    conn %>%
      dbGetQuery(writeQueryForSeats())
  })
  
  actualOccupancy <- reactive({
    seats() %>%
      transmute(origin,
                date = ymd_hms(time_hour) %>% as.Date(),
                dayOfYear = yday(date),
                occupancy = computeOccupancy(date, as.numeric(seats))) %>%
      filter(between(date, 
                     ymd(input$date_zoom[1]), 
                     ymd(input$date_zoom[2]))) %>%
      group_by(dayOfYear) %>%
      summarise(nettoccupied = sum(occupancy)) %>%
      ungroup()
    
  })
  
  # output$occupancy_table <- renderDT({
  #   actualOccupancy() %>%
  #     datatable(rownames = FALSE,
  #               colnames = c('Van', 'Datum', 'Day Index', 'Seats'),
  #               selection = "none",
  #               class = "compact",
  #               options = list(scrollX = TRUE,
  #                              dom = 'tp'
  #               )
  #     )
  # })
  
  output$occupancy_plot <- renderPlot({
    actualOccupancy() %>%
      ggplot(aes(x = dayOfYear, y = nettoccupied)) +
      geom_point()
  })
  
  tr <- tribble(~a, ~b,
          1, 3,
          1, 6,
          2, 5,
          2, 19)
  
  tr %>%
    group_by(a) %>%
    summarise(n = sum(b))
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