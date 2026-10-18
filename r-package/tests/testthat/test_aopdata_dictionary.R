context("aopdata_dictionary")

# skip tests because they take too much time
testthat::skip_on_cran()



# Expected success -----------------------------------

test_that("aopdata_dictionary", {

  testthat::expect_invisible(aopdata_dictionary(lang='en') )
  testthat::expect_invisible(aopdata_dictionary(lang='pt') )
})


# Expected errors -----------------------------------
test_that("aopdata_dictionary", {

  testthat::expect_error(aopdata_dictionary(lang='999'), class = "aopdata_error")
  testthat::expect_error(aopdata_dictionary(lang=999) )

})
