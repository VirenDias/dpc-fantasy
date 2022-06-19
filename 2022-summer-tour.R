source("src/print-post.R")
source("src/update-google-sheet.R")
source("src/update-website-data.R")

library(tidyverse)

league_ids <- list(
  "NA" = 14281,
  "SA" = 14299,
  "WEU" = 14279,
  "EEU" = 14295,
  "CN" = 14248,
  "SEA" = 14270
)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2022-06-06 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-06-13 09:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2022-06-13 09:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-06-20 09:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2022-06-20 09:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-06-27 09:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2022-06-27 09:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-07-04 09:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2022-07-04 09:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-07-11 09:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2022-07-11 09:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-07-18 09:00", tz = "UTC") %>% as.integer()
  )
)

# Update Google Sheet
lapply(names(league_ids), function(league_name) {
  update_google_sheet(
    google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
    work_sheet = league_name,
    league_id = league_ids[[league_name]],
    update = TRUE
  )
})

# Update website
lapply(names(league_ids), function(league_name) {
  update_website_data(
    league_id = league_ids[[league_name]],
    period_dates = period_dates,
    update = FALSE
  )
})

# Create Reddit post
## Period 1
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = FALSE,
  start_time = period_dates$period_1$start_time,
  end_time = period_dates$period_1$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_summer_tour_p1.txt"
)

## Period 2
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = FALSE,
  start_time = period_dates$period_2$start_time,
  end_time = period_dates$period_2$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_summer_tour_p2.txt"
)

## Period 3
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = FALSE,
  start_time = period_dates$period_3$start_time,
  end_time = period_dates$period_3$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_summer_tour_p3.txt"
)

## Period 4
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = FALSE,
  start_time = period_dates$period_4$start_time,
  end_time = period_dates$period_4$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_summer_tour_p4.txt"
)

## Period 5
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = FALSE,
  start_time = period_dates$period_5$start_time,
  end_time = period_dates$period_5$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_summer_tour_p5.txt"
)

## Period 6
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = FALSE,
  start_time = period_dates$period_6$start_time,
  end_time = period_dates$period_6$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_summer_tour_p6.txt"
)
