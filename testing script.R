library(httr) # change to require
library(jsonlite) # change to require


res = GET("https://api-web.nhle.com/v1/score/2024-10-07")

json = fromJSON(rawToChar(res$content))

data <- data.frame(gameDate = json$games$gameDate)
