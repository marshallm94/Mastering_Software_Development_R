source('load_data.R')

df <- load_data()

katrina <- df %>% dplyr::filter(storm_id == "Katrina-2005",
				month == 8,
				day == 29) %>%
  select(latitude, longitude, wind_speed, ne, se, sw, nw)

map <- get_map(katrina %>%
	       select(longitude, latitude) %>%
	       slice(1),
	       zoom = 6,
	       maptype = 'toner-background')
base_map <- ggmap(map)

quadrant <- list(seq(0,90), seq(90,180), seq(180,270), seq(270,360))
center <- katrina %>% select(longitude, latitude) %>% slice(1)
colors <- c("red", "orange", "yellow")
wind_speeds <- c(34, 50, 64)

for (j in 1:3) {

  # subsetting on wind_speed
  direction <- katrina %>%
    filter(wind_speed == wind_speeds[j]) %>%
    select(c(ne, se, sw, nw)) %>%
    as.list()

  # creating data for plotting
  tmp <- list()
  for (i in 1:4) {

    destPoint(p = center,
	      b = quadrant[[i]],
	      d = direction[[i]] * 1852) %>%
      as_tibble() %>%
      rename(longitude = lon, latitude = lat) %>%
      rbind(center) -> tmp[[i]]

  }

  # add geoms to already created plots
  color <- colors[j]
  for (i in 1:4) {

    base_map <- base_map + geom_polygon(data = tmp[[i]],
					aes(x = longitude, y = latitude),
					fill = color, alpha = 0.5)

  }
}
plot(base_map)


# base_map + geom_polygon(data = z, aes(x = lon,
# 				      y = lat,
# 				      fill = factor(wind_speed),
# 				      color = factor(wind_speed),
# 				      group = wind_speed)) +
#   scale_color_manual(name = "Wind speed (kts)",
# 		     values = c('red','orange','yellow')) +
#   scale_fill_manual(name = "Wind speed (kts)", 
# 		     values = c('red','orange','yellow'))


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
