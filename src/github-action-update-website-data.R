source("src/update-website-data.R")

league_ids <- list("Summer Major 2023" = 15438)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2023-06-29 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-06-30 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2023-06-30 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-01 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2023-07-01 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-02 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2023-07-02 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-03 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2023-07-03 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-05 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2023-07-05 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-06 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_7" = list(
    "start_time" = as.POSIXct("2023-07-06 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-07 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_8" = list(
    "start_time" = as.POSIXct("2023-07-07 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-08 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_9" = list(
    "start_time" = as.POSIXct("2023-07-08 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-09 00:00", tz = "UTC") %>% as.integer()
  ),
  "period_10" = list(
    "start_time" = as.POSIXct("2023-07-09 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-10 00:00", tz = "UTC") %>% as.integer()
  )
)

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}
