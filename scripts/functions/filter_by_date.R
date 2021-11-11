filter_by_date <- function (data, dates){
    
    data %>%
        filter(date >= as.POSIXct(dates[1]),   
               date <= as.POSIXct(dates[2]))
        
}
