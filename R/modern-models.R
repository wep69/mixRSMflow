# General blending models and integrated mean-square error tools.

.mix_gbm_terms <- function(Xc, spec, gbm_terms = NULL) {
  comps <- spec$components
  terms <- lapply(seq_len(spec$q), function(i) .mix_term(Xc[,i], comps[i]))
  if (is.null(gbm_terms) || !length(gbm_terms)) return(.mix_bind_terms(terms))
  for (r in seq_along(gbm_terms)) {
    tr <- gbm_terms[[r]]
    ids <- tr$components
    if (is.numeric(ids)) ids <- comps[as.integer(ids)]
    ids <- as.character(ids)
    if (!length(ids) %in% c(2L,3L) || any(!ids %in% comps))
      .mix_stop("Each gbm_terms entry must identify two or three mixture components.")
    idx <- match(ids, comps); Z <- Xc[,idx,drop=FALSE]
    den <- rowSums(Z)
    s <- as.numeric(tr$s %||% 1)
    g <- as.numeric(tr$g %||% rep(1,length(ids)))
    if (length(g)==1L) g <- rep(g,length(ids))
    if (length(g)!=length(ids) || any(!is.finite(g)) || !is.finite(s))
      .mix_stop("GBM exponents g and s must be finite and have compatible lengths.")
    if (length(ids)==2L) {
      h <- as.numeric(tr$h %||% 0.5)
      if (length(h)!=1L || !is.finite(h) || h < 0 || h > 1)
        .mix_stop("A binary GBM term requires scalar h in [0,1].")
      ex <- c(g[1]*h, g[2]*(1-h))
    } else {
      h <- as.numeric(tr$h %||% c(1/3,1/3))
      if (length(h)!=2L || any(!is.finite(h)) || any(h<0) || sum(h)>1)
        .mix_stop("A ternary GBM term requires h=c(h1,h2), h1,h2>=0 and h1+h2<=1.")
      ex <- c(g[1]*h[1], g[2]*h[2], g[3]*(1-sum(h)))
    }
    prop <- matrix(0,nrow(Z),ncol(Z)); nz <- den > 0
    prop[nz,] <- Z[nz,,drop=FALSE] / den[nz]
    # 0^0 is treated as one for the limiting monomial convention.
    v <- rep(1,nrow(Z))
    for (j in seq_len(ncol(Z))) if (ex[j] != 0) v <- v * prop[,j]^ex[j]
    v <- v * den^s
    label <- tr$label %||% paste0("GBM:",paste(ids,collapse=":"),"[g=",paste(signif(g,5),collapse=","),";h=",paste(signif(h,5),collapse=","),";s=",signif(s,5),"]")
    terms[[length(terms)+1L]] <- .mix_term(v,label)
  }
  .mix_bind_terms(terms)
}

#' Define one general blending model term
#'
#' Creates a validated term specification for the general blending model (GBM)
#' parameterization of Brown, Donev and Bissett. The nonlinear exponents are
#' fixed by this specification; the associated regression coefficient is then
#' estimated by [mix_fit()].
#'
#' @param components Two or three component names (or positions).
#' @param g Component-specific non-negative/flexible power parameters.
#' @param h For a binary term, one allocation parameter. For a ternary term,
#'   two allocation parameters whose sum is at most one.
#' @param s Homogeneity/order exponent applied to the component subtotal.
#' @param label Optional basis-column label.
#' @return A list suitable for the `gbm_terms` argument of [mix_basis()] or [mix_fit()].
#' @references Brown, L., Donev, A. N., & Bissett, A. C. (2015).
#' General Blending Models for Data From Mixture Experiments. Technometrics,
#' 57, 449-456. doi:10.1080/00401706.2014.947003.
#' @examples
#' term <- mix_gbm_term(c("A", "B"), g = c(1, 1), h = 0.5, s = 1)
#' term
#' @export
mix_gbm_term <- function(components, g = 1, h = NULL, s = 1, label = NULL) {
  components <- components
  if (!length(components) %in% c(2L,3L)) .mix_stop("components must identify two or three components.")
  g <- as.numeric(g); if (length(g)==1L) g <- rep(g,length(components))
  if (length(g)!=length(components) || any(!is.finite(g))) .mix_stop("g has incompatible length or non-finite values.")
  if (is.null(h)) h <- if (length(components)==2L) 0.5 else c(1/3,1/3)
  list(components=components,g=g,h=as.numeric(h),s=as.numeric(s),label=label)
}

