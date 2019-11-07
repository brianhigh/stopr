library(readr)
test_that("find_stops works", {
  data_dir <- file.path("..", "..", "inst", "extdata")
  df <- read_csv(file.path(data_dir, "test_data.csv"))
  stops <- find_stops(df, stop_min_duration_s = 20, k = 5, digits = 3)
  stops_ref <- read_csv(file.path(data_dir, "stops.csv"))
  # testthat::compare(stops, stops_ref)
  expect_equal(stops, stops_ref)
})
library(tibble)
library(plotKML)
test_that("find_stops works with raw gpx file", {
  data_dir <- file.path("..", "..", "inst", "extdata")
  stops <- find_stops(
    as_tibble(readGPX(file.path(data_dir, "test_data.gpx"))$tracks[[1]][[1]]), 
    stop_min_duration_s = 20, k = 5, digits = 3, 
    .vars = c(lon = 'lon', lat = 'lat', time = 'time'))
  stops_ref <- read_csv(file.path(data_dir, "stops.csv"))
  # testthat::compare(stops, stops_ref)
  expect_equal(stops, stops_ref)
})