# Audited hierarchical model reduction for mixture response surfaces

The default hybrid score combines prediction error, numerical
conditioning, and parsimony. Term removal is considered only when
hierarchy is preserved. No term is removed solely because of a p-value.

## Usage

``` r
mix_reduce(object, criterion = c("hybrid", "press", "aic", "bic"),
                       min_terms = NULL, max_steps = 50L, protect = NULL, tolerance =
                       1e-4)
```

## Arguments

- object:

  A \`mix_fit\` object.

- criterion:

  \`hybrid\`, \`press\`, \`aic\`, or \`bic\`.

- min_terms:

  Minimum number of retained basis columns.

- max_steps:

  Maximum backward-removal steps.

- protect:

  Terms that may not be removed; component main terms are protected by
  default.

- tolerance:

  Required fractional score improvement for a removal.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_reduction\` object containing the selected fit and complete
audit path.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 3, seed = 12)
fit <- mix_fit("response", d, sp, model = "scheffe_special_cubic")
red <- mix_reduce(fit, criterion = "press", max_steps = 2)
red$retained_terms
#> [1] "A"   "B"   "C"   "A:B" "A:C" "B:C"
red2 <- mix_reduce(fit, criterion = "aic", max_steps = 2)
red2$retained_terms
#> [1] "A"   "B"   "C"   "A:B" "A:C" "B:C"
mix_reduce(fit, criterion = "bic", max_steps = 2)
#> <mix_reduction> Criterion: bic 
#> Retained terms: 6  Removed: 1 
#> Removed: A:B:C 
#>  step removed p     score accepted                                  reason
#>     0    <NA> 7 -100.2510     TRUE                           initial model
#>     1   A:B:C 6 -102.7327     TRUE score improved with hierarchy preserved
#>     2     B:C 6 -102.1488    FALSE           no material score improvement
```
