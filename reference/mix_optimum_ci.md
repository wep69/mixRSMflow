# Quantify uncertainty in the location of the optimum

Quantify uncertainty in the location of the optimum

## Usage

``` r
mix_optimum_ci(object,method=c("parametric","residual_bootstrap"),B=500L,level=0.95,
                           grid_resolution=20L,seed=1L)
```

## Arguments

- object:

  A \`mix_optimum\` or \`mix_fit\` object.

- method:

  \`parametric\` coefficient simulation or \`residual_bootstrap\`.

- B:

  Number of draws/bootstrap replicates.

- level:

  Confidence level.

- grid_resolution:

  Optimization grid used for each replicate.

- seed:

  Random seed.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_optimum_ci\` object with marginal intervals and a joint cloud of
optimal compositions.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_lattice", degree = 4)$data
set.seed(5)
d$response <- with(d, 6*A + 5*B + 5.5*C + 3*A*B + 2*A*C + 2*B*C) + rnorm(nrow(d), 0, 0.5)
fit <- mix_fit("response", d, sp)
ci <- mix_optimum_ci(fit, method = "parametric", B = 10, grid_resolution = 6, seed = 2)
ci$intervals
#>   component  estimate    lower     upper
#> 1         A 0.5000000 0.051847 0.9591927
#> 2         B 0.1666667 0.000000 0.4813687
#> 3         C 0.3333333 0.000000 0.8875000
ci2 <- mix_optimum_ci(fit, method = "residual_bootstrap", B = 10, grid_resolution = 6, seed = 3)
ci2$intervals
#>   component  estimate      lower     upper
#> 1         A 0.5000000 0.27657344 0.8035363
#> 2         B 0.1666667 0.00000000 0.4593754
#> 3         C 0.3333333 0.01308086 0.6291667
mix_optimum_ci(fit, method = "parametric", B = 10, level = .9, grid_resolution = 6, seed = 4)
#> <mix_optimum_ci> parametric  Successful: 10 / 10 
#>  component  estimate        lower     upper
#>          A 0.5000000 0.0015714310 0.7762701
#>          B 0.1666667 0.0008900304 0.5498325
#>          C 0.3333333 0.0000000000 0.5446590
#> Response interval:
#>    lower   median    upper 
#> 6.288780 6.361365 6.518877 
```
