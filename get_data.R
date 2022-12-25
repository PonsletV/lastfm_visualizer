username <- "ponsletv"
apiKey <- "29245bbe7903da4ec9dbe327a8b7c741"
apiSecret <- "d8578c1038ce6a469671a1f692e922d2"

library(scrobbler)
lastFM <- download_scrobbles(username = username, api_key = apiKey)

write.csv(lastFM, file="lastFMdata.csv")

