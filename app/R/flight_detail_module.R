#' Flights details Module
#'
#' Module displaying detailed information of flights
#'
#' @param modalTitle string - the title for the modal dialog
#' @param flight reactive containing a row of the flights data frame
#' @param airports named vector used as a look-up table for full airport names
#' @param modalTrigger reactive trigger to open the modal dialog
#'
#' @return None
#'
#'
flightDetailModuleServer <- function(id, 
                                     modalTitle, 
                                     flight,
                                     airports,
                                     modalTrigger) {
  
  moduleServer(id, 
               function(input, output, session) {
                
                 origin <- reactive({
                   airports[[flight()$origin]]
                 })
                 
                 destination <- reactive({
                   writeDestinationDisplayName(airports, flight()$dest)
                 })
                 
                 observeEvent(modalTrigger(), {
                   showModal(
                     modalDialog(
                       div(style = "padding: 30px;",
                           fluidRow(
                             
                             HTML(printFlightCard(flight(), origin(), destination())),
                             
                             ) # Close fluid row
                           ), # Close div
                       title = modalTitle,
                       size = 'm',
                       footer = list(modalButton('Sluiten')) 
                     ) # Close modal dialog
                   ) # Close showModal
                 }) # Close modal trigger
               }) # Close module server
  
} # End flightDetailModuleServer
