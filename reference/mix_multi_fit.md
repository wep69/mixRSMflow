# Fit several responses using a shared mixture specification

Fit several responses using a shared mixture specification

## Usage

``` r
mix_multi_fit(responses,data,spec=NULL,...)
```

## Arguments

- responses:

  Character vector of response columns.

- data:

  Data frame or \`mix_design\`.

- spec:

  Mixture specification.

- ...:

  Additional arguments passed to or from other methods.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_multi_fit\` object.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("multiresponse", n_rep = 2, seed = 22)
mf <- mix_multi_fit(c("quality", "stability"), d, sp, model = "scheffe_quadratic")
mf
#> <mix_multi_fit> Responses: quality, stability 
mf2 <- mix_multi_fit(c("quality", "stability"), d, sp, model = "scheffe_linear")
mf3 <- mix_multi_fit("quality", d, sp, model = "scheffe_special_cubic")
mf3
#> <mix_multi_fit> Responses: quality 
```
