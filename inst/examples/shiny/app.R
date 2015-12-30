library(shiny)

data(MisLinks)
data(MisNodes)

#### Server ####
server <- function(input, output) {

  output$force <- renderAop({
    aopxplorer(Links = MisLinks, Nodes = MisNodes, Source = "source",
                 Target = "target", Value = "value", NodeID = "name",
                 Group = "group", opacity = input$opacity)
  })

}

#### UI ####

ui <- shinyUI(fluidPage(

  titlePanel("Shiny AOPNetwork "),

  sidebarLayout(
    sidebarPanel(
      sliderInput("opacity", "Opacity (not for Sankey)", 0.6, min = 0.1,
                  max = 1, step = .1)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Force Network", aopOutput("force"))
      )
    )
  )
))

#### Run ####
shinyApp(ui = ui, server = server)
