context("check_connection")

# skip tests because they need internet and third-party hosts
testthat::skip_on_cran()
testthat::skip_if_offline()


url_ok <- 'https://google.com/'
url_timeout <- 'https://www.google.com:81/'
url_error <- 'https://httpbin.org/status/300'


# Expected success -----------------------------------

test_that("check_connection", {

  testthat::expect_true(check_connection(url = url_ok) )
  testthat::expect_true(check_connection(url = url_ok, silent = TRUE) )
})


# Expected errors to fail gracefully -----------------------------------
test_that("check_connection", {

  # broken link / non-existent
  testthat::expect_message( check_connection(url = "banana") )
  testthat::expect_false( check_connection(url = "banana") )

  # connection timeout
  testthat::expect_message( check_connection(url = url_timeout) )
  testthat::expect_false( check_connection(url = url_timeout) )

  # link not working
  testthat::expect_message( check_connection(url = url_error) )
  testthat::expect_false( check_connection(url = url_error) )

})
