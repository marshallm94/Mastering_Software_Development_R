library(tidyverse)
library(lubridate)
library(ggplot2)
library(geosphere)
library(ggmap)
library(grid)

# register API key - only needs to be run once
# con <- file("~/.bash_profile")
# results <- readLines(con)
# close(con)
# 
# api_key <- str_split(results[grepl("GOOGLE_MAPS_KEY", results)], "=")[[1]][2]
# register_google(key = api_key, write = TRUE)

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
df <- ext_tracks %>%
  dplyr::filter(hour == '12') %>%
  tidyr::pivot_longer(radius_34_ne:radius_64_nw,
	       names_to = 'tmp',
	       values_to = 'value') %>%
  tidyr::separate('tmp', c('tmp','wind_speed','direction')) %>%
  tidyr::pivot_wider(names_from = 'direction', values_from = 'value') %>%
  dplyr::mutate(date = lubridate::ymd_h(paste(year, month, day, hour,
					      sep = '-')),
	 storm_id = stringr::str_to_title(paste(storm_name, year, sep = '-')),
	 longitude = -longitude) %>%
  dplyr::select(-tmp) %>%
  dplyr::mutate(month = as.numeric(month),
		day = as.numeric(day),
		hour = as.numeric(hour),
		wind_speed = as.factor(wind_speed),
		ne = 1852 * ne,
		se = 1852 * se,
		nw = 1852 * nw,
		sw = 1852 * sw)

katrina <- df %>% dplyr::filter(storm_id == "Katrina-2005",
				month == 8,
				day == 29) %>%
  select(latitude, longitude, wind_speed, ne, se, sw, nw)

long <- katrina %>%
  filter(wind_speed == 34) %>%
  pivot_longer(c(ne, se, sw, nw),
	       names_to = "direction",
	       values_to = 'value') %>%
  mutate(wind_speed = as.numeric(34),
	 bearing = c(45, 135, 225, 315)) %>%
  slice(1)

tmp <- tibble(longitude = destPoint(p = c(-89.6, 29.5),
				    b = 1:360,
				    d = 370400)[,1],
	      latitude = destPoint(p = c(-89.6, 29.5),
                                   b = 1:360,
                                   d = 370400)[,2]) 
ggplot(tmp, aes(x = longitude, y = latitude)) +
  geom_polygon(color = 'red')



# base_map + geom_polygon(data = z, aes(x = lon,
# 				      y = lat,
# 				      fill = factor(wind_speed),
# 				      color = factor(wind_speed),
# 				      group = wind_speed)) +
#   scale_color_manual(name = "Wind speed (kts)",
# 		     values = c('red','orange','yellow')) +
#   scale_fill_manual(name = "Wind speed (kts)", 
# 		     values = c('red','orange','yellow'))


map <- get_map(katrina %>%
	       select(longitude, latitude) %>%
	       slice(1),
	       zoom = 6,
	       maptype = 'toner-background')
base_map <- ggmap(map)
plot(base_map)

base_map + geom_polygon(data = df_out, aes(x = longitude,
					   y = latitude, 
					   fill = factor(wind_speed),
					   color = factor(wind_speed),
					   group = wind_speed)) +
  scale_color_manual(name = "Wind speed (kts)",
		     values = c('red','orange','yellow')) +
  scale_fill_manual(name = "Wind speed (kts)", 
		     values = c('red','orange','yellow'))

ggplot(data = katrina) +
  geom_hurricane(aes(x = longitude, y = latitude,
                     r_ne = ne, r_se = se, r_nw = nw, r_sw = sw,
                     fill = wind_speed, color = wind_speed)) +
  scale_color_manual(name = "Wind speed (kts)",
                     values = c("red", "orange", "yellow")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("red", "orange", "yellow"))
