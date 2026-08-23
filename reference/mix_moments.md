# Compute moments over a simplex or approximate moments over a constrained region

Compute moments over a simplex or approximate moments over a constrained
region

## Usage

``` r
mix_moments(spec, powers, method = c("auto", "exact", "monte_carlo"), n = 100000L, seed =
1L)
```

## Arguments

- spec:

  Mixture specification.

- powers:

  Non-negative exponent vector or matrix; one column per component.

- method:

  \`auto\`, \`exact\`, or \`monte_carlo\`. Exact moments are available
  for the unrestricted simplex.

- n:

  Number of Monte Carlo feasible points.

- seed:

  Random seed.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

Data frame containing one moment for each row of \`powers\`.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
mix_moments(sp, powers = c(1, 1, 0), method = "exact")
#>   A B C     moment mc_se method
#> 1 1 1 0 0.08333333     0  exact
mix_moments(sp, powers = c(2, 0, 0), method = "exact")
#>   A B C    moment mc_se method
#> 1 2 0 0 0.1666667     0  exact
mix_moments(sp, powers = c(1, 1, 1), method = "monte_carlo", n = 20000, seed = 2)
#>   A B C     moment        mc_se      method
#> 1 1 1 1 0.01669483 7.741138e-05 monte_carlo
```
