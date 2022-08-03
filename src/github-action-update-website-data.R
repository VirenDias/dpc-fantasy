source("src/update-website-data.R")

league_ids <- list("Summer Major 2022" = 14417)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2022-08-04 14:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-05 14:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2022-08-05 14:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-06 14:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2022-08-06 14:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-07 14:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2022-08-07 14:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-08 14:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2022-08-08 14:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-09 14:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2022-08-09 14:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-10 14:00", tz = "UTC") %>% as.integer()
  ),
  "period_7" = list(
    "start_time" = as.POSIXct("2022-08-10 14:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-11 14:00", tz = "UTC") %>% as.integer()
  ),
  "period_8" = list(
    "start_time" = as.POSIXct("2022-08-11 14:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-12 14:00", tz = "UTC") %>% as.integer()
  ),
  "period_9" = list(
    "start_time" = as.POSIXct("2022-08-12 14:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-13 14:00", tz = "UTC") %>% as.integer()
  ),
  "period_10" = list(
    "start_time" = as.POSIXct("2022-08-13 14:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-14 14:00", tz = "UTC") %>% as.integer()
  ),
  "period_11" = list(
    "start_time" = as.POSIXct("2022-08-14 14:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-15 14:00", tz = "UTC") %>% as.integer()
  )
)

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}
