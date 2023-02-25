#' Add & Edit Module
#'
#' Module to add & edit dossiers in the patients database file
#'
#' @importFrom shiny observeEvent showModal modalDialog removeModal fluidRow column textInput numericInput selectInput modalButton actionButton reactive eventReactive
#' @importFrom shinyFeedback showFeedbackDanger hideFeedback showToast
#' @importFrom shinyjs enable disable
#' @importFrom lubridate with_tz
#' @importFrom uuid UUIDgenerate
#' @importFrom DBI dbExecute
#'
#' @param modal_title string - the title for the modal
#' @param rendezvous_patient reactive returning a 1 row data frame of the dossier to edit
#' @param modal_trigger reactive trigger to open the modal (Add or Edit buttons)
#'
#' @return None
#'
flightDetailModuleServer <- function(id, 
                                     modal_title, 
                                     flight, 
                                     modal_trigger) {
  
  moduleServer(id, 
               function(input, output, session) {
                 
                 ns <- session$ns
                 
                 ############# MODAL TRIGGER #################################
                 observeEvent(modal_trigger(), {
                   
                   hold <- flight()
                  
                   #------------FILL-IN FORM----------------------------------
                   
                   showModal(
                     modalDialog(
                       div(style = "padding: 30px;",
                           fluidRow(
                             
                             HTML(paste0("<h4 style=text-align:center;>Nouveau rendez-vous pour M./Mme. ",
                                         hold$origin, " ", hold$destination, "</h4>")),
                             tags$br(),
                             tags$br()
                             )
                           ), # Close div
                       title = modal_title,
                       size = 'l',
                       footer = list(modalButton('Annuler')) 
                     ) # Close modal dialog
                   ) # Close showModal
                   
                   
                   
                 }) # Close modal trigger
                 
                 
               }) # Close module server
  
} # End dossiersEditModuleServer
