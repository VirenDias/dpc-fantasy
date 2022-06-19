source("src/update-website-data.R")

league_ids <- list(
  "NA" = 14281,
  "SA" = 14299,
  "WEU" = 14279,
  "EEU" = 14295,
  "CN" = 14248,
  "SEA" = 14270
)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2022-06-06 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-06-13 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2022-06-13 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-06-20 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2022-06-19 22:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-06-26 22:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2022-06-26 22:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-07-04 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2022-07-03 22:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-07-10 22:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2022-07-10 22:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-07-17 22:00", tz = "UTC") %>% as.integer()
  )
)

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}