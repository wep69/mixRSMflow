# Fit a two-region segmented mixture model

This implementation fits separate mixture response surfaces on two
scientifically specified regions separated by a component threshold. It
intentionally does not impose continuity unless a future model-specific
constraint is supplied, and the

## Usage

``` r
mix_segmented_fit(response, data, spec = NULL, split_component, cut,
                              model_left = "scheffe_quadratic", model_right = model_left,
                              family = stats::gaussian(), ...)
```

## Arguments

- response:

  Response column name.

- data:

  Data frame or \`mix_design\`.

- spec:

  Mixture specification.

- split_component:

  Component defining the two regions.

- cut:

  Split threshold in original mixture units.

- model_left:

  Mixture models fitted below/above the threshold.

- model_right:

  Mixture models fitted below/above the threshold.

- family:

  GLM family used by both segments.

- ...:

  Additional arguments passed to or from other methods.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_segmented_fit\` object.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 3, seed = 14)
sf <- mix_segmented_fit("response", d, sp, split_component = "A", cut = .3,
                        model_left = "scheffe_linear", model_right = "scheffe_linear")
sf
#> <mix_segmented_fit>
#> Split: A <= 0.3 vs > 0.3 
#> Left model: scheffe_linear  Right model: scheffe_linear 
#> Boundary continuity constrained: FALSE 
sf2 <- mix_segmented_fit("response", d, sp, split_component = "A", cut = .4,
                         model_left = "scheffe_linear", model_right = "scheffe_linear")
sf2
#> <mix_segmented_fit>
#> Split: A <= 0.4 vs > 0.4 
#> Left model: scheffe_linear  Right model: scheffe_linear 
#> Boundary continuity constrained: FALSE 
mix_segmented_fit("response", d, sp, split_component = "B", cut = .4,
                  model_left = "scheffe_linear", model_right = "scheffe_linear")
#> <mix_segmented_fit>
#> Split: B <= 0.4 vs > 0.4 
#> Left model: scheffe_linear  Right model: scheffe_linear 
#> Boundary continuity constrained: FALSE 
```
