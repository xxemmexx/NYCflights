flightDetailModuleServer <- function(id, 
                                     modal_title, 
                                     flight,
                                     modal_trigger) {
  
  moduleServer(id, 
               function(input, output, session) {
                 
                 #ns <- session$ns
                
                 observeEvent(modal_trigger(), {
                   
                   hold <- flight()
                   
                   showModal(
                     modalDialog(
                       div(style = "padding: 30px;",
                           fluidRow(
                             
                             HTML(paste0("<h3 style=text-align:center;><b>Vlucht nr. ", hold$flight, "</b></h3>")),
                             tags$br(),
                             tags$br(),
                             HTML(paste0('<h4 style=text-align:left;><i class="fa fa-plane-departure"></i> - Vertrek</h4>')),
                             tags$hr(),
                             HTML(paste0('<h4 style=text-align:left;><i class="fa fa-plane-arrival"></i> - Aankomst</h4>')),
                             tags$br()
                             )
                           ), # Close div
                       title = modal_title,
                       size = 'l',
                       footer = list(modalButton('Sluiten')) 
                     ) # Close modal dialog
                   ) # Close showModal
                 }) # Close modal trigger
               }) # Close module server
  
} # End flightDetailModuleServer
