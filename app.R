# Load packages ----
library(shiny)
library(tidyverse)
library(sevenbridges)

# Source helpers ----
source("helpers.R")

# User interface ----
ui <- fluidPage(

  titlePanel("CAVATICA Billing"),

  wellPanel(textInput("token",
                      label = "Token",
                      value = "Enter token...")),
  br(),
  br(),


  # Multi-panel for adaptive coding

  fluidRow(
    column(4,
           h3("Billing Group Name")),
    column(4,
           h3("Remaining Funds")),
    column(4,
           h3("Funds Used")),
  ),

  uiOutput("groups"),

  p("**Funds used assumes initial funding = $2000",
    align = "right")

)




# Server logic
server <- function(input, output) {

  # running "billing api" to get the data
  dataInput <- reactive({
    if (input$token ==  "Enter token..." || input$token == "")
      return(NULL)

    billing_api(input$token)
  })


  # Multi-panel for adaptive coding

  # Running a new wellPanel for each billing group
  output$groups <- renderUI({
    output_list <- lapply(seq_along(dataInput()), function(x){
      plotname <- paste("plot_", x, sep = "")
      breakdownname <- paste("breakdown_", x, sep="")
      analysis_table <- paste("analysis_", x, sep="")
      storage_table <- paste("storage_", x, sep="")

      wellPanel(
        fluidRow(
          column(4,
                 h4(names(dataInput()[x]))),

          column(4,
                 h4(sprintf("$%0.2f %3s", dataInput()[[x]]$summary$balance$amount, dataInput()[[2]]$summary$balance$currency))),

          column(4,
                 plotOutput(plotname, height = 50)),
        ),


        fluidRow(
            column(12,
                   tabsetPanel(
                     tabPanel("Hide Breakdown", ""),
                     tabPanel("Overview", "Price Graph Placeholder"),
                     tabPanel("Analysis", dataTableOutput(analysis_table) ),
                     tabPanel("Storage", dataTableOutput(storage_table)),
                     tabPanel("Egress", "None")
                   ))), style = "padding: 5px;"
        )

    })

    do.call(tagList, output_list)
  })




  observe(

    lapply(seq_along(dataInput()), function(y) {

      # assume limit is $2000 for now
      limit = 2000
      balance = dataInput()[[y]]$summary$balance$amount
      status_bar = data.frame(balance = 1 - (balance/limit))


      output[[paste0("plot_", y, sep="")]] <- renderPlot({
        ggplot(data = status_bar, aes(x = NA, y = balance, fill = balance))+geom_bar(stat="identity")+
          xlab("")+
          ylab("")+
          theme_bw()+
          theme(axis.ticks = element_blank(),
                axis.text = element_blank(),
                panel.grid = element_blank(),
                panel.background = element_blank(),
                legend.position = "none")+
          scale_x_discrete(expand = c(0,0))+
          scale_y_continuous(limits = c(0,1), expand = c(0,0))+
          scale_fill_gradient(low = "green", high = "red", limits = c(0,1))+
          coord_flip()
      })

        output[[paste0("analysis_", y, sep="")]] <- renderDataTable({
          data.frame(`Analysis Type` = sapply(dataInput()[[y]]$analysis$items, function(x) x$analysis_type),
                     `Project Name` = sapply(dataInput()[[y]]$analysis$items, function(x) x$project_name),
                     `Analysis Name` = sapply(dataInput()[[y]]$analysis$items, function(x) x$analysis_name),
                     `Ran By` = sapply(dataInput()[[y]]$analysis$items, function(x) x$ran_by),
                     Cost = sapply(dataInput()[[y]]$analysis$items, function(x) x$analysis_cost$amount),
                     Currency = sapply(dataInput()[[y]]$analysis$items, function(x) x$analysis_cost$currency))
        })


        output[[paste0("storage_", y, sep="")]] <- renderDataTable({
          data.frame(Active = sapply(dataInput()[[y]]$storage$items, function(x) x$active$size),
                     Archive = sapply(dataInput()[[y]]$storage$items, function(x) x$archived$size),
                     Location = sapply(dataInput()[[y]]$storage$items, function(x) x$location),
                     `Project Name` = sapply(dataInput()[[y]]$storage$items, function(x) x$project_name),
                     `Created By` = sapply(dataInput()[[y]]$storage$items, function(x) x$project_created_by))
          })

    })
  )

}

# Run the app
shinyApp(ui, server)
