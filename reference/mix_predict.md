# Predict from a fitted mixture model with uncertainty

Predict from a fitted mixture model with uncertainty

## Usage

``` r
mix_predict(object,newdata=NULL,interval=c("none","confidence","prediction"),
                        level=0.95,type=c("response","link"))
```

## Arguments

- object:

  A fitted mixture model.

- newdata:

  New mixture/process settings; defaults to fitted data.

- interval:

  \`none\`, \`confidence\`, or \`prediction\` (prediction is Gaussian
  only).

- level:

  Confidence level.

- type:

  \`response\` or \`link\` for GLMs.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

Data frame with predictions and optional uncertainty limits.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 18)
fit <- mix_fit("response", d, sp)
head(mix_predict(fit, interval = "confidence"))
#>   A B C .run response .prediction  .se_link   .lower   .upper
#> 1 1 0 0    1 4.866763    4.950325 0.1477001 4.637214 5.263435
#> 2 1 0 0    2 5.028108    4.950325 0.1477001 4.637214 5.263435
#> 3 0 1 0    3 6.010098    6.109290 0.1477001 5.796180 6.422401
#> 4 0 1 0    4 6.248680    6.109290 0.1477001 5.796180 6.422401
#> 5 0 0 1    5 7.138427    7.262133 0.1477001 6.949023 7.575244
#> 6 0 0 1    6 7.265912    7.262133 0.1477001 6.949023 7.575244
head(mix_predict(fit, interval = "prediction"))
#>   A B C .run response .prediction  .se_link   .lower   .upper
#> 1 1 0 0    1 4.866763    4.950325 0.1477001 4.393451 5.507199
#> 2 1 0 0    2 5.028108    4.950325 0.1477001 4.393451 5.507199
#> 3 0 1 0    3 6.010098    6.109290 0.1477001 5.552416 6.666164
#> 4 0 1 0    4 6.248680    6.109290 0.1477001 5.552416 6.666164
#> 5 0 0 1    5 7.138427    7.262133 0.1477001 6.705259 7.819007
#> 6 0 0 1    6 7.265912    7.262133 0.1477001 6.705259 7.819007
mix_predict(fit, newdata = data.frame(A = 1/3, B = 1/3, C = 1/3),
            interval = "confidence", level = .9)
#>           A         B         C .prediction   .se_link   .lower  .upper
#> 1 0.3333333 0.3333333 0.3333333    6.026957 0.06869479 5.907024 6.14689
```
