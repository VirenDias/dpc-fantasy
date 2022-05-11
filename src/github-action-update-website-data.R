source("src/update-website-data.R")

league_ids <- c(
  14173
)

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

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}