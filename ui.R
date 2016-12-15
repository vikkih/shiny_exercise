# load packages
library(shiny)

shinyUI(fluidPage(
  # define UI page title
  titlePanel("Legco2016 App"),
  
  # define UI layout
  sidebarLayout(
  
  	# sidebar panel is for getting user input
    sidebarPanel(
      
      # help message for user
      helpText("Select geographical constituencies."),
    
      # definition of check box; by default "Overall" is checked in UI
      # user selections are saved to variable const
      checkboxGroupInput("const", label="Constituencies",
                         choices = list("Overall" = 1, "Hong Kong Island" = 2,
                                        "Kowloon West" = 3, "Kowloon East" = 4,
                                        "New Territories West" = 5, "New Territories East" = 6),
                         selected = 1)

    ),
    
    # main panel is for displaying plotted graph
    mainPanel(plotOutput("plot")
              )
  )
))