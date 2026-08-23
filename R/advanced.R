#' Convert between original proportions and lower/upper pseudocomponents
#'
#' Lower pseudocomponents are defined by z_i = (x_i - L_i)/(T - sum L),
#' while upper pseudocomponents are defined by u_i = (U_i - x_i)/(sum U - T).
#' Both transformations preserve a unit-sum simplex after scaling.
#'
#' @param x Data frame, matrix, or numeric vector.
#' @param spec A `mix_spec` object.
#' @param type `L` for lower-bound pseudocomponents or `U` for upper-bound pseudocomponents.
#' @param inverse If `TRUE`, convert pseudocomponents back to original proportions.
#' @return A data frame with one column per mixture component.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"), lower = c(.1, .1, .1), upper = c(.8, .8, .8))
#' x <- data.frame(A = .2, B = .3, C = .5)
#' z <- mix_pseudocomponents(x, sp, type = "L")
#' mix_pseudocomponents(z, sp, type = "L", inverse = TRUE)
#' @export
mix_pseudocomponents <- function(x, spec, type = c("L", "U"), inverse = FALSE) {
  stopifnot(inherits(spec, "mix_spec"))
  type <- match.arg(type)
  X <- if (is.vector(x) && !is.list(x)) matrix(as.numeric(x), nrow = 1L) else as.matrix(x)
  if (ncol(X) != spec$q) .mix_stop("x must have one column per mixture component.")
  if (!is.null(colnames(X)) && all(spec$components %in% colnames(X))) X <- X[, spec$components, drop = FALSE]
  if (type == "L") {
    scale <- spec$total - sum(spec$lower)
    if (scale <= spec$tol) .mix_stop("Lower bounds leave no pseudocomponent region.")
    Z <- if (inverse) sweep(X * scale, 2L, spec$lower, "+") else sweep(X, 2L, spec$lower, "-") / scale
  } else {
    scale <- sum(spec$upper) - spec$total
    if (scale <= spec$tol) .mix_stop("Upper bounds leave no U-pseudocomponent region.")
    Z <- if (inverse) sweep(-X * scale, 2L, spec$upper, "+") else sweep(-X, 2L, spec$upper, "+") / scale
  }
  Z <- as.data.frame(Z, check.names = FALSE); names(Z) <- spec$components
  if (inverse) {
    if (any(abs(rowSums(Z) - spec$total) > 100 * spec$tol)) .mix_warn("Back-transformed rows do not sum to the mixture total within tolerance.")
  } else {
    target <- 1
    if (any(abs(rowSums(Z) - target) > 100 * spec$tol)) .mix_warn("Some pseudocomponent rows do not sum to one; verify the original compositions and bounds.")
  }
  Z
}

#' Reparameterize an equivalent Scheffe model with an intercept and slack component
#'
#' For linear and quadratic Scheffe models this function refits the same response
#' space using a slack-variable polynomial. The transformation is useful for
#' teaching, numerical diagnostics, and comparison of coefficient interpretations.
#'
#' @param object A Gaussian or GLM `mix_fit` fitted with `scheffe_linear` or `scheffe_quadratic`.
#' @param slack_component Component to eliminate through the mixture total constraint.
#' @return A new `mix_fit` object with model `slack_linear` or `slack_quadratic`.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 2, seed = 11)
#' fit <- mix_fit("response", d, sp, model = "scheffe_quadratic")
#' slack <- mix_reparameterize(fit, slack_component = "C")
#' slack$reparameterization
#' @export
mix_reparameterize <- function(object, slack_component = NULL) {
  if (!inherits(object, "mix_fit")) .mix_stop("mix_reparameterize expects a mix_fit object.")
  target_model <- switch(object$model,
                         scheffe_linear = "slack_linear",
                         scheffe_quadratic = "slack_quadratic",
                         NULL)
  if (is.null(target_model)) .mix_stop("Exact intercept/slack reparameterization is currently available for linear and quadratic Scheffe models.")
  slack_component <- slack_component %||% tail(object$spec$components, 1L)
  ans <- mix_fit(object$response, object$data, spec = object$spec, model = target_model,
                 family = object$family, weights = object$weights, offset = object$offset,
                 process = object$process, process_order = object$process_order,
                 mixture_process = object$mixture_process, slack_component = slack_component)
  p1 <- mix_predict(object)$.prediction; p2 <- mix_predict(ans)$.prediction
  ans$reparameterization <- list(from = object$model, slack_component = slack_component,
                                 max_abs_fitted_difference = max(abs(p1 - p2)))
  ans$audit <- c(ans$audit, list(.mix_audit("mix_reparameterize", ans$reparameterization)))
  ans
}

