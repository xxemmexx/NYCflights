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
             tabName = "flights_tab"),
    HTML("<h4><b>>>>>Inputs</b></h4>")
    
  )
)

#-------------------------------------------------------------------------------
# Dashboard Body
#-------------------------------------------------------------------------------
body <- dashboardBody(
  tabItems(
    tabItem(tabName = "home_tab",
            box(id = "welkom_note_box",
                   width = 6,
                   title = HTML('<h3 style="text-align:center">Welkom in de NYC Dashboard <h3><br> <h4 style="text-align:center">Al de informatie over je vluchten vanuit NYC in één plek!</h4><br><br>'),
                   tabPanel("",
                            "Bienvenidos todos"))),
    tabItem(tabName = "flights_tab",
            box(width = 3,
                numericInput("flight_number",
                             "Vluchtnummer",
                             min = 1,
                             value = NULL
                             )),
            box(width = 9,
                tableOutput("flights_table") %>% withSpinner()))
    ) # Close tabItems
  ) # Close dasboardBody

ui <- dashboardPage(header, sidebar, body)