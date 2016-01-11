
library(shiny)

data(MisLinks)
data(MisNodes)

#### Server ####
server <- function(input, output) {

  setwd("~/Documents/projects/FY16/cpAOP")
  x <- read.table("FLcpAOPchemisect.txt", sep="\t", header=TRUE)
  x_nodes <- c(as.vector(x$V1), as.vector(x$V2))
  x_nodes_unique <- unique(x_nodes)
  x_nodes_df <- data.frame(name=x_nodes_unique, group=1, size=1)

  which_apply <- function(link_vector, unique_nodes){
    return(which(unique_nodes == link_vector)-1)
  }

  x_links_source <- sapply(as.vector(x$V1), which_apply, x_nodes_unique)
  x_links_target <- sapply(as.vector(x$V2), which_apply, x_nodes_unique)
  x_links_df <- data.frame(source=x_links_source, target=x_links_target, value=1)

  output$force <- renderAop({
    aopxplorer(Links = x_links_df, Nodes = x_nodes_df, Source = "source",
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
                  max = 1, step = .1),
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
