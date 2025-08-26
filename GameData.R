library(httr) # change to require
library(jsonlite)
library(lubridate)
library(dplyr)

## Build dataset of all regular season games

# Generate sequence of dates
date_seq <- seq.Date(from = start_date, to = end_date, by = "day")

# Convert to character
date_char <- as.character(date_seq)

# Build dataset

# if dataset doesn't exist yet, make a new data frame; else load old dataset
if (!file.exists("data/game_data.csv")) {
  game_data <- data.frame()
} else {
  game_data <- read.csv("data/game_data.csv")
}

for (date in date_char) {
  
  # loop check for if date exists in dataset already, or if its the end_date
  # (always update present day because of ongoing games)
  if (!(date %in% game_data$gameDate) || date == end_date) {
    
    # Scalp data from NHL API using given games_api_url, start and end dates 
    url <- paste0(games_api_url, date)
    res = GET(url)
    json = fromJSON(rawToChar(res$content))
    
    # If there are no regular season games during the date, skip
    if ((length(json$games) != 0 ) && 
        (length(subset(json$games, gameType == 2)) != 0)) {
      
      # Get rid of games that were cancelled
      games <- subset(json$games, gameScheduleState != "CNCL")
      
      # Get rid of preseason or playoff games
      games <- subset(games, gameType == 2)
      
      # Get rid of ongoing games (must be checked when NHL regular season is in progress)
      games <- subset(games, gameState == "OFF")
      
      # Change Start time from UTC to PST
      games$startTimePST = with_tz(ymd_hms(games$startTimeUTC, tz = "UTC"), tz = "America/Los_Angeles")
      
      # Build list of games for the date
      date_data <- data.frame(
        gameID = games$id,
        gameDate = games$gameDate,
        # Remove date from startTimePST using regex
        startTimePST = sub("^[^ ]+ ", "", as.character(games$startTimePST)),
        visitor = games$awayTeam$name$default,
        visitorScore = games$awayTeam$score,
        home = games$homeTeam$name$default,
        homeScore = games$homeTeam$score,
        gameOutcome = games$gameOutcome$lastPeriodType
      )
      
      # Combine list of games for the day with previous days 
      before_rows <- nrow(game_data)
      game_data <- rbind(game_data, date_data)
      
      # Remove duplicates
      game_data <- distinct(game_data)
      
      # Count how many games were added
      after_rows <- nrow(game_data)
      new_rows <- after_rows - before_rows
      
      # Print only if new rows were actually added (ignore cancelled games)
      if (new_rows > 0 & nrow(date_data) != 0) {
        plural <- ifelse(new_rows == 1, "game", "games")
        print(paste0(date, " added to game_data (", new_rows, " new ", plural, ")"))
      }
  
    }
  }
  
}

# Export game_data as csv
if (!dir.exists("data")) dir.create("data")
write.csv(game_data, "data/game_data.csv", row.names = FALSE)

# Print when game_data successfully loaded
print("Successfully loaded in game_data")

