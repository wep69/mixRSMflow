test_that("scientifically invalid requests fail explicitly", {
  sp <- mix_spec(c("A","B","C"))
  expect_error(mix_basis(data.frame(A=.2,B=.3,C=.5),sp,"ratio",denominator="C"),NA)
  expect_error(mix_basis(data.frame(A=.2,B=.8,C=0),sp,"logcontrast"),"strictly positive")
  expect_error(mix_fit("missing",data.frame(A=.2,B=.3,C=.5),sp),"Response column")
  expect_error(mix_optimal_design(sp,runs=2,model="scheffe_quadratic",starts=1,max_iter=1,random_candidates=20,resolution=3),"No nonsingular")
})
