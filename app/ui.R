#-------------------------------------------------------------------------------
# Header
#-------------------------------------------------------------------------------
header <- dashboardHeader(
  dropdownMenu(type = "messages",
               headerText = "U hebt nieuwe berichtjes",
               messageItem(
                 from = "M",
                 message = "Welcome to the analysis area!",
                 href = "https://dict.leo.org/french-english/area"
               )),
  dropdownMenu(type = "notifications",
               headerText = "U hebt nieuwe notificaties",
               notificationItem(text = "Welkom notificatie bijgevoegd",
                                href = "https://dict.leo.org/french-english/area")),
  dropdownMenu(type = "tasks",
               headerText = "Hoe ver ben je met je analyse?",
               taskItem(
                 text = "Je bent er bijna!",
                 value = 55
               ))
)

#-------------------------------------------------------------------------------
# Sidebar
#-------------------------------------------------------------------------------
sidebar <- dashboardSidebar(
  HTML("<h4><b>>>>>Navigatie</b></h4>"),
  sidebarMenu(
    menuItem("Welkom!",
             tabName = "home_tab"),
    menuItem("Vluchtinformatie",
             tabName = "flights_tab")
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
                   title = HTML(printTitle),
                   tabPanel("",
                            HTML(printGreeting)))),
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