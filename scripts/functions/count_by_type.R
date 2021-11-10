count_by_type <- function(data, type_list = NULL) {
    
    if (is.null(type_list)) {
        data %>%
            mutate(type = str_to_upper(type)) %>%
            group_by(type) %>%
            tally() %>%
            ungroup() %>%
            arrange(desc(n))
    }
    else {
        data %>%
            mutate(type = str_to_upper(type)) %>%
            filter(type %in% type_list) %>%
            group_by(type) %>%
            tally() %>%
            arrange(desc(n))
    }
}
