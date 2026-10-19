#' Select city input
#'
#' @description Subsets the metadata table by 'city'.
#'
#' @param temp_meta A data.frame with the url addresses of aop datasets
#' @param city city input (passed from read_ function)
#'
#' @return A `data.frame` object with metadata subsetted by 'city'
#' @keywords internal
#'
select_city_input <- function(temp_meta=temp_meta, city=NULL){

  # cities available
  cities_available <- paste(unique(temp_meta$name_muni),collapse = " | ")
  error_msg <- "Data currently available only for the cities: {cities_available}."


  # NULL or numeric
  if( !is.character(city) | any(nchar(city)<3) ){
    cli::cli_abort(
      message = error_msg,
      class = "aopdata_error",
      call = rlang::caller_env()
    )
  }

  # 3 letter-abbreviation
  if (all(nchar(city)==3)) {

      # valid input 'all'
      if (any(city =='all')) { return(temp_meta) }

      # valid input
      if (all(city %in% temp_meta$city)) { temp_meta <- temp_meta[ temp_meta$city %in% city, ]
                                  return(temp_meta) }


      # invalid input
      else {
        cli::cli_abort(
          message = error_msg,
          class = "aopdata_error",
          call = rlang::caller_env()
        )
        }
    }


  # full name
  if (all(nchar(city)>3)) {

    city <- tolower(city)
    # remove accents
    city <- base::iconv(city, to="ASCII//TRANSLIT")

    # valid input
    if (all(city %in% temp_meta$name_muni)) { temp_meta <- temp_meta[ temp_meta$name_muni %in% city, ]
                                        return(temp_meta)
                                      }

    # invalid input
    else {
      cli::cli_abort(
        message = error_msg,
        class = "aopdata_error",
        call = rlang::caller_env()
      )
      }
  }
}




#' Select year input
#'
#' @description Subsets the metadata table by 'year'.
#'
#' @param temp_meta A data.frame with the url addresses of aop datasets
#' @param year Year of the dataset (passed from read_ function)
#'
#' @return A `data.frame` object with metadata subsetted by 'year'
#' @keywords internal
#'
select_year_input <- function(temp_meta=temp_meta, year=NULL){

  abort_if_invalid(
    checkmate::check_numeric(year, finite = TRUE, any.missing = FALSE),
    "year"
  )

  years_available <- paste(unique(temp_meta$year),collapse = " ")

  # valid input
  if (year %in% temp_meta$year) {
    temp_meta <- temp_meta[ temp_meta$year %in% year, ]
    return(temp_meta)
    }

  # invalid input
    cli::cli_abort(
      message = "Data currently available only for the years {years_available}.",
      class = "aopdata_error",
      call = rlang::caller_env()
    )

  }




#' Select mode input
#'
#' @description Subsets the metadata table by 'mode'.
#'
#' @param temp_meta A data.frame with the url addresses of aop datasets
#' @param mode Transport mode (passed by read_ function)
#'
#' @return A `data.frame` object with metadata subsetted by 'mode'
#' @keywords internal
#'
select_mode_input <- function(temp_meta=temp_meta, mode=NULL){

  abort_if_invalid(checkmate::check_string(mode, null.ok = FALSE), "mode")

  # Valid input
  if (mode %in% temp_meta$mode) {
    temp_meta <- temp_meta[ temp_meta$mode %in% mode, ]
    return(temp_meta)
    }

  # invalid input
  modes_available <- unique(temp_meta$mode)
  error_msg <- paste(
    "This {.arg mode} is not available for this {.arg city} and {.arg year}.",
    "Please try another {.arg year} or one of the following modes:",
    "{.val {modes_available}}."
  )
  # invalid input
  cli::cli_abort(
    message = error_msg,
    class = "aopdata_error",
    call = rlang::caller_env()
  )

}



