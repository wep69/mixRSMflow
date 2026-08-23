# Model-based fractionation of crossed mixture-process designs

Selects a full-rank fraction using QR initialization and a D-information
exchange search rather than silently taking an arbitrary subset.

## Usage

``` r
mix_fractionate_process(design, process, fraction,
  model = "scheffe_quadratic", process_order = 2L,
  mixture_process = TRUE, seed = 1L, exchange_iter = 300L)
```

## Arguments

- design:

  A `mix_design` containing mixture and process columns.

- process:

  Character vector naming process variables.

- fraction:

  Fraction in (0,1\] or integer number of runs.

- model:

  Mixture basis protected during fractionation.

- process_order:

  Process polynomial order.

- mixture_process:

  Whether mixture-by-process interactions are protected.

- seed:

  Seed used in exchange-search exploration.

- exchange_iter:

  Maximum exchange iterations.

## Value

A fractionated `mix_design`.

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
mp <- mix_design(sp, "mixture_process", process = list(temp = c(-1, 1)))
fr <- mix_fractionate_process(mp, process = "temp", fraction = 10,
                              process_order = 1, mixture_process = FALSE)
nrow(fr$data)
#> [1] 10
fr2 <- mix_fractionate_process(mp, process = "temp", fraction = .5,
                               process_order = 1, mixture_process = FALSE)
nrow(fr2$data)
#> [1] 7
mix_fractionate_process(mp, process = "temp", fraction = 8, model = "scheffe_linear",
                        process_order = 1, mixture_process = FALSE)
#> <mix_design> mixture_process_fractionated 
#>  Runs: 8 
#>  Components: A, B, C 
#>    A   B   C .run temp
#>  1.0 0.0 0.0    1   -1
#>  0.0 1.0 0.0    2   -1
#>  0.0 0.0 1.0    3   -1
#>  0.5 0.5 0.0    4   -1
#>  1.0 0.0 0.0    5    1
#>  0.0 1.0 0.0    6    1
#>  0.0 0.0 1.0    7    1
#>  0.5 0.0 0.5    8    1
```
