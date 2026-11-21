# number of aopdata_network messages signalled while evaluating expr
count_network_msgs <- function(expr) {
  n <- 0
  withCallingHandlers(
    expr,
    aopdata_network = function(m) {
      n <<- n + 1
      invokeRestart("muffleMessage")
    }
  )
  n
}

# forget that old data releases were already checked in this session
reset_cache_state <- function() {
  aopdata_env$old_cache_checked <- NULL
}
