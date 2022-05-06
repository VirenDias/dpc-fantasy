source("get-player-data.R")

library(tidyverse)
library(httr)

get_team_data <- function(league_id, update = FALSE) {
  message(paste0("Retrieving team data for league ID ", league_id))
  
  dir_path <- paste0("data/", league_id)
  file_path <- paste0(dir_path, "/teams.csv")
  if (!dir.exists(dir_path) || !file.exists(file_path)) {
    update <- TRUE
  }
  
  if (update) {
    # Get team IDs
    team_ids <- get_player_data(league_id = league_id, update = FALSE)$team_id
    team_ids <- unique(team_ids)
    
    # Get team data
    teams <- data.frame(
      team_id = as.numeric(),
      team_name = as.character(),
      team_tag = as.character()
    )
    for (team_id in team_ids) {
      response_team <- GET(
        url = "https://www.dota2.com/webapi/IDOTA2Teams/GetSingleTeamInfo/v001",
        query = list(team_id = team_id)
      )
      if (http_status(response_team)$category != "Success") {
        stop("Unsuccessful request")
      }
      
      # Store team data
      teams <- teams %>%
        add_row(
          team_id = as.numeric(content(response_team)$team_id), 
          team_name = as.character(content(response_team)$name), 
          team_tag = as.character(content(response_team)$tag)
        )
    }
    teams <- tibble(teams)
    
    # Write the data to disk
    if (!dir.exists(dir_path)) {
      dir.create(dir_path)
    }
    teams <- teams %>% arrange(team_id)
    write_csv(x = teams, file = file_path)
  } else {
    teams <- read_csv(file_path, progress = FALSE, show_col_types = FALSE)
  }
  
  return(teams)
}
