# Construct multiple-lattice designs for major and minor component groups

The design crosses simplex lattices within major and minor component
groups at user-specified totals allocated to the major group. This
provides a transparent construction for mixture systems in which
components are

## Usage

``` r
mix_multiple_lattice(spec, major, minor = setdiff(spec$components, major),
                                 major_totals, major_degree = 3L, minor_degree = 2L,
                                 max_runs = 100000L, randomize = FALSE, seed = 1L)
```

## Arguments

- spec:

  A \`mix_spec\` object.

- major:

  Character vector of major components.

- minor:

  Character vector of minor components. Defaults to all remaining
  components.

- major_totals:

  Feasible totals assigned to the major-component group.

- major_degree:

  Simplex-lattice degrees within the groups.

- minor_degree:

  Simplex-lattice degrees within the groups.

- max_runs:

  Safety cap before feasibility filtering.

- randomize:

  Randomize run order.

- seed:

  Random seed.

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
sp <- mix_spec(c("A", "B", "C"))
d <- mix_multiple_lattice(sp, major = c("A", "B"), minor = "C",
                          major_totals = c(.6, .8), major_degree = 2, minor_degree = 1)
head(d$data)
#>     A   B   C .run
#> 1 0.0 0.6 0.4    1
#> 2 0.3 0.3 0.4    2
#> 3 0.6 0.0 0.4    3
#> 4 0.0 0.8 0.2    4
#> 5 0.4 0.4 0.2    5
#> 6 0.8 0.0 0.2    6
d2 <- mix_multiple_lattice(sp, major = c("A", "B"), minor = "C",
                           major_totals = .7, major_degree = 2, minor_degree = 2)
nrow(d2$data)
#> [1] 3
d3 <- mix_multiple_lattice(sp, major = c("A", "B"), minor = "C",
                           major_totals = c(.6, .8), major_degree = 1, minor_degree = 1,
                           randomize = TRUE, seed = 6)
head(d3$data)
#>     A   B   C .run
#> 1 0.0 0.6 0.4    1
#> 2 0.6 0.0 0.4    2
#> 4 0.8 0.0 0.2    3
#> 3 0.0 0.8 0.2    4
```
