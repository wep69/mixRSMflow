\name{mix_inverse_transform}
\alias{mix_inverse_transform}
\title{Transform independent coordinates back to mixture coordinates}
\usage{
mix_inverse_transform(y, spec, center = NULL)
}
\arguments{
  \item{y}{Matrix or numeric vector with `q-1` independent coordinates.}
  \item{spec}{A `mix_spec` object.}
  \item{center}{Center used in the inverse transformation.}
}
\description{
Transform independent coordinates back to mixture coordinates
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
Data frame in original mixture coordinates.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
x <- data.frame(A = 0.2, B = 0.3, C = 0.5)
y <- mix_transform(x, sp)
mix_inverse_transform(y, sp)
mix_inverse_transform(as.numeric(y[1, ]), sp)
mix_inverse_transform(matrix(c(0.1, -0.05, -0.2, 0.15), nrow = 2, byrow = TRUE), sp)
}
