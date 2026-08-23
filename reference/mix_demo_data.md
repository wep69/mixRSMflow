# Generate reproducible pedagogical mixture datasets

The datasets are simulated and carry known response-generating
mechanisms, avoiding licensing problems associated with textbook
datasets.

## Usage

``` r
mix_demo_data(kind=c("mixture","mixture_process","multiresponse"),n_rep=3L,seed=20260813L)
```

## Arguments

- kind:

  \`mixture\`, \`mixture_process\`, or \`multiresponse\`.

- n_rep:

  Number of replicates per base blend for \`mixture\` and
  \`multiresponse\`.

- seed:

  Random seed.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A data frame with mixture components and simulated response(s).

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
d <- mix_demo_data("mixture", n_rep = 2, seed = 27)
head(d)
#>   A B C .run response
#> 1 1 0 0    1 5.043289
#> 2 1 0 0    2 4.906078
#> 3 0 1 0    3 6.162384
#> 4 0 1 0    4 6.037662
#> 5 0 0 1    5 7.003176
#> 6 0 0 1    6 7.253143
head(mix_demo_data("mixture_process", n_rep = 1, seed = 2))
#>     A   B   C .run temperature time response
#> 1 1.0 0.0 0.0    1          -1   -1 4.238555
#> 2 0.0 1.0 0.0    2          -1   -1 5.383273
#> 3 0.0 0.0 1.0    3          -1   -1 6.985812
#> 4 0.5 0.5 0.0    4          -1   -1 5.171532
#> 5 0.5 0.0 0.5    5          -1   -1 4.785555
#> 6 0.0 0.5 0.5    6          -1   -1 6.423836
head(mix_demo_data("multiresponse", n_rep = 1, seed = 3))
#>     A   B   C .run response  quality     cost stability
#> 1 1.0 0.0 0.0    1 4.526852 4.526852 5.364254  7.269441
#> 2 0.0 1.0 0.0    2 6.247345 6.247345 9.714037  4.050029
#> 3 0.0 0.0 1.0    3 7.246582 7.246582 8.430318  7.727332
#> 4 0.5 0.5 0.0    4 5.842616 5.842616 7.668245  6.063839
#> 5 0.5 0.0 0.5    5 5.360241 5.360241 6.913081  7.724092
#> 6 0.0 0.5 0.5    6 6.755422 6.755422 8.485638  6.201810
```
