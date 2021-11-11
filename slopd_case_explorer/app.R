
# Libraries ----
library(shiny)
library(shinyWidgets)
library(shinyjs)

library(tidyverse)
library(lubridate)
library(devtools)
library(usethis)
library(ggplot2)
library(here)
library(DT)

# load functions
source(here('scripts/functions/load_and_preprocess_data.R'))
source(here('scripts/functions/filter_by_search.R'))
source(here('scripts/functions/filter_by_date.R'))
source(here('scripts/functions/count_by_date.R'))
source(here('scripts/functions/count_by_type.R'))
source(here('scripts/functions/create_frequency_plot.R'))
source(here('scripts/functions/create_time_series_plot.R'))

slopd_data <- load_and_preprocess_data(
  url = "https://raw.githubusercontent.com/nagol/SLOPD_data/main/data/csv/SLOPD_report.csv")


# UI ----
ui <- fluidPage(
    title = "San Luis Obispo Police Department - Call Log Explorer",
    
    div(
      class = "container",
      id = "header",
      class = "page-header",
      h1("SLOPD Police Call Explorer"),
      p(
        class = "lead",
        "A Citizen Created, Unofficial Data Exploration Tool"
      ),
      p(
        "The San Luis Obispo Police department publishes detailed records about
         interactions with the public. This tool is designed to make investigation
         of these data a little easier as well as providing a little context with
         historical data."
      ),
      p("There are many insights one can gain by seeing for oneself
         the struggles of their local community. Even in a small, sleepy town
         like San Luis Obispo crime, disagreements, accidents, and emergencies
         are a daily part of life. The news only shows the most sensational and 
         outrageous. So, what is really going on around SLO?")
    ),
  
    
    # main body ----
    div(
      class = "panel-body",
        # Sidebar
        column(
            width = 4, 
            wellPanel(
                
                # type picker input ----
                pickerInput(inputId = "type_select_input", 
                            label = "Type", 
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
                    todayButton = TRUE,
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
        
                # # search input location ----
                # searchInput(
                #     inputId = "location_search_input",
                #     label = "Location Search",
                #     value = "",
                #     placeholder = "Enter Address to Search",
                #     btnSearch = icon("search"),
                #     btnReset = icon("remove"),
                #     resetValue = "",
                #     width = NULL
                # ),
                
                # search input call comments ----
                searchInput(
                    inputId = "call_search_input",
                    label = "Call Comments Search",
                    value = "",
                    placeholder = "Enter Search Terms (ie. TRANSIENT)",
                    btnSearch = icon("search"),
                    btnReset = icon("remove"),
                    resetValue = "",
                    width = NULL
                )
                # ,
                # actionButton(
                #   inputId = "search_button",
                #   label = "Analyze Selection",
                #   icon = icon("play")
                # )
                )),
        
        
        # plots ----
        column(
          width = 8,
          div(
              tabsetPanel(
                tabPanel("Time-Series Plot", plotOutput(outputId = "time_plot")),
                tabPanel("Frequency Plot", plotOutput(outputId = "freq_plot"))
              )
            )
        )
    ),
    
    # data ----
    div(
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
          title = "Blah",
          subtitle = "Blah")
    } else {
      
    }
  })
  
  
  output$filtered_data <- renderDT({
    
    data() %>%
      select(case_number, date, received, arrived, 
             address, type, call_comments,
             responsible_officer, units, description,
             clearance_code) %>%
    datatable(options = list(
      deferRender = TRUE,
      scrollY = 400,
      scrollX = TRUE,
      scroller = TRUE,
      autoWidth = TRUE,
      columnDefs = list(list(width = '10%', targets = c(1,2,3,4)))
    ))  # %>% formatStyle(columns = c(2,3), width='20px')
    
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
