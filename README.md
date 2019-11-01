# stopr

`stopr` is an R package providing stop detection functions for GPS track data. 

## Installation

You can install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("brianhigh/stopr")
```

## Functions

The function `find_stops()` will find stops on a route and return them as rows
of a `tibble`. The function uses the latitude, longitude, and timestamp 
variables from a GPS track dataset. Function options provide for control 
of operation, including a minimum stop duration cutoff and smoothing parameters.

## Example

This is a basic example which shows you how to use `find_stops()`:

``` r
library(readr)
library(stopr)
df <- read_csv(data_file)
stops <- with(df, find_stops(latitude, longitude, datetime,
                    stop_min_duration_s = 20, k = 5))
```

Where...

* The stop duration cutoff, `stop_min_duration_s`, was set to a minimum of 20 seconds.
* The window size, `k`, for the rolling median (smoothing) was set to 5 seconds.

## Applications

`stopr` output can be plotted on maps like the one below, showing stops 
in red, with the size of the point proportional to the duration of the stop.

![Track in orange with stops in red](images/test_data.jpg)
