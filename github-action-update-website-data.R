source("update-website-data.R")

league_ids <- c(
  14051,
  14071,
  14052,
  13709,
  14041,
  14067
)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2022-03-15 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-03-21 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2022-03-21 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-03-28 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2022-03-28 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-04-04 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2022-04-04 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-04-11 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2022-04-11 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-04-18 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2022-04-18 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-04-25 08:00", tz = "UTC") %>% as.integer()
  )
)

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}