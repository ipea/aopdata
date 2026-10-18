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

  # check_downloaded_obj
  testthat::expect_null( check_downloaded_obj(NULL) )
  testthat::expect_message( check_downloaded_obj(NULL), class = "aopdata_network")

})


### checkmate text with braces ----------------

testthat::test_that("abort_if_invalid handles braces in checkmate messages", {
  check <- checkmate::check_choice("x", c("{a}", "b"))
  testthat::expect_error(abort_if_invalid(check, "x"), class = "aopdata_error")
  testthat::expect_true(abort_if_invalid(TRUE, "x"))
})
