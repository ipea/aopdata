#' Support function to download metadata internally used in aopdata
#'
#' @description Downloads `metadata.csv` from the GitHub release or, if that
#'              fails, from the Ipea server, and caches it in `tempdir()` for
#'              the session. A file is cached only once it has been read
#'              successfully; a cached file that can't be read is downloaded
#'              again. A copy is also kept in the cache directory; when the
#'              metadata can't be downloaded, that copy is used for the rest
#'              of the session.
#'
#' @return A `data.table` with the metadata, or `NULL` (with a message) if it
#'         could not be downloaded.
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' df <- download_metadata()
#' }}
#'
download_metadata <- function(){

  # metadata cached in this session
  tempf <- file.path(tempdir(), "metadata_aopdata.csv")
  metadata <- read_metadata(tempf)
  if (!is.null(metadata)) { return(metadata) }

  if (!curl::has_internet()) {
    metadata <- use_cached_metadata(tempf)
    if (!is.null(metadata)) { return(metadata) }
    inform_failure("No internet connection.")
    return(invisible(NULL))
  }

  # partial file while downloading
  part <- paste0(tempf, ".part")
  on.exit(unlink(part[file.exists(part)]), add = TRUE)

  # try the GitHub release, then the Ipea server
  urls <- c(paste0('https://github.com/ipea/aopdata/releases/download/',
                   data_release, '/metadata.csv'),
            'https://www.ipea.gov.br/geobr/aopdata/metadata/metadata.csv')

  for (u in urls) {
    status <- aop_fetch(u, part)

    # the user interrupted the download
    if (identical(status, "aborted")) { return(invisible(NULL)) }

    # keep the file only if it can be read
    metadata <- if (identical(status, "ok")) read_metadata(part) else NULL
    if (!is.null(metadata)) {
      suppressWarnings(file.rename(part, tempf))
      save_cached_metadata(tempf)
      return(metadata)
    }
  }

  metadata <- use_cached_metadata(tempf)
  if (!is.null(metadata)) { return(metadata) }

  msg <- paste("Could not download the metadata from GitHub or the Ipea server.",
               "Please try again later.")
  inform_failure(msg)
  return(invisible(NULL))
}




#' Path of the copy of the metadata kept in the cache directory
#'
#' @return The path (the file may not exist).
#' @keywords internal
#'
cached_metadata_file <- function() {
  file.path(data_dir(), "metadata_aopdata.csv")
}




#' Keep a copy of the metadata in the cache directory
#'
#' @param tempf Path of the metadata cached in this session.
#'
#' @return `NULL`, invisibly. A failure to save the copy is ignored.
#' @keywords internal
#'
save_cached_metadata <- function(tempf) {
  dest <- cached_metadata_file()
  part <- paste0(dest, ".", Sys.getpid(), ".part")
  ok <- suppressWarnings(file.copy(tempf, part, overwrite = TRUE))
  if (isTRUE(ok)) { suppressWarnings(file.rename(part, dest)) }
  unlink(part)
  return(invisible(NULL))
}




#' Use the copy of the metadata kept in the cache directory
#'
#' @description Used when the metadata can't be downloaded. The copy is also
#'              saved as the metadata of this session, so later calls neither
#'              try to download it nor message again.
#'
#' @param tempf Path of the metadata cached in this session.
#'
#' @return A `data.table` with the metadata, or `NULL` if there is no valid
#'         copy.
#' @keywords internal
#'
use_cached_metadata <- function(tempf) {
  metadata <- read_metadata(cached_metadata_file())
  if (is.null(metadata)) { return(NULL) }

  suppressWarnings(file.copy(cached_metadata_file(), tempf, overwrite = TRUE))
  inform_cache(paste("Could not download the metadata; using the copy saved",
                     "in the cache. Only cached data can be read."))
  return(metadata)
}




#' Read and validate a metadata file
#'
#' @param path Path to a metadata csv file.
#'
#' @return A `data.table`, or `NULL` if the file is missing, can't be read,
#'         is empty or lacks the columns used by the package.
#' @keywords internal
#'
read_metadata <- function(path) {

  if (!file.exists(path) || isTRUE(file.size(path) == 0)) { return(NULL) }

  metadata <- tryCatch(
    suppressWarnings(data.table::fread(path, stringsAsFactors = FALSE)),
    error = function(e) NULL
  )

  needed <- c("type", "city", "year", "mode", "download_path2", "name_muni")
  if (is.null(metadata) || nrow(metadata) == 0 ||
      !all(needed %in% names(metadata))) {
    return(NULL)
  }

  return(metadata)
}
