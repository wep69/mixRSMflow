# Define a curved or independent-coordinate region of interest

Define a curved or independent-coordinate region of interest

## Usage

``` r
mix_region(spec, type = c("polytope", "sphere", "ellipsoid", "cuboid"),
                       center = NULL, radius = NULL, shape = NULL,
                       lower_y = NULL, upper_y = NULL)
```

## Arguments

- spec:

  A \`mix_spec\` object.

- type:

  Region type: \`polytope\`, \`sphere\`, \`ellipsoid\`, or \`cuboid\`.

- center:

  Optional center in original mixture coordinates.

- radius:

  Radius in orthonormal independent coordinates for a sphere.

- shape:

  Positive-definite \`(q-1) x (q-1)\` ellipsoid shape matrix.

- lower_y:

  Bounds in independent coordinates for a cuboid.

- upper_y:

  Bounds in independent coordinates for a cuboid.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_region\` object inheriting from \`mix_spec\`.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
rg <- mix_region(sp, type = "sphere", radius = 0.2)
rg$region
#> $type
#> [1] "sphere"
#> 
#> $center
#> [1] 0.3333333 0.3333333 0.3333333
#> 
#> $radius
#> [1] 0.2
#> 
rg2 <- mix_region(sp, type = "ellipsoid", shape = diag(2))
rg2$region
#> $type
#> [1] "ellipsoid"
#> 
#> $center
#> [1] 0.3333333 0.3333333 0.3333333
#> 
#> $shape
#>      [,1] [,2]
#> [1,]    1    0
#> [2,]    0    1
#> 
rg3 <- mix_region(sp, type = "cuboid", lower_y = c(-0.3, -0.3), upper_y = c(0.3, 0.3))
rg3$region
#> $type
#> [1] "cuboid"
#> 
#> $center
#> [1] 0.3333333 0.3333333 0.3333333
#> 
#> $lower_y
#> [1] -0.3 -0.3
#> 
#> $upper_y
#> [1] 0.3 0.3
#> 
```
