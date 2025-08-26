
## MAIN


# Define constants: start and end dates, urls, etc.
start_date <- as.Date("2024-10-01")
end_date <- as.Date("2024-11-01")

games_api_url <- "https://api-web.nhle.com/v1/score/"
teams_api_url <- "https://api-web.nhle.com/v1/standings/"

# Build dataset of game data
source("GameData.R")

# Build team database
source("TeamData.R")
