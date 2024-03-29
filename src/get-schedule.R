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
      url = "https://www.dota2.com/webapi/IDOTA2League/GetLeagueData/v001",
      query = list(league_id = league_id)
    )
    if (http_status(response)$category != "Success") {
      stop("Unsuccessful request")
    }
    
    # Store schedule
    schedule <- data.frame(
      node_group_id = as.numeric(),
      node_group_name = as.character(),
      node_id = as.numeric(),
      node_name = as.character(),
      best_of = as.numeric(),
      inc_id_1 = as.numeric(),
      inc_id_2 = as.numeric(),
      team_id_1 = as.numeric(), 
      team_id_2 = as.numeric(), 
      team_wins_1 = as.numeric(), 
      team_wins_2 = as.numeric(), 
      time = as.numeric()
    )
    for (stage in content(response)$node_groups) {
      for (group in stage$node_groups) {
        for (match in group$nodes) {
          schedule <- schedule %>%
            add_row(
              node_group_id = as.numeric(group$node_group_id),
              node_group_name = as.character(group$name),
              node_id = as.numeric(match$node_id),
              node_name = as.character(match$name),
              best_of = as.numeric(
                switch(match$node_type, "1" = 1, "2" = 3, "3" = 5, "4" = 2)
              ),
              inc_id_1 = as.numeric(match$incoming_node_id_1),
              inc_id_2 = as.numeric(match$incoming_node_id_2),
              team_id_1 = as.numeric(match$team_id_1), 
              team_id_2 = as.numeric(match$team_id_2), 
              team_wins_1 = as.numeric(match$team_1_wins), 
              team_wins_2 = as.numeric(match$team_2_wins), 
              time = as.numeric(match$scheduled_time)
            )
        }
      }
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
