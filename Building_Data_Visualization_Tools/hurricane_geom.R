library(ggpubr)
library(tidyverse)
library(lubridate)
library(geosphere)
library(ggmap)
library(grid)

register API key - only needs to be run once
con <- file("~/.bash_profile")
results <- readLines(con)
close(con)

api_key <- str_split(results[grepl("GOOGLE_MAPS_KEY", results)], "=")[[1]][2]
register_google(key = api_key, write = TRUE)


#' Read in data.
#'
#' Reads the hurricane data into a data frame. The filepath to the data should
#' be 'data/hurricane_data.txt'.
#'
#' @return The Extended Best Track dataset in a tibble.
#' 
#' @import readr
#' @import dplyr
#' 
#' @examples
#' df <- load_data()
#'
#' @export
load_data <- function() {

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

  ext_tracks <- readr::read_fwf("data/hurricane_data.txt",
				readr::fwf_widths(ext_tracks_widths, ext_tracks_colnames),
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
		  wind_speed = as.factor(wind_speed))

    return(df)
}

#' Creates a data frame of latitude and longitude points to plot the radius of
#' a given wind radii.
#'
#' @param data The data for a given wind speed of a hurricane instance.
#' @param scales 
#' @param scale_radii The amount the radius should be scaled for the plot. 
#'
#' @return A data frame
#' 
#' @import geosphere
#' @import tibble
#' @import dplyr
compute_group_func <- function(data, scales, scale_radii) {

  quadrant <- list(seq(0,90), seq(90,180), seq(180,270), seq(270,360))

  # x = longitude, y = latitude
  center <- c(data$x, data$y)

  # getting radius for each quadrant/direction
  direction <- data %>%
    dplyr::select(c(r_ne, r_se, r_sw, r_nw)) %>%
    as.list()

  frames <- data.frame()
  # creating data for plotting
  for (i in 1:4) {

    new_data <- geosphere::destPoint(p = center,
				     b = quadrant[[i]],
				     d = direction[[i]] * 1852 * scale_radii) %>%
      tibble::as_tibble() %>%
      dplyr::rename(x = lon, y = lat)

    frames <- rbind(frames, new_data)

  }
  frames
}

#' The Stat backend for GeomHurricane
#' 
#' @import ggplo2
StatHurricane <- ggplot2::ggproto("StatHurricane",
				  Stat,
				  compute_group = compute_group_func,
				  required_aes = c('x','y','r_ne','r_se',
						   'r_nw','r_sw','fill','colour'),
				  optional_aes = c('scale_radii')
)

#' The Geom backend for geom_hurricane.
#' 
#' @import ggplo2
GeomHurricane <- ggplot2::ggproto("GeomHurricane",
				  GeomPolygon,
				  default_aes = ggplot2::aes(alpha = 0.65, lwd = 0.75),
				  required_aes = c('x','y','r_ne','r_se','r_nw',
						   'r_sw','fill','colour'),
				  optional_aes = c('scale_radii')
)

#' Plots a hurricane instance.
#'
#' Create a circular shape that displays how far various wind speeds reached in
#' each of the NE, SE, SW and NW directions.
#'
#' @param x The longitude of the hurricane.
#' @param y The latitude of the hurricane
#' @param r_ne The miles that a given wind speed was recored to have reached in the NE direction.
#' @param r_se The miles that a given wind speed was recored to have reached in the SE direction.
#' @param r_nw The miles that a given wind speed was recored to have reached in the NW direction.
#' @param r_sw The miles that a given wind speed was recored to have reached in the SW direction.
#' @param scale_radii The number to scale the 4 radii by.
#' @param fill The speed of the wind.
#' @param color The speed of the wind.
#'
#' @return A ggplot2 plot.
#' 
#' @import ggplot2
#' 
#' @examples
#' df <- load_data()
#' katrina <- df %>% dplyr::filter(storm_id == "Katrina-2005",
#'				   month == 8,
#'				   day == 29)
#' geom_hurricane(data = katrina, ggplot2::aes(x = longitude, y = latitude,
#'					       r_ne = ne, r_se = se, r_nw = nw, r_sw = sw,
#'					       fill = wind_speed,
#'					       color = wind_speed)) +
#' ggplot2::scale_color_manual(name = "Wind speed (kts)",
#'			       values = c("red", "orange", "yellow")) +
#' ggplot2::scale_fill_manual(name = "Wind speed (kts)",
#'			      values = c("red", "orange", "yellow")) +
#'
#' @export
geom_hurricane <- function(mapping = NULL, data = NULL, scale_radii = 1,
			   position = "identity", na.rm = FALSE, 
			   show.legend = NA, inherit.aes = TRUE, ...) {

        ggplot2::layer(
                geom = GeomHurricane,
		mapping = mapping,  
                data = data,
		stat = StatHurricane,
		position = position, 
                show.legend = show.legend,
		inherit.aes = inherit.aes,
                params = list(na.rm = na.rm, scale_radii = scale_radii, ...)
        )
}


# code to produce plot
df <- load_data()

ike <- df %>% dplyr::filter(storm_id == 'Ike-2008', day == 13)
map <- ggmap::get_map(ike %>%
			dplyr::select(longitude, latitude) %>%
			dplyr::slice(1),
		      zoom = 6,
		      maptype = 'toner-background')
base_map <- ggmap::ggmap(map)

plot_radii_1 <- base_map +
  geom_hurricane(data = ike , ggplot2::aes(x = longitude, y = latitude,
					   r_ne = ne, r_se = se, r_nw = nw, r_sw = sw,
					   fill = wind_speed,
					   color = wind_speed)) +
  ggplot2::scale_color_manual(name = "Wind speed (kts)",
			      values = c("red", "orange", "yellow")) +
  ggplot2::scale_fill_manual(name = "Wind speed (kts)",
			     values = c("red", "orange", "yellow")) +
  ggplot2::ggtitle("Scale Radii = 1")

plot_radii_0.5 <- base_map +
  geom_hurricane(data = ike , ggplot2::aes(x = longitude, y = latitude,
					   r_ne = ne, r_se = se, r_nw = nw, r_sw = sw,
					   fill = wind_speed,
					   color = wind_speed),
		 scale_radii = 0.5) +
  ggplot2::scale_color_manual(name = "Wind speed (kts)",
			      values = c("red", "orange", "yellow")) +
  ggplot2::scale_fill_manual(name = "Wind speed (kts)",
			     values = c("red", "orange", "yellow")) +
  ggplot2::ggtitle("Scale Radii = 0.5")

both_plots <- ggpubr::ggarrange(plot_radii_1,
				plot_radii_0.5,
				ncol = 2,
				legend = 'right',
				common.legend = TRUE)

both_plots <- ggpubr::annotate_figure(both_plots,
				      top = text_grob('Hurricane Ike | September 13, 2008',
						      size = 12))

png('Ike_Plot.png', height = 5, width = 8, units = 'in', res = 300)
plot(both_plots)
dev.off()
