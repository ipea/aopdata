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
