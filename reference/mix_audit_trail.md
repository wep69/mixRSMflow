# Extract an auditable trail from a mixRSMflow object

Extract an auditable trail from a mixRSMflow object

## Usage

``` r
mix_audit_trail(object)
```

## Arguments

- object:

  Any mixRSMflow result object containing an \`audit\` field.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A normalized data frame of audit steps.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_centroid")
mix_audit_trail(d)
#>         step                    time
#> 1 mix_design 2026-08-23 23:34:38 UTC
#>                                                                                                                                                                                                        details
#> 1 List of 7  $ type          : chr "simplex_centroid"  $ n             : int 7  $ seed          : int 1  $ randomized    : logi FALSE  $ degree        : int 3  $ blocks        : NULL  $ hard_to_change: NULL
fit <- mix_fit("response", mix_demo_data("mixture", n_rep = 2, seed = 30), sp)
mix_audit_trail(fit)
#>      step                    time
#> 1 mix_fit 2026-08-23 23:34:38 UTC
#>                                                                                                                                   details
#> 1 List of 5  $ response: chr "response"  $ model   : chr "scheffe_quadratic"  $ engine  : chr "lm"  $ n       : int 22  $ p       : int 6
mix_audit_trail(sp)
#>       step                    time                                   details
#> 1 mix_spec 2026-08-23 23:34:38 UTC List of 2  $ q    : int 3  $ total: num 1
```
