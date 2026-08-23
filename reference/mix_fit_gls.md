# Fit weighted/generalized least-squares mixture models through nlme

Fit weighted/generalized least-squares mixture models through nlme

## Usage

``` r
mix_fit_gls(response, data, spec = NULL, model = "scheffe_quadratic",
                        process = NULL, mixture_process = FALSE,
                        correlation = NULL, variance = NULL, method = c("REML", "ML"),
                        terms = NULL, ...)
```

## Arguments

- response:

  Response column name.

- data:

  Data frame or \`mix_design\`.

- spec:

  Mixture specification.

- model:

  Mixture basis.

- process:

  Optional process-variable names.

- mixture_process:

  Include mixture-process interactions.

- correlation:

  Optional \`nlme\` correlation structure.

- variance:

  Optional \`nlme\` variance function (e.g. \`varIdent\`, \`varPower\`).

- method:

  \`REML\` or \`ML\`.

- terms:

  Optional basis terms to retain.

- ...:

  Additional arguments passed to or from other methods.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_fit_gls\` object.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
if (requireNamespace("nlme", quietly = TRUE)) {
  sp <- mix_spec(c("A", "B", "C"))
  d <- mix_demo_data("mixture", n_rep = 2, seed = 7)
  gf <- mix_fit_gls("response", d, sp, model = "scheffe_quadratic", method = "ML")
  gf
  gf2 <- mix_fit_gls("response", d, sp, model = "scheffe_linear", method = "REML")
  gf3 <- mix_fit_gls("response", d, sp, model = "scheffe_quadratic", method = "ML",
                     terms = c("A", "B", "C", "A:B"))
  gf2
  gf3
}
#> <mix_fit_gls>
#> Response: response  Model: scheffe_quadratic  Method: ML 
#>      .m1      .m2      .m3      .m4 
#> 4.671572 6.293007 7.000191 2.167565 
```
