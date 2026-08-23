test_that("Scheffe bases contain expected terms", {
  sp <- mix_spec(c("A","B","C"))
  d <- data.frame(A=c(1,.5,0),B=c(0,.5,.5),C=c(0,0,.5))
  q <- mix_basis(d,sp,"scheffe_quadratic")
  expect_equal(ncol(q),6L)
  expect_true(all(c("A","B","C","A:B","A:C","B:C") %in% colnames(q)))
  sc <- mix_basis(d,sp,"scheffe_special_cubic")
  expect_true("A:B:C" %in% colnames(sc))
})

test_that("general blending basis reproduces important special cases", {
  sp <- mix_spec(c("A","B","C"))
  d <- data.frame(A=.2,B=.3,C=.5)
  # Scheffe quadratic cross-product: h=.5, g=2, s=2
  t1 <- mix_gbm_term(c("A","B"),g=c(2,2),h=.5,s=2,label="ABscheffe")
  X1 <- mix_basis(d,sp,"gbm",gbm_terms=list(t1))
  expect_equal(unname(X1[1,"ABscheffe"]),.2*.3,tolerance=1e-12)
  # Becker H2: h=.5, g=2, s=1
  t2 <- mix_gbm_term(c("A","B"),g=c(2,2),h=.5,s=1,label="ABh2")
  X2 <- mix_basis(d,sp,"gbm",gbm_terms=list(t2))
  expect_equal(unname(X2[1,"ABh2"]),.2*.3/(.2+.3),tolerance=1e-12)
  # Becker H3: h=.5, g=1, s=1
  t3 <- mix_gbm_term(c("A","B"),g=c(1,1),h=.5,s=1,label="ABh3")
  X3 <- mix_basis(d,sp,"gbm",gbm_terms=list(t3))
  expect_equal(unname(X3[1,"ABh3"]),sqrt(.2*.3),tolerance=1e-12)
})

test_that("Cox and log-contrast bases use q-1 independent coordinates", {
  sp <- mix_spec(c("A","B","C"))
  d <- data.frame(A=c(.2,.3),B=c(.3,.2),C=.5)
  expect_equal(ncol(mix_basis(d,sp,"cox_linear")),3L)
  expect_equal(ncol(mix_basis(d,sp,"logcontrast")),3L)
})