#' Diagnose collinearity and estimability in mixture model matrices
#'
#' @param object A `mix_fit`, `mix_design`, numeric matrix, or data frame.
#' @param spec Mixture specification when `object` is a design/data frame.
#' @param model Model basis for a design/data frame.
#' @param tol Numerical rank tolerance.
#' @return A `mix_collinearity` object with singular values, condition indices,
#' coefficient-correlation matrix, variance-decomposition proportions, and recommendations.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_design(sp, "simplex_lattice", degree = 3)
#' mix_collinearity(d, model = "scheffe_quadratic")
#' @export
mix_collinearity <- function(object, spec = NULL, model = "scheffe_quadratic", tol = 1e-10) {
  if (inherits(object, "mix_fit")) {
    X <- object$X; source <- paste0("fit:", object$model)
  } else if (inherits(object, "mix_design")) {
    spec <- spec %||% object$spec; X <- mix_basis(object$data, spec, model = model); source <- paste0("design:", object$type)
  } else if (is.matrix(object)) { X <- object; source <- "matrix"
  } else if (is.data.frame(object)) {
    if (is.null(spec)) .mix_stop("spec is required when object is a data frame.")
    X <- mix_basis(object, spec, model = model); source <- "data"
  } else .mix_stop("Unsupported object for mix_collinearity().")
  X <- as.matrix(X)
  sx <- sqrt(colSums(X^2)); sx[sx <= tol] <- 1
  Z <- sweep(X, 2L, sx, "/")
  sv <- svd(Z)
  rank <- sum(sv$d > max(sv$d) * tol)
  cond_index <- sqrt(max(sv$d^2) / pmax(sv$d^2, .Machine$double.eps))
  names(cond_index) <- paste0("dim", seq_along(cond_index))
  M <- crossprod(Z)
  Mi <- .mix_safe_inverse(M, tol = tol)
  cor_coef <- if (anyNA(Mi)) matrix(NA_real_, ncol(X), ncol(X), dimnames = list(colnames(X), colnames(X))) else stats::cov2cor(Mi)
  # Belsley-style variance-decomposition proportions based on eigenvectors of Z'Z.
  ee <- eigen((M + t(M))/2, symmetric = TRUE)
  lam <- pmax(ee$values, .Machine$double.eps)
  phi <- sweep(ee$vectors^2, 2L, lam, "/")
  vdp <- sweep(phi, 1L, rowSums(phi), "/")
  rownames(vdp) <- colnames(X); colnames(vdp) <- paste0("dim", seq_len(ncol(vdp)))
  max_ci <- max(cond_index[is.finite(cond_index)], na.rm = TRUE)
  severity <- if (rank < ncol(X)) "non-estimable" else if (max_ci >= 100) "severe" else if (max_ci >= 30) "high" else if (max_ci >= 10) "moderate" else "low"
  recommendation <- switch(severity,
    `non-estimable` = "Model matrix is rank deficient. Reduce the model or augment the design before inference.",
    severe = "Severe conditioning: consider design augmentation, reparameterization, or a scientifically defensible reduced model; emphasize prediction uncertainty.",
    high = "High conditioning: inspect correlated terms and prediction-variance diagnostics before interpreting individual coefficients.",
    moderate = "Moderate conditioning: retain diagnostics and sensitivity analyses, especially in constrained regions.",
    low = "No major numerical collinearity signal under the scaled model matrix."
  )
  out <- list(source = source, rank = rank, p = ncol(X), singular_values = sv$d,
              condition_indices = cond_index, max_condition_index = max_ci,
              coefficient_correlation = cor_coef, variance_decomposition = vdp,
              severity = severity, recommendation = recommendation,
              audit = list(.mix_audit("mix_collinearity", list(source = source, severity = severity))))
  class(out) <- "mix_collinearity"; out
}

