library("rjson")
api <- fromJSON(file = "API.json")

username <- readline(prompt="lastfm username: ")

library(scrobbler)
lastFM <- download_scrobbles(username = username, api_key = api$key)

write.csv(lastFM, file="lastFMdata.csv")
