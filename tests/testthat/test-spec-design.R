test_that("specification and transformations preserve the simplex", {
  sp <- mix_spec(c("A","B","C"))
  expect_s3_class(sp,"mix_spec")
  X <- data.frame(A=c(.2,.4),B=c(.3,.1),C=c(.5,.5))
  Y <- mix_transform(X,sp)
  X2 <- mix_inverse_transform(Y,sp)
  expect_equal(as.matrix(X2[c("A","B","C")]),as.matrix(X),tolerance=1e-10)
  expect_equal(rowSums(X2[c("A","B","C")]),rep(1,2),tolerance=1e-12)
})

test_that("classical design sizes are correct", {
  sp <- mix_spec(c("A","B","C"))
  sc <- mix_design(sp,"simplex_centroid")
  sl <- mix_design(sp,"simplex_lattice",degree=3)
  expect_equal(nrow(sc$data),7L)
  expect_equal(nrow(sl$data),choose(3+3-1,3-1))
  expect_true(all(abs(rowSums(sl$data[sp$components])-1)<1e-12))
})

test_that("extreme vertices satisfy component and linear constraints", {
  sp <- mix_spec(c("A","B","C"),lower=c(.1,.1,.1),upper=c(.7,.8,.8),
                 A=matrix(c(1,1,0),1),b=.75,dir="<=")
  V <- mix_vertices(sp)
  expect_gt(nrow(V),0)
  expect_true(all(V$A>=.1-1e-8 & V$A<=.7+1e-8))
  expect_true(all(V$A+V$B<=.75+1e-8))
  expect_equal(rowSums(V),rep(1,nrow(V)),tolerance=1e-7)
})

test_that("pseudocomponent transformations round-trip", {
  sp <- mix_spec(c("A","B","C"),lower=c(.1,.1,.1),upper=c(.7,.8,.8))
  X <- data.frame(A=.2,B=.3,C=.5)
  L <- mix_pseudocomponents(X,sp,"L")
  expect_equal(mix_pseudocomponents(L,sp,"L",inverse=TRUE),X,tolerance=1e-10)
  U <- mix_pseudocomponents(X,sp,"U")
  expect_equal(mix_pseudocomponents(U,sp,"U",inverse=TRUE),X,tolerance=1e-10)
})
