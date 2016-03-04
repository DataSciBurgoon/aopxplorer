library(shiny)
library(jsonlite)

json_aopns <- fromJSON("http://localhost:3000/networks")

#### Server ####
server <- function(input, output, session) {

  aopns <- NULL

  observeEvent(input$go, {
    print(input$network)
    network_scrubbed <- gsub(" ", "%20", isolate(input$network))
    print(network_scrubbed)
    aopns <- fromJSON(paste("http://localhost:3000/networks/", network_scrubbed, sep=""))
    aopns$nodes <- data.frame(name=aopns$nodes, group=1)
    output$force <- renderAop({
      #This catches the input file
      inFile <- input$file1
      if(is.null(inFile)){
        print("yo!")
        #This sends the info to the UI to render the AOP
        aopxplorer(Links = aopns$links, Nodes = aopns$nodes,
                   Source = "source", Target = "target", Value = 1,
                   NodeID = "name", Group = "group", opacity = 100)
      }
      else{
        #This reads in the input data file
        data_with_group <- read.csv(inFile$datapath, header=TRUE, sep="\t")

        #This updates the group assignments
        #The sorts are VERY important to make sure everything gets mapped to the right place
        #This does not allow for incomplete input files -- there needs to be a line for every node!!
        aopns$nodes <- data_with_group[match(aopns$nodes$name, data_with_group$name),]
        print(aopns$nodes)
        aopxplorer(Links = aopns$links, Nodes = aopns$nodes,
                   Source = "source", Target = "target", Value = 1,
                   NodeID = "name", Group = "group", opacity = 100)
      }

    })
  })

}

#### UI ####

ui <- shinyUI(fluidPage(

  tags$img(src="http://localhost:3000/modules/core/img/brand/aopxplorer_logo.png", width="25%", height="25%"),

  titlePanel("Explore AOP Networks with Your Data"),

  sidebarLayout(
    sidebarPanel(
      selectInput('network', 'Choose AOP Network', json_aopns$ao_label$value),
      fileInput('file1', 'Choose CSV File [optional]', accept=c('text/csv',
                                                     'text/comma-separated-values,text/plain', '.csv')),
      actionButton("go", "Go!")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Force Network", aopOutput("force"))
      )
    )
  )
))

#### Run ####
app <- shinyApp(ui = ui, server = server)
runApp(app, port=7600)



