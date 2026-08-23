.mix_information <- function(X, prior_precision = NULL) {
  M <- crossprod(X)
  if (!is.null(prior_precision)) {
    P <- if (length(prior_precision)==1L) diag(prior_precision,ncol(X)) else as.matrix(prior_precision)
    if(!all(dim(P)==dim(M))) .mix_stop("prior_precision has incompatible dimensions.")
    M <- M + P
  }
  M
}

.mix_design_loss <- function(idx, candidate_mats, eval_mats, criterion,
                             prior_precision=NULL, alternative_mats=NULL,
                             alias_mats=NULL, robust="mean") {
  losses <- numeric(length(candidate_mats))
  for (m in seq_along(candidate_mats)) {
    X <- candidate_mats[[m]][idx,,drop=FALSE]
    if (!criterion %in% c("BayesD","BayesI") && qr(X)$rank < ncol(X)) return(Inf)
    M <- .mix_information(X, if(criterion%in%c("BayesD","BayesI")) prior_precision else NULL)
    Mi <- .mix_safe_inverse(M)
    if (anyNA(Mi)) return(Inf)
    if (criterion %in% c("D","BayesD")) losses[m] <- -.mix_logdet(M)
    else if (criterion == "A") losses[m] <- sum(diag(Mi))
    else if (criterion %in% c("I","BayesI")) {
      F <- eval_mats[[m]]; A <- crossprod(F)/nrow(F); losses[m] <- sum(diag(Mi %*% A))
    } else if (criterion == "G") {
      F <- eval_mats[[m]]; losses[m] <- max(rowSums((F %*% Mi)*F))
    } else if (criterion == "E") {
      losses[m] <- -min(eigen((M+t(M))/2,symmetric=TRUE,only.values=TRUE)$values)
    } else if (criterion == "T") {
      Z <- alternative_mats[[m]][idx,,drop=FALSE]
      P <- X %*% Mi %*% t(X)
      RZ <- Z - P %*% Z
      losses[m] <- -sum(RZ^2)
    } else if (criterion == "Alias") {
      Z <- alias_mats[[m]][idx,,drop=FALSE]
      Aalias <- Mi %*% crossprod(X,Z)
      losses[m] <- sum(Aalias^2)
    } else .mix_stop("Unknown criterion.")
  }
  if(length(losses)==1L) return(losses)
  if(robust=="worst") max(losses) else mean(losses)
}

.mix_exchange_search <- function(start_idx, candidate_mats, eval_mats, criterion,
                                 allow_replicates=TRUE, max_iter=25L, trials=200L,
                                 seed=1L, prior_precision=NULL, alternative_mats=NULL,
                                 alias_mats=NULL, robust="mean") {
  set.seed(seed); idx<-start_idx
  best <- .mix_design_loss(idx,candidate_mats,eval_mats,criterion,prior_precision,alternative_mats,alias_mats,robust)
  nc <- nrow(candidate_mats[[1]])
  for(iter in seq_len(max_iter)) {
    improved<-FALSE
    order_runs<-sample.int(length(idx))
    for(pos in order_runs) {
      cand <- if(nc<=trials) seq_len(nc) else sample.int(nc,trials)
      if(!allow_replicates) cand<-setdiff(cand,idx[-pos])
      local_best<-best; local_val<-idx[pos]
      for(v in cand) {
        if(v==idx[pos]) next
        prop<-idx;prop[pos]<-v
        val<-.mix_design_loss(prop,candidate_mats,eval_mats,criterion,prior_precision,alternative_mats,alias_mats,robust)
        if(is.finite(val)&&val<local_best-1e-10) {local_best<-val;local_val<-v}
      }
      if(local_val!=idx[pos]) {idx[pos]<-local_val;best<-local_best;improved<-TRUE}
    }
    if(!improved) break
  }
  list(idx=idx,loss=best)
}

