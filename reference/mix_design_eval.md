# Evaluate information and prediction-variance properties of a mixture design

Evaluate information and prediction-variance properties of a mixture
design

## Usage

``` r
mix_design_eval(design,spec=NULL,model="scheffe_quadratic",evaluation=NULL,resolution=15L,
                process=NULL,process_order=2L,mixture_process=FALSE,
                reference=NULL)
```

## Arguments

- design:

  A \`mix_design\` or data frame.

- spec:

  Mixture specification when \`design\` is a data frame.

- model:

  Model basis.

- evaluation:

  Optional prediction-evaluation set.

- resolution:

  Evaluation-grid resolution.

- process:

  Optional process-variable names.

- process_order:

  Process polynomial order.

- mixture_process:

  Include mixture-process interactions.

- reference:

  Optional reference design for relative efficiency calculations.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_design_evaluation\` object containing information criteria, FDS,
and VDG data, and a numeric vector \`prediction_variance\` of
evaluation-grid variances.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_lattice", degree = 3)
ev <- mix_design_eval(d, model = "scheffe_quadratic", resolution = 8)
head(ev$fds)
#>       fraction prediction_variance
#> 1 0.0009560229           0.2552359
#> 2 0.0019120459           0.2552599
#> 3 0.0028680688           0.2553256
#> 4 0.0038240918           0.2553918
#> 5 0.0047801147           0.2554092
#> 6 0.0057361377           0.2555103
ev2 <- mix_design_eval(d, model = "scheffe_special_cubic", resolution = 8)
ev3 <- mix_design_eval(d, model = "scheffe_linear", resolution = 8)
head(ev3$vdg)
#>                 n      mean       q50       q90       max
#> [0,0.158]     105 0.1077675 0.1077506 0.1139702 0.1148607
#> (0.158,0.227] 105 0.1224132 0.1220891 0.1289931 0.1307875
#> (0.227,0.275] 104 0.1393680 0.1402337 0.1439188 0.1452662
#> (0.275,0.323] 105 0.1538288 0.1538729 0.1608716 0.1627350
#> (0.323,0.369] 104 0.1730353 0.1731522 0.1808089 0.1814874
#> (0.369,0.41]  105 0.1917745 0.1914865 0.1996285 0.2010590
```
