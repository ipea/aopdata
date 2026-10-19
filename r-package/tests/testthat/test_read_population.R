context("read_population")

# skip tests because they take too much time
testthat::skip_on_cran()

### expected behavior ----------------
  test_that("read_population expected behavior", {

    testthat::expect_s3_class(read_population(city='nat', geometry = TRUE, showProgress = FALSE), 'sf')
    testthat::expect_s3_class(read_population(city='nat', geometry = FALSE, showProgress = FALSE), 'data.frame')
    testthat::expect_s3_class(read_population(city='all', geometry = FALSE, showProgress = FALSE), 'data.frame')
  })

### expected errors and messages ----------------

test_that("read_population errors and messages", {

  # Wrong city
  testthat::expect_error(read_population(city = 'abcdefg'))
  testthat::expect_error(read_population(city = 'abc'))

  # Wrong year
  testthat::expect_error(read_population(city = 'rec', year=1500))

  # Wrong geometry or showProgress
  testthat::expect_error(read_population(city = 'rec', year=2010, geometry = 'aaa'))
  testthat::expect_error(read_population(city = 'rec', year=2010, showProgress = 'aaa'), class = "aopdata_error")

})




### broken internet ----------------

testthat::test_that("gracefully fail if could not download metadata", {

  # meta data
  testthat::local_mocked_bindings(
    select_metadata = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_null( read_population(city='nat') )
  testthat::expect_equal( count_network_msgs(read_population(city='nat')), 1 )
})

testthat::test_that("gracefully fail if could not download data", {

  # meta data
  testthat::local_mocked_bindings(
    download_data = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_null( read_population(city='nat') )
  testthat::expect_equal( count_network_msgs(read_population(city='nat')), 1 )
})

testthat::test_that("gracefully fail if could not download grid data", {

  # meta data
  testthat::local_mocked_bindings(
    read_grid = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_null( read_population(city='nat', geometry = TRUE) )
  testthat::expect_equal( count_network_msgs(read_population(city='nat', geometry = TRUE)), 1 )
})


### progress messages ----------------

testthat::test_that("progress messages follow showProgress", {

  testthat::local_mocked_bindings(
    select_metadata = function(...) { data.frame(download_path2 = "x", year = 2010) },
    download_data = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_message(
    read_population(city = 'nat', showProgress = TRUE),
    "Downloading population data"
  )
  testthat::expect_no_message(
    read_population(city = 'nat', showProgress = FALSE),
    message = "Downloading"
  )
})