#' Integrated mean-square prediction error under an explicit larger model
#'
#' Evaluates the Box-Draper variance-plus-bias decomposition for a fitted model
#' relative to an explicitly specified larger model. It does not silently guess
#' omitted-term coefficients. Bias can be evaluated at supplied coefficients or
#' integrated with respect to a supplied covariance/prior matrix.
#'
#' @param design A `mix_design` or design data frame.
#' @param spec A `mix_spec` when `design` is a data frame.
#' @param fitted_model Basis name used for the fitted model.
#' @param true_model Larger basis name defining possible omitted terms.
#' @param evaluation Optional feasible evaluation data. If `NULL`, a grid is generated.
#' @param beta_omitted Optional named or ordered coefficient vector for omitted terms.
#' @param beta_cov Optional covariance matrix for zero-mean omitted coefficients. This
#'   yields expected integrated squared bias.
#' @param sigma2 Error variance multiplying the integrated prediction variance.
#' @param resolution Evaluation-grid resolution.
#' @param fitted_args,true_args Named lists passed to [mix_basis()] for each model.
#' @return A `mix_imse` object with variance, bias and total IMSE components.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_design(sp, "simplex_lattice", degree = 3)
#' im <- mix_imse(d, fitted_model = "scheffe_quadratic",
#'                true_model = "scheffe_special_cubic", beta_omitted = c(`A:B:C` = 2),
#'                sigma2 = .25, resolution = 8)
#' im
#' @export
mix_imse <- function(design, spec = NULL, fitted_model = "scheffe_quadratic",
                     true_model = "scheffe_special_cubic", evaluation = NULL,
                     beta_omitted = NULL, beta_cov = NULL, sigma2 = 1,
                     resolution = 18L, fitted_args = list(), true_args = list()) {
  dat <- .mix_extract_data(design)
  if (inherits(design,"mix_design")) spec <- spec %||% design$spec
  if (is.null(spec)) .mix_stop("A mix_spec is required.")
  if (!is.finite(sigma2) || sigma2 < 0) .mix_stop("sigma2 must be non-negative and finite.")
  Xf <- do.call(mix_basis,c(list(data=dat,spec=spec,model=fitted_model),fitted_args))
  Xt <- do.call(mix_basis,c(list(data=dat,spec=spec,model=true_model),true_args))
  if (anyDuplicated(colnames(Xf)) || anyDuplicated(colnames(Xt))) .mix_stop("Basis column names must be unique for IMSE evaluation.")
  if (!all(colnames(Xf) %in% colnames(Xt))) .mix_stop("The fitted basis must be nested within the stated true-model basis by column name.")
  omitted <- setdiff(colnames(Xt),colnames(Xf))
  M <- .mix_safe_inverse(crossprod(Xf))
  if (anyNA(M)) .mix_stop("The fitted design matrix is singular; IMSE is not estimable for this design.")
  E <- evaluation
  if (is.null(E)) E <- .mix_candidate_grid(spec,resolution=resolution,random_n=1000L,seed=93L)
  E <- as.data.frame(E,check.names=FALSE)
  Ff <- do.call(mix_basis,c(list(data=E,spec=spec,model=fitted_model),fitted_args))
  Ft <- do.call(mix_basis,c(list(data=E,spec=spec,model=true_model),true_args))
  Ff <- Ff[,colnames(Xf),drop=FALSE]
  integrated_variance <- sigma2 * mean(rowSums((Ff %*% M)*Ff))
  if (!length(omitted)) {
    B <- matrix(0,nrow(E),0L); ibias <- 0; bias_mode <- "none (models identical)"
  } else {
    Xo <- Xt[,omitted,drop=FALSE]; Fo <- Ft[,omitted,drop=FALSE]
    B <- Fo - Ff %*% M %*% crossprod(Xf,Xo)
    if (!is.null(beta_omitted)) {
      b <- as.numeric(beta_omitted)
      if (!is.null(names(beta_omitted))) b <- as.numeric(beta_omitted[omitted])
      if (length(b)!=length(omitted) || any(!is.finite(b))) .mix_stop("beta_omitted must contain one finite coefficient for each omitted term.")
      ibias <- mean(drop(B %*% b)^2); bias_mode <- "fixed omitted coefficients"
    } else if (!is.null(beta_cov)) {
      K <- as.matrix(beta_cov)
      if (!all(dim(K)==length(omitted)) || any(!is.finite(K))) .mix_stop("beta_cov must be a finite square covariance matrix for omitted terms.")
      if (!is.null(rownames(K)) && all(omitted %in% rownames(K))) K <- K[omitted,omitted,drop=FALSE]
      ev <- eigen((K+t(K))/2,symmetric=TRUE,only.values=TRUE)$values
      if (min(ev) < -1e-8) .mix_stop("beta_cov must be positive semidefinite.")
      ibias <- mean(rowSums((B %*% K)*B)); bias_mode <- "expected squared bias under beta_cov"
    } else {
      ibias <- NA_real_; bias_mode <- "not evaluated; supply beta_omitted or beta_cov"
    }
  }
  total <- if (is.na(ibias)) NA_real_ else integrated_variance + ibias
  out <- list(imse=total,integrated_variance=integrated_variance,integrated_squared_bias=ibias,
              bias_mode=bias_mode,omitted_terms=omitted,n_evaluation=nrow(E),sigma2=sigma2,
              fitted_model=fitted_model,true_model=true_model,spec=spec)
  class(out) <- "mix_imse"; out
}

#' @export
print.mix_imse <- function(x, ...) {
  cat("Integrated MSE assessment\n")
  cat("  Fitted model:",x$fitted_model,"\n  Reference larger model:",x$true_model,"\n")
  cat("  Integrated variance:",format(x$integrated_variance,digits=6),"\n")
  cat("  Integrated squared bias:",if(is.na(x$integrated_squared_bias))"not evaluated" else format(x$integrated_squared_bias,digits=6),"\n")
  cat("  IMSE:",if(is.na(x$imse))"not evaluated" else format(x$imse,digits=6),"\n")
  invisible(x)
}
