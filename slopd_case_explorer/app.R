# Libraries ----
library(shiny)
library(shinyWidgets)
library(tidyverse)
library(lubridate)
library(devtools)
library(usethis)
library(ggplot2)
library(here)
library(DT)


# load functions
source('scripts/functions/load_and_preprocess_data.R')
source('scripts/functions/filter_by_search.R')
source('scripts/functions/filter_by_date.R')
source('scripts/functions/count_by_date.R')
source('scripts/functions/count_by_type.R')
source('scripts/functions/create_frequency_plot.R')
source('scripts/functions/create_time_series_plot.R')

slopd_data <- load_and_preprocess_data(
  url = "https://raw.githubusercontent.com/nagol/SLOPD_data/main/data/csv/SLOPD_report.csv")

# UI ----
ui <- fluidPage(
  
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    
    title = "San Luis Obispo Police Department - Call Log Explorer",
  
    div(
      id = "header",
      class = "page-header",
      class = "container",
      h1("SLOPD Call Log Explorer"),
      p(
        class = "lead",
        "An Unofficial Data Exploration Tool"
      ),
      p(
        "The San Luis Obispo Police department publishes detailed records about
         interactions with the public. This tool is designed to make investigation
         of these data a little easier as well as providing a little context with
         historical data."
      ),
      p("There are many insights one can gain by seeing for oneself
         the struggles of their local community. Even a small, sleepy town
         like San Luis Obispo experiences daily disagreements, accidents, criminal acts, 
         and emergencies are a daily part of human life. The police are often the 
         first line of contact for many in times of distress and as such,
         police incident records provide a unique, raw vantage point of the 
         happenings in the community."), 
      p("What is really going on around SLO?")
    ),
  
    
    # main body ----
    div(

        class = "panel-body",
        
        # Sidebar
        column(
            width = 4, 
            
            p(em("Customize your search using the filters below.")),
            
            wellPanel(
              
              div(
                
                # type picker input ----
                pickerInput(inputId = "type_select_input", 
                            label = "Incident Type", 
                            choices = slopd_data %>% 
                              select(type) %>%
                              arrange(type) %>%
                              unique(), 
                            selected = slopd_data %>% 
                              filter(type != '9-1-1 ABANDON') %>% 
                              select(type) %>% 
                              unique() %>% 
                              pull(), 
                            multiple = TRUE,
                            options = list(`actions-box` = TRUE),
                            width = NULL, 
                            inline = FALSE),
                
                br(),
                
                # date airDatepicker input ----
                airDatepickerInput(
                    inputId = "date_select_input",
                    label = "Date (select range)",
                    value = list(min(slopd_data$date), max(slopd_data$date)),
                    multiple = FALSE,
                    range = TRUE,
                    timepicker = FALSE,
                    separator = " to ",
                    placeholder = NULL,
                    dateFormat = "yyyy-mm-dd",
                    firstDay = NULL,
                    minDate = min(slopd_data$date),
                    maxDate = max(slopd_data$date),
                    disabledDates = NULL,
                    highlightedDates = NULL,
                    view = c("days", "months", "years"),
                    startView = NULL,
                    minView = c("days", "months", "years"),
                    monthsField = c("monthsShort", "months"),
                    clearButton = TRUE,
                    todayButton = FALSE,
                    autoClose = FALSE,
                    timepickerOpts = timepickerOptions(),
                    position = NULL,
                    update_on = c("change", "close"),
                    addon = c("right", "left", "none"),
                    language = "en",
                    inline = FALSE,
                    onlyTimepicker = FALSE,
                    width = NULL,
                    toggleSelected = TRUE),
                
                
                br(),
                
                # search input call comments ----
                searchInput(
                    inputId = "call_search_input",
                    label = "Call Comments Search",
                    value = "",
                    placeholder = "Enter Search (ex. yell|scream)",
                    btnSearch = icon("search"),
                    btnReset = icon("trash"),
                    resetValue = "",
                    width = '100%'
                    
                )
              )
            )
          ),
        
        # plots ----
        column(
          width = 8,
          div(
              #class = "panel",
              tabsetPanel(
                tabPanel("Time-Series Plot", plotOutput(outputId = "time_plot")),
                tabPanel("Frequency Plot", plotOutput(outputId = "freq_plot"))
              )
            )
        )
    ),
    
    # data ----
    div(
        class = "panel",
        column(
            width = 12,
            div(
                div(
                    h4("Selected Incident Data"),
                    DTOutput(outputId = "filtered_data")
                    )
            )
        )
    )
    
    # div(
    #   column(
    #     width = 12,
    #     verbatimTextOutput(outputId = 'debug')
    #   )
    # )
)


# server ----
server <- function(input, output) {
  
  data <- reactive({
    filtered_data <- slopd_data %>%
      filter(type %in% input$type_select_input) %>%
      filter_by_date(input$date_select_input) %>%
      filter_by_search(
        search_pattern = input$call_search_input, 
        search_column = call_comments)
    filtered_data
  })
  
  output$time_plot <- renderPlot({
    
    if (NROW(data()) > 0) {
      
      data() %>%
        count_by_date() %>%
        create_time_series_plot(
          title = "Showing", 
          subtitle = "Selected")  
    } else {
        
      }
  })
  
  output$freq_plot <- renderPlot({
    
    if (NROW(data()) > 0) {
      
      data() %>%
        count_by_type(type_list = NULL) %>%
        create_frequency_plot(
          type, 
          title = "",
          subtitle = "")
    } else {
      
    }
  })
  
  
  output$filtered_data <- renderDT({
    
    data() %>%
      select(case_number, date, received, arrived, 
             address, type, call_comments,
             responsible_officer, units, description,
             clearance_code) %>%
    arrange(desc(case_number)) %>%
    datatable(options = list(
      deferRender = TRUE,
      scrollY = 400,
      scrollX = TRUE,
      scroller = TRUE,
      autoWidth = TRUE,
      columnDefs = list(list(width = '10%', targets = c(1,2,3,4,5,6,7,8,9,10,11)))
    ))  
    
  })
  
  output$debug <- renderText({

    print("Type Selected:")
    print(input$type_select_input) 
    print("Dates Selected:")
    print(input$date_select_input)
    print(input$date_select_input[1])
    print(input$date_select_input[2])
    print(str(input$date_select_input))
    print(length(input$date_select_input))
    print("Call Search:")
    print(input$call_search_input)
   
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
