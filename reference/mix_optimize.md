# Optimize a fitted mixture response surface under exact mixture constraints

Optimize a fitted mixture response surface under exact mixture
constraints

## Usage

``` r
mix_optimize(object,goal=c("maximize","minimize","target"),target=NULL,
                         method=c("hybrid","grid","ga"),grid_resolution=30L,
                         random_candidates=5000L,near_tolerance=0.01,seed=1L)
```

## Arguments

- object:

  A \`mix_fit\` object.

- goal:

  \`maximize\`, \`minimize\`, or \`target\`.

- target:

  Target response for \`goal="target"\`.

- method:

  \`hybrid\`, \`grid\`, or \`ga\`.

- grid_resolution:

  Feasible-grid resolution.

- random_candidates:

  Number of random feasible candidates added to the grid.

- near_tolerance:

  Relative tolerance defining the near-optimal region.

- seed:

  Random seed.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_optimum\` object containing the best composition, response, and
near-optimal region.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 20)
fit <- mix_fit("response", d, sp)
opt <- mix_optimize(fit, goal = "maximize", method = "grid", grid_resolution = 7,
                    random_candidates = 0)
opt$composition
#> A B C 
#> 0 0 1 
opt2 <- mix_optimize(fit, goal = "minimize", method = "grid", grid_resolution = 7,
                     random_candidates = 0)
opt2$composition
#> A B C 
#> 1 0 0 
opt3 <- mix_optimize(fit, goal = "target", target = 6, method = "grid",
                     grid_resolution = 7, random_candidates = 0)
```
