# Augment an existing design according to an information objective

Augment an existing design according to an information objective

## Usage

``` r
mix_augment(design,n_new=1L,model="scheffe_quadratic",objective=c("D","I","G",
"optimum_uncertainty"),fit=NULL,resolution=15L,seed=1L,candidates=2000L)
```

## Arguments

- design:

  Existing \`mix_design\`.

- n_new:

  Number of additional runs.

- model:

  Model basis.

- objective:

  \`D\`, \`I\`, \`G\`, or \`optimum_uncertainty\`.

- fit:

  Optional fitted model required for optimum-focused augmentation.

- resolution:

  Candidate resolution.

- seed:

  Random seed.

- candidates:

  Maximum number of candidate compositions scored per added run.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

Augmented \`mix_design\`.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_centroid")
a <- mix_augment(d, n_new = 1, model = "scheffe_quadratic", objective = "D",
                 resolution = 6, candidates = 150)
nrow(a$data)
#> [1] 8
a2 <- mix_augment(d, n_new = 1, model = "scheffe_quadratic", objective = "G",
                  resolution = 6, candidates = 150)
a3 <- mix_augment(d, n_new = 1, model = "scheffe_linear", objective = "I",
                  resolution = 6, candidates = 150)
nrow(a3$data)
#> [1] 8
```
