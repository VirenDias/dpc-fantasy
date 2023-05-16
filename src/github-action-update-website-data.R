source("src/update-website-data.R")

league_ids <- list(
  "NA" = 15350,
  "SA" = 15365,
  "WEU" = 15351,
  "EEU" = 15335,
  "CN" = 15383,
  "SEA" = 15374
)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2023-05-15 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-05-22 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2023-05-22 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-05-29 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2023-05-29 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-06-05 07:00", tz = "UTC") %>% as.integer()
  )
)

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}
