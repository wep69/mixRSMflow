.mix_random_candidates <- function(spec, n = 5000L, seed = 1L) {
  set.seed(seed)
  q <- spec$q
  ans <- matrix(NA_real_, 0L, q)
  batch <- max(1000L, n)
  tries <- 0L
  while (nrow(ans) < n && tries < 20L) {
    Z <- matrix(stats::rexp(batch * q), batch, q)
    Z <- Z / rowSums(Z) * spec$total
    Z <- t(apply(Z, 1L, .mix_project_bounded_simplex,
                 lower = spec$lower, upper = spec$upper, total = spec$total, tol = spec$tol))
    keep <- apply(Z, 1L, .mix_feasible, spec = spec)
    if (any(keep)) ans <- rbind(ans, Z[keep, , drop = FALSE])
    tries <- tries + 1L
  }
  if (!nrow(ans)) return(stats::setNames(as.data.frame(ans), spec$components))
  ans <- ans[seq_len(min(n, nrow(ans))), , drop = FALSE]
  ans <- .mix_unique_rows(as.data.frame(ans))
  names(ans) <- spec$components
  ans
}


.mix_uniform_feasible <- function(spec, n = 5000L, seed = 1L, max_batches = 200L) {
  # Dirichlet(1,...,1) is uniform on the full simplex. Rejection, without
  # projection, preserves the uniform measure on the feasible subset.
  set.seed(seed)
  q <- spec$q; n <- as.integer(n)
  if (n < 1L) return(stats::setNames(as.data.frame(matrix(numeric(),0L,q)),spec$components))
  ans <- matrix(NA_real_,0L,q); tries <- 0L
  batch <- max(2000L, min(50000L, n * 4L))
  while (nrow(ans) < n && tries < max_batches) {
    Z <- matrix(stats::rexp(batch*q),batch,q)
    Z <- Z / rowSums(Z) * spec$total
    keep <- apply(Z,1L,.mix_feasible,spec=spec)
    if (any(keep)) ans <- rbind(ans,Z[keep,,drop=FALSE])
    tries <- tries + 1L
    if (tries %% 10L == 0L && nrow(ans) < n/20) batch <- min(100000L,batch*2L)
  }
  if (!nrow(ans)) return(stats::setNames(as.data.frame(ans),spec$components))
  ans <- ans[seq_len(min(n,nrow(ans))),,drop=FALSE]
  out <- as.data.frame(ans,check.names=FALSE); names(out) <- spec$components
  attr(out,"acceptance_complete") <- nrow(out) >= n
  attr(out,"requested_n") <- n
  out
}

.mix_candidate_grid <- function(spec, resolution = 12L, random_n = 0L, seed = 1L) {
  resolution <- as.integer(resolution)
  if (resolution < 1L) .mix_stop("resolution must be >= 1.")
  X <- .mix_simplex_grid(spec$q, resolution, spec$total)
  X <- as.data.frame(X, check.names = FALSE); names(X) <- spec$components
  X <- .mix_filter_feasible(X, spec)
  add <- list()
  if (identical((spec$region %||% list(type="polytope"))$type, "polytope")) {
    v <- try(mix_vertices(spec, max_combinations = 100000L), silent = TRUE)
    if (!inherits(v, "try-error") && nrow(v)) add[[length(add)+1L]] <- v
  }
  if (.mix_feasible(spec$center, spec)) {
    cc <- as.data.frame(t(spec$center), check.names = FALSE); names(cc) <- spec$components
    add[[length(add)+1L]] <- cc
  }
  if (random_n > 0L) add[[length(add)+1L]] <- .mix_random_candidates(spec, random_n, seed)
  if (length(add)) X <- rbind(X, do.call(rbind, add))
  .mix_unique_rows(X)
}

.mix_design_object <- function(data, spec, type, metadata = list()) {
  data <- as.data.frame(data, check.names = FALSE)
  out <- list(data = data, spec = spec, type = type, metadata = metadata,
              audit = list(.mix_audit("mix_design", c(list(type = type, n = nrow(data)), metadata))))
  class(out) <- "mix_design"
  out
}


