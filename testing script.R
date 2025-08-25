library(httr) # change to require
library(jsonlite)
library(lubridate)

## Build dataset of all regular season games

# Define constants: start and end dates, urls, etc.
start_date <- as.Date("2024-10-01")
end_date <- as.Date("2024-11-01")

api_url <- "https://api-web.nhle.com/v1/score/"



# Generate sequence of dates
date_seq <- seq.Date(from = start_date, to = end_date, by = "day")

# Convert to character
date_char <- as.character(date_seq)

# Build dataset

for (date in date_char) {
  
  
  # if dataset doesn't exist yet, make a new data frame
  if (!exists("game_data")) {
    game_data <- data.frame()
  }
  
  # skip if date exists in dataset already
  if (!(date %in% game_data$gameDate)) {
    
    # Scalp data from NHL API using given api_url, start and end dates 
    url <- paste0(api_url, date)
    res = GET(url)
    json = fromJSON(rawToChar(res$content))
    
    # If there are no regular season games during the date, skip
    if ((length(json$games) != 0 ) && 
        (length(subset(json$games, gameType == 2)) != 0)) {
      
      # Get rid of games that were cancelled
      games <- subset(json$games, gameScheduleState != "CNCL")
      
      # Get rid of preseason or playoff games
      games <- subset(json$games, gameType == 2)
      
      # Change Start time from UTC to PST
      games$startTimePST = with_tz(ymd_hms(games$startTimeUTC, tz = "UTC"), tz = "America/Los_Angeles")
      
      # Build list of games for the date
      date_data <- data.frame(
        gameType = games$gameType, 
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
      game_data <- rbind(game_data, date_data)
      
      # Print the date of which games have successfully been added to dataset
      # Ignore cancelled games
      if (nrow(date_data) != 0) {
        print(paste0(date, " added to game_data"))
      }
    }
  }
  
}

# Clear variables
rm("date_data", "games", "json", "res", "date", "date_char", "date_seq", "url")

