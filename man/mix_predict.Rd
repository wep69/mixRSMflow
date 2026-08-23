\name{mix_predict}
\alias{mix_predict}
\title{Predict from a fitted mixture model with uncertainty}
\usage{
mix_predict(object,newdata=NULL,interval=c("none","confidence","prediction"),
                        level=0.95,type=c("response","link"))
}
\arguments{
  \item{object}{A fitted mixture model.}
  \item{newdata}{New mixture/process settings; defaults to fitted data.}
  \item{interval}{`none`, `confidence`, or `prediction` (prediction is Gaussian only).}
  \item{level}{Confidence level.}
  \item{type}{`response` or `link` for GLMs.}
}
\description{
Predict from a fitted mixture model with uncertainty
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
Data frame with predictions and optional uncertainty limits.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 18)
fit <- mix_fit("response", d, sp)
head(mix_predict(fit, interval = "confidence"))
head(mix_predict(fit, interval = "prediction"))
mix_predict(fit, newdata = data.frame(A = 1/3, B = 1/3, C = 1/3),
            interval = "confidence", level = .9)
}
