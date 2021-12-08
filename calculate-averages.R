source("get-match-data.R")

library(tidyverse)

calculate_averages <- function(league_id, update = FALSE, num_matches = 25) {
  # Get required data
  matches <- get_match_data(league_id = league_id, update = update) %>%
    group_by(player_id) %>%
    slice_max(order_by = match_id, n = num_matches) %>%
    ungroup()
  
  # Calculate average results
  averages <- matches %>%
    group_by(player_id) %>%
    summarise(across(.cols = kills:total, .fns = ~mean(., na.rm = TRUE)))
  
  return(averages)
}
