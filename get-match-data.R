source("get-player-data.R")

library(tidyverse)
library(httr)
# Refactor to only get match data
get_prediction_data <- function(
  league_id,
  start_time = as.integer(Sys.time()),
  num_matches = 25,
  update = FALSE
) {
  message(
    paste0(
      "Retrieving prediction data for league ID ", 
      league_id,
      " and period ",
      as.POSIXct(start_time, tz = "UTC", origin = "1970-01-01") %>% as.Date()
    )
  )
  
  dir_path <- paste0("data/", league_id)
  file_path <- paste0(dir_path, "/matches.csv")
  if (!dir.exists(dir_path) || !file.exists(file_path)) {
    update <- TRUE
  }
  
  # Get player IDs
  player_ids <- get_player_data(league_id = league_id, update = FALSE)$player_id
  
  if (update) {
    # Get recent pro match data before start date
    match_ids <- c()
    i <- 1
    for (player_id in player_ids) {
      message(paste0("Retrieving match IDs (", i, "/", length(player_ids), ")"))
      
      response <- GET(
        "https://datdota.com/api/players/single-performance",
        query = list(
          players = player_id,
          before = as.POSIXct(start_time, tz = "UTC", origin = "1970-01-01") %>%
            format(., "%d/%m/%Y"),
          tier = "1,2",
          "valve-event" = "does-not-matter"
        )
      )
      if (http_status(response)$category != "Success") {
        message(paste0("Unsuccessful request for player ID: ", player_id))
      }
      
      # Store last 25 match IDs
      for (match in content(response)$data[1:num_matches]) {
        match_ids <- c(match_ids, match$matchId)
      }
      
      i <- i + 1
      Sys.sleep(1)
    }
    
    # Load and skip cached matches
    if (file.exists(file_path)) {
      cached_data <- read_csv(
        file = file_path,
        progress = FALSE,
        show_col_types = FALSE
      )
    } else {
      cached_data <- data.frame(
        player_id = as.numeric(),
        series_id = as.numeric(),
        series_type = as.numeric(),
        match_id = as.numeric(),
        start_time = as.numeric(),
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
    match_ids <- setdiff(unique(match_ids), unique(cached_data$match_id))
    
    # Get match data for remaining matches
    new_data <- slice(cached_data, 0)
    i <- 1
    for (match_id in match_ids) {
      message(
        paste0(
          "Retrieving match data for match ID ",
          match_id, 
          " (",
          i, 
          "/", 
          length(match_ids),
          ")"
        )
      )
      
      response <- GET(paste0("https://api.opendota.com/api/matches/", match_id))
      if (http_status(response)$category != "Success") {
        message(paste0("Unsuccessful request for match ID: ", match_id))
      }
      
      for (player in content(response)$players) {
        # Get matches before start time (only used start date before)
        if (content(response)$start_time < start_time) {
          new_data <- new_data %>%
            add_row(
              player_id = as.numeric(player$account_id),
              series_id = as.numeric(content(response)$series_id),
              series_type = as.numeric(content(response)$series_type),
              match_id = as.numeric(match_id),
              start_time = as.numeric(content(response)$start_time),
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
              total = kills + deaths + creep_score + gold_per_min + 
                tower_kills + roshan_kills + team_fight + obs_wards_planted + 
                camps_stacked + runes_grabbed + first_blood + stuns
            )
        }
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
    matches <- all_data
    
  } else {
    matches <- read_csv(
      file_path, 
      progress = FALSE, 
      show_col_types = FALSE
    )
  }
  
  # Retrieve relevant data
  matches <- matches %>% 
    filter(player_id %in% player_ids) %>%
    filter(start_time < !!start_time) %>%
    group_by(player_id) %>%
    slice_max(order_by = start_time, n = num_matches) %>%
    ungroup()
  
  return(matches)
}

################################################################################

get_result_data <- function(
  league_id,
  update = FALSE
) {
  message(paste0("Retrieving results data for league ID ", league_id))
  
  dir_path <- paste0("data/", league_id)
  file_path <- paste0(dir_path, "/matches.csv")
  if (!dir.exists(dir_path) || !file.exists(file_path)) {
    update <- TRUE
  }
  
  # Get league data
  response_league <- GET(
    url = "https://www.dota2.com/webapi/IDOTA2League/GetLeagueData/v001",
    query = list(league_id = league_id)
  )
  if (http_status(response_league)$category != "Success") {
    stop("Unsuccessful request")
  }
  
  # Store match IDs
  match_ids <- c()
  for (series in content(response_league)$series_infos) {
    for (match_id in series$match_ids) {
      match_ids <- c(match_ids, match_id)
    }
  }
  
  if (update) {
    # Load and skip cached matches
    if (file.exists(file_path)) {
      cached_data <- read_csv(
        file = file_path,
        progress = FALSE,
        show_col_types = FALSE
      )
    } else {
      cached_data <- data.frame(
        player_id = as.numeric(),
        series_id = as.numeric(),
        series_type = as.numeric(),
        match_id = as.numeric(),
        start_time = as.numeric(),
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
    remaining_ids <- setdiff(match_ids, unique(cached_data$match_id))
    
    # Get match data for remaining matches
    new_data <- slice(cached_data, 0)
    i <- 1
    for (match_id in remaining_ids) {
      message(
        paste0(
          "Retrieving match data for match ID ",
          match_id, 
          " (",
          i, 
          "/", 
          length(remaining_ids),
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
            series_id = as.numeric(content(response)$series_id),
            series_type = as.numeric(content(response)$series_type),
            match_id = as.numeric(match_id),
            start_time = as.numeric(content(response)$start_time),
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
            total = kills + deaths + creep_score + gold_per_min + 
              tower_kills + roshan_kills + team_fight + obs_wards_planted + 
              camps_stacked + runes_grabbed + first_blood + stuns
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
    matches <- all_data
    
  } else {
    matches <- read_csv(
      file_path, 
      progress = FALSE, 
      show_col_types = FALSE
    )
  }
  
  # Retrieve relevant data
  matches <- matches %>% 
    filter(match_id %in% match_ids)
  
  return(matches)
}