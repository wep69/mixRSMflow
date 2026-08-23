test_that("design evaluation computes FDS and prediction variance", {
  sp <- mix_spec(c("A","B","C"))
  d <- mix_design(sp,"simplex_centroid")
  ev <- mix_design_eval(d,model="scheffe_quadratic",resolution=8)
  expect_s3_class(ev,"mix_design_evaluation")
  expect_gt(nrow(ev$fds),10)
  expect_true(all(is.finite(ev$prediction_variance)))
})

test_that("IMSE separates integrated variance and specified bias", {
  sp <- mix_spec(c("A","B","C"))
  d <- mix_design(sp,"simplex_lattice",degree=3)
  iv <- mix_imse(d,fitted_model="scheffe_quadratic",true_model="scheffe_special_cubic",
                 beta_omitted=c(`A:B:C`=2),sigma2=.25,resolution=8)
  expect_s3_class(iv,"mix_imse")
  expect_true(iv$integrated_variance>0)
  expect_true(iv$integrated_squared_bias>=0)
  expect_equal(iv$imse,iv$integrated_variance+iv$integrated_squared_bias,tolerance=1e-12)
})

test_that("optimal design returns feasible requested run count", {
  sp <- mix_spec(c("A","B","C"))
  od <- mix_optimal_design(sp,model="scheffe_quadratic",runs=8,criterion="D",
                           algorithm="exchange",resolution=7,max_iter=100,seed=5)
  expect_s3_class(od,"mix_design")
  expect_equal(nrow(od$data),8L)
  expect_equal(rowSums(od$data[sp$components]),rep(1,8),tolerance=1e-7)
})
