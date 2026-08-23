#!/usr/bin/env Rscript
# Local release validation for mixRSMflow. This script never downloads or
# installs CRAN dependencies. It assumes development dependencies are present.
args <- commandArgs(trailingOnly = TRUE)
pkg <- if (length(args)) normalizePath(args[[1L]], mustWork = TRUE) else normalizePath(getwd(), mustWork = TRUE)
required <- c("devtools", "roxygen2", "testthat", "rcmdcheck", "knitr", "rmarkdown")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Install these development packages before validation: ", paste(missing, collapse = ", "))
cat("Package source:", pkg, "\n")
cat("R:", R.version.string, "\n")

cat("\n[1/7] Regenerating documentation\n")
devtools::document(pkg, quiet = FALSE)

cat("\n[2/7] Running testthat\n")
devtools::test(pkg, reporter = "summary", stop_on_failure = TRUE)

cat("\n[3/7] Building vignettes\n")
devtools::build_vignettes(pkg)

cat("\n[4/7] Building source tarball\n")
tarball <- devtools::build(pkg, path = dirname(pkg), vignettes = TRUE, manual = TRUE)
cat("Built:", tarball, "\n")

cat("\n[5/7] Installing built tarball into a temporary clean library\n")
lib <- tempfile("mixRSMflow-lib-"); dir.create(lib)
rbin <- file.path(R.home("bin"), "R")
install_status <- system2(rbin, c("CMD", "INSTALL", "--no-multiarch", paste0("--library=", shQuote(lib)), shQuote(tarball)))
if (!identical(install_status, 0L)) stop("Clean-library installation failed.")

cat("\n[6/7] Running frozen numerical validation battery against installed build\n")
rscript <- file.path(R.home("bin"), "Rscript")
battery <- file.path(pkg, "inst", "scripts", "run_validation_battery.R")
battery_out <- file.path(pkg, "validation_battery_results.csv")
# Set R_LIBS_USER in the current process instead of passing it through
# system2(env = ...): on Windows the env entries are not reliably promoted to
# child environment variables, and the battery then fails to locate the
# freshly installed build. The child Rscript inherits Sys.setenv() values.
old_libs <- Sys.getenv("R_LIBS_USER", unset = "")
Sys.setenv(R_LIBS_USER = paste(c(lib, old_libs[nzchar(old_libs)]), collapse = .Platform$path.sep))
on.exit({
  if (nzchar(old_libs)) Sys.setenv(R_LIBS_USER = old_libs) else Sys.unsetenv("R_LIBS_USER")
}, add = TRUE)
battery_status <- system2(rscript, c(shQuote(battery), shQuote(battery_out)))
if (!identical(battery_status, 0L)) stop("Frozen numerical validation battery failed.")

cat("\n[7/7] R CMD check --as-cran\n")
chk <- rcmdcheck::rcmdcheck(tarball, args = "--as-cran", error_on = "never", check_dir = file.path(dirname(pkg), "check"))
print(chk)
if (length(chk$errors) || length(chk$warnings)) {
  stop("Release gate failed: R CMD check reported errors or warnings. Review check output.")
}
cat("\nLOCAL RELEASE VALIDATION PASSED. Review NOTE(s) manually before submission.\n")
