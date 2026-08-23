# Define a mixture specification

Creates the central specification object used by all mixRSMflow
workflows. Components are constrained to sum to \`total\`, while
optional lower, upper, and linear restrictions define the feasible
composition region.

## Usage

``` r
mix_spec(components, total = 1, lower = 0, upper = total,
                     A = NULL, b = NULL, dir = "<=", units = "proportion",
                     tol = 1e-8)
```

## Arguments

- components:

  Character vector of component names.

- total:

  Mixture total, usually 1 or 100.

- lower:

  Lower bounds for each component.

- upper:

  Upper bounds for each component.

- A:

  Optional linear-constraint matrix with one column per component.

- b:

  Right-hand side vector for \`A\`.

- dir:

  Direction(s) for the linear restrictions: \`\<=\`, \`\>=\`, or \`==\`.

- units:

  Optional text describing component units.

- tol:

  Numerical feasibility tolerance.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

An object of class \`mix_spec\`.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
sp
#> <mix_spec>
#>  Components: A, B, C 
#>  Total: 1 
#>  Region: polytope 
#>  Bounds:
#>  component lower upper
#>          A     0     1
#>          B     0     1
#>          C     0     1
sp2 <- mix_spec(c("A", "B", "C"), lower = c(.1, .1, .1), upper = c(.7, .8, .8))
sp2
#> <mix_spec>
#>  Components: A, B, C 
#>  Total: 1 
#>  Region: polytope 
#>  Bounds:
#>  component lower upper
#>          A   0.1   0.7
#>          B   0.1   0.8
#>          C   0.1   0.8
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
sp3 <- mix_spec(c("A", "B", "C"), A = matrix(c(1, 0, 0), nrow = 1), b = 0.5)
sp3
#> <mix_spec>
#>  Components: A, B, C 
#>  Total: 1 
#>  Region: polytope 
#>  Bounds:
#>  component lower upper
#>          A     0     1
#>          B     0     1
#>          C     0     1
#>  General linear inequalities: 1 
```
