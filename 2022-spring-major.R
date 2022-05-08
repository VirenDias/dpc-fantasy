source("src/print-post.R")
source("src/update-google-sheet.R")
source("src/update-website-data.R")

library(tidyverse)

league_ids <- list("Spring Major 2022" = 14173)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2022-05-12 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-13 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2022-05-13 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-14 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2022-05-14 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-15 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2022-05-15 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-16 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2022-05-16 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-17 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2022-05-17 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-18 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_7" = list(
    "start_time" = as.POSIXct("2022-05-18 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-19 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_8" = list(
    "start_time" = as.POSIXct("2022-05-19 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-20 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_9" = list(
    "start_time" = as.POSIXct("2022-05-20 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-21 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_10" = list(
    "start_time" = as.POSIXct("2022-05-21 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-22 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_11" = list(
    "start_time" = as.POSIXct("2022-05-22 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-23 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_12" = list(
    "start_time" = as.POSIXct("2022-05-23 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-05-24 00:00", tz = "UTC") %>% as.integer()
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
lapply(1:length(period_dates), function(i) {
  print_post(
    league_ids = league_ids,
    update = FALSE,
    start_time = period_dates[[i]]$start_time,
    end_time = period_dates[[i]]$end_time,
    google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
    file_path = paste0("data/posts/2022_spring_major_p", i, ".txt")
  )
})
