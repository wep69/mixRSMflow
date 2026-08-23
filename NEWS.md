# mixRSMflow 0.1.0.9000

* Initial development source snapshot.
* Added bounded mixture specification, general linear restrictions, L/U pseudocomponents, extreme-vertex enumeration, and independent-coordinate regions.
* Added simplex-lattice, simplex-centroid, axial, augmented, symmetric-simplex, extreme-vertices, multiple-lattice, categorized-component, mixture-process, mixture-amount, split-plot, blocked, and Latin-square process design constructors.
* Added Scheffe linear through quartic families plus slack-variable, inverse, ratio, Cox, log-contrast, Becker/general-blending, additive-blending, and Kronecker bases.
* Added Gaussian/GLM fits and optional GLS, mixed-effects, and Bayesian backends.
* Added lack-of-fit/pure-error decomposition, collinearity diagnostics, hierarchical model reduction, component screening, Cox/Piepel effects, and segmented fits.
* Added D/A/I/G/E/T/Alias/Bayesian optimal-design criteria, model-robust aggregation, exchange/GA/hybrid search, FDS, VDG, rotatability diagnostics, and sequential augmentation.
* Added constrained optimization, GA search, optimum-location uncertainty, near-optimal regions, desirability, response constraints, Pareto approximation, biplots, and optional GP Bayesian optimization.
* Added publication-oriented vector 3D mixture surfaces, ternary contours, Plotly backends, reporting, a Shiny teaching interface, simulated datasets, and a capability registry.

## Local runtime validation fixes

* Single-row ratio, Cox, log-contrast, and inverse bases previously failed with
  a `dimnames` mismatch; they now build the correct column shape for any number
  of rows.
* The mixture-process basis (`mixture_process = TRUE`) generated all
  component-by-process cross terms, which are collinear with the process main
  effects because components sum to one; cross terms now omit constant columns
  and the last component's main effect so the declared model is estimable.
* `mix_design_eval()` now returns `prediction_variance` as a numeric vector
  instead of a data frame.
* The mixture-specification centre is now corrected to sum exactly to the
  mixture total; `mix_transform()`/`mix_inverse_transform()` round trips are
  exact to machine precision instead of inheriting the ~1e-8 bisection
  tolerance.
* `mix_augment()` no longer fails with an `rbind` column mismatch when the
  parent design carries an auxiliary `.run` column; the same alignment bug in
  the `mix_bo()` sequential-objective path was fixed by padding new rows to
  the observation table's columns. `mix_augment()` also gained a `candidates`
  argument, and its I/G objectives precompute the evaluation-grid basis
  instead of rebuilding it for every candidate.
* `mix_optimum_ci()` now optimizes on the declared grid instead of adding five
  thousand random candidates per call, samples a 1000-point uncertainty cloud,
  and only warns about few successful replicates when fewer than 20% succeed.
* `mix_fit_bayes()` now defaults to `brms::brmsfamily("gaussian")` instead of
  the unexported `brms::gaussian`, removing the `R CMD check` dependency
  warning.
* The mixture-process vignette now declares `process_order = 1` for its
  two-level process factors: a quadratic process model is rank deficient on
  that crossed design, and the vignette explains why.
* The Shiny interface no longer embeds non-ASCII arrow characters, keeping all
  R code files portable ASCII.
* `inst/scripts/validate_local.R` sets `R_LIBS_USER` through `Sys.setenv()`
  before running the frozen battery: `system2(env = ...)` entries were not
  reliably promoted to child environment variables on Windows, which made the
  battery fail to locate the freshly installed build.
* Vignette files were renamed from `NN-*.Rmd` to `vNN-*.Rmd` because
  `R CMD check` requires vignette file names to start with a letter.
* S3 method help pages now use `\method{generic}{class}` markup in their
  `\usage` sections, and all `...` arguments are documented.
* Every exported function now has at least three usage examples in its manual
  page and at least three executed calls across the vignettes (a runtime-
  verified example index was added to the validation vignette).
* The maintainer placeholder was replaced with the real author and contact in
  `DESCRIPTION`.
