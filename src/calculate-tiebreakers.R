source("src/get-schedule.R")

library(tidyverse)

calculate_tiebreakers <- function(
    league_id, 
    start_time, 
    end_time,
    tiebreaker_ranks = NULL,
    tie_best_of = 1,
    tie_2_best_of = 3,
    update = FALSE
) {
  message(paste0("Calculating tiebreakers for league ID ", league_id))
  
  # Get schedule and determine relevant node groups
  schedule <- get_schedule(league_id, update = update) %>%
    suppressMessages()
  node_groups <- schedule %>%
    filter(time >= start_time, time < end_time) %>%
    pull(node_group_id) %>%
    unique()
  
  # Determine all possible tiebreakers and associated percentage of scenarios
  lapply(node_groups, function(node_group) {
    
    ## Determine all possible scenarios
    scenarios <- schedule %>%
      filter(
        node_group_id == node_group, 
        time >= start_time, time < end_time
      ) %>%
      select(-team_wins_1, -team_wins_2) %>%
      expand_grid(team_wins_1 = 0:max(best_of), team_wins_2 = 0:max(best_of)) %>%
      relocate(team_wins_1, team_wins_2, .before = time) %>%
      filter(team_wins_1 + team_wins_2 == best_of) %>%
      group_split(node_id)
    scenarios <- scenarios %>%
      lapply(function(x) 1:nrow(x)) %>% 
      cross() %>%
      lapply(function(x) {
        mapply(
          FUN = function(y, z) slice(y, z),
          y = scenarios, 
          z = x, 
          SIMPLIFY = FALSE
        ) %>%
          bind_rows()
      })
    
    ## Determine all possible ties
    ties <- lapply(scenarios, function(scenario) {
      schedule %>% 
        filter(node_group_id == node_group, time < start_time) %>% 
        bind_rows(scenario) %>% 
        mutate(
          team_points_1 = ifelse(
            best_of == 2, 
            team_wins_1, 
            as.integer(team_wins_1 > team_wins_2)
          ),
          team_points_2 = ifelse(
            best_of == 2, 
            team_wins_2, 
            as.integer(team_wins_2 > team_wins_1)
          )
        ) %>%
        pivot_longer(
          cols = c(team_id_1, team_id_2, team_points_1, team_points_2), 
          names_to = c(".value", "team"), 
          names_pattern = "(^.+)(_.$)"
        ) %>%
        group_by(team_id) %>%
        summarise(points = sum(team_points), .groups = "drop") %>%
        mutate(rank = min_rank(desc(points))) %>%
        group_by(rank) %>%
        filter(n() > 1) %>%
        arrange(team_id) %>%
        summarise(
          tied_teams = list(team_id),
          tied_ranks = sapply(unique(rank), function(x) list(x:(x + n() - 1))),
          .groups = "drop"
        ) %>%
        select(-rank)
    }) %>%
      bind_rows(.id = "scenario_id")
    
    ## Determine which ties will result in tiebreakers
    tiebreakers <- if (is.null(tiebreaker_ranks)) {
      ties
    } else {
      lapply(tiebreaker_ranks, function(tiebreaker_rank) {
        ties %>%
          rowwise() %>%
          filter(
            tiebreaker_rank %in% tied_ranks,
            (tiebreaker_rank + 1) %in% tied_ranks
          )
      }) %>%
        bind_rows() %>%
        distinct()
    }
    
    ## Determine format and percentage of scenarios for each tiebreaker
    tiebreakers <- tiebreakers %>%
      group_by(tied_teams, tied_ranks) %>%
      summarise(
        best_of = ifelse(lengths(unique(tied_ranks)) == 2, tie_2_best_of, tie_best_of),
        scenarios_num = n(),
        scenarios_total = length(scenarios), 
        .groups = "drop"
      )
    
    return(tiebreakers)
  }) %>%
    bind_rows()
}
