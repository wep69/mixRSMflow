.mix_extract_data <- function(data) {
  if (inherits(data, "mix_design")) data$data else as.data.frame(data, check.names = FALSE)
}

.mix_response_name <- function(response) {
  if (is.character(response) && length(response) == 1L) return(response)
  deparse(substitute(response))
}

.mix_fit_core <- function(y, X, family = stats::gaussian(), weights = NULL, offset = NULL) {
  n <- length(y); p <- ncol(X)
  if (is.null(weights)) weights <- rep(1, n)
  if (family$family == "gaussian" && family$link == "identity") {
    fit <- stats::lm.wfit(X, y, w = weights, offset = offset)
    if (fit$rank < p) .mix_stop("The requested model matrix is rank deficient. Reduce the model or augment the design.")
    coef <- fit$coefficients
    fitted <- fit$fitted.values
    resid <- fit$residuals
    dfres <- n - fit$rank
    rss <- sum(weights * resid^2)
    sigma2 <- if (dfres > 0) rss / dfres else NA_real_
    bread <- .mix_safe_inverse(crossprod(X * sqrt(weights)))
    vc <- sigma2 * bread
    list(engine = "lm", fit = fit, coefficients = coef, fitted = fitted,
         residuals = resid, df_residual = dfres, dispersion = sigma2,
         vcov = vc, weights = weights, working_weights = weights,
         logLik = if (dfres > 0 && rss > 0) -0.5*n*(log(2*pi)+1+log(rss/n)) else NA_real_)
  } else {
    fit <- stats::glm.fit(X, y, family = family, weights = weights, offset = offset)
    if (fit$rank < p) .mix_stop("The requested GLM model matrix is rank deficient. Reduce the model or augment the design.")
    phi <- if (family$family %in% c("poisson","binomial")) 1 else sum(fit$weights * fit$residuals^2) / fit$df.residual
    bread <- .mix_safe_inverse(crossprod(X * sqrt(fit$weights)))
    vc <- phi * bread
    list(engine = "glm", fit = fit, coefficients = fit$coefficients,
         fitted = fit$fitted.values, residuals = fit$residuals,
         df_residual = fit$df.residual, dispersion = phi, vcov = vc,
         weights = weights, working_weights = fit$weights,
         logLik = NA_real_)
  }
}

#' Fit classical and generalized mixture response-surface models
#'
#' @param response Response column name.
#' @param data Data frame or `mix_design` containing observed responses.
#' @param spec Mixture specification. If `data` is a `mix_design`, its specification is used by default.
#' @param model Mixture basis passed to [mix_basis()].
#' @param family A GLM family; Gaussian identity is the classical default.
#' @param weights Optional observation weights or column name.
#' @param offset Optional offset vector or column name.
#' @param process Optional process-variable names.
#' @param process_order Polynomial order for process variables.
#' @param mixture_process Include mixture by process interactions.
#' @param terms Optional basis-column names or indices to retain. This supports audited model reduction while preserving the original model family.
#' @param ... Additional basis arguments such as `slack_component`, `reference`, or `denominator`.
#' @return A `mix_fit` object.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 2, seed = 4)
#' fit <- mix_fit("response", d, sp, model = "scheffe_quadratic")
#' coef(fit)
#' @export
mix_fit <- function(response, data, spec = NULL,
                    model = "scheffe_quadratic", family = stats::gaussian(),
                    weights = NULL, offset = NULL, process = NULL,
                    process_order = 2L, mixture_process = FALSE, terms = NULL, ...) {
  if (inherits(data, "mix_design")) {
    spec <- spec %||% data$spec
    dat <- data$data
    design <- data
  } else { dat <- as.data.frame(data, check.names = FALSE); design <- NULL }
  if (is.null(spec) || !inherits(spec, "mix_spec")) .mix_stop("A mix_spec is required.")
  response <- if (is.character(response)) response[[1L]] else deparse(substitute(response))
  if (!response %in% names(dat)) .mix_stop("Response column not found: ", response)
  y <- dat[[response]]
  if (!is.numeric(y) || any(!is.finite(y))) .mix_stop("The response must be finite numeric data.")
  w <- if (is.character(weights)) dat[[weights]] else weights
  off <- if (is.character(offset)) dat[[offset]] else offset
  Xfull <- mix_basis(dat, spec, model = model, process = process,
                     process_order = process_order, mixture_process = mixture_process, ...)
  if (!is.null(terms)) {
    if (is.numeric(terms)) {
      terms <- as.integer(terms)
      if (any(terms < 1L | terms > ncol(Xfull))) .mix_stop("terms contains invalid column indices.")
      active <- colnames(Xfull)[terms]
    } else {
      active <- as.character(terms)
      missing_terms <- setdiff(active, colnames(Xfull))
      if (length(missing_terms)) .mix_stop("Unknown basis terms: ", paste(missing_terms, collapse = ", "))
    }
    X <- Xfull[, unique(active), drop = FALSE]
  } else X <- Xfull
  core <- .mix_fit_core(y, X, family = family, weights = w, offset = off)
  names(core$coefficients) <- colnames(X)
  rownames(core$vcov) <- colnames(core$vcov) <- colnames(X)
  out <- c(core, list(
    call = match.call(), data = dat, response = response, y = y, X = X,
    spec = spec, design = design, model = model, family = family,
    process = process, process_order = process_order,
    mixture_process = mixture_process, basis_args = list(...),
    active_terms = colnames(X), full_basis_names = colnames(Xfull),
    offset = off,
    audit = list(.mix_audit("mix_fit", list(response=response, model=model,
                                             engine=core$engine, n=nrow(dat), p=ncol(X))))
  ))
  class(out) <- "mix_fit"
  out
}

