flightDetailModuleServer <- function(id, 
                                     modal_title, 
                                     flight,
                                     airports,
                                     modal_trigger) {
  
  moduleServer(id, 
               function(input, output, session) {
                
                 origin <- reactive({
                   airports[[flight()$origin]]
                 })
                 
                 destination <- reactive({
                   writeDestinationDisplayName(airports, flight()$dest)
                 })
                 
                 observeEvent(modal_trigger(), {
                   showModal(
                     modalDialog(
                       div(style = "padding: 30px;",
                           fluidRow(
                             
                             HTML(printFlightCard(flight(), origin(), destination())),
                             
                             ) # Close fluid row
                           ), # Close div
                       title = modal_title,
                       size = 'm',
                       footer = list(modalButton('Sluiten')) 
                     ) # Close modal dialog
                   ) # Close showModal
                 }) # Close modal trigger
               }) # Close module server
  
} # End flightDetailModuleServer
