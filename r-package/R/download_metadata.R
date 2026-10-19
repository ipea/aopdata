#' Support function to download metadata internally used in aopdata
#'
#' @description Downloads `metadata.csv` from the GitHub release or, if that
#'              fails, from the Ipea server, and caches it in `tempdir()` for
#'              the session. A file is cached only once it has been read
#'              successfully; a cached file that can't be read is downloaded
#'              again.
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
    inform_failure("No internet connection.")
    return(invisible(NULL))
  }

  # partial file while downloading
  part <- paste0(tempf, ".part")
  on.exit(unlink(part[file.exists(part)]), add = TRUE)

  # try the GitHub release, then the Ipea server
  urls <- c('https://github.com/ipea/aopdata/releases/download/v1.0.0/metadata.csv',
            'https://www.ipea.gov.br/geobr/aopdata/metadata/metadata.csv')

  for (u in urls) {
    status <- aop_fetch(u, part)

    # the user interrupted the download
    if (identical(status, "aborted")) { return(invisible(NULL)) }

    # keep the file only if it can be read
    metadata <- if (identical(status, "ok")) read_metadata(part) else NULL
    if (!is.null(metadata)) {
      suppressWarnings(file.rename(part, tempf))
      return(metadata)
    }
  }

  msg <- paste("Could not download the metadata from GitHub or the Ipea server.",
               "Please try again later.")
  inform_failure(msg)
  return(invisible(NULL))
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