#' Fit a mixed-effects mixture model through lme4
#'
#' This adapter preserves the mixture basis while delegating mixed-model
#' estimation to `lme4::lmer` or `lme4::glmer`. It is intended for block,
#' split-plot, and related hierarchical designs.
#'
#' @param response Response column name.
#' @param data Data frame or `mix_design`.
#' @param spec Mixture specification.
#' @param random Random-effects term such as `(1|block)`.
#' @param model Mixture basis.
#' @param family `NULL` for `lmer`, otherwise a GLM family for `glmer`.
#' @param process Optional process variables.
#' @param mixture_process Include mixture-process interactions.
#' @param terms Optional mixture-basis terms to retain.
#' @param ... Additional arguments passed to [mix_basis()].
#' @return A `mix_fit_mixed` object.
#' @examples
#' if (requireNamespace("lme4", quietly = TRUE)) {
#'   sp <- mix_spec(c("A", "B", "C"))
#'   d <- mix_demo_data("mixture", n_rep = 3, seed = 5)
#'   d$block <- factor(rep(seq_len(3), length.out = nrow(d)))
#'   mm <- mix_fit_mixed("response", d, sp, random = "(1|block)", model = "scheffe_linear")
#'   mm
#' }
#' @export
mix_fit_mixed <- function(response, data, spec = NULL, random,
                          model = "scheffe_quadratic", family = NULL,
                          process = NULL, mixture_process = FALSE, terms = NULL, ...) {
  if (!requireNamespace("lme4", quietly = TRUE)) .mix_stop("Package 'lme4' is required for mix_fit_mixed().")
  dat <- .mix_extract_data(data)
  if (inherits(data,"mix_design")) spec <- spec %||% data$spec
  if (is.null(spec)) .mix_stop("A mix_spec is required.")
  response <- if (is.character(response)) response[[1L]] else deparse(substitute(response))
  if (!response %in% names(dat)) .mix_stop("Response column not found.")
  Xfull <- mix_basis(dat, spec, model=model, process=process, mixture_process=mixture_process, ...)
  if (!is.null(terms)) {
    active <- if (is.numeric(terms)) colnames(Xfull)[as.integer(terms)] else as.character(terms)
    if (anyNA(active) || length(setdiff(active, colnames(Xfull)))) .mix_stop("Invalid terms for mix_fit_mixed().")
    X <- Xfull[, unique(active), drop = FALSE]
  } else X <- Xfull
  safe <- paste0(".m", seq_len(ncol(X)))
  aug <- dat
  for (j in seq_len(ncol(X))) aug[[safe[j]]] <- X[,j]
  rhs <- paste(safe, collapse = " + ")
  f <- stats::as.formula(paste(response, "~ 0 +", rhs, "+", random))
  fit <- if (is.null(family)) lme4::lmer(f, data=aug) else lme4::glmer(f, data=aug, family=family)
  out <- list(call=match.call(), fit=fit, data=dat, augmented_data=aug, response=response,
              spec=spec, model=model, process=process, mixture_process=mixture_process,
              basis_args=list(...), basis_names=colnames(X), full_basis_names=colnames(Xfull), safe_names=safe,
              random=random, family=family,
              audit=list(.mix_audit("mix_fit_mixed",list(engine=class(fit)[1L],random=random))))
  class(out) <- "mix_fit_mixed"
  out
}

