source("src/update-website-data.R")

league_ids <- list("The International 2022" = 14268)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2022-10-15 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-10-16 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2022-10-16 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-10-17 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2022-10-17 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-10-18 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2022-10-18 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-10-20 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2022-10-20 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-10-21 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2022-10-21 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-10-22 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_7" = list(
    "start_time" = as.POSIXct("2022-10-22 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-10-23 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_8" = list(
    "start_time" = as.POSIXct("2022-10-23 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-10-29 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_9" = list(
    "start_time" = as.POSIXct("2022-10-29 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-10-30 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_10" = list(
    "start_time" = as.POSIXct("2022-10-30 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-10-31 00:00", tz = "UTC") %>% as.integer()
  )
)

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}
