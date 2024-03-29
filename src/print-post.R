source("src/get-player-data.R")
source("src/get-team-data.R")
source("src/get-schedule.R")
source("src/calculate-tiebreakers.R")
source("src/calculate-averages.R")

library(tidyverse)
library(knitr)
library(rlang)

print_post <- function(
    league_ids, 
    start_time, 
    end_time,
    google_sheet,
    file_path,
    innate_data_only = FALSE,
    exponential = FALSE,
    tiebreaker = FALSE,
    tiebreaker_ranks = NULL,
    tie_best_of = 1,
    tie_2_best_of = 3,
    update = FALSE
) {
  options(knitr.kable.NA = "—")
  file.create(file_path)
  table_no <- 2
  all_region_averages <- data.frame()
  
  for (league_name in names(league_ids)) {
    # Get required data --------------------------------------------------------
    league_id <- league_ids[[league_name]]
    
    players <- get_player_data(league_id = league_id, update = update)
    teams <- get_team_data(league_id = league_id, update = update)
    all_schedule <- get_schedule(league_id = league_id, update = update) %>%
      arrange(time)
    schedule <- all_schedule %>% filter(time >= start_time, time < end_time)
    
    # Create section heading ---------------------------------------------------
    paste0("# ", league_name) %>% write_lines(file = file_path, append = TRUE)
    write_lines("", file = file_path, append = TRUE)
    
    # Create schedule table ----------------------------------------------------
    get_potential_teams <- function(team_id, inc_id) {
      if (team_id == 0) {
        potential_ids <- all_schedule %>% 
          filter(node_id == inc_id) %>%
          select(team_id_1, team_id_2) %>%
          unlist()
        if (!(0 %in% potential_ids)) return(potential_ids) else return(team_id)
      } else {
        return(team_id)
      }
    }
    
    if (0 %in% (schedule %>% select(team_id_1, team_id_2) %>% unlist())) {
      schedule <- schedule %>% 
        mutate(
          team_id_1 = mapply(
            FUN = get_potential_teams, 
            team_id = team_id_1,
            inc_id = inc_id_1,
            SIMPLIFY = FALSE
          ),
          team_id_2 = mapply(
            FUN = get_potential_teams,
            team_id = team_id_2,
            inc_id = inc_id_2,
            SIMPLIFY = FALSE
          )
        ) %>%
        unnest(cols = c(team_id_1, team_id_2))
    }
    
    ## Format data
    schedule_table <- schedule %>%
      left_join(teams, by = c("team_id_1" = "team_id")) %>%
      rename(team_name_1 = team_name) %>%
      left_join(teams, by = c("team_id_2" = "team_id")) %>%
      rename(team_name_2 = team_name) %>%
      mutate(
        best_of = paste0("Bo", best_of),
        time = format(
          as.POSIXct(time, tz = "UTC", origin = "1970-01-01"),
          "%Y-%m-%d %H:%M",
          usetz = TRUE
        )
      ) %>%
      group_by(node_id) %>%
      summarise(
        across(
          .cols = everything(), 
          .fns = function(x) {
            if (length(unique(unlist(x))) > 1) {
              return(paste0(unlist(x), collapse = " / "))
            } else {
              return(as.character(x[1]))
            }
          }
        )
      ) %>%
      arrange(time) %>%
      select(team_name_1, team_name_2, best_of, time)
    
    ## Create table caption
    paste0(
      "***Table ",
      table_no,
      ":** The schedule.*"
    ) %>%
      write_lines(file = file_path, append = TRUE)
    
    write_lines("", file = file_path, append = TRUE)
    table_no <- table_no + 1
    
    ## Create table
    kable(
      x = schedule_table,
      format = "pipe",
      col.names = c("Team 1", "Team 2", "Series", "Time"),
      align = "lll"
    ) %>%
      write_lines(file = file_path, append = TRUE)
    
    write_lines("", file = file_path, append = TRUE)
    
    # Create tiebreaker tables -------------------------------------------------
    if (tiebreaker) {
      tiebreakers <- calculate_tiebreakers(
        league_id = league_id,
        start_time = start_time,
        end_time = end_time,
        tiebreaker_ranks = tiebreaker_ranks,
        tie_best_of = tie_best_of,
        tie_2_best_of = tie_2_best_of,
      )
      
      ## General
      ### Format data
      tiebreaker_table <- tiebreakers %>%
        arrange(desc(scenarios_num)) %>%
        group_by(tied_teams) %>%
        transmute(
          teams = paste0(
            teams %>% 
              filter(team_id %in% unlist(tied_teams)) %>% 
              arrange(team_name) %>%
              pull(team_name),
            collapse = " / "
          ),
          ranks = paste0(min(tied_ranks[[1]]), "–", max(tied_ranks[[1]])),
          series = paste0("Bo", best_of),
          scenarios = paste0(scenarios_num, " of ", scenarios_total),
          scenarios_perc = (scenarios_num / scenarios_total) * 100
        ) %>%
        ungroup() %>%
        select(-tied_teams)
      
      ### Create table caption
      paste0(
        "***Table ",
        table_no,
        ":** The potential tiebreakers.*"
      ) %>%
        write_lines(file = file_path, append = TRUE)
      
      write_lines("", file = file_path, append = TRUE)
      table_no <- table_no + 1
      
      ### Create table
      kable(
        x = tiebreaker_table,
        format = "pipe",
        digits = 2,
        col.names = c("Teams", "Ranks", "Series", "Num. Scn.", "Pct. Scn."),
        align = "lllrr"
      ) %>%
        write_lines(file = file_path, append = TRUE)
      
      write_lines("", file = file_path, append = TRUE) 
      
      ## Teamwise
      ### Format data
      teamwise_tiebreaker_table <- tiebreakers %>%
        mutate(
          series = mapply(
            function(x, y) paste0(rep(x, y), collapse = " + "), 
            x = paste0("Bo", best_of), 
            y = lengths(tied_teams) - 1
          )
        ) %>%
        unnest_longer(tied_teams) %>%
        left_join(teams, by = c("tied_teams" = "team_id")) %>%
        group_by(team_name, series) %>%
        summarise(
          scenarios = paste0(
            sum(scenarios_num),
            " of ",
            unique(scenarios_total)
          ),
          scenarios_perc = (sum(scenarios_num) / unique(scenarios_total)) * 100,
          .groups = "drop"
        ) %>%
        rename(team = team_name) %>%
        arrange(team, desc(scenarios_perc), desc(series))
      
      ### Create table caption
      paste0(
        "***Table ",
        table_no,
        ":** The teamwise potential tiebreakers.*"
      ) %>%
        write_lines(file = file_path, append = TRUE)
      
      write_lines("", file = file_path, append = TRUE)
      table_no <- table_no + 1
      
      ### Create table
      kable(
        x = teamwise_tiebreaker_table,
        format = "pipe",
        digits = 2,
        col.names = c("Team", "Series", "Num. Scn.", "Pct. Scn."),
        align = "llrr"
      ) %>%
        write_lines(file = file_path, append = TRUE)
      
      write_lines("", file = file_path, append = TRUE) 
    }
    
    # Create choices tables ----------------------------------------------------
    ## Determine series and relevant players
    series <- schedule %>%
      filter(time >= start_time, time < end_time) %>%
      pivot_longer(
        cols = c(team_id_1, team_id_2), 
        names_to = "slot",
        values_to = "team_id"
      ) %>%
      distinct(team_id, node_id, .keep_all = TRUE) %>%
      group_by(node_id, slot) %>%
      mutate(pot = if_else(condition = n() > 1, true = TRUE, false = FALSE)) %>%
      ungroup() %>%
      group_by(team_id) %>%
      summarise(
        bas_bo1 = sum((best_of == 1)*!pot),
        bas_bo2 = sum((best_of == 2)*!pot),
        bas_bo3 = sum((best_of == 3)*!pot),
        bas_bo5 = sum((best_of == 5)*!pot),
        pot_bo1 = sum((best_of == 1)*pot), 
        pot_bo2 = sum((best_of == 2)*pot), 
        pot_bo3 = sum((best_of == 3)*pot), 
        pot_bo5 = sum((best_of == 5)*pot),
        series = paste0(
          if_else(
            condition = pot, 
            true = paste0("(Bo", best_of, ")"),
            false = paste0("Bo", best_of)
          ),
          collapse = " + ")
      )
    
    ## Include the most likely tiebreaker as a potential series
    if (tiebreaker) {
      tiebreaker_series <- tiebreakers %>% 
        mutate(num_matches = lengths(tied_teams) - 1) %>%
        unnest_longer(tied_teams, values_to = "team_id") %>%
        group_by(team_id, best_of, num_matches) %>%
        summarise(scenarios_num = sum(scenarios_num), .groups = "drop") %>%
        group_by(team_id) %>%
        filter(scenarios_num == max(scenarios_num)) %>%
        filter(best_of == max(best_of)) %>%
        filter(num_matches == max(num_matches)) %>%
        select(-scenarios_num) %>%
        mutate(
          series = mapply(
            function(x, y) paste0(rep(x, y), collapse = " + "),
            x = paste0("(Bo", best_of, ")"),
            y = num_matches
          )
        ) %>%
        pivot_wider(
          names_from = best_of,
          names_glue = "pot_bo{.name}",
          values_from = num_matches
        )
      
      series <- series %>%
        bind_rows(tiebreaker_series) %>%
        group_by(team_id) %>%
        summarise(
          across(.cols = contains("_bo"), ~sum(., na.rm = TRUE)),
          series = paste0(series, collapse = " + ")
        )
    }
    
    relevant_players <- players %>%
      inner_join(series, by = "team_id") %>%
      select(player_id, contains("_bo"))
    
    ## Calculate averages
    averages <- calculate_summaries(
      league_id = league_id, 
      player_series = relevant_players,
      start_time = start_time,
      innate_data_only = innate_data_only,
      exponential = exponential,
      update = update
    )
    
    ## Format data
    choices_table <- averages %>%
      left_join(players, by = "player_id") %>%
      left_join(teams, by = "team_id") %>%
      left_join(series %>% select(team_id, series), by = "team_id") %>%
      select(
        player_name, 
        player_role, 
        team_name, 
        series,
        avg,
        std,
        if (sum(.$bas_exp == .$pot_exp | is.na(.$bas_exp)) < nrow(.)) "bas_exp",
        pot_exp
      ) %>%
      arrange(desc(pot_exp))
    
    roles <- list("Core", "Mid", "Support")
    for (role in roles) {
      ## Create table caption
      paste0(
        "***Table ",
        table_no,
        ":** The potential choices for the ",
        role,
        " role.*"
      ) %>%
        write_lines(file = file_path, append = TRUE)
      
      write_lines("", file = file_path, append = TRUE)
      table_no <- table_no + 1
      
      ## Create table
      kable(
        x = choices_table %>% 
          filter(player_role == role) %>% 
          select(-player_role),
        format = "pipe",
        digits = 2,
        col.names = c(
          "Player", 
          "Team", 
          "Series",
          "Avg.",
          "Std.",
          if ("bas_exp" %in% names(choices_table)) {
            c("Bas. Exp.", "Pot. Exp.")
          } else {
            "Exp."
          }
        )
      ) %>%
        chr_unserialise_unicode() %>%
        write_lines(file = file_path, append = TRUE)
      
      write_lines("", file = file_path, append = TRUE)
    }
    
    # Add to all-region averages -----------------------------------------------
    all_region_averages <- averages %>%
      right_join(players, by = "player_id") %>%
      bind_rows(all_region_averages, .)
  }
  
  # Add notes section ----------------------------------------------------------
  write_lines(
    "# Notes", 
    file = file_path, 
    append = TRUE
  )
  write_lines("", file = file_path, append = TRUE)
  write_lines(
    "* The data has been acquired from OpenDota and datdota.", 
    file = file_path, 
    append = TRUE
  )
  write_lines(
    "* The numbers here are based on each player's 50 most recent tier 1 and 2 pro matches.", 
    file = file_path, 
    append = TRUE
  )
  write_lines(
    "* Each match has been exponentially weighted such that the most recent matches have the biggest impact.", 
    file = file_path, 
    append = TRUE
  )
  write_lines("", file = file_path, append = TRUE)
  
  # Add glossary section -------------------------------------------------------
  write_lines(
    "# Glossary", 
    file = file_path, 
    append = TRUE
  )
  write_lines("", file = file_path, append = TRUE)
  if (tiebreaker) {
    write_lines(
      "* **Num. Scn.:** Number of scenarios, i.e. the number of scenarios in which a particular tiebreaker will take place.", 
      file = file_path, 
      append = TRUE
    )
    write_lines(
      "* **Pct. Scn.:** Percentage of scenarios, i.e. the percentage of all possible scenarios in which a particular tiebreaker will take place.", 
      file = file_path, 
      append = TRUE
    )
  }
  write_lines(
    "* **Avg.:** Average.", 
    file = file_path, 
    append = TRUE
  )
  write_lines(
    "* **Std.:** Standard deviation.", 
    file = file_path, 
    append = TRUE
  )
  write_lines(
    "* **Exp.:** Expectation / expected value.", 
    file = file_path, 
    append = TRUE
  )
  write_lines(
    "* **Bas. Exp.:** Baseline expectation, i.e. the expectation if only the confirmed series are played.", 
    file = file_path, 
    append = TRUE
  )
  write_lines(
    "* **Pot. Exp.:** Potential expectation, i.e. the expectation if all potential series are played.", 
    file = file_path, 
    append = TRUE
  )
  write_lines(
    "* **(BoX):** Denotes series that could potentially be played depending on the outcome of earlier series.", 
    file = file_path, 
    append = TRUE
  )
  write_lines("", file = file_path, append = TRUE)
  
  # Create card bonus table ----------------------------------------------------
  card_bonus_table <- all_region_averages %>%
    group_by(player_role) %>%
    summarise(across(.cols = kills:stuns, .fns = ~mean(., na.rm = TRUE))) %>%
    gather(key = "Indicator", value = "value", kills:stuns) %>%
    spread(key = player_role, value = value) %>%
    mutate(
      Indicator = recode_factor(
        Indicator,
        "kills" = "Kills",
        "deaths" = "Deaths",
        "creep_score" = "Creep Score",
        "gold_per_min" = "GPM",
        "tower_kills" = "Tower Kills",
        "roshan_kills" = "Roshan Kills",
        "team_fight" = "Teamfight",
        "obs_wards_planted" = "Obs Wards",
        "camps_stacked" = "Camps Stacked",
        "runes_grabbed" = "Runes Grabbed",
        "first_blood" = "First Blood",
        "stuns" = "Stuns"
      ),
      across(.cols = -Indicator, .fns = ~.*100/sum(.))
    )
  
  ## Create section heading
  file <- read_lines(file_path, lazy = FALSE)
  write_lines(
    "# Gold/Silver Card Bonuses", 
    file = file_path, 
    append = FALSE
  )
  write_lines("", file = file_path, append = TRUE)
  
  ## Create section text
  write_lines(
    paste0(
      "Please refer to this [Google Sheet](https://docs.google.com/spreadsheets/d/",
      google_sheet,
      ") for what to look for for each individual player, or the table below for what to look for for each role in general."
    ),
    file = file_path, 
    append = TRUE
  )
  write_lines("", file = file_path, append = TRUE)
  
  ## Create table caption
  write_lines(
    "***Table 1:** The percentage of fantasy points earned by each indicator for each role.*",
    file = file_path, 
    append = TRUE
  )
  write_lines("", file = file_path, append = TRUE)
  
  ## Create table
  kable(
    x = card_bonus_table,
    format = "pipe",
    digits = 2
  ) %>%
    write_lines(file = file_path, append = TRUE)
  write_lines("", file = file_path, append = TRUE)
  
  write_lines(file, file = file_path, append = TRUE)
}
