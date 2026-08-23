\name{mix_fractionate_process}
\alias{mix_fractionate_process}
\title{Model-based fractionation of crossed mixture-process designs}
\usage{
mix_fractionate_process(design, process, fraction,
  model = "scheffe_quadratic", process_order = 2L,
  mixture_process = TRUE, seed = 1L, exchange_iter = 300L)
}
\arguments{
\item{design}{A \code{mix_design} containing mixture and process columns.}
\item{process}{Character vector naming process variables.}
\item{fraction}{Fraction in (0,1] or integer number of runs.}
\item{model}{Mixture basis protected during fractionation.}
\item{process_order}{Process polynomial order.}
\item{mixture_process}{Whether mixture-by-process interactions are protected.}
\item{seed}{Seed used in exchange-search exploration.}
\item{exchange_iter}{Maximum exchange iterations.}
}
\description{Selects a full-rank fraction using QR initialization and a D-information exchange search rather than silently taking an arbitrary subset.}
\value{A fractionated \code{mix_design}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
mp <- mix_design(sp, "mixture_process", process = list(temp = c(-1, 1)))
fr <- mix_fractionate_process(mp, process = "temp", fraction = 10,
                              process_order = 1, mixture_process = FALSE)
nrow(fr$data)
fr2 <- mix_fractionate_process(mp, process = "temp", fraction = .5,
                               process_order = 1, mixture_process = FALSE)
nrow(fr2$data)
mix_fractionate_process(mp, process = "temp", fraction = 8, model = "scheffe_linear",
                        process_order = 1, mixture_process = FALSE)
}
