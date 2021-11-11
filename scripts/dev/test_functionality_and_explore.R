# load libraries ----
library(tidyverse)
library(lubridate)
library(devtools)
library(usethis)
library(ggplot2)
library(here)


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



# Transient ----
transient_data <- filter_by_search(
    slopd_data, 
    search_pattern = 'TRANSIENT|HOMELESS|TRANS|TENT|SLEEPING|CAMP', 
    search_column = call_comments)

transient_data %>%
    filter(type != "9-1-1 ABANDON") %>%
    count_by_type(type_list = NULL) %>%
    create_frequency_plot(
        type, 
        title = "Top-20 incidents associated with search phrase",
        subtitle = "TRANSIENT|HOMELESS|TENT|SLEEP|CAMP")

transient_data %>%
    filter(type != "9-1-1 ABANDON") %>%
    count_by_date() %>%
    create_time_series_plot(
        title = "Incidents associated with search phrase:", 
        subtitle = "TRANSIENT|HOMELESS|TENT|SLEEP|CAMP")

# Hastings ----   
address_data <- filter_by_search(
    slopd_data, 
    search_pattern = '684 STONERIDGE', 
    search_column = address)

address_data %>%
    count_by_date() %>%
    create_time_series_plot(
        title = "Incidents involving the following address:", 
        subtitle = "684 Stoneridge")

# Noise ----
noise_data <- slopd_data %>%
    filter(str_detect(type, 'NOISE'))

noise_data %>%
    filter(type != "9-1-1 ABANDON") %>%
    count_by_date() %>%
    create_time_series_plot(
        title = "Incidents associated with search phrase:", 
        subtitle = "NOISE")

# Suicide ----
slopd_data %>%
    filter(str_detect(type, 'SUICIDE')) %>%
    count_by_date() %>%
    create_time_series_plot(
        title = "Incidents associated with search phrase:", 
        subtitle = "Suicide",
        show_trend = FALSE)

# Assault ----
slopd_data %>%
    filter(str_detect(type, 'ASSAULT|BATTERY|ROBBERY|THEFT')) %>%
    count_by_date() %>%
    create_time_series_plot(
        title = "Incidents associated with search phrase:", 
        subtitle = "ASSAULT|BATTERY|ROBBERY")

# Rape/Sexual Assault ----
slopd_data %>%
    filter(str_detect(type, 'RAPE|SEX')) %>%
    count_by_date() %>%
    create_time_series_plot(
        title = "Incidents associated with search phrase:", 
        subtitle = "RAPE|SEX")

# Graffiti ----
slopd_data %>%
    filter(str_detect(type, 'GRAPH|VANDAL')) %>%
    count_by_date() %>%
    create_time_series_plot(
        title = "Incidents associated with search phrase:", 
        subtitle = "GRAFFITI|VANDAL")


# Following/Stalking ----
slopd_data %>%
filter_by_search(
    search_pattern = 'FOLLOW|STALK', 
    search_column = call_comments) %>%
    filter(!str_detect(call_comments, 'SHOPLIFT')) %>%
    count_by_date() %>%
    create_time_series_plot(
        title = "Incidents associated with search phrase:", 
        subtitle = "FOLLOW|STALK")



