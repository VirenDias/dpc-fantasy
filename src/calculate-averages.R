source("src/get-match-data.R")

library(tidyverse)
library(RcppAlgos)

permute_series <- function(outcomes, points, best_of) {
  if (length(points) < best_of) return(NA)
  
  # Sample only 10 data points for Bo5 and above to reduce computation time
  if (best_of >= 5) {
    sample_size <- min(10, length(points))
    set.seed(2022)
    sample_indices <- sample(x = 1:length(points), size = sample_size)
    outcomes <- outcomes[sample_indices]
    points <- points[sample_indices]
  }
  
  # Determine all possible permutations of the data
  if (best_of == 1) {
    permutations <- points
  } else if (best_of == 2) {
    permutations <- comboGeneral(v = points, m = best_of, FUN = sum)
  } else {
    best <- ceiling(best_of / 2)
    permutations <- permuteGeneral(
      v = paste0(outcomes, points),
      m = best_of,
      FUN = function(x) {
        ## Only consider partial series if the required number of wins is met
        for (i in best:best_of) {
          partial_x <- x[1:i]
          partial_wins <- sum(as.numeric(substr(partial_x, 1, 1)))
          if (partial_wins == best | (i - partial_wins) == best) break
        }
        
        ## Calculate the total points for the series
        partial_points <- as.numeric(sub(".", "", partial_x))
        total_points <- sum(sort(partial_points, decreasing = TRUE)[1:best])
        return(total_points)
      }
    )
  }
  
  return(unlist(permutations))
}

average_series <- function(
  outcomes, 
  points, 
  num_bo1 = 0, 
  num_bo2 = 0, 
  num_bo3 = 0, 
  num_bo5 = 0
) {
  # Calculate permutations and averages
  perm_series <- list()
  if (num_bo1 > 0) {
    perm_bo1 <- permute_series(outcomes, points, best_of = 1)
    avg_bo1 <- mean(perm_bo1)
    for (i in 1:num_bo1) perm_series <- c(perm_series, list(perm_bo1))
  } else {
    avg_bo1 <- NA
  }
  if (num_bo2 > 0) {
    perm_bo2 <- permute_series(outcomes, points, best_of = 2)
    avg_bo2 <- mean(perm_bo2)
    for (i in 1:num_bo2) perm_series <- c(perm_series, list(perm_bo2))
  } else {
    avg_bo2 <- NA
  }
  if (num_bo3 > 0) {
    perm_bo3 <- permute_series(outcomes, points, best_of = 3)
    avg_bo3 <- mean(perm_bo3)
    for (i in 1:num_bo3) perm_series <- c(perm_series, list(perm_bo3))
  } else {
    avg_bo3 <- NA
  }
  if (num_bo5 > 0) {
    perm_bo5 <- permute_series(outcomes, points, best_of = 5)
    avg_bo5 <- mean(perm_bo5)
    for (i in 1:num_bo5) perm_series <- c(perm_series, list(perm_bo5))
  } else {
    avg_bo5 <- NA
  }
  
  # Calculate expectation
  expectation <- expand.grid(perm_series) %>%
    apply(MARGIN = 1, FUN = max) %>%
    mean()
  
  return(
    tibble(
      "average_bo1" = avg_bo1, 
      "average_bo2" = avg_bo2, 
      "average_bo3" = avg_bo3, 
      "average_bo5" = avg_bo5, 
      "expectation" = expectation
    )
  )
}

calculate_averages <- function(
  league_id,
  player_series = NULL,
  start_time = as.integer(Sys.time()),
  update = FALSE
) {
  # Get required data
  matches <- get_prediction_data(
    league_id = league_id, 
    start_time = start_time,
    update = update
  )
  
  # Calculate the single match averages
  averages <- matches %>%
    group_by(player_id) %>%
    summarise(across(.cols = kills:total, .fns = ~mean(., na.rm = TRUE)))
  
  # Calculate the series averages
  if (!is.null(player_series)) {
    series_averages <- matches %>%
      right_join(player_series, by = "player_id") %>%
      group_by(player_id) %>%
      summarise(
        average_series(
          outcomes = win,
          points = total,
          num_bo1 = max(num_bo1, 0),
          num_bo2 = max(num_bo2, 0),
          num_bo3 = max(num_bo3, 0),
          num_bo5 = max(num_bo5, 0)
        )
      ) %>%
      select_if(
        names(.) %in% c("player_id", "expectation") | colSums(!is.na(.)) > 0
      )
    averages <- averages %>% right_join(series_averages, by = "player_id")
  }
  
  return(averages)
}
