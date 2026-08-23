.mix_new_basis <- function(object, newdata) {
  args <- c(list(data=newdata, spec=object$spec, model=object$model,
                 process=object$process, process_order=object$process_order %||% 2L,
                 mixture_process=object$mixture_process %||% FALSE), object$basis_args)
  X <- do.call(mix_basis,args)
  required <- colnames(object$X)
  miss <- setdiff(required, colnames(X))
  if(length(miss)) .mix_stop("New-data basis is missing fitted terms: ", paste(miss, collapse = ", "))
  X[, required, drop=FALSE]
}

#' Predict from a fitted mixture model with uncertainty
#'
#' @param object A fitted mixture model.
#' @param newdata New mixture/process settings; defaults to fitted data.
#' @param interval `none`, `confidence`, or `prediction` (prediction is Gaussian only).
#' @param level Confidence level.
#' @param type `response` or `link` for GLMs.
#' @return Data frame with predictions and optional uncertainty limits.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 2, seed = 18)
#' fit <- mix_fit("response", d, sp)
#' head(mix_predict(fit, interval = "confidence"))
#' @export
mix_predict <- function(object,newdata=NULL,interval=c("none","confidence","prediction"),
                        level=0.95,type=c("response","link")) {
  interval<-match.arg(interval); type<-match.arg(type)
  if(inherits(object,"mix_fit")) {
    nd<-newdata %||% object$data; X<- .mix_new_basis(object,nd)
    eta<-drop(X %*% object$coefficients)
    se_eta<-sqrt(pmax(0,rowSums((X %*% object$vcov)*X)))
    crit<-if(object$engine=="lm") stats::qt((1+level)/2,df=object$df_residual) else stats::qnorm((1+level)/2)
    if(object$engine=="lm" || type=="link") pred<-eta else pred<-object$family$linkinv(eta)
    out<-data.frame(.prediction=pred)
    if(interval!="none") {
      if(interval=="prediction" && object$engine!="lm") .mix_stop("Prediction intervals are implemented only for Gaussian linear mixture models.")
      se_use<-if(interval=="prediction") sqrt(se_eta^2+object$dispersion) else se_eta
      lo_eta<-eta-crit*se_use; hi_eta<-eta+crit*se_use
      if(object$engine=="lm" || type=="link") {lo<-lo_eta;hi<-hi_eta} else {lo<-object$family$linkinv(lo_eta);hi<-object$family$linkinv(hi_eta)}
      out$.se_link<-se_eta; out$.lower<-lo; out$.upper<-hi
    }
    cbind(as.data.frame(nd,check.names=FALSE),out)
  } else if(inherits(object,"mix_fit_gls")) {
    nd <- newdata %||% object$data
    Xfull <- do.call(mix_basis, c(list(data=nd,spec=object$spec,model=object$model,process=object$process,mixture_process=object$mixture_process),object$basis_args))
    miss <- setdiff(object$basis_names, colnames(Xfull)); if(length(miss)) .mix_stop("New-data basis is missing fitted GLS terms.")
    X <- Xfull[,object$basis_names,drop=FALSE]
    beta <- stats::coef(object$fit); names(beta) <- object$basis_names
    eta <- drop(X %*% beta)
    out <- data.frame(.prediction=eta)
    if(interval!="none") {
      if(interval=="prediction") .mix_stop("Prediction intervals for correlated GLS observations are not provided because their variance depends on the specified new-observation correlation structure.")
      V <- stats::vcov(object$fit); rownames(V)<-colnames(V)<-object$basis_names
      se <- sqrt(pmax(0,rowSums((X %*% V)*X))); crit <- stats::qt((1+level)/2,df=object$fit$dims$N-object$fit$dims$p)
      out$.se_link<-se;out$.lower<-eta-crit*se;out$.upper<-eta+crit*se
    }
    cbind(nd,out)
  } else if(inherits(object,"mix_fit_mixed")) {
    nd<-newdata %||% object$data
    Xfull<-do.call(mix_basis,c(list(data=nd,spec=object$spec,model=object$model,process=object$process,mixture_process=object$mixture_process),object$basis_args))
    X<-Xfull[,object$basis_names,drop=FALSE]
    aug<-nd; for(j in seq_len(ncol(X))) aug[[object$safe_names[j]]]<-X[,j]
    pr<-stats::predict(object$fit,newdata=aug,re.form=NA,type=if(is.null(object$family))"response" else type)
    cbind(nd,.prediction=as.numeric(pr))
  } else if(inherits(object,"mix_fit_bayes")) {
    nd<-newdata %||% object$data
    Xfull<-do.call(mix_basis,c(list(data=nd,spec=object$spec,model=object$model,process=object$process,mixture_process=object$mixture_process),object$basis_args))
    X<-Xfull[,object$basis_names,drop=FALSE]
    aug<-nd; for(j in seq_len(ncol(X))) aug[[object$safe_names[j]]]<-X[,j]
    ep<-brms::posterior_epred(object$fit,newdata=aug,re_formula=NA)
    a<-(1-level)/2
    out<-data.frame(.prediction=colMeans(ep),.lower=apply(ep,2,stats::quantile,probs=a),.upper=apply(ep,2,stats::quantile,probs=1-a))
    cbind(nd,out)
  } else .mix_stop("Unsupported fitted object.")
}

#' @export
predict.mix_fit <- function(object,newdata=NULL,...) mix_predict(object,newdata=newdata,...)

