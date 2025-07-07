# map plot of station locations, wind direction and wind speed for a single
# timestamp

library(tidyverse)
library(lubridate)

meta = read_csv('data/METADATA.csv') |>
       select(id, lon, lat)
  
# load data
tstamp = '2023-06-01 12:00'
w = read_csv(paste('data/midas-wind-', year(tstamp), '.csv.gz', sep='')) |> 
  filter(time == tstamp) |>
  left_join(meta, by='id') 

# convert speed from knots to kmh and calculate u and v, and approximate 1-hour
# displacement coordinates
w = w |> mutate(speed = speed * 1.852,
                u = speed * cospi(dir / 180),
                v = speed * sinpi(dir / 180),
                dlon = u * 0.015, 
                dlat = v * 0.009) 

# map plot
ggplot(w) + 
  geom_point(aes(x=lon, y=lat, col=speed)) +
  geom_segment(aes(x=lon, y=lat, xend=lon+dlon, yend=lat+dlat, col=speed)) + 
  scale_colour_viridis_c(option='C') +
  borders(region='UK') +
  theme_bw()

ggsave('fig/example_01.png', width=6, height=8)
