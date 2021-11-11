filter_by_search <- function (data, search_pattern, search_column) {
    data %>%
        filter(str_detect(pattern = str_to_upper(search_pattern), {{search_column}}))
}