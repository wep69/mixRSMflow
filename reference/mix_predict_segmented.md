# Predict from a segmented mixture model

Predict from a segmented mixture model

## Usage

``` r
mix_predict_segmented(object, newdata = NULL, interval = c("none", "confidence",
"prediction"), level = 0.95)
```

## Arguments

- object:

  A \`mix_segmented_fit\`.

- newdata:

  New data.

- interval:

  Prediction interval type passed to \`mix_predict\`.

- level:

  Confidence level.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

Predictions in original row order.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 3, seed = 15)
sf <- mix_segmented_fit("response", d, sp, split_component = "A", cut = .3,
                        model_left = "scheffe_linear", model_right = "scheffe_linear")
head(mix_predict_segmented(sf))
#>   A B C .run response .prediction
#> 1 1 0 0    1 4.746588    4.799441
#> 2 1 0 0    2 5.029602    4.799441
#> 3 1 0 0    3 4.638869    4.799441
#> 4 0 1 0    4 6.461496    6.387524
#> 5 0 1 0    5 6.387843    6.387524
#> 6 0 1 0    6 6.074031    6.387524
head(mix_predict_segmented(sf, interval = "confidence"))
#>   A B C .run response .prediction   .se_link   .lower   .upper
#> 1 1 0 0    1 4.746588    4.799441 0.09716106 4.592347 5.006535
#> 2 1 0 0    2 5.029602    4.799441 0.09716106 4.592347 5.006535
#> 3 1 0 0    3 4.638869    4.799441 0.09716106 4.592347 5.006535
#> 4 0 1 0    4 6.461496    6.387524 0.09134910 6.188491 6.586556
#> 5 0 1 0    5 6.387843    6.387524 0.09134910 6.188491 6.586556
#> 6 0 1 0    6 6.074031    6.387524 0.09134910 6.188491 6.586556
mix_predict_segmented(sf, newdata = data.frame(A = .2, B = .4, C = .4),
                      interval = "confidence")
#>     A   B   C .prediction  .se_link   .lower   .upper
#> 1 0.2 0.4 0.4    6.370581 0.0913491 6.171548 6.569614
```
