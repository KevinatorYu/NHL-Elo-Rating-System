library(readr)

# Implement Elo based on GameData and TeamData

# Start Elo at 1500 for all 
leaderboard <- team_data
leaderboard$elo <- startingElo

# Function to calculate expected score
expected_score <- function(homeElo, visitorElo) {
  homeElo <- homeElo + homeIceBonus
  return(1 / (1 + 10^((visitorElo - homeElo)/400)))
}

for (gameIndex in 1:nrow(game_data)) {
  
  # get game
  game <- game_data[gameIndex,]
  
  # get team names
  homeTeam <- game$home
  visitorTeam <- game$visitor
  
  # get team elos, expected score
  homeElo <- leaderboard[which(leaderboard$teamName == homeTeam), ]$elo
  visitorElo <- leaderboard[which(leaderboard$teamName == visitorTeam), ]$elo
  
  # get scores
  homeScore <- game$homeScore
  visitorScore <- game$visitorScore
  
  # get expected scores
  expHome <- expected_score(homeElo, visitorElo)
  expVisit <- 1 - expHome
  
  # homeScore outcomes
  if (homeScore > visitorScore && game$gameOutcome == "REG") {
    # home wins in Reg
    S_home <- RegWin
    S_visit <- RegLoss
  } else if (homeScore > visitorScore && (game$gameOutcome == "OT" || game$gameOutcome == "SO")) {
    # home wins in OT/SO
    S_home <- OTWin
    S_visit <- OTLoss
  } else if (homeScore < visitorScore && game$gameOutcome == "REG") {
    # visitor wins in Reg
    S_home <- RegLoss
    S_visit <- RegWin
  } else if (homeScore < visitorScore && (game$gameOutcome == "OT" || game$gameOutcome == "SO")) {
    # visitor wins in OT/SO
    S_home <- OTLoss
    S_visit <- OTWin
  } else {
    S_home <- 0.5
    S_visit <- 0.5
    print(paste0("Tie Detected in gameIndex ", gameIndex, ". Please check"))
  }
  
  # margin multiplier
  margin <- abs(homeScore - visitorScore)
  marginMult <- ifelse(margin > 0, log(margin + 1), 1)
  
  # update ratings
  homeNewElo <- homeElo + Kfactor * (S_home - expHome) * marginMult
  visitorNewElo <- visitorElo + Kfactor * (S_visit - expVisit) * marginMult
  
  leaderboard[which(leaderboard$teamName == homeTeam), ]$elo <- round(homeNewElo, 2)
  leaderboard[which(leaderboard$teamName == visitorTeam), ]$elo <- round(visitorNewElo, 2)
  
}

# reorder leaderboard by elo
leaderboard <- leaderboard[order(-leaderboard$elo),]
leaderboard$eloRank <- seq_len(nrow(team_data))

# reorder s.t. eloRank rank is the first column
leaderboard <- leaderboard[, c("eloRank", setdiff(names(leaderboard), "eloRank"))]

# write leaderboard file into csv
if (!dir.exists("data")) dir.create("data")
write_excel_csv(leaderboard, "data/leaderboard.csv")

