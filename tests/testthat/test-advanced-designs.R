test_that("multiple-lattice and categorized designs obey mixture totals", {
  sp <- mix_spec(c("A1","A2","B1","B2"))
  ml <- mix_multiple_lattice(sp,major=c("A1","A2"),minor=c("B1","B2"),
                             major_totals=c(.4,.6),major_degree=2,minor_degree=2)
  expect_true(all(abs(rowSums(ml$data[sp$components])-1)<1e-8))
  # categories is documented as a named list of component vectors.
  catd <- mix_categorized_design(sp,categories=list(A=c("A1","A2"),B=c("B1","B2")),
                                 between_degree=2,within_degree=2)
  expect_true(all(abs(rowSums(catd$data[sp$components])-1)<1e-8))
})

test_that("Latin square process construction is balanced", {
  sp <- mix_spec(c("A","B","C"))
  ld <- mix_latin_process_design(sp,list(temp=c(20,30,40)),list(time=c(1,2,3)))
  expect_equal(nrow(ld$data),9L)
  # table() carries dim/dimnames attributes; compare the bare integer counts.
  expect_equal(unname(as.integer(sort(table(ld$data$.latin_treatment)))),rep(3L,3))
})

test_that("split plot encodes whole plot units", {
  sp <- mix_spec(c("A","B","C"))
  d <- mix_design(sp,"split_plot",base_type="simplex_centroid",
                  process=list(temp=c(20,40),speed=c(1,2)),hard_to_change="temp")
  expect_true(all(c(".whole_plot",".subplot") %in% names(d$data)))
  expect_equal(length(unique(d$data$.whole_plot)),2L)
})

test_that("model-based mixture-process fractionation preserves requested run count and estimability metadata", {
  sp <- mix_spec(c("A","B","C"))
  full <- mix_design(sp,"mixture_process",base_type="simplex_centroid",
                     process=list(temp=c(-1,0,1),speed=c(-1,1)))
  frac <- mix_fractionate_process(full,process=c("temp","speed"),fraction=0.6,
                                  model="scheffe_linear",process_order=1,
                                  mixture_process=TRUE,seed=4)
  expect_s3_class(frac,"mix_design")
  expect_equal(nrow(frac$data),floor(0.6*nrow(full$data)))
  expect_equal(frac$metadata$fractionation,"D-information")
  expect_true(all(abs(rowSums(frac$data[sp$components])-1)<1e-10))
})
