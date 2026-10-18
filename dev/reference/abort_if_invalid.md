# Throw an aopdata error when a checkmate check fails

Throw an aopdata error when a checkmate check fails

## Usage

``` r
abort_if_invalid(check, arg, call = rlang::caller_env())
```

## Arguments

- check:

  Result of a `checkmate::check_*()` call: `TRUE` or a string.

- arg:

  Name of the argument being checked.

- call:

  Environment of the call shown in the error.

## Value

`invisible(TRUE)`, or an error of class `aopdata_error`.
