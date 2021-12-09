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
  players <- get_player_data(league_id = league_id, update = update)
  teams <- get_team_data(league_id = league_id, update = update)
  schedule <- get_schedule(league_id, update = update)
  
  website_data <- lapply(period_dates, function(period) {
    period_schedule <- schedule %>%
      filter(time >= period$start_time, time < period$end_time)
    series <- period_schedule %>%
    pivot_longer(cols = team_id_1:team_id_2, values_to = "team_id") %>%
      group_by(team_id) %>%
      summarise(series = n())
    relevant_teams <- unique(
      c(period_schedule$team_id_1, period_schedule$team_id_2)
    )

    period_schedule <- period_schedule %>%
      arrange(time) %>%
      left_join(teams, by = c("team_id_1" = "team_id")) %>%
      rename(team_name_1 = team_name) %>%
      left_join(teams, by = c("team_id_2" = "team_id")) %>%
      rename(team_name_2 = team_name) %>%
      mutate(
        time = format(
          as.POSIXct(time, tz = "UTC", origin = "1970-01-01"),
          "%Y-%m-%d %H:%M",
          usetz = TRUE
        )
      ) %>%
      select(team_name_1, team_name_2, time)
    
    roles <- list(
      "core" = "Core",
      "mid" = "Mid",
      "support" = "Support"
    )
    period_prediction <- lapply(roles, function(role) {
      calculate_averages(
        league_id = league_id, 
        start_time = period$start_time,
        update = update
      ) %>%
        right_join(players, by = "player_id") %>%
        left_join(teams, by = "team_id") %>%
        left_join(series, by = "team_id") %>%
        filter(team_id %in% relevant_teams) %>%
        filter(player_role == role) %>%
        arrange(desc(total)) %>%
        select(player_name, team_name, series, total)
    })
    
    matches_result <- get_result_data(
      league_id = league_id,
      start_time = period$start_time,
      end_time = period$end_time,
      update = update
    )
    period_result_single <- matches_result %>%
      inner_join(players, by = "player_id") %>%
      left_join(teams, by = "team_id") %>%
      select(player_name, player_role, team_name, match_id, kills:total) %>%
      arrange(desc(total))
    period_result_aggregate <- bind_rows(
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
      group_by(player_id, series_id) %>%
      summarise(
        across(.cols = kills:total, .fns = ~sum(., na.rm = TRUE)),
        .groups = "keep"
      ) %>%
      ungroup(series_id) %>%
      slice_max(order_by = total, n = 1) %>%
      ungroup() %>%
      right_join(players, by = "player_id") %>%
      left_join(teams, by = "team_id") %>%
      select(player_name, player_role, team_name, kills:total) %>%
      arrange(desc(total))
    
    list(
      "schedule" = period_schedule,
      "prediction" = period_prediction,
      "result_single" = period_result_single,
      "result_aggregate" = period_result_aggregate
    )
  })
  
  return(toJSON(website_data))
}