#' Manage the aopdata cache
#'
#' @description
#' aopdata saves the files it downloads in a cache directory, so a file is
#' downloaded only once and is read from the cache in later R sessions.
#'
#' - `set_aopdata_cache_dir()` sets a custom location for the cache: the cache
#'   directory is an `aopdata` folder created inside `path` (or `path` itself,
#'   if it is already a folder named `aopdata`). The choice is
#'   saved and kept across R sessions. `path = NULL` goes back to the default
#'   cache directory, given by [tools::R_user_dir()].
#' - `get_aopdata_cache_dir()` returns the cache directory in use.
#' - `list_aopdata_cache()` lists the cached files.
#' - `delete_aopdata_cache()` deletes the cached files and the cache
#'   directory. Files in the cache directory that were not saved by aopdata
#'   are kept, and so is the directory then.
#'
#' @details
#' Files are saved in a subfolder named after the data release
#' (`aopdata_data_release_<tag>`), so a new data release never reads files
#' cached from a previous one. Files cached from previous data releases are
#' deleted the first time data is downloaded in a session. Set
#' `options(aopdata.keep_old_cache = TRUE)` to keep them, for example when two
#' versions of aopdata with different data releases share one cache.
#'
#' The cache is keyed on the data release of the installed package: a file is
#' not downloaded again while the package's data release stays the same.
#'
#' To use a cache directory only in the current session, without saving it,
#' set `options(aopdata.cache_dir = "<path>")`, e.g.
#' `options(aopdata.cache_dir = tempdir())`. As with `set_aopdata_cache_dir()`,
#' the cache directory is an `aopdata` folder inside that path. The option
#' takes precedence over `set_aopdata_cache_dir()`.
#'
#' A copy of the metadata of the data files is kept in the cache. When the
#' metadata can't be downloaded (e.g. offline), this copy is used for the rest
#' of the session, so cached data can still be read. A message of class
#' `aopdata_cache` says so.
#'
#' @param path A string with the path of a directory in which the cache
#'        directory (an `aopdata` folder) is created, or `NULL` to use the
#'        default cache directory.
#' @param verbose Logical. Whether to print a message. Defaults to `TRUE`.
#'
#' @return
#' - `set_aopdata_cache_dir()`: the path of the cache directory, invisibly.
#' - `get_aopdata_cache_dir()`: the path of the cache directory.
#' - `list_aopdata_cache()`: a character vector with the paths of the cached
#'   files.
#' - `delete_aopdata_cache()`: `TRUE`, invisibly.
#'
#' @name aopdata_cache
NULL




#' @rdname aopdata_cache
#' @export
#' @examplesIf interactive()
#' # use a custom cache directory, then go back to the previous setting
#' had_config <- file.exists(file.path(tools::R_user_dir("aopdata", "config"),
#'                                     "cache_dir"))
#' old <- get_aopdata_cache_dir()
#' set_aopdata_cache_dir(tempdir())
#' set_aopdata_cache_dir(if (had_config) old else NULL)
set_aopdata_cache_dir <- function(path, verbose = TRUE) {

  abort_if_invalid(checkmate::check_string(path, null.ok = TRUE,
                                           min.chars = 1), "path")
  abort_if_invalid(checkmate::check_flag(verbose), "verbose")

  config_file <- config_cache_file()

  # back to the default directory
  if (is.null(path)) {
    unlink(config_file)
    cache_dir <- default_cache_dir()
  } else {
    cache_dir <- cache_root(path)
    dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
    if (!dir.exists(cache_dir)) {
      cli::cli_abort(
        "Could not create the cache directory {.file {cache_dir}}.",
                     class = "aopdata_error")
    }
    dir.create(dirname(config_file), recursive = TRUE, showWarnings = FALSE)
    writeLines(cache_dir, config_file)
  }

  if (isTRUE(verbose)) {
    cli::cli_inform(
      c("i" = "aopdata files will be cached in {.file {cache_dir}}."),
                    class = "aopdata_cache")
  }

  return(invisible(cache_dir))
}




#' @rdname aopdata_cache
#' @export
#' @examples
#' get_aopdata_cache_dir()
get_aopdata_cache_dir <- function() {

  # session-only option first (a folder inside that path)
  path <- getOption("aopdata.cache_dir")
  if (is.character(path) && length(path) == 1 && !is.na(path) && nzchar(path)) {
    return(cache_root(path))
  }

  # then the saved setting, then the default
  config_file <- config_cache_file()
  cache_dir <- if (file.exists(config_file)) {
    tryCatch(readLines(config_file, n = 1, warn = FALSE),
             error = function(e) NULL)
  }
  if (length(cache_dir) != 1 || is.na(cache_dir) || !nzchar(cache_dir)) {
    return(default_cache_dir())
  }

  return(normalize_dir(cache_dir))
}




