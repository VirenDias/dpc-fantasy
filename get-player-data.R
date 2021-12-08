library(tidyverse)
library(httr)
library(rlang)

get_player_data <- function(league_id, update = FALSE) {
  message(paste0("Retrieving player data for league ID ", league_id))
  
  dir_path <- paste0("data/", league_id)
  file_path <- paste0(dir_path, "/players.csv")
  if (!dir.exists(dir_path) || !file.exists(file_path)) {
    update <- TRUE
  }
  
  if (update) {
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
    for (player in content(response_league)$leagues[[1]]$registered_players) {
      players <- players %>%
        add_row(
          player_id = as.numeric(player$account_id), 
          player_name = as.character(chr_unserialise_unicode(player$name)), 
          team_id = as.numeric(player$team_id)
        )
    }
    
    # Store role data
    roles <- data.frame(
      player_id = as.numeric(), 
      player_role = as.numeric()
    )
    for (team_id in unique(players$team_id)) {
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
        player_role = as.character(
          factor(
            x = player_role, 
            levels = c(0, 1, 2, 4),
            labels = c("Undefined", "Core", "Support", "Mid"))
        )
      )
    players <- players %>% left_join(roles, by = "player_id") %>% tibble()
    
    # Write the data to disk
    if (!dir.exists(dir_path)) {
      dir.create(dir_path)
    }
    write_csv(x = players, file = file_path)
  } else {
    players <- read_csv(file_path, progress = FALSE, show_col_types = FALSE)
  }
  
  return(players)
}
