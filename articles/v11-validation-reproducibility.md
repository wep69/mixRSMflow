# Validation, benchmarking and reproducibility

## mixRSMflow: Validation, Benchmarking, Reproducibility, and Scientific Release Gates

**Extended instructional vignette**  
**Package:** `mixRSMflow`  
**Version targeted:** `0.1.0.9000`  
**Extended vignette:** 33  
**Format:** Markdown source only  
**Primary ownership:** scientific software validation, mathematical
invariants, unit/golden/frozen tests, simulation scenarios, design
benchmarks, stochastic reproducibility, graphics validation,
optional-backend gates, local R validation, source build/check, CI
strategy, metadata verification, audit trails, and release
classification  
**Companion material:** `21-validation-and-benchmarks.Rmd`,
`22-reproducibility.Rmd`, `VALIDATION.md`, `RELEASE_CHECKLIST.md`,
`inst/METHOD_GATES.md`

> This document is intentionally supplied as `.md`. A software
> capability is not labeled validated merely because code exists. Static
> checks, runtime tests, scientific simulations, optional-backend
> checks, and release checks are reported as separate gates.

> **Scope boundary.** This extended vignette owns the topic named in its
> title. Closely related methods that belong to another extended
> vignette are referenced rather than re-taught. This separation is
> deliberate so that the extended documentation remains deep without
> becoming repetitive.

------------------------------------------------------------------------

### 1. Why scientific package validation must be layered

A function can parse correctly and still compute the wrong result. A
numerical algorithm can return the correct answer for one example and
fail near a boundary. A package can pass unit tests and still fail to
install from its built tarball. A method can work in the core engine
while an optional backend silently changes the estimand.

For a scientific package, validation therefore needs several distinct
layers.

The central rule is:

**Never collapse implementation status, static validation, numerical
validation, statistical validation, backend validation, and release
validation into one word such as “tested.”**

------------------------------------------------------------------------

### 2. Learning objectives

After this vignette, the reader should be able to:

1.  explain the difference between implementation and validation;
2.  use mathematical invariants to test mixture geometry;
3.  design golden tests with analytically known results;
4.  use frozen scenarios for regression testing;
5.  construct simulation batteries for bias, coverage, prediction, and
    optimum recovery;
6.  validate stochastic algorithms under fixed seeds and repeated seeds;
7.  benchmark design algorithms on common regions and models;
8.  distinguish algorithm quality from runtime performance;
9.  validate vector and raster graphics independently of statistical
    numbers;
10. treat optional backends as capability-specific validation targets;
11. inspect the package capability registry and method gates;
12. use audit trails and session information for reproducibility;
13. execute local source build, clean installation, frozen battery, and
    `R CMD check --as-cran`;
14. interpret ERROR, WARNING, and NOTE correctly;
15. distinguish a source snapshot from a real `R CMD build` tarball;
16. define PASS, CONDITIONAL PASS, and FAIL release states;
17. organize a permanent validation dossier.

------------------------------------------------------------------------

### 3. Validation architecture

| Layer | Question |
|:---|:---|
| Static source audit | Are exports, arguments, Rd files, and structure internally consistent? |
| Parse/load | Does R parse and load the code? |
| Unit tests | Do individual contracts and edge cases behave correctly? |
| Mathematical invariants | Are fixed-sum and constraint identities always satisfied? |
| Golden tests | Does the package reproduce known analytical results? |
| Frozen numerical battery | Do canonical scenarios remain stable across code changes? |
| Simulation validation | Does the method have expected statistical behavior? |
| Cross-backend comparison | Do equivalent supported backends agree when they should? |
| Graphics validation | Do files render correctly and represent correct numeric objects? |
| Build/install | Does the built package work outside the development tree? |
| CRAN-style check | Does the release artifact pass R package checks? |
| Optional capability gate | Has each advertised backend been tested? |
| Metadata/reproducibility | Can results be traced to versions, seeds, and sources? |

------------------------------------------------------------------------

## Part I. Capability and method gates

### 4. Inspect the capability registry

``` r

library(mixRSMflow)

mix_capabilities()
```

Filter:

``` r

mix_capabilities(tier = "Tier 1")
mix_capabilities(module = "optimal_design")
```

A capability row documents implementation and validation classification.
It does not override the actual runtime status recorded for a specific
release environment.

------------------------------------------------------------------------

