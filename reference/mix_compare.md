# Compare fitted mixture models without selecting solely by one metric

Compare fitted mixture models without selecting solely by one metric

## Usage

``` r
mix_compare(..., criterion = NULL)
```

## Arguments

- criterion:

  Optional ordering criterion: \`AIC\`, \`BIC\`, \`RMSE\`, or \`PRESS\`.

- ...:

  Additional arguments passed to or from other methods.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

Comparison table with model size, fit, prediction, and conditioning
metrics.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 10)
f1 <- mix_fit("response", d, sp, model = "scheffe_linear")
f2 <- mix_fit("response", d, sp, model = "scheffe_quadratic")
mix_compare(f1, f2, criterion = "PRESS")
#>   id             model engine  n p       AIC       BIC      RMSE     PRESS
#> 1  2 scheffe_quadratic     lm 22 6 -76.88806 -70.34180 0.1326312 0.5942591
#> 2  1    scheffe_linear     lm 22 3 -48.06142 -44.78829 0.2926820 2.4846761
#>   condition_number
#> 1         8.705838
#> 2         1.563472
f3 <- mix_fit("response", d, sp, model = "scheffe_special_cubic")
mix_compare(f1, f2, f3, criterion = "AIC")
#>   id                 model engine  n p       AIC       BIC      RMSE     PRESS
#> 1  2     scheffe_quadratic     lm 22 6 -76.88806 -70.34180 0.1326312 0.5942591
#> 2  3 scheffe_special_cubic     lm 22 7 -74.94169 -67.30439 0.1324696 0.7023587
#> 3  1        scheffe_linear     lm 22 3 -48.06142 -44.78829 0.2926820 2.4846761
#>   condition_number
#> 1         8.705838
#> 2        55.812294
#> 3         1.563472
mix_compare(f1, f2)
#>   id             model engine  n p       AIC       BIC      RMSE     PRESS
#> 1  1    scheffe_linear     lm 22 3 -48.06142 -44.78829 0.2926820 2.4846761
#> 2  2 scheffe_quadratic     lm 22 6 -76.88806 -70.34180 0.1326312 0.5942591
#>   condition_number
#> 1         1.563472
#> 2         8.705838
```
