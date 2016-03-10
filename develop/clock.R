library("ggplot2")
library("gganimate")
library("dplyr")
library("tidyr")
library("readr")
library("lubridate")
Sys.setlocale("LC_ALL","English")
library("emojifont")
list.emojifonts()
date <- "2016-03-10"
load.emojifont('OpenSansEmoji.ttf')

activities <- read_csv2("timeuse.csv") %>%
  mutate(start = ymd_hms(paste0(date, start, ":00")),
         end = ymd_hms(paste0(date, end, ":00")))

# Generate digitial clock face
first.nine <- c('00', '01', '02', '03', '04', '05', '06', '07', '08', '09')
hours <- c(first.nine, as.character(seq(10,23,1)))
mins <- c(first.nine, as.character(seq(10,59,1)))
time.chars.l <- lapply(hours, function(h) paste(h, ':', mins, sep=''))
time.chars <- do.call(c, time.chars.l)

# Generate analog clock face
hour.pos <- seq(0, 12, 12/(12*60))[1:720]
min.pos <-seq(0,12, 12/60)[1:60]
hour.pos <- rep(hour.pos, 2)
all.times <- tbl_df(cbind(hour.pos, min.pos, 24)) %>%
  mutate(index = time.chars) %>%
  mutate(time = ymd_hms(paste0(date, index, ":00")),
         activity = NA) %>%
  select(-3)
# add activities
for(i in 1:nrow(activities)){
  start <- activities$start[i]
  end <- activities$end[i]
  activity <- activities$activity[i]
  all.times$activity[all.times$time>=start & all.times$time<end] <- activity
}
all.times$activity[nrow(all.times)] <- all.times$activity[nrow(all.times)-1]

cur.time <- all.times %>% gather(name, time.info, 1:2) %>%
  arrange(index) %>%
  mutate(hands = ifelse(name == "hour.pos", 0.5, 1))


# plot!
cur.time2 <- filter(cur.time, time>ymd_hms("2016-03-10 15:00:00"),
                    time<ymd_hms("2016-03-10 23:00:00") )
clock <- ggplot(cur.time2, aes(xmin=time.info,
                               xmax=time.info+0.03, ymin=0,
                               ymax=hands,
                              frame = index))+
geom_rect(aes(alpha=0.5))+
  theme_bw()+
coord_polar()+
  scale_x_continuous(limits=c(0,12), breaks=0:11,
                     labels=c(12, 1:11))+
  scale_y_continuous(limits=c(0,1.1)) +
  coord_polar()+
  geom_text(aes(x = 0,
                y = 0,
                label = emoji(activity)),
            family="OpenSansEmoji", size=20)+
  theme(legend.position="none",
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        axis.title.y=element_blank(),
        panel.background=element_blank(),
        panel.border=element_blank(),panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),plot.background=element_blank())

gg_animate(clock, "clock.mp4", interval = 0.025)
