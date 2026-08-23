\name{mix_pseudocomponents}
\alias{mix_pseudocomponents}
\title{Convert between original proportions and lower/upper pseudocomponents}
\usage{
mix_pseudocomponents(x, spec, type = c("L", "U"), inverse = FALSE)
}
\arguments{
  \item{x}{Data frame, matrix, or numeric vector.}
  \item{spec}{A `mix_spec` object.}
  \item{type}{`L` for lower-bound pseudocomponents or `U` for upper-bound pseudocomponents.}
  \item{inverse}{If `TRUE`, convert pseudocomponents back to original proportions.}
}
\description{
Lower pseudocomponents are defined by z_i = (x_i - L_i)/(T - sum L), while upper pseudocomponents are defined by u_i = (U_i - x_i)/(sum U - T). Both transformations preserve a unit-sum simplex after scaling.
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A data frame with one column per mixture component.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"), lower = c(.1, .1, .1), upper = c(.8, .8, .8))
x <- data.frame(A = .2, B = .3, C = .5)
z <- mix_pseudocomponents(x, sp, type = "L")
mix_pseudocomponents(z, sp, type = "L", inverse = TRUE)
u <- mix_pseudocomponents(x, sp, type = "U")
u
}
