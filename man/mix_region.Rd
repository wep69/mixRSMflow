\name{mix_region}
\alias{mix_region}
\title{Define a curved or independent-coordinate region of interest}
\usage{
mix_region(spec, type = c("polytope", "sphere", "ellipsoid", "cuboid"),
                       center = NULL, radius = NULL, shape = NULL,
                       lower_y = NULL, upper_y = NULL)
}
\arguments{
  \item{spec}{A `mix_spec` object.}
  \item{type}{Region type: `polytope`, `sphere`, `ellipsoid`, or `cuboid`.}
  \item{center}{Optional center in original mixture coordinates.}
  \item{radius}{Radius in orthonormal independent coordinates for a sphere.}
  \item{shape}{Positive-definite `(q-1) x (q-1)` ellipsoid shape matrix.}
  \item{lower_y}{Bounds in independent coordinates for a cuboid.}
  \item{upper_y}{Bounds in independent coordinates for a cuboid.}
}
\description{
Define a curved or independent-coordinate region of interest
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_region` object inheriting from `mix_spec`.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
rg <- mix_region(sp, type = "sphere", radius = 0.2)
rg$region
rg2 <- mix_region(sp, type = "ellipsoid", shape = diag(2))
rg2$region
rg3 <- mix_region(sp, type = "cuboid", lower_y = c(-0.3, -0.3), upper_y = c(0.3, 0.3))
rg3$region
}
