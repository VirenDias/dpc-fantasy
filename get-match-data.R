source("get-player-data.R")

library(tidyverse)
library(httr)

get_match_data <- function(league_id, update = FALSE, num_matches = 25) {
  message(paste0("Retrieving match data for league ID ", league_id))
  
  dir_path <- "data/"
  file_path <- paste0(dir_path, "/match_cache.csv")
  if (!dir.exists(dir_path) || !file.exists(file_path)) {
    update <- TRUE
  }
  
  # Get player IDs
  player_ids <- get_player_data(league_id = league_id, update = FALSE)$player_id
  
  if (update) {
    # Get recent pro match data
    match_list <- data.frame(
      player_id = as.numeric(),
      match_id = as.numeric()
    )
    i <- 1
    for (player_id in player_ids) {
      message(paste0("Retrieving match IDs (", i, "/", length(player_ids), ")"))
      
      response <- GET(
        "https://datdota.com/api/players/single-performance",
        query = list(
          players = player_id,
          tier = "1,2",
          "valve-event" = "does-not-matter"
        )
      )
      if (http_status(response)$category != "Success") {
        message(paste0("Unsuccessful request for player ID: ", player_id))
      }
      
      # Store last 25 match IDs
      for (match in content(response)$data[1:num_matches]) {
        match_list <- match_list %>% add_row(
          player_id = as.numeric(player_id),
          match_id = as.numeric(match$matchId)
        )
      }
      
      i <- i + 1
      Sys.sleep(1)
    }
    
    # Load and skip cached matches
    if (file.exists(file_path)) {
      cached_data <- read_csv(
        file = file_path,
        col_types = list(.default = "n"),
        progress = FALSE
      )
    } else {
      cached_data <- data.frame(
        player_id = as.numeric(),
        match_id = as.numeric(),
        kills = as.numeric(),
        deaths = as.numeric(),
        creep_score = as.numeric(),
        gold_per_min = as.numeric(),
        tower_kills = as.numeric(),
        roshan_kills = as.numeric(),
        team_fight = as.numeric(),
        obs_wards_planted = as.numeric(),
        camps_stacked = as.numeric(),
        runes_grabbed = as.numeric(),
        first_blood = as.numeric(),
        stuns = as.numeric(),
        total = as.numeric()
      )
    }
    remaining_list <- match_list %>%
      anti_join(cached_data, by = c("player_id", "match_id"))
    
    # Get match data for remaining matches
    new_data <- slice(cached_data, 0)
    i <- 1
    for (match_id in unique(remaining_list$match_id)) {
      message(
        paste0(
          "Retrieving matches (",
          i, 
          "/", 
          length(unique(remaining_list$match_id)),
          ")"
        )
      )
      
      response <- GET(paste0("https://api.opendota.com/api/matches/", match_id))
      if (http_status(response)$category != "Success") {
        message(paste0("Unsuccessful request for match ID: ", match_id))
      }
      
      for (player in content(response)$players) {
        new_data <- new_data %>%
          add_row(
            player_id = as.numeric(player$account_id),
            match_id = as.numeric(match_id),
            kills = as.numeric(player$kills)*0.3,
            deaths = 3 - as.numeric(player$deaths)*0.3,
            creep_score = as.numeric(player$last_hits + player$denies)*0.003,
            gold_per_min = as.numeric(player$gold_per_min)*0.002,
            tower_kills = as.numeric(player$towers_killed),
            roshan_kills = as.numeric(player$roshans_killed),
            team_fight = as.numeric(player$teamfight_participation)*3,
            obs_wards_planted = as.numeric(player$obs_placed)*0.5,
            camps_stacked = as.numeric(player$camps_stacked)*0.5,
            runes_grabbed = as.numeric(player$rune_pickups)*0.25,
            first_blood = as.numeric(player$firstblood_claimed)*4,
            stuns = as.numeric(player$stuns)*0.05,
            total = kills + deaths + creep_score + gold_per_min + tower_kills + 
              roshan_kills + team_fight + obs_wards_planted + camps_stacked +
              runes_grabbed + first_blood + stuns
          )
      }
      
      i <- i + 1
      Sys.sleep(1)
    }
    
    all_data <- union(cached_data, new_data)
    
    # Cache new data
    if (!dir.exists(dir_path)) {
      dir.create(dir_path)
    }
    write_csv(x = all_data, file = file_path)
    
    # Retrieve relevant data
    matches <- all_data %>% filter(player_id %in% player_ids)
  } else {
    matches <- read_csv(
      file_path, 
      progress = FALSE, 
      show_col_types = FALSE
    ) %>%
      filter(player_id %in% player_ids)
  }
  
  return(matches)
}