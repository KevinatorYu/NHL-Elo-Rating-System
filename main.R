
## MAIN


# Define constants: start and end dates, urls, elo constants etc.
start_date <- as.Date("2024-10-01")
end_date <- as.Date("2025-04-17")

games_api_url <- "https://api-web.nhle.com/v1/score/"
teams_api_url <- "https://api-web.nhle.com/v1/standings/"

# Elo
startingElo <- 1500
homeIceBonus <- 50
Kfactor <- 24

# Game Results
RegWin = 1
OTWin = 0.75
OTLoss = 0.25
RegLoss = 0

# Build dataset of game data
source("GameData.R")

# Build team database
source("TeamData.R")

# Produce Elos
source("elo.R")

# print leaderboard onto console
leaderboard