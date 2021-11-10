filter_by_date <- function (data, low_date, high_date){
    
    if (is.null(low_date)) {
        low_date <- min(data$date)
    }
    
    if (is.null(high_date)) {
        high_date <- max(data$date)
    }
    
    data %>%
        filter(date >= as.POSIXct(low_date))%>%
        filter(date <= as.POSIXct(high_date))
    
}
