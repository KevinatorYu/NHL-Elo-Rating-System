library(readr)

## Build list of teams with their team statistics

# Scalp data from NHL API using given teams_api_url on the end date 
url <- paste0(teams_api_url, end_date)
res = GET(url)
json = fromJSON(rawToChar(res$content))

standings <- json$standings

# Build data frame with list of teams
team_data <- data.frame(
  teamName = standings$placeName$default,
  confName = standings$conferenceName,
  divName = standings$divisionName,
  GP = standings$gamesPlayed,
  W = standings$wins,
  L = standings$losses,
  OTL = standings$otLosses,
  PTS = standings$points,
  PTS_P = round(standings$pointPctg, 3),
  RW = standings$regulationWins,
  ROW = standings$regulationPlusOtWins,
  GF = standings$goalFor,
  GA = standings$goalAgainst,
  DIFF = standings$goalDifferential,
  HOME = paste0(standings$homeWins, "-", standings$homeLosses, "-", standings$homeOtLosses),
  AWAY = paste0(standings$roadWins, "-", standings$roadLosses, "-", standings$roadOtLosses),
  SO = paste0(standings$shootoutWins, "-", standings$shootoutLosses),
  L10 = paste0(standings$l10Wins, "-", standings$l10Losses, "-", standings$l10OtLosses),
  STRK = paste0(standings$streakCode, standings$streakCount)
)

# Add Base Ranking
team_data$baseRank <- seq_len(nrow(team_data))
# reorder s.t. base rank is the first column
team_data <- team_data[, c("baseRank", setdiff(names(team_data), "baseRank"))]

# Export as CSV
if (!dir.exists("data")) dir.create("data")
write.csv(team_data, "data/team_data.csv", row.names = FALSE, fileEncoding = "UTF-8")

# Need to use readr because of UTF-8-BOM encoding (Montréal looks weird in Excel)
write_excel_csv(team_data, "data/team_data.csv")

# Clear variables
suppressWarnings({
  rm("json", "res", "standings", "url")
})
