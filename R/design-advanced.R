#' Construct multiple-lattice designs for major and minor component groups
#'
#' The design crosses simplex lattices within major and minor component groups
#' at user-specified totals allocated to the major group. This provides a
#' transparent construction for mixture systems in which components are
#' classified by practical abundance.
#'
#' @param spec A `mix_spec` object.
#' @param major Character vector of major components.
#' @param minor Character vector of minor components. Defaults to all remaining components.
#' @param major_totals Feasible totals assigned to the major-component group.
#' @param major_degree,minor_degree Simplex-lattice degrees within the groups.
#' @param max_runs Safety cap before feasibility filtering.
#' @param randomize Randomize run order.
#' @param seed Random seed.
#' @return A `mix_design` object.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_multiple_lattice(sp, major = c("A", "B"), minor = "C",
#'                           major_totals = c(.6, .8), major_degree = 2, minor_degree = 1)
#' head(d$data)
#' @export
mix_multiple_lattice <- function(spec, major, minor = setdiff(spec$components, major),
                                 major_totals, major_degree = 3L, minor_degree = 2L,
                                 max_runs = 100000L, randomize = FALSE, seed = 1L) {
  stopifnot(inherits(spec,"mix_spec")); major <- as.character(major); minor <- as.character(minor)
  if (!length(major) || !length(minor)) .mix_stop("Both major and minor groups must contain at least one component.")
  if (length(intersect(major,minor)) || !setequal(c(major,minor),spec$components)) .mix_stop("major and minor must form a non-overlapping partition of all components.")
  major_totals <- as.numeric(major_totals)
  if (any(!is.finite(major_totals)) || any(major_totals < 0 | major_totals > spec$total)) .mix_stop("major_totals must lie between 0 and the mixture total.")
  rows <- list(); k <- 0L
  for (mt in major_totals) {
    G1 <- .mix_simplex_grid(length(major), as.integer(major_degree), mt)
    G2 <- .mix_simplex_grid(length(minor), as.integer(minor_degree), spec$total-mt)
    nr <- nrow(G1)*nrow(G2)
    if (nr + k > max_runs) .mix_stop("Requested multiple-lattice construction exceeds max_runs.")
    for (i in seq_len(nrow(G1))) for (j in seq_len(nrow(G2))) {
      x <- stats::setNames(numeric(spec$q), spec$components)
      x[major] <- G1[i,]; x[minor] <- G2[j,]
      if (.mix_feasible(x,spec)) {k<-k+1L;rows[[k]]<-x}
    }
  }
  if (!k) .mix_stop("No feasible multiple-lattice runs were generated.")
  X <- .mix_unique_rows(as.data.frame(do.call(rbind,rows),check.names=FALSE)); names(X)<-spec$components
  if (randomize) {set.seed(seed);X<-X[sample.int(nrow(X)),,drop=FALSE]}
  X$.run<-seq_len(nrow(X))
  .mix_design_object(X,spec,"multiple_lattice",list(major=major,minor=minor,major_totals=major_totals,major_degree=major_degree,minor_degree=minor_degree,seed=seed))
}

.mix_cross_category_rows <- function(parts, comps, max_runs) {
  counts <- vapply(parts,nrow,integer(1)); total <- prod(counts)
  if (!is.finite(total) || total > max_runs) .mix_stop("Categorized-component design would exceed max_runs.")
  idx <- expand.grid(lapply(counts,seq_len),KEEP.OUT.ATTRS=FALSE)
  out <- matrix(0,nrow(idx),length(comps),dimnames=list(NULL,comps))
  for (r in seq_len(nrow(idx))) for (g in seq_along(parts)) {
    z <- parts[[g]][idx[r,g],,drop=FALSE]
    out[r,colnames(z)] <- as.numeric(z[1,])
  }
  out
}

