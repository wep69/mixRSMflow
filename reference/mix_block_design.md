# Allocate a mixture design to approximately orthogonal balanced blocks

A balanced swap-search minimizes squared differences among block totals
of standardized model columns. Exact orthogonality is reported when
achieved numerically; otherwise the result is explicitly labelled
near-orthogonal.

## Usage

``` r
mix_block_design(design, n_blocks, model = "scheffe_quadratic", iterations = 50000L, seed
= 1L)
```

## Arguments

- design:

  A \`mix_design\` object.

- n_blocks:

  Number of blocks.

- model:

  Model basis whose estimability should be balanced over blocks.

- iterations:

  Maximum pair-swap attempts.

- seed:

  Random seed.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A new \`mix_design\` with \`.block\` and block-balance diagnostics.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_lattice", degree = 3)
bd <- mix_block_design(d, n_blocks = 2, iterations = 100, seed = 2)
table(bd$data$.block)
#> 
#> 1 2 
#> 5 5 
bd2 <- mix_block_design(d, n_blocks = 3, iterations = 100, seed = 4)
table(bd2$data$.block)
#> 
#> 1 2 3 
#> 4 3 3 
mix_block_design(d, n_blocks = 2, model = "scheffe_linear", iterations = 100, seed = 5)
#> <mix_design> simplex_lattice_blocked 
#>  Runs: 10 
#>  Components: A, B, C 
#>          A         B         C .run .block
#>  0.0000000 0.0000000 1.0000000    1      2
#>  0.0000000 0.3333333 0.6666667    2      1
#>  0.0000000 0.6666667 0.3333333    3      2
#>  0.0000000 1.0000000 0.0000000    4      1
#>  0.3333333 0.0000000 0.6666667    5      1
#>  0.3333333 0.3333333 0.3333333    6      2
#>  0.3333333 0.6666667 0.0000000    7      2
#>  0.6666667 0.0000000 0.3333333    8      1
#>  0.6666667 0.3333333 0.0000000    9      1
#>  1.0000000 0.0000000 0.0000000   10      2
```
