\name{mix_augment}
\alias{mix_augment}
\title{Augment an existing design according to an information objective}
\usage{
mix_augment(design,n_new=1L,model="scheffe_quadratic",objective=c("D","I","G",
"optimum_uncertainty"),fit=NULL,resolution=15L,seed=1L,candidates=2000L)
}
\arguments{
  \item{design}{Existing `mix_design`.}
  \item{n_new}{Number of additional runs.}
  \item{model}{Model basis.}
  \item{objective}{`D`, `I`, `G`, or `optimum_uncertainty`.}
  \item{fit}{Optional fitted model required for optimum-focused augmentation.}
  \item{resolution}{Candidate resolution.}
  \item{seed}{Random seed.}
  \item{candidates}{Maximum number of candidate compositions scored per added run.}
}
\description{
Augment an existing design according to an information objective
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
Augmented `mix_design`.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_centroid")
a <- mix_augment(d, n_new = 1, model = "scheffe_quadratic", objective = "D",
                 resolution = 6, candidates = 150)
nrow(a$data)
a2 <- mix_augment(d, n_new = 1, model = "scheffe_quadratic", objective = "G",
                  resolution = 6, candidates = 150)
a3 <- mix_augment(d, n_new = 1, model = "scheffe_linear", objective = "I",
                  resolution = 6, candidates = 150)
nrow(a3$data)
}
