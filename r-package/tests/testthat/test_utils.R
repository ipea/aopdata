context("utils")

# skip tests because they take too much time
testthat::skip_on_cran()




# ### download metadata ----------------
#
# testthat::test_that("gracefully fail if could not download metadata", {
#
#   # meta data
#   testthat::local_mocked_bindings(
#     check_connection = function(...) { FALSE }
#   )
#   testthat::expect_null( download_metadata() )
# })
#


### check connection ----------------
# url <- 'https://www.google.com:81/'   # timeout
# url <- 'https://httpbin.org/status/300' # error

testthat::test_that("check connection", {

  # timeout
  testthat::expect_false( check_connection(url = 'https://www.google.com:81/') )

  # connection error
  testthat::expect_false( check_connection(url = 'https://httpbin.org/status/300') )


})


### checkmate text with braces ----------------

testthat::test_that("abort_if_invalid handles braces in checkmate messages", {
  check <- checkmate::check_choice("x", c("{a}", "b"))
  testthat::expect_error(abort_if_invalid(check, "x"), class = "aopdata_error")
  testthat::expect_true(abort_if_invalid(TRUE, "x"))
})



### download_data (offline: aop_fetch is mocked) ----------------
# fixtures use fake basenames (aoptest_*) so they never mix with real cached data

write_fixture <- function(path) {
  data.table::fwrite(data.table::data.table(id_hex = c("a1", "a2"), x = 1:2), path)
}

testthat::test_that("download_data falls back to the mirror per file, keeping order", {
  calls <- list()
  testthat::local_mocked_bindings(
    aop_fetch = function(urls, paths, progress = FALSE, label = NULL) {
      calls[[length(calls) + 1]] <<- urls
      # file b fails on the Ipea server; everything works on the mirror
      ok <- grepl("github.com", urls) | !grepl("aoptest_b", urls)
      for (i in which(ok)) {
        id <- sub("^aoptest_(.)\\.csv$", "\\1", basename(urls[i]))
        data.table::fwrite(data.table::data.table(id_hex = id, x = id), paths[i])
      }
      ifelse(ok, "ok", "http_error")
    }
  )
  urls <- paste0("https://www.ipea.gov.br/x/aoptest_", c("a", "b", "c"), ".csv")
  dest <- file.path(tempdir(), basename(urls))
  on.exit(unlink(dest), add = TRUE)

  out <- download_data(urls, progress_bar = FALSE)
  testthat::expect_equal(out$x, c("a", "b", "c"))
  testthat::expect_length(calls, 2)
  testthat::expect_equal(
    calls[[2]],
    "https://github.com/ipea/aopdata/releases/download/v1.0.0/aoptest_b.csv"
  )
})

testthat::test_that("download_data returns NULL and cleans up when both servers fail", {
  testthat::local_mocked_bindings(
    aop_fetch = function(urls, paths, progress = FALSE, label = NULL) {
      for (p in paths) writeLines("partial", p)
      rep("conn_error", length(urls))
    }
  )
  url <- "https://www.ipea.gov.br/x/aoptest_bothfail.csv"
  dest <- file.path(tempdir(), basename(url))

  testthat::expect_message(
    out <- download_data(url, progress_bar = FALSE),
    class = "aopdata_network"
  )
  testthat::expect_null(out)
  testthat::expect_false(file.exists(dest))
  testthat::expect_false(file.exists(paste0(dest, ".part")))
})

testthat::test_that("download_data reuses a complete cached file", {
  testthat::local_mocked_bindings(
    aop_fetch = function(...) stop("aop_fetch should not be called")
  )
  url <- "https://www.ipea.gov.br/x/aoptest_cached.csv"
  dest <- file.path(tempdir(), basename(url))
  write_fixture(dest)
  on.exit(unlink(dest), add = TRUE)

  testthat::expect_s3_class(download_data(url, progress_bar = FALSE), "data.frame")
})

