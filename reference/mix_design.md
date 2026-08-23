# Generate classical and mixture-process designs

Generate classical and mixture-process designs

## Usage

``` r
mix_design(spec,
                       type = c("simplex_lattice", "simplex_centroid", "axial",
                                "augmented_centroid", "symmetric_simplex",
                                "extreme_vertices", "rotatable", "multiple_lattice",
                                "categorized_components", "mixture_process",
                                "split_plot", "mixture_amount"),
                       degree = 3L, alpha = NULL, include_centroid = TRUE,
                       edge_midpoints = TRUE, base_type = "simplex_centroid",
                       process = NULL, amount = NULL, fraction = NULL,
                       hard_to_change = NULL, fraction_method = c("D", "random"),
                       fraction_model = "scheffe_quadratic",
                       fraction_process_order = 2L, fraction_mixture_process = TRUE,
                       major = NULL, minor = NULL, major_totals = NULL,
                       categories = NULL, category_totals = NULL, between_degree = 2L,
                       within_degree = 2L,
                       blocks = NULL,
                       randomize = FALSE, seed = 1L)
```

## Arguments

- spec:

  A \`mix_spec\` or \`mix_region\` object.

- type:

  Design type. Supported values include \`simplex_lattice\`,
  \`simplex_centroid\`, \`axial\`, \`augmented_centroid\`,
  \`symmetric_simplex\`, \`extreme_vertices\`, \`rotatable\`,
  \`multiple_lattice\`, \`categorized_components\`, \`mixture_process\`,
  \`split_plot\`, and \`mixture_amount\`.

- degree:

  Lattice degree for \`simplex_lattice\` or base resolution.

- alpha:

  Axial mixture coordinate; if \`NULL\`, a midpoint-type value is used.

- include_centroid:

  Add the feasible center where relevant.

- edge_midpoints:

  Include midpoints of extreme-vertex pairs when feasible.

- base_type:

  Base mixture design for mixture-process/amount designs.

- process:

  Named list of process-variable levels.

- amount:

  Numeric levels for total mixture amount.

- fraction:

  Optional fraction \`(0,1\]\` of the crossed design to retain.

- hard_to_change:

  Character names of process variables defining whole plots.

- fraction_method:

  Use \`D\` for model-based D-information fractionation or \`random\`
  for an explicitly random teaching/control fraction.

- fraction_model:

  Mixture basis protected during D-information fractionation.

- fraction_process_order:

  Process polynomial order protected during fractionation.

- fraction_mixture_process:

  Include mixture-by-process interactions in the protected fractionation
  model.

- major:

  Component groups for \`multiple_lattice\`.

- minor:

  Component groups for \`multiple_lattice\`.

- major_totals:

  Totals allocated to the major group.

- categories:

  Named component categories for \`categorized_components\`.

- category_totals:

  Optional category totals for categorized designs.

- between_degree:

  Lattice degrees for categorized designs.

- within_degree:

  Lattice degrees for categorized designs.

- blocks:

  Optional number of blocks for balanced block labels.

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
d <- mix_design(sp, "simplex_centroid")
head(d$data)
#>     A   B   C .run
#> 1 1.0 0.0 0.0    1
#> 2 0.0 1.0 0.0    2
#> 3 0.0 0.0 1.0    3
#> 4 0.5 0.5 0.0    4
#> 5 0.5 0.0 0.5    5
#> 6 0.0 0.5 0.5    6
d2 <- mix_design(sp, "simplex_lattice", degree = 3)
d3 <- mix_design(sp, "axial")
head(d3$data)
#>           A         B         C .run
#> 1 0.6666667 0.1666667 0.1666667    1
#> 2 0.1666667 0.6666667 0.1666667    2
#> 3 0.1666667 0.1666667 0.6666667    3
#> 4 0.3333333 0.3333333 0.3333333    4
```
