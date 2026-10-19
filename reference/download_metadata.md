# Support function to download metadata internally used in aopdata

Downloads `metadata.csv` from the GitHub release or, if that fails, from
the Ipea server, and caches it in
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) for the session. A
file is cached only once it has been read successfully; a cached file
that can't be read is downloaded again.

## Usage

``` r
download_metadata()
```

## Value

A `data.table` with the metadata, or `NULL` (with a message) if it could
not be downloaded.

## Examples

``` r
if (FALSE)  if (interactive()) {
df <- download_metadata()
} # \dontrun{}
```