.mix_fraction_d <- function(dat, spec, target, process_names, model = "scheffe_quadratic",
                            process_order = 2L, mixture_process = TRUE, seed = 1L,
                            exchange_iter = 300L) {
  X <- mix_basis(dat, spec, model = model, process = process_names,
                 process_order = process_order, mixture_process = mixture_process)
  p <- ncol(X); n <- nrow(X); target <- as.integer(target)
  if (target < p) .mix_stop("Requested process-design fraction has ", target,
                            " runs but at least ", p, " are needed to estimate the declared fractionation model.")
  if (target >= n) return(seq_len(n))
  # QR pivoting on X' supplies a rank-seeking initial row subset.
  piv <- qr(t(X))$pivot
  sel <- unique(piv[seq_len(min(p,target))])
  if (length(sel) < p || qr(X[sel,,drop=FALSE])$rank < p)
    .mix_stop("Could not find a full-rank initial fraction for the declared model.")
  loss <- function(ids) {
    M <- crossprod(X[ids,,drop=FALSE])
    ld <- .mix_logdet(M)
    if (!is.finite(ld)) Inf else -ld/p
  }
  while (length(sel) < target) {
    cand <- setdiff(seq_len(n),sel)
    vals <- vapply(cand,function(i) loss(c(sel,i)),numeric(1))
    sel <- c(sel,cand[which.min(vals)])
  }
  current <- loss(sel); set.seed(seed)
  for (it in seq_len(as.integer(exchange_iter))) {
    outpos <- sample.int(length(sel),1L); pool <- setdiff(seq_len(n),sel)
    if (!length(pool)) break
    trial_candidates <- if (length(pool)>100L) sample(pool,100L) else pool
    vals <- vapply(trial_candidates,function(j) {z<-sel;z[outpos]<-j;loss(z)},numeric(1))
    k <- which.min(vals)
    if (length(k) && is.finite(vals[k]) && vals[k] < current - 1e-12) {
      sel[outpos] <- trial_candidates[k]; current <- vals[k]
    }
  }
  sort(sel)
}

#' Fractionate a crossed mixture-process design using model-based D information
#'
#' @param design A `mix_design` containing mixture and process columns.
#' @param process Character names of process variables.
#' @param fraction Fraction in `(0,1]` or an integer number of runs.
#' @param model Mixture basis used to protect estimability.
#' @param process_order Process polynomial order.
#' @param mixture_process Include mixture-by-process interactions in the protected model.
#' @param seed Random seed used only in exchange-search tie/exploration steps.
#' @param exchange_iter Maximum exchange iterations.
#' @return A fractionated `mix_design` with the declared model and selection metadata.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' mp <- mix_design(sp, "mixture_process", process = list(temp = c(-1, 1)))
#' fr <- mix_fractionate_process(mp, process = "temp", fraction = 10,
#'                               process_order = 1, mixture_process = FALSE)
#' nrow(fr$data)
#' @export
mix_fractionate_process <- function(design, process, fraction, model="scheffe_quadratic",
                                    process_order=2L, mixture_process=TRUE,
                                    seed=1L, exchange_iter=300L) {
  if (!inherits(design,"mix_design")) .mix_stop("design must be a mix_design object.")
  if (!length(process) || any(!process %in% names(design$data))) .mix_stop("process must name process columns in the design.")
  n <- nrow(design$data)
  if (length(fraction)!=1L || !is.finite(fraction) || fraction<=0) .mix_stop("fraction must be a positive scalar.")
  target <- if (fraction <= 1) max(1L,floor(n*fraction)) else as.integer(fraction)
  if (target > n) .mix_stop("Requested fraction exceeds the number of available runs.")
  ids <- .mix_fraction_d(design$data,design$spec,target,process,model,process_order,mixture_process,seed,exchange_iter)
  d <- design$data[ids,,drop=FALSE]; d$.run <- seq_len(nrow(d)); rownames(d)<-NULL
  .mix_design_object(d,design$spec,paste0(design$type,"_fractionated"),
                     c(design$metadata,list(fractionation="D-information",source_runs=n,target_runs=target,
                                            model=model,process=process,process_order=process_order,
                                            mixture_process=mixture_process,seed=seed)))
}

