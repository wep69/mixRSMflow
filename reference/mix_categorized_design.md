# Construct categorized-component or mixture-of-mixtures designs

Components are grouped into named categories. A between-category simplex
lattice allocates the total among categories; within each positive
category, another lattice allocates that category total among its
components. The same

## Usage

``` r
mix_categorized_design(spec, categories, between_degree = 2L, within_degree = 2L,
                                   category_totals = NULL, max_runs = 100000L, seed = 1L)
```

## Arguments

- spec:

  A \`mix_spec\` object.

- categories:

  Named list of non-overlapping component vectors covering all
  components.

- between_degree:

  Simplex-lattice degree for category totals.

- within_degree:

  Scalar or named degrees used inside categories.

- category_totals:

  Optional data frame/matrix of pre-specified category totals.

- max_runs:

  Safety cap on expanded combinations.

- seed:

  Random seed recorded in metadata.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_design\` object.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C", "D"))
cats <- list(base = c("A", "B"), additive = c("C", "D"))
d <- mix_categorized_design(sp, cats, between_degree = 2, within_degree = 1)
head(d$data)
#>     A   B   C   D .run
#> 1 0.0 0.0 0.0 1.0    1
#> 2 0.0 0.0 1.0 0.0    2
#> 3 0.0 0.5 0.0 0.5    3
#> 4 0.5 0.0 0.0 0.5    4
#> 5 0.0 0.5 0.5 0.0    5
#> 6 0.5 0.0 0.5 0.0    6
d2 <- mix_categorized_design(sp, cats, between_degree = 2, within_degree = 2)
d3 <- mix_categorized_design(sp, cats, between_degree = 1, within_degree = 1)
head(d3$data)
#>   A B C D .run
#> 1 0 0 0 1    1
#> 2 0 0 1 0    2
#> 3 0 1 0 0    3
#> 4 1 0 0 0    4
```
