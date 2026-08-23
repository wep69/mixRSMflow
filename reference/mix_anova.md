# ANOVA and pure-error/lack-of-fit decomposition for mixture models

ANOVA and pure-error/lack-of-fit decomposition for mixture models

## Usage

``` r
mix_anova(object, replicate_by = NULL)
```

## Arguments

- object:

  A \`mix_fit\` object.

- replicate_by:

  Optional columns defining replicated design points. By default,
  mixture components plus process variables are used.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

Data frame containing regression, residual, lack-of-fit, pure-error, and
total components.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 3, seed = 8)
fit <- mix_fit("response", d, sp, model = "scheffe_quadratic")
mix_anova(fit)
#>        source df         SS         MS         F   p_value
#> 1  Regression  6 13.2019380 2.20032301        NA        NA
#> 2    Residual 27  1.1414789 0.04227700        NA        NA
#> 3 Lack of fit  5  0.1047728 0.02095456 0.4446779 0.8124527
#> 4  Pure error 22  1.0367061 0.04712300        NA        NA
#> 5       Total 32 14.3434169         NA        NA        NA
mix_anova(fit, replicate_by = c("A", "B", "C"))
#>        source df         SS         MS         F   p_value
#> 1  Regression  6 13.2019380 2.20032301        NA        NA
#> 2    Residual 27  1.1414789 0.04227700        NA        NA
#> 3 Lack of fit  5  0.1047728 0.02095456 0.4446779 0.8124527
#> 4  Pure error 22  1.0367061 0.04712300        NA        NA
#> 5       Total 32 14.3434169         NA        NA        NA
fit2 <- mix_fit("response", d, sp, model = "scheffe_linear")
mix_anova(fit2)
#>        source df        SS         MS        F     p_value
#> 1  Regression  3 11.874248 3.95808261       NA          NA
#> 2    Residual 30  2.469169 0.08230564       NA          NA
#> 3 Lack of fit  8  1.432463 0.17905788 3.799798 0.006106592
#> 4  Pure error 22  1.036706 0.04712300       NA          NA
#> 5       Total 32 14.343417         NA       NA          NA
```