.mix_path_limits <- function(reference,direction,spec,tol=1e-10) {
  lo<--Inf; hi<-Inf
  for(i in seq_along(reference)) {
    d<-direction[i]
    if(abs(d)<tol) next
    a<-(spec$lower[i]-reference[i])/d; b<-(spec$upper[i]-reference[i])/d
    lo<-max(lo,min(a,b)); hi<-min(hi,max(a,b))
  }
  if(nrow(spec$A)) {
    ar<-drop(spec$A%*%reference); ad<-drop(spec$A%*%direction)
    for(j in seq_along(ar)) {
      if(abs(ad[j])<tol) {if(ar[j]>spec$b[j]+spec$tol) return(c(NA,NA)); next}
      bound<-(spec$b[j]-ar[j])/ad[j]
      if(ad[j]>0) hi<-min(hi,bound) else lo<-max(lo,bound)
    }
  }
  c(lo,hi)
}

.mix_cox_direction <- function(reference,i,spec) {
  s<-reference/spec$total
  d<-numeric(spec$q); d[i]<-1
  if(s[i] >= 1-spec$tol) .mix_stop("Reference point is degenerate for this Cox direction.")
  others<-setdiff(seq_len(spec$q),i)
  d[others]<--s[others]/(1-s[i])
  d/spec$total*spec$total
}

.mix_piepel_direction <- function(reference,i,spec) {
  L<-spec$lower; scale<-spec$total-sum(L)
  if(scale<=spec$tol) .mix_stop("Lower bounds leave no L-pseudocomponent space.")
  z<-(reference-L)/scale
  d_z<-numeric(spec$q); d_z[i]<-1
  if(z[i]>=1-spec$tol) .mix_stop("Reference is degenerate in L-pseudocomponent space.")
  others<-setdiff(seq_len(spec$q),i); d_z[others]<--z[others]/(1-z[i])
  scale*d_z
}

#' Compute interpretable component effects and trace paths
#'
#' @param object A `mix_fit` object.
#' @param type Effect type: `cox`, `piepel`, `component_trace`, `substitution`, or `directional`.
#' @param component Focal component name.
#' @param reference Reference composition; defaults to the fitted specification center.
#' @param n Number of trace points.
#' @param from_component Component to decrease for substitution effects.
#' @param to_component Component to increase for substitution effects.
#' @param direction Optional custom direction vector for `directional`.
#' @param delta Small step used to report a local numerical slope.
#' @return A `mix_effect` list with path, predictions, and local slope.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 2, seed = 17)
#' fit <- mix_fit("response", d, sp)
#' e <- mix_effects(fit, type = "cox", component = "A", n = 21)
#' head(e$path)
#' @export
mix_effects <- function(object,type=c("cox","piepel","component_trace","substitution","directional"),
                        component=NULL,reference=NULL,n=101L,from_component=NULL,to_component=NULL,
                        direction=NULL,delta=1e-4) {
  if(!inherits(object,"mix_fit")) .mix_stop("mix_effects expects a mix_fit object.")
  type<-match.arg(type); spec<-object$spec; ref<-as.numeric(reference %||% spec$center)
  if(!.mix_feasible(ref,spec)) .mix_stop("reference must be feasible.")
  if(type%in%c("cox","piepel","component_trace")) {
    if(is.null(component)||!component%in%spec$components) .mix_stop("A valid component is required.")
    i<-match(component,spec$components)
    d<-if(type=="piepel") .mix_piepel_direction(ref,i,spec) else .mix_cox_direction(ref,i,spec)
  } else if(type=="substitution") {
    if(is.null(from_component)||is.null(to_component)||!all(c(from_component,to_component)%in%spec$components)) .mix_stop("Valid from_component and to_component are required.")
    d<-numeric(spec$q);d[match(from_component,spec$components)]<--1;d[match(to_component,spec$components)]<-1
  } else {
    if(is.null(direction)||length(direction)!=spec$q||abs(sum(direction))>1e-8) .mix_stop("direction must have q elements summing to zero.")
    d<-as.numeric(direction)
  }
  lim<-.mix_path_limits(ref,d,spec); if(any(!is.finite(lim))) lim[!is.finite(lim)]<-c(-1,1)[!is.finite(lim)]
  tt<-seq(lim[1],lim[2],length.out=as.integer(n)); X<-sweep(outer(tt,d),2,ref,"+")
  X<-as.data.frame(X,check.names=FALSE);names(X)<-spec$components;X<-.mix_filter_feasible(X,spec)
  # Carry process variables at their fitted medians when needed.
  if(length(object$process)) for(nm in object$process) X[[nm]]<-stats::median(object$data[[nm]],na.rm=TRUE)
  pred<-mix_predict(object,X,interval="confidence")
  eps<-min(delta,0.1*(lim[2]-lim[1])); slope<-NA_real_
  if(is.finite(eps)&&eps>0&&all(c(-eps,eps)>=lim[1])&&all(c(-eps,eps)<=lim[2])) {
    xx<-rbind(ref-eps*d,ref+eps*d);xx<-as.data.frame(xx,check.names=FALSE);names(xx)<-spec$components
    if(length(object$process)) for(nm in object$process) xx[[nm]]<-stats::median(object$data[[nm]],na.rm=TRUE)
    pp<-mix_predict(object,xx)$.prediction;slope<-(pp[2]-pp[1])/(2*eps)
  }
  out<-list(type=type,component=component,reference=stats::setNames(ref,spec$components),direction=stats::setNames(d,spec$components),limits=lim,path=pred,local_slope=slope)
  class(out)<-"mix_effect";out
}

#' @export
print.mix_effect <- function(x,...) {
  cat("<mix_effect>",x$type,"\n")
  if(!is.null(x$component)) cat(" Component:",x$component,"\n")
  cat(" Local slope:",format(x$local_slope,digits=6),"\n")
  print(utils::head(x$path,8L),row.names=FALSE);invisible(x)
}
