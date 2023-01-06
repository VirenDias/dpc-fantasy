source("src/get-match-data.R")

library(tidyverse)
library(RcppAlgos)

calculate_exponential_summary <- function(
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

calculate_period_summary <- function(
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
    progress = NULL
) {
  if (!is.null(progress)) {
    message(paste0("Calculating summaries (", progress, ")"))
  }
  
  if (unique(is.na(outcomes) | is.na(points))) {
    return(
      tibble(
        "avg" = NA,
        "std" = NA,
        "bas_exp" = NA,
        "pot_exp" = NA
      )
    )
  }
  
  # Calculate average, standard deviation, and win rate
  if (exponential) {
    avg <- calculate_exponential_summary(values = points, func = "average")
    std <- calculate_exponential_summary(values = points, func = "stddev")
    win_rate <- calculate_exponential_summary(
      values = outcomes, 
      func = "average"
    )
  } else {
    avg <- mean(points)
    std <- sd(points)
    win_rate <- mean(outcomes)
  }
  
  # Calculate series distributions
  ## Calculate order statistic distributions
  order_statistic_distribution <- function(r, n, avg = 0, std = 1) {
    integ_avg <- function(x, r, n, avg = 0, std = 1) {
      x * 
        (factorial(n) / (factorial(r - 1) * factorial(n - r))) * 
        ((1 - pnorm(x, avg, std, lower.tail = FALSE))^(r - 1)) * 
        (pnorm(x, avg, std, lower.tail = FALSE)^(n - r)) * dnorm(x, avg, std)
    }
    result_avg <- integrate(integ_avg, -Inf, Inf, r, n, avg, std, abs.tol = 0)
    result_avg <- result_avg$value
    
    integ_var <- function(x, r, n, avg = 0, std = 1) {
      (x - result_avg)^2 * 
        (factorial(n) / (factorial(r - 1) * factorial(n - r))) * 
        ((1 - pnorm(x, avg, std, lower.tail = FALSE))^(r - 1)) *
        (pnorm(x, avg, std, lower.tail = FALSE)^(n - r)) * dnorm(x, avg, std)
    }
    result_var <- integrate(integ_var, -Inf, Inf, r, n, avg, std, abs.tol = 0)
    result_var <- result_var$value
    
    return(tibble("avg" = result_avg, "var" = result_var))
  }
  
  series_distribution <- function(win_rate, avg, std, best_of) {
    thresh <- list("1" = 1, "2" = 2, "3" = 2, "5" = 3)[[as.character(best_of)]]
    
    ## Calculate series length probabilities
    length_probabilities <- permuteGeneral(
      v = c("W", "L"),
      m = best_of,
      repetition = TRUE,
      FUN = function(x) {
        prob <- win_rate^sum(x == "W") * (1 - win_rate)^sum(x == "L")
        for (i in thresh:best_of) {
          partial_x <- x[1:i]
          partial_wins <- if (best_of == 2) {
            length(partial_x)
          } else {
            sum(partial_x == "W")
          }
          if (partial_wins == thresh | (i - partial_wins) == thresh) {
            return(
              tibble(
                num_matches = length(partial_x), 
                prob = prob
              )
            )
          }
        }
      }
    ) %>%
      bind_rows() %>%
      group_by(num_matches) %>% 
      summarise(prob = sum(prob))
    
    ## Calculate combined order statistic distributions
    length_probabilities %>%
      rowwise() %>%
      mutate(
        lapply(
          tail(1:num_matches, thresh),
          order_statistic_distribution,
          n = num_matches,
          avg = avg,
          std = std
        ) %>%
          bind_rows() %>%
          summarise(avg = sum(avg), var = sum(var))
      ) %>%
      group_by() %>%
      summarise(avg = sum(prob * avg), std = sqrt(sum(prob * var)))
  }
  
  dist_bo1 <- series_distribution(win_rate, avg, std, best_of = 1)
  dist_bo2 <- series_distribution(win_rate, avg, std, best_of = 2)
  dist_bo3 <- series_distribution(win_rate, avg, std, best_of = 3)
  dist_bo5 <- series_distribution(win_rate, avg, std, best_of = 5)
  
  # Calculate period expectation
  ## Calculate combined same series type distributions
  same_series_distribution <- function(num, dist) {
    if (num > 0) {
      order_statistic_distribution(
        r = num, 
        n = num, 
        avg = dist$avg, 
        std = dist$std
      ) %>%
        transmute(avg, std = sqrt(var))
    } else {
      NULL
    }
  }
  
  bas_dists <- list(
    "bo1" <- same_series_distribution(bas_bo1, dist_bo1),
    "bo2" <- same_series_distribution(bas_bo2, dist_bo2),
    "bo3" <- same_series_distribution(bas_bo3, dist_bo3),
    "bo5" <- same_series_distribution(bas_bo5, dist_bo5)
  ) %>%
    .[lapply(., is.null) == FALSE]
  pot_dists <- list(
    "bo1" <- same_series_distribution(bas_bo1 + pot_bo1, dist_bo1),
    "bo2" <- same_series_distribution(bas_bo2 + pot_bo2, dist_bo2),
    "bo3" <- same_series_distribution(bas_bo3 + pot_bo3, dist_bo3),
    "bo5" <- same_series_distribution(bas_bo5 + pot_bo5, dist_bo5)
  ) %>%
    .[lapply(., is.null) == FALSE]
  
  ## Calculate combined different series type distributions
  different_series_expectation_2 <- function(dist1, dist2) {
    avg1 <- dist1$avg
    std1 <- dist1$std
    avg2 <- dist2$avg
    std2 <- dist2$std
    
    avg1 * pnorm((avg1 - avg2) / sqrt(std1^2 + std2^2)) +
      avg2 * pnorm((avg2 - avg1) / sqrt(std1^2 + std2^2)) +
      sqrt(std1^2 + std2^2) * dnorm((avg1 - avg2) / sqrt(std1^2 + std2^2))
  }
  
  bas_exp <- if (length(bas_dists) == 1) {
    bas_dists[[1]]$avg
  } else if (length(bas_dists) == 2) {
    different_series_expectation_2(
      dist1 = bas_dists[[1]],
      dist2 = bas_dists[[2]]
    )
  } else {
    NA
  }
  pot_exp <- if (length(pot_dists) == 1) {
    pot_dists[[1]]$avg
  } else if (length(pot_dists) == 2) {
    different_series_expectation_2(
      dist1 = pot_dists[[1]],
      dist2 = pot_dists[[2]]
    )
  } else {
    NA
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
  ## Must be ordered from oldest to newest
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
  
  # Calculate the single match summaries
  summaries <- if (exponential) {
    matches %>%
      group_by(player_id) %>%
      summarise(
        across(.cols = kills:total, .fns = calculate_exponential_summary)
      )
  } else {
    matches %>%
      group_by(player_id) %>%
      summarise(across(.cols = kills:total, .fns = ~mean(., na.rm = TRUE)))
  }
  
  # Calculate the period summaries
  if (!is.null(player_series)) {
    period_summaries <- matches %>%
      right_join(player_series, by = "player_id") %>%
      group_by(player_id) %>%
      summarise(
        calculate_period_summary(
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
    summaries <- summaries %>% right_join(period_summaries, by = "player_id")
  }
  
  return(summaries)
}
