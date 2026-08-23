.mix_term <- function(values, label) {
  attr(values, "label") <- label
  values
}

.mix_bind_terms <- function(terms) {
  if (!length(terms)) return(matrix(numeric(), 0L, 0L))
  X <- do.call(cbind, lapply(terms, as.numeric))
  colnames(X) <- vapply(terms, function(z) attr(z, "label"), character(1))
  X
}

.mix_scheffe_terms <- function(Xc, model) {
  comps <- colnames(Xc); q <- ncol(Xc); terms <- list(); k <- 0L
  add <- function(v, lab) { k <<- k + 1L; terms[[k]] <<- .mix_term(v, lab) }
  for (i in seq_len(q)) add(Xc[,i], comps[i])
  if (model == "scheffe_linear") return(.mix_bind_terms(terms))
  pairs <- if (q >= 2L) utils::combn(q, 2L) else matrix(integer(), 2L, 0L)
  for (j in seq_len(ncol(pairs))) {
    i1 <- pairs[1,j]; i2 <- pairs[2,j]
    add(Xc[,i1]*Xc[,i2], paste0(comps[i1], ":", comps[i2]))
  }
  if (model == "scheffe_quadratic") return(.mix_bind_terms(terms))
  triples <- if (q >= 3L) utils::combn(q, 3L) else matrix(integer(), 3L, 0L)
  if (model %in% c("scheffe_special_cubic", "scheffe_cubic", "scheffe_special_quartic", "scheffe_quartic")) {
    if (model %in% c("scheffe_cubic", "scheffe_quartic")) {
      for (j in seq_len(ncol(pairs))) {
        i1 <- pairs[1,j]; i2 <- pairs[2,j]
        add(Xc[,i1]*Xc[,i2]*(Xc[,i1]-Xc[,i2]), paste0(comps[i1], ":", comps[i2], "*diff"))
      }
    }
    if (model %in% c("scheffe_special_cubic", "scheffe_cubic")) {
      for (j in seq_len(ncol(triples))) {
        ids <- triples[,j]
        add(apply(Xc[,ids,drop=FALSE],1L,prod), paste(comps[ids], collapse=":"))
      }
      return(.mix_bind_terms(terms))
    }
  }
  if (model %in% c("scheffe_special_quartic", "scheffe_quartic")) {
    if (model == "scheffe_quartic") {
      for (j in seq_len(ncol(pairs))) {
        i1 <- pairs[1,j]; i2 <- pairs[2,j]
        add(Xc[,i1]*Xc[,i2]*(Xc[,i1]-Xc[,i2])^2, paste0(comps[i1], ":", comps[i2], "*diff2"))
      }
    }
    for (j in seq_len(ncol(triples))) {
      ids <- triples[,j]
      for (s in ids) {
        other <- ids[ids != s]
        v <- Xc[,s]^2 * Xc[,other[1]] * Xc[,other[2]]
        add(v, paste0(comps[s], "^2:", comps[other[1]], ":", comps[other[2]]))
      }
    }
    if (model == "scheffe_quartic" && q >= 4L) {
      quads <- utils::combn(q, 4L)
      for (j in seq_len(ncol(quads))) {
        ids <- quads[,j]
        add(apply(Xc[,ids,drop=FALSE],1L,prod), paste(comps[ids], collapse=":"))
      }
    }
    return(.mix_bind_terms(terms))
  }
  .mix_stop("Unsupported Scheffe model: ", model)
}

.mix_process_terms <- function(data, process, order = 2L) {
  if (is.null(process) || !length(process)) return(matrix(numeric(), nrow(data), 0L))
  if (!all(process %in% names(data))) .mix_stop("All process variables must be present in data.")
  P <- as.data.frame(data[process], check.names = FALSE)
  if (any(!vapply(P, is.numeric, logical(1)))) .mix_stop("Core process-variable basis currently requires numeric process variables.")
  terms <- list(); k <- 0L
  add <- function(v, lab) { k <<- k + 1L; terms[[k]] <<- .mix_term(v, lab) }
  for (nm in process) add(P[[nm]], paste0("proc:", nm))
  if (order >= 2L) {
    for (nm in process) add(P[[nm]]^2, paste0("proc:", nm, "^2"))
    if (length(process) >= 2L) {
      cmb <- utils::combn(process, 2L)
      for (j in seq_len(ncol(cmb))) add(P[[cmb[1,j]]]*P[[cmb[2,j]]], paste0("proc:", cmb[1,j], ":", cmb[2,j]))
    }
  }
  .mix_bind_terms(terms)
}

