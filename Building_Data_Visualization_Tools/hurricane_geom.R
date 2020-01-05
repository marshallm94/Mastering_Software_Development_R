library(ggplot2)

StatNEW <- ggproto("StatNEW", Stat,
                   compute_group = <a function that does computations>,
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

