# Diagnose collinearity and estimability in mixture model matrices

Diagnose collinearity and estimability in mixture model matrices

## Usage

``` r
mix_collinearity(object, spec = NULL, model = "scheffe_quadratic", tol = 1e-10)
```

## Arguments

- object:

  A \`mix_fit\`, \`mix_design\`, numeric matrix, or data frame.

- spec:

  Mixture specification when \`object\` is a design/data frame.

- model:

  Model basis for a design/data frame.

- tol:

  Numerical rank tolerance.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_collinearity\` object with singular values, condition indices,
coefficient-correlation matrix, variance-decomposition proportions, and
recommendations.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_lattice", degree = 3)
mix_collinearity(d, model = "scheffe_quadratic")
#> <mix_collinearity> design:simplex_lattice 
#> Rank: 6 / 6  Max condition index: 3.2572  Severity: low 
#> No major numerical collinearity signal under the scaled model matrix. 
mix_collinearity(d, model = "scheffe_special_cubic")
#> <mix_collinearity> design:simplex_lattice 
#> Rank: 7 / 7  Max condition index: 3.8614  Severity: low 
#> No major numerical collinearity signal under the scaled model matrix. 
fit <- mix_fit("response", mix_demo_data("mixture", n_rep = 2, seed = 8), sp)
mix_collinearity(fit)
#> <mix_collinearity> fit:scheffe_quadratic 
#> Rank: 6 / 6  Max condition index: 3.4565  Severity: low 
#> No major numerical collinearity signal under the scaled model matrix. 
```
