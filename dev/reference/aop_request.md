# Build a download request

Build a download request

## Usage

``` r
aop_request(url)
```

## Arguments

- url:

  A string with the url address of a file.

## Value

An `httr2_request`. curl's 10 s connect timeout is kept, a transfer
slower than 1 kB/s for 30 s is aborted, and nothing is retried
automatically (the mirror is the retry).
