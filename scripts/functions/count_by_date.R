count_by_date <- function (data) {
    
    # Make sure all dates are represented with at least 0
    min_date = min(data$date)
    max_date = max(data$date)
    dates_df = tibble("date" = seq(ymd(min_date), ymd(max_date + 1), by = "1 days"))
    
    data_counts <- data %>%
        group_by(date) %>%
        tally()
    
    dates_df %>%
        left_join(data_counts, by = c('date' = 'date')) %>%
        replace_na(list(n = 0))
}