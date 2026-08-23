# Fit a Bayesian mixture model through brms

Fit a Bayesian mixture model through brms

## Usage

``` r
mix_fit_bayes(response, data, spec = NULL, model="scheffe_quadratic",
                          family = NULL, random = NULL, prior = NULL,
                          process = NULL, mixture_process = FALSE, terms = NULL, ...,
                          brms_args = list())
```

## Arguments

- response:

  Response column name.

- data:

  Data frame or \`mix_design\`.

- spec:

  Mixture specification.

- model:

  Mixture basis.

- family:

  A \`brms\` family.

- random:

  Optional brms-compatible random-effects expression without the
  response.

- prior:

  Optional brms prior specification.

- process:

  Optional process variables.

- mixture_process:

  Include mixture-process interactions.

- terms:

  Optional mixture-basis terms to retain.

- brms_args:

  Named list of additional arguments passed to \`brms::brm\`.

- ...:

  Additional arguments passed to or from other methods.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_fit_bayes\` object.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
if (FALSE) { # Requires brms and a configured Stan toolchain
  sp <- mix_spec(c("A", "B", "C"))
  d <- mix_demo_data("mixture", n_rep = 2, seed = 6)
  bf <- mix_fit_bayes("response", d, sp, model = "scheffe_quadratic")
  bf2 <- mix_fit_bayes("response", d, sp, model = "scheffe_linear")
  bf3 <- mix_fit_bayes("response", d, sp, model = "scheffe_special_cubic",
                       brms_args = list(iter = 500))
}
```
