`%||%` <- function(x, y) if (is.null(x)) y else x

.mix_stop <- function(..., call. = FALSE) stop(..., call. = call.)
.mix_warn <- function(..., call. = FALSE) warning(..., call. = call.)

.mix_check_names <- function(x, what = "names") {
  if (is.null(x) || anyNA(x) || any(!nzchar(x)) || anyDuplicated(x)) {
    .mix_stop(what, " must be non-missing, non-empty, and unique.")
  }
  invisible(TRUE)
}

.mix_recycle <- function(x, n, name) {
  if (length(x) == 1L) x <- rep(x, n)
  if (length(x) != n) .mix_stop(name, " must have length 1 or ", n, ".")
  as.numeric(x)
}

.mix_orthonormal_basis <- function(q) {
  if (q < 2L) .mix_stop("At least two mixture components are required.")
  H <- stats::contr.helmert(q)
  sweep(H, 2L, sqrt(colSums(H^2)), "/")
}

.mix_project_bounded_simplex <- function(v, lower, upper, total, tol = 1e-12) {
  if (sum(lower) - total > tol || total - sum(upper) > tol) {
    .mix_stop("The lower/upper bounds do not admit the requested mixture total.")
  }
  f <- function(lambda) sum(pmin(upper, pmax(lower, v - lambda))) - total
  lo <- min(v - upper) - abs(total) - 1
  hi <- max(v - lower) + abs(total) + 1
  flo <- f(lo); fhi <- f(hi)
  k <- 0L
  while (flo < 0 && k < 100L) { lo <- lo * 2 - 1; flo <- f(lo); k <- k + 1L }
  k <- 0L
  while (fhi > 0 && k < 100L) { hi <- hi * 2 + 1; fhi <- f(hi); k <- k + 1L }
  for (i in seq_len(200L)) {
    mid <- (lo + hi) / 2
    fm <- f(mid)
    if (abs(fm) <= tol) break
    if (fm > 0) lo <- mid else hi <- mid
  }
  p <- pmin(upper, pmax(lower, v - mid))
  # Enforce the mixture total exactly so the centre lies on the simplex plane;
  # otherwise transform/inverse-transform round trips inherit the bisection
  # tolerance (up to ~1e-8) as systematic error.
  adj <- total - sum(p)
  if (abs(adj) > 0) {
    idx <- if (adj > 0) which.max(upper - p) else which.max(p - lower)
    p[idx] <- p[idx] + adj
  }
  p
}

.mix_normalize_constraints <- function(A = NULL, b = NULL, dir = "<=", q = NULL) {
  if (is.null(A)) return(list(A = matrix(numeric(), 0L, q %||% 0L), b = numeric()))
  A <- as.matrix(A)
  storage.mode(A) <- "double"
  if (!is.null(q) && ncol(A) != q) .mix_stop("Constraint matrix A must have one column per component.")
  if (is.null(b) || length(b) != nrow(A)) .mix_stop("b must have one value per row of A.")
  if (length(dir) == 1L) dir <- rep(dir, nrow(A))
  if (length(dir) != nrow(A)) .mix_stop("dir must have length 1 or nrow(A).")
  outA <- list(); outb <- list(); k <- 0L
  for (i in seq_len(nrow(A))) {
    d <- dir[[i]]
    if (d %in% c("<=", "<")) {
      k <- k + 1L; outA[[k]] <- A[i, ]; outb[[k]] <- b[[i]]
    } else if (d %in% c(">=", ">")) {
      k <- k + 1L; outA[[k]] <- -A[i, ]; outb[[k]] <- -b[[i]]
    } else if (d %in% c("=", "==")) {
      k <- k + 1L; outA[[k]] <- A[i, ]; outb[[k]] <- b[[i]]
      k <- k + 1L; outA[[k]] <- -A[i, ]; outb[[k]] <- -b[[i]]
    } else {
      .mix_stop("Unsupported constraint direction: ", d)
    }
  }
  list(A = do.call(rbind, outA), b = unlist(outb, use.names = FALSE))
}

