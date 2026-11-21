context("cache")

# skip tests because they take too much time
testthat::skip_on_cran()

# setup-cache.R points tools::R_user_dir() to folders inside tempdir()


### set, get and reset the cache directory ----------------

testthat::test_that("set_aopdata_cache_dir creates an aopdata folder inside path", {
  on.exit(set_aopdata_cache_dir(NULL, verbose = FALSE), add = TRUE)
  path <- file.path(tempdir(), "aoptest_custom")
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  testthat::expect_message(out <- set_aopdata_cache_dir(path))
  testthat::expect_equal(out, normalize_dir(file.path(path, "aopdata")))
  testthat::expect_true(dir.exists(out))
  testthat::expect_equal(get_aopdata_cache_dir(), out)
  testthat::expect_equal(readLines(config_cache_file()), out)

  # back to the default, removing the saved setting
  testthat::expect_equal(set_aopdata_cache_dir(NULL, verbose = FALSE),
                         default_cache_dir())
  testthat::expect_false(file.exists(config_cache_file()))
  testthat::expect_equal(get_aopdata_cache_dir(), default_cache_dir())
})

testthat::test_that("a relative path is saved as an absolute path", {
  on.exit(set_aopdata_cache_dir(NULL, verbose = FALSE), add = TRUE)
  wd <- setwd(tempdir())
  on.exit(setwd(wd), add = TRUE)
  on.exit(unlink(file.path(tempdir(), "aoptest_rel"), recursive = TRUE), add = TRUE)

  out <- set_aopdata_cache_dir("aoptest_rel", verbose = FALSE)
  setwd(wd)
  testthat::expect_equal(get_aopdata_cache_dir(), out)
  testthat::expect_true(dir.exists(out))
  testthat::expect_match(out, "aoptest_rel/aopdata$")
})

testthat::test_that("the aopdata.cache_dir option takes precedence, for the session", {
  on.exit(set_aopdata_cache_dir(NULL, verbose = FALSE), add = TRUE)
  set_aopdata_cache_dir(file.path(tempdir(), "aoptest_saved"), verbose = FALSE)
  on.exit(unlink(file.path(tempdir(), "aoptest_saved"), recursive = TRUE), add = TRUE)

  old <- options(aopdata.cache_dir = file.path(tempdir(), "aoptest_opt"))
  on.exit(options(old), add = TRUE)
  testthat::expect_equal(get_aopdata_cache_dir(),
                         normalize_dir(file.path(tempdir(), "aoptest_opt", "aopdata")))
  testthat::expect_match(readLines(config_cache_file()), "aoptest_saved/aopdata$")
})

testthat::test_that("set_aopdata_cache_dir rejects invalid input", {
  testthat::expect_error(set_aopdata_cache_dir(1), class = "aopdata_error")
  testthat::expect_error(set_aopdata_cache_dir(c("a", "b")), class = "aopdata_error")
  testthat::expect_error(set_aopdata_cache_dir(""), class = "aopdata_error")
  testthat::expect_error(set_aopdata_cache_dir(tempdir(), verbose = NA),
                         class = "aopdata_error")
})


testthat::test_that("the cache directory can be passed back to set_aopdata_cache_dir", {
  on.exit(set_aopdata_cache_dir(NULL, verbose = FALSE), add = TRUE)
  on.exit(unlink(file.path(tempdir(), "aoptest_back"), recursive = TRUE), add = TRUE)
  out <- set_aopdata_cache_dir(file.path(tempdir(), "aoptest_back"), verbose = FALSE)
  testthat::expect_equal(set_aopdata_cache_dir(out, verbose = FALSE), out)
})


### list and delete ----------------

testthat::test_that("delete_aopdata_cache deletes only the aopdata folder", {
  path <- file.path(tempdir(), "aoptest_user_folder")
  on.exit(unlink(path, recursive = TRUE), add = TRUE)
  old <- options(aopdata.cache_dir = path)
  on.exit(options(old), add = TRUE)

  dir.create(path, showWarnings = FALSE)
  writeLines("mine", file.path(path, "user_file.txt"))
  release <- file.path(get_aopdata_cache_dir(), "aopdata_data_release_v1.0.0")
  dir.create(release, recursive = TRUE)
  writeLines("x", file.path(release, "aoptest_a.csv"))

  testthat::expect_equal(basename(list_aopdata_cache()), "aoptest_a.csv")

  testthat::expect_message(delete_aopdata_cache())
  testthat::expect_false(dir.exists(get_aopdata_cache_dir()))
  testthat::expect_true(file.exists(file.path(path, "user_file.txt")))
  testthat::expect_length(list_aopdata_cache(), 0)
})

testthat::test_that("delete_aopdata_cache keeps a user's own 'aopdata' folder", {
  path <- file.path(tempdir(), "aoptest_own")
  on.exit(unlink(path, recursive = TRUE), add = TRUE)
  old <- options(aopdata.cache_dir = path)
  on.exit(options(old), add = TRUE)

  # a folder named 'aopdata' that already holds the user's files
  dir.create(file.path(path, "aopdata", "R"), recursive = TRUE)
  writeLines("mine", file.path(path, "aopdata", "R", "code.R"))
  release <- file.path(get_aopdata_cache_dir(), "aopdata_data_release_v1.0.0")
  dir.create(release)
  writeLines("x", file.path(release, "aoptest_a.csv"))

  delete_aopdata_cache(verbose = FALSE)
  testthat::expect_false(dir.exists(release))
  testthat::expect_true(file.exists(file.path(path, "aopdata", "R", "code.R")))
})


### old data releases ----------------

testthat::test_that("old data releases are deleted once per session, unless kept", {
  path <- file.path(tempdir(), "aoptest_releases")
  on.exit(unlink(path, recursive = TRUE), add = TRUE)
  old <- options(aopdata.cache_dir = path)
  on.exit(options(old), add = TRUE)
  reset_cache_state()
  on.exit(reset_cache_state(), add = TRUE)

  make_release <- function(tag) {
    d <- file.path(get_aopdata_cache_dir(), paste0("aopdata_data_release_", tag))
    dir.create(d, recursive = TRUE, showWarnings = FALSE)
    writeLines("x", file.path(d, "aoptest_a.csv"))
    d
  }
  old_release <- make_release("v0.0.1")
  current <- make_release(data_release)
  other <- file.path(get_aopdata_cache_dir(), "not_a_release")
  dir.create(other)

  # kept with the option
  keep <- options(aopdata.keep_old_cache = TRUE)
  testthat::expect_length(delete_old_releases(), 0)
  options(keep)
  testthat::expect_true(dir.exists(old_release))

  # deleted, with one message
  testthat::expect_message(delete_old_releases(), "v0.0.1", class = "aopdata_cache")
  testthat::expect_false(dir.exists(old_release))
  testthat::expect_true(dir.exists(current))
  testthat::expect_true(dir.exists(other))

  # only once per session
  make_release("v0.0.2")
  testthat::expect_silent(delete_old_releases())
  testthat::expect_true(dir.exists(file.path(get_aopdata_cache_dir(),
                                             "aopdata_data_release_v0.0.2")))
})

testthat::test_that("delete_aopdata_cache keeps a user's file named 'aopdata'", {
  path <- file.path(tempdir(), "aoptest_file")
  on.exit(unlink(path, recursive = TRUE), add = TRUE)
  dir.create(path)
  writeLines("x", file.path(path, "aopdata"))
  old <- options(aopdata.cache_dir = path)
  on.exit(options(old), add = TRUE)

  delete_aopdata_cache(verbose = FALSE)
  testthat::expect_true(file.exists(file.path(path, "aopdata")))
})
