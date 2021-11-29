source("get-schedule.R")
source("get-team-data.R")
source("get-player-data.R")
source("get-match-data.R")

library(tidyverse)
library(knitr)

calculate_summary <- function(
  league_id,
  role_errata = NULL,
  start_time, 
  end_time, 
  num_matches
) {
  # Get required data
  schedule <- get_schedule(
    league_id = league_id, 
    start_time = start_time, 
    end_time = end_time
  )
  teams <- get_team_data(
    team_ids = unique(c(schedule$team_id_1, schedule$team_id_2))
  )
  players <- get_player_data(
    league_id = league_id,
    team_ids = unique(c(schedule$team_id_1, schedule$team_id_2)),
    role_errata = role_errata
  )
  matches <- get_match_data(
    player_ids = players$player_id,
    num_matches = num_matches
  )
  
  # Calculate average results
  summary <- matches %>%
    group_by(player_id) %>%
    summarise(across(.cols = -match_id, .fns = ~mean(., na.rm = TRUE)))
  summary <- players %>%
    left_join(teams, by = "team_id") %>%
    left_join(summary, by = "player_id")
  
  return(
    list(
      "schedule" = schedule,
      "teams" = teams,
      "players" = players,
      "matches" = matches,
      "summary" = summary
    )
  )
}