#' Construct categorized-component or mixture-of-mixtures designs
#'
#' Components are grouped into named categories. A between-category simplex
#' lattice allocates the total among categories; within each positive category,
#' another lattice allocates that category total among its components. The same
#' construction can represent a mixture of sub-mixtures.
#'
#' @param spec A `mix_spec` object.
#' @param categories Named list of non-overlapping component vectors covering all components.
#' @param between_degree Simplex-lattice degree for category totals.
#' @param within_degree Scalar or named degrees used inside categories.
#' @param category_totals Optional data frame/matrix of pre-specified category totals.
#' @param max_runs Safety cap on expanded combinations.
#' @param seed Random seed recorded in metadata.
#' @return A `mix_design` object.
#' @examples
#' sp <- mix_spec(c("A", "B", "C", "D"))
#' cats <- list(base = c("A", "B"), additive = c("C", "D"))
#' d <- mix_categorized_design(sp, cats, between_degree = 2, within_degree = 1)
#' head(d$data)
#' @export
mix_categorized_design <- function(spec, categories, between_degree = 2L, within_degree = 2L,
                                   category_totals = NULL, max_runs = 100000L, seed = 1L) {
  stopifnot(inherits(spec,"mix_spec")); if(!is.list(categories)||is.null(names(categories))||any(names(categories)=="")) .mix_stop("categories must be a named list.")
  flat <- unlist(categories,use.names=FALSE)
  if (anyDuplicated(flat) || !setequal(flat,spec$components)) .mix_stop("categories must partition all mixture components exactly once.")
  nc <- length(categories)
  wd <- if(length(within_degree)==1L) rep(as.integer(within_degree),nc) else as.integer(within_degree)
  if(length(wd)!=nc||any(wd<1L)).mix_stop("within_degree must provide a positive degree per category.")
  if (is.null(category_totals)) {
    CT <- .mix_simplex_grid(nc,as.integer(between_degree),spec$total)
    colnames(CT)<-names(categories)
  } else {
    CT<-as.matrix(category_totals)
    if(ncol(CT)!=nc).mix_stop("category_totals must have one column per category.")
    if(!is.null(colnames(CT))&&all(names(categories)%in%colnames(CT))) CT<-CT[,names(categories),drop=FALSE]
    if(any(abs(rowSums(CT)-spec$total)>100*spec$tol)||any(CT<0)).mix_stop("Each category-total row must be non-negative and sum to spec$total.")
    colnames(CT)<-names(categories)
  }
  rows <- list();k<-0L
  for(r in seq_len(nrow(CT))){
    parts<-vector("list",nc)
    for(g in seq_len(nc)){
      comps<-categories[[g]]; tot<-CT[r,g]
      if(tot<=spec$tol){M<-matrix(0,1,length(comps),dimnames=list(NULL,comps))}
      else {M<-.mix_simplex_grid(length(comps),wd[g],tot);colnames(M)<-comps}
      parts[[g]]<-M
    }
    Z<-.mix_cross_category_rows(parts,spec$components,max_runs=max_runs)
    for(i in seq_len(nrow(Z)))if(.mix_feasible(Z[i,],spec)){k<-k+1L;if(k>max_runs).mix_stop("Feasible categorized design exceeds max_runs.");rows[[k]]<-Z[i,]}
  }
  if(!k).mix_stop("No feasible categorized-component runs were generated.")
  X<-.mix_unique_rows(as.data.frame(do.call(rbind,rows),check.names=FALSE));names(X)<-spec$components;X$.run<-seq_len(nrow(X))
  .mix_design_object(X,spec,"categorized_components",list(categories=categories,between_degree=between_degree,within_degree=wd,seed=seed))
}

