#' Download land use and population data
#'
#' @description
#' Download data on the spatial distribution of population, jobs, schools,
#' health care and social assistance facilities at a fine spatial resolution for
#' the cities included in the AOP project. See the documentation 'Details' for
#' the data dictionary. The data set reports information for each hexagon in a
#' H3 spatial grid at resolution 9, with a side of 174 meters and an area of
#' 0.10 km2. More information about H3 at \url{https://h3geo.org/docs/core-library/restable/}.
#'
#' @template city
#' @template year
#' @template geometry
#' @template showProgress
#'
#' @return A `data.table`, or an `sf` object (which also inherits from
#'         `data.table`) when `geometry = TRUE`.
#'
#' @details
#' # Data dictionary:
#' |  **data_type**   |  **column** |   **description** |**values**|
#' |------------------|-------------|-------------------|----------|
#' | temporal	        | year        | Year of reference | |
#' | geographic	      | id_hex      | Unique id of hexagonal cell | |
#' | geographic	      | abbrev_muni | Abbreviation of city name (3 letters) | |
#' | geographic	      | name_muni   | City name | |
#' | geographic	      | code_muni   | 7-digit code of each city | |
#' | sociodemographic | P001        | Total number of residents | |
#' | sociodemographic | P002        | Number of white residents | |
#' | sociodemographic | P003        | Number of black residents | |
#' | sociodemographic | P004        | Number of indigenous residents | |
#' | sociodemographic | P005        | Number of Asian-descendant residents | |
#' | sociodemographic | P006        | Number of men | |
#' | sociodemographic | P007        | Number of women | |
#' | sociodemographic | P010        | Number of people between 0 and 5 years old | |
#' | sociodemographic | P011        | Number of people between 6 and 14 years old | |
#' | sociodemographic | P012        | Number of people between 15 and 18 years old | |
#' | sociodemographic | P013        | Number of people between 19 and 24 years old | |
#' | sociodemographic | P014        | Number of people between 25 and 39 years old | |
#' | sociodemographic | P015        | Number of people between 40 and 69 years old | |
#' | sociodemographic | P016        | Number of people with 70 years old or more | |
#' | sociodemographic | R001        | Average household income per capita | R$ (Brazilian Reais), values in 2010 |
#' | sociodemographic | R002        | Income quintile group | 1 (poorest), 2, 3, 4, 5 (richest) |
#' | sociodemographic | R003        | Income decile group | 1 (poorest), 2, 3, 4, 5, 6, 7, 8, 9, 10 (richest) |
#' | land use	        | T001        | Total number of formal jobs | |
#' | land use	        | T002        | Number of formal jobs with primary education | |
#' | land use	        | T003        | Number of formal jobs with secondary education | |
#' | land use	        | T004        | Number of formal jobs with tertiary education | |
#' | land use	        | E001        | Total number of public schools | |
#' | land use	        | E002        | Number of public schools - early childhood | |
#' | land use	        | E003        | Number of public schools - elementary schools | |
#' | land use	        | E004        | Number of public schools - high schools | |
#' | land use	        | M001        | Total number of school enrollments | |
#' | land use	        | M002        | Number of school enrollments - early childhood | |
#' | land use	        | M003        | Number of school enrollments - elementary schools | |
#' | land use	        | M004        | Number of school enrollments  - high schools | |
#' | land use	        | S001        | Total number of healthcare facilities | |
#' | land use	        | S002        | Number of healthcare facilities - low complexity | |
#' | land use	        | S003        | Number of healthcare facilities - medium complexity | |
#' | land use	        | S004        | Number of healthcare facilities - high complexity | |
#' | land use	        | C001        | Total number of Social Assistance Reference Centers (CRAS) | |
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
#' @family land use data functions
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # a single city: pass the city name
#' bho <- read_landuse(
#'   city = 'Belo Horizonte',
#'   year = 2019,
#'   showProgress = FALSE
#'   )
#'
#' # ... or pass a three-letter abbreviation
#' bho <- read_landuse(
#'   city = 'bho',
#'   year = 2019,
#'   showProgress = FALSE
#'   )
#'
#' # all cities
#' all <- read_landuse(city = 'all', year = 2019)
#'
read_landuse <- function(city = NULL,
                         year = 2019,
                         geometry = FALSE,
                         showProgress = TRUE){

  # checks
  abort_if_invalid(checkmate::check_flag(geometry), "geometry")
  abort_if_invalid(checkmate::check_flag(showProgress), "showProgress")

  # Get metadata with data url addresses
  temp_meta <- select_metadata(t='land_use',
                               c=city,
                               y=year)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  if (isTRUE(showProgress)) {
    cli::cli_inform("Downloading land use data for the year {year}")
  }

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path2)

  # download files
  aop_landuse <- download_data(url = file_url, progress_bar = showProgress)

  # check if download failed
  if (is.null(aop_landuse)) { return(invisible(NULL)) }

  # Download and merge population data
  aop_population <- read_population(city=city, showProgress = showProgress)

    # check if download failed
    if (is.null(aop_population)) { return(invisible(NULL)) }

  # merge
  aop_population[, year := NULL]
  aop <- data.table::merge.data.table(aop_population, aop_landuse, by = c('id_hex', 'abbrev_muni', 'name_muni', 'code_muni'), all = TRUE)

  # with Vs without spatial data
  if (geometry == FALSE) {
    # return df
    return(aop)

  } else {
    # return sf
    aop_grid <- read_grid(city = city, showProgress = showProgress)

    # check if download failed
    if (is.null(aop_grid)) { return(invisible(NULL)) }

    # create function aop_join to bring in land use info
    aop_sf <- aop_spatial_join(aop, aop_grid)
    return(aop_sf)
  }
  }
