source("src/print-post.R")
source("src/update-google-sheet.R")
source("src/update-website-data.R")

library(tidyverse)

league_ids <- list("Winter Major 2023" = 15089)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2023-02-22 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-02-23 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2023-02-23 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-02-24 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2023-02-24 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-02-25 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2023-02-25 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-02-26 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2023-02-26 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-02-28 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2023-02-28 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-01 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_7" = list(
    "start_time" = as.POSIXct("2023-03-01 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-02 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_8" = list(
    "start_time" = as.POSIXct("2023-03-02 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-03 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_9" = list(
    "start_time" = as.POSIXct("2023-03-03 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-04 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_10" = list(
    "start_time" = as.POSIXct("2023-03-04 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-05 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_11" = list(
    "start_time" = as.POSIXct("2023-03-05 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-06 08:00", tz = "UTC") %>% as.integer()
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
  file_path = "data/posts/2023_winter_major_p1.txt",
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
  file_path = "data/posts/2023_winter_major_p2.txt",
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
  file_path = "data/posts/2023_winter_major_p3.txt",
  innate_data_only = FALSE,
  exponential = TRUE,
  update = FALSE
)

## Period 4
print_post(
  league_ids = league_ids,
  start_time = period_dates$period_4$start_time,
  end_time = period_dates$period_4$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2023_winter_major_p4.txt",
  innate_data_only = FALSE,
  exponential = TRUE,
  update = FALSE
)

## Period 5
print_post(
  league_ids = league_ids,
  start_time = period_dates$period_5$start_time,
  end_time = period_dates$period_5$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2023_winter_major_p5.txt",
  innate_data_only = FALSE,
  exponential = TRUE,
  tiebreaker = TRUE,
  tiebreaker_ranks = c(4, 6),
  tie_best_of = 1,
  tie_2_best_of = 3,
  update = FALSE
)

## Period 6
print_post(
  league_ids = league_ids,
  start_time = period_dates$period_6$start_time,
  end_time = period_dates$period_6$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2023_winter_major_p6.txt",
  innate_data_only = FALSE,
  exponential = TRUE,
  update = FALSE
)

## Period 7
print_post(
  league_ids = league_ids,
  start_time = period_dates$period_7$start_time,
  end_time = period_dates$period_7$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2023_winter_major_p7.txt",
  innate_data_only = FALSE,
  exponential = TRUE,
  update = FALSE
)

## Period 8
print_post(
  league_ids = league_ids,
  start_time = period_dates$period_8$start_time,
  end_time = period_dates$period_8$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2023_winter_major_p8.txt",
  innate_data_only = FALSE,
  exponential = TRUE,
  update = FALSE
)

## Period 9
print_post(
  league_ids = league_ids,
  start_time = period_dates$period_9$start_time,
  end_time = period_dates$period_9$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2023_winter_major_p9.txt",
  innate_data_only = FALSE,
  exponential = TRUE,
  update = FALSE
)

## Period 10
print_post(
  league_ids = league_ids,
  start_time = period_dates$period_10$start_time,
  end_time = period_dates$period_10$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2023_winter_major_p10.txt",
  innate_data_only = FALSE,
  exponential = TRUE,
  update = FALSE
)

## Period 11
print_post(
  league_ids = league_ids,
  start_time = period_dates$period_11$start_time,
  end_time = period_dates$period_11$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2023_winter_major_p11.txt",
  innate_data_only = FALSE,
  exponential = TRUE,
  update = FALSE
)
