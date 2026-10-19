#' Download spatial hexagonal grid H3
#'
#' @description
#' Results of the AOP project are spatially aggregated on a H3 spatial grid at
#' resolution 9, with a side of 174 meters and an area of 0.10 km2. More
#' information about H3 at \url{https://h3geo.org/docs/core-library/restable/}.
#' See the documentation 'Details' for the data dictionary.
#'
#' @template city
#' @template showProgress
#'
#' @return An `sf data.frame` object
#' @details
#' # Data dictionary:
#' |**Data type**|**column**|**Description**|
#' |-----|-----|-----|
#' | geographic	| `id_hex`	   | Unique id of hexagonal cell	|
#' | geographic	| `abbrev_muni`| Abbreviation of city name (3 letters)	|
#' | geographic	| `name_muni`  | City name	|
#' | geographic	| `code_muni`	 | 7-digit code of each city	| |
#'
#' # Cities available
#' |**City name**| **Three-letter abbreviation**|
#' |-----|-----|
#' | Belem | `bel` |
#' | Belo Horizonte | `bho` |
#' | Brasilia  | `bsb`|
#' | Campinas  | `cam` |
#' | Campo Grande | `cgr` |
#' | Curitiba | `cur`|
#' | Duque de Caxias | `duq` |
#' | Fortaleza | `for`|
#' | Goiania  | `goi` |
#' | Guarulhos  | `gua`|
#' | Maceio  | `mac`|
#' | Manaus  | `man`|
#' | Natal  | `nat`|
#' | Porto Alegre | `poa`|
#' | Recife | `rec` |
#' | Rio de Janeiro  | `rio`|
#' | Salvador  | `sal`|
#' | Sao Goncalo  | `sgo`|
#' | Sao Luis  | `slz`|
#' | Sao Paulo  | `spo`|
#'
#' @export
#' @family spatial data functions
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read spatial grid of a single city
#' nat <- read_grid(city = 'Natal', showProgress = FALSE)
#'
#' # Read spatial grid of all cities in the project
#' # all <- read_grid(city = 'all', showProgress = FALSE)
#'

read_grid <- function(city = NULL,
                      showProgress = FALSE){

  # checks
  abort_if_invalid(checkmate::check_flag(showProgress), "showProgress")

  # Get metadata with data url addresses
  temp_meta <- select_metadata(t="grid", c=city)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path2)

  # download files
  aop_sf <- download_data(url = file_url, progress_bar = showProgress)

  # check if download failed
  if (is.null(aop_sf)) { return(invisible(NULL)) }

  return(aop_sf)
}
