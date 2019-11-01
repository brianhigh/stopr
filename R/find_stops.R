#' Find Stops
#'
#' Find stops made in a route given coordinates and timestamps from a GPS track.
#' @param x (data.frame) GPS dataset.
#' @param stop_min_duration_s (integer) Minimum stop duration cutoff in seconds. 
#'     (Must be greater than k. Default: 10)
#' @param digits (integer) Decimal places used for rounding. 
#'     (Must be 0 or greater. Default: 3)
#' @param k (integer) Window length for rolling median. 
#'     (Must be odd, 3 or greater. Default: 3)
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
#' object of class data.frame or inherits from class data.drame. It must 
#' include "latitude" (numeric), "longitude" (numeric) and "datetime" (datetime) 
#' variables. If the variables are present, they will be converted to the 
#' expected data types before stop detection is performed.
#' @examples
#' \dontrun{
#' library(readr)
#' df <- read_csv(system.file("extdata", "test_data.csv", package = "stopr"))
#' find_stops(df)
#' }
find_stops <- function(x, stop_min_duration_s = 10, digits = 3, k = 3) {
  # Define expected variables for data.frame 'x'.
  vars <- c('datetime', 'latitude', 'longitude')
  
  # Convert other parameters to expected data types.
  stop_min_duration_s <- as.integer(stop_min_duration_s)
  digits <- as.integer(digits)
  k <- as.integer(k)
  
  # Find stops in x if expected variables are present and parameters are valid.
  if ("data.frame" %in% class(x) & identical(vars, intersect(vars, names(x))) &
      stop_min_duration_s > k & digits >= 0 & k >= 3 & k %% 2 == 1) {
    x %>% dplyr::mutate(latitude = as.numeric(latitude),
                        longitude = as.numeric(longitude),
                        datetime = lubridate::as_datetime(datetime)) %>%
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
