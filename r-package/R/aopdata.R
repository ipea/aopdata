#' aopdata: Data from the 'Access to Opportunities Project (AOP)'
#'
#' Download data from the 'Access to Opportunities Project (AOP)'. The aopdata
#' package brings annual estimates of access to employment, health, education
#' and social assistance services by transport mode, as well as data on the
#' spatial distribution of population, jobs, health care, schools and social
#' assistance facilities at a fine spatial resolution for all cities included in
#' the project. More info on the AOP website <https://www.ipea.gov.br/acessooportunidades/en/>.
#'
#' @section Usage:
#' Please check the vignettes on the [website](https://ipea.github.io/aopdata/).
#'
#' @docType package
#' @name aopdata
#' @aliases aopdata-package
#'
#' @importFrom data.table setDT :=
#' @importFrom utils globalVariables
#' @importFrom methods is
#' @keywords internal
"_PACKAGE"


## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1") utils::globalVariables(
  c('geometry', 'i.geom', 'id_hex', 'type', '.', ':='))

