create_frequency_plot <- function(data, count_col, title, subtitle, x_label = ''){
    data %>%
        top_n(20) %>%
        arrange(n, {{count_col}}) %>%
        ggplot(aes(y = n, x = fct_reorder({{count_col}}, n))) + 
        geom_col() +
        coord_flip() +
        labs(
            x = x_label, 
            y = "Count",
            # title = title,
            # subtitle = subtitle,
            caption = str_glue("Total records found: {sum(data$n)}")) +
        theme_minimal() +
        theme(plot.title = element_text(size = rel(1.5), face="bold", vjust=1)) +
        theme(plot.subtitle = element_text(size = rel(1), face="italic", vjust=0))
    
}
