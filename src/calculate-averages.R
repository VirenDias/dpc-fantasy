source("src/get-match-data.R")

library(tidyverse)

calculate_averages <- function(
  league_id,
  start_time = as.integer(Sys.time()),
  update = FALSE
) {
  # Get required data
  matches <- get_prediction_data(
    league_id = league_id, 
    start_time = start_time,
    update = update
  )
  
  # Calculate average results
  averages <- matches %>%
    group_by(player_id) %>%
    summarise(across(.cols = kills:total, .fns = ~mean(., na.rm = TRUE)))
  
  return(averages)
}
