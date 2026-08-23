#' Fit several responses using a shared mixture specification
#' @param responses Character vector of response columns.
#' @param data Data frame or `mix_design`.
#' @param spec Mixture specification.
#' @param ... Arguments passed to [mix_fit()].
#' @return A `mix_multi_fit` object.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("multiresponse", n_rep = 2, seed = 22)
#' mf <- mix_multi_fit(c("quality", "stability"), d, sp, model = "scheffe_quadratic")
#' mf
#' @export
mix_multi_fit <- function(responses,data,spec=NULL,...) {
  responses<-as.character(responses);.mix_check_names(responses,"responses")
  fits<-lapply(responses,function(r)mix_fit(r,data=data,spec=spec,...));names(fits)<-responses
  out<-list(fits=fits,responses=responses,spec=fits[[1]]$spec,data=.mix_extract_data(data));class(out)<-"mix_multi_fit";out
}

.mix_desirability <- function(y,goal,low=NULL,high=NULL,target=NULL,weight=1) {
  if(goal=="maximize"){
    if(is.null(low)||is.null(high)).mix_stop("low and high are required for maximize desirability.")
    d<-ifelse(y<=low,0,ifelse(y>=high,1,((y-low)/(high-low))^weight))
  } else if(goal=="minimize"){
    if(is.null(low)||is.null(high)).mix_stop("low and high are required for minimize desirability.")
    d<-ifelse(y<=low,1,ifelse(y>=high,0,((high-y)/(high-low))^weight))
  } else {
    if(is.null(low)||is.null(high)||is.null(target)).mix_stop("low, target, and high are required for target desirability.")
    d<-ifelse(y<low|y>high,0,ifelse(y<=target,((y-low)/(target-low))^weight,((high-y)/(high-target))^weight))
  }
  pmin(1,pmax(0,d))
}

.mix_pareto <- function(Y,directions,targets=NULL) {
  Z<-as.matrix(Y)
  for(j in seq_len(ncol(Z))){
    if(directions[j]=="minimize") Z[,j]<--Z[,j]
    else if(directions[j]=="target"){
      tt<-targets[j];if(is.na(tt)).mix_stop("A target is required for Pareto handling of target-goal responses.")
      Z[,j]<--abs(Z[,j]-tt)
    }
  }
  n<-nrow(Z);dom<-logical(n)
  for(i in seq_len(n))if(!dom[i])for(j in seq_len(n))if(i!=j && all(Z[j,]>=Z[i,]) && any(Z[j,]>Z[i,])){dom[i]<-TRUE;break}
  which(!dom)
}

#' Multiresponse desirability, constraints, and Pareto optimization
#'
#' @param object A `mix_multi_fit` object or named list of `mix_fit` objects.
#' @param goals Named character vector (`maximize`, `minimize`, `target`).
#' @param settings Named list; each response entry may contain `low`, `high`, `target`, and `weight`.
#' @param response_weights Relative weights in the geometric mean of desirabilities.
#' @param constraints Optional named list of response bounds such as `list(y1=c(min=5,max=10))`.
#' @param resolution Feasible-grid resolution.
#' @param random_candidates Number of random feasible points.
#' @param seed Random seed.
#' @return A `mix_multiopt` object with best compromise and Pareto set.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("multiresponse", n_rep = 2, seed = 23)
#' mf <- mix_multi_fit(c("quality", "stability"), d, sp, model = "scheffe_quadratic")
#' goals <- c(quality = "maximize", stability = "maximize")
#' settings <- list(quality = list(low = min(d$quality), high = max(d$quality)),
#'                  stability = list(low = min(d$stability), high = max(d$stability)))
#' mo <- mix_multiopt(mf, goals, settings, resolution = 8, random_candidates = 50)
#' mo$composition
#' @export
mix_multiopt <- function(object,goals,settings,response_weights=NULL,constraints=NULL,
                         resolution=25L,random_candidates=5000L,seed=1L) {
  fits<-if(inherits(object,"mix_multi_fit"))object$fits else object
  if(is.null(names(fits))||any(!vapply(fits,inherits,logical(1),"mix_fit"))).mix_stop("object must contain named mix_fit objects.")
  resp<-names(fits);goals<-goals[resp];if(anyNA(goals)).mix_stop("goals must be named for every response.")
  spec<-fits[[1]]$spec;cand<-.mix_candidate_grid(spec,resolution,random_candidates,seed)
  Y<-sapply(fits,function(f)mix_predict(f,cand)$.prediction);if(is.vector(Y))Y<-matrix(Y,ncol=length(fits));colnames(Y)<-resp
  feasible<-rep(TRUE,nrow(cand))
  if(!is.null(constraints))for(nm in names(constraints)){
    rr<-constraints[[nm]];if(!is.null(rr["min"]))feasible<-feasible&Y[,nm]>=rr["min"];if(!is.null(rr["max"]))feasible<-feasible&Y[,nm]<=rr["max"]
  }
  D<-matrix(NA_real_,nrow(cand),length(resp),dimnames=list(NULL,resp))
  for(j in seq_along(resp)){s<-settings[[resp[j]]] %||% list();D[,j]<-.mix_desirability(Y[,j],goals[j],s$low,s$high,s$target,s$weight%||%1)}
  rw<-response_weights%||%rep(1,length(resp));rw<-rw/sum(rw)
  overall<-exp(rowSums(sweep(log(pmax(D,1e-300)),2,rw,"*")));overall[!feasible]<-0
  best<-which.max(overall);dirs<-as.character(goals);targets<-vapply(resp,function(nm){s<-settings[[nm]] %||% list();if(is.null(s$target))NA_real_ else as.numeric(s$target)},numeric(1));pi<-.mix_pareto(Y[feasible,,drop=FALSE],dirs,targets)
  feas_idx<-which(feasible);pareto_idx<-feas_idx[pi]
  out<-list(composition=as.numeric(cand[best,spec$components]),prediction=Y[best,],desirability=D[best,],overall=overall[best],
            candidate_results=cbind(cand,as.data.frame(Y),overall_desirability=overall,feasible=feasible),
            pareto=cbind(cand[pareto_idx,,drop=FALSE],as.data.frame(Y[pareto_idx,,drop=FALSE])),fits=fits,spec=spec,goals=goals,settings=settings)
  names(out$composition)<-spec$components;class(out)<-"mix_multiopt";out
}

#' @export
print.mix_multi_fit <- function(x,...) {cat("<mix_multi_fit> Responses:",paste(x$responses,collapse=", "),"\n");invisible(x)}
#' @export
print.mix_multiopt <- function(x,...) {cat("<mix_multiopt>\nBest composition:\n");print(round(x$composition,6));cat("Responses:\n");print(round(x$prediction,6));cat("Overall desirability:",format(x$overall,digits=6)," Pareto points:",nrow(x$pareto),"\n");invisible(x)}