#' Generate classical and mixture-process designs
#'
#' @param spec A `mix_spec` or `mix_region` object.
#' @param type Design type. Supported values include `simplex_lattice`,
#'   `simplex_centroid`, `axial`, `augmented_centroid`, `symmetric_simplex`,
#'   `extreme_vertices`, `rotatable`, `multiple_lattice`, `categorized_components`,
#'   `mixture_process`, `split_plot`, and `mixture_amount`.
#' @param degree Lattice degree for `simplex_lattice` or base resolution.
#' @param alpha Axial mixture coordinate; if `NULL`, a midpoint-type value is used.
#' @param include_centroid Add the feasible center where relevant.
#' @param edge_midpoints Include midpoints of extreme-vertex pairs when feasible.
#' @param base_type Base mixture design for mixture-process/amount designs.
#' @param process Named list of process-variable levels.
#' @param amount Numeric levels for total mixture amount.
#' @param fraction Optional fraction `(0,1]` of the crossed design to retain.
#' @param hard_to_change Character names of process variables defining whole plots.
#' @param fraction_method `D` for model-based D-information fractionation or `random` for an explicitly random teaching/control fraction.
#' @param fraction_model Mixture basis protected during D-information fractionation.
#' @param fraction_process_order Process order protected during fractionation.
#' @param fraction_mixture_process Include mixture-process interactions in the protected fractionation model.
#' @param major,minor Component groups for `multiple_lattice`.
#' @param major_totals Totals allocated to the major group.
#' @param categories Named component categories for `categorized_components`.
#' @param category_totals Optional category totals for categorized designs.
#' @param between_degree,within_degree Lattice degrees for categorized designs.
#' @param blocks Optional number of blocks for balanced block labels.
#' @param randomize Randomize run order.
#' @param seed Random seed.
#' @return A `mix_design` object.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_design(sp, "simplex_centroid")
#' head(d$data)
#' @export
mix_design <- function(spec,
                       type = c("simplex_lattice", "simplex_centroid", "axial",
                                "augmented_centroid", "symmetric_simplex",
                                "extreme_vertices", "rotatable", "multiple_lattice",
                                "categorized_components", "mixture_process",
                                "split_plot", "mixture_amount"),
                       degree = 3L, alpha = NULL, include_centroid = TRUE,
                       edge_midpoints = TRUE, base_type = "simplex_centroid",
                       process = NULL, amount = NULL, fraction = NULL,
                       hard_to_change = NULL, fraction_method = c("D","random"), fraction_model = "scheffe_quadratic",
                       fraction_process_order = 2L, fraction_mixture_process = TRUE,
                       major = NULL, minor = NULL, major_totals = NULL,
                       categories = NULL, category_totals = NULL, between_degree = 2L, within_degree = 2L,
                       blocks = NULL,
                       randomize = FALSE, seed = 1L) {
  stopifnot(inherits(spec, "mix_spec"))
  type <- match.arg(type)
  fraction_method <- match.arg(fraction_method)
  q <- spec$q; comps <- spec$components
  total <- spec$total
  degree <- as.integer(degree)
  if (degree < 1L) .mix_stop("degree must be >= 1.")

  if (type == "simplex_lattice") {
    X <- .mix_simplex_grid(q, degree, total)
    X <- as.data.frame(X, check.names = FALSE); names(X) <- comps
    X <- .mix_filter_feasible(X, spec)
  } else if (type == "simplex_centroid") {
    rows <- list(); k <- 0L
    for (s in seq_len(q)) {
      cc <- utils::combn(q, s)
      for (j in seq_len(ncol(cc))) {
        x <- numeric(q); x[cc[, j]] <- total / s
        if (.mix_feasible(x, spec)) { k <- k + 1L; rows[[k]] <- x }
      }
    }
    X <- if (k) as.data.frame(do.call(rbind, rows), check.names = FALSE) else data.frame()
    if (k) names(X) <- comps
  } else if (type == "axial") {
    alpha <- alpha %||% (0.5 + 0.5 / q)
    if (alpha <= 1/q || alpha > 1) .mix_stop("alpha should exceed 1/q and not exceed 1.")
    rows <- matrix((1-alpha) * total/(q-1), q, q)
    diag(rows) <- alpha * total
    X <- as.data.frame(rows, check.names = FALSE); names(X) <- comps
    X <- .mix_filter_feasible(X, spec)
    if (include_centroid && .mix_feasible(spec$center, spec)) {
      X <- rbind(X, stats::setNames(as.data.frame(t(spec$center)), comps))
    }
  } else if (type == "augmented_centroid") {
    d1 <- mix_design(spec, "simplex_centroid")$data
    d2 <- mix_design(spec, "axial", alpha = alpha, include_centroid = TRUE)$data
    X <- .mix_unique_rows(rbind(d1, d2))
  } else if (type == "symmetric_simplex") {
    p <- q - 1L
    # Radius is scaled so all plus/minus axial points remain feasible.
    maxr <- Inf
    for (j in seq_len(p)) {
      d <- spec$basis[, j]
      for (sgn in c(-1, 1)) {
        dd <- sgn * d
        pos <- dd > 0; neg <- dd < 0
        vals <- c((spec$upper[pos] - spec$center[pos]) / dd[pos],
                  (spec$lower[neg] - spec$center[neg]) / dd[neg])
        vals <- vals[is.finite(vals) & vals >= 0]
        if (length(vals)) maxr <- min(maxr, vals)
      }
    }
    if (!is.finite(maxr) || maxr <= 0) .mix_stop("Could not construct a symmetric simplex inside the feasible bounds.")
    radius <- 0.8 * maxr
    Y <- rbind(diag(p) * radius, -diag(p) * radius)
    X <- mix_inverse_transform(Y, spec)
    X <- .mix_filter_feasible(X, spec)
    if (include_centroid && .mix_feasible(spec$center, spec)) X <- rbind(X, stats::setNames(as.data.frame(t(spec$center)), comps))
  } else if (type == "extreme_vertices") {
    V <- mix_vertices(spec)
    X <- V
    if (edge_midpoints && nrow(V) >= 2L) {
      cmb <- utils::combn(nrow(V), 2L)
      mids <- t(vapply(seq_len(ncol(cmb)), function(j) {
        (as.numeric(V[cmb[1,j], comps]) + as.numeric(V[cmb[2,j], comps])) / 2
      }, numeric(q)))
      mids <- as.data.frame(mids, check.names = FALSE); names(mids) <- comps
      mids <- .mix_filter_feasible(mids, spec)
      X <- rbind(X, mids)
    }
    if (include_centroid && .mix_feasible(spec$center, spec)) X <- rbind(X, stats::setNames(as.data.frame(t(spec$center)), comps))
    X <- .mix_unique_rows(X)
  } else if (type == "rotatable") {
    p <- q - 1L
    # Central composite geometry in the orthonormal q-1 coordinate system.
    factorial <- as.matrix(expand.grid(rep(list(c(-1, 1)), p)))
    alpha_ccd <- (nrow(factorial))^(1/4)
    axial <- rbind(diag(p) * alpha_ccd, -diag(p) * alpha_ccd)
    Y0 <- rbind(factorial, axial, matrix(0, 1L, p))
    # Find largest common scale that preserves all mixture constraints.
    scale <- 1
    feasible_scale <- function(s) {
      XX <- mix_inverse_transform(Y0 * s, spec)
      all(vapply(seq_len(nrow(XX)), function(i) .mix_feasible(unlist(XX[i, comps]), spec), logical(1)))
    }
    if (!feasible_scale(scale)) {
      lo <- 0; hi <- 1
      for (i in seq_len(60L)) {
        mid <- (lo + hi)/2
        if (feasible_scale(mid)) lo <- mid else hi <- mid
      }
      scale <- lo * 0.999
    }
    if (scale <= spec$tol) .mix_stop("The feasible region is too narrow for the requested rotatable construction.")
    X <- mix_inverse_transform(Y0 * scale, spec)
    X <- .mix_filter_feasible(X, spec)
  } else if (type == "multiple_lattice") {
    if (is.null(major) || is.null(major_totals)) .mix_stop("major and major_totals are required for multiple_lattice.")
    dd <- mix_multiple_lattice(spec, major = major, minor = minor %||% setdiff(comps, major),
                               major_totals = major_totals, major_degree = degree,
                               minor_degree = max(1L, degree - 1L), randomize = FALSE, seed = seed)
    X <- dd$data[comps]
  } else if (type == "categorized_components") {
    if (is.null(categories)) .mix_stop("categories is required for categorized_components.")
    dd <- mix_categorized_design(spec, categories = categories, between_degree = between_degree,
                                  within_degree = within_degree, category_totals = category_totals, seed = seed)
    X <- dd$data[comps]
  } else if (type %in% c("mixture_process", "split_plot")) {
    if (is.null(process) || !length(process) || is.null(names(process))) .mix_stop("process must be a named list of process-variable levels.")
    .mix_check_names(names(process), "process names")
    if (any(names(process) %in% comps)) .mix_stop("Process-variable names must differ from mixture-component names.")
    base <- mix_design(spec, type = base_type, degree = degree, alpha = alpha)$data
    pg <- expand.grid(process, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
    X <- merge(base, pg, by = NULL)
    if (!is.null(fraction)) {
      if (!is.numeric(fraction) || length(fraction)!=1L || fraction <= 0 || fraction > 1) .mix_stop("fraction must lie in (0,1].")
      target <- max(1L, floor(fraction*nrow(X)))
      if (fraction_method == "D") {
        ids <- .mix_fraction_d(X,spec,target,names(process),fraction_model,
                               fraction_process_order,fraction_mixture_process,seed)
        X <- X[ids,,drop=FALSE]
      } else {
        set.seed(seed); X <- X[sample.int(nrow(X),target),,drop=FALSE]
        .mix_warn("Random process-design fractionation was explicitly requested; verify estimability with mix_design_eval().")
      }
    }
    if (type == "split_plot") {
      hard_to_change <- hard_to_change %||% names(process)[1L]
      if (!all(hard_to_change %in% names(process))) .mix_stop("hard_to_change must name process variables.")
      key <- interaction(X[hard_to_change], drop = TRUE, lex.order = TRUE)
      X$.whole_plot <- as.integer(key)
      X$.subplot <- ave(seq_len(nrow(X)), X$.whole_plot, FUN = seq_along)
    }
  } else if (type == "mixture_amount") {
    if (is.null(amount) || !length(amount) || any(!is.finite(amount)) || any(amount <= 0)) .mix_stop("Positive amount levels are required.")
    base <- mix_design(spec, type = base_type, degree = degree, alpha = alpha)$data
    X <- merge(base, data.frame(.amount = amount), by = NULL)
    for (nm in comps) X[[paste0(nm, "_amount")]] <- X[[nm]] / total * X$.amount
  }

  if (!exists("X", inherits = FALSE) || !nrow(X)) .mix_stop("The requested design contains no feasible runs.")
  rownames(X) <- NULL
  if (!is.null(blocks)) {
    blocks <- as.integer(blocks)
    if (blocks < 1L) .mix_stop("blocks must be >= 1.")
    X$.block <- rep(seq_len(blocks), length.out = nrow(X))
  }
  if (randomize) {
    set.seed(seed)
    X <- X[sample.int(nrow(X)), , drop = FALSE]
  }
  X$.run <- seq_len(nrow(X))
  .mix_design_object(X, spec, type, list(seed = seed, randomized = randomize,
                                        degree = degree, blocks = blocks,
                                        hard_to_change = hard_to_change))
}

#' @export
as.data.frame.mix_design <- function(x, ...) x$data

#' @export
print.mix_design <- function(x, ...) {
  cat("<mix_design>", x$type, "\n")
  cat(" Runs:", nrow(x$data), "\n")
  cat(" Components:", paste(x$spec$components, collapse = ", "), "\n")
  if (".whole_plot" %in% names(x$data)) cat(" Whole plots:", length(unique(x$data$.whole_plot)), "\n")
  print(utils::head(x$data, 10L), row.names = FALSE)
  invisible(x)
}
