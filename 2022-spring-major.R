source("src/print-post.R")
source("src/update-google-sheet.R")
source("src/update-website-data.R")

library(tidyverse)

league_ids <- list("Spring Major 2022" = 14173)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2022-05-12 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-13 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2022-05-13 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-14 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2022-05-14 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-15 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2022-05-15 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-16 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2022-05-16 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-17 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2022-05-17 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-18 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_7" = list(
    "start_time" = as.POSIXct("2022-05-18 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-20 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_8" = list(
    "start_time" = as.POSIXct("2022-05-20 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-21 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_9" = list(
    "start_time" = as.POSIXct("2022-05-21 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-22 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_10" = list(
    "start_time" = as.POSIXct("2022-05-22 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-23 07:00", tz = "UTC") %>% as.integer()
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
lapply(league_ids, function(league_id) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = FALSE
  )
})

# Create Reddit posts
## Period 1
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = FALSE,
  start_time = period_dates$period_1$start_time,
  end_time = period_dates$period_1$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_major_p1.txt"
)

## Period 2
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = FALSE,
  start_time = period_dates$period_2$start_time,
  end_time = period_dates$period_2$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_major_p2.txt"
)

## Period 3
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = FALSE,
  start_time = period_dates$period_3$start_time,
  end_time = period_dates$period_3$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_major_p3.txt"
)

## Period 4
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = FALSE,
  start_time = period_dates$period_4$start_time,
  end_time = period_dates$period_4$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_major_p4.txt"
)

## Period 5
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = TRUE,
  start_time = period_dates$period_5$start_time,
  end_time = period_dates$period_5$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_major_p5.txt"
)

## Period 6
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = TRUE,
  start_time = period_dates$period_6$start_time,
  end_time = period_dates$period_6$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_major_p6.txt"
)

## Period 7
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = TRUE,
  start_time = period_dates$period_7$start_time,
  end_time = period_dates$period_7$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_major_p7.txt"
)

## Period 8
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = TRUE,
  start_time = period_dates$period_8$start_time,
  end_time = period_dates$period_8$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_major_p8.txt"
)

## Period 9
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = TRUE,
  start_time = period_dates$period_9$start_time,
  end_time = period_dates$period_9$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_major_p9.txt"
)

## Period 10
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = TRUE,
  start_time = period_dates$period_10$start_time,
  end_time = period_dates$period_10$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_major_p10.txt"
)