.mix_cox_polynomial <- function(Xc, spec, reference, degree = 1L) {
  s <- reference %||% as.numeric(spec$center)
  if (length(s) != spec$q || any(s <= 0) || abs(sum(s)-spec$total) > 100*spec$tol) .mix_stop("reference must be a strictly positive feasible composition.")
  refidx <- spec$q
  Z <- sapply(seq_len(spec$q-1L), function(i) Xc[,i] - (s[i]/s[refidx])*Xc[,refidx])
  Z <- matrix(Z, nrow = nrow(Xc), ncol = spec$q - 1L)
  zn <- paste0("cox:",spec$components[seq_len(spec$q-1L)],"|",spec$components[refidx])
  colnames(Z) <- zn
  terms <- list(.mix_term(rep(1,nrow(Xc)),"(Intercept)")); k <- 1L
  if (degree >= 1L) for(i in seq_len(ncol(Z))){k<-k+1L;terms[[k]]<-.mix_term(Z[,i],zn[i])}
  if (degree >= 2L) {
    cmb <- utils::combn(seq_len(ncol(Z)),2L)
    for(i in seq_len(ncol(Z))){k<-k+1L;terms[[k]]<-.mix_term(Z[,i]^2,paste0(zn[i],"^2"))}
    if(ncol(cmb)) for(j in seq_len(ncol(cmb))){i<-cmb[1,j];h<-cmb[2,j];k<-k+1L;terms[[k]]<-.mix_term(Z[,i]*Z[,h],paste0(zn[i],":",zn[h]))}
  }
  if (degree >= 3L) {
    pz <- ncol(Z)
    # all monomials of total degree 3 in the q-1 free Cox coordinates
    expo <- .mix_compositions(3L,pz)
    for(r in seq_len(nrow(expo))){
      v <- rep(1,nrow(Z));labs<-character()
      for(i in seq_len(pz)) if(expo[r,i]>0){v<-v*Z[,i]^expo[r,i];labs<-c(labs,paste0(zn[i],if(expo[r,i]>1)paste0("^",expo[r,i]) else ""))}
      k<-k+1L;terms[[k]]<-.mix_term(v,paste(labs,collapse=":"))
    }
  }
  .mix_bind_terms(terms)
}

.mix_becker_terms <- function(Xc, spec, model, additive_component = NULL) {
  comps <- spec$components; q <- spec$q; terms <- list(); k <- 0L
  add <- function(v,lab){k<<-k+1L;terms[[k]]<<-.mix_term(v,lab)}
  for(i in seq_len(q)) add(Xc[,i],comps[i])
  eligible <- seq_len(q)
  if(model=="additive_blending") {
    if(is.null(additive_component)||!additive_component%in%comps).mix_stop("additive_component is required for additive_blending.")
    eligible <- which(comps != additive_component); model <- "becker_h2"
  }
  if(length(eligible)>=2L){
    cmb<-utils::combn(eligible,2L)
    for(j in seq_len(ncol(cmb))){
      ids<-cmb[,j];xi<-Xc[,ids[1]];xj<-Xc[,ids[2]]
      v<-switch(model,
        becker_h1=pmin(xi,xj),
        becker_h2=ifelse(xi+xj>0,xi*xj/(xi+xj),0),
        becker_h3=sqrt(pmax(0,xi*xj)))
      add(v,paste0(toupper(sub("becker_","",model)),":",comps[ids[1]],":",comps[ids[2]]))
    }
  }
  .mix_bind_terms(terms)
}

