source("get-player-data.R")
source("get-team-data.R")
source("get-schedule.R")
source("get-match-data.R")

library(tidyverse)
library(jsonlite)

update_website_data <- function(
  league_id,
  period_dates,
  update = FALSE
) {
  website_data <- list()
  
  # Get required metadata
  players <- get_player_data(league_id = league_id, update = update)
  teams <- get_team_data(league_id = league_id, update = update)
  schedule <- get_schedule(league_id, update = update)
  matches_result <- get_result_data(league_id = league_id, update = update)
  
  response_league <- GET(
    url = "https://www.dota2.com/webapi/IDOTA2League/GetLeagueData/v001",
    query = list(league_id = league_id)
  )
  if (http_status(response_league)$category != "Success") {
    stop("Unsuccessful request")
  }
  
  # Calculate and format schedule
  series <- schedule %>%
    pivot_longer(cols = team_id_1:team_id_2, values_to = "team_id") %>%
    group_by(team_id) %>%
    summarise(series = n())
  
  schedule <- schedule %>%
    left_join(teams, by = c("team_id_1" = "team_id")) %>%
    rename(team_name_1 = team_name) %>%
    left_join(teams, by = c("team_id_2" = "team_id")) %>%
    rename(team_name_2 = team_name) %>%
    select(team_name_1, team_name_2, time)
  
  # Calculate and format single results
  result_single <- matches_result %>%
    inner_join(players, by = "player_id") %>%
    left_join(teams, by = "team_id") %>%
    select(
      player_name, 
      player_role, 
      team_name, 
      match_id, 
      start_time, 
      kills:total
    )
  
  # Calculate and format aggregate results
  result_aggregate <- bind_rows(
    matches_result %>% filter(series_type == 0),
    matches_result %>%
      filter(series_type == 1) %>%
      group_by(player_id, series_id) %>%
      slice_max(order_by = total, n = 2) %>%
      ungroup(),
    matches_result %>%
      filter(series_type == 2) %>%
      group_by(player_id, series_id) %>%
      slice_max(order_by = total, n = 3) %>%
      ungroup()
  ) %>%
    mutate(
      period = cut(
        x = start_time,
        breaks = unique(unlist(period_dates)),
        labels = paste0("period_", 1:length(period_dates)),
        include.lowest = TRUE
      )
    ) %>%
    group_by(player_id, period, series_id) %>%
    summarise(total = sum(total, na.rm = TRUE), .groups = "keep") %>%
    ungroup(series_id) %>%
    slice_max(order_by = total, n = 1) %>%
    ungroup() %>%
    right_join(players, by = "player_id") %>%
    left_join(teams, by = "team_id") %>%
    select(player_name, player_role, team_name, period, total) %>%
    pivot_wider(names_from = period, values_from = total)
  
  website_data <- list(
    "name" = unbox(content(response_league)$info$name),
    "description" = unbox(content(response_league)$info$description),
    "start_date" = content(response_league)$info$start_timestamp,
    "end_date" = content(response_league)$info$end_timestamp,
    "last_activity" = unbox(content(response_league)$info$most_recent_activity),
    "schedule" = schedule,
    "result_single" = result_single,
    "result_aggregate" = result_aggregate
  )

  write_json(
    x = website_data,
    path = paste0("docs/data/", league_id, ".json"),
    na = "string"
  )
  
  # Get league banner
  download.file(
    url = paste0(
      "https://cdn.dota2.com/apps/dota2/images/leagues/", 
      league_id,
      "/images/image_1.png"
    ),
    destfile = paste0("docs/img/", league_id, ".png"),
    mode = "wb"
  )
  
  # Update league list
  if (!file.exists("docs/data/league_list.json")) {
    league_list <- tibble(
      league_id = as.numeric(),
      last_activity = as.numeric()
    )
  } else {
    league_list <- read_json("docs/data/league_list.json") %>% bind_rows()
  }
  league_list <- league_list %>% 
    add_row(
      league_id = as.numeric(league_id),
      last_activity = as.numeric(content(response_league)$info$most_recent_activity)
    ) %>%
    group_by(league_id) %>%
    slice_max(order_by = last_activity, n = 1, with_ties = FALSE) %>%
    ungroup() %>%
    arrange(desc(last_activity))
  
  write_json(
    x = league_list, 
    path = "docs/data/league_list.json",
    auto_unbox = TRUE
  )
}