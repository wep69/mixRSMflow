test_that("Gaussian Scheffe fit recovers deterministic coefficients", {
  sp <- mix_spec(c("A","B","C"))
  d <- mix_design(sp,"simplex_lattice",degree=4)$data
  X <- mix_basis(d,sp,"scheffe_quadratic")
  beta <- c(A=2,B=4,C=6,`A:B`=3,`A:C`=-2,`B:C`=1)
  d$y <- drop(X %*% beta)
  fit <- mix_fit("y",d,sp,model="scheffe_quadratic")
  expect_equal(coef(fit),beta,tolerance=1e-9)
  expect_equal(mix_predict(fit,d)$.prediction,d$y,tolerance=1e-9)
})

test_that("replicates permit pure-error and lack-of-fit decomposition", {
  sp <- mix_spec(c("A","B","C"))
  d0 <- mix_design(sp,"simplex_centroid")$data
  d <- d0[rep(seq_len(nrow(d0)),each=2),]
  d$y <- with(d,2*A+4*B+5*C+A*B) + rep(c(-.02,.02),nrow(d0))
  fit <- mix_fit("y",d,sp,"scheffe_quadratic")
  a <- mix_anova(fit)
  expect_true(all(c("Pure error","Lack of fit") %in% a$source))
  expect_gte(a$df[a$source=="Pure error"],1)
})

test_that("diagnostics expose conditioning and leverage", {
  sp <- mix_spec(c("A","B","C"))
  d <- mix_demo_data("mixture",n_rep=1,seed=7)
  fit <- mix_fit("response",d,sp,"scheffe_quadratic")
  dg <- mix_diagnose(fit)
  expect_true(is.finite(dg$condition_number))
  expect_equal(nrow(dg$observations),nrow(d))
  cc <- mix_collinearity(fit)
  # mix_collinearity() reports its scalar diagnostic as max_condition_index.
  expect_true(is.finite(cc$max_condition_index))
})
