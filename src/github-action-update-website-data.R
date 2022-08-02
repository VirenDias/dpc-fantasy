source("src/update-website-data.R")

league_ids <- list("Summer Major 2022" = 14417)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2022-08-04 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-05 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2022-08-05 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-06 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2022-08-06 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-07 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2022-08-07 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-08 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2022-08-08 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-09 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2022-08-09 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-10 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_7" = list(
    "start_time" = as.POSIXct("2022-08-10 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-11 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_8" = list(
    "start_time" = as.POSIXct("2022-08-11 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-12 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_9" = list(
    "start_time" = as.POSIXct("2022-08-12 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-13 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_10" = list(
    "start_time" = as.POSIXct("2022-08-13 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-14 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_11" = list(
    "start_time" = as.POSIXct("2022-08-14 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-08-15 00:00", tz = "UTC") %>% as.integer()
  )
)

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}
