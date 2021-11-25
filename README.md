# SLOPD Call Log Dashboard

This simple shiny dashboard was designed to allow for investigation of SLOPD Call Log data. 
In particular, for finding patterns of various types of behavior/incidents.

## Interactive Dashboard 

[https://logan-lossing.shinyapps.io/slopd_activity/](https://logan-lossing.shinyapps.io/slopd_activity/)

## Data Source

The data source is available at [here](https://github.com/nagol/SLOPD_data). The data is updated Monday-Thursday afternoon.

## How to Use

This simple tool was originally designed to make it easy to look for patterns in the call data. When looking at the raw data there are many potential fields to explore. With experience, it seemed that the most useful field was the unstructured Call Comments input by the 911 operator (`call_comments`). Though the SLOPD data is categorized by `type` the labels can often seem random or be in classified in some unexpected way. Thus, the main function of this tool is to allow searching (and allowing *regular expressions*) for words associated with the call `type` you might be looking for.

Once you have a search that seems to return reasonable matches then the time series plot will visualize the frequency over time and the frequency bar chart will provide the 20 most common call `type` labels associated with the search. I have found filtering by `type`

In general, I have found filtering by `date` to be basically useless and the `airDatePicker` html widget is awkward at best.

### Example - Noise Complaints due to Parties

San Luis Obispo is home to a university not unfamiliar with partying. How many complaints relating to parties are the SLOPD responding to? Are there any noticable trends in these data?

#### By Call Comments Search

Consider words that often might be associated with a complaint about a loud party. Words like *noise*, *loud music*, and *party* should be good indicators.

Let's try the search phrase `noise|loud music|party`

*Insert search result*

*Insert data results*

#### By Type

What were the labels applied by SLOPD to these calls? That is where this plot shines. In this example, these call `type` labels all seem appropriate and related but this is not always the case. 