#' @export
print.mix_collinearity <- function(x, ...) {
  cat("<mix_collinearity>", x$source, "\nRank:", x$rank, "/", x$p,
      " Max condition index:", format(x$max_condition_index, digits = 5),
      " Severity:", x$severity, "\n")
  cat(x$recommendation, "\n")
  invisible(x)
}

.mix_term_parents <- function(term, all_terms) {
  # Conservative hierarchy rule: a complex term can only be retained if all
  # lower-order component terms identifiable from its label remain present.
  if (term %in% c("(Intercept)")) return(character())
  t0 <- sub("\\*.*$", "", term)
  t0 <- gsub("\\^2", "", t0)
  toks <- unique(strsplit(t0, ":", fixed = TRUE)[[1]])
  toks <- toks[!startsWith(toks, "proc") & toks != "H2" & toks != "H3"]
  parents <- intersect(toks, all_terms)
  # Pairwise parent for triple/higher Scheffe terms.
  if (length(toks) >= 3L) {
    cmb <- utils::combn(toks, 2L)
    pairs <- apply(cmb, 2L, function(z) paste(z, collapse = ":"))
    revpairs <- apply(cmb, 2L, function(z) paste(rev(z), collapse = ":"))
    parents <- unique(c(parents, intersect(c(pairs, revpairs), all_terms)))
  }
  parents
}

#' Audited hierarchical model reduction for mixture response surfaces
#'
#' The default hybrid score combines prediction error, numerical conditioning,
#' and parsimony. Term removal is considered only when hierarchy is preserved.
#' No term is removed solely because of a p-value.
#'
#' @param object A `mix_fit` object.
#' @param criterion `hybrid`, `press`, `aic`, or `bic`.
#' @param min_terms Minimum number of retained basis columns.
#' @param max_steps Maximum backward-removal steps.
#' @param protect Terms that may not be removed; component main terms are protected by default.
#' @param tolerance Required fractional score improvement for a removal.
#' @return A `mix_reduction` object containing the selected fit and complete audit path.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 3, seed = 12)
#' fit <- mix_fit("response", d, sp, model = "scheffe_special_cubic")
#' red <- mix_reduce(fit, criterion = "press", max_steps = 2)
#' red$retained_terms
#' @export
mix_reduce <- function(object, criterion = c("hybrid", "press", "aic", "bic"),
                       min_terms = NULL, max_steps = 50L, protect = NULL, tolerance = 1e-4) {
  if (!inherits(object, "mix_fit")) .mix_stop("mix_reduce expects a mix_fit object.")
  criterion <- match.arg(criterion)
  all_terms <- object$full_basis_names %||% colnames(object$X)
  active <- colnames(object$X)
  component_terms <- intersect(object$spec$components, active)
  protect <- unique(c(protect, component_terms, if ("(Intercept)" %in% active) "(Intercept)" else character()))
  min_terms <- as.integer(min_terms %||% length(protect))
  if (min_terms < length(protect)) min_terms <- length(protect)

  # Build the refit call explicitly so basis arguments are preserved.
  refit <- function(terms) {
    args <- c(list(response = object$response, data = object$data, spec = object$spec,
                   model = object$model, family = object$family, weights = object$weights,
                   offset = object$offset, process = object$process,
                   process_order = object$process_order,
                   mixture_process = object$mixture_process, terms = terms), object$basis_args)
    try(do.call(mix_fit, args), silent = TRUE)
  }
  score <- function(fit) {
    d <- mix_diagnose(fit)
    press <- sum((fit$residuals / pmax(1 - d$observations$leverage, 1e-8))^2)
    if (criterion == "press") return(log(pmax(press / length(fit$y), .Machine$double.eps)))
    k <- length(fit$coefficients); n <- length(fit$y)
    rss <- sum(fit$residuals^2)
    aic <- n * log(pmax(rss/n, .Machine$double.eps)) + 2*k
    bic <- n * log(pmax(rss/n, .Machine$double.eps)) + log(n)*k
    if (criterion == "aic") return(aic)
    if (criterion == "bic") return(bic)
    # Auditable package heuristic. PRESS dominates; conditioning and complexity are secondary.
    log(pmax(press/n, .Machine$double.eps)) + 0.05*log1p(d$condition_number) + 2*k/n
  }
  current <- object; current_score <- score(current)
  audit <- data.frame(step = 0L, removed = NA_character_, p = length(active), score = current_score,
                      accepted = TRUE, reason = "initial model", stringsAsFactors = FALSE)
  step <- 0L
  while (length(active) > min_terms && step < as.integer(max_steps)) {
    removable <- setdiff(active, protect)
    if (!length(removable)) break
    candidates <- list(); scores <- numeric(); reasons <- character()
    for (tm in removable) {
      proposed <- setdiff(active, tm)
      # Do not remove a parent required by a remaining term.
      required <- unique(unlist(lapply(proposed, .mix_term_parents, all_terms = all_terms), use.names = FALSE))
      if (tm %in% required) { reasons[tm] <- "hierarchy protected"; next }
      ff <- refit(proposed)
      if (inherits(ff, "try-error")) { reasons[tm] <- "refit failed or rank deficient"; next }
      candidates[[tm]] <- ff; scores[tm] <- score(ff); reasons[tm] <- "candidate"
    }
    if (!length(scores)) break
    best_tm <- names(which.min(scores))[1L]; best_score <- scores[[best_tm]]
    improvement <- (current_score - best_score) / pmax(abs(current_score), 1)
    step <- step + 1L
    accept <- is.finite(improvement) && improvement > tolerance
    audit <- rbind(audit, data.frame(step = step, removed = best_tm,
                                     p = length(active) - as.integer(accept), score = best_score,
                                     accepted = accept,
                                     reason = if (accept) "score improved with hierarchy preserved" else "no material score improvement",
                                     stringsAsFactors = FALSE))
    if (!accept) break
    active <- setdiff(active, best_tm); current <- candidates[[best_tm]]; current_score <- best_score
  }
  out <- list(original = object, selected = current, criterion = criterion,
              retained_terms = active, removed_terms = setdiff(colnames(object$X), active), audit = audit,
              rule = if (criterion == "hybrid") "PRESS + conditioning penalty + parsimony; hierarchical backward search" else paste0("hierarchical backward search using ", criterion))
  class(out) <- "mix_reduction"; out
}

