# Read and validate a metadata file

Read and validate a metadata file

## Usage

``` r
read_metadata(path)
```

## Arguments

- path:

  Path to a metadata csv file.

## Value

A `data.table`, or `NULL` if the file is missing, can't be read, is
empty or lacks the columns used by the package.