.mix_ga_search <- function(runs,candidate_mats,eval_mats,criterion,allow_replicates=TRUE,
                           population=40L,generations=60L,seed=1L,prior_precision=NULL,
                           alternative_mats=NULL,alias_mats=NULL,robust="mean") {
  set.seed(seed);nc<-nrow(candidate_mats[[1]])
  make_one<-function() sample.int(nc,runs,replace=allow_replicates)
  pop<-replicate(population,make_one(),simplify=FALSE)
  fitness<-function(z) .mix_design_loss(z,candidate_mats,eval_mats,criterion,prior_precision,alternative_mats,alias_mats,robust)
  vals<-vapply(pop,fitness,numeric(1))
  for(g in seq_len(generations)) {
    elite_n<-max(2L,ceiling(population*0.2)); elite<-pop[order(vals)[seq_len(elite_n)]]
    newpop<-elite
    while(length(newpop)<population) {
      p1<-elite[[sample.int(elite_n,1)]];p2<-elite[[sample.int(elite_n,1)]]
      cut<-if(runs>1L) sample.int(runs-1L,1L) else 1L
      child<-if(runs>1L)c(p1[seq_len(cut)],p2[(cut+1L):runs]) else p1
      if(runif(1)<0.7) child[sample.int(runs,1)]<-sample.int(nc,1)
      if(!allow_replicates && anyDuplicated(child)) child<-sample.int(nc,runs,replace=FALSE)
      newpop[[length(newpop)+1L]]<-child
    }
    pop<-newpop;vals<-vapply(pop,fitness,numeric(1))
  }
  j<-which.min(vals);list(idx=pop[[j]],loss=vals[j])
}

#' Construct exact optimal mixture designs
#'
#' @param spec Mixture specification.
#' @param model Primary model basis or vector of model names for model-robust design.
#' @param runs Number of exact design runs.
#' @param criterion Optimality criterion: D, A, I, G, E, T, Alias, BayesD, or BayesI.
#' @param algorithm `exchange`, `ga`, or `hybrid`.
#' @param candidates Optional candidate data frame. If omitted, a feasible grid plus random points is generated.
#' @param evaluation Optional prediction-evaluation grid for I/G criteria.
#' @param resolution Simplex grid resolution.
#' @param random_candidates Additional random feasible candidates.
#' @param process Optional named list of process levels to cross with mixture candidates.
#' @param process_order Process polynomial order.
#' @param mixture_process Include mixture-process interactions.
#' @param allow_replicates Allow replicated exact design points.
#' @param robust `mean` or `worst` aggregation across multiple candidate models.
#' @param prior_precision Prior precision matrix/scalar for BayesD/BayesI linear-normal criteria.
#' @param alternative_model Alternative model for T-optimal discrimination.
#' @param alias_model Higher-order model supplying omitted columns for Alias criterion.
#' @param starts Number of independent starts.
#' @param max_iter Exchange iterations.
#' @param population GA population size.
#' @param generations GA generations.
#' @param seed Random seed.
#' @return A `mix_design` with optimality metadata.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' od <- mix_optimal_design(sp, model = "scheffe_quadratic", runs = 8, criterion = "D",
#'                          algorithm = "exchange", resolution = 5, random_candidates = 20,
#'                          starts = 1, max_iter = 2, seed = 19)
#' od
#' @export
mix_optimal_design <- function(spec,model="scheffe_quadratic",runs,
                               criterion=c("D","A","I","G","E","T","Alias","BayesD","BayesI"),
                               algorithm=c("hybrid","exchange","ga"),candidates=NULL,evaluation=NULL,
                               resolution=12L,random_candidates=1000L,process=NULL,process_order=2L,
                               mixture_process=FALSE,allow_replicates=TRUE,robust=c("mean","worst"),
                               prior_precision=NULL,alternative_model=NULL,alias_model=NULL,
                               starts=3L,max_iter=20L,population=40L,generations=50L,seed=1L) {
  stopifnot(inherits(spec,"mix_spec"));criterion<-match.arg(criterion);algorithm<-match.arg(algorithm);robust<-match.arg(robust)
  runs<-as.integer(runs);if(runs<1L).mix_stop("runs must be positive.")
  models<-as.character(model)
  cand<-candidates %||% .mix_candidate_grid(spec,resolution,random_candidates,seed)
  if(!is.null(process)) cand<-merge(cand,expand.grid(process,KEEP.OUT.ATTRS=FALSE),by=NULL)
  if(nrow(cand)<2L).mix_stop("Too few feasible candidate points.")
  eval<-evaluation %||% .mix_candidate_grid(spec,max(resolution,15L),min(random_candidates,2000L),seed+11L)
  if(!is.null(process)) eval<-merge(eval,expand.grid(process,KEEP.OUT.ATTRS=FALSE),by=NULL)
  cmats<-lapply(models,function(m)mix_basis(cand,spec,m,process=if(is.null(process))NULL else names(process),process_order=process_order,mixture_process=mixture_process))
  emats<-lapply(models,function(m)mix_basis(eval,spec,m,process=if(is.null(process))NULL else names(process),process_order=process_order,mixture_process=mixture_process))
  if(any(vapply(cmats,ncol,integer(1))>runs)) .mix_warn("runs is smaller than the number of parameters for at least one candidate model; singular designs will be rejected.")
  altmats<-aliasmats<-NULL
  if(criterion=="T") {
    if(is.null(alternative_model)).mix_stop("alternative_model is required for T-optimality.")
    altmats<-lapply(seq_along(models),function(i)mix_basis(cand,spec,alternative_model,process=if(is.null(process))NULL else names(process),process_order=process_order,mixture_process=mixture_process))
  }
  if(criterion=="Alias") {
    if(is.null(alias_model)).mix_stop("alias_model is required for Alias criterion.")
    aliasmats<-lapply(seq_along(models),function(i){Z<-mix_basis(cand,spec,alias_model,process=if(is.null(process))NULL else names(process),process_order=process_order,mixture_process=mixture_process);Z[,setdiff(colnames(Z),colnames(cmats[[i]])),drop=FALSE]})
  }
  best<-list(loss=Inf,idx=NULL)
  for(s in seq_len(as.integer(starts))) {
    set.seed(seed+s-1L)
    init<-sample.int(nrow(cand),runs,replace=allow_replicates)
    if(algorithm%in%c("ga","hybrid")) {
      z<-.mix_ga_search(runs,cmats,emats,criterion,allow_replicates,population,generations,seed+s-1L,prior_precision,altmats,aliasmats,robust)
    } else z<-list(idx=init,loss=Inf)
    if(algorithm%in%c("exchange","hybrid")) {
      z<-.mix_exchange_search(if(is.null(z$idx))init else z$idx,cmats,emats,criterion,allow_replicates,max_iter,200L,seed+100L+s,prior_precision,altmats,aliasmats,robust)
    }
    if(is.finite(z$loss)&&z$loss<best$loss)best<-z
  }
  if(is.null(best$idx)).mix_stop("No nonsingular optimal design was found. Increase runs or candidate diversity.")
  X<-cand[best$idx,,drop=FALSE];rownames(X)<-NULL;X$.run<-seq_len(nrow(X))
  .mix_design_object(X,spec,"optimal",list(model=models,criterion=criterion,algorithm=algorithm,
      objective=best$loss,robust=robust,seed=seed,candidate_n=nrow(cand),evaluation_n=nrow(eval),
      process=process,process_order=process_order,mixture_process=mixture_process))
}

