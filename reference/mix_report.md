# Create a reproducible scientific mixture-analysis report

Create a reproducible scientific mixture-analysis report

## Usage

``` r
mix_report(object,file=NULL,format=c("markdown","html","docx","pdf"),
                       title="mixRSMflow Scientific Analysis Report",include_session=TRUE)
```

## Arguments

- object:

  A \`mix_fit\`, \`mix_multi_fit\`, or list containing \`fit\`,
  \`design\`, \`optimum\`, and related artifacts.

- file:

  Output path. If omitted, report text is returned.

- format:

  \`markdown\`, \`html\`, \`docx\`, or \`pdf\`.

- title:

  Report title.

- include_session:

  Include session information.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

Invisibly, a \`mix_report\` object containing the report source and
output path.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and `mix_report()`.

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 26)
fit <- mix_fit("response", d, sp)
r <- mix_report(fit, format = "markdown")
r
#> <mix_report> markdown 
#> # mixRSMflow Scientific Analysis Report
#> 
#> Generated: 2026-08-23 23:35:10 UTC
#> 
#> ## Scientific scope
#> 
#> This report was generated from the fitted objects supplied to `mixRSMflow`. It records model specification, diagnostics, uncertainty, and reproducibility metadata; it does not replace scientific judgement.
#> 
#> ## Mixture specification
#> 
#> Components: A, B, C
#> Mixture total: 1
#> Region: polytope
#> 
#> | component | lower | upper |
#> | --- | --- | --- |
#> | A | 0 | 1 |
#> | B | 0 | 1 |
#> | C | 0 | 1 |
#> 
#> ## Model
#> 
#> Response: `response`
#> Model basis: `scheffe_quadratic`
#> Engine: `lm`
#> Observations: 22
#> Estimated terms: 6
#> 
#> ### Coefficients
#> 
#> | estimate | std_error | statistic | p_value |
#> | --- | --- | --- | --- |
#> | 4.67120 | 0.14904 | 31.34132 | 0.00000 |
#> | 6.28176 | 0.14904 | 42.14733 | 0.00000 |
#> | 7.15824 | 0.14904 | 48.02810 | 0.00000 |
#> | 2.51578 | 0.67489 | 3.72772 | 0.00183 |
#> | -2.25477 | 0.67489 | -3.34096 | 0.00415 |
#> | 0.22690 | 0.67489 | 0.33620 | 0.74109 |
#> 
#> ### ANOVA / lack-of-fit
#> 
#> | source | df | SS | MS | F | p_value |
#> | --- | --- | --- | --- | --- | --- |
#> | Regression | 6 | 9.83182 | 1.63864 | NA | NA |
#> | Residual | 16 | 0.76883 | 0.04805 | NA | NA |
#> | Lack of fit | 5 | 0.21092 | 0.04218 | 0.83175 | 0.55329  
#> ...
r2 <- mix_report(fit, format = "html", title = "Exploratory fit", include_session = FALSE)
r3 <- mix_report(list(fit = fit, design = fit$design), format = "markdown")
```
