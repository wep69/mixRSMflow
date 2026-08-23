#' Generate reproducible pedagogical mixture datasets
#'
#' The datasets are simulated and carry known response-generating mechanisms,
#' avoiding licensing problems associated with textbook datasets.
#'
#' @param kind `mixture`, `mixture_process`, or `multiresponse`.
#' @param n_rep Number of replicates per base blend for `mixture` and `multiresponse`.
#' @param seed Random seed.
#' @return A data frame with mixture components and simulated response(s).
#' @examples
#' d <- mix_demo_data("mixture", n_rep = 2, seed = 27)
#' head(d)
#' @export
mix_demo_data <- function(kind=c("mixture","mixture_process","multiresponse"),n_rep=3L,seed=20260813L) {
  kind<-match.arg(kind);set.seed(seed);spec<-mix_spec(c("A","B","C"))
  if(kind=="mixture_process"){
    d<-mix_design(spec,"mixture_process",base_type="simplex_centroid",process=list(temperature=c(-1,0,1),time=c(-1,1)))$data
    mu<-4.5*d$A+6.0*d$B+6.8*d$C+2.0*d$A*d$B-3.0*d$A*d$C+1.5*d$B*d$C+
      .35*d$temperature-.25*d$time+.55*d$B*d$temperature
    d$response<-mu+rnorm(nrow(d),0,.18);attr(d,"mix_spec")<-spec;return(d)
  }
  base<-mix_design(spec,"augmented_centroid")$data
  d<-base[rep(seq_len(nrow(base)),each=as.integer(n_rep)),,drop=FALSE]
  mu<-4.7*d$A+6.3*d$B+7.2*d$C+2.2*d$A*d$B-2.5*d$A*d$C+6.2*d$A^2*d$B*d$C-6.6*d$A*d$B^2*d$C
  d$response<-mu+rnorm(nrow(d),0,.18)
  if(kind=="multiresponse"){
    d$quality<-d$response
    mu2<-8.0-2.5*d$A+1.8*d$B+0.4*d$C-2*d$B*d$C
    d$cost<-mu2+rnorm(nrow(d),0,.12)
    d$stability<-5.5+1.8*d$A-1.2*d$B+2.3*d$C+1.5*d$A*d$B+rnorm(nrow(d),0,.15)
  }
  d$.run<-seq_len(nrow(d));rownames(d)<-NULL;attr(d,"mix_spec")<-spec;d
}
