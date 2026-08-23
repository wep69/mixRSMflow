# Convert between original proportions and lower/upper pseudocomponents

Lower pseudocomponents are defined by z_i = (x_i - L_i)/(T - sum L),
while upper pseudocomponents are defined by u_i = (U_i - x_i)/(sum U -
T). Both transformations preserve a unit-sum simplex after scaling.

## Usage

``` r
mix_pseudocomponents(x, spec, type = c("L", "U"), inverse = FALSE)
```

## Arguments

- x:

  Data frame, matrix, or numeric vector.

- spec:

  A \`mix_spec\` object.

- type:

  \`L\` for lower-bound pseudocomponents or \`U\` for upper-bound
  pseudocomponents.

- inverse:

  If \`TRUE\`, convert pseudocomponents back to original proportions.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A data frame with one column per mixture component.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"), lower = c(.1, .1, .1), upper = c(.8, .8, .8))
x <- data.frame(A = .2, B = .3, C = .5)
z <- mix_pseudocomponents(x, sp, type = "L")
mix_pseudocomponents(z, sp, type = "L", inverse = TRUE)
#>     A   B   C
#> 1 0.2 0.3 0.5
u <- mix_pseudocomponents(x, sp, type = "U")
u
#>           A         B         C
#> 1 0.4285714 0.3571429 0.2142857
```
