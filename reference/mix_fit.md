# Fit classical and generalized mixture response-surface models

Fit classical and generalized mixture response-surface models

## Usage

``` r
mix_fit(response, data, spec = NULL,
                    model = "scheffe_quadratic", family = stats::gaussian(),
                    weights = NULL, offset = NULL, process = NULL,
                    process_order = 2L, mixture_process = FALSE, terms = NULL, ...)
```

## Arguments

- response:

  Response column name.

- data:

  Data frame or \`mix_design\` containing observed responses.

- spec:

  Mixture specification. If \`data\` is a \`mix_design\`, its
  specification is used by default.

- model:

  Mixture basis passed to \[mix_basis()\].

- family:

  A GLM family; Gaussian identity is the classical default.

- weights:

  Optional observation weights or column name.

- offset:

  Optional offset vector or column name.

- process:

  Optional process-variable names.

- process_order:

  Polynomial order for process variables.

- mixture_process:

  Include mixture by process interactions.

- terms:

  Optional basis-column names or indices to retain. This supports
  audited model reduction while preserving the original model family.

- ...:

  Additional arguments passed to or from other methods.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_fit\` object.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 4)
fit <- mix_fit("response", d, sp, model = "scheffe_quadratic")
coef(fit)
#>          A          B          C        A:B        A:C        B:C 
#>  4.6867799  6.4505916  7.3565890  1.5100929 -1.6191029 -0.5568988 
fit2 <- mix_fit("response", d, sp, model = "scheffe_linear")
fit3 <- mix_fit("response", d, sp, model = "scheffe_special_cubic")
coef(fit3)
#>          A          B          C        A:B        A:C        B:C      A:B:C 
#>  4.6864655  6.4502771  7.3562745  1.5174048 -1.6117910 -0.5495868 -0.0955266 
```
