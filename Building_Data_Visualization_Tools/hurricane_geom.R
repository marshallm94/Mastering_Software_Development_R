# NOTE(mmcquillen): General approach:
# 	- StatNEW --> GeomNew
# 		* New stat creates the actual data to be plotted
# 		  (hidden from user).
# 		* New geom simply plots the data.
# 	- create a function that creates a series of latitude and longitude
# 	  points (the new stat) then pass to geom_polygon() as sniff test
# 	  (this is roughly how it will work as the finished product).
# 	- the compute_group() function in the new stat should return a series
# 	  of latitude/longitude ponits.

# 	- geom_hurricane should work very similarly to geom_polygon.
# 	- check out geosphere::destPoint which should be used in the new stat
# 	  to create the points to be plotted (based on the lat, long & rad).
# 	- Variables from output of new stat will be the required_aes(inputs)
# 	  of the new geom.
# 	- When creating df in new stat using geosphere::destPoint, make sure
# 	  the longitude/latitude points are in the order ne, se, sw, nw.
# 	- Use GeomPolygon to build geom_hurricane. 
# 	- set 'geom = polygon' in the stat_hurricane function. 
# 	- geom_hurricane should inherit most of the properties of geom_polygon.
# 	  (check "Extending ggplot2" vignette - "inheriting from an existing
# 	  Geom") 	



library(ggplot2)
library(geosphere)

StatHurricane <- ggproto("StatHurricane", Stat,
			 compute_group = function(data, scales) {

			   lat_long <- data %>% select(longitude,
						       latitude)




			 },
                   default_aes = aes(<default values for certain aesthetics>),
                   required_aes = <a character vector of required aesthetics>)

# framework
GeomName <- ggproto("GeomName", Geom,
        required_aes = <a character vector of required aesthetics>,
        default_aes = aes(<default values for certain aesthetics>),
        draw_key = <a function used to draw the key in the legend>,
        draw_panel = function(data, panel_scales, coord) {
                ## Function that returns a grid grob that will 
                ## be plotted (this is where the real work occurs)
        }
)

# example object
library(grid)
GeomMyPoint <- ggproto("GeomMyPoint", Geom,
        required_aes = c("x", "y"),
        default_aes = aes(shape = 1),
        draw_key = draw_key_point,
        draw_panel = function(data, panel_scales, coord) {
                ## Transform the data first
                coords <- coord$transform(data, panel_scales)
                
                ## Construct a grid grob
                pointsGrob(
                        x = coords$x,
                        y = coords$y,
                        pch = coords$shape
                )
        })

# example function
geom_hurricane(aes(x = longitude, y = latitude,
		   r_ne = ne, r_se = se, r_nw = nw, r_sw = sw,
		   fill = wind_speed, color = wind_speed))

geom_hurricane <- function(mapping = NULL, data = NULL, stat = "identity",
                         position = "identity", na.rm = FALSE, 
                         show.legend = NA, inherit.aes = TRUE, ...) {
        ggplot2::layer(
                geom = GeomMyPoint, mapping = mapping,  
                data = data, stat = stat, position = position, 
                show.legend = show.legend, inherit.aes = inherit.aes,
                params = list(na.rm = na.rm, ...)
        )
}

