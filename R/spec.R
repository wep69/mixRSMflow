#' Define a mixture specification
#'
#' Creates the central specification object used by all mixRSMflow workflows.
#' Components are constrained to sum to `total`, while optional lower, upper,
#' and linear restrictions define the feasible composition region.
#'
#' @param components Character vector of component names.
#' @param total Mixture total, usually 1 or 100.
#' @param lower Lower bounds for each component.
#' @param upper Upper bounds for each component.
#' @param A Optional linear-constraint matrix with one column per component.
#' @param b Right-hand side vector for `A`.
#' @param dir Direction(s) for the linear restrictions: `<=`, `>=`, or `==`.
#' @param units Optional text describing component units.
#' @param tol Numerical feasibility tolerance.
#' @return An object of class `mix_spec`.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' sp
#' @export
mix_spec <- function(components, total = 1, lower = 0, upper = total,
                     A = NULL, b = NULL, dir = "<=", units = "proportion",
                     tol = 1e-8) {
  components <- as.character(components)
  .mix_check_names(components, "components")
  q <- length(components)
  if (q < 2L) .mix_stop("At least two mixture components are required.")
  total <- as.numeric(total)[1]
  if (!is.finite(total) || total <= 0) .mix_stop("total must be positive and finite.")
  lower <- .mix_recycle(lower, q, "lower")
  upper <- .mix_recycle(upper, q, "upper")
  if (any(!is.finite(lower)) || any(!is.finite(upper))) .mix_stop("Bounds must be finite.")
  if (any(lower > upper)) .mix_stop("Each lower bound must not exceed its upper bound.")
  if (sum(lower) > total + tol || sum(upper) < total - tol) {
    .mix_stop("Bounds are incompatible with the requested mixture total.")
  }
  con <- .mix_normalize_constraints(A, b, dir, q)
  if (nrow(con$A)) colnames(con$A) <- components
  basis <- .mix_orthonormal_basis(q)
  rownames(basis) <- components
  center <- .mix_project_bounded_simplex(rep(total / q, q), lower, upper, total, tol)
  names(center) <- components
  out <- list(
    components = components, q = q, total = total,
    lower = stats::setNames(lower, components),
    upper = stats::setNames(upper, components),
    A = con$A, b = con$b, units = units, tol = tol,
    basis = basis, center = center,
    region = list(type = "polytope"),
    audit = list(.mix_audit("mix_spec", list(q = q, total = total)))
  )
  class(out) <- "mix_spec"
  # General restrictions are checked by vertex enumeration when needed.
  if (!.mix_feasible(center, out) && nrow(out$A)) {
    vv <- try(mix_vertices(out, max_combinations = 100000L), silent = TRUE)
    if (inherits(vv, "try-error") || !nrow(vv)) {
      .mix_stop("No feasible point was identified for the supplied linear restrictions.")
    }
    out$center <- colMeans(vv[, components, drop = FALSE])
  }
  out
}

#' Define a curved or independent-coordinate region of interest
#'
#' @param spec A `mix_spec` object.
#' @param type Region type: `polytope`, `sphere`, `ellipsoid`, or `cuboid`.
#' @param center Optional center in original mixture coordinates.
#' @param radius Radius in orthonormal independent coordinates for a sphere.
#' @param shape Positive-definite `(q-1) x (q-1)` ellipsoid shape matrix.
#' @param lower_y,upper_y Bounds in independent coordinates for a cuboid.
#' @return A `mix_region` object inheriting from `mix_spec`.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' rg <- mix_region(sp, type = "sphere", radius = 0.2)
#' rg$region
#' @export
mix_region <- function(spec, type = c("polytope", "sphere", "ellipsoid", "cuboid"),
                       center = NULL, radius = NULL, shape = NULL,
                       lower_y = NULL, upper_y = NULL) {
  stopifnot(inherits(spec, "mix_spec"))
  type <- match.arg(type)
  center <- center %||% spec$center
  center <- as.numeric(center)
  if (length(center) != spec$q || !.mix_feasible(center, spec)) {
    .mix_stop("center must be a feasible mixture composition.")
  }
  reg <- list(type = type, center = center)
  if (type == "sphere") {
    if (is.null(radius) || !is.finite(radius) || radius <= 0) .mix_stop("A positive radius is required.")
    reg$radius <- as.numeric(radius)
  } else if (type == "ellipsoid") {
    p <- spec$q - 1L
    shape <- as.matrix(shape)
    if (!all(dim(shape) == c(p, p))) .mix_stop("shape must be a (q-1) by (q-1) matrix.")
    ev <- eigen((shape + t(shape))/2, symmetric = TRUE, only.values = TRUE)$values
    if (any(ev <= 0)) .mix_stop("shape must be positive definite.")
    reg$shape <- shape
  } else if (type == "cuboid") {
    p <- spec$q - 1L
    lower_y <- .mix_recycle(lower_y, p, "lower_y")
    upper_y <- .mix_recycle(upper_y, p, "upper_y")
    if (any(lower_y >= upper_y)) .mix_stop("lower_y must be strictly below upper_y.")
    reg$lower_y <- lower_y; reg$upper_y <- upper_y
  }
  out <- spec
  out$region <- reg
  out$audit <- c(out$audit, list(.mix_audit("mix_region", list(type = type))))
  class(out) <- c("mix_region", "mix_spec")
  out
}

