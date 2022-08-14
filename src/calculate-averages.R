source("src/get-match-data.R")

library(tidyverse)
library(RcppAlgos)

summarise_exponentially <- function(
    values, 
    ranks = NULL,
    alpha = NULL, 
    func = "average"
) {
  values <- values[!is.na(values)]
  alpha <- if (!is.null(alpha)) {
    alpha
  } else if (is.null(alpha) & is.null(ranks)) {
    2 / (length(values) + 1)
  } else if (is.null(alpha) & !is.null(ranks)) {
    2 / (ceiling(max(ranks)) + 2)
  }
  
  powers <- if (is.null(ranks)) (length(values) - 1):0 else ranks
  weights <- (1 - alpha)^powers
  ew_avg <- sum(weights * values) / sum(weights)
  
  if (func == "average") {
    summary <- ew_avg
  } else if (func == "stddev") {
    bias <- sum(weights)^2 / (sum(weights)^2 - sum(weights^2))
    ew_std <- sqrt(bias * sum(weights * (values - ew_avg)^2) / sum(weights))
    summary <- ew_std
  }
  
  return(summary)
}

permute_series <- function(outcomes, points, best_of) {
  if (length(points) < best_of) return(NA)
  
  rank_digits = nchar(length(points) - 1)
  ranks <- sprintf(paste0("%0", rank_digits, "d"), (length(points) - 1):0)
  
  # Determine all possible permutations of the data
  if (best_of == 1) {
    permutations <- list("ranks" = as.numeric(ranks), "points" = points)
  } else if (best_of == 2) {
    permutations <- comboGeneral(
      v = paste0(ranks, points), 
      m = best_of, 
      FUN = function(x) {
        ## Calculate the total points for the series and the associated rank
        mean_rank <- mean(as.numeric(substr(x, 1, rank_digits)))
        total_points <- sum(
          as.numeric(sub(paste0("^.{", rank_digits, "}"), "", x))
        )
        
        return(list("rank" = mean_rank, "points" = total_points))
      }
    )
    
    permutations <- list(
      "ranks" = sapply(permutations, function(x) x$rank),
      "points" = sapply(permutations, function(x) x$points)
    )
  } else {
    best <- ceiling(best_of / 2)
    permutations <- permuteGeneral(
      v = paste0(ranks, outcomes, points),
      m = best_of,
      FUN = function(x) {
        ## Only consider partial series if the required number of wins is met
        for (i in best:best_of) {
          partial_x <- x[1:i]
          partial_wins <- sum(
            as.numeric(substr(partial_x, rank_digits + 1, rank_digits + 1))
          )
          if (partial_wins == best | (i - partial_wins) == best) break
        }
        
        ## Calculate the total points for the series and the associated rank
        partial_points <- as.numeric(
          sub(paste0("^.{", rank_digits + 1, "}"), "", partial_x)
        )
        total_points <- sum(sort(partial_points, decreasing = TRUE)[1:best])
        mean_rank <- mean(as.numeric(substr(partial_x, 1, rank_digits)))
        
        return(list("rank" = mean_rank, "points" = total_points))
      }
    )
    
    permutations <- list(
      "ranks" = sapply(permutations, function(x) x$rank),
      "points" = sapply(permutations, function(x) x$points)
    )
  }
  
  return(permutations)
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
    pot_bo5 = 0,
    exponential = FALSE,
    exact = FALSE,
    progress = NULL
) {
  if (!is.null(progress)) {
    message(paste0("Calculating summaries (", progress, ")"))
  }
  
  # Calculate Bo1 permutation, average, and standard deviation
  perm_bo1 <- permute_series(outcomes, points, best_of = 1)
  if (exponential) {
    avg <- summarise_exponentially(
      perm_bo1$points, 
      ranks = perm_bo1$ranks, 
      func = "average"
    )
    std <- summarise_exponentially(
      perm_bo1$points, 
      ranks = perm_bo1$ranks,
      func = "stddev"
    )
  } else {
    avg <- mean(perm_bo1$points)
    std <- sd(perm_bo1$points)
  }

  # Calculate Bo2, Bo3, and Bo5 permutations if necessary
  perm_bo2 <- if (bas_bo2 > 0 | pot_bo2 > 0) {
    permute_series(outcomes, points, best_of = 2)
  } else {
    list("ranks" = NA, "points" = NA)
  }
  perm_bo3 <- if (bas_bo3 > 0 | pot_bo3 > 0) {
    permute_series(outcomes, points, best_of = 3)
  } else {
    list("ranks" = NA, "points" = NA)
  }
  perm_bo5 <- if (bas_bo5 > 0 | pot_bo5 > 0) {
    permute_series(outcomes, points, best_of = 5)
  } else {
    list("ranks" = NA, "points" = NA)
  }
  
  if (exact) {
    # Calculate the baseline expectation
    series <- list(
      "ranks" = c(
        rep(list(perm_bo1$ranks), bas_bo1),
        rep(list(perm_bo2$ranks), bas_bo2),
        rep(list(perm_bo3$ranks), bas_bo3),
        rep(list(perm_bo5$ranks), bas_bo5)
      ),
      "points" = c(
        rep(list(perm_bo1$points), bas_bo1),
        rep(list(perm_bo2$points), bas_bo2),
        rep(list(perm_bo3$points), bas_bo3),
        rep(list(perm_bo5$points), bas_bo5)
      )
    )
    if(length(series) != 0) {
      points <- do.call(
        what = expand_grid, 
        args = setNames(object = series$points, nm = 1:length(series$points))
      ) %>%
        transmute(max = pmax(!!!.)) %>%
        pull(max)
      
      if (exponential) {
        ranks <- do.call(
          what = expand_grid, 
          args = setNames(object = series$ranks, nm = 1:length(series$ranks))
        ) %>%
          transmute(mean = rowMeans(.)) %>%
          pull(mean)
        
        bas_exp <- summarise_exponentially(points, ranks = ranks)
      } else {
        bas_exp <- points %>% mean()
      }
    } else {
      bas_exp <- as.numeric(NA)
    }
    
    # Calculate the potential expectation
    if (pot_bo1 > 0 | pot_bo2 > 0 | pot_bo3 > 0 | pot_bo5 > 0) {
      series <- list(
        "ranks" = c(
          rep(list(perm_bo1$ranks), bas_bo1 + pot_bo1),
          rep(list(perm_bo2$ranks), bas_bo2 + pot_bo2),
          rep(list(perm_bo3$ranks), bas_bo3 + pot_bo3),
          rep(list(perm_bo5$ranks), bas_bo5 + pot_bo5)
        ),
        "points" = c(
          rep(list(perm_bo1$points), bas_bo1 + pot_bo1),
          rep(list(perm_bo2$points), bas_bo2 + pot_bo2),
          rep(list(perm_bo3$points), bas_bo3 + pot_bo3),
          rep(list(perm_bo5$points), bas_bo5 + pot_bo5)
        )
      )
      points <- do.call(
        what = expand_grid, 
        args = setNames(object = series$points, nm = 1:length(series$points))
      ) %>%
        transmute(max = pmax(!!!.)) %>%
        pull(max)
      
      if (exponential) {
        ranks <- do.call(
          what = expand_grid, 
          args = setNames(object = series$ranks, nm = 1:length(series$ranks))
        ) %>%
          transmute(mean = rowMeans(.)) %>%
          pull(mean)
        
        pot_exp <- summarise_exponentially(points, ranks = ranks)
      } else {
        pot_exp <- points %>% mean()
      }
    } else {
      pot_exp <- bas_exp
    }
  } else {
    set.seed(2022)
    make_series <- function(series, points, ranks, reps) {
      if (reps > 0) {
        for (i in 1:reps) {
          sample <- if (exponential) {
            rnorm(
              n = 100000, 
              mean = summarise_exponentially(points, ranks, func = "average"), 
              sd = summarise_exponentially(points, ranks, func = "stddev")
            )
          } else {
            rnorm(n = 100000, mean = mean(points), sd = sd(points))
          }
          series <- c(series, list(sample))
        }
      }
      return(series)
    }
    
    # Calculate the baseline expectation
    series <- c()
    series <- make_series(
      series = series, 
      points = perm_bo1$points, 
      ranks = perm_bo1$ranks, 
      reps = bas_bo1
    )
    series <- make_series(
      series = series, 
      points = perm_bo2$points, 
      ranks = perm_bo2$ranks, 
      reps = bas_bo2
    )
    series <- make_series(
      series = series, 
      points = perm_bo3$points, 
      ranks = perm_bo3$ranks, 
      reps = bas_bo3
    )
    series <- make_series(
      series = series, 
      points = perm_bo5$points, 
      ranks = perm_bo5$ranks, 
      reps = bas_bo5
    )
    
    if(length(series) != 0) {
      bas_exp <- do.call(
        what = pmax, 
        args = series
      ) %>%
        mean()
    } else {
      bas_exp <- as.numeric(NA)
    }
    
    # Calculate the potential expectation
    if (pot_bo1 > 0 | pot_bo2 > 0 | pot_bo3 > 0 | pot_bo5 > 0) {
      series <- c()
      series <- make_series(
        series = series, 
        points = perm_bo1$points, 
        ranks = perm_bo1$ranks,
        reps = bas_bo1 + pot_bo1
      )
      series <- make_series(
        series = series, 
        points = perm_bo2$points, 
        ranks = perm_bo2$ranks,
        reps = bas_bo2 + pot_bo2
      )
      series <- make_series(
        series = series, 
        points = perm_bo3$points, 
        ranks = perm_bo3$ranks,
        reps = bas_bo3 + pot_bo3
      )
      series <- make_series(
        series = series, 
        points = perm_bo5$points, 
        ranks = perm_bo5$ranks,
        reps = bas_bo5 + pot_bo5
      )
      
      pot_exp <- do.call(
        what = pmax, 
        args = series
      ) %>%
        mean()
    } else {
      pot_exp <- bas_exp
    }
  }
  
  return(
    tibble(
      "avg" = avg,
      "std" = std,
      "bas_exp" = bas_exp,
      "pot_exp" = pot_exp
    )
  )
}

calculate_summaries <- function(
    league_id,
    player_series = NULL,
    start_time = as.integer(Sys.time()),
    innate_data_only = FALSE,
    exponential = FALSE,
    update = FALSE
) {
  message(paste0("Calculating summaries for league ID ", league_id))
  
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
  averages <- if (exponential) {
    matches %>%
      group_by(player_id) %>%
      summarise(across(.cols = kills:total, .fns = summarise_exponentially))
  } else {
    matches %>%
      group_by(player_id) %>%
      summarise(across(.cols = kills:total, .fns = ~mean(., na.rm = TRUE)))
  }
  
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
          pot_bo5 = max(pot_bo5, 0),
          exponential = exponential,
          progress = paste0(cur_group_id(), "/", length(unique(.$player_id)))
        )
      )
    averages <- averages %>% right_join(series_averages, by = "player_id")
  }
  
  return(averages)
}
