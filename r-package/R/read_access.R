#' Download accessibility estimates with population and land use data
#'
#' @description
#' Download estimates of access to employment, health, education and social
#' assistance services by transport mode and time of the day for the cities
#' included in the AOP project. See the documentation 'Details' for the data
#' dictionary. The data set reports information for each hexagon in a H3 spatial
#' grid at resolution 9, with a side of 174 meters and an area of 0.10 km2. More
#' information about H3 at \url{https://h3geo.org/docs/core-library/restable/}.
#'
#' @template city
#' @param mode Character. A transport mode: `'walk'` (the default),
#'             `'bicycle'`, `'public_transport'` or `'car'`. See 'Cities
#'             available' for the years and cities of each mode.
#' @param peak Logical. If `TRUE` (the default), returns accessibility estimates
#'             during peak time, between 6am and 8am. If `FALSE`, returns
#'             accessibility during off-peak, between 2pm and 4pm. Only used
#'             for `car` and `public_transport`. Walking and cycling
#'             accessibility does not vary by time of day, so for these modes
#'             `peak` is ignored and the `peak` column is always 1.
#' @template year
#' @template geometry
#' @template showProgress
#'
#' @return A `data.table`, or an `sf` object (which also inherits from
#'         `data.table`) when `geometry = TRUE`.
#'
#' @details
#' The output also includes the land use and population columns returned
#' by [read_landuse()]; see its documentation or [aopdata_dictionary()].
#'
#' # Data dictionary:
#' |  **data_type**  |  **column** |   **description** |**values**|
#' |-----------------|-------------|-------------------|----------|
#' | temporal	       | year        | Year of reference | |
#' | transport	     | mode        | Transport mode | walk; bicycle; public_transport; car |
#' | transport	     | peak        | Peak and off-peak | 1 (peak); 0 (off-peak) |
#'
#' The name of the columns with accessibility estimates are the junction of
#' three components: 1) Type of accessibility indicator 2) Type of opportunity /
#' population 3) Time threshold
#'
#'### 1) Type of accessibility indicator
#'
#' |**Indicator**| **Description**                          | **Observation** |
#' |-------------|------------------------------------------|-----------------|
#' | CMA	       | Cumulative opportunity measure (active)  | |
#' | CMP	       | Cumulative opportunity measure (passive) | |
#' | TMI         | Travel time to closest opportunity       | Value = Inf when no opportunity is reachable within the maximum travel time considered in the routing |
#'
#'
#'### 2) Type of opportunity / population
#' |**Type of opportunity**|**Description**|**Observation: available in combination with**|
#' |-----------------------|---------------|----------------------------------------------|
#' | TT	| All jobs | CMA indicator |
#' | TB	| Jobs with primary education | CMA indicator |
#' | TM	| Jobs with secondary education | CMA indicator |
#' | TA	| Jobs with tertiary education | CMA indicator |
#' | ST	| All healthcare facilities | CMA and TMI indicators |
#' | SB	| Healthcare facilities - Low complexity | CMA and TMI indicators |
#' | SM	| Healthcare facilities - Medium complexity | CMA and TMI indicators |
#' | SA	| Healthcare facilities - High complexity | CMA and TMI indicators |
#' | ET	| All public schools | CMA and TMI indicators |
#' | EI	| Public schools - early childhood | CMA and TMI indicators |
#' | EF	| Public schools - elementary schools | CMA and TMI indicators |
#' | EM	| Public schools - high schools | CMA and TMI indicators |
#' | MT	| All school enrollments | CMA indicator |
#' | MI	| School enrollments - early childhood | CMA indicator |
#' | MF	| School enrollments - elementary schools | CMA indicator |
#' | MM	| School enrollments - high schools | CMA indicator |
#' | CT	| All Social Assistance Reference Centers (CRAS) | CMA and TMI indicators |
#'
#' |**People**|**Description**|**Observation: available in combination with**|
#' |----------|---------------|----------------------------------------------|
#' | PT      |	All population | CMP indicator |
#' | PH      |	Men | CMP indicator |
#' | PM      |	Women | CMP indicator |
#' | PB      |	White population | CMP indicator |
#' | PA      |	Asian-descendent population | CMP indicator |
#' | PI      |	Indigenous population | CMP indicator |
#' | PN      |	Black population | CMP indicator |
#' | P0005I  |	Population between 0 and 5 years old | CMP indicator |
#' | P0614I  |	Population between 6 and 14 years old | CMP indicator |
#' | P1518I  |	Population between 15 and 18 years old | CMP indicator |
#' | P1924I  |	Population between 19 and 24 years old | CMP indicator |
#' | P2539I  |	Population between 25 and 39 years old | CMP indicator |
#' | P4069I  |	Population between 40 and 69 years old | CMP indicator |
#' | P70I    |	Population with 70 years old or more | CMP indicator |
#'
#'
#' ### 3) Time threshold (only applicable to CMA and CMP estimates)
#' |**Time threshold**|**Description	**|**Observation: only applicable to**|
#' |------------------|-----------------|-----------------------------------|
#' | 15	  | Opportunities accessible within 15 min.  | All transport modes      |
#' | 30	  | Opportunities accessible within 30 min.  | All transport modes      |
#' | 45	  | Opportunities accessible within 45 min.  | Active transport modes   |
#' | 60	  | Opportunities accessible within 60 min.  | All transport modes      |
#' | 90	  | Opportunities accessible within 90 min.  | Public transport and car |
#' | 120	| Opportunities accessible within 120 min. | Public transport and car |
#'
#'
#'## 4) Cities available
#' Walking and cycling: all cities, 2017 to 2019. Car: all cities, 2019.
#' Public transport: `bho`, `cam`, `cur`, `for`, `poa`, `spo` (2017 to
#' 2019); `rio` (2018 and 2019); `goi`, `rec` (2019).
#'
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
#' @family accessibility data functions
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' # Read accessibility estimates of a single city
#' df <- read_access(
#'   city = 'Fortaleza',
#'   mode = 'public_transport',
#'   year = 2019,
#'   showProgress = FALSE
#' )
#'
#' # Read accessibility estimates for all cities
#' all <- read_access(
#'   city = 'all',
#'   mode = 'walk',
#'   year = 2019,
#'   showProgress = FALSE
#' )
#'
read_access <- function(city = NULL,
                        mode = 'walk',
                        peak = TRUE,
                        year = 2019,
                        geometry = FALSE,
                        showProgress = TRUE){

  # checks
  abort_if_invalid(checkmate::check_flag(peak), "peak")
  abort_if_invalid(checkmate::check_flag(geometry), "geometry")
  abort_if_invalid(checkmate::check_flag(showProgress), "showProgress")

  # Get metadata with data url addresses
  temp_meta <- select_metadata(t='access',
                               c=city,
                               y=year,
                               m=mode)

  # check if download failed
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # cities of the request that have this mode (codes)
  city <- unique(temp_meta$city)

  if (isTRUE(showProgress)) {
    cli::cli_inform("Downloading accessibility data for the year {year}")
  }


  # list paths of files to download
  file_url <- as.character(temp_meta$download_path2)

  # download files
  aop_access <- download_data(url = file_url, progress_bar = showProgress)

  # check if download failed
  if (is.null(aop_access)) { return(invisible(NULL)) }

  # peak Vs off-peak
  if (isFALSE(peak) && mode %in% c('car', 'public_transport')) {
                  aop_access <- subset(aop_access, peak == 0)
                } else {
                  aop_access <- subset(aop_access, peak == 1)
                }

 # Download and merge land use data
  aop_landuse <- read_landuse(city=city, year=year, showProgress=showProgress)

  # check if download failed
  if (is.null(aop_landuse)) { return(invisible(NULL)) }

  # merge
  aop <- aop_merge(aop_landuse, aop_access)

  # with Vs without spatial data
  if (geometry == FALSE) {
      # return df
      return(aop)

    } else {
      # return sf
      aop_grid <- read_grid(city = city, showProgress = showProgress)

      # check if download failed
      if (is.null(aop_grid)) { return(invisible(NULL)) }

      aop_sf <- aop_spatial_join(aop, aop_grid)
      return(aop_sf)
    }
  }
