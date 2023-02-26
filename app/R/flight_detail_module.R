flightDetailModuleServer <- function(id, 
                                     modal_title, 
                                     flight,
                                     modal_trigger) {
  
  moduleServer(id, 
               function(input, output, session) {
                
                 observeEvent(modal_trigger(), {
                   showModal(
                     modalDialog(
                       div(style = "padding: 30px;",
                           fluidRow(
                             
                             HTML(printFlightCard(flight())),
                             
                             ) # Close fluid row
                           ), # Close div
                       title = modal_title,
                       size = 'l',
                       footer = list(modalButton('Sluiten')) 
                     ) # Close modal dialog
                   ) # Close showModal
                 }) # Close modal trigger
               }) # Close module server
  
} # End flightDetailModuleServer
