#' Read a CSV file into a tibble (tidyverse dataframe)
#'
#' This function reads a CSV file into R as a tibble.
#'
#' @param filename The aboslute or relative path to the filename to read into
#'    R (should be a CSV file) .
#' 
#' @return The CSV data in tibble (tidyverse version of data frames) format.
#' 
#' @importFrom readr read_csv
#' @importFrom dplyr tbl_df
#' 
#' @note If the file doesn't exist, a message will be displayed saying so.
#'
#' @examples
#' df <- fars_read("~/data/jason_bournes_data.csv")
#' df <- fars_read("C:\\Documents\\jack_bauers_data.csv")
#'
#' @export
fars_read <- function(filename) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}

#' Creates a descriptive filename based on the input year.
#'
#' @param year The year that you would like in the filename.
#' 
#' @return A character object that represents the filename for car fatality data.  
#'
#' @examples
#' filename_2018 <- make_filename(2018)
#' print(filename_2018)
#' [1] "accident_2018.csv.bz2"
#'
#' @export
make_filename <- function(year) {
        year <- as.integer(year)
        sprintf("accident_%d.csv.bz2", year)
}

#' Collects the MONTH and year associated with a fatal car incident for each year
#'    provided.
#'
#' @param years A vector of years which have an associated file in the current
#'    working directory.
#' 
#' @return A list of data frames, each with two columns; MONTH and year. Each
#' row in a data frame represent a fatal car accident in that month and year. 
#' 
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#' 
#' @note If one of the years specified doesn't have an associated file, and error
#'    will be thrown.
#' 
#' @examples
#' years <- fars_read_years(c(2013, 2014, 2015)) 
#' print(class(years))
#' [1] "list"
#' 
#' print(years)
#' [[1]]
#' # A tibble: 30,202 x 2
#'    MONTH  year
#'    <dbl> <dbl>
#'  1     1  2013
#'  2     1  2013
#'  3     1  2013
#'  4     1  2013
#'  5     1  2013
#'  6     1  2013
#'  7     1  2013
#'  8     1  2013
#'  9     1  2013
#' 10     1  2013
#' # … with 30,192 more rows
#' 
#' [[2]]
#' # A tibble: 30,056 x 2
#'    MONTH  year
#'    <dbl> <dbl>
#'  1     1  2014
#'  2     1  2014
#'  3     1  2014
#'  4     1  2014
#'  5     1  2014
#'  6     1  2014
#'  7     1  2014
#'  8     1  2014
#'  9     1  2014
#' 10     1  2014
#' # … with 30,046 more rows
#' 
#' [[3]]
#' # A tibble: 32,166 x 2
#'    MONTH  year
#'    <dbl> <dbl>
#'  1     1  2015
#'  2     1  2015
#'  3     1  2015
#'  4     1  2015
#'  5     1  2015
#'  6     1  2015
#'  7     1  2015
#'  8     1  2015
#'  9     1  2015
#' 10     1  2015
#' # … with 32,156 more rows
#' 
#' @export
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate(dat, year = year) %>% 
                                dplyr::select(MONTH, year)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}

#' Creates a table summarizing the count of fatal car incidents in a given month
#' and year combination.
#'
#' @param years a vector of years for which the number of fatal car incidents
#'     should be displayed, grouped by Month.
#' 
#' @return a data frame.
#' 
#' @importFrom dplyr bind_rows 
#' @importFrom dplyr group_by
#' @importFrom dplyr summarize 
#' @importFrom dplyr spread 
#' 
#' @note If one of the years specified doesn't have an associated file, and error
#'    will be thrown.
#' 
#' @examples
#' summary_df <- fars_summarize_years(c(2013, 2014, 2015)) 
#' # A tibble: 12 x 4
#'    MONTH `2013` `2014` `2015`
#'    <dbl>  <int>  <int>  <int>
#'  1     1   2230   2168   2368
#'  2     2   1952   1893   1968
#'  3     3   2356   2245   2385
#'  4     4   2300   2308   2430
#'  5     5   2532   2596   2847
#'  6     6   2692   2583   2765
#'  7     7   2660   2696   2998
#'  8     8   2899   2800   3016
#'  9     9   2741   2618   2865
#' 10    10   2768   2831   3019
#' 11    11   2615   2714   2724
#' 12    12   2457   2604   2781
#'
#' @export
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>% 
                dplyr::group_by(year, MONTH) %>% 
                dplyr::summarize(n = n()) %>%
                tidyr::spread(year, n)
}

#' Creates a geographical plot showing the accidents for a given year in a given
#'    state. Each accident is plotted as a single dot.
#'
#' @param state.num The state number which you would like displayed.
#' @inheritParams make_filename
#'
#' @return Displays a plot (no object returned).
#'
#' @importFrom maps map
#' @importFrom dplyr filter
#' @importFrom graphics points 
#'
#' @note If the state.num argument doesn't correspond to a state within the 
#'    specified data frame's STATE column, and error will be thrown.
#' @note If there are no accidents to plot for the specified state.num/year combination
#'   a message will display saying so. 
#' 
#' @examples
#' fars_map_state(42, 2015)
#' # plot of state 42 pops up with accidents plotted as dots
#'
#' @export
fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter(data, STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
