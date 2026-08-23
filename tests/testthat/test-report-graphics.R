test_that("markdown scientific report is generated without external converters", {
  sp <- mix_spec(c("A","B","C"))
  d <- mix_demo_data("mixture",n_rep=1,seed=17)
  fit <- mix_fit("response",d,sp,"scheffe_quadratic")
  f <- tempfile(fileext=".md")
  r <- mix_report(fit,file=f,format="markdown")
  expect_true(file.exists(f))
  expect_s3_class(r,"mix_report")
  expect_match(paste(readLines(f,warn=FALSE),collapse="\n"),"Reproducibility")
})

test_that("ternary plot returns a ggplot object", {
  sp <- mix_spec(c("A","B","C"))
  d <- mix_demo_data("mixture",n_rep=1,seed=19)
  fit <- mix_fit("response",d,sp,"scheffe_quadratic")
  p <- mix_plot(fit,"ternary_contour",engine="ggplot2",resolution=10)
  expect_s3_class(p,"ggplot")
})
