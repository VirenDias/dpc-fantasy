source("update-website-data.R")

league_ids <- c(
  13741,
  13712,
  13738,
  13709,
  13716,
  13747
)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2021-11-30 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2021-12-07 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2021-12-07 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2021-12-14 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2021-12-14 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2021-12-21 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2021-12-21 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-01-11 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2022-01-11 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-01-18 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2022-01-18 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-01-25 08:00", tz = "UTC") %>% as.integer()
  )
)

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}