#' @export
print.mix_reduction <- function(x, ...) {
  cat("<mix_reduction> Criterion:", x$criterion, "\nRetained terms:", length(x$retained_terms),
      " Removed:", length(x$removed_terms), "\n")
  if (length(x$removed_terms)) cat("Removed:", paste(x$removed_terms, collapse = ", "), "\n")
  print(x$audit, row.names = FALSE)
  invisible(x)
}

#' Screen component directional effects with uncertainty
#'
#' @param object A `mix_fit` object.
#' @param direction `cox` or `piepel`.
#' @param reference Feasible reference composition; defaults to `spec$center`.
#' @param level Confidence level.
#' @param delta Finite-difference step in path coordinates.
#' @return Data frame of local directional slopes, standard errors, confidence intervals, and p-values.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 2, seed = 13)
#' fit <- mix_fit("response", d, sp)
#' mix_screen(fit, direction = "cox")
#' @export
mix_screen <- function(object, direction = c("cox", "piepel"), reference = NULL,
                       level = 0.95, delta = 1e-5) {
  if (!inherits(object, "mix_fit")) .mix_stop("mix_screen expects a mix_fit object.")
  direction <- match.arg(direction); spec <- object$spec
  ref <- as.numeric(reference %||% spec$center)
  if (!.mix_feasible(ref, spec)) .mix_stop("reference must be feasible.")
  rows <- vector("list", spec$q)
  crit <- if (object$engine == "lm") stats::qt((1+level)/2, object$df_residual) else stats::qnorm((1+level)/2)
  for (i in seq_len(spec$q)) {
    d <- if (direction == "cox") .mix_cox_direction(ref, i, spec) else .mix_piepel_direction(ref, i, spec)
    lim <- .mix_path_limits(ref, d, spec)
    eps <- min(delta, 0.2*min(abs(lim[is.finite(lim) & lim != 0]), na.rm = TRUE))
    if (!is.finite(eps) || eps <= 0) eps <- delta
    plus <- ref + eps*d; minus <- ref - eps*d
    if (!.mix_feasible(plus, spec) || !.mix_feasible(minus, spec)) {
      # one-sided derivative when the reference is on a boundary
      eps <- min(delta, max(0, lim[2]) / 2)
      if (!is.finite(eps) || eps <= 0) { rows[[i]] <- data.frame(component=spec$components[i], slope=NA,se=NA,lower=NA,upper=NA,p_value=NA); next }
      P <- rbind(ref, ref + eps*d); denom <- eps
      sign <- 1
    } else { P <- rbind(minus, plus); denom <- 2*eps; sign <- 1 }
    nd <- as.data.frame(P, check.names = FALSE); names(nd) <- spec$components
    if (length(object$process)) for (nm in object$process) nd[[nm]] <- stats::median(object$data[[nm]], na.rm = TRUE)
    XB <- .mix_new_basis(object, nd)
    contrast <- sign*(XB[nrow(XB),] - XB[1,]) / denom
    est_link <- sum(contrast * object$coefficients)
    se <- sqrt(max(0, drop(t(contrast) %*% object$vcov %*% contrast)))
    # For GLMs this is a link-scale local slope; make scale explicit in output.
    stat <- est_link / se
    p <- if (object$engine == "lm") 2*stats::pt(abs(stat), object$df_residual, lower.tail = FALSE) else 2*stats::pnorm(abs(stat), lower.tail = FALSE)
    rows[[i]] <- data.frame(component = spec$components[i], slope = est_link, se = se,
                            lower = est_link - crit*se, upper = est_link + crit*se,
                            p_value = p, scale = if (object$engine == "lm") "response" else "link")
  }
  do.call(rbind, rows)
}

