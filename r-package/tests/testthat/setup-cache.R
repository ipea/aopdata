# tests never touch the user's real cache or config: tools::R_user_dir()
# reads these variables, so every test file uses folders inside tempdir()
aoptest_old_env <- Sys.getenv(c("R_USER_CACHE_DIR", "R_USER_CONFIG_DIR"), unset = NA)
aoptest_old_opt <- options(aopdata.cache_dir = NULL)
Sys.setenv(
  R_USER_CACHE_DIR = file.path(tempdir(), "aoptest_user_cache"),
  R_USER_CONFIG_DIR = file.path(tempdir(), "aoptest_user_config")
)

# teardown-cache.R restores them
