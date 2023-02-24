#-------------------------------------------------------------------------------
# Header
#-------------------------------------------------------------------------------
header <- dashboardHeader(
  dropdownMenu(type = "messages",
               headerText = "U hebt nieuwe berichtjes",
               messageItem(
                 from = "Alonso M. Acuña",
                 message = "Historical facts for February 3rd",
                 href = "https://en.wikipedia.org/wiki/Super_Bowl_XLVII"
               ),
               messageItem(
                 from = "Alonso M. Acuña",
                 message = "Historical facts for February 9th",
                 href = "https://en.wikipedia.org/wiki/February_2013_North_American_blizzard"
               )),
  dropdownMenu(type = "notifications",
               headerText = "U hebt nieuwe notificaties",
               notificationItem(text = "Welkom notificatie bijgevoegd",
                                href = "https://dict.leo.org/french-english/area"))
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
    HTML("<h4><b>>>>>Inputs</b></h4>"),
    conditionalPanel('input.sidebar_menu == "drukte_tab" || input.sidebar_menu == "map_tab"',
                     selectInput("origin",
                                 "Vanaf",
                                 choices = c(""))
    
    )
  )
)

#-------------------------------------------------------------------------------
# Dashboard Body
#-------------------------------------------------------------------------------
body <- dashboardBody(
  tabItems(
    tabItem(tabName = "home_tab",
            box(id = "welkom_note_box",
                width = 12,
                background = 'black',
                title = HTML(printTitle),
                tabPanel("",
                         HTML(printGreeting)))),
    tabItem(tabName = "drukte_tab",
            box(width = 4,
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
              
              ), # Close fluid row
            tags$br(),
            tags$br(),
            tags$br(),
            fluidRow(
              box(width = 12, 
                leafletOutput("destinations_map") %>% withSpinner())
              ) # Close fluid row
    ),
    tabItem(tabName = "flights_tab",
            box(width = 3,
                numericInput("flight_number",
                             "Vluchtnummer",
                             min = 1,
                             value = NULL)
                ),
            box(width = 3,
                HTML('<b>Vanaf</b>'),
                checkboxInput("origin_jfk", 
                              'JFK'),
                checkboxInput("origin_lga", 
                              'La Guardia'),
                checkboxInput("origin_ewr", 
                              'Newark')
                ),
            box(width = 3,
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

ui <- dashboardPage(header, sidebar, body)