#' Transform mixture coordinates to independent orthonormal coordinates
#' @param x Data frame, matrix, or numeric vector of mixture compositions.
#' @param spec A `mix_spec` object.
#' @param center Center for the transformation; defaults to `spec$center`.
#' @return Matrix with `q-1` independent coordinates.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' x <- data.frame(A = 0.2, B = 0.3, C = 0.5)
#' mix_transform(x, sp)
#' @export
mix_transform <- function(x, spec, center = NULL) {
  stopifnot(inherits(spec, "mix_spec"))
  X <- if (is.vector(x) && !is.list(x)) matrix(x, nrow = 1L) else as.matrix(x)
  if (ncol(X) != spec$q) .mix_stop("x must have one column per mixture component.")
  center <- as.numeric(center %||% spec$center)
  sweep(X, 2L, center, "-") %*% spec$basis
}

#' Transform independent coordinates back to mixture coordinates
#' @param y Matrix or numeric vector with `q-1` independent coordinates.
#' @param spec A `mix_spec` object.
#' @param center Center used in the inverse transformation.
#' @return Data frame in original mixture coordinates.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' x <- data.frame(A = 0.2, B = 0.3, C = 0.5)
#' y <- mix_transform(x, sp)
#' mix_inverse_transform(y, sp)
#' @export
mix_inverse_transform <- function(y, spec, center = NULL) {
  stopifnot(inherits(spec, "mix_spec"))
  Y <- if (is.vector(y) && !is.list(y)) matrix(y, nrow = 1L) else as.matrix(y)
  if (ncol(Y) != spec$q - 1L) .mix_stop("y must have q-1 columns.")
  center <- as.numeric(center %||% spec$center)
  X <- sweep(Y %*% t(spec$basis), 2L, center, "+")
  X <- as.data.frame(X, check.names = FALSE)
  names(X) <- spec$components
  X
}

#' Enumerate extreme vertices of a linearly constrained mixture region
#'
#' Uses active-set enumeration for the equality `sum(x)=total` plus bound and
#' general linear inequalities. Intended for moderate-dimensional constrained
#' mixture problems.
#' @param spec A `mix_spec` or polytope `mix_region` object.
#' @param max_combinations Safety limit for active-set combinations.
#' @param tol Numerical tolerance.
#' @return Data frame of unique feasible extreme vertices.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"), lower = c(.1, .1, .1), upper = c(.7, .8, .8))
#' mix_vertices(sp)
#' @export
mix_vertices <- function(spec, max_combinations = 250000L, tol = spec$tol %||% 1e-8) {
  stopifnot(inherits(spec, "mix_spec"))
  if (!identical((spec$region %||% list(type="polytope"))$type, "polytope")) {
    .mix_stop("Extreme vertices are defined here only for polytope regions.")
  }
  q <- spec$q
  Aall <- rbind(diag(q), -diag(q), spec$A)
  ball <- c(spec$upper, -spec$lower, spec$b)
  m <- nrow(Aall)
  ncomb <- choose(m, q - 1L)
  if (!is.finite(ncomb) || ncomb > max_combinations) {
    .mix_stop("Active-set enumeration would require ", format(ncomb, scientific = FALSE),
              " combinations; increase max_combinations or use a coarser candidate strategy.")
  }
  cmb <- utils::combn(m, q - 1L)
  verts <- vector("list", ncol(cmb)); nv <- 0L
  for (j in seq_len(ncol(cmb))) {
    idx <- cmb[, j]
    E <- rbind(rep(1, q), Aall[idx, , drop = FALSE])
    rhs <- c(spec$total, ball[idx])
    if (qr(E, tol = tol)$rank < q) next
    x <- try(solve(E, rhs), silent = TRUE)
    if (inherits(x, "try-error")) next
    if (all(drop(Aall %*% x) <= ball + 10 * tol) && abs(sum(x) - spec$total) <= 10 * tol) {
      nv <- nv + 1L; verts[[nv]] <- x
    }
  }
  if (!nv) return(stats::setNames(as.data.frame(matrix(numeric(), 0L, q)), spec$components))
  X <- do.call(rbind, verts[seq_len(nv)])
  X <- .mix_unique_rows(as.data.frame(X), digits = max(6L, ceiling(-log10(tol))))
  names(X) <- spec$components
  rownames(X) <- NULL
  X
}

#' @export
print.mix_spec <- function(x, ...) {
  cat("<mix_spec>\n")
  cat(" Components:", paste(x$components, collapse = ", "), "\n")
  cat(" Total:", format(x$total), "\n")
  cat(" Region:", (x$region %||% list(type="polytope"))$type, "\n")
  cat(" Bounds:\n")
  print(data.frame(component = x$components, lower = x$lower, upper = x$upper), row.names = FALSE)
  if (nrow(x$A)) cat(" General linear inequalities:", nrow(x$A), "\n")
  invisible(x)
}
