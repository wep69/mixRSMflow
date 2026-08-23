# Transform independent coordinates back to mixture coordinates

Transform independent coordinates back to mixture coordinates

## Usage

``` r
mix_inverse_transform(y, spec, center = NULL)
```

## Arguments

- y:

  Matrix or numeric vector with \`q-1\` independent coordinates.

- spec:

  A \`mix_spec\` object.

- center:

  Center used in the inverse transformation.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

Data frame in original mixture coordinates.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
x <- data.frame(A = 0.2, B = 0.3, C = 0.5)
y <- mix_transform(x, sp)
mix_inverse_transform(y, sp)
#>     A   B   C
#> 1 0.2 0.3 0.5
mix_inverse_transform(as.numeric(y[1, ]), sp)
#>     A   B   C
#> 1 0.2 0.3 0.5
mix_inverse_transform(matrix(c(0.1, -0.05, -0.2, 0.15), nrow = 2, byrow = TRUE), sp)
#>           A         B         C
#> 1 0.2830351 0.4244564 0.2925085
#> 2 0.4135174 0.1306747 0.4558078
```
