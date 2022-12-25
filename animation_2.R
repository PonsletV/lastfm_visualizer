processed_data <- read.csv(file = "processed_data.csv", stringsAsFactors = F)

tops <- processed_data %>%
  group_by(monthID) %>%
  mutate(rank = rank(-value, ties.method="random"),
         Value_rel = value/value[rank==1],
         Value_lbl = sapply(as.integer(value), toString)) %>%
  group_by(category) %>%
  filter(rank <= 25) %>%
  ungroup()

# re order
tops <- tops[order(tops$rank),]
tops <- tops[order(tops$monthID),]

# 7. ggplot  + gganimate
library(ggplot2)
library(tidyverse)
library(gganimate)
library(gifski)

staticplot = ggplot(tops, aes(rank, group = category,
                                       fill = as.factor(category), color = as.factor(category))) +
  geom_tile(aes(y = value/2,
                height = value,
                width = 0.9), alpha = 0.8, color = NA) +
  geom_text(aes(y = 0, label = paste(category, " ")), vjust = 0.2, hjust = 0, fontface= "bold", color="white", size=16/.pt) +
  geom_text(aes(y=value,label = Value_lbl, hjust=0)) +
  coord_flip(clip = "off", expand = FALSE) +
  scale_y_continuous(labels = scales::comma) +
  scale_x_reverse() +
  guides(color = "none", fill = "none") +
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.position="none",
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        panel.grid.major.x = element_line( size=.1, color="grey" ),
        panel.grid.minor.x = element_line( size=.1, color="grey" ),
        plot.title=element_text(size=25, hjust=0.5, face="bold", colour="grey", vjust=-1),
        plot.subtitle=element_text(size=18, hjust=0.5, face="italic", color="grey"),
        plot.caption =element_text(size=8, hjust=0.5, face="italic", color="grey"),
        plot.background=element_blank(),
        plot.margin = margin(2,2, 2, 4, "cm"))

anim = staticplot + transition_states(date, transition_length = 4, state_length = 1) +
  view_follow(fixed_x = TRUE)  +
  labs(title = 'Cumulated scrobbles : {closest_state}',
       subtitle  =  "Top 25 albums",
       caption  = "My top albums from April 2020 to August 2022. | Data Source: last.fm")

a <- animate(anim, 600, fps = 20,  width = 1200, height = 1000,
        renderer = ffmpeg_renderer()) 
anim_save("animation.mp4", animation = a )