#' Fit weighted/generalized least-squares mixture models through nlme
#'
#' @param response Response column name.
#' @param data Data frame or `mix_design`.
#' @param spec Mixture specification.
#' @param model Mixture basis.
#' @param process Optional process-variable names.
#' @param mixture_process Include mixture-process interactions.
#' @param correlation Optional `nlme` correlation structure.
#' @param variance Optional `nlme` variance function (e.g. `varIdent`, `varPower`).
#' @param method `REML` or `ML`.
#' @param terms Optional basis terms to retain.
#' @param ... Additional basis arguments.
#' @return A `mix_fit_gls` object.
#' @examples
#' if (requireNamespace("nlme", quietly = TRUE)) {
#'   sp <- mix_spec(c("A", "B", "C"))
#'   d <- mix_demo_data("mixture", n_rep = 2, seed = 7)
#'   gf <- mix_fit_gls("response", d, sp, model = "scheffe_quadratic", method = "ML")
#'   gf
#' }
#' @export
mix_fit_gls <- function(response, data, spec = NULL, model = "scheffe_quadratic",
                        process = NULL, mixture_process = FALSE,
                        correlation = NULL, variance = NULL, method = c("REML", "ML"),
                        terms = NULL, ...) {
  if (!requireNamespace("nlme", quietly = TRUE)) .mix_stop("Package 'nlme' is required for mix_fit_gls().")
  method <- match.arg(method); dat <- .mix_extract_data(data)
  if (inherits(data, "mix_design")) spec <- spec %||% data$spec
  if (is.null(spec)) .mix_stop("A mix_spec is required.")
  response <- if (is.character(response)) response[[1L]] else deparse(substitute(response))
  Xfull <- mix_basis(dat, spec, model = model, process = process, mixture_process = mixture_process, ...)
  if (!is.null(terms)) {
    active <- if (is.numeric(terms)) colnames(Xfull)[as.integer(terms)] else as.character(terms)
    if (anyNA(active) || length(setdiff(active, colnames(Xfull)))) .mix_stop("Invalid terms for mix_fit_gls().")
    X <- Xfull[, unique(active), drop = FALSE]
  } else X <- Xfull
  safe <- paste0(".m", seq_len(ncol(X))); aug <- dat
  for (j in seq_len(ncol(X))) aug[[safe[j]]] <- X[,j]
  f <- stats::as.formula(paste(response, "~ 0 +", paste(safe, collapse = " + ")))
  fit <- nlme::gls(f, data = aug, correlation = correlation, weights = variance, method = method)
  out <- list(call = match.call(), fit = fit, data = dat, augmented_data = aug,
              response = response, spec = spec, model = model, process = process,
              mixture_process = mixture_process, basis_args = list(...),
              basis_names = colnames(X), full_basis_names = colnames(Xfull), safe_names = safe,
              method = method, correlation = correlation, variance = variance,
              audit = list(.mix_audit("mix_fit_gls", list(method = method, correlation = !is.null(correlation), variance = !is.null(variance)))))
  class(out) <- "mix_fit_gls"; out
}

