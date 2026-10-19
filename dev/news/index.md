# Changelog

## aopdata (development version)

**Major changes**

- Data files are now downloaded with {httr2}. If a file can’t be
  downloaded from the Ipea server, that file is downloaded from the
  GitHub mirror, so a single unavailable file or server no longer makes
  the whole request fail. When several files are downloaded at once, the
  progress bar counts files; when only one file is downloaded, it shows
  the amount of data downloaded.
- aopdata now requires R \>= 4.1.0 (a requirement of {httr2}).

**Bug fixes**

- HTTP errors (e.g. 404 pages) are no longer saved and read as data.
- Interrupted or corrupted downloads are no longer reused from the
  session cache: files are saved only once they are complete, and a
  cached file that can’t be read is removed.
- Downloads that stall are now stopped instead of hanging the R session.
- The metadata file is now downloaded with the same downloader as the
  data files (GitHub release first, Ipea server as fallback), and cached
  only once it has been read successfully. A broken cached metadata file
  is downloaded again instead of making every later call in the session
  fail.
- When a download fails, the user now sees one message that says what
  failed. Previously the functions could print “No internet connection.”
  up to three times, even when only one file was unavailable.

**Minor changes**

- City codes and names can now be mixed, in any capitalisation and with
  or without accents, in every function
  (e.g. `city = c('nat', 'São Paulo')`). Previously a mix returned
  `NULL` or a misleading error, and only
  [`read_access()`](https://ipea.github.io/aopdata/dev/reference/read_access.md)
  accepted upper-case city codes and `'ALL'`.
- Invalid inputs now give a clear error before any data is downloaded:
  `city` missing, `NULL`, `NA` or not text; an unknown city (the error
  names it and lists the valid codes and names); and a `mode` that a
  requested city doesn’t have (the error names the city and lists the
  cities with that mode).
- `peak`, `geometry` and `showProgress` must be a single `TRUE` or
  `FALSE`. `showProgress = 1`/`0` is no longer accepted, and `NA` or
  vectors give an error instead of a base R error. A vector `year` also
  gives a clear error; one year per call is supported.
- Which cities have public transport is now taken from the metadata
  instead of lists hard-coded in
  [`read_access()`](https://ipea.github.io/aopdata/dev/reference/read_access.md).
- [`aopdata_dictionary()`](https://ipea.github.io/aopdata/dev/reference/aopdata_dictionary.md)
  now only accepts `lang = "en"` or `"pt"`; values such as `"english"`
  were accepted before and silently did nothing.
- All messages and errors now use {cli}. Errors have the condition class
  `aopdata_error`, and messages about failed downloads have the class
  `aopdata_network`, so they can be caught with
  [`tryCatch()`](https://rdrr.io/r/base/conditions.html) or
  [`withCallingHandlers()`](https://rdrr.io/r/base/conditions.html).
  Download failure messages are now `rlang_message`s (previously
  `cliMessage`). The wording of the errors for invalid arguments, `mode`
  and `showProgress` changed, so match on the condition class rather
  than on the message text.
- The “Downloading … data” messages are now only shown when
  `showProgress = TRUE`. The “Using mode” message was removed.

## aopdata v1.1.2

CRAN release: 2026-01-09

**Minor changes**

- Messages and errors now use {cli}
- Avoid printing internet connection messages twice

**Bug fixes**

- Updated vignettes to avoid error in case of eventual internet
  connection issue.
- Now using the latest version of {rmarkdown}.

## aopdata v1.1.1

CRAN release: 2025-01-28

**Bug fixes**

- Download functions should now fail gracefully with an informative
  message when there are internet connection problems. Making sure to
  propagate the internet connection issue across function levels.

## aopdata v1.1.0

CRAN release: 2024-08-27

**Minor changes**

- Simplified internal functions
- Removed dependency on the {httr} package
- Now using
  [`curl::multi_download()`](https://jeroen.r-universe.dev/curl/reference/multi_download.html)
  to download files in parallel

## aopdata v1.0.3

CRAN release: 2023-08-31

**Bug fixes**

- Simplified internal functions
- Download functions should now fail gracefully with an informative
  message when there are internet connection problems. Using a more
  robust solution now that also accounts for timeout.

## aopdata v1.0.2

CRAN release: 2023-05-19

**Bug fixes**

- Fixed bug that printed message ‘connection fail’ in the 1st attempt,
  when it should only print in the 2nd attempt
- updated CITATION file with bibentry()

## aopdata v1.0.1

CRAN release: 2022-08-31

**Minor changes**

- Remove code redundancy from main read\_ and download function
- Do not throw connection error message in first check
- Improve error message when `mode = car`. Closes
  [\#52](https://github.com/ipea/aopdata/issues/52)
- Added citation file

**Bug fixes**

- Fixed bug that did not allow one to download access estimates by car
  in off-peak period. Closes
  [\#53](https://github.com/ipea/aopdata/issues/53)

## aopdata v1.0.0

CRAN release: 2022-08-12

**Major changes**

- New function
  [`aopdata_dictionary()`](https://ipea.github.io/aopdata/dev/reference/aopdata_dictionary.md)
  to open the aopdata data dictionary on a web browser.
- All data sets are now simultaneously stored on github and on Ipea’s
  server. The package now downloads the data from github. In case the
  github link is off line for some reason, then the package tries to
  download the data from Ipea’s server. For users, the effect of this
  change is that the package is much more stable and less vulnerable to
  instabilities in Ipea’s data server connection.
- New data sets:
  - Year coverage
    - Access and Land use data sets now cover years **2017, 2018 and
      2019**
  - New cities
    - Data for Goiania now covers the entire **metro area of Goiania**
      in 2019.
  - New modes
    - Access data now bring accessibility estimates by **car** in 2019
  - New activities
    - Land use and access data now bring data for **centers for social
      assistance (CRAS)**
    - Population data sets with minor spatial corrections to smooth
      spatial distributions

**Minor changes**

- `read_` functions now have no default value for the `city` parameter.
  [Closes](https://github.com/ipea/aopdata/issues/38)
  [\#38](https://github.com/ipea/aopdata/issues/38).
- Fixed `ERROR` message when there is no data for a particular transport
  mode for an specific city & year.

## aopdata v0.2.3

CRAN release: 2022-01-28

**Minor changes**

- Download functions should now fail gracefully with an informative
  message when there are internet connection problems.
- Remove `crul` from package dependencies.
- skip examples on CRAN. Examples now only run on interactive R
  sessions.
- update links from http to https

## aopdata v0.2.2

CRAN release: 2021-04-30

**Minor changes**

- Adds `crul` as a package dependency. Now aoptadata fails gracefully
  when there is internet connection problems. Closes
  [\#32](https://github.com/ipea/aopdata/issues/32).
- `showProgress` now sets to `FALSE` in all tests, examples and
  vignettes. Closes [\#32](https://github.com/ipea/aopdata/issues/32).
- skip tests on CRAN. Tests are run only locally

## aopdata v0.2.1

CRAN release: 2021-04-07

**Minor changes**

- Allow for user to download data few selected cities. Closes
  [\#29](https://github.com/ipea/aopdata/issues/29)
- Fix progress bar even when showProgress = F. Closes
  [\#30](https://github.com/ipea/aopdata/issues/30)
- Fix encoding issues using `base::iconv(city, to="ASCII//TRANSLIT")`.
  Closes [\#31](https://github.com/ipea/aopdata/issues/31)

## aopdata v0.2.0

CRAN release: 2021-03-31

**Major changes**

- New function read_population. Closes
  [\#21](https://github.com/ipea/aopdata/issues/21)
- New parameter `peak` added to
  [`read_access()`](https://ipea.github.io/aopdata/dev/reference/read_access.md)
  function. Closes [\#17](https://github.com/ipea/aopdata/issues/17)
- New internal support function `is_online()` to alert for possible
  internet connection problem. Closes
  [\#26](https://github.com/ipea/aopdata/issues/26)
- Cache downloaded data in tempdir. Closes
  [\#28](https://github.com/ipea/aopdata/issues/28)

**Minor changes**

- Downloads two or more cities at the same time. Closes
  [\#3](https://github.com/ipea/aopdata/issues/3).

## aopdata v0.1.0

CRAN release: 2021-03-08

- First version on CRAN
