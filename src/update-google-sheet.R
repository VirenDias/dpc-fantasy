source("src/get-player-data.R")
source("src/get-team-data.R")
source("src/calculate-averages.R")

library(tidyverse)
library(googlesheets4)

update_google_sheet <- function(
  google_sheet,
  work_sheet,
  league_id,
  update = FALSE
) {
  # Get required data
  players <- get_player_data(league_id = league_id, update = update)
  teams <- get_team_data(league_id = league_id, update = update)
  averages <- calculate_averages(league_id = league_id, update = update)
  
  # Format values
  averages <- averages %>%
    mutate(
      across(
        .cols = -player_id, 
        .fns = ~format(round(., digits = 2), nsmall = 2)
      )
    ) %>%
    right_join(players, by = "player_id") %>%
    left_join(teams, by = "team_id") %>%
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
  
  # Update Google Sheet
  write_sheet(averages, ss = google_sheet, sheet = work_sheet)
}