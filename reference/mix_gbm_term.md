# Define one general blending model term

Creates a validated term specification for the general blending model
(GBM) parameterization of Brown, Donev and Bissett. The nonlinear
exponents are fixed by this specification; the associated regression
coefficient is then

## Usage

``` r
mix_gbm_term(components, g = 1, h = NULL, s = 1, label = NULL)
```

## Arguments

- components:

  Two or three component names (or positions).

- g:

  Component-specific non-negative/flexible power parameters.

- h:

  For a binary term, one allocation parameter. For a ternary term, two
  allocation parameters whose sum is at most one.

- s:

  Homogeneity/order exponent applied to the component subtotal.

- label:

  Optional basis-column label.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A list suitable for the \`gbm_terms\` argument of \[mix_basis()\] or
\[mix_fit()\].

## References

Brown, L., Donev, A. N., & Bissett, A. C. (2015). General Blending
Models for Data From Mixture Experiments. Technometrics, 57, 449-456.
doi:10.1080/00401706.2014.947003.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
term <- mix_gbm_term(c("A", "B"), g = c(1, 1), h = 0.5, s = 1)
term
#> $components
#> [1] "A" "B"
#> 
#> $g
#> [1] 1 1
#> 
#> $h
#> [1] 0.5
#> 
#> $s
#> [1] 1
#> 
#> $label
#> NULL
#> 
sp <- mix_spec(c("A", "B", "C"))
X <- mix_basis(data.frame(A = .2, B = .3, C = .5), sp, "gbm", gbm_terms = list(term))
X
#>        A   B   C GBM:A:B[g=1,1;h=0.5;s=1]
#> [1,] 0.2 0.3 0.5                 0.244949
#> attr(,"mix_model")
#> [1] "gbm"
mix_gbm_term(c("A", "B", "C"), g = c(1, 1, 1), h = 1/3, s = 1)
#> $components
#> [1] "A" "B" "C"
#> 
#> $g
#> [1] 1 1 1
#> 
#> $h
#> [1] 0.3333333
#> 
#> $s
#> [1] 1
#> 
#> $label
#> NULL
#> 
mix_gbm_term(c("A", "B", "C"), g = c(1, 2, 1), h = c(0.25, 0.25), s = 1)
#> $components
#> [1] "A" "B" "C"
#> 
#> $g
#> [1] 1 2 1
#> 
#> $h
#> [1] 0.25 0.25
#> 
#> $s
#> [1] 1
#> 
#> $label
#> NULL
#> 
```
