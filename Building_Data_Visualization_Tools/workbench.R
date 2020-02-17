source('load_data.R')

df <- load_data()

katrina <- df %>% dplyr::filter(storm_id == "Katrina-2005",
				month == 8,
				day == 29)

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

frames <- tibble()
for (j in 1:3) {

  # subsetting on wind_speed
  direction <- katrina %>%
    filter(wind_speed == wind_speeds[j]) %>%
    select(c(ne, se, sw, nw)) %>%
    as.list()

  # creating data for plotting
  for (i in 1:4) {

    new_data <- destPoint(p = center,
			  b = quadrant[[i]],
			  d = direction[[i]] * 1852) %>%
      as_tibble() %>%
      rename(longitude = lon, latitude = lat) %>%
      mutate(wind_speed = factor(wind_speeds[j]))

    frames <- rbind(frames, new_data)
  }
}

display_plot <- ggplot() 

display_plot + geom_polygon(data = frames, aes(x = longitude,
					   y = latitude,
					   color = wind_speed,
					   fill = wind_speed,
					   group = wind_speed), alpha = 0.75) +
  scale_color_manual(name = "Wind speed (kts)",
		     values = c("red", "orange", "yellow")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("red", "orange", "yellow"))


display_plot <- display_plot + geom_polygon(data = frames,
					    aes(x = longitude, y = latitude),
					    color = factor(wind_speed),
					    fill = factor(wind_speed),
					    group = wind_speed) +
  scale_color_manual(name = "Wind speed (kts)",
		     values = c("red", "orange", "yellow")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("red", "orange", "yellow"))
#   display_plot <- display_plot + geom_polygon(data = frames,
# 					      aes(x = longitude, y = latitude),
# 					      color = colors[j],
# 					      fill = colors[j],
# 					      alpha = 0.75)

plot(display_plot)


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
