source("get-player-data.R")
source("get-team-data.R")
source("get-schedule.R")
source("calculate-averages.R")

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
  
  for (region_name in names(league_ids)) {
    # Get required data
    league_id <- league_ids[[region_name]]
    
    players <- get_player_data(league_id = league_id, update = update)
    teams <- get_team_data(league_id = league_id, update = update)
    schedule <- get_schedule(league_id = league_id, update = update) %>%
      filter(time >= start_time, time < end_time)
    averages <- calculate_averages(
      league_id = league_id, 
      start_time = start_time,
      update = update
    )
    
    relevant_teams <- unique(c(schedule$team_id_1, schedule$team_id_2))
    series <- schedule %>%
      pivot_longer(cols = team_id_1:team_id_2, values_to = "team_id") %>%
      group_by(team_id) %>%
      summarise(series = n())
    all_region_averages <- averages %>%
      right_join(players, by = "player_id") %>%
      bind_rows(all_region_averages, .)
    
    # Create section heading
    paste0("# ", region_name) %>% write_lines(file = file_path, append = TRUE)
    write_lines("", file = file_path, append = TRUE)
    
    # Create schedule table
    schedule <- schedule  %>%
      arrange(time) %>%
      left_join(teams, by = c("team_id_1" = "team_id")) %>%
      rename(team_name_1 = team_name) %>%
      left_join(teams, by = c("team_id_2" = "team_id")) %>%
      rename(team_name_2 = team_name) %>%
      mutate(
        time = format(
          as.POSIXct(time, tz = "UTC", origin = "1970-01-01"),
          "%Y-%m-%d %H:%M",
          usetz = TRUE
        )
      ) %>%
      select(team_name_1, team_name_2, time)
    
    ## Create table caption
    paste0(
      "***Table ",
      table_no,
      ":** The schedule for the ",
      region_name,
      " region.*"
    ) %>%
      write_lines(file = file_path, append = TRUE)
    
    write_lines("", file = file_path, append = TRUE)
    table_no <- table_no + 1
    
    ## Create table
    kable(
      x = schedule,
      format = "pipe",
      col.names = c("Team 1", "Team 2", "Scheduled Time"),
      align = "lll"
    ) %>%
      write_lines(file = file_path, append = TRUE)
    
    write_lines("", file = file_path, append = TRUE)
    
    # Create choices tables
    averages <- averages %>%
      right_join(players, by = "player_id") %>%
      left_join(teams, by = "team_id") %>%
      left_join(series, by = "team_id") %>%
      filter(team_id %in% relevant_teams) %>%
      arrange(desc(total)) %>%
      select(player_name, player_role, team_name, series, total)
    
    roles <- list("Core", "Mid", "Support")
    for (role in roles) {
      ## Create table caption
      paste0(
        "***Table ",
        table_no,
        ":** The potential choices for the ",
        role,
        " role in the ",
        region_name,
        " region.*"
      ) %>%
        write_lines(file = file_path, append = TRUE)
      
      write_lines("", file = file_path, append = TRUE)
      table_no <- table_no + 1
      
      ## Create table
      kable(
        x = averages %>% filter(player_role == role) %>% select(-player_role),
        format = "pipe",
        digits = 2,
        col.names = c("Player", "Team", "Series", "Avg.")
      ) %>%
        chr_unserialise_unicode() %>%
        write_lines(file = file_path, append = TRUE)
      
      write_lines("", file = file_path, append = TRUE)
    }
  }
  
  # Create card bonus table
  file <- read_lines(file_path, lazy = FALSE)
  all_region_averages <- all_region_averages %>%
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
    x = all_region_averages,
    format = "pipe",
    digits = 2
  ) %>%
    write_lines(file = file_path, append = TRUE)
  
  write_lines("", file = file_path, append = TRUE)
  write_lines(file, file = file_path, append = TRUE)
}