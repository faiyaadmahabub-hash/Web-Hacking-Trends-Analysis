# Offline source checks only. Do not source entire scripts: they install packages
# and expect absent external data and machine-specific working directories.
args <- commandArgs(trailingOnly = FALSE)
script <- sub("^--file=", "", args[grepl("^--file=", args)])
root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
cat(R.version.string, "\n")
packages <- c("dplyr", "ggplot2", "tidyr", "stringr", "lubridate", "scales",
              "missForest", "rgeolocate", "corrplot", "ggcorrplot", "knitr")
print(data.frame(package = packages, available = vapply(packages, requireNamespace, logical(1), quietly = TRUE)))
scripts <- list.files(root, pattern = "\\.R$", full.names = TRUE)
for (path in scripts) {
  expressions <- parse(path, encoding = "UTF-8")
  cat("PASS parse:", basename(path), "-", length(expressions), "expressions\n")
}
parse_failures <- 0L
for (path in list.files(root, pattern = "\\.Rmd$", full.names = TRUE)) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  active <- FALSE
  code <- character()
  chunks <- 0L
  for (line in lines) {
    if (grepl("^```\\{r", line)) {
      active <- TRUE; chunks <- chunks + 1L
    } else if (active && grepl("^```", line)) {
      active <- FALSE
    } else if (active) {
      code <- c(code, line)
    }
  }
  parsed <- tryCatch({parse(text = code, encoding = "UTF-8"); TRUE}, error = function(error) {
    cat("FAIL Rmd parse:", basename(path), conditionMessage(error), "\n")
    FALSE
  })
  if (parsed) cat("PASS Rmd extraction/parse:", basename(path), "-", chunks, "chunks\n")
  else parse_failures <- parse_failures + 1L
}
# Execute only the original mode helper on a synthetic vector. No external data.
os_script <- scripts[grepl("OS Analysis", scripts, fixed = TRUE)]
expressions <- parse(os_script, encoding = "UTF-8")
helper <- Filter(function(x) is.call(x) && identical(x[[1]], as.name("<-")) &&
                   identical(x[[2]], as.name("getMode")), as.list(expressions))
stopifnot(length(helper) == 1L)
eval(helper[[1]])
stopifnot(identical(getMode(c("Linux", "Windows", "Linux")), "Linux"))
cat("PASS original getMode helper on synthetic input (not real incident evidence)\n")
required <- c("hackingData.csv", "Clean_Loss_Data.csv", "GeoLite2-Country.mmdb")
for (name in required) {
  found <- list.files(root, recursive = TRUE, pattern = paste0("^", name, "$"), full.names = TRUE)
  cat(if (length(found)) "AVAILABLE:" else "BLOCKED: missing", name, "\n")
}
quit(status = if (parse_failures) 1L else 0L)