#' Fit a two-region segmented mixture model
#'
#' This implementation fits separate mixture response surfaces on two scientifically
#' specified regions separated by a component threshold. It intentionally does not
#' impose continuity unless a future model-specific constraint is supplied, and the
#' returned object records that limitation explicitly.
#'
#' @param response Response column name.
#' @param data Data frame or `mix_design`.
#' @param spec Mixture specification.
#' @param split_component Component defining the two regions.
#' @param cut Split threshold in original mixture units.
#' @param model_left,model_right Mixture models fitted below/above the threshold.
#' @param family GLM family used by both segments.
#' @param ... Additional arguments passed to `mix_fit`.
#' @return A `mix_segmented_fit` object.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 3, seed = 14)
#' sf <- mix_segmented_fit("response", d, sp, split_component = "A", cut = .3,
#'                         model_left = "scheffe_linear", model_right = "scheffe_linear")
#' sf
#' @export
mix_segmented_fit <- function(response, data, spec = NULL, split_component, cut,
                              model_left = "scheffe_quadratic", model_right = model_left,
                              family = stats::gaussian(), ...) {
  dat <- .mix_extract_data(data); if (inherits(data, "mix_design")) spec <- spec %||% data$spec
  if (is.null(spec)) .mix_stop("A mix_spec is required.")
  if (!split_component %in% spec$components) .mix_stop("Unknown split_component.")
  if (!is.finite(cut)) .mix_stop("cut must be finite.")
  left <- dat[[split_component]] <= cut; right <- !left
  if (sum(left) < spec$q || sum(right) < spec$q) .mix_stop("Both segments need enough observations to estimate a mixture model.")
  f1 <- mix_fit(response, dat[left,,drop=FALSE], spec = spec, model = model_left, family = family, ...)
  f2 <- mix_fit(response, dat[right,,drop=FALSE], spec = spec, model = model_right, family = family, ...)
  out <- list(call = match.call(), response = if(is.character(response))response[[1L]] else deparse(substitute(response)),
              data = dat, spec = spec, split_component = split_component, cut = cut,
              left = f1, right = f2, continuity_constrained = FALSE,
              limitation = "Piecewise fits are independent at the boundary; continuity is not imposed.",
              audit = list(.mix_audit("mix_segmented_fit", list(split_component = split_component, cut = cut))))
  class(out) <- "mix_segmented_fit"; out
}

#' Predict from a segmented mixture model
#' @param object A `mix_segmented_fit`.
#' @param newdata New data.
#' @param interval Prediction interval type passed to `mix_predict`.
#' @param level Confidence level.
#' @return Predictions in original row order.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("mixture", n_rep = 3, seed = 15)
#' sf <- mix_segmented_fit("response", d, sp, split_component = "A", cut = .3,
#'                         model_left = "scheffe_linear", model_right = "scheffe_linear")
#' head(mix_predict_segmented(sf))
#' @export
mix_predict_segmented <- function(object, newdata = NULL, interval = c("none", "confidence", "prediction"), level = 0.95) {
  if (!inherits(object, "mix_segmented_fit")) .mix_stop("object must be a mix_segmented_fit.")
  interval <- match.arg(interval); nd <- newdata %||% object$data
  left <- nd[[object$split_component]] <= object$cut
  pieces <- vector("list", 2L)
  if (any(left)) { a <- mix_predict(object$left, nd[left,,drop=FALSE], interval = interval, level = level); a$.row <- which(left); pieces[[1]] <- a }
  if (any(!left)) { a <- mix_predict(object$right, nd[!left,,drop=FALSE], interval = interval, level = level); a$.row <- which(!left); pieces[[2]] <- a }
  out <- do.call(rbind, pieces[!vapply(pieces, is.null, logical(1))]); out <- out[order(out$.row),,drop=FALSE]; out$.row <- NULL; rownames(out) <- NULL; out
}