### 5. Method gates

Read:

``` text
inst/METHOD_GATES.md
```

The file exists to prevent the package from overclaiming historical
formulas or specialized methods that are not fully reproduced and
validated.

Examples of an appropriate gate include:

- grouped/categorized design geometry implemented but a particular
  historical coefficient transformation not claimed;
- modern analogue of a historical figure generated from the fitted
  model, not a copied textbook image;
- an approximation or Monte Carlo integration labeled as such rather
  than described as an exact closed-form reproduction.

------------------------------------------------------------------------

## Part II. Mathematical invariants

### 6. Fixed-sum invariant

Every feasible candidate should satisfy

``` math
\left|\sum_i x_i-T\right|<\epsilon.
```

``` r

sp <- mix_spec(
  c("A", "B", "C"),
  lower = c(0.10, 0.05, 0.05),
  upper = c(0.70, 0.80, 0.80),
  A = matrix(c(1, 1, 0), nrow = 1),
  b = 0.75,
  dir = "<="
)

V <- mix_vertices(sp)

stopifnot(
  max(abs(rowSums(V) - 1)) <= 1e-7
)
```

------------------------------------------------------------------------

### 7. Bound invariant

``` r

stopifnot(
  all(V$A >= 0.10 - 1e-7),
  all(V$B >= 0.05 - 1e-7),
  all(V$C >= 0.05 - 1e-7),
  all(V$A <= 0.70 + 1e-7),
  all(V$B <= 0.80 + 1e-7),
  all(V$C <= 0.80 + 1e-7)
)
```

------------------------------------------------------------------------

### 8. General-constraint invariant

``` r

stopifnot(
  all(V$A + V$B <= 0.75 + 1e-7)
)
```

These invariants should also be tested for generated candidate sets,
augmented designs, and Bayesian-optimization proposals.

------------------------------------------------------------------------

## Part III. Transformation invariants

### 9. Forward/inverse transformation

``` r

x <- V
z <- mix_transform(x, sp)
x2 <- mix_inverse_transform(z, sp)

max(abs(as.matrix(x) - as.matrix(x2)))
```

Expected result: near numerical precision.

------------------------------------------------------------------------

### 10. Pseudocomponent reversibility

``` r

spL <- mix_spec(
  c("A", "B", "C"),
  lower = c(0.10, 0.20, 0.10)
)

xL <- data.frame(
  A = c(0.20, 0.40),
  B = c(0.30, 0.20),
  C = c(0.50, 0.40)
)

zL <- mix_pseudocomponents(xL, spL, "L")
xL2 <- mix_pseudocomponents(zL, spL, "L", inverse = TRUE)

max(abs(as.matrix(xL) - as.matrix(xL2)))
```

------------------------------------------------------------------------

## Part IV. Golden tests

### 11. Exact coefficient recovery

The package contains a frozen Scheffé quadratic dataset with known
coefficients.

After installation:

``` r

f <- system.file(
  "extdata",
  "golden_scheffe_quadratic.csv",
  package = "mixRSMflow"
)

d <- read.csv(f)
sp0 <- mix_spec(c("A", "B", "C"))

fit <- mix_fit(
  "y",
  d,
  sp0,
  "scheffe_quadratic"
)

truth <- c(
  A = 2,
  B = 4,
  C = 6,
  `A:B` = 3,
  `A:C` = -2,
  `B:C` = 1
)

max(abs(coef(fit) - truth))
```

The frozen validation threshold in the current source is extremely small
because the scenario is constructed for exact linear recovery.

------------------------------------------------------------------------

### 12. GBM identity golden test

For the binary GBM term with

``` math
g_i=g_j=2,\quad h=1/2,\quad s=2,
```

verify

``` math
GBM(x_i,x_j)=x_ix_j.
```

``` r

sp0 <- mix_spec(c("A", "B", "C"))

x <- data.frame(
  A = c(0.2, 0.3, 0.4),
  B = c(0.3, 0.4, 0.2),
  C = c(0.5, 0.3, 0.4)
)

term <- mix_gbm_term(
  c("A", "B"),
  g = c(2, 2),
  h = 0.5,
  s = 2,
  label = "AB"
)

G <- mix_basis(
  x,
  sp0,
  model = "gbm",
  gbm_terms = list(term)
)
```

Compare the GBM column with `x$A * x$B`.

------------------------------------------------------------------------

