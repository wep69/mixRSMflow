# Launch the interactive mixRSMflow teaching and analysis application

The Shiny interface mirrors the package workflow and displays
reproducible R commands for the main operations. It is intentionally an
optional interface; all scientific functionality remains available
through the R API.

## Usage

``` r
run_mixrsm_app(launch.browser = TRUE, demo = TRUE)
```

## Arguments

- launch.browser:

  Passed to \`shiny::runApp\`.

- demo:

  If \`TRUE\`, preload a simulated three-component dataset.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

No return value; launches a Shiny application.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  run_mixrsm_app()
  run_mixrsm_app(launch.browser = FALSE, demo = FALSE)
  run_mixrsm_app(launch.browser = FALSE, demo = TRUE)
}
args(run_mixrsm_app)
#> function (launch.browser = TRUE, demo = TRUE) 
#> NULL
requireNamespace("shiny", quietly = TRUE)
```
