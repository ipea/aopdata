# Download files in parallel

The only function in the package that downloads data files.

## Usage

``` r
aop_fetch(urls, paths, progress = FALSE, label = "Downloading files")
```

## Arguments

- urls:

  Character. Urls of the files.

- paths:

  Character. Where to save each file.

- progress:

  Logical. Show a progress bar: of downloaded data when there is a
  single file, of the number of files otherwise.

- label:

  Character. Name of the progress bar of files.

## Value

A character vector with one status per file (see
[`classify_resp()`](https://ipea.github.io/aopdata/reference/classify_resp.md)).
