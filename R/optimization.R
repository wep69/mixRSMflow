.mix_objective_values <- function(fit, points, goal="maximize", target=NULL) {
  pr<-mix_predict(fit,points)$.prediction
  if(goal=="maximize") pr else if(goal=="minimize") -pr else -abs(pr-target)
}

.mix_ga_composition <- function(fit,goal,target,n_pop=80L,generations=80L,seed=1L) {
  spec<-fit$spec;set.seed(seed)
  pop<-.mix_random_candidates(spec,n_pop,seed)
  if(nrow(pop)<n_pop) pop<-rbind(pop,.mix_candidate_grid(spec,15L,1000L,seed+1L))
  pop<-pop[seq_len(min(n_pop,nrow(pop))),,drop=FALSE]
  add_process <- function(P) {
    if (length(fit$process)) {
      for (nm in fit$process) P[[nm]] <- stats::median(fit$data[[nm]], na.rm = TRUE)
    }
    P
  }
  score<-function(P).mix_objective_values(fit,add_process(P),goal,target)
  vals<-score(pop)
  for(g in seq_len(generations)){
    elite_n<-max(4L,ceiling(nrow(pop)*.2));ord<-order(vals,decreasing=TRUE);elite<-pop[ord[seq_len(elite_n)],,drop=FALSE]
    children<-elite
    while(nrow(children)<n_pop){
      a<-as.numeric(elite[sample.int(elite_n,1),fit$spec$components]);b<-as.numeric(elite[sample.int(elite_n,1),fit$spec$components])
      lam<-runif(1);z<-lam*a+(1-lam)*b
      z<-z+rnorm(spec$q,0,0.03*spec$total);z<-.mix_project_bounded_simplex(z,spec$lower,spec$upper,spec$total,spec$tol)
      if(.mix_feasible(z,spec)){zz<-as.data.frame(t(z),check.names=FALSE);names(zz)<-spec$components;children<-rbind(children,zz)}
    }
    pop<-children[seq_len(n_pop),,drop=FALSE];vals<-score(pop)
  }
  j<-which.max(vals);list(point=pop[j,,drop=FALSE],score=vals[j])
}

#' Optimize a fitted mixture response surface under exact mixture constraints
#'
#' @param object A `mix_fit` object.
#' @param goal `maximize`, `minimize`, or `target`.
#' @param target Target response for `goal="target"`.
#' @param method `hybrid`, `grid`, or `ga`.
#' @param grid_resolution Feasible-grid resolution.
#' @param random_candidates Number of random feasible candidates added to the grid.
#' @param near_tolerance Relative tolerance defining the near-optimal region.
#' @param seed Random seed.
#' @return A `mix_optimum` object containing the best composition, response, and near-optimal region.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 2, seed = 20)
#' fit <- mix_fit("response", d, sp)
#' opt <- mix_optimize(fit, goal = "maximize", method = "grid", grid_resolution = 10)
#' opt$composition
#' @export
mix_optimize <- function(object,goal=c("maximize","minimize","target"),target=NULL,
                         method=c("hybrid","grid","ga"),grid_resolution=30L,
                         random_candidates=5000L,near_tolerance=0.01,seed=1L) {
  if(!inherits(object,"mix_fit")).mix_stop("mix_optimize expects a mix_fit object.")
  goal<-match.arg(goal);method<-match.arg(method);if(goal=="target"&&is.null(target)).mix_stop("target is required.")
  spec<-object$spec
  cand<-.mix_candidate_grid(spec,grid_resolution,random_candidates,seed)
  if(length(object$process)){
    fixed<-lapply(object$process,function(nm)stats::median(object$data[[nm]],na.rm=TRUE));names(fixed)<-object$process
    for(nm in object$process)cand[[nm]]<-fixed[[nm]]
  }
  sc<-.mix_objective_values(object,cand,goal,target);j<-which.max(sc);best<-cand[j,,drop=FALSE];bestscore<-sc[j]
  if(method%in%c("ga","hybrid")){
    ga<-.mix_ga_composition(object,goal,target,80L,80L,seed+101L)
    if(length(object$process))for(nm in object$process)ga$point[[nm]]<-fixed[[nm]]
    gscore<-.mix_objective_values(object,ga$point,goal,target)
    if(gscore>bestscore){best<-ga$point;bestscore<-gscore}
  }
  response<-mix_predict(object,best,interval="confidence")
  # Define near-optimality on the response scale.
  preds<-mix_predict(object,cand)$.prediction
  opt<-response$.prediction[1]
  span<-max(preds)-min(preds);tol_abs<-near_tolerance*pmax(span,abs(opt),1e-12)
  if(goal=="maximize")keep<-preds>=opt-tol_abs else if(goal=="minimize")keep<-preds<=opt+tol_abs else keep<-abs(preds-target)<=abs(opt-target)+tol_abs
  near<-cand[keep,,drop=FALSE];near$.prediction<-preds[keep]
  comp<-as.numeric(best[1,spec$components]);names(comp)<-spec$components
  out<-list(composition=comp,prediction=response$.prediction[1],lower=response$.lower[1],upper=response$.upper[1],
            goal=goal,target=target,method=method,near_tolerance=near_tolerance,near_optimal=near,
            fit=object,spec=spec,seed=seed,audit=list(.mix_audit("mix_optimize",list(goal=goal,method=method))))
  class(out)<-"mix_optimum";out
}

