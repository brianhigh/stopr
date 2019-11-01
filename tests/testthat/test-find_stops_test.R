library(readr)
test_that("find_stops works", {
  data_dir <- file.path("..", "..", "inst", "extdata")
  df <- read_csv(file.path(data_dir, "test_data.csv"))
  stops <- with(df, find_stops(latitude, longitude, datetime))
  stops_ref <- read_csv(file.path(data_dir, "stops.csv"))
  expect_equal(stops, stops_ref)
})
