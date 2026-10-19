context("aopdata_dictionary")

# skip tests because they take too much time
testthat::skip_on_cran()



# Expected success -----------------------------------

test_that("aopdata_dictionary opens the dictionary page", {

  # record the url instead of opening a browser
  opened <- character()
  old <- options(browser = function(url) opened <<- c(opened, url))
  on.exit(options(old), add = TRUE)

  testthat::expect_invisible(aopdata_dictionary(lang='en') )
  testthat::expect_invisible(aopdata_dictionary(lang='pt') )
  testthat::expect_match(opened[1], "data_dic_en\\.html$")
  testthat::expect_match(opened[2], "data_dic_pt\\.html$")
})


# Expected errors -----------------------------------
test_that("aopdata_dictionary rejects invalid languages", {

  testthat::expect_error(aopdata_dictionary(lang='999'), class = "aopdata_error")
  testthat::expect_error(aopdata_dictionary(lang='english'), class = "aopdata_error")
  testthat::expect_error(aopdata_dictionary(lang=c('en', 'pt')), class = "aopdata_error")
  testthat::expect_error(aopdata_dictionary(lang=999) )

})
