source("src/update-website-data.R")

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

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}