#' Evaluate information and prediction-variance properties of a mixture design
#'
#' @param design A `mix_design` or data frame.
#' @param spec Mixture specification when `design` is a data frame.
#' @param model Model basis.
#' @param evaluation Optional prediction-evaluation set.
#' @param resolution Evaluation-grid resolution.
#' @param process Optional process-variable names.
#' @param process_order Process polynomial order.
#' @param mixture_process Include mixture-process interactions.
#' @param reference Optional reference design for relative efficiency calculations.
#' @return A `mix_design_evaluation` object containing information criteria, FDS, and VDG data.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_design(sp, "simplex_lattice", degree = 3)
#' ev <- mix_design_eval(d, model = "scheffe_quadratic", resolution = 8)
#' head(ev$fds)
#' @export
mix_design_eval <- function(design,spec=NULL,model="scheffe_quadratic",evaluation=NULL,resolution=15L,
                            process=NULL,process_order=2L,mixture_process=FALSE,reference=NULL) {
  if(inherits(design,"mix_design")){spec<-spec%||%design$spec;dat<-design$data}else dat<-as.data.frame(design,check.names=FALSE)
  if(is.null(spec)).mix_stop("A mix_spec is required.")
  X<-mix_basis(dat,spec,model,process=process,process_order=process_order,mixture_process=mixture_process)
  rank<-qr(X)$rank;p<-ncol(X);n<-nrow(X)
  if(rank<p).mix_stop("Design is rank deficient for the requested model.")
  M<-crossprod(X);Mi<-.mix_safe_inverse(M)
  ev<-eigen((M+t(M))/2,symmetric=TRUE,only.values=TRUE)$values
  eval<-evaluation%||%.mix_candidate_grid(spec,resolution,1000L,11L)
  # If process variables are in model but not supplied in evaluation, use observed unique combinations.
  if(length(process)&&!all(process%in%names(eval))){pg<-unique(dat[process]);eval<-merge(eval,pg,by=NULL)}
  F<-mix_basis(eval,spec,model,process=process,process_order=process_order,mixture_process=mixture_process)
  pv<-rowSums((F%*%Mi)*F)
  fds<-data.frame(fraction=seq_along(pv)/length(pv),prediction_variance=sort(pv))
  Y<-mix_transform(eval[spec$components],spec);radius<-sqrt(rowSums(Y^2))
  bins<-cut(radius,breaks=unique(stats::quantile(radius,probs=seq(0,1,length.out=11),na.rm=TRUE)),include.lowest=TRUE)
  vdg<-do.call(rbind,lapply(split(pv,bins),function(z)data.frame(n=length(z),mean=mean(z),q50=stats::median(z),q90=stats::quantile(z,.9),max=max(z))))
  measures<-c(D=exp(.mix_logdet(M)/p)/n,A=sum(diag(Mi)),I=mean(pv),G=max(pv),E=min(ev)/n,condition=max(ev)/min(ev))
  eff<-NULL
  if(!is.null(reference)){
    r<-mix_design_eval(reference,spec=spec,model=model,evaluation=eval,process=process,process_order=process_order,mixture_process=mixture_process)
    eff<-c(D=measures["D"]/r$measures["D"],A=r$measures["A"]/measures["A"],I=r$measures["I"]/measures["I"],G=r$measures["G"]/measures["G"],E=measures["E"]/r$measures["E"])
  }
  out<-list(measures=measures,relative_efficiency=eff,fds=fds,vdg=vdg,prediction_variance=pv,rank=rank,p=p,n=n,model=model,spec=spec)
  class(out)<-"mix_design_evaluation";out
}

