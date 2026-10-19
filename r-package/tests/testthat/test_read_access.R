context("read_access")

# skip tests because they take too much time
testthat::skip_on_cran()

### expected behavior ----------------
  test_that("read_access expected behavior", {

    testthat::expect_s3_class(read_access(city='all', geometry = FALSE, peak=FALSE, showProgress = FALSE), 'data.frame')
    testthat::expect_s3_class(read_access(city='nat', geometry = TRUE, showProgress = FALSE), 'sf')
    testthat::expect_s3_class(read_access(city='nat', geometry = FALSE, showProgress = FALSE), 'data.frame')
    testthat::expect_s3_class(read_access(city='nat', geometry = FALSE, peak=FALSE, showProgress = FALSE), 'data.frame')
    car <- read_access(city='nat', geometry = FALSE, mode='car', peak=FALSE, showProgress = FALSE)
    testthat::expect_s3_class(car, 'data.frame')
    testthat::expect_gt(nrow(car), 0)
    testthat::expect_true(all(car$peak[!is.na(car$peak)] == 0))
    testthat::expect_true(all(car$mode[!is.na(car$mode)] == 'car'))
    testthat::expect_s3_class(read_access(city='poa', geometry = FALSE, mode='public_transport', peak=FALSE, showProgress = FALSE), 'data.frame')
    pt <- read_access(city='poa', geometry = FALSE, mode='public_transport', peak=TRUE, showProgress = FALSE)
    testthat::expect_s3_class(pt, 'data.frame')
    testthat::expect_gt(nrow(pt), 0)
    testthat::expect_true(all(pt$peak[!is.na(pt$peak)] == 1))
    testthat::expect_s3_class(read_access(city='poa', geometry = FALSE, mode='public_transport', peak=TRUE, showProgress = FALSE, year=2018), 'data.frame')
    testthat::expect_s3_class(read_access(city='poa', geometry = FALSE, mode='public_transport', peak=TRUE, showProgress = FALSE, year=2017), 'data.frame')
    testthat::expect_s3_class(read_access(city='porto alegre', geometry = FALSE, mode='public_transport', peak=TRUE, showProgress = FALSE), 'data.frame')
  })


test_that("read_access expected behavior multiple cities", {

  test_walk <- read_access(city=c('nat', 'for'), mode= 'walk', geometry = FALSE, showProgress = FALSE)
  testthat::expect_s3_class(test_walk, 'data.frame')
  test_walk <- test_walk[!is.na(test_walk$mode), ]
  expect_equal(  length(unique(test_walk$abbrev_muni)) , 2)
  expect_equal(  unique(test_walk$mode) , 'walk')


  test_pt <- read_access(city=c('rec', 'for'), mode= 'public_transport', geometry = FALSE, showProgress = FALSE)
  testthat::expect_s3_class(test_pt, 'data.frame')
  test_pt <- test_pt[!is.na(test_pt$mode), ]
  expect_equal(  length(unique(test_pt$abbrev_muni)) , 2)
  expect_equal(  unique(test_pt$mode) , 'public_transport')


})



### expected errors and messages ----------------

test_that("read_access errors and messages", {

  # Wrong city
  testthat::expect_error(read_access(city = 'abcdefg', showProgress = FALSE))
  testthat::expect_error(read_access(city = 'abc', showProgress = FALSE))
  testthat::expect_error(read_access( showProgress = FALSE))

  # Wrong year
  testthat::expect_error(read_access(city = 'rec', year=1500, showProgress = FALSE))

   # Wrong mode
   testthat::expect_error( read_access(city='natal', mode= 'public_transport', geometry = FALSE, showProgress = FALSE) )
   testthat::expect_error( read_access(city=c('nat', 'poa'), mode= 'public_transport', geometry = FALSE, showProgress = FALSE), class = "aopdata_error")
   testthat::expect_error( read_access(city='nat', mode= 'public_transport', geometry = FALSE, showProgress = FALSE), class = "aopdata_error")
   testthat::expect_error( read_access(city='nat', mode= 'public_transport', geometry = FALSE, showProgress = FALSE, year=2018) )
   testthat::expect_error( read_access(city='nat', mode= 'public_transport', geometry = FALSE, showProgress = FALSE, year=2017) )

    # Wrong geometry, peak, showProgress
   testthat::expect_error(read_access(city = 'rec', year=2019, geometry = 'aaa'))
   testthat::expect_error(read_access(city = 'rec', year=2019, showProgress = 'aaa'))
   testthat::expect_error(read_access(city = 'rec', year=2019, peak = 'aaa'))

})


### broken internet ----------------

testthat::test_that("gracefully fail if could not download metadata", {

  # meta data
  testthat::local_mocked_bindings(
    select_metadata = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_null( read_access(city='nat') )
  testthat::expect_equal( count_network_msgs(read_access(city='nat')), 1 )
})

testthat::test_that("gracefully fail if could not download data", {

  # meta data
  testthat::local_mocked_bindings(
    download_data = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_null( read_access(city='nat') )
  testthat::expect_equal( count_network_msgs(read_access(city='nat')), 1 )
})

testthat::test_that("gracefully fail if could not download grid data", {

  # meta data
  testthat::local_mocked_bindings(
    read_grid = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_null( read_access(city='nat', geometry = TRUE) )
  testthat::expect_equal( count_network_msgs(read_access(city='nat', geometry = TRUE)), 1 )
})


testthat::test_that("gracefully fail if could not download land use data", {

  # meta data
  testthat::local_mocked_bindings(
    read_landuse = function(...) { inform_failure("offline"); NULL }
  )
  testthat::expect_null( read_access(city='nat') )
  testthat::expect_equal( count_network_msgs(read_access(city='nat')), 1 )
})


testthat::test_that("a failed nested download gives exactly one message", {
  real_download_data <- download_data
  testthat::local_mocked_bindings(
    download_data = function(url, ...) {
      if (any(grepl("population", url))) {
        inform_failure("offline")
        return(invisible(NULL))
      }
      real_download_data(url, ...)
    }
  )
  testthat::expect_equal(
    count_network_msgs(out <- read_access(city = 'nat', showProgress = FALSE)),
    1
  )
  testthat::expect_null(out)
})


testthat::test_that("flags must be TRUE or FALSE", {
  testthat::expect_error(read_access(city = 'nat', peak = NA), class = "aopdata_error")
  testthat::expect_error(read_access(city = 'nat', showProgress = 1), class = "aopdata_error")
  testthat::expect_error(read_population(city = 'nat', showProgress = 0), class = "aopdata_error")
  testthat::expect_error(read_landuse(city = 'nat', geometry = NA), class = "aopdata_error")
})