#' Select metadata
#'
#' @description Subsets the metadata table by data 'type', 'city', 'year' and
#'              'mode'
#'
#' @param t Type of data: 'access' or 'grid' (passed from `read_` function)
#' @param c City (passed from `read_` function)
#' @param m Transport mode (passed from `read_` function)
#' @param y Year of the dataset (passed from `read_` function)
#'
#' @return A `data.frame` object with metadata subsetted by data type,
#'        'city', 'year' and 'mode'
#' @keywords internal
#'
select_metadata <- function(t=NULL, c=NULL, y=NULL, m=NULL){

# download metadata
  metadata <- as.data.frame(download_metadata())

  # check if download failed
  if (nrow(metadata)==0) { return(invisible(NULL)) }

  # Select data type
  temp_meta <- subset(metadata, type == t)

  # Select city input
  temp_meta <- select_city_input(temp_meta, city=c)

  # select year input
  if (t %in% c('access','land_use', 'population')) {
    temp_meta <- select_year_input(temp_meta, year=y)
  }

  # select mode input
  if (t=='access') {
    temp_meta <- select_mode_input(temp_meta, mode=m)
    }

  return(temp_meta)
}




#' Download data to a temporary directory.
#'
#' @description Downloads the requested files to a temporary directory (the
#'              session cache) and reads them. Each file is downloaded from
#'              the Ipea server first and, if that fails, from the GitHub
#'              release mirror.
#'
#' @param url A string with the url address of aop dataset
#' @param progress_bar Logical. Defaults to (TRUE) display progress bar
#'
#' @return An `sf` or a `data.frame`, or `NULL` (with a message) if any file
#'         could not be downloaded or read.
#' @keywords internal
#'
download_data <- function(url, progress_bar = showProgress){

  # check showProgress input
  if (!(progress_bar %in% c(TRUE, FALSE))) {
    cli::cli_abort(
      "{.arg showProgress} must be TRUE or FALSE.",
      class = "aopdata_error"
    )
    }

  # dest files in the session cache, and partial files while downloading
  dest <- file.path(tempdir(), basename(url))
  part <- paste0(dest, ".part")
  on.exit(unlink(part[file.exists(part)]), add = TRUE)

  # backup links
  mirror <- paste0('https://github.com/ipea/aopdata/releases/download/v1.0.0/',
                   basename(url))
  sources <- list(url, mirror)
  labels <- c("Downloading files", "Downloading files (mirror)")

  # files already downloaded in this session are not downloaded again
  status <- ifelse(file.exists(dest) & file.size(dest) > 0, "ok", "pending")

  # try the Ipea server, then the mirror for the files that failed
  for (k in seq_along(sources)) {
    pending <- status != "ok"
    if (!any(pending)) { break }

    status[pending] <- aop_fetch(sources[[k]][pending], part[pending],
                                 progress = progress_bar, label = labels[k])

    # the user interrupted the download
    if (any(status == "aborted")) { return(invisible(NULL)) }

    # move complete downloads into the cache
    done <- pending & status == "ok"
    moved <- suppressWarnings(file.rename(part[done], dest[done]))
    status[done] <- ifelse(moved, "ok", "http_error")
  }

  # if anything fails, return NULL
  if (any(status != "ok")) {
    msg <- paste("Could not download the data from the Ipea server or its",
                 "GitHub mirror. Please try again later.")
    inform_failure(msg)
    return(invisible(NULL))
  }

  # load data; a file that can't be read is removed from the cache
  temp_data <- tryCatch(suppressMessages(load_data(dest)),
                        error = function(e) NULL)

  if (is.null(temp_data)) {
    unlink(dest)
    inform_failure("The downloaded data could not be read. Please try again.")
    return(invisible(NULL))
  }

  return(temp_data)

}




#' Build a download request
#'
#' @param url A string with the url address of a file.
#'
#' @return An `httr2_request`. curl's 10 s connect timeout is kept, a
#'         transfer slower than 1 kB/s for 30 s is aborted, and nothing is
#'         retried automatically (the mirror is the retry).
#' @keywords internal
#'
aop_request <- function(url) {
  req <- httr2::request(url)
  req <- httr2::req_user_agent(req, "aopdata (https://github.com/ipea/aopdata)")
  req <- httr2::req_options(req, connecttimeout = 10,
                            low_speed_limit = 1024, low_speed_time = 30)

  # httr2 retries 429/503 responses in parallel mode without a limit
  req <- httr2::req_retry(req, max_tries = 1,
                          is_transient = function(resp) FALSE)
  return(req)
}




