source('load_data.R')

df <- load_data()

katrina <- df %>% dplyr::filter(storm_id == "Katrina-2005",
				month == 8,
				day == 29) %>%
  select(latitude, longitude, wind_speed, ne, se, sw, nw)

quadrant <- list(seq(0,90), seq(90,180), seq(180,270), seq(270,360))
center <- katrina %>% select(longitude, latitude) %>% slice(1)

tmp <- list()
for (i in 1:4) {

  destPoint(p = center,
	    b = quadrant[[i]],
	    d = 150 * 1852) %>%
    as_tibble() %>%
    rename(longitude = lon, latitude = lat) %>%
    rbind(center) -> tmp[[i]]

}

map <- get_map(katrina %>%
	       select(longitude, latitude) %>%
	       slice(1),
	       zoom = 6,
	       maptype = 'toner-background')
base_map <- ggmap(map)

colors <- c('red','green','blue','yellow')
for (i in 1:4) {

  base_map <- base_map + geom_polygon(data = tmp[[i]],
				      aes(x = longitude, y = latitude),
				      fill = colors[i], alpha = 0.5)

}
plot(base_map)

# ne = 1852 * ne,
# se = 1852 * se,
# nw = 1852 * nw,
# sw = 1852 * sw)


long <- katrina %>%
  pivot_longer(c(ne, se, sw, nw),
	       names_to = "direction",
	       values_to = 'value') %>%
  mutate(bearing_start = case_when(direction == 'ne' ~ 1,
				   direction == 'nw' ~ 90,
				   direction == 'sw' ~ 180,
				   direction == 'se' ~ 270),
	 bearing_stop = case_when(direction == 'ne' ~ 90,
                                  direction == 'nw' ~ 180,
                                  direction == 'sw' ~ 270,
                                  direction == 'se' ~ 360)
  )




tmp <- tibble(longitude = destPoint(p = long %>% select(longitude, latitude),
				    b = 1:45,
				    d = 10000)[,1],
	      latitude = destPoint(p = long %>% select(longitude, latitude),
				   b = 1:45,
                                   d = 10000)[,2]) 
ggplot(tmp, aes(x = longitude, y = latitude)) +
  geom_polygon(fill = 'red')


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
