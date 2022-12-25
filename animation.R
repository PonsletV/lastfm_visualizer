processed_data <- read.csv(file = "processed_data.csv", stringsAsFactors = F)

tops <- processed_data %>%
  group_by(monthID) %>%
  mutate(rank = min_rank(-cum_count) *1) %>%
  filter(rank <= 10) %>%
  ungroup()

# re order
tops <- tops[order(tops$rank),]
tops <- tops[order(tops$monthID),]

tops$ordering <- 11 - tops$rank
# 7. ggplot  + gganimate
library(ggplot2)
library(tidyverse)
library(gganimate)
library(gifski)

y_max = ceiling(max(tops$cum_count)/100)*100

plot <- tops %>%
  
  ggplot(aes(ordering,
             group = artist)) +
  
  geom_tile(aes(y = cum_count/2,
                height = cum_count,
                width = 0.9,
                fill = artist),
            alpha = 0.9,
            colour = "Black",
            size = 0.75) +
  
  # text on top of bars
  geom_text(aes(y = cum_count, label = artist), 
            vjust = -0.5) +
  
  # text in x-axis (requires clip = "off" in coord_cartesian)
  geom_text(aes(y = 0,
                label = artist),
            vjust = 1.1) +
  
  # label showing the month/year in the top left corner
  geom_label(aes(x=1.5,
                 y=y_max,
                 label=paste0(date)),
             size=8,
             color = 'black') +
  
  coord_cartesian(clip = "off",
                  expand = FALSE) +
  
  labs(title = 'My most played artist over time.',
       subtitle = "My top lastFM artists from April 2020 to August 2022.",
       caption = '\n \n\nsource: lastFM | plot by @statnamara',
       x = '',
       y = '') +
  
  
  theme(
    plot.title = element_text(size = 18),
    axis.ticks.x = element_blank(),
    axis.text.x  = element_blank(),
    legend.position = "none",
  ) +    
  
  transition_states(monthID,
                    transition_length = 20,
                    state_length = 2,
                    wrap = F) +             # wrap = F prevents the last frame being an in-between of the last and first months
  
  ease_aes('cubic-in-out')
animate(plot,
        duration = 48,           # seconds
        fps = 20,
        detail = 20,
        width = 1000,           # px
        height = 700,           # px
        end_pause = 90,
        renderer = gifski_renderer())         # number of frames to freeze on the last frame
anim_save(filename = "lastFM.gif", animation = last_animation())
