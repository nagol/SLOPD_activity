create_time_series_plot <- function(data, title = '', subtitle = '', show_trend = TRUE){
    
    plot <- data %>%
        mutate(dow = wday(date, label = TRUE)) %>%
        ggplot(aes(x = date, y = n)) +
        geom_line() +
        geom_tile(aes(
            x = date,
            y = 0,
            height = Inf,
            fill = dow
            ), alpha = .4) +
        geom_point() +
        labs(
            x = '', 
            y = '', 
            title = title,
            subtitle = subtitle,
            caption = str_glue("Total records found: {sum(data$n)}")
            ) +
        theme_minimal() +
        theme(plot.title = element_text(size = rel(1.5), face="bold", vjust=1)) +
        theme(plot.subtitle = element_text(size = rel(1), face="italic", vjust=0)) +
        theme(legend.position = "bottom") + 
        guides(title = NULL, fill = guide_legend(nrow = 1, title = NULL))
    
    if (show_trend) {
        plot <- plot + geom_smooth(se = FALSE, color = 'red')
        return(plot)
        
    } else {
        return(plot)
    }
}