## Part V. Frozen numerical battery

### 13. Why freeze scenarios?

A frozen battery prevents a future refactor from silently changing core
numerical behavior.

The source snapshot includes:

``` text
inst/extdata/simulation_scenarios.csv
inst/scripts/run_validation_battery.R
```

The validation script writes machine-readable results.

Core scenarios include checks such as:

- coefficient recovery;
- maximum constraint violation;
- IMSE decomposition identity;
- GBM/Scheffé identity.

A scenario is marked PASS only if it is actually executed and meets its
threshold.

------------------------------------------------------------------------

## Part VI. Simulation validation

### 14. Why unit tests are not enough

A function can return the correct object class and still produce biased
or poorly calibrated inference.

Simulation studies should evaluate statistical behavior under known
data-generating mechanisms.

------------------------------------------------------------------------

### 15. Suggested simulation axes

Vary:

- number of components: 3, 4, 5+;
- full versus constrained region;
- mild versus severe constraint width;
- number of runs;
- replication level;
- true model degree;
- fitted model degree;
- residual variance;
- heteroscedasticity;
- non-Gaussian response;
- interior optimum;
- boundary optimum;
- flat optimum plateau;
- competing local maxima;
- mixture-process interactions;
- random effects;
- stochastic design algorithms.

------------------------------------------------------------------------

### 16. Parameter recovery metrics

For coefficient `beta_j` across simulations:

``` math
Bias(\hat\beta_j)=E(\hat\beta_j)-\beta_j.
```

Evaluate:

- bias;
- RMSE;
- standard-error calibration;
- interval coverage;
- convergence/failure rate.

Do not select methods only by p-values.

------------------------------------------------------------------------

### 17. Prediction metrics

Evaluate:

- RMSE on a common feasible grid;
- maximum absolute error;
- average prediction variance;
- worst-case prediction variance;
- coverage of confidence/prediction intervals;
- boundary error versus interior error.

------------------------------------------------------------------------

### 18. Optimum-recovery metrics

When the true response surface is known, record:

- Euclidean distance in independent coordinates between estimated and
  true optimum;
- component-wise error;
- response regret;
- probability the true optimum lies in the estimated uncertainty region;
- coverage of the near-optimal region;
- frequency of boundary misclassification.

A method can estimate maximum response accurately while estimating the
optimum location poorly on a flat surface. Report both.

------------------------------------------------------------------------

## Part VII. Design benchmarks

### 19. Compare algorithms on the same problem

For each benchmark:

1.  fix the mixture region;
2.  fix the model;
3.  fix the run count;
4.  fix candidate/evaluation sets;
5.  run exchange, GA, and hybrid approaches;
6.  repeat stochastic algorithms across seeds;
7.  compare objective quality, FDS/VDG, conditioning, runtime, and
    stability.

Do not compare algorithms using different candidate sets and call the
difference algorithmic performance.

------------------------------------------------------------------------

### 20. Separate statistical quality from speed

A faster algorithm can be worse statistically. A slightly better design
can require dramatically more computation.

Report at least:

- objective score;
- average prediction variance;
- maximum prediction variance;
- condition number;
- runtime;
- memory where relevant;
- between-seed variability.

------------------------------------------------------------------------

## Part VIII. Stochastic reproducibility

### 21. Fixed seeds

All stochastic examples should expose a seed.

``` r

od <- mix_optimal_design(
  sp0,
  "scheffe_quadratic",
  runs = 10,
  criterion = "I",
  algorithm = "hybrid",
  seed = 33001
)
```

The seed is necessary for reproducibility, but one seed is not enough to
demonstrate algorithm stability.

------------------------------------------------------------------------

### 22. Repeated seeds

``` r

seeds <- 1:10

res <- lapply(
  seeds,
  function(s) {
    mix_optimal_design(
      sp0,
      "scheffe_quadratic",
      runs = 10,
      criterion = "I",
      algorithm = "hybrid",
      seed = s
    )
  }
)
```

Compare objective quality across runs.

------------------------------------------------------------------------

## Part IX. Graphics validation

### 23. Numeric first, graphic second

The graphic should be derived from a verified numeric object.

