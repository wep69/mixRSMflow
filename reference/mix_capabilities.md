# Inspect the package capability registry

Inspect the package capability registry

## Usage

``` r
mix_capabilities(module = NULL, tier = NULL)
```

## Arguments

- module:

  Optional module filter.

- tier:

  Optional validation-tier filter.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A data frame describing source-implemented capabilities, optional
backends, target validation tiers, and current runtime-certification
status.

## See also

`mix_capabilities()`, the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
head(mix_capabilities())
#>           capability module validation_tier implementation
#> 1    simplex_lattice design          Tier 1         native
#> 2   simplex_centroid design          Tier 1         native
#> 3              axial design          Tier 1         native
#> 4 augmented_centroid design          Tier 1         native
#> 5  symmetric_simplex design          Tier 1         native
#> 6   extreme_vertices design          Tier 1         native
#>            runtime_status
#> 1 local_runtime_validated
#> 2 local_runtime_validated
#> 3 local_runtime_validated
#> 4 local_runtime_validated
#> 5 local_runtime_validated
#> 6 local_runtime_validated
mix_capabilities(module = "optimal_design")
#>                  capability         module validation_tier implementation
#> 1                 D_optimal optimal_design          Tier 1         native
#> 2                 A_optimal optimal_design          Tier 1         native
#> 3                 I_optimal optimal_design          Tier 1         native
#> 4                 G_optimal optimal_design          Tier 1         native
#> 5                 E_optimal optimal_design          Tier 1         native
#> 6                 T_optimal optimal_design          Tier 2         native
#> 7             alias_optimal optimal_design          Tier 1         native
#> 8                bayesian_D optimal_design          Tier 2         native
#> 9                bayesian_I optimal_design          Tier 2         native
#> 10     model_robust_optimal optimal_design          Tier 2         native
#> 11 genetic_algorithm_design optimal_design          Tier 1         native
#> 12                      FDS optimal_design          Tier 1         native
#> 13                      VDG optimal_design          Tier 1         native
#> 14  rotatability_diagnostic optimal_design          Tier 1         native
#> 15  sequential_augmentation optimal_design          Tier 1         native
#>             runtime_status
#> 1  local_runtime_validated
#> 2  local_runtime_validated
#> 3  local_runtime_validated
#> 4  local_runtime_validated
#> 5  local_runtime_validated
#> 6  local_runtime_validated
#> 7  local_runtime_validated
#> 8  local_runtime_validated
#> 9  local_runtime_validated
#> 10 local_runtime_validated
#> 11 local_runtime_validated
#> 12 local_runtime_validated
#> 13 local_runtime_validated
#> 14 local_runtime_validated
#> 15 local_runtime_validated
mix_capabilities(module = "design")
#>                           capability module validation_tier implementation
#> 1                    simplex_lattice design          Tier 1         native
#> 2                   simplex_centroid design          Tier 1         native
#> 3                              axial design          Tier 1         native
#> 4                 augmented_centroid design          Tier 1         native
#> 5                  symmetric_simplex design          Tier 1         native
#> 6                   extreme_vertices design          Tier 1         native
#> 7                   multiple_lattice design          Tier 1         native
#> 8             categorized_components design          Tier 1         native
#> 9  rotatable_independent_coordinates design          Tier 1         native
#> 10                   mixture_process design          Tier 1         native
#> 11                    mixture_amount design          Tier 1         native
#> 12                 split_plot_design design          Tier 2         native
#> 13              latin_square_process design          Tier 2         native
#> 14                   block_balancing design          Tier 2         native
#>             runtime_status
#> 1  local_runtime_validated
#> 2  local_runtime_validated
#> 3  local_runtime_validated
#> 4  local_runtime_validated
#> 5  local_runtime_validated
#> 6  local_runtime_validated
#> 7  local_runtime_validated
#> 8  local_runtime_validated
#> 9  local_runtime_validated
#> 10 local_runtime_validated
#> 11 local_runtime_validated
#> 12 local_runtime_validated
#> 13 local_runtime_validated
#> 14 local_runtime_validated
nrow(mix_capabilities())
#> [1] 71
```
