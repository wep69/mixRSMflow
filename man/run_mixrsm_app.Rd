\name{run_mixrsm_app}
\alias{run_mixrsm_app}
\title{Launch the interactive mixRSMflow teaching and analysis application}
\usage{
run_mixrsm_app(launch.browser = TRUE, demo = TRUE)
}
\arguments{
  \item{launch.browser}{Passed to `shiny::runApp`.}
  \item{demo}{If `TRUE`, preload a simulated three-component dataset.}
}
\description{
The Shiny interface mirrors the package workflow and displays reproducible R commands for the main operations. It is intentionally an optional interface; all scientific functionality remains available through the R API.
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
No return value; launches a Shiny application.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  run_mixrsm_app()
  run_mixrsm_app(launch.browser = FALSE, demo = FALSE)
  run_mixrsm_app(launch.browser = FALSE, demo = TRUE)
}
args(run_mixrsm_app)
requireNamespace("shiny", quietly = TRUE)
}