#' Allocate a mixture design to approximately orthogonal balanced blocks
#'
#' A balanced swap-search minimizes squared differences among block totals of
#' standardized model columns. Exact orthogonality is reported when achieved
#' numerically; otherwise the result is explicitly labelled near-orthogonal.
#'
#' @param design A `mix_design` object.
#' @param n_blocks Number of blocks.
#' @param model Model basis whose estimability should be balanced over blocks.
#' @param iterations Maximum pair-swap attempts.
#' @param seed Random seed.
#' @return A new `mix_design` with `.block` and block-balance diagnostics.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_design(sp, "simplex_lattice", degree = 3)
#' bd <- mix_block_design(d, n_blocks = 2, iterations = 100, seed = 2)
#' table(bd$data$.block)
#' @export
mix_block_design <- function(design, n_blocks, model = "scheffe_quadratic", iterations = 50000L, seed = 1L) {
  if(!inherits(design,"mix_design")).mix_stop("mix_block_design expects a mix_design object.")
  n_blocks<-as.integer(n_blocks);if(n_blocks<2L||n_blocks>nrow(design$data)).mix_stop("n_blocks must be between 2 and the number of runs.")
  dat<-design$data;spec<-design$spec
  X<-mix_basis(dat,spec,model=model);Z<-scale(X,center=TRUE,scale=TRUE);Z[,!is.finite(colSums(Z))]<-0;Z[!is.finite(Z)]<-0
  n<-nrow(Z);sizes<-rep(n%/%n_blocks,n_blocks);if(n%%n_blocks)sizes[seq_len(n%%n_blocks)]<-sizes[seq_len(n%%n_blocks)]+1L
  set.seed(seed);assign<-sample(rep(seq_len(n_blocks),sizes))
  target<-colSums(Z)/n_blocks
  objective<-function(a){sum(vapply(seq_len(n_blocks),function(b){s<-colSums(Z[a==b,,drop=FALSE]);sum((s-target)^2)},numeric(1)))}
  obj<-objective(assign);best<-obj
  for(it in seq_len(as.integer(iterations))){
    ij<-sample.int(n,2L);if(assign[ij[1]]==assign[ij[2]])next
    a2<-assign;a2[ij]<-rev(a2[ij]);o2<-objective(a2)
    if(o2<obj){assign<-a2;obj<-o2;if(obj<best)best<-obj;if(obj<1e-12)break}
  }
  dat$.block<-assign;dat$.run<-seq_len(nrow(dat))
  out<-.mix_design_object(dat,spec,paste0(design$type,"_blocked"),c(design$metadata,list(block_model=model,n_blocks=n_blocks,block_objective=obj,orthogonal=isTRUE(obj<1e-10),seed=seed)))
  out$block_diagnostics<-list(objective=obj,orthogonal=isTRUE(obj<1e-10),block_sizes=table(assign),model=model)
  out
}

#' Generate a Latin-square crossed mixture-process design
#'
#' This helper assigns two process factors with the same number of levels to a
#' square layout using a cyclic Latin square and crosses each cell with one row
#' from a base mixture design. It is primarily a structured teaching/construction
#' tool; optimality should be evaluated with [mix_design_eval()].
#'
#' @param spec A `mix_spec` object.
#' @param process1,process2 Single-element named lists, for example
#'   `list(temperature = c(20, 30, 40))`, containing equal numbers of levels.
#'   For backward compatibility, a numeric vector with a single common name is
#'   also accepted.
#' @param base_type Base mixture design type.
#' @param degree Base mixture lattice degree.
#' @param seed Random seed used when recycling/shuffling mixture runs.
#' @return A `mix_design` with row, column, and Latin treatment identifiers.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_latin_process_design(sp, list(temp = c(20, 30)),
#'                               list(speed = c(100, 200)), seed = 3)
#' head(d$data)
#' @export
mix_latin_process_design <- function(spec, process1, process2, base_type="simplex_centroid", degree=2L, seed=1L) {
  stopifnot(inherits(spec,"mix_spec"))
  unpack <- function(x, label) {
    if (is.list(x) && length(x) == 1L && !is.null(names(x)) && nzchar(names(x)[1L])) {
      return(list(name = names(x)[1L], values = as.numeric(x[[1L]])))
    }
    if (is.numeric(x) && !is.null(names(x)) && length(unique(names(x))) == 1L && nzchar(names(x)[1L])) {
      return(list(name = names(x)[1L], values = as.numeric(x)))
    }
    .mix_stop(label, " must be a single-element named list such as list(temp = c(20, 30, 40)).")
  }
  a <- unpack(process1, "process1"); b <- unpack(process2, "process2")
  if (identical(a$name, b$name)) .mix_stop("process1 and process2 must have different factor names.")
  p1 <- a$values; p2 <- b$values; n <- length(p1)
  if (n < 2L || length(p2) != n || any(!is.finite(c(p1,p2)))) .mix_stop("process factors must have the same number of finite levels >= 2.")
  base <- mix_design(spec, base_type, degree=degree)$data
  set.seed(seed); idx <- sample(rep(seq_len(nrow(base)), length.out=n*n))
  rows <- vector("list",n*n); k <- 0L
  for (r in seq_len(n)) for (c in seq_len(n)) {
    k <- k+1L; z <- base[idx[k], spec$components, drop=FALSE]
    z[[a$name]] <- p1[r]; z[[b$name]] <- p2[c]
    z$.latin_treatment <- ((r+c-2L) %% n)+1L
    z$.row_block <- r; z$.col_block <- c; rows[[k]] <- z
  }
  X <- do.call(rbind,rows); X$.run <- seq_len(nrow(X)); rownames(X) <- NULL
  .mix_design_object(X,spec,"latin_square_mixture_process",list(process_factors=c(a$name,b$name),levels=n,seed=seed))
}
