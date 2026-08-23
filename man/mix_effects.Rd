\name{mix_effects}
\alias{mix_effects}
\title{Compute interpretable component effects and trace paths}
\usage{
mix_effects(object,type=c("cox","piepel","component_trace","substitution","directional"),
                        component=NULL,reference=NULL,n=101L,from_component=NULL,
                        to_component=NULL,
                        direction=NULL,delta=1e-4)
}
\arguments{
  \item{object}{A `mix_fit` object.}
  \item{type}{Effect type: `cox`, `piepel`, `component_trace`, `substitution`, or `directional`.}
  \item{component}{Focal component name.}
  \item{reference}{Reference composition; defaults to the fitted specification center.}
  \item{n}{Number of trace points.}
  \item{from_component}{Component to decrease for substitution effects.}
  \item{to_component}{Component to increase for substitution effects.}
  \item{direction}{Optional custom direction vector for `directional`.}
  \item{delta}{Small step used to report a local numerical slope.}
}
\description{
Compute interpretable component effects and trace paths
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_effect` list with path, predictions, and local slope.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 17)
fit <- mix_fit("response", d, sp)
e <- mix_effects(fit, type = "cox", component = "A", n = 21)
head(e$path)
e2 <- mix_effects(fit, type = "piepel", component = "B", n = 21)
e2$local_slope
mix_effects(fit, type = "substitution", from_component = "A", to_component = "B", n = 21)
}
