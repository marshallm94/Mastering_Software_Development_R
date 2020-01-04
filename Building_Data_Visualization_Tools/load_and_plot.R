library(tidyverse)
library(lubridate)

source('hurricane_geom.R')

ext_tracks_widths <- c(7, 10, 2, 2, 3, 5, 5, 6, 4, 5, 4, 4, 5, 3, 4, 3, 3, 3,
                       4, 3, 3, 3, 4, 3, 3, 3, 2, 6, 1)

ext_tracks_colnames <- c("storm_id", "storm_name", "month", "day",
                          "hour", "year", "latitude", "longitude",
                          "max_wind", "min_pressure", "rad_max_wind",
                          "eye_diameter", "pressure_1", "pressure_2",
                          paste("radius_34",
				c("ne", "se", "sw", "nw"),
				sep = "_"),
                          paste("radius_50",
				c("ne", "se", "sw", "nw"),
				sep = "_"),
                          paste("radius_64",
				c("ne", "se", "sw", "nw"),
				sep = "_"),
                          "storm_type", "distance_to_land", "final")

ext_tracks <- read_fwf("data/hurricane_data.txt", 
                       fwf_widths(ext_tracks_widths, ext_tracks_colnames),
                       na = "-99")

# tidy data
ext_tracks %>%
  filter(hour == '12') %>%
  pivot_longer(radius_34_ne:radius_64_nw,
	       names_to = 'tmp',
	       values_to = 'value') %>%
  separate('tmp', c('tmp','wind_speed','direction')) %>%
  pivot_wider(names_from = 'direction', values_from = 'value') %>%
  mutate(date = lubridate::ymd_h(paste(year, month, day, hour, sep = '-')),
	 storm_id = str_to_title(paste(storm_name, year, sep = '-')),
	 longitude = -longitude) %>%
  select(storm_id, date, latitude, longitude, wind_speed,
	 ne, nw, se, sw) %>%
  filter(storm_id == 'Katrina-2005', latitude == 29.5) %>%
  glimpse()
