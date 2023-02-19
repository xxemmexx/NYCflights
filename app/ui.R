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

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Welkom!",
             tabName = "home"),
    menuItem("Gegevens",
             tabName = "data"),
    HTML("Input")
    
  )
)

body <- dashboardBody(tabItems(
  tabItem(tabName = "home",
          tabBox(id = "welkom_note",
                 width = 12,
                 title = "Welkom in de nieuwe wereld van dataanalyse!",
                 tabPanel("ES",
                          "Bienvenidos todos"),
                 tabPanel("NL",
                          "Welkom allemaal"))),
  tabItem(tabName = "data")
))

ui <- dashboardPage(header, sidebar, body)