#' Classify the result of one download
#'
#' @param x A response, an error condition, or `NULL` (request never ran).
#'
#' @return One of `"ok"`, `"http_error"`, `"conn_error"` or `"aborted"`.
#' @keywords internal
#'
classify_resp <- function(x) {

  # the request never ran because the user interrupted the download
  if (is.null(x)) { return("aborted") }

  if (inherits(x, "httr2_response")) {
    status <- httr2::resp_status(x)
    if (status < 200 || status >= 300) { return("http_error") }

    # an HTML page served with status 200 is not data
    type <- tolower(httr2::resp_content_type(x))
    if (isTRUE(startsWith(type, "text/html"))) { return("http_error") }

    return("ok")
  }

  if (inherits(x, "httr2_http")) { return("http_error") }

  return("conn_error")
}




#' Download files in parallel
#'
#' @description The only function in the package that downloads data files.
#'
#' @param urls Character. Urls of the files.
#' @param paths Character. Where to save each file.
#' @param progress Logical. Show a progress bar.
#' @param label Character. Name of the progress bar.
#'
#' @return A character vector with one status per file (see `classify_resp()`).
#' @keywords internal
#'
aop_fetch <- function(urls, paths, progress = FALSE,
                      label = "Downloading files") { # nocov start

  if (!length(urls)) { return(character(0)) }

  reqs <- lapply(urls, aop_request)

  # after Ctrl+C, httr2 lets the active requests finish and says so
  # (not detected if cli.default_handler is set; then the mirror may be tried)
  interrupted <- FALSE
  resps <- tryCatch(
    withCallingHandlers(
      httr2::req_perform_parallel(
        reqs,
        paths = paths,
        on_error = "continue",
        progress = if (isTRUE(progress)) label else FALSE,
        max_active = min(length(reqs), 10)
      ),
      message = function(m) {
        if (grepl("Terminating iteration", conditionMessage(m), fixed = TRUE)) {
          interrupted <<- TRUE
        }
      }
    ),
    error = function(e) NULL
  )

  if (interrupted) { return(rep("aborted", length(urls))) }

  # an error in the download machinery itself (not the network)
  if (is.null(resps)) { return(rep("http_error", length(urls))) }

  return(vapply(resps, classify_resp, character(1)))
} # nocov end



#' Load data from tempdir to global environment
#'
#' @description Reads data from tempdir to global environment.
#'
#' @param temps The address of a data file stored in tempdir. Defaults to NULL
#'
#' @return Returns either an `sf` or a `data.frame`, depending of the data set
#'         that was downloaded
#' @keywords internal
#'
load_data <- function(temps=NULL){

  # check if .csv or geopackage
  if( temps[1] %like% '.csv' ){ fformat <- 'csv'}
  if( temps[1] %like% '.gpkg' ){ fformat <- 'gpkg'}

  ### one single file
  if (length(temps)==1) {

    # read file
    if( fformat=='csv' ){ temp <- data.table::fread(temps) }
    if( fformat=='gpkg' ){ temp <- sf::st_read(temps, quiet=T) }
  }

  ### multiple files
  else if (length(temps) > 1) {

    # csv
    if( fformat=='csv' ){
      files <- lapply(X=temps, FUN= data.table::fread)
      temp <- data.table::rbindlist(files, fill = TRUE)
    }
    # geopackage
    if( fformat=='gpkg' ){
      files <- lapply(X=temps, FUN= sf::st_read, quiet=T)
      temp <- sf::st_as_sf(data.table::rbindlist(files, fill = TRUE))
    }
  }

  # check if data was read Ok
  if (nrow(temp)==0) {
    msg <- "A file must have been corrupted during download. Please restart your R session and download the data again."
    inform_failure(msg)
    return(invisible(NULL))
  }

  return(temp)

  # load data to memory
  temp_data <- load_data(temps)
  return(temp_data)
}



#' Spatial join of AOP data
#'
#' @description Merges land use or access data with H3 grid geometries
#'
#' @param aop_df A `data.frame` of aop data
#' @param aop_sf A spatial `sf` of aop data
#'
#' @return Returns a `data.frame sf` with access/land use data and grid geometries
#' @keywords internal
#'
aop_spatial_join <- function(aop_df, aop_sf){

  data.table::setDT(aop_df)
  data.table::setDT(aop_sf)
  data.table::setkeyv(aop_df, c('id_hex', 'abbrev_muni', 'name_muni', 'code_muni'))

  # merge
    # slower # aop <- data.table::merge.data.table(aop_df, aop_sf, by = 'id_hex')
    aop_df[aop_sf, on = 'id_hex', geometry := i.geom]

  # back to sf
  aop <- sf::st_sf(aop_df)
  aop <- subset(aop, id_hex != 'a')

  return(aop)

  }




