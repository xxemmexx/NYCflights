server <- function(input, output, session) {
  
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
                      choices = c("", origins()),
                      selected = "")
  })
  
  destinations <- reactive({
    conn %>%
      dbGetQuery(writeQueryForDestinations(anOrigin = input$origin))
  })
  
  #-----------------------------------------------------------------------------
  # Vluchtinformatie
  #-----------------------------------------------------------------------------
  originsFilter <- reactive({
    origins <- c('JFK', 'EWR', 'LGA')
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