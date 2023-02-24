#-------------------------------------------------------------------------------
# Header
#-------------------------------------------------------------------------------
header <- dashboardHeader(title = tags$li(a(href = 'http://shinyapps.company.com',
                                            icon("plane"),
                                            title = "NYCFlights"),
                                          class = "dropdown"),
                          tags$li(a(href = 'http://www.nza.nl',
                                    img(src = 'nza-logo.png',
                                        title = "Ga naar NZa", height = "30px"),
                                    style = "padding-top:10px; padding-bottom:10px;"),
                                  class = "dropdown"),
                          dropdownMenu(type = "messages",
                                       headerText = "U hebt nieuwe berichtjes",
                                       messageItem(
                                         from = "Wiki fact",
                                         message = "February 3rd, 2023",
                                         href = "https://en.wikipedia.org/wiki/Super_Bowl_XLVII"
                                       ),
                                       messageItem(
                                         from = "Wiki fact",
                                         message = "February 9th, 2023",
                                         href = "https://en.wikipedia.org/wiki/February_2013_North_American_blizzard"
                                       )),
                          dropdownMenu(type = "notifications",
                                       headerText = "U hebt nieuwe notificaties",
                                       notificationItem(text = "Voorzicht! Deze applicatie is kapot. Klik hier voor een betere versie!",
                                                        href = "emme.shinyapps.io/rebozos"))
  
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
    menuItem("Destinaties",
             tabName = "map_tab"),
    menuItem("Vluchtinformatie",
             tabName = "flights_tab"),
    conditionalPanel('input.sidebar_menu == "drukte_tab" || input.sidebar_menu == "map_tab"',
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
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "stylesheet.css")
  ),
  useShinyFeedback(),
  tabItems(
    tabItem(tabName = "home_tab",
            box(id = "welkom_note_box",
                width = 12,
                title = HTML(printTitle),
                tabPanel("",
                         HTML(printGreeting)))),
    tabItem(tabName = "drukte_tab",
            box(width = 4,
                background = 'navy',
                dateRangeInput("date_zoom",
                               label = "Daten",
                               start = "2013-01-01",
                               end = "2013-02-01",
                               separator = "t/m",
                               language = "nl")),
            box(width = 12,
                plotOutput("occupancy_plot") %>% withSpinner()),
            box(width = 12,
                plotOutput("capacity_plot", height = '14em') %>% withSpinner())
            # box(width = 9,
            #     DTOutput("occupancy_table") %>% withSpinner())
            ),
    tabItem(tabName = "map_tab",
            fluidRow(
              box(width = 12,
                  title = "Overzicht destinaties",
                leafletOutput("destinations_map") %>% withSpinner())
              ) # Close fluid row
    ),
    tabItem(tabName = "flights_tab",
            box(width = 3,
                background = 'navy',
                numericInput("flight_number",
                             "Vluchtnummer",
                             min = 1,
                             value = NULL)
                ),
            box(width = 3,
                background = 'navy',
                HTML('<b>Vliegend vanaf</b>'),
                checkboxInput("origin_jfk", 
                              'JFK'),
                checkboxInput("origin_lga", 
                              'La Guardia'),
                checkboxInput("origin_ewr", 
                              'Newark')
                ),
            box(width = 3,
                background = 'navy',
                dateRangeInput("date_of_interest",
                               label = "Daten",
                               start = "2013-01-01",
                               end = "2013-12-31",
                               separator = "t/m",
                               language = "nl")),
            box(width = 9,
                DTOutput("flights_table") %>% withSpinner()))
    ) # Close tabItems
  ) # Close dasboardBody

ui <- dashboardPage(header = header, 
                    sidebar = sidebar, 
                    body = body, 
                    skin = "black")