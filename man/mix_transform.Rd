\name{mix_transform}
\alias{mix_transform}
\title{Transform mixture coordinates to independent orthonormal coordinates}
\usage{
mix_transform(x, spec, center = NULL)
}
\arguments{
  \item{x}{Data frame, matrix, or numeric vector of mixture compositions.}
  \item{spec}{A `mix_spec` object.}
  \item{center}{Center for the transformation; defaults to `spec$center`.}
}
\description{
Transform mixture coordinates to independent orthonormal coordinates
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
Matrix with `q-1` independent coordinates.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
x <- data.frame(A = 0.2, B = 0.3, C = 0.5)
mix_transform(x, sp)
mix_transform(c(A = 0.2, B = 0.3, C = 0.5), sp)
mix_transform(x, sp, center = c(A = 0, B = 0, C = 1))
}
