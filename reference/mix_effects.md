# Compute interpretable component effects and trace paths

Compute interpretable component effects and trace paths

## Usage

``` r
mix_effects(object,type=c("cox","piepel","component_trace","substitution","directional"),
                        component=NULL,reference=NULL,n=101L,from_component=NULL,
                        to_component=NULL,
                        direction=NULL,delta=1e-4)
```

## Arguments

- object:

  A \`mix_fit\` object.

- type:

  Effect type: \`cox\`, \`piepel\`, \`component_trace\`,
  \`substitution\`, or \`directional\`.

- component:

  Focal component name.

- reference:

  Reference composition; defaults to the fitted specification center.

- n:

  Number of trace points.

- from_component:

  Component to decrease for substitution effects.

- to_component:

  Component to increase for substitution effects.

- direction:

  Optional custom direction vector for \`directional\`.

- delta:

  Small step used to report a local numerical slope.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_effect\` list with path, predictions, and local slope.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 17)
fit <- mix_fit("response", d, sp)
e <- mix_effects(fit, type = "cox", component = "A", n = 21)
head(e$path)
#>      A     B     C .prediction   .se_link   .lower   .upper
#> 1 0.00 0.500 0.500    6.829646 0.07429353 6.672151 6.987142
#> 2 0.05 0.475 0.475    6.735755 0.06332275 6.601517 6.869994
#> 3 0.10 0.450 0.450    6.640261 0.05443763 6.524859 6.755664
#> 4 0.15 0.425 0.425    6.543164 0.04773544 6.441969 6.644358
#> 5 0.20 0.400 0.400    6.444463 0.04319585 6.352892 6.536034
#> 6 0.25 0.375 0.375    6.344160 0.04059458 6.258103 6.430216
e2 <- mix_effects(fit, type = "piepel", component = "B", n = 21)
e2$local_slope
#> [1] 1.653513
mix_effects(fit, type = "substitution", from_component = "A", to_component = "B", n = 21)
#> <mix_effect> substitution 
#>  Local slope: 2.48604 
#>          A          B         C .prediction   .se_link   .lower   .upper
#>  0.6666667 0.00000000 0.3333333    4.982320 0.06925092 4.835514 5.129125
#>  0.6333333 0.03333333 0.3333333    5.134048 0.06244863 5.001663 5.266434
#>  0.6000000 0.06666667 0.3333333    5.278529 0.05664876 5.158439 5.398619
#>  0.5666667 0.10000000 0.3333333    5.415760 0.05183154 5.305883 5.525638
#>  0.5333333 0.13333333 0.3333333    5.545744 0.04795327 5.444087 5.647400
#>  0.5000000 0.16666667 0.3333333    5.668478 0.04494288 5.573204 5.763753
#>  0.4666667 0.20000000 0.3333333    5.783965 0.04270416 5.693436 5.874493
#>  0.4333333 0.23333333 0.3333333    5.892202 0.04112555 5.805020 5.979385
```
