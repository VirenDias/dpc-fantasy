source("src/update-website-data.R")

league_ids <- list("Spring Major 2023" = 15251)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2023-04-26 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-04-27 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2023-04-27 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-04-28 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2023-04-28 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-04-29 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2023-04-29 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-04-30 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2023-04-30 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-05-05 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2023-05-05 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-05-06 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_7" = list(
    "start_time" = as.POSIXct("2023-05-06 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-05-07 07:00", tz = "UTC") %>% as.integer()
  ),
  "period_8" = list(
    "start_time" = as.POSIXct("2023-05-07 07:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-05-08 07:00", tz = "UTC") %>% as.integer()
  )
)

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}
