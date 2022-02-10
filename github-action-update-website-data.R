source("update-website-data.R")

league_ids <- c(
  13961,
  13954,
  13960,
  13926,
  13937,
  13939
)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2022-02-11 00:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-02-22 00:00", tz = "UTC") %>% as.integer()
  )
)

for (league_id in league_ids) {
  update_website_data(
    league_id = league_id,
    period_dates = period_dates,
    update = TRUE
  )
}