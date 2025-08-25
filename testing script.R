library(httr) # change to require
library(jsonlite)
library(lubridate)

# Build dataset of all regular season games

# Define constants: start and end dates, urls, etc.
start_date <- as.Date("2024-10-04")
end_date <- as.Date("2024-10-30")

api_url <- "https://api-web.nhle.com/v1/score/"



# Generate sequence of dates
date_seq <- seq.Date(from = start_date, to = end_date, by = "day")

# Convert to character
date_char <- as.character(date_seq)

# Build dataset

data <- data.frame()

for (date in date_char) {
  
  url <- paste0(api_url, date)
  
  res = GET(url)
  
  json = fromJSON(rawToChar(res$content))
  
  # If there are no games during the date, skip
  if (length(json$games) != 0) {
    
    # Get rid of cancelled games
    games <- subset(json$games, gameScheduleState != "CNCL")
    
    games$startTimePST = with_tz(ymd_hms(games$startTimeUTC, tz = "UTC"), tz = "America/Los_Angeles")
    
    date_data <- data.frame(
      gameType = games$gameType, 
      gameDate = games$gameDate, 
      startTimePST = games$startTimePST,
      visitor = games$awayTeam$name$default,
      visitorScore = games$awayTeam$score,
      home = games$homeTeam$name$default,
      homeScore = games$homeTeam$score,
      gameOutcome = games$gameOutcome$lastPeriodType
    )
    
    data <- rbind(data, date_data)
    
  }
  
}