#' Build a mixture-model basis matrix
#'
#' Supports classical Scheffe polynomials and several alternative parameterizations
#' discussed in the mixture-experiment literature. Higher-order special/full
#' Scheffe forms follow the canonical term structures used in standard mixture DOE.
#'
#' @param data Data frame containing the mixture components.
#' @param spec A `mix_spec` object.
#' @param model Model basis name.
#' @param process Optional numeric process-variable names.
#' @param process_order Polynomial order for process variables (1 or 2).
#' @param mixture_process If `TRUE`, interact mixture terms with process terms.
#'   To keep the mixture-process model estimable, cross terms are generated for
#'   all mixture columns except constant/intercept columns and the last
#'   component's main effect (whose cross family is collinear with the process
#'   main effects because the components sum to one).
#' @param slack_component Component designated as slack for slack-variable models.
#' @param reference Reference composition for Cox parameterization.
#' @param denominator Denominator component for ratio models.
#' @param inverse_components Components receiving reciprocal terms.
#' @param additive_component Component assumed to blend additively in the Becker-type reduced model.
#' @param gbm_terms List of fixed-exponent general blending terms created by [mix_gbm_term()].
#' @return Numeric design matrix with informative column names.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_design(sp, "simplex_centroid")
#' X <- mix_basis(d$data, sp, model = "scheffe_quadratic")
#' head(X)
#' @export
mix_basis <- function(data, spec,
                      model = c("scheffe_linear", "scheffe_quadratic",
                                "scheffe_special_cubic", "scheffe_cubic",
                                "scheffe_special_quartic", "scheffe_quartic",
                                "slack_linear", "slack_quadratic", "kronecker_quadratic",
                                "inverse_scheffe", "ratio", "cox_linear", "cox_quadratic", "cox_cubic", "logcontrast",
                                "becker_h1", "becker_h2", "becker_h3", "additive_blending", "gbm"),
                      process = NULL, process_order = 2L, mixture_process = FALSE,
                      slack_component = NULL, reference = NULL, denominator = NULL,
                      inverse_components = NULL, additive_component = NULL, gbm_terms = NULL) {
  stopifnot(inherits(spec, "mix_spec"))
  model <- match.arg(model)
  data <- as.data.frame(data, check.names = FALSE)
  if (!all(spec$components %in% names(data))) .mix_stop("data is missing one or more mixture components.")
  Xc <- as.matrix(data[spec$components]); storage.mode(Xc) <- "double"
  if (any(!is.finite(Xc))) .mix_stop("Mixture coordinates must be finite.")

  if (startsWith(model, "scheffe_")) {
    Xm <- .mix_scheffe_terms(Xc, model)
  } else if (model %in% c("slack_linear", "slack_quadratic")) {
    slack_component <- slack_component %||% tail(spec$components, 1L)
    if (!slack_component %in% spec$components) .mix_stop("Unknown slack_component.")
    keep <- setdiff(spec$components, slack_component)
    Z <- as.matrix(data[keep])
    terms <- list(.mix_term(rep(1, nrow(data)), "(Intercept)")); k <- 1L
    for (nm in keep) { k <- k+1L; terms[[k]] <- .mix_term(data[[nm]], nm) }
    if (model == "slack_quadratic") {
      for (nm in keep) { k <- k+1L; terms[[k]] <- .mix_term(data[[nm]]^2, paste0(nm,"^2")) }
      if (length(keep) >= 2L) {
        cmb <- utils::combn(keep, 2L)
        for (j in seq_len(ncol(cmb))) { k<-k+1L; terms[[k]] <- .mix_term(data[[cmb[1,j]]]*data[[cmb[2,j]]], paste(cmb[,j], collapse=":")) }
      }
    }
    Xm <- .mix_bind_terms(terms)
  } else if (model == "kronecker_quadratic") {
    terms <- list(); k <- 0L
    for (i in seq_len(spec$q)) {
      k<-k+1L; terms[[k]] <- .mix_term(Xc[,i]^2, paste0(spec$components[i],"^2"))
    }
    if (spec$q >= 2L) {
      cmb <- utils::combn(spec$q,2L)
      for (j in seq_len(ncol(cmb))) { i<-cmb[1,j]; h<-cmb[2,j]; k<-k+1L; terms[[k]] <- .mix_term(Xc[,i]*Xc[,h], paste0(spec$components[i],":",spec$components[h])) }
    }
    Xm <- .mix_bind_terms(terms)
  } else if (model == "inverse_scheffe") {
    Xm <- .mix_scheffe_terms(Xc, "scheffe_quadratic")
    inverse_components <- inverse_components %||% spec$components
    if (!all(inverse_components %in% spec$components)) .mix_stop("Unknown inverse_components.")
    if (any(as.matrix(data[inverse_components]) <= 0)) .mix_stop("Inverse terms require strictly positive component proportions.")
    Z <- sapply(inverse_components, function(nm) 1/data[[nm]])
    Z <- matrix(Z, nrow = nrow(data), ncol = length(inverse_components))
    colnames(Z) <- paste0("inv:", inverse_components)
    Xm <- cbind(Xm, Z)
  } else if (model == "ratio") {
    denominator <- denominator %||% tail(spec$components,1L)
    if (!denominator %in% spec$components) .mix_stop("Unknown denominator component.")
    if (any(data[[denominator]] <= 0)) .mix_stop("Ratio models require a strictly positive denominator component.")
    num <- setdiff(spec$components, denominator)
    Z <- sapply(num, function(nm) data[[nm]]/data[[denominator]])
    Z <- matrix(Z, nrow = nrow(data), ncol = length(num))
    colnames(Z) <- paste0(num,"/",denominator)
    Xm <- cbind(`(Intercept)`=1, Z)
  } else if (model %in% c("cox_linear","cox_quadratic","cox_cubic")) {
    deg <- match(model,c("cox_linear","cox_quadratic","cox_cubic"))
    Xm <- .mix_cox_polynomial(Xc,spec,reference,degree=deg)
  } else if (model == "logcontrast") {
    if (any(Xc <= 0)) .mix_stop("Log-contrast models require strictly positive component proportions.")
    refidx <- spec$q
    Z <- sapply(seq_len(spec$q-1L), function(i) log(Xc[,i]/Xc[,refidx]))
    Z <- matrix(Z, nrow = nrow(Xc), ncol = spec$q - 1L)
    colnames(Z) <- paste0("log(",spec$components[seq_len(spec$q-1L)],"/",spec$components[refidx],")")
    Xm <- cbind(`(Intercept)`=1, Z)
  } else if (model %in% c("becker_h1", "becker_h2", "becker_h3", "additive_blending")) {
    Xm <- .mix_becker_terms(Xc,spec,model,additive_component=additive_component)
  } else if (model == "gbm") {
    Xm <- .mix_gbm_terms(Xc,spec,gbm_terms=gbm_terms)
  }

  Xp <- .mix_process_terms(data, process, order = process_order)
  if (ncol(Xp)) {
    X <- cbind(Xm, Xp)
    if (isTRUE(mixture_process)) {
      # The mixture constraint makes every component's cross-term family
      # collinear with the corresponding process main effect (sum_i x_i z = z),
      # and any constant/intercept column crossed with a process variable
      # duplicates that process main effect. Exclude the last component's main
      # effect and constant columns so the declared mixture-process model is
      # estimable (Cornell-style leave-one-component-out parameterization).
      const <- apply(Xm, 2L, function(z) diff(range(z)) <= 0)
      drop <- which(const | colnames(Xm) %in% spec$components[spec$q])
      use <- setdiff(seq_len(ncol(Xm)), drop)
      cross <- matrix(numeric(), nrow(data), 0L)
      labs <- character()
      for (i in use) for (j in seq_len(ncol(Xp))) {
        cross <- cbind(cross, Xm[,i]*Xp[,j]); labs <- c(labs,paste0(colnames(Xm)[i],"*",colnames(Xp)[j]))
      }
      colnames(cross) <- labs
      X <- cbind(X,cross)
    }
  } else X <- Xm
  storage.mode(X) <- "double"
  attr(X,"mix_model") <- model
  attr(X,"process") <- process
  X
}
