source("print-post.R")
source("update-google-sheet.R")
source("update-website-data.R")

library(tidyverse)

league_ids <- list(
  "NA" = 14051,
  "SA" = 14071,
  "WEU" = 14052,
  # "EEU" = 13709,
  "CN" = 14041,
  "SEA" = 14067
)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2022-03-15 06:55", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-03-21 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2022-03-21 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-03-28 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2022-03-28 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-04-04 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2022-04-04 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-04-11 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2022-04-11 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-04-18 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2022-04-18 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-04-25 07:00", tz = "UTC") %>% as.integer()
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
  start_time = period_dates$period_1$start_time,
  end_time = period_dates$period_1$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_p1.txt"
)

## Period 2
print_post(
  league_ids = league_ids,
  update = FALSE,
  start_time = period_dates$period_2$start_time,
  end_time = period_dates$period_2$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_p2.txt"
)

## Period 3
print_post(
  league_ids = league_ids,
  update = FALSE,
  start_time = period_dates$period_3$start_time,
  end_time = period_dates$period_3$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_p3.txt"
)

## Period 4
print_post(
  league_ids = league_ids,
  update = FALSE,
  start_time = period_dates$period_4$start_time,
  end_time = period_dates$period_4$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_p4.txt"
)

## Period 5
print_post(
  league_ids = league_ids,
  update = FALSE,
  start_time = period_dates$period_5$start_time,
  end_time = period_dates$period_5$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_p5.txt"
)

## Period 6
print_post(
  league_ids = league_ids,
  update = FALSE,
  start_time = period_dates$period_6$start_time,
  end_time = period_dates$period_6$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2022_spring_p6.txt"
)
