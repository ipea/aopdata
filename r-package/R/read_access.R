#' Download accessibility estimates with population and land use data
#'
#' @description
#' Download estimates of access to employment, health, education and social
#' assistance services by transport mode and time of the day for the cities
#' included in the AOP project. See the documentation 'Details' for the data
#' dictionary. The data set reports information for each heaxgon in a H3 spatial
#' grid at resolution 9, with a side of 174 meters and an area of 0.10 km2. More
#' information about H3 at \url{https://h3geo.org/docs/core-library/restable/}.
#'
#' @template city
#' @param mode Character. A transport mode. Modes available include
#'             'public_transport', 'bicycle', or 'walk' (the default).
#' @param peak Logical. If `TRUE` (the default), returns accessibility estimates
#'             during peak time, between 6am and 8am. If `FALSE`, returns
#'             accessibility during off-peak, between 2pm and 4am. This argument
#'             only takes effect when `mode` is either `car` or `public_transport`.
#' @template year
#' @template geometry
#' @template showProgress
#'
#' @return A `data.frame` object
#'
#' @details
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
#' | TMI         | Travel time to closest opportunity       | Value = Inf when travel time is longer than 2h (public transport or car) or 1,5h (walking or bicycle) |
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
#' | MT	| All school enrollments | CMA and TMI indicators |
#' | MI	| School enrollments - early childhood | CMA and TMI indicators |
#' | MF	| School enrollments - elementary schools | CMA and TMI indicators |
#' | MM	| School enrollments - high schools | CMA and TMI indicators |
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
#' | PN      |	Back population | CMP indicator |
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
#' | 15	  | Opportunities accessible within 15 min.  | Active transport modes   |
#' | 30	  | Opportunities accessible within 30 min.  | All transport modes      |
#' | 45	  | Opportunities accessible within 45 min.  | Active transport modes   |
#' | 60	  | Opportunities accessible within 60 min.  | All transport modes      |
#' | 90	  | Opportunities accessible within 90 min.  | Public transport and car |
#' | 120	| Opportunities accessible within 120 min. | Public transport and car |
#'
#'
#'## 4) Cities available
#' |**City name**| **Three-letter abbreviation**|**Transport modes**|
#' |-----|-----|-----|
#' | Belem | `bel` | Active |
#' | Belo Horizonte | `bho` | All |
#' | Brasilia  | `bsb`| Active |
#' | Campinas  | `cam` | All |
#' | Campo Grande | `cgr` | Active |
#' | Curitiba | `cur`| Active |
#' | Duque de Caxias | `duq` | Active |
#' | Fortaleza | `for`| All |
#' | Goiania  | `goi` | All |
#' | Guarulhos  | `gua`| Active |
#' | Maceio  | `mac`| Active |
#' | Manaus  | `man`| Active |
#' | Natal  | `nat`| Active |
#' | Porto Alegre | `poa`| All |
#' | Recife | `rec` | All |
#' | Rio de Janeiro  | `rio`| All |
#' | Salvador  | `sal`| Active |
#' | Sao Goncalo  | `sgo`| Active |
#' | Sao Luis  | `slz`| Active |
#' | Sao Paulo  | `spo`| All |
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
  abort_if_invalid(checkmate::check_logical(peak), "peak")
  abort_if_invalid(checkmate::check_logical(geometry), "geometry")

  # remove accents
  city <- tolower(city)
  city <- base::iconv(city, to="ASCII//TRANSLIT")

  # all cities with public transport
  if(any(city=='all') & mode == 'public_transport' & year==2019){
    city <- c('for', 'rec', 'bho', 'rio', 'spo', 'cur', 'poa', 'goi', 'cam')
    }
  if(any(city=='all') & mode == 'public_transport' & year==2018){
    city <- c('for', 'bho', 'rio', 'spo', 'cur', 'poa', 'cam')
  }
  if(any(city=='all') & mode == 'public_transport' & year==2017){
    city <- c('for', 'bho', 'spo', 'cur', 'poa', 'cam')
    }

  # Get metadata with data url addresses
  temp_meta <- select_metadata(t='access',
                               c=city,
                               y=year,
                               m=mode)

  # check if download failed
  check_downloaded_obj(temp_meta) # nocov
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  if (isTRUE(showProgress)) {
    cli::cli_inform("Downloading accessibility data for the year {year}")
  }


  # cities with public transport
  if(year==2019){
  cities_with_pt <- c('for', 'rec', 'bho', 'rio', 'spo', 'cur', 'poa', 'goi', 'cam',
                           'fortaleza', 'recife', 'belo horizonte',
                           'rio de janeiro', 'sao paulo', 'curitiba',
                           'porto alegre', 'goiania', 'campinas')
  }
  if(year==2018){
  cities_with_pt <- c('for', 'bho', 'rio', 'spo', 'cur', 'poa', 'cam',
                           'fortaleza', 'belo horizonte', 'rio de janeiro',
                           'sao paulo', 'curitiba', 'porto alegre', 'campinas')
  }
  if(year==2017){
  cities_with_pt <- c('for', 'bho', 'spo', 'cur', 'poa', 'cam',
                           'fortaleza', 'belo horizonte', 'sao paulo',
                           'curitiba', 'porto alegre', 'campinas')}

  # check cities with public transport data
  cities_with_pt_check <- all(city %in% cities_with_pt )

  if (isFALSE(cities_with_pt_check) & mode == 'public_transport') {
    cities_available <- paste(cities_with_pt, collapse = ", ")
    error_msg <- "The only cities with public transport data in {year} are: {cities_available}."
    cli::cli_abort(error_msg, class = "aopdata_error")
    }

  if (any(city == 'all') & mode=='public_transport') {
    temp_meta <- subset(temp_meta, city %in% cities_with_pt)
  }

  # list paths of files to download
  file_url <- as.character(temp_meta$download_path2)

  # download files
  aop_access <- download_data(url = file_url, progress_bar = showProgress)

  # check if download failed
  check_downloaded_obj(aop_access) # nocov
  if (is.null(aop_access)) { return(invisible(NULL)) }

  # peak Vs off-peak
  if ((peak==FALSE & mode == 'car') |
      (peak==FALSE & mode == 'public_transport' & cities_with_pt_check)) {
                  aop_access <- subset(aop_access, peak == 0)
                } else {
                  aop_access <- subset(aop_access, peak == 1)
                }

 # Download and merge land use data
  aop_landuse <- read_landuse(city=city, year=year, showProgress=showProgress)

  # check if download failed
  check_downloaded_obj(aop_landuse) # nocov
  if (is.null(aop_landuse)) { return(invisible(NULL)) }

  # merge
  aop <- aop_merge(aop_landuse, aop_access)

  # with Vs without spatial data
  if (geometry == FALSE) {
      # return df
      return(aop)

    } else {
      # return sf
      aop_grid <- suppressMessages(
        read_grid(city = city, showProgress = showProgress)
      )

      # check if download failed
      check_downloaded_obj(aop_grid) # nocov
      if (is.null(aop_grid)) { return(invisible(NULL)) }

      aop_sf <- aop_spatial_join(aop, aop_grid)
      return(aop_sf)
    }
  }
