lastFM <- read.csv("lastFMdata.csv")

# keep only interesting columns
lastFM2 <- lastFM[, c("song_title", "artist", "album", "date")]

# remove time stamp from date
lastFM2$date <- gsub(",.*", "", lastFM2$date)

# format date to date format
library(lubridate)
lastFM2$date <- lubridate::dmy(lastFM2$date)

# reorder by date
lastFM2 <- lastFM2[order(lastFM2$date),]

library(dplyr)

# add year and month as separated fields
lastFM2$year <- year(lastFM2$date)
lastFM2$month <- month(lastFM2$date)

# unique ID per each month (ascending)
lastFM2$monthID <- lastFM2$month + ((lastFM2$year - 2020)* 12)

# remove day from date to keep only month and year
lastFM2$date <- format(lastFM2$date, format="%Y-%m")

# group by month & artist & count the plays
lastFMGrouped <- group_by(lastFM2, artist, monthID, date) %>%
  summarise(count=n())

# order by month (ascending)
lastFMGrouped <- lastFMGrouped[order(lastFMGrouped$monthID),]

# Get every artist name and all dates / month IDs
allBands <- unique(lastFMGrouped$artist)
allMonthIDs <- unique(lastFMGrouped$monthID)
allDates <- unique(lastFMGrouped$date)

refDF <- data.frame(artist = rep(allBands, length(allMonthIDs)),
                    monthID = rep(allMonthIDs, length(allBands)),
                    date = rep(allDates, length(allBands)),
                    count = rep(0, length(allBands)*length(allMonthIDs)))

col_join <- colnames(lastFMGrouped)
col_join <- col_join[col_join != "count"]

# merges the data with reference data
full_agg <- merge(refDF, lastFMGrouped, 
                  by.x = col_join, by.y = col_join,
                  all.x = TRUE, all.y = FALSE,
                  sort = FALSE)

# replaces count with 0 when not played for the month
full_agg$count <- coalesce(full_agg$count.y, full_agg$count.x)

full_agg <- full_agg[, c("artist", "monthID", "date", "count")]

full_agg <- full_agg[order(full_agg$count, decreasing=TRUE),]
full_agg <- full_agg[order(full_agg$monthID),]

# add a cumulative sum of all scrobbles per month
full_agg <- full_agg %>% group_by(artist) %>%
  mutate(cum_count=cumsum(count))

full_agg <- full_agg[full_agg$cum_count != 0,]

full_agg$value <- full_agg$cum_count
full_agg$category <- full_agg$artist
# other solution
# full_agg$cum_count <- ave(full_agg$count, full_agg$artist, FUN = cumsum)

# save preprocessed data in a csv file
write.csv(full_agg, file = "processed_data.csv")

