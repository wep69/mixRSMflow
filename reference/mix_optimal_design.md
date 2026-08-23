# Construct exact optimal mixture designs

Construct exact optimal mixture designs

## Usage

``` r
mix_optimal_design(spec,model="scheffe_quadratic",runs,
                               criterion=c("D","A","I","G","E","T","Alias","BayesD",
                               "BayesI"),
                               algorithm=c("hybrid","exchange","ga"),candidates=NULL,
                               evaluation=NULL,
                               resolution=12L,random_candidates=1000L,process=NULL,
                               process_order=2L,
                               mixture_process=FALSE,allow_replicates=TRUE,
                               robust=c("mean","worst"),
                               prior_precision=NULL,alternative_model=NULL,
                               alias_model=NULL,
                               starts=3L,max_iter=20L,population=40L,generations=50L,
                               seed=1L)
```

## Arguments

- spec:

  Mixture specification.

- model:

  Primary model basis or vector of model names for model-robust design.

- runs:

  Number of exact design runs.

- criterion:

  Optimality criterion: D, A, I, G, E, T, Alias, BayesD, or BayesI.

- algorithm:

  \`exchange\`, \`ga\`, or \`hybrid\`.

- candidates:

  Optional candidate data frame. If omitted, a feasible grid plus random
  points is generated.

- evaluation:

  Optional prediction-evaluation grid for I/G criteria.

- resolution:

  Simplex grid resolution.

- random_candidates:

  Additional random feasible candidates.

- process:

  Optional named list of process levels to cross with mixture
  candidates.

- process_order:

  Process polynomial order.

- mixture_process:

  Include mixture-process interactions.

- allow_replicates:

  Allow replicated exact design points.

- robust:

  \`mean\` or \`worst\` aggregation across multiple candidate models.

- prior_precision:

  Prior precision matrix/scalar for BayesD/BayesI linear-normal
  criteria.

- alternative_model:

  Alternative model for T-optimal discrimination.

- alias_model:

  Higher-order model supplying omitted columns for Alias criterion.

- starts:

  Number of independent starts.

- max_iter:

  Exchange iterations.

- population:

  GA population size.

- generations:

  GA generations.

- seed:

  Random seed.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_design\` with optimality metadata.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
od <- mix_optimal_design(sp, model = "scheffe_quadratic", runs = 8, criterion = "D",
                         algorithm = "exchange", resolution = 5, random_candidates = 20,
                         starts = 1, max_iter = 2, seed = 19)
od
#> <mix_design> optimal 
#>  Runs: 8 
#>  Components: A, B, C 
#>    A   B   C .run
#>  0.0 1.0 0.0    1
#>  0.0 0.4 0.6    2
#>  1.0 0.0 0.0    3
#>  0.4 0.0 0.6    4
#>  0.0 0.0 1.0    5
#>  0.6 0.0 0.4    6
#>  0.6 0.4 0.0    7
#>  0.0 0.6 0.4    8
od2 <- mix_optimal_design(sp, model = "scheffe_quadratic", runs = 8, criterion = "A",
                          algorithm = "exchange", resolution = 5, random_candidates = 20,
                          starts = 1, max_iter = 2, seed = 11)
od2
#> <mix_design> optimal 
#>  Runs: 8 
#>  Components: A, B, C 
#>          A         B         C .run
#>  0.3725824 0.3662282 0.2611894    1
#>  0.0000000 0.6000000 0.4000000    2
#>  0.6000000 0.0000000 0.4000000    3
#>  1.0000000 0.0000000 0.0000000    4
#>  0.0000000 1.0000000 0.0000000    5
#>  0.0000000 0.0000000 1.0000000    6
#>  0.6000000 0.4000000 0.0000000    7
#>  0.0000000 0.4000000 0.6000000    8
od3 <- mix_optimal_design(sp, model = "scheffe_quadratic", runs = 8, criterion = "D",
                          algorithm = "ga", resolution = 5, random_candidates = 20,
                          population = 8, generations = 3, seed = 7)
od3
#> <mix_design> optimal 
#>  Runs: 8 
#>  Components: A, B, C 
#>          A          B         C .run
#>  0.8000000 0.20000000 0.0000000    1
#>  0.2469426 0.02435927 0.7286981    2
#>  0.2347951 0.15877841 0.6064264    3
#>  0.4000000 0.60000000 0.0000000    4
#>  0.0000000 1.00000000 0.0000000    5
#>  0.0000000 0.00000000 1.0000000    6
#>  0.3333333 0.33333333 0.3333333    7
#>  1.0000000 0.00000000 0.0000000    8
```
