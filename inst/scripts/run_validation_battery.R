#!/usr/bin/env Rscript
# Frozen core validation battery. Designed to be run from the package source
# after installation/loading. It writes results rather than modifying package code.

args <- commandArgs(trailingOnly = TRUE)
outfile <- if (length(args)) args[[1L]] else "mixRSMflow_validation_results.csv"

if (!requireNamespace("mixRSMflow", quietly = TRUE)) {
  stop("Install mixRSMflow before running this validation battery.")
}

library(mixRSMflow)
results <- list(); add <- function(id, metric, value, target, pass, note="") {
  results[[length(results)+1L]] <<- data.frame(scenario_id=id,metric=metric,value=as.character(value),
    target=as.character(target),pass=as.logical(pass),note=note,stringsAsFactors=FALSE)
}

# S01: exact coefficient recovery.
sp <- mix_spec(c("A","B","C"))
f <- system.file("extdata","golden_scheffe_quadratic.csv",package="mixRSMflow")
d <- utils::read.csv(f)
fit <- mix_fit("y",d,sp,"scheffe_quadratic")
truth <- c(A=2,B=4,C=6,`A:B`=3,`A:C`=-2,`B:C`=1)
err <- max(abs(coef(fit)-truth))
add("S01","max_abs_coefficient_error",err,"<=1e-8",is.finite(err)&&err<=1e-8)

# S03: all returned vertices obey declared constraints.
spc <- mix_spec(c("A","B","C"),lower=c(.1,.1,.1),upper=c(.7,.8,.8),
                A=matrix(c(1,1,0),1),b=.75,dir="<=")
V <- mix_vertices(spc)
viol <- max(c(abs(rowSums(V)-1),pmax(.1-as.matrix(V),0),pmax(as.matrix(V)-matrix(spc$upper,nrow(V),3,byrow=TRUE),0),pmax(V$A+V$B-.75,0)))
add("S03","max_constraint_violation",viol,"<=1e-7",is.finite(viol)&&viol<=1e-7)

# S06: IMSE decomposition identity.
des <- mix_design(sp,"simplex_lattice",degree=3)
im <- mix_imse(des,fitted_model="scheffe_quadratic",true_model="scheffe_special_cubic",
               beta_omitted=c(`A:B:C`=2),sigma2=.25,resolution=10)
delta <- abs(im$imse-(im$integrated_variance+im$integrated_squared_bias))
add("S06","imse_decomposition_error",delta,"<=1e-12",is.finite(delta)&&delta<=1e-12)

# S10: GBM identity with Scheffe pairwise term.
x <- data.frame(A=.2,B=.3,C=.5)
t <- mix_gbm_term(c("A","B"),g=c(2,2),h=.5,s=2,label="AB")
xb <- mix_basis(x,sp,"gbm",gbm_terms=list(t))
delta <- abs(xb[1,"AB"]-.2*.3)
add("S10","gbm_scheffe_identity_error",delta,"<=1e-12",is.finite(delta)&&delta<=1e-12)

res <- do.call(rbind,results)
utils::write.csv(res,outfile,row.names=FALSE)
cat("Validation results written to",normalizePath(outfile,mustWork=FALSE),"\n")
print(res)
if (any(!res$pass)) quit(status=1L)
