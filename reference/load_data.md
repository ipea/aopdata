# Load data from tempdir to global environment

Reads data from tempdir to global environment.

## Usage

``` r
load_data(temps)
```

## Arguments

- temps:

  The paths of one or more data files stored in tempdir, all `.csv` or
  all `.gpkg`.

## Value

Returns either an `sf` or a `data.frame`, depending of the data set that
was downloaded
