library(tidyverse)
library(httr)

get_team_data <- function(team_ids) {
  message("Retrieving team data")
  
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
  
  return(teams)
}