#' Multiresponse prediction biplot over the feasible mixture region
#'
#' @param object A `mix_multi_fit` object.
#' @param resolution Candidate-grid resolution.
#' @param scale Standardize responses before PCA.
#' @param plot If `TRUE`, return a ggplot biplot as well.
#' @return A `mix_biplot` object containing PCA scores, loadings, candidate compositions, and optional plot.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_demo_data("multiresponse", n_rep = 2, seed = 16)
#' mf <- mix_multi_fit(c("quality", "stability"), d, sp, model = "scheffe_quadratic")
#' bp <- mix_biplot(mf, resolution = 8, plot = FALSE)
#' bp$loadings
#' @export
mix_biplot <- function(object, resolution = 20L, scale = TRUE, plot = TRUE) {
  if (!inherits(object, "mix_multi_fit")) .mix_stop("mix_biplot expects a mix_multi_fit object.")
  spec <- object$spec; cand <- .mix_candidate_grid(spec, resolution, 2000L, 91L)
  Y <- sapply(object$fits, function(f) mix_predict(f, cand)$.prediction)
  pc <- stats::prcomp(Y, center = TRUE, scale. = scale)
  scores <- as.data.frame(pc$x[,1:min(2,ncol(pc$x)),drop=FALSE]); names(scores) <- paste0("PC", seq_len(ncol(scores)))
  load <- as.data.frame(pc$rotation[,1:min(2,ncol(pc$rotation)),drop=FALSE]); names(load) <- paste0("PC", seq_len(ncol(load))); load$response <- rownames(load)
  p <- NULL
  if (isTRUE(plot)) {
    if (!requireNamespace("ggplot2", quietly = TRUE)) .mix_stop("Package 'ggplot2' is required for plot=TRUE.")
    if (ncol(scores) < 2L) .mix_stop("At least two principal components are required for a biplot.")
    mult <- 0.8 * min(diff(range(scores$PC1)), diff(range(scores$PC2))) / pmax(max(sqrt(load$PC1^2 + load$PC2^2)), 1e-12)
    p <- ggplot2::ggplot(scores, ggplot2::aes(x = .data$PC1, y = .data$PC2)) +
      ggplot2::geom_point(alpha = .25) +
      ggplot2::geom_segment(data = load, ggplot2::aes(x=0,y=0,xend=.data$PC1*mult,yend=.data$PC2*mult),
                            inherit.aes = FALSE, arrow = grid::arrow(length = grid::unit(0.12,"inches"))) +
      ggplot2::geom_text(data = load, ggplot2::aes(x=.data$PC1*mult,y=.data$PC2*mult,label=.data$response),
                         inherit.aes = FALSE, vjust = -0.4) + ggplot2::theme_minimal()
  }
  out <- list(pca = pc, scores = cbind(cand, scores), loadings = load, plot = p, spec = spec)
  class(out) <- "mix_biplot"; out
}

#' Compute moments over a simplex or approximate moments over a constrained region
#'
#' @param spec Mixture specification.
#' @param powers Non-negative exponent vector or matrix; one column per component.
#' @param method `auto`, `exact`, or `monte_carlo`. Exact moments are available for the unrestricted simplex.
#' @param n Number of Monte Carlo feasible points.
#' @param seed Random seed.
#' @return Data frame containing one moment for each row of `powers`.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' mix_moments(sp, powers = c(1, 1, 0), method = "exact")
#' @export
mix_moments <- function(spec, powers, method = c("auto", "exact", "monte_carlo"), n = 100000L, seed = 1L) {
  stopifnot(inherits(spec, "mix_spec")); method <- match.arg(method)
  P <- if (is.vector(powers)) matrix(powers, nrow=1L) else as.matrix(powers)
  if (ncol(P) != spec$q || any(P < 0) || any(!is.finite(P))) .mix_stop("powers must be a non-negative matrix with q columns.")
  unrestricted <- all(abs(spec$lower) <= spec$tol) && all(abs(spec$upper - spec$total) <= spec$tol) && !nrow(spec$A) && identical(spec$region$type, "polytope")
  if (method == "auto") method <- if (unrestricted) "exact" else "monte_carlo"
  if (method == "exact" && !unrestricted) .mix_stop("Exact moments are implemented only for the unrestricted simplex; use monte_carlo for constrained regions.")
  if (method == "exact") {
    vals <- apply(P, 1L, function(a) {
      A <- sum(a)
      exp(lgamma(spec$q) - lgamma(spec$q + A) + sum(lgamma(1 + a))) * spec$total^A
    })
    se <- rep(0, length(vals))
  } else {
    X <- .mix_uniform_feasible(spec, as.integer(n), seed)
    if (nrow(X) < 100L) .mix_stop("Too few feasible rejection-sampled Monte Carlo points were obtained. The constrained region may be too small for simplex-uniform rejection sampling.")
    if (nrow(X) < as.integer(n)) .mix_warn("Only ", nrow(X), " of ", as.integer(n), " requested uniform feasible points were accepted; Monte Carlo precision may be lower than requested.")
    vals <- se <- numeric(nrow(P))
    Xm <- as.matrix(X[spec$components])
    for (i in seq_len(nrow(P))) {
      z <- apply(sweep(log(pmax(Xm, .Machine$double.xmin)), 2L, P[i,], "*"), 1L, sum)
      zz <- exp(z); vals[i] <- mean(zz); se[i] <- stats::sd(zz)/sqrt(length(zz))
    }
  }
  out <- as.data.frame(P); names(out) <- spec$components; out$moment <- vals; out$mc_se <- se; out$method <- method; out
}

