test_that("bounded optimization stays on the feasible simplex", {
  sp <- mix_spec(c("A","B","C"),lower=c(.05,.05,.05),upper=c(.8,.8,.8))
  # The augmented-centroid demo data loses all boundary blends after filtering
  # to the bounded region, leaving a rank-deficient quadratic basis. A degree-5
  # lattice filtered by mix_design() provides 6 interior points spanning the
  # feasible region.
  d <- mix_design(sp,"simplex_lattice",degree=5)$data
  # Duplicate each blend once so the quadratic fit keeps residual degrees of
  # freedom (a saturated 6x6 fit makes parametric quantiles degenerate).
  d <- d[rep(seq_len(nrow(d)),each=2),]
  d$response <- with(d, 4.7*A + 6.3*B + 7.2*C + 2.2*A*B - 2.5*A*C)
  fit <- mix_fit("response",d,sp,"scheffe_quadratic")
  op <- mix_optimize(fit,"maximize",grid_resolution=12,method="grid")
  expect_s3_class(op,"mix_optimum")
  expect_equal(sum(op$composition),1,tolerance=1e-7)
  expect_true(all(op$composition>=sp$lower-1e-7 & op$composition<=sp$upper+1e-7))
})

test_that("multiresponse optimizer returns desirability and Pareto set", {
  sp <- mix_spec(c("A","B","C"))
  d <- mix_demo_data("multiresponse",n_rep=1,seed=13)
  mf <- mix_multi_fit(c("quality","stability"),d,sp,model="scheffe_quadratic")
  mo <- mix_multiopt(mf,goals=c(quality="maximize",stability="maximize"),
                     settings=list(quality=list(low=min(d$quality),high=max(d$quality)),
                                   stability=list(low=min(d$stability),high=max(d$stability))),resolution=9)
  expect_s3_class(mo,"mix_multiopt")
  expect_true(mo$overall>=0 && mo$overall<=1)
  expect_gt(nrow(mo$pareto),0)
})
