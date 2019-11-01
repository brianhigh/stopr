library(readr)
test_that("find_stops works", {
  data_dir <- file.path("..", "..", "inst", "extdata")
  df <- read_csv(file.path(data_dir, "test_data.csv"))
  stops <- with(df, find_stops(latitude, longitude, datetime, 
                               stop_min_duration_s = 20, k = 5, digits = 3))
  stops_ref <- read_csv(file.path(data_dir, "stops.csv"))
  # testthat::compare(stops, stops_ref)
  expect_equal(stops, stops_ref)
})