#' @rdname aopdata_cache
#' @export
#' @examples
#' list_aopdata_cache()
list_aopdata_cache <- function() {
  files <- list.files(get_aopdata_cache_dir(), recursive = TRUE,
                      full.names = TRUE)
  files[!grepl("[.]part$", files)]
}




#' @rdname aopdata_cache
#' @export
#' @examplesIf interactive()
#' # delete a cache directory used only in this session
#' old <- options(aopdata.cache_dir = tempdir())
#' delete_aopdata_cache()
#' options(old)
delete_aopdata_cache <- function(verbose = TRUE) {

  abort_if_invalid(checkmate::check_flag(verbose), "verbose")

  # only the folders aopdata creates, then the cache directory if nothing
  # else is left in it: an existing folder named 'aopdata' may hold the
  # user's own files
  cache_dir <- get_aopdata_cache_dir()
  unlink(release_dirs(), recursive = TRUE, force = TRUE)
  if (dir.exists(cache_dir) &&
      length(list.files(cache_dir, all.files = TRUE, no.. = TRUE)) == 0) {
    unlink(cache_dir, recursive = TRUE, force = TRUE)
  }

  if (isTRUE(verbose)) {
    cli::cli_inform(
      c("v" = "Deleted the aopdata files cached in {.file {cache_dir}}."),
                    class = "aopdata_cache")
  }

  return(invisible(TRUE))
}




#' Default cache directory
#'
#' @return The path of the default cache directory.
#' @keywords internal
default_cache_dir <- function() {
  normalize_dir(tools::R_user_dir("aopdata", which = "cache"))
}




#' Path of the file that stores a custom cache directory
#'
#' @return The path of the config file (it may not exist).
#' @keywords internal
config_cache_file <- function() {
  file.path(tools::R_user_dir("aopdata", which = "config"), "cache_dir")
}




#' Cache directory inside a path chosen by the user
#'
#' @param path A directory path.
#'
#' @return The absolute path of the `aopdata` folder inside `path`, or of
#'         `path` itself if it is already named `aopdata` (so the result of
#'         [get_aopdata_cache_dir()] can be passed back).
#' @keywords internal
cache_root <- function(path) {
  path <- normalize_dir(path)
  if (basename(path) == "aopdata") { return(path) }
  file.path(path, "aopdata")
}




#' Make a directory path absolute
#'
#' @param path A directory path.
#'
#' @return The absolute path, with forward slashes.
#' @keywords internal
normalize_dir <- function(path) {
  normalizePath(path.expand(path), winslash = "/", mustWork = FALSE)
}




#' Folders of data releases in the cache
#'
#' @return The paths of the `aopdata_data_release_*` folders in the cache
#'         directory.
#' @keywords internal
release_dirs <- function() {
  dirs <- list.files(get_aopdata_cache_dir(),
                     pattern = "^aopdata_data_release_",
                     full.names = TRUE)
  dirs[dir.exists(dirs)]
}




#' Folder of the current data release in the cache
#'
#' @description Deletes old data releases (once per session) and creates the
#'              folder of the current one if needed. Never errors: the caller
#'              checks that the folder exists.
#'
#' @return The path of the folder.
#' @keywords internal
data_dir <- function() {
  delete_old_releases()
  path <- file.path(get_aopdata_cache_dir(),
                    paste0("aopdata_data_release_", data_release))
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  return(path)
}




#' Delete files cached from previous data releases
#'
#' @description Runs once per session. Skipped when
#'              `options(aopdata.keep_old_cache = TRUE)`.
#'
#' @return The paths of the deleted folders, invisibly.
#' @keywords internal
delete_old_releases <- function() {

  if (isTRUE(aopdata_env$old_cache_checked) ||
      isTRUE(getOption("aopdata.keep_old_cache", FALSE))) {
    return(invisible(character(0)))
  }
  aopdata_env$old_cache_checked <- TRUE

  dirs <- release_dirs()
  old <- dirs[basename(dirs) != paste0("aopdata_data_release_", data_release)]
  if (length(old) == 0) { return(invisible(character(0))) }

  unlink(old, recursive = TRUE, force = TRUE)
  deleted <- old[!dir.exists(old)]

  if (length(deleted) > 0) {
    releases <- sub("^aopdata_data_release_", "", basename(deleted))
    inform_cache(paste0("Deleted the files cached from previous data releases ",
                        "of aopdata (", paste(releases, collapse = ", "), ")."))
  }

  return(invisible(deleted))
}
