#' aopdata data dictionary
#'
#' @description
#' Opens aopdata data dictionary on a web browser. This function requires
#' internet connection.
#'
#' @param lang Character. Language of data dictionary. It can be either `"en"`
#'        for English (default) or `"pt"` for Portuguese.
#'
#' @return  Opens aopdata data dictionary on a web browser
#'
#' @family Data dictionary
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#'
#' # Data dictionary in English
#' aopdata_dictionary(lang='en')
#'
#' # Data dictionary in Portuguese
#' aopdata_dictionary(lang='pt')
#'
#' @export
aopdata_dictionary <- function(lang='en'){

  # checks
  abort_if_invalid(
    checkmate::check_string(lang, pattern = 'en|pt', null.ok = FALSE),
    "lang"
  )

  # test server connection
  try( silent = TRUE,
       check_con <- check_connection('https://ipea.github.io/aopdata')
       )
  if(is.null(check_con) | isFALSE(check_con)){ return(invisible(NULL)) }

  if(lang=='en'){ utils::browseURL("https://ipea.github.io/aopdata/articles/data_dic_en.html") }
  if(lang=='pt'){ utils::browseURL("https://ipea.github.io/aopdata/articles/data_dic_pt.html") }

  return(invisible(NULL))
}
