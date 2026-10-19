# Select mode input

Subsets the metadata table by 'mode'.

## Usage

``` r
select_mode_input(
  temp_meta = temp_meta,
  mode = NULL,
  all_cities = FALSE,
  year_meta = temp_meta
)
```

## Arguments

- temp_meta:

  A data.frame with the url addresses of aop datasets

- mode:

  Transport mode (passed by read\_ function)

- all_cities:

  Logical. `TRUE` if the user asked for all cities.

- year_meta:

  The metadata of the selected type and year, before the city filter.
  Used to find the cities with this mode.

## Value

A `data.frame` object with metadata subsetted by 'mode'
