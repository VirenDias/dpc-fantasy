source("get-player-data.R")
source("get-match-data.R")

library(tidyverse)
library(googlesheets4)

update_google_sheet <- function(
  google_sheet,
  work_sheet,
  league_id,
  role_errata = NULL,
  num_matches
) {
  players <- get_player_data(league_id = league_id, role_errata = role_errata)
  teams <- get_team_data(team_ids = unique(players$team_id))
  matches <- get_match_data(
    player_ids = players$player_id, 
    num_matches = num_matches
  )
  
  summary <- matches %>%
    group_by(player_id) %>%
    summarise(
      across(
        .cols = -match_id, 
        .fns = ~format(round(mean(., na.rm = TRUE), digits = 2), nsmall = 2)
      )
    )
  summary <- players %>%
    left_join(teams, by = "team_id") %>%
    left_join(summary, by = "player_id") %>%
    mutate(player_role = as.character(player_role)) %>%
    arrange(team_name, player_role) %>%
    select(
      "Player Name" = player_name,
      "Team Name" = team_name,
      "Role" = player_role,
      "Kills" = kills,
      "Deaths" = deaths,
      "Creep Score" = creep_score,
      "GPM" = gold_per_min,
      "Tower Kills" = tower_kills,
      "Roshan Kills" = roshan_kills,
      "Teamfight" = team_fight,
      "Obs Wards" = obs_wards_planted,
      "Camps Stacked" = camps_stacked,
      "Runes Grabbed" = runes_grabbed,
      "First Blood" = first_blood,
      "Stuns" = stuns,
      "Total" = total
    )
  
  write_sheet(summary, ss = google_sheet, sheet = work_sheet)
}