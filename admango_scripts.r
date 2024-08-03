library("tidyverse")

# TODO: create a script to adjust names when importing data.


# single date conversion
date <- mdy(<date>)

# function to convert date ranges according to admango's output 
# TODO: adjust to mutate the imported data frame?
date_start <- mdy(str_sub(<date>, 1, 11))
date_end <- mdy(str_sub(<date>, -1, -11))

# gantt chart?
ggplot(<data.frame>, aes(<date>, <ad_type or url>)) +
  geom_line(group = <ad_type or url>, linewidth = 10, position = "jittery") +
  labs (
    x = "Date", y = "Type of ad",
    title = "Something describing the table"
    subtitle = "Data taken from **admango.com**"
    caption = "Is there any data that has been ommitted?"
  )