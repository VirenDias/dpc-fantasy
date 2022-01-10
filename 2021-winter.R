source("print-post.R")
source("update-google-sheet.R")
source("update-website-data.R")

library(tidyverse)

league_ids <- list(
  "NA" = 13741,
  "SA" = 13712,
  "WEU" = 13738,
  "EEU" = 13709,
  "CN" = 13716,
  "SEA" = 13747
)

period_dates <- list(
  "period_1" = list(
    "start_time" = as.POSIXct("2021-11-30 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2021-12-07 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_2" = list(
    "start_time" = as.POSIXct("2021-12-07 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2021-12-14 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_3" = list(
    "start_time" = as.POSIXct("2021-12-14 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2021-12-21 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_4" = list(
    "start_time" = as.POSIXct("2021-12-21 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-01-11 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_5" = list(
    "start_time" = as.POSIXct("2022-01-11 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-01-18 08:00", tz = "UTC") %>% as.integer()
  ),
  "period_6" = list(
    "start_time" = as.POSIXct("2022-01-18 08:00", tz = "UTC") %>% as.integer(),
    "end_time" = as.POSIXct("2022-01-25 08:00", tz = "UTC") %>% as.integer()
  )
)

role_errata <- data.frame(
  player_id = as.numeric(),
  player_role = as.character()
) %>%
  # NA
  add_row(player_id = 26771994, player_role = "Support") %>%
  add_row(player_id = 193884241, player_role = "Support") %>%
  add_row(player_id = 1261414529, player_role = "Support") %>% # Check
  add_row(player_id = 1262036558, player_role = "Mid") %>% # Check
  add_row(player_id = 329977411, player_role = "Mid") %>%
  # SA
  add_row(player_id = 185202677, player_role = "Core") %>%
  add_row(player_id = 85312703, player_role = "Core") %>%
  add_row(player_id = 182177187, player_role = "Support") %>%
  # WEU
  add_row(player_id = 90125566, player_role = "Support") %>%
  add_row(player_id = 93618577, player_role = "Mid") %>%
  add_row(player_id = 167976729, player_role = "Core") %>%
  add_row(player_id = 152168157, player_role = "Support") %>%
  # EEU
  add_row(player_id = 123051238, player_role = "Support") %>%
  add_row(player_id = 176139572, player_role = "Mid") %>%
  add_row(player_id = 320219866, player_role = "Support") %>%
  add_row(player_id = 331855530, player_role = "Core") %>%
  add_row(player_id = 93817671, player_role = "Support") %>%
  add_row(player_id = 293731272, player_role = "Core") %>%
  add_row(player_id = 344861218, player_role = "Support") %>%
  add_row(player_id = 363739653, player_role = "Core") %>%
  # CN
  add_row(player_id = 147767183, player_role = "Core") %>%
  add_row(player_id = 107081378, player_role = "Support") %>%
  add_row(player_id = 101908305, player_role = "Core") %>%
  add_row(player_id = 136178375, player_role = "Support") %>%
  add_row(player_id = 150588364, player_role = "Mid") %>%
  add_row(player_id = 262367336, player_role = "Core") %>%
  add_row(player_id = 129683931, player_role = "Core") %>%
  add_row(player_id = 191458152, player_role = "Mid") %>%
  add_row(player_id = 198161112, player_role = "Support") %>%
  # SEA
  add_row(player_id = 401653350, player_role = "Core") %>%
  add_row(player_id = 135495981, player_role = "Core") %>%
  add_row(player_id = 837609249, player_role = "Core") # %>%
  add_row(player_id = 112531417, player_role = "Support")

# Update Google Sheet
lapply(names(league_ids), function(league_name) {
  update_google_sheet(
    google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
    work_sheet = league_name,
    league_id = league_ids[[league_name]],
    update = TRUE
  )
})

# Update website
lapply(names(league_ids), function(league_name) {
  update_website_data(
    league_id = league_ids[[league_name]],
    period_dates = period_dates,
    update = FALSE
  )
})

# Create Reddit post
## Period 1
print_post(
  league_ids = league_ids,
  update = FALSE,
  start_time = period_dates$period_1$start_time,
  end_time = period_dates$period_1$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2021_winter_p1.txt"
)

## Period 2
print_post(
  league_ids = league_ids,
  update = FALSE,
  start_time = period_dates$period_2$start_time,
  end_time = period_dates$period_2$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2021_winter_p2.txt"
)

## Period 3
print_post(
  league_ids = league_ids,
  update = FALSE,
  start_time = period_dates$period_3$start_time,
  end_time = period_dates$period_3$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2021_winter_p3.txt"
)

## Period 4
print_post(
  league_ids = league_ids,
  update = FALSE,
  start_time = period_dates$period_4$start_time,
  end_time = period_dates$period_4$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2021_winter_p4.txt"
)

## Period 5
print_post(
  league_ids = league_ids,
  update = FALSE,
  start_time = period_dates$period_5$start_time,
  end_time = period_dates$period_5$end_time,
  google_sheet = "11ExiDnIYbupgsjuSbr9zeaBTXb_xn2N9uyvyD0Gz1bc",
  file_path = "data/posts/2021_winter_p5.txt"
)
