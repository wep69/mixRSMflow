# Gaussian-process Bayesian optimization over a mixture region

This advanced adapter uses \`DiceKriging\` when available. It can either
recommend the next feasible composition from existing observations or,
when an explicit deterministic \`objective\` function is supplied,
conduct

## Usage

``` r
mix_bo(data,response,spec,goal=c("maximize","minimize"),iterations=1L,
                   objective=NULL,candidate_n=5000L,nugget=1e-8,seed=1L)
```

## Arguments

- data:

  Existing mixture data.

- response:

  Response column name.

- spec:

  Mixture specification.

- goal:

  \`maximize\` or \`minimize\`.

- iterations:

  Number of sequential recommendations/evaluations.

- objective:

  Optional function accepting a numeric composition vector and returning
  a scalar response.

- candidate_n:

  Number of random feasible candidates per iteration.

- nugget:

  GP nugget parameter.

- seed:

  Random seed.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_bo\` object containing GP history and recommended point(s).

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
if (requireNamespace("DiceKriging", quietly = TRUE)) {
  sp <- mix_spec(c("A", "B", "C"))
  d <- mix_demo_data("mixture", n_rep = 1, seed = 24)
  bo <- mix_bo(d, "response", sp, iterations = 1, candidate_n = 100, seed = 2)
  bo$recommendation
  bo2 <- mix_bo(d, "response", sp, goal = "minimize", iterations = 1, candidate_n = 100, seed = 3)
  bo2$recommendation
  d2 <- d
  d2$.run <- NULL
  bo3 <- mix_bo(d2, "response", sp, iterations = 1, candidate_n = 100, seed = 4,
                objective = function(x) x[1] + 2 * x[2])
  bo3$status
}
#> [1] "sequential_simulation"
```