testthat::test_that("download_data stops without the mirror when interrupted", {
  calls <- 0
  testthat::local_mocked_bindings(
    aop_fetch = function(urls, paths, progress = FALSE, label = NULL) {
      calls <<- calls + 1
      rep("aborted", length(urls))
    }
  )
  url <- "https://www.ipea.gov.br/x/aoptest_abort.csv"

  testthat::expect_no_message(
    out <- download_data(url, progress_bar = FALSE),
    class = "aopdata_network"
  )
  testthat::expect_null(out)
  testthat::expect_equal(calls, 1)
})

testthat::test_that("download_data removes a cached file that can't be read", {
  testthat::local_mocked_bindings(
    aop_fetch = function(urls, paths, progress = FALSE, label = NULL) {
      for (p in paths) writeLines("not a geopackage", p)
      rep("ok", length(urls))
    }
  )
  url <- "https://www.ipea.gov.br/x/aoptest_bad.gpkg"
  dest <- file.path(tempdir(), basename(url))
  on.exit(unlink(dest), add = TRUE)

  testthat::expect_message(
    out <- download_data(url, progress_bar = FALSE),
    class = "aopdata_network"
  )
  testthat::expect_null(out)
  testthat::expect_false(file.exists(dest))
})

testthat::test_that("classify_resp classifies download results", {
  resp <- function(status, type = NULL) {
    headers <- if (is.null(type)) list() else list(`Content-Type` = type)
    httr2::response(status_code = status, headers = headers)
  }
  http_err <- structure(class = c("httr2_http_404", "httr2_http", "httr2_error",
                                  "rlang_error", "error", "condition"),
                        list(message = "404"))
  conn_err <- structure(class = c("httr2_failure", "httr2_error", "rlang_error",
                                  "error", "condition"),
                        list(message = "timeout"))

  testthat::expect_equal(classify_resp(resp(200, "text/csv")), "ok")
  testthat::expect_equal(classify_resp(resp(200)), "ok")
  testthat::expect_equal(classify_resp(resp(200, "text/html; charset=utf-8")), "http_error")
  testthat::expect_equal(classify_resp(resp(404, "text/plain")), "http_error")
  testthat::expect_equal(classify_resp(http_err), "http_error")
  testthat::expect_equal(classify_resp(conn_err), "conn_error")
  testthat::expect_equal(classify_resp(NULL), "aborted")
})


testthat::test_that("aop_request keeps the connect timeout and doesn't retry", {
  req <- aop_request("https://example.com/aoptest.csv")
  testthat::expect_s3_class(req, "httr2_request")
  testthat::expect_equal(req$options$connecttimeout, 10)
  testthat::expect_equal(req$options$low_speed_limit, 1024)

  # a busy server (503) fails once, so the mirror can be tried
  calls <- 0
  httr2::local_mocked_responses(function(req) {
    calls <<- calls + 1
    httr2::response(status_code = 503)
  })
  part <- file.path(tempdir(), "aoptest_503.csv.part")
  on.exit(unlink(part), add = TRUE)
  testthat::expect_equal(aop_fetch("https://example.com/aoptest_503.csv", part),
                         "http_error")
  testthat::expect_equal(calls, 1)
})

testthat::test_that("aop_fetch reports an interrupted download as aborted", {
  testthat::local_mocked_bindings(
    req_perform_parallel = function(reqs, ...) {
      cli::cli_alert_warning("Terminating iteration; returning 1 response.")
      lapply(reqs, function(r) httr2::response(status_code = 200))
    },
    .package = "httr2"
  )
  testthat::expect_equal(
    aop_fetch(c("https://example.com/a", "https://example.com/b"),
              file.path(tempdir(), c("aoptest_i1", "aoptest_i2"))),
    c("aborted", "aborted")
  )
})



### download_metadata (offline: aop_fetch is mocked) ----------------

