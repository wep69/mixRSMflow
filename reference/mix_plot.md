# Unified static and interactive plotting for mixture workflows

Unified static and interactive plotting for mixture workflows

## Usage

``` r
mix_plot(object,type=NULL,engine=c("ggplot2","base","plotly"),resolution=30L,views=2L,
                     file=NULL,width=7,height=6,dpi=300,...)
```

## Arguments

- object:

  A \`mix_fit\`, \`mix_design\`, \`mix_design_evaluation\`,
  \`mix_optimum\`, \`mix_optimum_ci\`, \`mix_effect\`, or
  \`mix_multiopt\` object.

- type:

  Plot type. Common choices include \`design\`, \`surface3d\`,
  \`ternary_contour\`, \`ternary_filled\`, \`heatmap\`, \`residuals\`,
  \`qq\`, \`leverage\`, \`fds\`, \`vdg\`, \`component_trace\`,
  \`optimum\`, \`optimum_ci\`, \`desirability\`, and \`pareto\`.

- engine:

  \`ggplot2\`, \`base\`, or \`plotly\`.

- resolution:

  Surface/grid resolution.

- views:

  Number of views for Cornell-style static 3D wireframes.

- file:

  Optional PDF/SVG/PNG/TIFF output path. Base 3D PDF/SVG output is
  vector.

- width:

  Device size in inches.

- height:

  Device size in inches.

- dpi:

  Raster resolution.

- ...:

  Additional arguments passed to or from other methods.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A plot object when applicable, otherwise the plotted data invisibly.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 25)
fit <- mix_fit("response", d, sp)
mix_plot(fit, type = "ternary_contour", resolution = 15)

mix_plot(fit, type = "ternary_filled", resolution = 10)

mix_plot(fit, type = "residuals")
```
