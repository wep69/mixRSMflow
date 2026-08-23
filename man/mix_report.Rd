\name{mix_report}
\alias{mix_report}
\title{Create a reproducible scientific mixture-analysis report}
\usage{
mix_report(object,file=NULL,format=c("markdown","html","docx","pdf"),
                       title="mixRSMflow Scientific Analysis Report",include_session=TRUE)
}
\arguments{
  \item{object}{A `mix_fit`, `mix_multi_fit`, or list containing `fit`, `design`, `optimum`, and related artifacts.}
  \item{file}{Output path. If omitted, report text is returned.}
  \item{format}{`markdown`, `html`, `docx`, or `pdf`.}
  \item{title}{Report title.}
  \item{include_session}{Include session information.}
}
\description{
Create a reproducible scientific mixture-analysis report
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
Invisibly, a `mix_report` object containing the report source and output path.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 26)
fit <- mix_fit("response", d, sp)
r <- mix_report(fit, format = "markdown")
r
r2 <- mix_report(fit, format = "html", title = "Exploratory fit", include_session = FALSE)
r3 <- mix_report(list(fit = fit, design = fit$design), format = "markdown")
}
