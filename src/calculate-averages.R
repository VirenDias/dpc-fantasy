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
  bas_bo1 = 0, 
  bas_bo2 = 0, 
  bas_bo3 = 0, 
  bas_bo5 = 0,
  pot_bo1 = 0, 
  pot_bo2 = 0, 
  pot_bo3 = 0, 
  pot_bo5 = 0
) {
  # Calculate Bo1 permutation, average, and standard deviation
  perm_bo1 <- permute_series(outcomes, points, best_of = 1)
  avg_bo1 <- mean(perm_bo1)
  sd_bo1 <- sd(perm_bo1)
  
  # Calculate Bo2, Bo3, and Bo5 permutations if necessary
  perm_bo2 <- if (bas_bo2 > 0 | pot_bo2 > 0) {
    permute_series(outcomes, points, best_of = 2)
  } else {
    NA
  }
  perm_bo3 <- if (bas_bo3 > 0 | pot_bo3 > 0) {
    permute_series(outcomes, points, best_of = 3)
  } else {
    NA
  }
  perm_bo5 <- if (bas_bo5 > 0 | pot_bo5 > 0) {
    permute_series(outcomes, points, best_of = 5)
  } else {
    NA
  }
  
  # Calculate the baseline expectation
  series <- c(
    rep(list(perm_bo1), bas_bo1),
    rep(list(perm_bo2), bas_bo2),
    rep(list(perm_bo3), bas_bo3),
    rep(list(perm_bo5), bas_bo5)
  )
  if(length(series) != 0) {
    bas_exp <- do.call(
      what = expand_grid, 
      args = setNames(object = series, nm = 1:length(series))
    ) %>%
      transmute(max = pmax(!!!.)) %>%
      pull(max) %>%
      mean()
  } else {
    bas_exp <- as.numeric(NA)
  }
  
  # Calculate the potential expectation
  if (pot_bo1 > 0 | pot_bo2 > 0 | pot_bo3 > 0 | pot_bo5 > 0) {
    series <- c(
      rep(list(perm_bo1), bas_bo1 + pot_bo1),
      rep(list(perm_bo2), bas_bo2 + pot_bo2),
      rep(list(perm_bo3), bas_bo3 + pot_bo3),
      rep(list(perm_bo5), bas_bo5 + pot_bo5)
    )
    pot_exp <- do.call(
      what = expand_grid, 
      args = setNames(object = series, nm = 1:length(series))
    ) %>%
      transmute(max = pmax(!!!.)) %>%
      pull(max) %>%
      mean()
  } else {
    pot_exp <- bas_exp
  }
  
  return(
    tibble(
      "avg" = avg_bo1,
      "sd" = sd_bo1,
      "bas_exp" = bas_exp,
      "pot_exp" = pot_exp
    )
  )
}

calculate_averages <- function(
  league_id,
  player_series = NULL,
  innate_data_only = FALSE,
  start_time = as.integer(Sys.time()),
  update = FALSE
) {
  # Get required data
  if (innate_data_only) {
    matches <- get_result_data(
      league_id = league_id, 
      start_time = start_time,
      update = update
    )
  } else {
    matches <- get_prediction_data(
      league_id = league_id, 
      start_time = start_time,
      update = update
    )
  }
  
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
          bas_bo1 = max(bas_bo1, 0),
          bas_bo2 = max(bas_bo2, 0),
          bas_bo3 = max(bas_bo3, 0),
          bas_bo5 = max(bas_bo5, 0),
          pot_bo1 = max(pot_bo1, 0),
          pot_bo2 = max(pot_bo2, 0),
          pot_bo3 = max(pot_bo3, 0),
          pot_bo5 = max(pot_bo5, 0)
        )
      )
    averages <- averages %>% right_join(series_averages, by = "player_id")
  }
  
  return(averages)
}
