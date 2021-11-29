library(tidyverse)
library(httr)

get_player_data <- function(league_id, team_ids = NULL, role_errata = NULL) {
  message("Retrieving player data")
  
  # Get league data
  response_league <- GET(
    url = "https://www.dota2.com/webapi/IDOTA2League/GetLeaguesData/v001",
    query = list(league_ids = league_id)
  )
  if (http_status(response_league)$category != "Success") {
    stop("Unsuccessful request")
  }
  
  # Store player data
  players <- data.frame(
    player_id = as.numeric(), 
    player_name = as.character(), 
    team_id = as.numeric()
  )
  for (player in content(response_league, encoding = "UTF-8")$leagues[[1]]$registered_players) {
    players <- players %>%
      add_row(
        player_id = as.numeric(player$account_id), 
        player_name = as.character(player$name), 
        team_id = as.numeric(player$team_id)
      )
  }
  
  if (is.null(team_ids)) {
    team_ids <- unique(players$team_id)
  }
  
  # Store role data
  roles <- data.frame(
    player_id = as.numeric(), 
    player_role = as.numeric()
  )
  for (team_id in team_ids) {
    response_team <- GET(
      url = "https://www.dota2.com/webapi/IDOTA2Teams/GetSingleTeamInfo/v001",
      query = list(team_id = team_id)
    )
    if (http_status(response_team)$category != "Success") {
      stop("Unsuccessful request")
    }
    
    for (player in content(response_team)$members) {
      roles <- roles %>%
        add_row(
          player_id = as.numeric(player$account_id),
          player_role = as.numeric(player$role)
        )
    }
  }
  
  roles <- roles %>%
    mutate(
      player_role = factor(
        x = player_role, 
        levels = c(0, 1, 2, 4),
        labels = c("Undefined", "Core", "Support", "Mid"))
    )
  players <- left_join(players, roles, by = "player_id")
  
  # Correct role data
  if (is.null(role_errata)) {
    role_errata <- data.frame(
      player_id = as.numeric(),
      player_role = as.character()
    )
  }
  players <- players %>%
    rows_update(
      semi_join(role_errata, players, by = "player_id"), 
      by = "player_id"
    )
  
  # Return only players in supplied team IDs
  players <- players %>% filter(team_id %in% team_ids)
  
  return(players)
}
