source("src/update-website-data.R")

league_ids <- list("Winter Major 2023" = 15089)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2023-02-22 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-02-23 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2023-02-23 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-02-24 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2023-02-24 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-02-25 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2023-02-25 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-02-26 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2023-02-26 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-02-28 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2023-02-28 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-01 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_7" = list(
    "start_time" = as.POSIXct("2023-03-01 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-02 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_8" = list(
    "start_time" = as.POSIXct("2023-03-02 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-03 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_9" = list(
    "start_time" = as.POSIXct("2023-03-03 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-04 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_10" = list(
    "start_time" = as.POSIXct("2023-03-04 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-05 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_11" = list(
    "start_time" = as.POSIXct("2023-03-05 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2023-03-06 08:00", tz = "UTC") %>% as.integer()
  )
)

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}
