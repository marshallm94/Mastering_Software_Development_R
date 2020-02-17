library(ggplot2)
library(geosphere)

# testing area
source('load_data.R')

df <- load_data()

katrina <- df %>% dplyr::filter(storm_id == "Katrina-2005",
				month == 8,
				day == 29)

compute_group_func <- function(data, scales) {

  quadrant <- list(seq(0,90), seq(90,180), seq(180,270), seq(270,360))

  # x = longitude, y = latitude
  center <- c(data$x, data$y)

  # getting radius for each quadrant/direction
  direction <- data %>%
    select(c(r_ne, r_se, r_sw, r_nw)) %>%
    as.list()

  frames <- data.frame()
  # creating data for plotting
  for (i in 1:4) {

    new_data <- destPoint(p = center,
			  b = quadrant[[i]],
			  d = direction[[i]] * 1852) %>%
      as_tibble() %>%
      rename(x = lon, y = lat)

    frames <- rbind(frames, new_data)

  }
  frames
}

StatHurricane <- ggproto("StatHurricane",
			 Stat,
			 compute_group = compute_group_func,
			 required_aes = c('x','y','r_ne','r_se','r_nw','r_sw'),
			 optional_aes = c('fill','color')
)

stat_hurricane <- function(mapping = NULL, data = NULL, geom = "polygon",
                           position = "identity", na.rm = FALSE, 
                           show.legend = NA, inherit.aes = TRUE, ...) {
        ggplot2::layer(
                stat = StatHurricane, 
                data = data, 
                mapping = mapping, 
                geom = geom, 
                position = position, 
                show.legend = show.legend, 
                inherit.aes = inherit.aes,
                params = list(na.rm = na.rm, ...)
        )
}

ggplot(data = katrina) +
  geom_polygon(stat = 'hurricane', aes(x = longitude, y = latitude,
		     r_ne = ne, r_se = se, r_sw = sw, r_nw = nw,
		     fill = wind_speed,
		     color = wind_speed)) +
  scale_color_manual(name = "Wind speed (kts)",
		     values = c("red", "orange", "yellow")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("red", "orange", "yellow"))


GeomHurricane <- ggproto("GeomHurricane",
			 GeomPolygon,
			 default_aes = aes(alpha = 0.65, lwd = 1),
			 optional_aes = c('fill'),
			 required_aes = c('x','y','r_ne','r_se','r_nw','r_sw'),
			 draw_key = draw_key_polygon
)

geom_hurricane <- function(mapping = NULL, data = NULL, stat = 'hurricane',
                         position = "identity", na.rm = FALSE, 
                         show.legend = NA, inherit.aes = TRUE, ...) {

        ggplot2::layer(
                geom = GeomHurricane,
		mapping = mapping,  
                data = data,
		stat = stat,
		position = position, 
                show.legend = show.legend,
		inherit.aes = inherit.aes,
                params = list(na.rm = na.rm, ...)
        )
}

base_map +
  geom_hurricane(data = katrina, aes(x = longitude, y = latitude,
				     r_ne = ne, r_se = se,
				     r_nw = nw, r_sw = sw,
				     fill = wind_speed,
				     color = wind_speed)) +
  scale_color_manual(name = "Wind speed (kts)",
                     values = c("red", "orange", "yellow")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("red", "orange", "yellow"))