For a response contour, compare a few plotted grid values with direct
[`mix_predict()`](https://wep69.github.io/mixRSMflow/reference/mix_predict.md)
calculations.

For the 3D vector surface, confirm:

- component orientation;
- response range;
- consistency with the ternary contour;
- no points outside the feasible region.

------------------------------------------------------------------------

### 24. File-integrity checks

For each export format:

- confirm file exists;
- confirm nonzero file size;
- open/render it;
- inspect clipping;
- inspect fonts/labels;
- verify declared dpi for raster output;
- verify vector geometry for PDF/SVG when required.

Visual regression packages such as `vdiffr` can supplement but not
replace manual scientific inspection.

------------------------------------------------------------------------

## Part X. Optional-backend validation

### 25. Why optional packages need separate gates

Core R code can work while:

- `nlme` adapter fails on a covariance structure;
- `lme4` formula translation changes;
- `brms` API changes;
- `DiceKriging` optimizer changes;
- `plotly` rendering changes;
- `shiny` interface breaks.

Each advertised optional capability should have at least one runtime
test in an environment where the dependency is installed.

------------------------------------------------------------------------

### 26. Suggested backend matrix

| Backend | Capability | Minimum validation |
|:---|:---|:---|
| `nlme` | GLS | fit + prediction + covariance example |
| `lme4` | mixed model | fit + random structure + prediction |
| `brms` | Bayesian fit | smoke fit + convergence + posterior extraction |
| `DiceKriging` | Bayesian optimization | proposal feasibility + deterministic seed check |
| `plotly` | interactive graphics | object creation + manual interaction |
| `shiny` | app | launch + core workflow consistency |

------------------------------------------------------------------------

## Part XI. Local R validation pipeline

### 27. Main Windows entry point

The source package includes:

``` text
VALIDATE_WINDOWS.ps1
```

which calls:

``` text
inst/scripts/validate_local.R
```

The validation sequence includes:

1.  `roxygen2` documentation;
2.  `testthat`;
3.  vignette building;
4.  R package build;
5.  installation into a temporary library;
6.  frozen numerical validation;
7.  `R CMD check --as-cran`.

------------------------------------------------------------------------

### 28. Unix entry point

``` text
VALIDATE_UNIX.sh
```

The same scientific gates should be preserved across platforms.

------------------------------------------------------------------------

## Part XII. Source snapshot versus R-built tarball

### 29. Why the distinction matters

A manually archived source tree is useful for transfer and inspection.

A true release artifact must be produced by:

``` text
R CMD build
```

The build process can expose problems that are invisible in the
development tree:

- ignored files;
- incorrect paths;
- vignette build failures;
- missing installed resources;
- documentation issues.

Therefore do not call the source snapshot a CRAN-ready tarball.

------------------------------------------------------------------------

## Part XIII. Clean installation

### 30. Install the built tarball into a temporary library

A package that works only under `devtools::load_all()` is not
sufficiently validated.

The clean-install gate confirms:

- namespace behavior after installation;
- [`system.file()`](https://rdrr.io/r/base/system.file.html) resources;
- included data/scripts;
- dependency declarations;
- examples from the installed package.

------------------------------------------------------------------------

## Part XIV. R CMD check

### 31. ERROR

Any ERROR blocks release.

------------------------------------------------------------------------

### 32. WARNING

Any WARNING should also block release until investigated and resolved or
formally justified under the target repository’s policies.

------------------------------------------------------------------------

### 33. NOTE

Every NOTE must be read. Do not automatically ignore NOTES because they
are not warnings.

Classify each as:

- resolved;
- acceptable and documented;
- blocker.

------------------------------------------------------------------------

## Part XV. Validation status language

### 34. FAIL

Use FAIL when any required gate fails, including:

- test failure;
- numerical battery failure;
- install failure;
- ERROR/WARNING;
- invalid constraints;
- corrupted figure;
- required backend failure.

------------------------------------------------------------------------

### 35. CONDITIONAL PASS

Use when core required gates pass but a non-core release condition
remains, such as:

- optional backend intentionally excluded from the advertised release
  scope;
- NOTE awaiting documented resolution;
- editorial metadata task remaining.

------------------------------------------------------------------------

### 36. PASS

Reserve PASS for an explicitly defined scope with completed evidence.

Example:

``` text
Static audit:            PASS
R parse/load:            PASS
Unit tests:              PASS
Frozen battery:          PASS
Vignettes:               PASS
Built-tarball install:   PASS
R CMD check:             0 ERROR / 0 WARNING
Declared backends:       PASS
Metadata:                VERIFIED
Method gates:            SATISFIED
```

------------------------------------------------------------------------

## Part XVI. Metadata verification

### 37. Scientific references

The package contains metadata/reference files under `inst/metadata/` and
`references/`.

Before release:

- verify DOI;
- verify author names;
- verify year;
- verify package/software versions mentioned in the state-of-the-art
  vignette;
- update the search date;
- preserve two-source verification records where the project protocol
  requires them.

Do not invent missing bibliographic metadata.

------------------------------------------------------------------------

## Part XVII. Reproducibility and audit trail

### 38. Object-level audit

``` r

sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_lattice", degree = 2, seed = 33001)

mix_audit_trail(d)
```

------------------------------------------------------------------------

### 39. Report-level session information

``` r

mix_report(
  d,
  file = "design_report.md",
  include_session = TRUE
)
```

Archive:

- R version;
- OS;
- `mixRSMflow` version;
- optional backend versions;
- seeds;
- source data hash/version;
- analysis script;
- validation log.

------------------------------------------------------------------------

## Part XVIII. Validation dossier

### 40. Recommended directory

``` text
validation/
├── environment/
├── static_audits/
├── unit_tests/
├── golden_tests/
├── simulation_battery/
├── design_benchmarks/
├── backend_tests/
├── graphics/
├── R_CMD_check/
├── metadata/
└── release/
```

Every release candidate should be traceable to a frozen validation
dossier.

------------------------------------------------------------------------

## Part XIX. Complete release-gate workflow

### 41. Stage 1: source integrity

Verify checksums and repository status.

### 42. Stage 2: static API consistency

Run the supplied static audits.

### 43. Stage 3: R parse and load

Run every R file through the R parser and `devtools::load_all()`.

### 44. Stage 4: documentation

Regenerate roxygen documentation and inspect changes.

### 45. Stage 5: unit tests

All required `testthat` files pass.

### 46. Stage 6: vignette rendering

Every quick vignette and extended vignette intended for build renders or
is included according to the chosen documentation strategy.

### 47. Stage 7: real R build

Create the tarball.

### 48. Stage 8: clean install

Install the tarball into a clean temporary library.

### 49. Stage 9: numerical validation

Run the frozen battery from the installed package.

### 50. Stage 10: CRAN-style check

Run `R CMD check --as-cran` or `rcmdcheck` equivalent.

### 51. Stage 11: optional capabilities

Test every backend that will be advertised as working.

### 52. Stage 12: scientific review

Review method gates, references, figures, simulations, and conclusions.

Only then classify the release.

------------------------------------------------------------------------

## Part XX. Common mistakes

### 53. Calling code “validated” because it was written

Implementation is not validation.

------------------------------------------------------------------------

### 54. Increasing tolerances until tests pass

A tolerance change requires numerical justification.

------------------------------------------------------------------------

### 55. Testing only on the development machine

Use clean installation and CI/multiple platforms when possible.

------------------------------------------------------------------------

### 56. Benchmarking algorithms on different candidate sets

Hold the scientific problem fixed.

------------------------------------------------------------------------

### 57. Validating only mean coefficients

Also test geometry, prediction, optimum location, constraints, and
failure modes.

------------------------------------------------------------------------

### 58. Ignoring optional backends

Do not advertise an untested optional pathway as validated.

------------------------------------------------------------------------

### 59. Treating a generated plot as correct because it opens

Verify the numerical content and geometry.

------------------------------------------------------------------------

### 60. Reusing an old PASS after changing the source

Any material code/documentation change requires the relevant gates to be
rerun.

------------------------------------------------------------------------

## Part XXI. Function-selection guide

| Validation question | Tool |
|:---|:---|
| What capabilities are registered? | [`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md) |
| What did this object record? | [`mix_audit_trail()`](https://wep69.github.io/mixRSMflow/reference/mix_audit_trail.md) |
| Can I produce an auditable report? | [`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md) |
| Geometry invariant | [`mix_spec()`](https://wep69.github.io/mixRSMflow/reference/mix_spec.md), [`mix_vertices()`](https://wep69.github.io/mixRSMflow/reference/mix_vertices.md), explicit checks |
| Known coefficient recovery | frozen golden data + [`mix_fit()`](https://wep69.github.io/mixRSMflow/reference/mix_fit.md) |
| GBM identity | [`mix_gbm_term()`](https://wep69.github.io/mixRSMflow/reference/mix_gbm_term.md) + [`mix_basis()`](https://wep69.github.io/mixRSMflow/reference/mix_basis.md) |
| Design benchmark | [`mix_optimal_design()`](https://wep69.github.io/mixRSMflow/reference/mix_optimal_design.md), [`mix_design_eval()`](https://wep69.github.io/mixRSMflow/reference/mix_design_eval.md) |
| Optimum recovery simulation | [`mix_optimize()`](https://wep69.github.io/mixRSMflow/reference/mix_optimize.md), [`mix_optimum_ci()`](https://wep69.github.io/mixRSMflow/reference/mix_optimum_ci.md) |
| Full local gate | `inst/scripts/validate_local.R` |
| Frozen battery | `inst/scripts/run_validation_battery.R` |
| Windows entry point | `VALIDATE_WINDOWS.ps1` |
| Unix entry point | `VALIDATE_UNIX.sh` |

------------------------------------------------------------------------

## Part XXII. Reporting checklist for a validation statement

package version/commit/hash;

operating system;

R version;

library/dependency versions;

static-audit results;

parse/load result;

testthat summary;

golden-test summary;

frozen-battery file;

simulation scenarios and seeds;

design-benchmark definitions;

stochastic repeated-seed results;

optional backend matrix;

graphics inspection record;

built tarball filename/hash;

clean-install log;

`00check.log`;

ERROR count;

WARNING count;

NOTE disposition;

method-gate review;

metadata verification date;

final PASS/CONDITIONAL PASS/FAIL classification and scope.

------------------------------------------------------------------------

## Appendix A. Compact installed-package validation script

``` r

library(mixRSMflow)

sp <- mix_spec(
  c("A", "B", "C"),
  lower = c(0.10, 0.05, 0.05),
  upper = c(0.70, 0.80, 0.80),
  A = matrix(c(1, 1, 0), nrow = 1),
  b = 0.75,
  dir = "<="
)

V <- mix_vertices(sp)

stopifnot(
  max(abs(rowSums(V) - 1)) <= 1e-7,
  all(V$A + V$B <= 0.75 + 1e-7)
)

z <- mix_transform(V, sp)
V2 <- mix_inverse_transform(z, sp)
stopifnot(max(abs(as.matrix(V) - as.matrix(V2))) <= 1e-7)

caps <- mix_capabilities()
print(caps)
```

------------------------------------------------------------------------

## Appendix B. Boundary with other extended vignettes

This vignette owns **evidence that the software and its declared
capabilities work as specified**. It does not re-teach scientific
mixture geometry (24), design theory (25), blending models (26),
structured experiments (27), multiresponse decisions (28), optimum
uncertainty (29), sequential science (30), response engines (31), or
figure construction (32), except when those topics appear as validation
targets.

------------------------------------------------------------------------

## Final perspective

Scientific software quality is not one gate.

A trustworthy release needs a chain of evidence:

**source integrity -\> mathematical invariants -\> unit/golden tests -\>
statistical simulation -\> algorithm benchmarks -\> optional-backend
checks -\> graphics inspection -\> R build -\> clean install -\> R CMD
check -\> metadata and method-gate review -\> archived validation
dossier.**

The package should state exactly which links in that chain have been
completed for each release.

------------------------------------------------------------------------

## Appendix C. Advanced validation laboratories

### C1. Laboratory: design a new golden test

Choose one analytically known identity not already in the frozen
battery. Examples:

- lower-bound pseudocomponent round trip;
- exact full-simplex moment;
- slack reparameterization fitted-value equivalence.

Write:

1.  data-generation code;
2.  exact expected result;
3.  tolerance rationale;
4.  test code;
5.  failure message.

#### Lesson

A golden test should have a known answer independent of the
implementation being tested. Otherwise the package can validate itself
against its own mistake.

------------------------------------------------------------------------

### C2. Laboratory: repeated-seed benchmark

Benchmark exchange, GA, and hybrid I-designs across 30 seeds on one
constrained region.

Record:

- objective score;
- condition number;
- maximum prediction variance;
- runtime;
- failure count.

Plot objective quality versus runtime.

#### Interpretation

The best algorithm depends on the trade-off between statistical design
quality, computational cost, and stability.

------------------------------------------------------------------------

### C3. Laboratory: optimum coverage simulation

Define a known quadratic surface with an interior optimum. Simulate 500
datasets, fit the model, compute
[`mix_optimum_ci()`](https://wep69.github.io/mixRSMflow/reference/mix_optimum_ci.md),
and estimate the proportion of joint regions that contain the true
optimum.

This is a direct statistical validation target for the
optimum-uncertainty module.

------------------------------------------------------------------------

### C4. Laboratory: release regression after code change

Modify one internal helper in a controlled branch. Rerun:

- static audits;
- unit tests;
- golden tests;
- frozen battery;
- vignette build;
- package build/install;
- `R CMD check`.

Record exactly which gates detect the change. This exercise demonstrates
why no single gate is sufficient.

------------------------------------------------------------------------

## Appendix D. Validation troubleshooting matrix

| Symptom | Meaning | Correct response |
|:---|:---|:---|
| static audit passes, R parse fails | static checker cannot replace R | fix source and rerun all relevant gates |
| unit tests pass, golden test fails | contract works but numeric result changed | investigate algorithm/regression |
| frozen result differs slightly across platforms | numerical tolerance/platform issue | quantify and justify tolerance, do not widen blindly |
| GA benchmark highly variable | search instability | improve settings or report instability |
| clean install fails, `load_all` works | packaging/resource declaration issue | debug built artifact |
| `R CMD check` warning appears | release blocker | resolve before release |
| optional backend absent | capability not tested | mark unavailable/unvalidated; do not substitute silently |
| figure opens but values wrong | visual code bug | validate against numeric predictions |

------------------------------------------------------------------------

## Appendix E. Guided validation exercises

#### Exercise 1. Invariant design

Write three invariant tests for every candidate-generation function:
total, bounds, and linear restrictions.

#### Exercise 2. Tolerance rationale

For a transformation round trip, compare `1e-6`, `1e-8`, and `1e-12`
tolerances. Explain which is justified by floating-point operations.

#### Exercise 3. Golden independence

Explain why using
[`mix_fit()`](https://wep69.github.io/mixRSMflow/reference/mix_fit.md)
to generate both the expected and observed coefficient vector is not a
valid golden test.

#### Exercise 4. Simulation power

Estimate how many Monte Carlo repetitions are needed to estimate 95%
coverage to a useful precision.

#### Exercise 5. Algorithm benchmark fairness

List every element that must be held constant when comparing GA and
exchange designs.

#### Exercise 6. Backend matrix

Create a table of installed/missing versions for `nlme`, `lme4`, `brms`,
`DiceKriging`, `plotly`, and `shiny`.

#### Exercise 7. Clean library

Explain why a package may accidentally use an undeclared dependency from
the developer’s ordinary library.

#### Exercise 8. Source snapshot

Explain why a zipped source tree is not the same artifact as
`R CMD build` output.

#### Exercise 9. NOTE review

Classify three hypothetical R CMD check NOTES as harmless, fixable, or
blocking and justify each.

#### Exercise 10. Graphics

Create an automated file-existence/hash check plus a manual
visual-inspection checklist.

#### Exercise 11. Metadata

Choose five key scientific references and document how DOI, title,
authors, and year would be verified from two sources.

#### Exercise 12. Reviewer exercise

A package paper states “all functions were validated” without
simulation, platform, or backend details. Draft a reviewer request for a
validation matrix.

------------------------------------------------------------------------

## Appendix F. Reviewer-style software-validation audit

A package manuscript should state:

1.  source version/commit;
2.  R versions/platforms;
3.  unit-test coverage or scope;
4.  golden identities;
5.  simulation scenarios;
6.  performance metrics;
7.  stochastic seeds/repetitions;
8.  design-benchmark fairness;
9.  optional backend versions;
10. graphics validation;
11. build/install checks;
12. R CMD check results;
13. known method gates/limitations;
14. metadata verification procedure;
15. archived reproducibility materials.

------------------------------------------------------------------------

## Appendix G. Validation statement templates

#### Static-only state

> The source tree passed the documented static structure/API/Rd audits.
> R runtime, numerical, vignette, installation, and `R CMD check` gates
> had not yet been executed in that environment and are therefore
> reported separately rather than inferred from the static result.

#### Runtime core PASS

> The declared core capability set passed R parse/load, unit tests,
> golden identities, the frozen numerical battery, vignette rendering,
> built-tarball installation, and `R CMD check` with no ERROR or
> WARNING. Optional backends are reported independently.

#### Conditional PASS

> Core release gates passed, but the stated optional capability was not
> included in the validated release scope because its external backend
> was unavailable in the test environment. The package therefore reports
> the capability as optional rather than silently substituting another
> method.

#### Failed gate

> The release candidate is not classified as validated because the
> specified numerical/runtime gate failed. The failure is retained in
> the validation record pending correction and rerun.

------------------------------------------------------------------------

## Appendix H. Applied validation case bank

### H1. Constraint regression bug

A future refactor accidentally allows candidate points that exceed an
upper bound by 0.01. Plotting may still look normal. A fixed-sum test
alone will not catch the error, but bound and general-constraint
invariants will. This illustrates why geometry validation needs several
simultaneous invariants.

### H2. Algorithm-quality regression

A faster GA implementation reduces runtime by 40% but produces designs
with consistently worse I-criterion and FDS behavior. The change should
not be accepted as an unqualified improvement. Scientific package
benchmarks must report both computational and statistical performance.

### H3. Optional-backend API change

A new `brms` release changes an argument or return structure. Core
package tests still pass because `brms` is optional. A backend-specific
CI job or local test detects the breakage. Capability-level validation
prevents the package from claiming that optional Bayesian workflows are
validated merely because core R code succeeds.

### H4. Graphic regression

A coordinate-order refactor rotates the ternary labels while leaving
predicted values correct. Numeric unit tests pass. A visual regression
or manual figure audit catches the mismatch. Scientific graphics need
independent validation because wrong geometry can communicate wrong
science even when the model numbers are correct.

### H5. Built-artifact resource failure

A report template exists in the source tree but is omitted from the
built tarball because of an ignore rule. `devtools::load_all()` works,
but the installed package fails. Clean-install validation from the real
R-built tarball catches this class of packaging defect.

------------------------------------------------------------------------

## Appendix I. Short-answer validation review

1.  **Does implemented mean validated?** No.
2.  **Why use invariants?** They express mathematical properties that
    should hold across cases.
3.  **What makes a golden test strong?** An expected answer independent
    of the implementation.
4.  **Why freeze scenarios?** To detect numerical regressions across
    versions.
5.  **Why simulate?** To validate statistical behavior such as bias and
    coverage.
6.  **Why repeat stochastic seeds?** To evaluate algorithm stability,
    not just reproducibility of one run.
7.  **Why test built tarballs?** Installed resources/namespaces can
    differ from development-tree behavior.
8.  **Why validate optional backends separately?** Core success does not
    certify external integrations.
9.  **What blocks release?** Failed required tests, numerical gates,
    install, or ERROR/WARNING under the declared policy.
10. **What should PASS mean?** PASS for an explicitly defined scope
    supported by archived evidence.

------------------------------------------------------------------------

## Appendix J. Deeper conceptual notes on evidence for scientific software

### J1. Validation scope must be explicit

A package can have a validated core and experimental extensions
simultaneously. The correct statement is not “the package is validated”
in the abstract, but “the declared core capabilities passed these gates
under these environments, while optional capability X remains separately
gated.” This scope-aware language is more credible and easier to
maintain.

### J2. Statistical validation differs from numerical regression testing

A frozen numerical scenario detects unexpected software changes, but it
does not prove statistical calibration. Coverage, bias, model-selection
behavior, or optimum recovery require simulation under known
data-generating mechanisms. Both types of evidence are necessary for
advanced scientific methods.

### J3. Reproducibility differs from replicability

A fixed seed and archived environment make a computational result
reproducible. Replicability asks whether the method performs similarly
across independent datasets or simulations. A stochastic optimizer can
be perfectly reproducible for seed 1 and still be unstable across seeds.
Validation should assess both concepts.

### J4. Cross-platform variability

Small floating-point differences can occur across operating systems,
BLAS/LAPACK implementations, and compiler toolchains. Tolerances should
therefore reflect numerical analysis rather than arbitrary exact
equality. At the same time, tolerances must remain tight enough to
detect substantive regressions.

### J5. Release evidence should be immutable

After a release candidate is declared PASS, archive checksums for the
exact tarball and validation outputs. If source files change, the prior
PASS applies only to the prior artifact. Rebuild and rerun the relevant
gates rather than carrying the label forward informally.
