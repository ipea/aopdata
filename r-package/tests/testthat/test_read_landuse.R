context("read_landuse")

# skip tests because they take too much time
testthat::skip_on_cran()

### expected behavior ----------------
  test_that("read_landuse expected behavior", {

    # whole file
    expect_true(is(  read_landuse(city='nat', geometry = TRUE, showProgress = FALSE), 'sf'))
    expect_true(is(  read_landuse(city='nat', geometry = FALSE, showProgress = FALSE), 'data.frame'))
    expect_true(is(  read_landuse(city='nat', geometry = FALSE, showProgress = FALSE), 'data.frame'))
    expect_true(is(  read_landuse(city='all', geometry = FALSE, showProgress = FALSE), 'data.frame'))
  })

### expected errors and messages ----------------

test_that("read_landuse errors and messages", {

  # Wrong city
  testthat::expect_error(read_landuse(city = 'abcdefg'))
  testthat::expect_error(read_landuse(city = 'abc'))

  # Wrong year
  testthat::expect_error(read_landuse(city = 'rec', year=1500), class = "aopdata_error")

  # Wrong geometry or showProgress
  testthat::expect_error(read_landuse(city = 'rec', year=2019, geometry = 'aaa'))
  testthat::expect_error(read_landuse(city = 'rec', year=2019, showProgress = 'aaa'))

})




### broken internet ----------------

testthat::test_that("gracefully fail if could not download metadata", {

  # meta data
  testthat::local_mocked_bindings(
    select_metadata = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_null( read_landuse(city='nat') )
  testthat::expect_equal( count_network_msgs(read_landuse(city='nat')), 1 )
})

testthat::test_that("gracefully fail if could not download data", {

  # meta data
  testthat::local_mocked_bindings(
    download_data = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_null( read_landuse(city='nat') )
  testthat::expect_equal( count_network_msgs(read_landuse(city='nat')), 1 )
})

testthat::test_that("gracefully fail if could not download grid data", {

  # meta data
  testthat::local_mocked_bindings(
    read_grid = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_null( read_landuse(city='nat', geometry = TRUE) )
  testthat::expect_equal( count_network_msgs(read_landuse(city='nat', geometry = TRUE)), 1 )
})

testthat::test_that("gracefully fail if could not download population data", {

  # meta data
  testthat::local_mocked_bindings(
    read_population = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_null( read_landuse(city='nat') )
  testthat::expect_equal( count_network_msgs(read_landuse(city='nat')), 1 )
})
