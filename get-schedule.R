library(tidyverse)
library(httr)

get_schedule <- function(league_id, start_time, end_time) {
  message("Retrieving schedule")
  
  # Get league data
  response <- GET(
    url = "https://www.dota2.com/webapi/IDOTA2League/GetLeaguesData/v001",
    query = list(league_ids = league_id)
  )
  if (http_status(response)$category != "Success") {
    stop("Unsuccessful request")
  }
  
  # Store schedule
  schedule <- data.frame(
    team_id_1 = as.numeric(), 
    team_id_2 = as.numeric(), 
    time = as.numeric()
  )
  for (match in content(response)$leagues[[1]]$node_groups[[1]]$node_groups[[1]]$nodes) {
    schedule <- schedule %>%
      add_row(
        team_id_1 = as.numeric(match$team_id_1), 
        team_id_2 = as.numeric(match$team_id_2), 
        time = as.numeric(match$scheduled_time)
      )
  }
  
  # Filter by start and end times
  schedule <- schedule %>% filter(time >= start_time, time < end_time)
  
  return(schedule)
}
