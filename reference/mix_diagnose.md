# Diagnose a fitted mixture model

Diagnose a fitted mixture model

## Usage

``` r
mix_diagnose(object)
```

## Arguments

- object:

  A \`mix_fit\` object.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_diagnostics\` object with observation-level and matrix
diagnostics.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 9)
fit <- mix_fit("response", d, sp)
mix_diagnose(fit)
#> <mix_diagnostics>
#>  Rank: 6 / 6  Condition number: 8.7058 
#>  .row   fitted    residual  leverage cooks_distance
#>     1 4.612134 -0.05015690 0.4622896    0.014651578
#>     2 4.612134 -0.05909612 0.4622896    0.020339530
#>     3 6.172599  0.10192504 0.4622896    0.060504094
#>     4 6.172599  0.07743247 0.4622896    0.034919594
#>     5 7.147333  0.13120193 0.4622896    0.100254396
#>     6 7.147333 -0.16097037 0.4622896    0.150908913
#>     7 6.103040  0.16151810 0.3567340    0.081924078
#>     8 6.103040 -0.05631381 0.3567340    0.009958615
#>     9 5.321969 -0.04162412 0.3567340    0.005440757
#>    10 5.321969 -0.06229753 0.3567340    0.012187395
dg <- mix_diagnose(fit)
names(dg)
#> [1] "observations"            "condition_number"       
#> [3] "singular_values"         "coefficient_correlation"
#> [5] "rank"                    "p"                      
#> [7] "n"                       "warnings"               
fit2 <- mix_fit("response", d, sp, model = "scheffe_linear")
mix_diagnose(fit2)
#> <mix_diagnostics>
#>  Rank: 3 / 3  Condition number: 1.5635 
#>  .row   fitted    residual  leverage cooks_distance
#>     1 4.672572 -0.11059521 0.2676768    0.018648207
#>     2 4.672572 -0.11953443 0.2676768    0.021784643
#>     3 6.512252 -0.23772873 0.2676768    0.086164381
#>     4 6.512252 -0.26222130 0.2676768    0.104833570
#>     5 6.923237  0.35529838 0.2676768    0.192464621
#>     6 6.923237  0.06312609 0.2676768    0.006075502
#>     7 5.592412  0.67214548 0.1010101    0.172480954
#>     8 5.592412  0.45431358 0.1010101    0.078799963
#>     9 5.797904 -0.51755962 0.1010101    0.102266960
#>    10 5.797904 -0.53823303 0.1010101    0.110600036
```
