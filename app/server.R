server <- function(input, output, session) {
  
  flights <- reactive({
    conn %>%
      dbGetQuery(writeFlightsQuery(aFlight = input$flight_number))
  })
  
  output$flights_table <- renderTable({
    
    flights() %>%
      head(10)
    
  })
}