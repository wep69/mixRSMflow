# Reparameterize an equivalent Scheffe model with an intercept and slack component

For linear and quadratic Scheffe models this function refits the same
response space using a slack-variable polynomial. The transformation is
useful for teaching, numerical diagnostics, and comparison of
coefficient interpretations.

## Usage

``` r
mix_reparameterize(object, slack_component = NULL)
```

## Arguments

- object:

  A Gaussian or GLM \`mix_fit\` fitted with \`scheffe_linear\` or
  \`scheffe_quadratic\`.

- slack_component:

  Component to eliminate through the mixture total constraint.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A new \`mix_fit\` object with model \`slack_linear\` or
\`slack_quadratic\`.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 11)
fit <- mix_fit("response", d, sp, model = "scheffe_quadratic")
slack <- mix_reparameterize(fit, slack_component = "C")
slack$reparameterization
#> $from
#> [1] "scheffe_quadratic"
#> 
#> $slack_component
#> [1] "C"
#> 
#> $max_abs_fitted_difference
#> [1] 6.217249e-15
#> 
slack2 <- mix_reparameterize(fit, slack_component = "A")
slack2$reparameterization
#> $from
#> [1] "scheffe_quadratic"
#> 
#> $slack_component
#> [1] "A"
#> 
#> $max_abs_fitted_difference
#> [1] 3.552714e-15
#> 
fit_lin <- mix_fit("response", d, sp, model = "scheffe_linear")
mix_reparameterize(fit_lin)
#> <mix_fit>
#>  Response: response 
#>  Model: slack_linear 
#>  Engine: lm 
#>  Observations: 22  Parameters: 3 
#> (Intercept)           A           B 
#>    6.857847   -2.187879   -0.438230 
```
