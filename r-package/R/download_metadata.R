#' Support function to download metadata internally used in aopdata
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' df <- download_metadata()
#' }}
#'
download_metadata <- function(){ # nocov start

  # create tempfile to save metadata
  tempf <- file.path(tempdir(), "metadata_aopdata.csv")

  # IF metadata has already been successfully downloaded
  if (file.exists(tempf) & file.info(tempf)$size != 0) {

  } else {

    # test server connection with github
    metadata_link <- 'https://github.com/ipea/aopdata/releases/download/v1.0.0/metadata.csv'
    try( silent = TRUE,
         check_con <- check_connection(metadata_link, silent = TRUE)
         )

    # if connection with github fails, try connection with ipea
    if (is.null(check_con) | isFALSE(check_con)) {
      metadata_link <- 'https://www.ipea.gov.br/geobr/aopdata/metadata/metadata.csv'
      try( silent = TRUE,
           check_con <- check_connection(metadata_link, silent = FALSE)
           )

      if (is.null(check_con) | isFALSE(check_con)) { return(invisible(NULL)) }
      }

    # download metadata to temp file
    try( silent = TRUE,
         downloaded_files <- curl::multi_download(
           urls = metadata_link,
           destfiles = tempf,
           progress = FALSE,
           resume = TRUE

           )
         )

    # if anything fails, return NULL
    if (any(!downloaded_files$success | is.na(downloaded_files$success))) {
      msg <- "File cached locally seems to be corrupted. Please download it again."
      inform_failure(msg)
      return(invisible(NULL))
    }
  }

 # read metadata
  metadata <- data.table::fread(tempf, stringsAsFactors=FALSE)

  # check if data was read Ok
  if (nrow(metadata)==0) {
    msg <- "A file must have been corrupted during download. Please restart your R session and download the data again."
    inform_failure(msg)
    return(invisible(NULL))
  }

  return(metadata)

}  # nocov end
