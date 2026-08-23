# Enumerate extreme vertices of a linearly constrained mixture region

Uses active-set enumeration for the equality \`sum(x)=total\` plus bound
and general linear inequalities. Intended for moderate-dimensional
constrained mixture problems.

## Usage

``` r
mix_vertices(spec, max_combinations = 250000L, tol = spec$tol %||% 1e-8)
```

## Arguments

- spec:

  A \`mix_spec\` or polytope \`mix_region\` object.

- max_combinations:

  Safety limit for active-set combinations.

- tol:

  Numerical tolerance.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

Data frame of unique feasible extreme vertices.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"), lower = c(.1, .1, .1), upper = c(.7, .8, .8))
mix_vertices(sp)
#>     A   B   C
#> 1 0.7 0.1 0.2
#> 2 0.7 0.2 0.1
#> 3 0.1 0.8 0.1
#> 4 0.1 0.1 0.8
nrow(mix_vertices(sp))
#> [1] 4
sp2 <- mix_spec(c("A", "B", "C"), lower = c(.1, .1, .1), upper = c(.7, .8, .8),
                A = matrix(c(1, 1, 0), 1), b = .75)
mix_vertices(sp2)
#>      A    B    C
#> 1 0.10 0.10 0.80
#> 2 0.10 0.65 0.25
#> 3 0.65 0.10 0.25
```
