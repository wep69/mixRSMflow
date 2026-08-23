#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Usage: Rscript install_offline.R <directory-with-package-archives>")
dir <- normalizePath(args[[1L]], mustWork = TRUE)
files <- list.files(dir, pattern = "\\.(zip|tar\\.gz|tgz)$", full.names = TRUE, ignore.case = TRUE)
if (!length(files)) stop("No R package archives found in ", dir)
# Multiple passes allow dependencies whose archives are in the same folder to be installed first.
remaining <- files
for (pass in seq_len(max(3L, length(files)))) {
  if (!length(remaining)) break
  failed <- character()
  for (f in remaining) {
    type <- if (grepl("\\.zip$", f, ignore.case = TRUE)) "win.binary" else "source"
    ok <- try(utils::install.packages(f, repos = NULL, type = type, dependencies = FALSE), silent = TRUE)
    if (inherits(ok, "try-error")) failed <- c(failed, f)
  }
  if (length(failed) == length(remaining)) break
  remaining <- failed
}
if (length(remaining)) {
  cat("Could not install these archives; inspect missing recursive/system dependencies:\n", paste(remaining, collapse="\n"), "\n", sep="")
  quit(status = 1L)
}
cat("All supplied package archives were installed.\n")
