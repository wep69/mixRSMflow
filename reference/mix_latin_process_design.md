# Generate a Latin-square crossed mixture-process design

This helper assigns two process factors with the same number of levels
to a square layout using a cyclic Latin square and crosses each cell
with one row from a base mixture design. It is primarily a structured
teaching/construction

## Usage

``` r
mix_latin_process_design(spec, process1, process2, base_type="simplex_centroid",
degree=2L, seed=1L)
```

## Arguments

- spec:

  A \`mix_spec\` object.

- process1:

  Single-element named lists, for example \`list(temperature = c(20, 30,
  40))\`, containing equal numbers of levels. For backward
  compatibility, a numeric vector with a single common name is also
  accepted.

- process2:

  Single-element named lists, for example \`list(temperature = c(20, 30,
  40))\`, containing equal numbers of levels. For backward
  compatibility, a numeric vector with a single common name is also
  accepted.

- base_type:

  Base mixture design type.

- degree:

  Base mixture lattice degree.

- seed:

  Random seed used when recycling/shuffling mixture runs.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_design\` with row, column, and Latin treatment identifiers.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_latin_process_design(sp, list(temp = c(20, 30)),
                              list(speed = c(100, 200)), seed = 3)
head(d$data)
#>     A   B C temp speed .latin_treatment .row_block .col_block .run
#> 1 1.0 0.0 0   20   100                1          1          1    1
#> 2 0.0 1.0 0   20   200                2          1          2    2
#> 3 0.0 0.0 1   30   100                2          2          1    3
#> 4 0.5 0.5 0   30   200                1          2          2    4
d2 <- mix_latin_process_design(sp, list(temp = c(20, 30, 40)),
                               list(speed = c(100, 200, 300)), seed = 4)
nrow(d2$data)
#> [1] 9
d3 <- mix_latin_process_design(sp, list(temp = c(20, 30)), list(speed = c(100, 200)),
                               base_type = "simplex_lattice", degree = 1, seed = 5)
nrow(d3$data)
#> [1] 4
```