#' @export
print.mix_design_evaluation <- function(x,...) {cat("<mix_design_evaluation>\n");print(round(x$measures,6));if(!is.null(x$relative_efficiency)){cat("Relative efficiencies:\n");print(round(x$relative_efficiency,4))};invisible(x)}

#' Augment an existing design according to an information objective
#'
#' @param design Existing `mix_design`.
#' @param n_new Number of additional runs.
#' @param model Model basis.
#' @param objective `D`, `I`, `G`, or `optimum_uncertainty`.
#' @param fit Optional fitted model required for optimum-focused augmentation.
#' @param resolution Candidate resolution.
#' @param seed Random seed.
#' @param candidates Maximum number of candidate compositions scored per added
#'   run; smaller sets keep the example fast while the default explores more of
#'   the region.
#' @return Augmented `mix_design`.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_design(sp, "simplex_centroid")
#' a <- mix_augment(d, n_new = 1, model = "scheffe_quadratic", objective = "D", resolution = 6)
#' nrow(a$data)
#' @export
mix_augment <- function(design,n_new=1L,model="scheffe_quadratic",objective=c("D","I","G","optimum_uncertainty"),fit=NULL,resolution=15L,seed=1L,candidates=2000L) {
  if(!inherits(design,"mix_design")).mix_stop("design must be a mix_design.")
  objective<-match.arg(objective);spec<-design$spec;current<-design$data
  cand<-.mix_candidate_grid(spec,resolution,as.integer(candidates),seed)
  eval<-cand
  # Precompute the evaluation-grid basis once; the objective loop below would
  # otherwise rebuild it for every candidate (thousands of times).
  F<-if(objective%in%c("I","G")) mix_basis(eval,spec,model) else NULL
  for(k in seq_len(as.integer(n_new))){
    scores<-rep(Inf,nrow(cand))
    for(i in seq_len(nrow(cand))){
      d<-rbind(current[spec$components],cand[i,,drop=FALSE]);X<-mix_basis(d,spec,model);if(qr(X)$rank<ncol(X))next
      Mi<-.mix_safe_inverse(crossprod(X))
      if(objective=="D") scores[i]<--.mix_logdet(crossprod(X))
      else if(objective=="I"){scores[i]<-mean(rowSums((F%*%Mi)*F))}
      else if(objective=="G"){scores[i]<-max(rowSums((F%*%Mi)*F))}
      else {
        if(is.null(fit)).mix_stop("fit is required for optimum_uncertainty augmentation.")
        opt<-mix_optimize(fit,method="grid",grid_resolution=resolution)
        Fo<-mix_basis(as.data.frame(t(opt$composition)),spec,fit$model);scores[i]<-drop(Fo%*%Mi%*%t(Fo))
      }
    }
    j<-which.min(scores);current<-rbind(current[spec$components],cand[j,,drop=FALSE])
  }
  current$.run<-seq_len(nrow(current));.mix_design_object(current,spec,"augmented",list(parent_type=design$type,n_new=n_new,objective=objective,seed=seed))
}
