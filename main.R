
## MAIN


# Define constants: start and end dates, urls, elo constants etc.
start_date <- as.Date("2024-10-01")
end_date <- as.Date("2025-04-17")

games_api_url <- "https://api-web.nhle.com/v1/score/"
teams_api_url <- "https://api-web.nhle.com/v1/standings/"

# Elo (fivethirtyeight default values)
startingElo <- 1500
homeIceBonus <- 50
Kfactor <- 6

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


# References:
# https://fivethirtyeight.com/methodology/how-our-nhl-predictions-work/
# https://github.com/Zmalski/NHL-API-Reference
# Own NHL project (2022), unarchived


# TODO:
# - Incorporate multiple year's of game data (3 years maybe? cause 2022-2023 season was the first season without pandemic problems)
#   - Incorporate preseason ratings (teams retain 70% of rating from end of previous season, fivethirtyeight)
#   - Deal with the renaming of the Coyotes to Utah Hockey Club to Utah Mammoth
# - Remove homeIceBonus for neutral-site games
# - Incorporate playoff games
# - Create script for game predictions + game score