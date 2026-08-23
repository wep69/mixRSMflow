#' Gaussian-process Bayesian optimization over a mixture region
#'
#' This advanced adapter uses `DiceKriging` when available. It can either
#' recommend the next feasible composition from existing observations or,
#' when an explicit deterministic `objective` function is supplied, conduct
#' a reproducible sequential optimization simulation.
#'
#' @param data Existing mixture data.
#' @param response Response column name.
#' @param spec Mixture specification.
#' @param goal `maximize` or `minimize`.
#' @param iterations Number of sequential recommendations/evaluations.
#' @param objective Optional function accepting a numeric composition vector and returning a scalar response.
#' @param candidate_n Number of random feasible candidates per iteration.
#' @param nugget GP nugget parameter.
#' @param seed Random seed.
#' @return A `mix_bo` object containing GP history and recommended point(s).
#' @examples
#' if (requireNamespace("DiceKriging", quietly = TRUE)) {
#'   sp <- mix_spec(c("A", "B", "C"))
#'   d <- mix_demo_data("mixture", n_rep = 1, seed = 24)
#'   bo <- mix_bo(d, "response", sp, iterations = 1, candidate_n = 100, seed = 2)
#'   bo$recommendation
#' }
#' @export
mix_bo <- function(data,response,spec,goal=c("maximize","minimize"),iterations=1L,
                   objective=NULL,candidate_n=5000L,nugget=1e-8,seed=1L) {
  if(!requireNamespace("DiceKriging",quietly=TRUE)).mix_stop("Package 'DiceKriging' is required for mix_bo().")
  goal<-match.arg(goal);dat<-as.data.frame(data,check.names=FALSE);response<-as.character(response)[1]
  if(!all(c(spec$components,response)%in%names(dat))).mix_stop("data is missing mixture components or response.")
  hist<-list();set.seed(seed)
  for(it in seq_len(as.integer(iterations))){
    X<-as.matrix(dat[spec$components])/spec$total;y<-dat[[response]];sgn<-if(goal=="maximize")1 else -1
    gp<-DiceKriging::km(design=as.data.frame(X),response=sgn*y,covtype="matern5_2",nugget=nugget,control=list(trace=FALSE))
    cand<-.mix_random_candidates(spec,candidate_n,seed+it);pred<-DiceKriging::predict.km(gp,newdata=as.data.frame(as.matrix(cand[spec$components])/spec$total),type="UK",se.compute=TRUE)
    best<-max(sgn*y);mu<-as.numeric(pred$mean);sd<-pmax(as.numeric(pred$sd),1e-12);z<-(mu-best)/sd
    ei<-(mu-best)*stats::pnorm(z)+sd*stats::dnorm(z);j<-which.max(ei);nextp<-cand[j,,drop=FALSE]
    hist[[it]]<-list(iteration=it,point=nextp,expected_improvement=ei[j],predicted_mean=sgn*mu[j],predicted_sd=sd[j])
    if(is.null(objective)) break
    val<-objective(as.numeric(nextp[1,spec$components]));if(length(val)!=1L||!is.finite(val)).mix_stop("objective must return one finite numeric value.")
    np<-as.data.frame(nextp,check.names=FALSE);np[[response]]<-val
    # Align the new row with the observation table (e.g. a trailing .run column).
    for(nm in setdiff(names(dat),names(np))) np[[nm]]<-NA
    dat<-rbind(dat,np)
  }
  out<-list(data=dat,response=response,spec=spec,goal=goal,history=hist,recommendation=tail(hist,1)[[1]]$point,seed=seed,
            status=if(is.null(objective))"recommendation_only" else "sequential_simulation")
  class(out)<-"mix_bo";out
}
#' @export
print.mix_bo <- function(x,...) {cat("<mix_bo>",x$status,"\nRecommended composition:\n");print(x$recommendation,row.names=FALSE);invisible(x)}
