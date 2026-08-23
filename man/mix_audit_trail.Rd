\name{mix_audit_trail}
\alias{mix_audit_trail}
\title{Extract an auditable trail from a mixRSMflow object}
\usage{
mix_audit_trail(object)
}
\arguments{
  \item{object}{Any mixRSMflow result object containing an `audit` field.}
}
\description{
Extract an auditable trail from a mixRSMflow object
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A normalized data frame of audit steps.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_centroid")
mix_audit_trail(d)
fit <- mix_fit("response", mix_demo_data("mixture", n_rep = 2, seed = 30), sp)
mix_audit_trail(fit)
mix_audit_trail(sp)
}