#' Assess approximate rotatability through radial prediction-variance dispersion
#'
#' @param design A `mix_design` or data frame.
#' @param spec Mixture specification when `design` is a data frame.
#' @param model Model basis.
#' @param bins Number of radial bins in independent coordinates.
#' @param resolution Evaluation-grid resolution.
#' @return A `mix_rotatability` object. A score near one indicates low within-radius variance dispersion.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_design(sp, "simplex_lattice", degree = 3)
#' mix_rotatability(d, model = "scheffe_quadratic", resolution = 8)
#' @export
mix_rotatability <- function(design, spec = NULL, model = "scheffe_quadratic", bins = 6L, resolution = 18L) {
  dat <- .mix_extract_data(design); if (inherits(design, "mix_design")) spec <- spec %||% design$spec
  if (is.null(spec)) .mix_stop("A mix_spec is required.")
  X <- mix_basis(dat, spec, model = model); Mi <- .mix_safe_inverse(crossprod(X))
  if (anyNA(Mi)) .mix_stop("The design cannot estimate the requested model.")
  E <- .mix_candidate_grid(spec, resolution, 1500L, 71L); F <- mix_basis(E, spec, model = model)
  pv <- rowSums((F %*% Mi) * F); Y <- mix_transform(E[spec$components], spec); radius <- sqrt(rowSums(Y^2))
  br <- unique(stats::quantile(radius, probs = seq(0,1,length.out=as.integer(bins)+1L), na.rm=TRUE))
  if (length(br) < 3L) .mix_stop("Insufficient radial variation to assess rotatability.")
  grp <- cut(radius, breaks=br, include.lowest=TRUE, labels=FALSE)
  tab <- do.call(rbind, lapply(sort(unique(grp)), function(g) {
    v <- pv[grp==g]; data.frame(bin=g,radius=mean(radius[grp==g]),mean=mean(v),sd=stats::sd(v),cv=stats::sd(v)/pmax(abs(mean(v)),1e-12),n=length(v))
  }))
  score <- 1 / (1 + weighted.mean(tab$cv^2, tab$n, na.rm=TRUE))
  out <- list(score=score, bins=tab, model=model, spec=spec,
              interpretation="Score is a numerical diagnostic, not a formal proof of exact rotatability.")
  class(out)<-"mix_rotatability"; out
}

#' @export
print.mix_rotatability <- function(x,...) {cat("<mix_rotatability> Score:",format(x$score,digits=5),"\n");print(x$bins,row.names=FALSE);cat(x$interpretation,"\n");invisible(x)}

#' @export
print.mix_fit_gls <- function(x, ...) {
  cat("<mix_fit_gls>\nResponse:", x$response, " Model:", x$model, " Method:", x$method, "\n")
  print(stats::coef(x$fit)); invisible(x)
}

#' @export
print.mix_segmented_fit <- function(x, ...) {
  cat("<mix_segmented_fit>\nSplit:", x$split_component, "<=", x$cut, "vs >", x$cut, "\n")
  cat("Left model:", x$left$model, " Right model:", x$right$model, "\n")
  cat("Boundary continuity constrained:", x$continuity_constrained, "\n")
  invisible(x)
}

#' @export
predict.mix_segmented_fit <- function(object, newdata = NULL, ...) mix_predict_segmented(object, newdata = newdata, ...)
