#-------------------------------------------------------------------------------
# Header
#-------------------------------------------------------------------------------
header <- dashboardHeader(title = "",
                          dropdownMenu(type = "messages",
                                       headerText = "U hebt nieuwe berichtjes",
                                       messageItem(
                                         from = "Wiki fact",
                                         message = "February 3rd, 2023",
                                         href = linkSuperBowl
                                       ),
                                       messageItem(
                                         from = "Wiki fact",
                                         message = "February 9th, 2023",
                                         href = linkBlizzard
                                       )),
                          tags$li(a(href = linkNZa,
                                    img(src = 'nza-logo.png',
                                        title = "Ga naar NZa", height = "30px"),
                                    style = "padding-top:10px; padding-bottom:10px;"),
                                  class = "dropdown")
  
)

#-------------------------------------------------------------------------------
# Sidebar
#-------------------------------------------------------------------------------
sidebar <- dashboardSidebar(
  HTML("<h4><b>>>>>Navigatie</b></h4>"),
  sidebarMenu(id = "sidebar_menu",
    menuItem("Welkom!",
             tabName = "home_tab"),
    menuItem("Vliegvelddrukte",
             tabName = "drukte_tab"),
    menuItem("Vertraging",
             tabName = "vertraging_tab"),
    menuItem("Destinaties",
             tabName = "map_tab"),
    menuItem("Vluchtinformatie",
             tabName = "flights_tab"),
    conditionalPanel('input.sidebar_menu == "drukte_tab" || input.sidebar_menu == "map_tab" ||
                     input.sidebar_menu == "vertraging_tab"',
                     HTML("<h4><b>>>>>Inputs</b></h4>"),
                     selectInput("origin",
                                 "Vliegend vanaf",
                                 choices = c(""))
    
    )
  )
)

#-------------------------------------------------------------------------------
# Dashboard Body
#-------------------------------------------------------------------------------
body <- dashboardBody(
  useShinyFeedback(),
  tabItems(
    tabItem(tabName = "home_tab",
            box(id = "welkom_note_box",
                width = 12,
                title = HTML(printTitle),
                tabPanel("",
                         HTML(printGreeting)))),
    tabItem(tabName = "drukte_tab",
            fluidRow(
              box(width = 4,
                  background = 'navy',
                  dateRangeInput("date_zoom",
                                 label = "Daten",
                                 start = "2013-01-01",
                                 end = "2013-02-01",
                                 separator = "t/m",
                                 language = "nl"))
            ), # Close fluid row
            fluidRow(
              box(width = 12,
                  plotOutput("occupancy_plot", height = '22em') %>% withSpinner())
            ), # Close fluid row
            fluidRow(
              box(width = 12,
                  plotOutput("capacity_plot", height = '12em') %>% withSpinner())
              ) # Close fluid row
            ),
    tabItem(tabName = "vertraging_tab",
            fluidRow(
              tabBox(
                side = "right", height = "450px",
                selected = "Analyse Team A",
                tabPanel("Analyse Team A", 
                         plotOutput("importance_I", height = '35em') %>% withSpinner()),
                tabPanel("Analyse Team B", 
                         plotOutput("importance_II", height = '35em') %>% withSpinner())
                ), # Close tabbox
              box(HTML(printVertragingText))
              ) # Close fluid row
            ),
    tabItem(tabName = "map_tab",
            fluidRow(
              box(width = 12,
                  title = "Overzicht destinaties",
                leafletOutput("destinations_map") %>% withSpinner())
              ) # Close fluid row
    ),
    tabItem(tabName = "flights_tab",
            fluidRow(
              box(width = 3,
                  background = 'navy',
                  dateRangeInput("date_of_interest",
                                 label = "Daten",
                                 start = "2013-01-01",
                                 end = "2013-02-01",
                                 separator = "t/m",
                                 language = "nl")),
              box(width = 3,
                  background = 'navy',
                  HTML('<b>Vliegend vanaf</b>'),
                  checkboxInput("origin_jfk", 
                                'JFK',
                                value = FALSE),
                  checkboxInput("origin_lga", 
                                'La Guardia',
                                value = TRUE),
                  checkboxInput("origin_ewr", 
                                'Newark',
                                value = FALSE)
              ),
              box(width = 3,
                  background = 'navy',
                  numericInput("flight_number",
                               "Vluchtnummer",
                               min = 1,
                               value = NULL)
              )
            ), # Close fluid row
            fluidRow(
              box(width = 9,
                  DTOutput("flights_table") %>% withSpinner()),
              tags$script(src = "flights_table_module.js"),
              tags$script(paste0("flights_table_module_js('')"))
              )
            ) # Close fluid row
    ) # Close tabItems
  ) # Close dasboardBody

#-------------------------------------------------------------------------------
# Call UI
#-------------------------------------------------------------------------------
ui <- dashboardPage(header = header, 
                    sidebar = sidebar, 
                    body = body, 
                    skin = "black")