#' Quantify uncertainty in the location of the optimum
#'
#' @param object A `mix_optimum` or `mix_fit` object.
#' @param method `parametric` coefficient simulation or `residual_bootstrap`.
#' @param B Number of draws/bootstrap replicates.
#' @param level Confidence level.
#' @param grid_resolution Optimization grid used for each replicate.
#' @param seed Random seed.
#' @return A `mix_optimum_ci` object with marginal intervals and a joint cloud of optimal compositions.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 2, seed = 21)
#' fit <- mix_fit("response", d, sp)
#' ci <- mix_optimum_ci(fit, method = "parametric", B = 10, grid_resolution = 8, seed = 2)
#' ci$intervals
#' @export
mix_optimum_ci <- function(object,method=c("parametric","residual_bootstrap"),B=500L,level=0.95,
                           grid_resolution=20L,seed=1L) {
  method<-match.arg(method)
  opt0<-if(inherits(object,"mix_optimum"))object else mix_optimize(object,method="grid",grid_resolution=grid_resolution,seed=seed,random_candidates=0L)
  fit<-opt0$fit;if(!inherits(fit,"mix_fit")).mix_stop("A classical mix_fit is required.")
  if(fit$engine!="lm"&&method=="residual_bootstrap").mix_stop("Residual bootstrap is currently implemented for Gaussian linear mixture fits.")
  set.seed(seed);spec<-fit$spec;cand<-.mix_candidate_grid(spec,grid_resolution,1000L,seed+7L)
  if(length(fit$process))for(nm in fit$process)cand[[nm]]<-stats::median(fit$data[[nm]],na.rm=TRUE)
  Xc<-.mix_new_basis(fit,cand)
  cloud<-matrix(NA_real_,B,spec$q);resp<-rep(NA_real_,B)
  if(method=="parametric"){
    ee<-eigen((fit$vcov+t(fit$vcov))/2,symmetric=TRUE);vals<-pmax(ee$values,0)
    L<-ee$vectors%*%diag(sqrt(vals),length(vals))
    for(b in seq_len(B)){
      beta<-fit$coefficients+drop(L%*%rnorm(length(fit$coefficients)))
      eta<-drop(Xc%*%beta);pred<-if(fit$engine=="lm")eta else fit$family$linkinv(eta)
      j<-if(opt0$goal=="maximize")which.max(pred) else if(opt0$goal=="minimize")which.min(pred) else which.min(abs(pred-opt0$target))
      cloud[b,]<-as.numeric(cand[j,spec$components]);resp[b]<-pred[j]
    }
  } else {
    r<-fit$y-fit$fitted
    for(b in seq_len(B)){
      db<-fit$data;db[[fit$response]]<-fit$fitted+sample(r,replace=TRUE)
      args<-c(list(response=fit$response,data=db,spec=spec,model=fit$model,family=fit$family,process=fit$process,process_order=fit$process_order,mixture_process=fit$mixture_process),fit$basis_args)
      fb<-try(do.call(mix_fit,args),silent=TRUE);if(inherits(fb,"try-error"))next
      xb<-.mix_new_basis(fb,cand);pred<-drop(xb%*%fb$coefficients)
      j<-if(opt0$goal=="maximize")which.max(pred) else if(opt0$goal=="minimize")which.min(pred) else which.min(abs(pred-opt0$target))
      cloud[b,]<-as.numeric(cand[j,spec$components]);resp[b]<-pred[j]
    }
  }
  ok<-stats::complete.cases(cloud)&is.finite(resp);cloud<-cloud[ok,,drop=FALSE];resp<-resp[ok]
  if(nrow(cloud)<max(2L,.2*B)).mix_warn("Few successful optimum replicates; inspect model stability.")
  colnames(cloud)<-spec$components;a<-(1-level)/2
  intervals<-data.frame(component=spec$components,estimate=opt0$composition,
                        lower=apply(cloud,2,stats::quantile,probs=a,na.rm=TRUE),
                        upper=apply(cloud,2,stats::quantile,probs=1-a,na.rm=TRUE),row.names=NULL)
  rint<-stats::quantile(resp,c(a,0.5,1-a),na.rm=TRUE)
  out<-list(optimum=opt0,method=method,B=B,successful=nrow(cloud),level=level,intervals=intervals,
            response_interval=stats::setNames(as.numeric(rint),c("lower","median","upper")),
            cloud=as.data.frame(cloud),seed=seed)
  class(out)<-"mix_optimum_ci";out
}

#' @export
print.mix_optimum <- function(x,...) {cat("<mix_optimum>",x$goal,"\nComposition:\n");print(round(x$composition,6));cat("Predicted response:",format(x$prediction,digits=7),"\n95% model interval:",format(x$lower,digits=7),"to",format(x$upper,digits=7),"\nNear-optimal candidate points:",nrow(x$near_optimal),"\n");invisible(x)}
#' @export
print.mix_optimum_ci <- function(x,...) {cat("<mix_optimum_ci>",x$method," Successful:",x$successful,"/",x$B,"\n");print(x$intervals,row.names=FALSE);cat("Response interval:\n");print(x$response_interval);invisible(x)}
