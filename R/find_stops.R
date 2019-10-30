#' Find Stops
#'
#' Find stops made in a route given coordinate and timestamps for a GPS track.
#' @param latitude (numeric) GPS Latitude.
#' @param longitude (numeric) GPS Longitude.
#' @param datetime (datetime) GPS Timestamp.
#' @param stop_min_duration_s (integer) Minimum stop duration cutoff in seconds.
#' @param digits (integer) Decimal places used for rounding.
#' @param k (integer) Window length for rolling median. (Must be odd.)
#' @keywords GPS, stops
#' @importFrom magrittr %>%
#' @export
#' @examples
#' find_stops(latitude, longitude, datetime)
find_stops <- function(latitude, longitude, datetime, stop_min_duration_s = 10,
                       digits = 3, k = 3) {
  tibble::tibble(latitude = as.numeric(latitude),
         longitude = as.numeric(longitude),
         datetime = lubridate::as_datetime(datetime)) %>%
    dplyr::mutate_at(.vars = vars(latitude, longitude),
            .funs = list(rnd = ~round(zoo::rollmedianr(., k, NA), digits))) %>%
    dplyr::mutate(loc = paste(latitude_rnd, longitude_rnd, sep = ',')) %>%
    dplyr::group_by(runid = rle(loc)$lengths %>% rep(seq_along(.), .)) %>%
    dplyr::summarise(start = min(datetime), end = max(datetime),
              latitude = mean(latitude), longitude = mean(longitude)) %>%
    dplyr::mutate(duration = as.numeric(end - start)) %>%
    dplyr::filter(duration >= stop_min_duration_s) %>%
    tidyr::drop_na()
}