#' Fit a Bayesian mixture model through brms
#'
#' @param response Response column name.
#' @param data Data frame or `mix_design`.
#' @param spec Mixture specification.
#' @param model Mixture basis.
#' @param family A `brms` family.
#' @param random Optional brms-compatible random-effects expression without the response.
#' @param prior Optional brms prior specification.
#' @param process Optional process variables.
#' @param mixture_process Include mixture-process interactions.
#' @param terms Optional mixture-basis terms to retain.
#' @param ... Additional arguments passed to [mix_basis()].
#' @param brms_args Named list of additional arguments passed to `brms::brm`.
#' @return A `mix_fit_bayes` object.
#' @examples
#' if (FALSE) { # Requires brms and a configured Stan toolchain
#'   sp <- mix_spec(c("A", "B", "C"))
#'   d <- mix_demo_data("mixture", n_rep = 2, seed = 6)
#'   bf <- mix_fit_bayes("response", d, sp, model = "scheffe_quadratic")
#' }
#' @export
mix_fit_bayes <- function(response, data, spec = NULL, model="scheffe_quadratic",
                          family = NULL, random = NULL, prior = NULL,
                          process = NULL, mixture_process = FALSE, terms = NULL, ...,
                          brms_args = list()) {
  if (!requireNamespace("brms", quietly = TRUE)) .mix_stop("Package 'brms' is required for mix_fit_bayes().")
  family <- family %||% brms::brmsfamily("gaussian")
  dat <- .mix_extract_data(data)
  if (inherits(data,"mix_design")) spec <- spec %||% data$spec
  if (is.null(spec)) .mix_stop("A mix_spec is required.")
  response <- if (is.character(response)) response[[1L]] else deparse(substitute(response))
  Xfull <- mix_basis(dat,spec,model=model,process=process,mixture_process=mixture_process,...)
  if (!is.null(terms)) {
    active <- if (is.numeric(terms)) colnames(Xfull)[as.integer(terms)] else as.character(terms)
    if (anyNA(active) || length(setdiff(active, colnames(Xfull)))) .mix_stop("Invalid terms for mix_fit_bayes().")
    X <- Xfull[, unique(active), drop = FALSE]
  } else X <- Xfull
  safe <- paste0(".m",seq_len(ncol(X))); aug <- dat
  for (j in seq_len(ncol(X))) aug[[safe[j]]] <- X[,j]
  rhs <- paste(safe,collapse=" + ")
  if (!is.null(random)) rhs <- paste(rhs,random,sep=" + ")
  f <- stats::as.formula(paste(response,"~ 0 +",rhs))
  args <- c(list(formula=f,data=aug,family=family), if(!is.null(prior)) list(prior=prior) else list(), brms_args)
  fit <- do.call(brms::brm,args)
  out <- list(call=match.call(),fit=fit,data=dat,augmented_data=aug,response=response,
              spec=spec,model=model,process=process,mixture_process=mixture_process,
              basis_args=list(...),basis_names=colnames(X),full_basis_names=colnames(Xfull),safe_names=safe,
              random=random,family=family,
              audit=list(.mix_audit("mix_fit_bayes",list(engine="brms"))))
  class(out)<-"mix_fit_bayes"; out
}

#' @export
coef.mix_fit <- function(object, ...) object$coefficients

#' @export
vcov.mix_fit <- function(object, ...) object$vcov

#' @export
fitted.mix_fit <- function(object, ...) object$fitted

#' @export
residuals.mix_fit <- function(object, type = c("response","pearson"), ...) {
  type <- match.arg(type)
  if (object$engine == "lm" || type == "response") return(object$y - object$fitted)
  mu <- object$fitted
  v <- object$family$variance(mu)
  (object$y-mu)/sqrt(pmax(v, .Machine$double.eps))
}

#' @export
print.mix_fit <- function(x, ...) {
  cat("<mix_fit>\n")
  cat(" Response:",x$response,"\n Model:",x$model,"\n Engine:",x$engine,"\n")
  cat(" Observations:",length(x$y)," Parameters:",length(x$coefficients),"\n")
  print(round(x$coefficients,6))
  invisible(x)
}

#' @export
summary.mix_fit <- function(object, ...) {
  se <- sqrt(diag(object$vcov))
  stat <- object$coefficients / se
  if (object$engine == "lm") {
    p <- 2*stats::pt(abs(stat), df=object$df_residual, lower.tail=FALSE)
  } else p <- 2*stats::pnorm(abs(stat), lower.tail=FALSE)
  tab <- data.frame(estimate=object$coefficients,std_error=se,statistic=stat,p_value=p,check.names=FALSE)
  out <- list(call=object$call, coefficients=tab, dispersion=object$dispersion,
              df_residual=object$df_residual, anova=try(mix_anova(object),silent=TRUE))
  class(out) <- "summary.mix_fit"; out
}

#' @export
print.summary.mix_fit <- function(x, ...) {
  cat("Mixture model summary\n\n")
  print(x$coefficients)
  cat("\nResidual df:",x$df_residual," Dispersion:",format(x$dispersion),"\n")
  if (!inherits(x$anova,"try-error")) { cat("\nANOVA / lack-of-fit decomposition:\n"); print(x$anova) }
  invisible(x)
}
