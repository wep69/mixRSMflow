#' ANOVA and pure-error/lack-of-fit decomposition for mixture models
#'
#' @param object A `mix_fit` object.
#' @param replicate_by Optional columns defining replicated design points. By default,
#'   mixture components plus process variables are used.
#' @return Data frame containing regression, residual, lack-of-fit, pure-error, and total components.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 3, seed = 8)
#' fit <- mix_fit("response", d, sp, model = "scheffe_quadratic")
#' mix_anova(fit)
#' @export
mix_anova <- function(object, replicate_by = NULL) {
  if (!inherits(object,"mix_fit")) .mix_stop("mix_anova currently expects a mix_fit object.")
  y <- object$y; res <- y-object$fitted; n <- length(y); p <- ncol(object$X)
  if (object$engine != "lm") {
    return(data.frame(source=c("Residual deviance"),df=object$df_residual,
                      SS=object$fit$deviance,MS=NA_real_,F=NA_real_,p_value=NA_real_))
  }
  sse <- sum(res^2); sst <- sum((y-mean(y))^2); ssr <- sst-sse
  replicate_by <- replicate_by %||% unique(c(object$spec$components,object$process))
  replicate_by <- intersect(replicate_by,names(object$data))
  if (length(replicate_by)) {
    key <- interaction(object$data[replicate_by],drop=TRUE,lex.order=TRUE)
    group_mean <- ave(y,key,FUN=mean)
    sspe <- sum((y-group_mean)^2)
    g <- nlevels(key); dfpe <- n-g
  } else { sspe <- NA_real_; dfpe <- 0L }
  dfres <- n-p
  sslof <- if (dfpe>0) sse-sspe else NA_real_
  dflof <- if (dfpe>0) dfres-dfpe else NA_integer_
  mspe <- if (dfpe>0) sspe/dfpe else NA_real_
  mslof <- if (!is.na(dflof) && dflof>0) sslof/dflof else NA_real_
  Fv <- if (is.finite(mspe) && mspe>0 && is.finite(mslof)) mslof/mspe else NA_real_
  pv <- if (is.finite(Fv) && dflof>0 && dfpe>0) stats::pf(Fv,dflof,dfpe,lower.tail=FALSE) else NA_real_
  data.frame(
    source=c("Regression","Residual","Lack of fit","Pure error","Total"),
    df=c(p,dfres,dflof,dfpe,n-1L),
    SS=c(ssr,sse,sslof,sspe,sst),
    MS=c(if(p>0)ssr/p else NA,sse/dfres,mslof,mspe,NA),
    F=c(NA,NA,Fv,NA,NA),p_value=c(NA,NA,pv,NA,NA),check.names=FALSE
  )
}

#' Diagnose a fitted mixture model
#'
#' @param object A `mix_fit` object.
#' @return A `mix_diagnostics` object with observation-level and matrix diagnostics.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 2, seed = 9)
#' fit <- mix_fit("response", d, sp)
#' mix_diagnose(fit)
#' @export
mix_diagnose <- function(object) {
  if (!inherits(object,"mix_fit")) .mix_stop("mix_diagnose expects a mix_fit object.")
  X <- object$X; w <- object$working_weights %||% rep(1,nrow(X))
  M1 <- .mix_safe_inverse(crossprod(X*sqrt(w)))
  Hdiag <- rowSums((X %*% M1) * X) * w
  r <- residuals(object,"pearson")
  p <- ncol(X)
  cook <- (r^2/pmax(object$dispersion,1e-12)) * Hdiag / pmax(p*(1-Hdiag)^2,1e-12)
  sv <- svd(X)$d
  cond <- max(sv)/pmax(min(sv),.Machine$double.eps)
  corr <- suppressWarnings(stats::cov2cor(object$vcov))
  obs <- data.frame(.row=seq_along(r),fitted=object$fitted,residual=r,
                    leverage=Hdiag,cooks_distance=cook)
  out <- list(observations=obs,condition_number=cond,singular_values=sv,
              coefficient_correlation=corr,rank=qr(X)$rank,p=ncol(X),n=nrow(X),
              warnings=character())
  if (cond > 1e4) out$warnings <- c(out$warnings,"The model matrix is strongly ill-conditioned; inspect the constrained region, parameterization, or design augmentation.")
  class(out)<-"mix_diagnostics"; out
}

#' Compare fitted mixture models without selecting solely by one metric
#'
#' @param ... Two or more `mix_fit` objects.
#' @param criterion Optional ordering criterion: `AIC`, `BIC`, `RMSE`, or `PRESS`.
#' @return Comparison table with model size, fit, prediction, and conditioning metrics.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 2, seed = 10)
#' f1 <- mix_fit("response", d, sp, model = "scheffe_linear")
#' f2 <- mix_fit("response", d, sp, model = "scheffe_quadratic")
#' mix_compare(f1, f2, criterion = "PRESS")
#' @export
mix_compare <- function(..., criterion = NULL) {
  fits <- list(...)
  if (!length(fits) || any(!vapply(fits,inherits,logical(1),"mix_fit"))) .mix_stop("All inputs must be mix_fit objects.")
  tab <- do.call(rbind,lapply(seq_along(fits),function(i){
    f<-fits[[i]]; n<-length(f$y); p<-length(f$coefficients); rss<-sum((f$y-f$fitted)^2)
    rmse<-sqrt(mean((f$y-f$fitted)^2)); dg<-mix_diagnose(f)
    h<-dg$observations$leverage
    press<-sum(((f$y-f$fitted)/pmax(1-h,1e-8))^2)
    aic<-if(f$engine=="lm" && rss>0) n*log(rss/n)+2*p else tryCatch(stats::AIC(f$fit),error=function(e)NA_real_)
    bic<-if(f$engine=="lm" && rss>0) n*log(rss/n)+log(n)*p else NA_real_
    data.frame(id=i,model=f$model,engine=f$engine,n=n,p=p,AIC=aic,BIC=bic,RMSE=rmse,PRESS=press,condition_number=dg$condition_number)
  }))
  if (!is.null(criterion)) {
    criterion<-match.arg(criterion,c("AIC","BIC","RMSE","PRESS")); tab<-tab[order(tab[[criterion]]),,drop=FALSE]
  }
  rownames(tab)<-NULL; tab
}

#' @export
print.mix_diagnostics <- function(x, ...) {
  cat("<mix_diagnostics>\n")
  cat(" Rank:",x$rank,"/",x$p," Condition number:",format(x$condition_number,digits=5),"\n")
  if(length(x$warnings)) cat(paste0(" Warning: ",x$warnings,"\n"))
  print(utils::head(x$observations,10L),row.names=FALSE)
  invisible(x)
}
