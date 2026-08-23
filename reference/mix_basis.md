# Build a mixture-model basis matrix

Supports classical Scheffe polynomials and several alternative
parameterizations discussed in the mixture-experiment literature.
Higher-order special/full Scheffe forms follow the canonical term
structures used in standard mixture DOE.

## Usage

``` r
mix_basis(data, spec,
                      model = c("scheffe_linear", "scheffe_quadratic",
                                "scheffe_special_cubic", "scheffe_cubic",
                                "scheffe_special_quartic", "scheffe_quartic",
                                "slack_linear", "slack_quadratic", "kronecker_quadratic",
                                "inverse_scheffe", "ratio", "cox_linear", "cox_quadratic",
                                "cox_cubic", "logcontrast",
                                "becker_h1", "becker_h2", "becker_h3", 
                                "additive_blending", "gbm"),
                      process = NULL, process_order = 2L, mixture_process = FALSE,
                      slack_component = NULL, reference = NULL, denominator = NULL,
                      inverse_components = NULL, additive_component = NULL, gbm_terms = 
                      NULL)
```

## Arguments

- data:

  Data frame containing the mixture components.

- spec:

  A \`mix_spec\` object.

- model:

  Model basis name.

- process:

  Optional numeric process-variable names.

- process_order:

  Polynomial order for process variables (1 or 2).

- mixture_process:

  If \`TRUE\`, interact mixture terms with process terms. To keep the
  mixture-process model estimable, cross terms are generated for all
  mixture columns except constant/intercept columns and the last
  component's main effect (whose cross family is collinear with the
  process main effects because the components sum to one).

- slack_component:

  Component designated as slack for slack-variable models.

- reference:

  Reference composition for Cox parameterization.

- denominator:

  Denominator component for ratio models.

- inverse_components:

  Components receiving reciprocal terms.

- additive_component:

  Component assumed to blend additively in the Becker-type reduced
  model.

- gbm_terms:

  List of fixed-exponent general blending terms created by
  \[mix_gbm_term()\].

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

Numeric design matrix with informative column names.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_centroid")
X <- mix_basis(d$data, sp, model = "scheffe_quadratic")
head(X)
#>        A   B   C  A:B  A:C  B:C
#> [1,] 1.0 0.0 0.0 0.00 0.00 0.00
#> [2,] 0.0 1.0 0.0 0.00 0.00 0.00
#> [3,] 0.0 0.0 1.0 0.00 0.00 0.00
#> [4,] 0.5 0.5 0.0 0.25 0.00 0.00
#> [5,] 0.5 0.0 0.5 0.00 0.25 0.00
#> [6,] 0.0 0.5 0.5 0.00 0.00 0.25
X2 <- mix_basis(d$data, sp, model = "scheffe_special_cubic")
head(X2)
#>        A   B   C  A:B  A:C  B:C A:B:C
#> [1,] 1.0 0.0 0.0 0.00 0.00 0.00     0
#> [2,] 0.0 1.0 0.0 0.00 0.00 0.00     0
#> [3,] 0.0 0.0 1.0 0.00 0.00 0.00     0
#> [4,] 0.5 0.5 0.0 0.25 0.00 0.00     0
#> [5,] 0.5 0.0 0.5 0.00 0.25 0.00     0
#> [6,] 0.0 0.5 0.5 0.00 0.00 0.25     0
mix_basis(d$data, sp, model = "slack_linear", slack_component = "C")
#>      (Intercept)         A         B
#> [1,]           1 1.0000000 0.0000000
#> [2,]           1 0.0000000 1.0000000
#> [3,]           1 0.0000000 0.0000000
#> [4,]           1 0.5000000 0.5000000
#> [5,]           1 0.5000000 0.0000000
#> [6,]           1 0.0000000 0.5000000
#> [7,]           1 0.3333333 0.3333333
#> attr(,"mix_model")
#> [1] "slack_linear"
```
