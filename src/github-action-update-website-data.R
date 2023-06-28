source("src/update-website-data.R")

league_ids <- list("Summer Major 2023" = 15438)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2023-06-29 01:55", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-06-30 01:55", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2023-06-30 01:55", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-01 01:55", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2023-07-01 01:55", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-02 01:55", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2023-07-02 01:55", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-03 01:55", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2023-07-03 01:55", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-05 01:55", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2023-07-05 01:55", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-06 01:55", tz = "UTC") %>% as.integer()
  ),
  "period_7" = list(
    "start_time" = as.POSIXct("2023-07-06 01:55", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-07 01:55", tz = "UTC") %>% as.integer()
  ),
  "period_8" = list(
    "start_time" = as.POSIXct("2023-07-07 01:55", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-08 01:55", tz = "UTC") %>% as.integer()
  ),
  "period_9" = list(
    "start_time" = as.POSIXct("2023-07-08 01:55", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-09 01:55", tz = "UTC") %>% as.integer()
  ),
  "period_10" = list(
    "start_time" = as.POSIXct("2023-07-09 01:55", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-07-10 01:55", tz = "UTC") %>% as.integer()
  )
)

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}
