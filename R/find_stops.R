#' Find Stops
#'
#' Find stops made in a route given coordinates and timestamps from a GPS track.
#' @param .data (data.frame) GPS dataset.
#' @param stop_min_duration_s (integer) Minimum stop duration cutoff in seconds. 
#'     (Must be greater than k. Default: 10)
#' @param digits (integer) Decimal places used for rounding. 
#'     (Must be 0 or greater. Default: 3)
#' @param k (integer) Window length for rolling median. 
#'     (Must be odd, 3 or greater. Default: 3)
#' @param .vars (named character vector) The datetime, latitude, and longitude 
#'     variables to be found within \code{.data}. 
#'     (Default: \code{c(time = 'datetime', lat = 'latitude', lon = 'longitude')})
#' @return (tibble) The coordinates and timestamps of the identified stops, 
#'     along with the stop durations (integer), will be returned as a tibble.
#' @keywords GPS, stops
#' @section Details:
#' Stops are determined by finding sequential observations near the same location.
#' A rounded rolling median is used for latitude and longitude with \code{rle()}
#' to reduce noise. For this purpose, rounding is to \code{digits} decimal places.
#' The stop duration cutoff \code{stop_min_duration_s} is in seconds, assuming
#' one observation per second. Otherwise, consider this as the minimum number of
#' observations per stop.
#' 
#' The GPS dataset can be a data.frame, tibble, data.table, etc., or any other 
#' object of class data.frame or that inherits from class data.drame. It must 
#' include the variables named in ".vars" which are "datetime" (datetime), 
#' "latitude" (numeric), and "longitude" (numeric) by default. If the variables 
#' are present within ".data", they will be converted to the expected data types 
#' before stop detection is performed.
#' @examples
#' \dontrun{
#' library(readr)
#' df <- read_csv(system.file("extdata", "test_data.csv", package = "stopr"))
#' find_stops(df)
#' }
find_stops <- function(.data, stop_min_duration_s = 10, digits = 3, k = 3,
                       .vars = c(time = 'datetime', lat = 'latitude', 
                                 lon = 'longitude')) {
  # Define expected names in ".vars".
  .varnames <- c('time', 'lat', 'lon')
  
  # Convert other parameters to expected data types.
  stop_min_duration_s <- as.integer(stop_min_duration_s)
  digits <- as.integer(digits)
  k <- as.integer(k)
  
  # Find stops in x if expected variables are present and parameters are valid.
  if (is.data.frame(.data) & is.vector(.vars) & length(.vars) == 3 & 
      length(setdiff(.varnames, names(.vars))) == 0 & 
      length(setdiff(.vars, names(.data))) == 0 &
      stop_min_duration_s > k & digits >= 0 & k >= 3 & k %% 2 == 1) {
    .data %>% 
      dplyr::mutate(
        latitude = as.numeric(.data[[.vars[['lat']]]]),
        longitude = as.numeric(.data[[.vars[['lon']]]]),
        datetime = lubridate::as_datetime(.data[[.vars[['time']]]])) %>%
      dplyr::mutate_at(.vars = dplyr::vars(latitude, longitude),
            .funs = list(rnd = ~round(zoo::rollmedianr(., k, NA), digits))) %>%
      dplyr::mutate(loc = paste(latitude_rnd, longitude_rnd, sep = ',')) %>%
      dplyr::group_by(stopid = rle(loc)$lengths %>% rep(seq_along(.), .)) %>%
      dplyr::summarise(start = min(datetime), end = max(datetime),
                latitude = mean(latitude), longitude = mean(longitude)) %>%
      dplyr::mutate(duration = as.numeric(end - start)) %>%
      dplyr::filter(duration >= stop_min_duration_s) %>% 
      dplyr::select(-stopid) %>% 
      tidyr::drop_na()
  } else {
    stop("Input parameters are missing or invalid. See: ?stopr::find_stops")
  }
}