#' Merge land use and access data
#'
#' @description Merges landuse and access data
#'
#' @param aop_landuse A `data.table` of aop land use data
#' @param aop_access A `data.table` of aop access data
#'
#' @return Returns a `data.table` with landuse and access data
#' @keywords internal
#'
aop_merge <- function(aop_landuse, aop_access){

  data.table::setDT(aop_landuse)
  data.table::setDT(aop_access)
  data.table::setkeyv(aop_landuse, c("id_hex", "abbrev_muni", "name_muni", "code_muni", "year"))
  data.table::setkeyv(aop_access,  c("id_hex", "abbrev_muni", "name_muni", "code_muni", "year"))

  # merge
  aop <- data.table::merge.data.table(aop_landuse, aop_access,
                                      by = c("id_hex", "abbrev_muni", "name_muni", "code_muni", "year"), all = TRUE) #'name_muni', 'code_muni',

  return(aop)
}




#' Check internet connection with Ipea server
#'
#' @description
#' Checks if there is an internet connection with Ipea server.
#'
#' @param url A string with the url address of an aop dataset
#' @param silent Logical. Throw a message when silent is `FALSE` (default)
#'
#' @return Logical. `TRUE` if url is working, `FALSE` if not.
#'
#' @keywords internal
#'
check_connection <- function(url = 'https://www.ipea.gov.br/geobr/aopdata/metadata/metadata.csv',
                             silent = FALSE){ # nocov start
  # url <- 'https://google.com/'               # ok
  # url <- 'https://www.google.com:81/'   # timeout
  # url <- 'https://httpbin.org/status/300' # error

  # Check if user has internet connection
  if (!curl::has_internet()) {
    if (isFALSE(silent)) {
      inform_failure("No internet connection.")
    }
    return(FALSE)
  }

  # Message for connection issues
  msg <- "Problem connecting to data server. Please try again in a few minutes."

  # Test server connection using curl
  handle <- curl::new_handle(ssl_verifypeer = FALSE)
  response <- try(curl::curl_fetch_memory(url, handle = handle), silent = TRUE)

  # Check if there was an error during the fetch attempt
  if (inherits(response, "try-error")) {
    if (isFALSE(silent)) {
      inform_failure(msg)
    }
    return(FALSE)
  }

  # Check the status code
  status_code <- response$status_code

  # Link working fine
  if (status_code == 200L) {
    return(TRUE)
  }

  # Link not working or timeout
  if (status_code != 200L) {
    if (isFALSE(silent)) {
      inform_failure(msg)
    }
    return(FALSE)
  }
} # nocov end





#' Check if object has been downloaded/created in global environment
#'
#' @param obj Any type of object
#'
#' @return Returns `NULL` with an informative message
#' @keywords internal
#'
check_downloaded_obj <- function(obj){

  if (is.null(obj)) {
    inform_failure("No internet connection.")
    return(invisible(NULL))
    }
}




#' Throw an aopdata error when a checkmate check fails
#'
#' @param check Result of a `checkmate::check_*()` call: `TRUE` or a string.
#' @param arg Name of the argument being checked.
#' @param call Environment of the call shown in the error.
#'
#' @return `invisible(TRUE)`, or an error of class `aopdata_error`.
#' @keywords internal
#'
abort_if_invalid <- function(check, arg, call = rlang::caller_env()) {
  if (!isTRUE(check)) {
    cli::cli_abort(
      c("Invalid {.arg {arg}} argument.", "x" = "{check}"),
      class = "aopdata_error",
      call = call
    )
  }
  invisible(TRUE)
}




#' Inform the user that a download failed
#'
#' @param msg The message text.
#'
#' @return Signals a message of class `aopdata_network`.
#' @keywords internal
#'
inform_failure <- function(msg) {
  cli::cli_inform(c("x" = "{msg}"), class = "aopdata_network")
}
