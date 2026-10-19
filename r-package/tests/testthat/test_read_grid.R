context("read_grid")

# skip tests because they take too much time
testthat::skip_on_cran()

### expected behavior ----------------
  test_that("read_grid expected behavior", {

    # whole file
    expect_true(is(  read_grid(city='nat', showProgress = FALSE), 'sf') )
    expect_true(is(  read_grid(city='Natal', showProgress = FALSE), 'sf'))
    expect_true(is(  read_grid(city='all', showProgress = FALSE), 'sf'))

  })


### expected errors and messages ----------------

test_that("read_grid errors and messages", {

  # Wrong city
  testthat::expect_error(read_grid(city = 'abcdefg'))
  testthat::expect_error(read_grid(city = 'abc'), class = "aopdata_error")
  testthat::expect_error(read_grid(city = 'a'))
  testthat::expect_error(read_grid(city = 1))
  testthat::expect_error(read_grid(city = NULL))
  testthat::expect_error(read_grid())

  # Wrong geometry or showProgress
  testthat::expect_error( read_grid(city = 'rec', showProgress = 'aaa'), class = "aopdata_error")
  testthat::expect_error( read_grid(city = 'rec', showProgress = 333))
  testthat::expect_error( read_grid(city = 'rec', showProgress = NULL))

})


### broken internet ----------------

testthat::test_that("gracefully fail if could not download metadata", {

  # meta data
  testthat::local_mocked_bindings(
    select_metadata = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_null( read_grid(city='nat') )
  testthat::expect_equal( count_network_msgs(read_grid(city='nat')), 1 )
})

testthat::test_that("gracefully fail if could not download data", {

  # meta data
  testthat::local_mocked_bindings(
    download_data = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_null( read_grid(city='nat') )
  testthat::expect_equal( count_network_msgs(read_grid(city='nat')), 1 )
})



