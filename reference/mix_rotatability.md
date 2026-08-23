# Assess approximate rotatability through radial prediction-variance dispersion

Assess approximate rotatability through radial prediction-variance
dispersion

## Usage

``` r
mix_rotatability(design, spec = NULL, model = "scheffe_quadratic", bins = 6L, resolution
= 18L)
```

## Arguments

- design:

  A \`mix_design\` or data frame.

- spec:

  Mixture specification when \`design\` is a data frame.

- model:

  Model basis.

- bins:

  Number of radial bins in independent coordinates.

- resolution:

  Evaluation-grid resolution.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_rotatability\` object. A score near one indicates low
within-radius variance dispersion.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_lattice", degree = 3)
mix_rotatability(d, model = "scheffe_quadratic", resolution = 8)
#> <mix_rotatability> Score: 0.96398 
#>  bin    radius      mean          sd         cv   n
#>    1 0.1410146 0.3139104 0.007888179 0.02512876 258
#>    2 0.2610968 0.3273208 0.032542641 0.09942123 258
#>    3 0.3381404 0.3565436 0.065774205 0.18447730 257
#>    4 0.4003225 0.3906961 0.097450805 0.24942865 258
#>    5 0.4867717 0.3427473 0.074562691 0.21754418 257
#>    6 0.6301291 0.4264172 0.112916514 0.26480289 258
#> Score is a numerical diagnostic, not a formal proof of exact rotatability. 
mix_rotatability(d, model = "scheffe_linear", resolution = 8)
#> <mix_rotatability> Score: 0.99321 
#>  bin    radius      mean          sd         cv   n
#>    1 0.1410146 0.1133701 0.007592849 0.06697401 258
#>    2 0.2610968 0.1413087 0.008083513 0.05720462 258
#>    3 0.3381404 0.1688332 0.007925978 0.04694561 257
#>    4 0.4003225 0.1963578 0.008872517 0.04518547 258
#>    5 0.4867717 0.2426853 0.017247170 0.07106804 257
#>    6 0.6301291 0.3409372 0.052718645 0.15462859 258
#> Score is a numerical diagnostic, not a formal proof of exact rotatability. 
mix_rotatability(d, model = "scheffe_quadratic", bins = 4, resolution = 8)
#> <mix_rotatability> Score: 0.95936 
#>  bin    radius      mean         sd         cv   n
#>    1 0.1736894 0.3170228 0.01639253 0.05170772 387
#>    2 0.3197643 0.3481388 0.05920459 0.17006032 386
#>    3 0.4205271 0.3768893 0.09635097 0.25564796 386
#>    4 0.5907839 0.3964394 0.10676904 0.26931994 387
#> Score is a numerical diagnostic, not a formal proof of exact rotatability. 
```
