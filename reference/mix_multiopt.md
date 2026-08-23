# Multiresponse desirability, constraints, and Pareto optimization

Multiresponse desirability, constraints, and Pareto optimization

## Usage

``` r
mix_multiopt(object,goals,settings,response_weights=NULL,constraints=NULL,
                         resolution=25L,random_candidates=5000L,seed=1L)
```

## Arguments

- object:

  A \`mix_multi_fit\` object or named list of \`mix_fit\` objects.

- goals:

  Named character vector (\`maximize\`, \`minimize\`, \`target\`).

- settings:

  Named list; each response entry may contain \`low\`, \`high\`,
  \`target\`, and \`weight\`.

- response_weights:

  Relative weights in the geometric mean of desirabilities.

- constraints:

  Optional named list of response bounds such as
  \`list(y1=c(min=5,max=10))\`.

- resolution:

  Feasible-grid resolution.

- random_candidates:

  Number of random feasible points.

- seed:

  Random seed.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_multiopt\` object with best compromise and Pareto set.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("multiresponse", n_rep = 2, seed = 23)
mf <- mix_multi_fit(c("quality", "stability"), d, sp, model = "scheffe_quadratic")
goals <- c(quality = "maximize", stability = "maximize")
settings <- list(quality = list(low = min(d$quality), high = max(d$quality)),
                 stability = list(low = min(d$stability), high = max(d$stability)))
mo <- mix_multiopt(mf, goals, settings, resolution = 8, random_candidates = 50)
mo$composition
#> A B C 
#> 0 0 1 
mo2 <- mix_multiopt(mf, goals, settings, response_weights = c(quality = 2, stability = 1),
                    resolution = 8, random_candidates = 50)
mo2$composition
#> A B C 
#> 0 0 1 
mo3 <- mix_multiopt(mf, goals, settings, constraints = list(quality = c(min = 4, max = 10)),
                    resolution = 8, random_candidates = 50)
mo3$overall
#> [1] 0.990462
```