.mix_feasible <- function(x, spec, tol = spec$tol %||% 1e-8) {
  x <- as.numeric(x)
  if (length(x) != length(spec$components)) return(FALSE)
  if (any(x < spec$lower - tol) || any(x > spec$upper + tol)) return(FALSE)
  if (abs(sum(x) - spec$total) > tol) return(FALSE)
  if (nrow(spec$A) && any(drop(spec$A %*% x) > spec$b + tol)) return(FALSE)
  reg <- spec$region %||% list(type = "polytope")
  if (identical(reg$type, "sphere")) {
    y <- drop(crossprod(spec$basis, x - reg$center))
    if (sqrt(sum(y^2)) > reg$radius + tol) return(FALSE)
  } else if (identical(reg$type, "ellipsoid")) {
    y <- drop(crossprod(spec$basis, x - reg$center))
    val <- drop(crossprod(y, solve(reg$shape, y)))
    if (val > 1 + tol) return(FALSE)
  } else if (identical(reg$type, "cuboid")) {
    y <- drop(crossprod(spec$basis, x - reg$center))
    if (any(y < reg$lower_y - tol) || any(y > reg$upper_y + tol)) return(FALSE)
  }
  TRUE
}

.mix_filter_feasible <- function(X, spec) {
  X <- as.data.frame(X, check.names = FALSE)
  keep <- vapply(seq_len(nrow(X)), function(i) .mix_feasible(unlist(X[i, spec$components, drop = TRUE]), spec), logical(1))
  X[keep, , drop = FALSE]
}

.mix_safe_inverse <- function(M, tol = 1e-10) {
  M <- as.matrix(M)
  ee <- eigen((M + t(M))/2, symmetric = TRUE)
  vmax <- max(abs(ee$values), 1)
  keep <- ee$values > tol * vmax
  if (!any(keep)) return(matrix(NA_real_, nrow(M), ncol(M)))
  V <- ee$vectors[, keep, drop = FALSE]
  V %*% (t(V) / ee$values[keep])
}

.mix_logdet <- function(M, tol = 1e-12) {
  ev <- eigen((M + t(M))/2, symmetric = TRUE, only.values = TRUE)$values
  if (any(ev <= tol * max(abs(ev), 1))) return(-Inf)
  sum(log(ev))
}

.mix_unique_rows <- function(X, digits = 12L) {
  if (!nrow(X)) return(X)
  key <- apply(round(as.matrix(X), digits), 1L, paste, collapse = "|")
  X[!duplicated(key), , drop = FALSE]
}

.mix_compositions <- function(n, k) {
  if (k == 1L) return(matrix(n, nrow = 1L))
  out <- vector("list", choose(n + k - 1L, k - 1L))
  idx <- 0L
  rec <- function(prefix, remain, slots) {
    if (slots == 1L) {
      idx <<- idx + 1L
      out[[idx]] <<- c(prefix, remain)
    } else {
      for (z in 0:remain) rec(c(prefix, z), remain - z, slots - 1L)
    }
  }
  rec(numeric(), n, k)
  do.call(rbind, out)
}

.mix_simplex_grid <- function(q, resolution, total = 1) {
  C <- .mix_compositions(as.integer(resolution), q)
  C / resolution * total
}

.mix_barycentric_xy <- function(X) {
  X <- as.matrix(X)
  if (ncol(X) != 3L) .mix_stop("Ternary coordinates require exactly three mixture components.")
  s <- rowSums(X)
  Z <- X / s
  data.frame(
    .x = Z[, 2] + 0.5 * Z[, 3],
    .y = sqrt(3) / 2 * Z[, 3]
  )
}

.mix_audit <- function(step, details = list()) {
  list(step = step, timestamp = format(Sys.time(), tz = "UTC", usetz = TRUE), details = details)
}
