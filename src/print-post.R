source("src/get-player-data.R")
source("src/get-team-data.R")
source("src/get-schedule.R")
source("src/calculate-averages.R")

library(tidyverse)
library(knitr)
library(rlang)

print_post <- function(
  league_ids, 
  update = FALSE,
  start_time, 
  end_time,
  google_sheet,
  file_path
) {
  file.create(file_path)
  table_no <- 2
  all_region_averages <- data.frame()
  
  for (league_name in names(league_ids)) {
    # Get required data
    league_id <- league_ids[[league_name]]
    
    players <- get_player_data(league_id = league_id, update = update)
    teams <- get_team_data(league_id = league_id, update = update)
    schedule <- get_schedule(league_id = league_id, update = update) %>%
      filter(time >= start_time, time < end_time)
    
    series <- schedule %>%
      pivot_longer(cols = team_id_1:team_id_2, values_to = "team_id") %>%
      group_by(team_id) %>%
      summarise(
        num_bo1 = sum(best_of == 1), 
        num_bo2 = sum(best_of == 2), 
        num_bo3 = sum(best_of == 3), 
        num_bo5 = sum(best_of == 5),
        series = paste0("Bo", best_of, collapse = " + ")
      )
    relevant_players <- players %>%
      inner_join(series, by = "team_id") %>%
      select(player_id, starts_with("num_bo"))
    averages <- calculate_averages(
      league_id = league_id, 
      player_series = relevant_players,
      start_time = start_time,
      update = update
    )
    
    all_region_averages <- averages %>%
      select(-starts_with("bo")) %>%
      right_join(players, by = "player_id") %>%
      bind_rows(all_region_averages, .)
    
    # Create section heading
    paste0("# ", league_name) %>% write_lines(file = file_path, append = TRUE)
    write_lines("", file = file_path, append = TRUE)
    
    # Create schedule table
    schedule_table <- schedule  %>%
      arrange(time) %>%
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
      col.names = c("Team 1", "Team 2", "Series Type", "Scheduled Time"),
      align = "lll"
    ) %>%
      write_lines(file = file_path, append = TRUE)
    
    write_lines("", file = file_path, append = TRUE)
    
    # Create choices tables
    choices_table <- averages %>%
      left_join(players, by = "player_id") %>%
      left_join(teams, by = "team_id") %>%
      left_join(series %>% select(team_id, series), by = "team_id") %>%
      arrange(desc(expectation)) %>%
      select(
        player_name, 
        player_role, 
        team_name, 
        series,
        total,
        starts_with("average_"),
        expectation
      )
    if ("total" %in% names(choices_table) & 
        "average_bo1" %in% names(choices_table)) {
      choices_table <- choices_table %>% select(-total)
    }
    
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
          paste0(
            "Avg. Bo", 
            Filter(function(x) x != 1, sort(unique(schedule$best_of)))
          ),
          "Exp."
        )
      ) %>%
        chr_unserialise_unicode() %>%
        write_lines(file = file_path, append = TRUE)
      
      write_lines("", file = file_path, append = TRUE)
    }
  }
  
  # Create card bonus table
  file <- read_lines(file_path, lazy = FALSE)
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
      )
    )
  
  ## Create section heading
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
    "***Table 1:** The average fantasy points earned per role for each indicator.*",
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