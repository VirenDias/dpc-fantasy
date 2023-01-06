source("src/print-post.R")
source("src/update-google-sheet.R")
source("src/update-website-data.R")

library(tidyverse)

league_ids <- list(
  "NA" = 14893,
  "SA" = 14886,
  "WEU" = 14892,
  "EEU" = 14858,
  "CN" = 14859,
  "SEA" = 14927
)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2023-01-08 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-01-16 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2023-01-16 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-01-23 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2023-01-23 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-02-04 08:00", tz = "UTC") %>% as.integer()
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
  file_path = "data/posts/2023_winter_tour_p1.txt"
)

## Period 2
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = FALSE,
  start_time = period_dates$period_2$start_time,
  end_time = period_dates$period_2$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2023_winter_tour_p2.txt"
)

## Period 3
print_post(
  league_ids = league_ids,
  update = FALSE,
  innate_data_only = FALSE,
  start_time = period_dates$period_3$start_time,
  end_time = period_dates$period_3$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2023_winter_tour_p3.txt"
)
