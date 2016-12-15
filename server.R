# server.R

# source scripts
source("plot_turnout.R")


# define input/output
shinyServer(function(input, output) {

    output$plot <- renderPlot({
      
                    plot_graph(input$const)
      
  })

  
})