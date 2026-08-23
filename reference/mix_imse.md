# Integrated mean-square prediction error under an explicit larger model

Evaluates the Box-Draper variance-plus-bias decomposition for a fitted
model relative to an explicitly specified larger model. It does not
silently guess omitted-term coefficients. Bias can be evaluated at
supplied coefficients or

## Usage

``` r
mix_imse(design, spec = NULL, fitted_model = "scheffe_quadratic",
                     true_model = "scheffe_special_cubic", evaluation = NULL,
                     beta_omitted = NULL, beta_cov = NULL, sigma2 = 1,
                     resolution = 18L, fitted_args = list(), true_args = list())
```

## Arguments

- design:

  A \`mix_design\` or design data frame.

- spec:

  A \`mix_spec\` when \`design\` is a data frame.

- fitted_model:

  Basis name used for the fitted model.

- true_model:

  Larger basis name defining possible omitted terms.

- evaluation:

  Optional feasible evaluation data. If \`NULL\`, a grid is generated.

- beta_omitted:

  Optional named or ordered coefficient vector for omitted terms.

- beta_cov:

  Optional covariance matrix for zero-mean omitted coefficients. This
  yields expected integrated squared bias.

- sigma2:

  Error variance multiplying the integrated prediction variance.

- resolution:

  Evaluation-grid resolution.

- fitted_args:

  Named lists passed to \[mix_basis()\] for each model.

- true_args:

  Named lists passed to \[mix_basis()\] for each model.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_imse\` object with variance, bias and total IMSE components.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_lattice", degree = 3)
im <- mix_imse(d, fitted_model = "scheffe_quadratic",
               true_model = "scheffe_special_cubic", beta_omitted = c(`A:B:C` = 2),
               sigma2 = .25, resolution = 8)
im
#> Integrated MSE assessment
#>   Fitted model: scheffe_quadratic 
#>   Reference larger model: scheffe_special_cubic 
#>   Integrated variance: 0.0906849 
#>   Integrated squared bias: 0.000608563 
#>   IMSE: 0.0912935 
im2 <- mix_imse(d, fitted_model = "scheffe_linear", true_model = "scheffe_quadratic",
                beta_omitted = c(`A:B` = 1, `A:C` = 1, `B:C` = 1), resolution = 8)
im2
#> Integrated MSE assessment
#>   Fitted model: scheffe_linear 
#>   Reference larger model: scheffe_quadratic 
#>   Integrated variance: 0.199966 
#>   Integrated squared bias: 0.0112757 
#>   IMSE: 0.211242 
mix_imse(d, fitted_model = "scheffe_quadratic", true_model = "scheffe_special_cubic",
         beta_cov = matrix(1), sigma2 = 1, resolution = 8)
#> Integrated MSE assessment
#>   Fitted model: scheffe_quadratic 
#>   Reference larger model: scheffe_special_cubic 
#>   Integrated variance: 0.36274 
#>   Integrated squared bias: 0.000152141 
#>   IMSE: 0.362892 
```
