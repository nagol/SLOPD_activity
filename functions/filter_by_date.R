filter_by_date <- function (data, dates){
    
    print(dates)
    
    data %>%
        filter(date >= as.POSIXct(dates[1]),   
               date <= as.POSIXct(ymd(dates[2]) + 1))
        
}
