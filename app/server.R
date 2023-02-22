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
  flights <- reactive({
    conn %>%
      dbGetQuery(writeQueryForFlightsWithFilters(aFlight = input$flight_number))
  })
  
  
  output$flights_table <- renderDT({
    
    flights() %>%
      filter(origin == input$origin) %>%
      transmute(flight, origin, dest, sdISO(ymd_hms(time_hour))) %>%
      datatable(rownames = FALSE,
                colnames = c('Vlucht', 'Van', 'Naar', 'Datum'),
                selection = "single",
                class = "compact stripe row-border nowrap",
                #escape = -1,  # Escape the HTML in all except 1st column (which has the buttons)
                options = list(scrollX = TRUE,
                               dom = 'ftp',
                               pageLength = 10,
                               language = list(emptyTable = "Geen vlucht gevonden",
                                               zeroRecords = "Geen vlucht gevonden",
                                               paginate = list(`next` = 'Volgende',
                                                               previous = 'Vorige'),
                                               search = 'Zoeken: ')
                               )
                ) 
    
  })
}