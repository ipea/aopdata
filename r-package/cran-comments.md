── R CMD check results ─────────────────────────────────────────── aopdata 1.2.0 ────
Duration: 9m 0.1s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔


# aopdata v1.2.0

**Major changes**

- Data files are now downloaded with {httr2}. If a file can't be downloaded from the Ipea server, that file is downloaded from the GitHub mirror, so a single unavailable file or server no longer makes the whole request fail. When several files are downloaded at once, the progress bar counts files; when only one file is downloaded, it shows the amount of data downloaded.
- aopdata now requires R >= 4.1.0 (a requirement of {httr2}).

**Bug fixes**

- HTTP errors (e.g. 404 pages) are no longer saved and read as data.
- Interrupted or corrupted downloads are no longer reused from the session cache: files are saved only once they are complete, and a cached file that can't be read is removed.
- Downloads that stall are now stopped instead of hanging the R session.
- The metadata file is now downloaded with the same downloader as the data files (GitHub release first, Ipea server as fallback), and cached only once it has been read successfully. A broken cached metadata file is downloaded again instead of making every later call in the session fail.
- Grids (`geometry = TRUE` or `read_grid()`) of several cities now have a bounding box that covers all the cities, and are a plain `sf` data frame. Previously the bounding box covered only the first city, so maps of several cities could be cropped.
- When a download fails, the user now sees one message that says what failed. Previously the functions could print "No internet connection." up to three times, even when only one file was unavailable.

**Minor changes**

- Documentation corrected to match the data: the years and cities of each transport mode, the off-peak window, time thresholds, the TMI indicators, the defaults of `read_population(year)` and `read_grid(showProgress)`, and return types.
- Typos fixed in the documentation and vignettes; the package citation (`citation("aopdata")`) now lists the two Ipea discussion papers as technical reports, with their DOIs.
- City codes and names can now be mixed, in any capitalisation and with or without accents, in every function (e.g. `city = c('nat', 'São Paulo')`). Previously a mix returned `NULL` or a misleading error, and only `read_access()` accepted upper-case city codes and `'ALL'`.
- Invalid inputs now give a clear error before any data is downloaded: `city` missing, `NULL`, `NA` or not text; an unknown city (the error names it and lists the valid codes and names); and a `mode` that a requested city doesn't have (the error names the city and lists the cities with that mode).
- `peak`, `geometry` and `showProgress` must be a single `TRUE` or `FALSE`. `showProgress = 1`/`0` is no longer accepted, and `NA` or vectors give an error instead of a base R error. A vector `year` also gives a clear error; one year per call is supported.
- Which cities have public transport is now taken from the metadata instead of lists hard-coded in `read_access()`.
- `aopdata_dictionary()` now only accepts `lang = "en"` or `"pt"`; values such as `"english"` were accepted before and silently did nothing.
- All messages and errors now use {cli}. Errors have the condition class `aopdata_error`, and messages about failed downloads have the class `aopdata_network`, so they can be caught with `tryCatch()` or `withCallingHandlers()`. Download failure messages are now `rlang_message`s (previously `cliMessage`). The wording of the errors for invalid arguments, `mode` and `showProgress` changed, so match on the condition class rather than on the message text.
- The "Downloading ... data" messages are now only shown when `showProgress = TRUE`. The "Using mode" message was removed.
