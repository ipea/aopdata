# restore what setup-cache.R changed
for (v in names(aoptest_old_env)) {
  if (is.na(aoptest_old_env[[v]])) {
    Sys.unsetenv(v)
  } else {
    do.call(Sys.setenv, as.list(aoptest_old_env[v]))
  }
}
options(aoptest_old_opt)
