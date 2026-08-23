# Multiresponse prediction biplot over the feasible mixture region

Multiresponse prediction biplot over the feasible mixture region

## Usage

``` r
mix_biplot(object, resolution = 20L, scale = TRUE, plot = TRUE)
```

## Arguments

- object:

  A \`mix_multi_fit\` object.

- resolution:

  Candidate-grid resolution.

- scale:

  Standardize responses before PCA.

- plot:

  If \`TRUE\`, return a ggplot biplot as well.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_biplot\` object containing PCA scores, loadings, candidate
compositions, and optional plot.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("multiresponse", n_rep = 2, seed = 16)
mf <- mix_multi_fit(c("quality", "stability"), d, sp, model = "scheffe_quadratic")
bp <- mix_biplot(mf, resolution = 8, plot = FALSE)
bp$loadings
#>                  PC1        PC2  response
#> quality   -0.7071068 -0.7071068   quality
#> stability  0.7071068 -0.7071068 stability
bp2 <- mix_biplot(mf, resolution = 8, scale = FALSE, plot = FALSE)
bp2$loadings
#>                  PC1       PC2  response
#> quality    0.4201798 0.9074409   quality
#> stability -0.9074409 0.4201798 stability
mf2 <- mix_multi_fit(c("quality", "stability"), d, sp, model = "scheffe_linear")
bp3 <- mix_biplot(mf2, resolution = 6, plot = FALSE)
```