# moves the session's cached metadata aside; restore() puts it back
stash_metadata_cache <- function() {
  tempf <- file.path(tempdir(), "metadata_aopdata.csv")
  backup <- tempfile(fileext = ".csv")
  had_cache <- file.exists(tempf)
  if (had_cache) file.rename(tempf, backup)
  restore <- function() {
    unlink(c(tempf, paste0(tempf, ".part")))
    if (had_cache) file.rename(backup, tempf)
  }
  list(path = tempf, restore = restore)
}

write_metadata_fixture <- function(path) {
  data.table::fwrite(
    data.table::data.table(type = "grid", city = "nat", year = NA, mode = NA,
                           download_path = "x", download_path2 = "y",
                           name_muni = "natal"),
    path
  )
}

testthat::test_that("download_metadata falls back to the Ipea server", {
  cache <- stash_metadata_cache()
  on.exit(cache$restore(), add = TRUE)
  tempf <- cache$path
  calls <- character()
  testthat::local_mocked_bindings(
    aop_fetch = function(urls, paths, ...) {
      calls <<- c(calls, urls)
      if (grepl("github.com", urls)) return("http_error")
      write_metadata_fixture(paths)
      "ok"
    }
  )
  testthat::expect_equal(count_network_msgs(meta <- download_metadata()), 0)
  testthat::expect_equal(meta$city, "nat")
  testthat::expect_length(calls, 2)
  testthat::expect_match(calls[2], "ipea.gov.br")
  testthat::expect_true(file.exists(tempf))
})

testthat::test_that("download_metadata replaces a cached file that can't be read", {
  cache <- stash_metadata_cache()
  on.exit(cache$restore(), add = TRUE)
  tempf <- cache$path
  writeLines("Not Found", tempf)
  testthat::local_mocked_bindings(
    aop_fetch = function(urls, paths, ...) { write_metadata_fixture(paths); "ok" }
  )
  testthat::expect_equal(download_metadata()$city, "nat")
  testthat::expect_equal(read_metadata(tempf)$city, "nat")
})

testthat::test_that("download_metadata reuses a valid cached file", {
  cache <- stash_metadata_cache()
  on.exit(cache$restore(), add = TRUE)
  tempf <- cache$path
  write_metadata_fixture(tempf)
  testthat::local_mocked_bindings(
    aop_fetch = function(...) stop("aop_fetch should not be called")
  )
  testthat::expect_equal(download_metadata()$city, "nat")
})

testthat::test_that("download_metadata fails gracefully, caching nothing", {
  cache <- stash_metadata_cache()
  on.exit(cache$restore(), add = TRUE)
  tempf <- cache$path
  testthat::local_mocked_bindings(
    aop_fetch = function(urls, paths, ...) {
      writeLines("<html>error page</html>", paths)
      "ok"
    }
  )
  testthat::expect_equal(count_network_msgs(out <- download_metadata()), 1)
  testthat::expect_null(out)
  testthat::expect_false(file.exists(tempf))
  testthat::expect_false(file.exists(paste0(tempf, ".part")))
})

testthat::test_that("download_metadata says when there is no internet", {
  cache <- stash_metadata_cache()
  on.exit(cache$restore(), add = TRUE)
  testthat::local_mocked_bindings(has_internet = function() FALSE, .package = "curl")
  testthat::expect_equal(count_network_msgs(out <- download_metadata()), 1)
  testthat::expect_null(out)
})

testthat::test_that("download_metadata stops without the second source when interrupted", {
  cache <- stash_metadata_cache()
  on.exit(cache$restore(), add = TRUE)
  calls <- 0
  testthat::local_mocked_bindings(
    aop_fetch = function(...) { calls <<- calls + 1; "aborted" }
  )
  testthat::expect_equal(count_network_msgs(out <- download_metadata()), 0)
  testthat::expect_null(out)
  testthat::expect_equal(calls, 1)
  testthat::expect_false(file.exists(cache$path))
})
