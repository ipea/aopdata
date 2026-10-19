# Classify the result of one download

Classify the result of one download

## Usage

``` r
classify_resp(x)
```

## Arguments

- x:

  A response, an error condition, or `NULL` (request never ran).

## Value

One of `"ok"`, `"http_error"`, `"conn_error"` or `"aborted"`.
