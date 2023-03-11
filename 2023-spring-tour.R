source("src/print-post.R")
source("src/update-google-sheet.R")
source("src/update-website-data.R")

library(tidyverse)

league_ids <- list(
  "NA" = 15085,
  "SA" = 15135,
  "WEU" = 15086,
  "EEU" = 15137,
  "CN" = 15140,
  "SEA" = 15125
)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2023-03-12 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-19 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2023-03-19 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-26 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2023-03-26 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-04-03 08:00", tz = "UTC") %>% as.integer()
  )
)

# Update Google Sheet
lapply(names(league_ids), function(league_name) {
  update_google_sheet(
    google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
    work_sheet = league_name,
    league_id = league_ids[[league_name]],
    exponential = TRUE,
    update = FALSE
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
  start_time = period_dates$period_1$start_time,
  end_time = period_dates$period_1$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2023_spring_tour_p1.txt",
  innate_data_only = FALSE,
  exponential = TRUE,
  update = FALSE
)

## Period 2
print_post(
  league_ids = league_ids,
  start_time = period_dates$period_2$start_time,
  end_time = period_dates$period_2$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2023_spring_tour_p2.txt",
  innate_data_only = FALSE,
  exponential = TRUE,
  update = FALSE
)

## Period 3
print_post(
  league_ids = league_ids,
  start_time = period_dates$period_3$start_time,
  end_time = period_dates$period_3$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2023_spring_tour_p3.txt",
  innate_data_only = FALSE,
  exponential = TRUE,
  update = FALSE
)
