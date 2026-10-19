# Download data to a temporary directory.

Downloads the requested files to a temporary directory (the session
cache) and reads them. Each file is downloaded from the Ipea server
first and, if that fails, from the GitHub release mirror.

## Usage

``` r
download_data(url, progress_bar)
```

## Arguments

- url:

  A string with the url address of aop dataset

- progress_bar:

  Logical. Whether to display a progress bar.

## Value

An `sf` or a `data.frame`, or `NULL` (with a message) if any file could
not be downloaded or read.
