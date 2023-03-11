source("src/update-website-data.R")

league_ids <- list(
  "NA" = 15085,
  "SA" = 15135,
  "WEU" = 15086,
  "EEU" = 15137,
  "CN" = 15140,
  "SEA" = 15125
)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2023-03-12 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-19 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2023-03-19 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-26 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2023-03-26 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-04-03 08:00", tz = "UTC") %>% as.integer()
  )
)

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}
