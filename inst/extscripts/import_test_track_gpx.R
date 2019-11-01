# Import the test GPS track data in GPX format and save as CSV.
# Note: The GPX file was exported from Geo Tracker version 4.0.2.1750 (Android).

# Filename: import_test_track_gpx.R
# Copyright (c) Brian High
# License: MIT https://opensource.org/licenses/MIT (See LICENSE file.)
# Repository: https://github.com/brianhigh/stopr

# Load packages.
if (!suppressPackageStartupMessages(require(pacman))) {
  install.packages("pacman", repos = "http://cran.us.r-project.org")
}
pacman::p_load(tibble, plotKML, dplyr, lubridate, readr)

# Import GPX file.
df <- as_tibble(readGPX("test_data.gpx")$tracks[[1]][[1]]) %>% 
  select(-extensions, -ele) %>% 
  rename(longitude=lon, latitude=lat, datetime=time) %>% 
  mutate(datetime = as_datetime(datetime))

# Save as CSV.
write_csv(df, file.path("..", "extdata", "test_data.csv"))
