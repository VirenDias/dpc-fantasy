library(tidyverse)
library(httr)

get_schedule <- function(league_id, update = FALSE) {
  message(paste0("Retrieving schedule for league ID ", league_id))
  
  dir_path <- paste0("data/", league_id)
  file_path <- paste0(dir_path, "/schedule.csv")
  if (!dir.exists(dir_path) || !file.exists(file_path)) {
    update <- TRUE
  }
  
  if (update) {
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
    schedule <- tibble(schedule)
    
    # Write the data to disk
    if (!dir.exists(dir_path)) {
      dir.create(dir_path)
    }
    write_csv(x = schedule, file = paste0(dir_path, "/schedule.csv"))
  } else {
    schedule <- read_csv(file_path, progress = FALSE, show_col_types = FALSE)
  }
  
  return(schedule)
}
