# Fit a mixed-effects mixture model through lme4

This adapter preserves the mixture basis while delegating mixed-model
estimation to \`lme4::lmer\` or \`lme4::glmer\`. It is intended for
block, split-plot, and related hierarchical designs.

## Usage

``` r
mix_fit_mixed(response, data, spec = NULL, random,
                          model = "scheffe_quadratic", family = NULL,
                          process = NULL, mixture_process = FALSE, terms = NULL, ...)
```

## Arguments

- response:

  Response column name.

- data:

  Data frame or \`mix_design\`.

- spec:

  Mixture specification.

- random:

  Random-effects term such as \`(1\|block)\`.

- model:

  Mixture basis.

- family:

  \`NULL\` for \`lmer\`, otherwise a GLM family for \`glmer\`.

- process:

  Optional process variables.

- mixture_process:

  Include mixture-process interactions.

- terms:

  Optional mixture-basis terms to retain.

- ...:

  Additional arguments passed to or from other methods.

## Details

This help page is a prebuilt source-snapshot reference. The roxygen2
comments in the R source are authoritative and should be regenerated
with roxygen2 during the local release gate.

## Value

A \`mix_fit_mixed\` object.

## See also

[`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md),
the package vignettes, and
[`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md).

## Examples

``` r
if (requireNamespace("lme4", quietly = TRUE)) {
  sp <- mix_spec(c("A", "B", "C"))
  d <- mix_demo_data("mixture", n_rep = 3, seed = 5)
  d$block <- factor(rep(seq_len(3), length.out = nrow(d)))
  mm <- mix_fit_mixed("response", d, sp, random = "(1|block)", model = "scheffe_linear")
  mm
  d2 <- d
  d2$response <- d2$response + as.numeric(d2$block)
  mm2 <- mix_fit_mixed("response", d2, sp, random = "(1|block)", model = "scheffe_quadratic")
  mm3 <- mix_fit_mixed("response", d2, sp, random = "(1|block)", model = "scheffe_linear")
}
#> boundary (singular) fit: see help('isSingular')
```
