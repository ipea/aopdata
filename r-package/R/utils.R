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

  checkmate::assert_numeric(year, finite = TRUE, any.missing = FALSE)

  years_available <- paste(unique(temp_meta$year),collapse = " ")

  # valid input
  if (year %in% temp_meta$year) {
    temp_meta <- temp_meta[ temp_meta$year %in% year, ]
    return(temp_meta)
    }

  # invalid input
    cli::cli_abort(
      message = "Data currently available only for the years {years_available}.",
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

  checkmate::assert_string(mode, null.ok = FALSE)

  # Valid input
  if (mode %in% temp_meta$mode) {
    message(paste0("Using mode ", mode))
    temp_meta <- temp_meta[ temp_meta$mode %in% mode, ]
    return(temp_meta)
    }

  # invalid input
  error_msg <- paste0("Error: This 'mode' is not available for this 'city' & 'year'. Please try another 'year' or one of the following modes: ",
                      paste(unique(temp_meta$mode), collapse = " "))
  # invalid input
  cli::cli_abort(
    message = error_msg,
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
#' @description Save requested data (either an `sf` or a `data.frame`)
#'              to a temporary directory.
#'
#' @param url A string with the url address of aop dataset
#' @param progress_bar Logical. Defaults to (TRUE) display progress bar
#'
#' @return No visible output. The downloaded file (either an `sf` or a
#'         `data.frame`) is saved to a temporary directory.
#' @keywords internal
#'
download_data <- function(url, progress_bar = showProgress){

  # check showProgress input
  if (!(progress_bar %in% c(TRUE, FALSE))) {
    cli::cli_abort("Value to argument 'showProgress' has to be either TRUE or FALSE")
    }

  # get backup links
  filenames <- basename(url)
  url2 <- paste0('https://github.com/ipea/aopdata/releases/download/v1.0.0/', filenames)

  # test connection with server1
  try( silent = TRUE, check_con <- check_connection(url[1], silent = TRUE))

  # if server1 fails, replace url and test connection with server2
  if (is.null(check_con) | isFALSE(check_con)) {
      url <- url2
      try( silent = TRUE, check_con <- check_connection(url[1], silent = TRUE))
      if (is.null(check_con) | isFALSE(check_con)) { return(invisible(NULL)) }
  }

  # dest files
  temps <- paste0(tempdir(),"/", unlist(lapply(strsplit(url,"/"),tail,n=1L)))

  # download files
  try(silent = TRUE,
      downloaded_files <- curl::multi_download(
        urls = url,
        destfiles = temps,
        progress = progress_bar,
        resume = TRUE
      )
  )

  # if anything fails, return NULL
  if (any(!downloaded_files$success | is.na(downloaded_files$success))) {
    msg <- "File cached locally seems to be corrupted. Please download it again."
    cli::cli_alert_danger(msg)
    return(invisible(NULL))
  }

  # load data
  temp_data <- load_data(temps)
  return(temp_data)

}



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
    cli::cli_alert_danger(msg)
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
      cli::cli_alert_danger("No internet connection.")
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
      cli::cli_alert_danger(msg)
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
      cli::cli_alert_danger(msg)
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
    cli::cli_alert_danger("No internet connection.")
    return(invisible(NULL))
    }
}

