load_and_preprocess_data <- function(url){
    
    read_csv(url) %>%
        mutate(
            date = mdy(date), 
            weekday = wday(date, label = TRUE), 
            month = month(date),
            type = str_to_upper(type)) 
}



