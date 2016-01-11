library(shiny)
library(RCurl)
library(jsonlite)

data(MisLinks)
data(MisNodes)

json_aopns <- fromJSON("http://localhost:3000/networks")

#### Server ####
server <- function(input, output, session) {
  #observeEvent(input$go, {
    print("here")
    json_aopn_specific <- reactive({
      aopns <- fromJSON(paste("http://localhost:3000/networks/", isolate(input$network)))
      print("here2!")
      return(aopns)
    })
  #})


    observeEvent(input$go, {
      print(input$network)
      network_scrubbed <- gsub(" ", "%20", isolate(input$network))
      print(network_scrubbed)
      aopns <- fromJSON(paste("http://localhost:3000/networks/", network_scrubbed, sep=""))
      output$force <- renderAop({
        print(aopns)
        aopxplorer(Links = aopns$links, Nodes = aopns$nodes,
                   Source = "source", Target = "target", Value = 1,
                   NodeID = "name", Group = 1, opacity = 100)
      })
    })






}

#### UI ####

ui <- shinyUI(fluidPage(

  titlePanel("Shiny AOPNetwork "),

  sidebarLayout(
    sidebarPanel(
      selectInput('network', 'Choose AOP Network', json_aopns$ao_label$value),
      actionButton("go", "Go!"),
      fileInput('file1', 'Choose CSV File', accept=c('text/csv',
                                                     'text/comma-separated-values,text/plain', '.csv'))
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
