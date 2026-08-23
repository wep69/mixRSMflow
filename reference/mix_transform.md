# Transform mixture coordinates to independent orthonormal coordinates

Transform mixture coordinates to independent orthonormal coordinates

## Usage

``` r
mix_transform(x, spec, center = NULL)
```

## Arguments

- x:

  Data frame, matrix, or numeric vector of mixture compositions.

- spec:

  A \`mix_spec\` object.

- center:

  Center for the transformation; defaults to \`spec\$center\`.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

Matrix with \`q-1\` independent coordinates.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
x <- data.frame(A = 0.2, B = 0.3, C = 0.5)
mix_transform(x, sp)
#>            [,1]      [,2]
#> [1,] 0.07071068 0.2041241
mix_transform(c(A = 0.2, B = 0.3, C = 0.5), sp)
#>            [,1]      [,2]
#> [1,] 0.07071068 0.2041241
mix_transform(x, sp, center = c(A = 0, B = 0, C = 1))
#>            [,1]       [,2]
#> [1,] 0.07071068 -0.6123724
```
