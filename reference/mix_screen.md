# Screen component directional effects with uncertainty

Screen component directional effects with uncertainty

## Usage

``` r
mix_screen(object, direction = c("cox", "piepel"), reference = NULL,
                       level = 0.95, delta = 1e-5)
```

## Arguments

- object:

  A \`mix_fit\` object.

- direction:

  \`cox\` or \`piepel\`.

- reference:

  Feasible reference composition; defaults to \`spec\$center\`.

- level:

  Confidence level.

- delta:

  Finite-difference step in path coordinates.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

Data frame of local directional slopes, standard errors, confidence
intervals, and p-values.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 13)
fit <- mix_fit("response", d, sp)
mix_screen(fit, direction = "cox")
#>   component      slope        se        lower      upper      p_value    scale
#> 1         A -1.9684016 0.1923636 -2.376194220 -1.5606089 1.992581e-08 response
#> 2         B  1.5541790 0.1923636  1.146386405  1.9619717 4.877540e-07 response
#> 3         C  0.4142225 0.1923636  0.006429902  0.8220152 4.689047e-02 response
mix_screen(fit, direction = "piepel")
#>   component      slope        se        lower      upper      p_value    scale
#> 1         A -1.9684016 0.1923636 -2.376194220 -1.5606089 1.992581e-08 response
#> 2         B  1.5541790 0.1923636  1.146386405  1.9619717 4.877540e-07 response
#> 3         C  0.4142225 0.1923636  0.006429902  0.8220152 4.689047e-02 response
mix_screen(fit, direction = "cox", reference = c(A = .4, B = .3, C = .3), level = .9)
#>   component      slope        se       lower     upper      p_value    scale
#> 1         A -1.9652453 0.1634161 -2.25055086 -1.679940 1.993896e-09 response
#> 2         B  1.8982869 0.2102032  1.53129657  2.265277 1.112690e-07 response
#> 3         C  0.3477077 0.2102032 -0.01928257  0.714698 1.175785e-01 response
```
