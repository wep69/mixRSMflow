# mixRSMflow: Generalized, Correlated, Hierarchical, and Bayesian Mixture Models

**Extended instructional vignette**  
**Package:** `mixRSMflow`  
**Version targeted:** `0.1.0.9000`  
**Extended vignette:** 31  
**Format:** Markdown source only  
**Primary ownership:** response distributions and error structures beyond ordinary Gaussian OLS: WLS, GLM, GLS, linear mixed-effects mixture models, generalized mixed models through optional backend arguments, and Bayesian mixture fitting through `brms`  
**Companion material:** `18-modern-models.Rmd`; Extended Vignette 27 owns the experimental design hierarchy itself

> This document is intentionally supplied as `.md`. Advanced backends are optional. Their numerical outputs and convergence diagnostics must be checked in the local R environment; code availability is not equivalent to scientific validation of a fitted model.

> **Scope boundary.** This extended vignette owns the topic named in its title. Closely related methods that belong to another extended vignette are referenced rather than re-taught. This separation is deliberate so that the extended documentation remains deep without becoming repetitive.

---

## 1. Why the mixture basis and response model must be separated

A mixture model has at least two conceptual layers:

1. **systematic blending structure**, such as a Scheffé quadratic basis;
2. **stochastic response structure**, such as Gaussian, Poisson, binomial, correlated Gaussian, hierarchical Gaussian, or Bayesian multilevel uncertainty.

Changing the response distribution does not remove the mixture constraint. Adding a random block effect does not turn components into ordinary independent factors.

The central rule is:

**Keep the mixture basis explicit while choosing the simplest response/error structure justified by the data-generating process and experimental design.**

---

## 2. Learning objectives

After this vignette, the reader should be able to:

1. distinguish model basis from response family;
2. fit ordinary Gaussian mixture models with `mix_fit()`;
3. use weights when observation precision is known or scientifically modeled;
4. fit Poisson and binomial GLM-style mixture surfaces;
5. explain why overdispersion may require a different engine than ordinary Poisson GLM;
6. fit Gaussian correlated-error models with `mix_fit_gls()`;
7. distinguish residual covariance from random effects;
8. fit hierarchical mixture models with `mix_fit_mixed()`;
9. encode blocks, batches, operators, or whole plots as random effects when scientifically appropriate;
10. pass process terms through the same adapters without losing mixture semantics;
11. fit optional Bayesian mixture models with `mix_fit_bayes()`;
12. state and justify priors rather than relying on opaque defaults;
13. distinguish a Bayesian response fit from a Bayesian optimal-design criterion;
14. use diagnostics and model comparison before interpreting coefficients;
15. avoid automatic escalation to more complex engines.

---

## 3. Function map

| Statistical layer | Function |
|:--|:--|
| Ordinary Gaussian/WLS/GLM | `mix_fit()` |
| Correlated or heterogeneous Gaussian errors | `mix_fit_gls()` |
| Hierarchical/random effects | `mix_fit_mixed()` |
| Bayesian response model | `mix_fit_bayes()` |
| Model matrix | `mix_basis()` |
| Diagnostics | `mix_diagnose()`, `mix_collinearity()` |
| Model comparison | `mix_compare()` |
| Prediction | `mix_predict()` |
| Reporting | `mix_report()` |

---

# Part I. Gaussian OLS as the reference engine

## 4. Baseline example

```r
library(mixRSMflow)

sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 3, seed = 31001)

m_ols <- mix_fit(
  "response",
  d,
  sp,
  model = "scheffe_quadratic",
  family = gaussian()
)

summary(m_ols)
```

Before escalating, examine:

```r
mix_anova(m_ols)
mix_diagnose(m_ols)
mix_collinearity(m_ols)
```

If the Gaussian model is scientifically appropriate and diagnostics are adequate, there is no methodological prize for replacing it with a more complex engine.

---

# Part II. Weighted Gaussian fitting

## 5. When observations have different precision

Suppose each formulation mean is based on a different number of subsamples and a scientifically justified precision weight is available.

```r
d_w <- d
d_w$weight <- seq(0.8, 1.2, length.out = nrow(d_w))

m_wls <- mix_fit(
  "response",
  d_w,
  sp,
  model = "scheffe_quadratic",
  weights = "weight"
)
```

### Interpretation

Weights should represent a known or defensible precision structure. Do not invent weights from residuals solely to force homoscedastic-looking plots without documenting the procedure.

---

# Part III. Generalized-linear mixture models

## 6. Poisson counts

Suppose the response is the number of pest individuals after treatment with a three-component botanical formulation.

```r
set.seed(31101)

d_count <- mix_design(
  sp,
  type = "simplex_lattice",
  degree = 4
)$data

eta <- with(
  d_count,
  1.5 * A + 0.8 * B + 1.2 * C + 0.6 * A * B
)

d_count$count <- rpois(
  nrow(d_count),
  lambda = exp(eta)
)

m_pois <- mix_fit(
  "count",
  d_count,
  sp,
  model = "scheffe_quadratic",
  family = poisson(link = "log")
)

summary(m_pois)
```

### Interpretation

The mixture basis enters the linear predictor. The log link maps the predictor to a positive mean count.

A Poisson model assumes the conditional variance equals the conditional mean. If this assumption is inadequate, use an engine that supports an appropriate alternative such as a generalized mixed model rather than manipulating the response to resemble Gaussian data.

---

## 7. Binomial proportions

Suppose each blend is applied to 20 experimental units and the response is the number showing disease control.

```r
set.seed(31102)

d_bin <- mix_design(
  sp,
  type = "simplex_lattice",
  degree = 4
)$data

lp <- with(
  d_bin,
  -0.5 + 1.8 * A + 0.6 * B - 0.2 * C + 1.0 * A * B
)

p <- plogis(lp)
d_bin$success <- rbinom(nrow(d_bin), size = 20, prob = p)
d_bin$failure <- 20 - d_bin$success
```

For an ordinary binomial GLM, construct the response in a form accepted by the underlying R family when using the lower-level fit workflow.

The key point is not the syntax detail: the mixture terms still represent admissible changes within the simplex, while the binomial family represents sampling variation in the response.

---

## 8. Do not choose a family by histogram alone

Response-family selection should consider:

- experimental sampling unit;
- support of the response;
- mean-variance relationship;
- grouping or repeated observations;
- zero-generation mechanism;
- scientific interpretation of the link.

A right-skewed positive continuous response is not automatically Gamma; a count is not automatically Poisson; a proportion derived from counts is not automatically beta.

---

# Part IV. GLS for residual covariance

## 9. Correlated Gaussian errors

`mix_fit_gls()` delegates Gaussian generalized least squares to `nlme` when available.

```r
if (requireNamespace("nlme", quietly = TRUE)) {
  d_gls <- mix_demo_data(
    "mixture",
    n_rep = 3,
    seed = 31201
  )

  d_gls$batch <- factor(
    rep(seq_len(3), length.out = nrow(d_gls))
  )

  m_gls <- mix_fit_gls(
    "response",
    d_gls,
    sp,
    model = "scheffe_quadratic",
    method = "REML"
  )

  m_gls
}
```

`correlation=` and `variance=` can receive structures supported by `nlme`.

---

## 10. Residual correlation versus random effects

These are not interchangeable concepts.

A random effect models variation among latent experimental units or groups. A residual covariance structure models remaining correlation among observations after fixed and random effects.

For example:

- `batch` random intercept: batches differ in baseline response;
- AR(1) residual correlation: observations close in time remain correlated within a batch;
- variance function: residual variability changes with formulation or process condition.

The correct choice comes from the design and measurement process.

---

## 11. Heterogeneous Gaussian variance

A formulation may be more variable in one part of the mixture space or under one process condition.

If a known `nlme` variance structure is scientifically justified, pass it explicitly through `variance=`.

### Reporting requirement

State the exact covariance and variance functions, the grouping variable, and whether ML or REML was used.

---

# Part V. Hierarchical mixture models

## 12. Blocks and batches

Suppose a mixture experiment is repeated across production batches.

```r
set.seed(31301)

d_mixed <- mix_demo_data(
  "mixture",
  n_rep = 4,
  seed = 31301
)

d_mixed$batch <- factor(
  rep(seq_len(4), length.out = nrow(d_mixed))
)
```

Fit:

```r
if (requireNamespace("lme4", quietly = TRUE)) {
  m_mixed <- mix_fit_mixed(
    response = "response",
    data = d_mixed,
    spec = sp,
    random = "(1 | batch)",
    model = "scheffe_quadratic"
  )

  m_mixed
}
```

### Interpretation

The random intercept estimates between-batch heterogeneity while the mixture coefficients describe the population-average blending structure conditional on the model parameterization.

---

## 13. Random effects must follow experimental units

Possible legitimate random grouping factors include:

- blocks;
- batches;
- greenhouse benches;
- operators sampled from a larger population;
- whole plots;
- experimental units repeatedly measured under several process conditions.

Do not add a random intercept because the fixed-effect model has a large p-value or because it lowers AIC. Random effects encode a sampling or randomization structure.

---

## 14. Split-plot connection

When `mix_design(type="split_plot")` creates `.whole_plot`, the corresponding analysis can include

```r
random = "(1 | .whole_plot)"
```

if that matches the actual randomization.

The design construction itself is owned by Extended Vignette 27; this vignette focuses on the stochastic model used after data are observed.

---

## 15. Mixture-process mixed model

The same adapter can include process terms.

```r
if (requireNamespace("lme4", quietly = TRUE)) {
  mp <- mix_demo_data(
    "mixture_process",
    n_rep = 2,
    seed = 31401
  )

  mp$batch <- factor(
    rep(seq_len(4), length.out = nrow(mp))
  )

  m_mp_mixed <- mix_fit_mixed(
    response = "response",
    data = mp,
    spec = sp,
    random = "(1 | batch)",
    model = "scheffe_quadratic",
    process = c("temperature", "time"),
    mixture_process = TRUE
  )
}
```

The mixture basis and random-effects hierarchy remain separate layers.

---

# Part VI. Generalized mixed models through the mixed adapter

## 16. Why combine a non-Gaussian family with random effects?

Examples include:

- pest counts across blocks;
- disease incidence across greenhouse benches;
- emergence successes within field blocks;
- repeated count outcomes from the same experimental unit.

`mix_fit_mixed()` accepts an optional `family` and delegates to an appropriate mixed-model backend when supported.

### Scientific checklist

Before fitting:

1. identify the response support;
2. identify the experimental grouping;
3. decide whether overdispersion or zero inflation is plausible;
4. verify backend capability;
5. inspect simulation-based or family-appropriate diagnostics in the backend where necessary.

The package should not be used as a reason to ignore backend-specific diagnostics.

---

# Part VII. Bayesian mixture models

## 17. Bayesian fitting preserves the mixture basis

The optional adapter `mix_fit_bayes()` delegates to `brms`.

```r
if (FALSE) {
  # Requires brms and a working Stan toolchain.
  library(brms)

  d_b <- mix_demo_data(
    "mixture",
    n_rep = 3,
    seed = 31501
  )

  priors <- c(
    prior(normal(0, 5), class = "b"),
    prior(exponential(1), class = "sigma")
  )

  m_bayes <- mix_fit_bayes(
    response = "response",
    data = d_b,
    spec = sp,
    model = "scheffe_quadratic",
    prior = priors,
    brms_args = list(
      chains = 4,
      iter = 4000,
      seed = 31501
    )
  )

  m_bayes
}
```

---

## 18. Priors are part of the scientific model

A prior on mixture coefficients should reflect the response scale and basis scaling.

Useful sources include:

- previous experiments with comparable formulations;
- measurement-scale knowledge;
- plausible response ranges;
- mechanistic constraints.

A vague prior is still a modeling choice. Report it.

---

## 19. Bayesian design is not Bayesian fitting

Extended Vignette 25 includes `BayesD` and `BayesI` **design criteria**, which use prior precision to choose experimental runs.

`mix_fit_bayes()` instead performs **Bayesian response estimation** after data are observed.

A study can use:

- classical design + Bayesian fit;
- Bayesian optimal design + frequentist fit;
- Bayesian design + Bayesian fit;
- neither.

The two layers should be named separately.

---

## 20. Posterior workflow expectations

A Bayesian analysis should include, through `brms` tools as appropriate:

- prior inspection;
- prior predictive checks;
- convergence (`R-hat`);
- effective sample size;
- trace behavior;
- posterior intervals;
- posterior predictive checks;
- sensitivity to influential priors;
- model comparison only when scientifically justified.

`mixRSMflow` preserves the mixture semantics but does not exempt the analyst from the diagnostic requirements of the Bayesian backend.

---

# Part VIII. Model comparison across engines

## 21. Do not compare incomparable likelihoods casually

AIC/BIC comparisons are meaningful only when models are fitted to the same response data under compatible likelihood definitions.

Examples of poor comparison:

- Gaussian OLS versus a transformed-response model without accounting for the transformation;
- REML fits with different fixed-effects structures;
- frequentist likelihood AIC versus a Bayesian posterior score as if they were identical;
- models using different observation subsets.

Use `mix_compare()` when the objects support a common criterion and supplement with scientific diagnostics.

---

## 22. A structured escalation path

Recommended sequence:

1. ordinary Gaussian mixture model if appropriate;
2. inspect residual diagnostics;
3. WLS if known precision differs;
4. GLS if residual covariance/heterogeneity is supported;
5. mixed effects if the experimental unit hierarchy requires it;
6. non-Gaussian family if response support requires it;
7. Bayesian fitting if posterior inference or prior information adds scientific value.

Complexity should solve an identified problem.

---

# Part IX. Agronomic case: blocked count response

## 23. Scientific problem

A botanical pesticide formulation has three component proportions and is evaluated in field blocks. The response is insect count after treatment.

### Step 1: mixture region

```r
sp_pest <- mix_spec(
  c("ActiveA", "ActiveB", "Adjuvant"),
  lower = c(0.05, 0.05, 0.10)
)
```

### Step 2: design

Use the design-focused documentation to construct the run plan before outcomes.

### Step 3: create teaching data

```r
set.seed(31601)

dp <- mix_design(
  sp_pest,
  "simplex_lattice",
  degree = 3
)$data

dp <- dp[rep(seq_len(nrow(dp)), each = 4), ]
dp$block <- factor(rep(1:4, times = nrow(dp) / 4))

eta <- with(
  dp,
  2.0 - 1.5 * ActiveA - 1.0 * ActiveB + 0.3 * Adjuvant
)

dp$count <- rpois(nrow(dp), exp(eta))
```

### Step 4: choose the stochastic model

If counts are independent conditional on block and the backend supports the declared family, use a generalized mixed model. If overdispersion is strong, an alternative count distribution may be required through the backend.

### Step 5: interpret on the response scale

A log-link coefficient is not a raw count difference. Translate predicted values to expected counts for scientifically relevant formulations.

### Step 6: show uncertainty

Use prediction or posterior intervals appropriate to the fitted engine and state whether they describe the conditional mean or future observation variability.

---

# Part X. Diagnostics by engine

## 24. OLS/WLS

Inspect:

- residual versus fitted pattern;
- Q-Q behavior;
- leverage;
- Cook distance;
- pure error/lack of fit where available;
- condition number.

Use:

```r
mix_diagnose(m_ols)
mix_collinearity(m_ols)
```

---

## 25. GLS

In addition to mean-model diagnostics, inspect:

- fitted correlation parameter;
- fitted variance function;
- residual pattern after standardization;
- sensitivity to covariance structure;
- ML versus REML choice for comparison.

---

## 26. Mixed models

Inspect:

- convergence;
- singularity;
- variance components;
- random-effect scale;
- residual patterns;
- influential groups if the backend supports them.

A variance component near zero can indicate the grouping effect is not estimable at the available information level. It does not automatically mean the experimental hierarchy was conceptually wrong.

---

## 27. Bayesian models

Inspect posterior diagnostics rather than only point summaries.

A posterior interval from a poorly converged chain is not a reliable uncertainty statement.

---

# Part XI. Common mistakes

## 28. Transforming every non-Gaussian response to force OLS

Use a response family that matches the data-generating process where appropriate.

---

## 29. Choosing Poisson for every count

Check dispersion and grouping.

---

## 30. Adding random effects to improve p-values

Random effects follow design or sampling hierarchy.

---

## 31. Modeling batch correlation twice without justification

Do not automatically combine a batch random effect and a residual covariance structure that represent the same dependence.

---

## 32. Comparing REML fits with different fixed effects using ordinary AIC logic

Use an appropriate comparison strategy.

---

## 33. Calling Bayesian intervals confidence intervals

Use the correct inferential language.

---

## 34. Treating backend convergence as a package detail

It is a scientific validity issue.

---

# Part XII. Function-selection guide

| Data/design issue | Start with |
|:--|:--|
| Gaussian independent residuals | `mix_fit()` |
| Known precision weights | `mix_fit(weights=...)` |
| Poisson/binomial ordinary response | `mix_fit(family=...)` |
| Correlated Gaussian residuals | `mix_fit_gls()` |
| Heterogeneous Gaussian residuals | `mix_fit_gls(variance=...)` |
| Block/batch/whole-plot random effects | `mix_fit_mixed()` |
| Non-Gaussian + random effects | `mix_fit_mixed(family=...)` when backend supports it |
| Posterior inference | `mix_fit_bayes()` |
| Mixture-process design construction | Extended Vignette 27 |
| Bayesian design criterion | Extended Vignette 25 |

---

# Part XIII. Reporting checklist

- [ ] mixture model basis;
- [ ] response distribution;
- [ ] link function;
- [ ] weights and their scientific origin;
- [ ] GLS covariance structure;
- [ ] GLS variance structure;
- [ ] ML/REML setting;
- [ ] random-effect formula;
- [ ] grouping factors and experimental units;
- [ ] generalized mixed-model family if used;
- [ ] backend package/version;
- [ ] convergence diagnostics;
- [ ] singularity or near-zero variance components;
- [ ] residual/family diagnostics;
- [ ] prior specification for Bayesian fit;
- [ ] chain/iteration settings;
- [ ] posterior convergence and predictive checks;
- [ ] interpretation on response scale;
- [ ] uncertainty type;
- [ ] limits of extrapolation within the mixture region.

---

# Appendix A. Compact engine comparison script

```r
library(mixRSMflow)

sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 3, seed = 20260813)

m_ols <- mix_fit(
  "response", d, sp,
  model = "scheffe_quadratic"
)

mix_diagnose(m_ols)

if (requireNamespace("nlme", quietly = TRUE)) {
  m_gls <- mix_fit_gls(
    "response", d, sp,
    model = "scheffe_quadratic",
    method = "REML"
  )
}

if (requireNamespace("lme4", quietly = TRUE)) {
  d$batch <- factor(rep(1:3, length.out = nrow(d)))

  m_mixed <- mix_fit_mixed(
    "response", d, sp,
    random = "(1 | batch)",
    model = "scheffe_quadratic"
  )
}
```

---

# Appendix B. Boundary with other extended vignettes

This vignette owns the stochastic response/error layer. Geometry is in 24, design optimality in 25, alternative blending bases in 26, experimental randomization structure in 27, multiresponse decisions in 28, optimum uncertainty in 29, sequential BO in 30, graphics in 32, and software validation in 33.

---

# Final perspective

The mixture basis answers **how composition enters the systematic response**. The family, covariance, random effects, and priors answer **how uncertainty and dependence are represented**.

A defensible escalation path is:

**basis -> simplest plausible response model -> diagnostics -> covariance/hierarchy if required -> generalized family if required -> Bayesian extension if scientifically useful -> prediction on the original response scale.**


---

# Appendix C. Advanced response-engine laboratories

## C1. Laboratory: OLS versus GLS

Simulate heteroscedastic Gaussian residuals whose variance differs across a process condition. Fit ordinary OLS and an appropriate `nlme` GLS variance structure. Compare residual plots and coefficient uncertainty.

### Lesson

A change in standard errors can reflect a better error model without changing the mixture basis.

---

## C2. Laboratory: batch random effect

Simulate four production batches with a random baseline shift and fit:

1. OLS ignoring batch;
2. fixed batch effects;
3. random batch intercept with `mix_fit_mixed()`.

Discuss which estimand is appropriate if batches are sampled from a broader production process.

---

## C3. Laboratory: Poisson overdispersion warning

Generate count data with variance larger than the mean. Fit a Poisson mixture GLM and inspect dispersion. Explain why a different generalized mixed/backend distribution may be needed rather than transforming the count to approximate normality.

---

## C4. Laboratory: Bayesian prior-scale check

Before a `brms` fit, translate plausible response ranges into coefficient-prior scales. Compare a very wide prior with a moderately regularizing prior through prior predictive simulation in the backend.

### Lesson

Prior scale must be interpreted relative to the mixture basis and link function.

---

# Appendix D. Response-engine troubleshooting matrix

| Symptom | Likely issue | Response |
|:--|:--|:--|
| residual funnel under OLS | heteroscedasticity | consider weights/GLS if scientifically supported |
| residual correlation by batch/time | ignored dependence | GLS or mixed structure depending mechanism |
| mixed model singular | unsupported random variance/correlation | inspect hierarchy and replication |
| Poisson residual variance too large | overdispersion | use appropriate count backend/model |
| Bayesian chains have high R-hat | nonconvergence | improve model/prior/sampling; do not interpret |
| posterior dominated by prior | weak data or too-informative prior | perform sensitivity analysis |
| GLS and mixed fit differ greatly | structures answer different dependence questions | revisit experimental unit logic |
| AIC compared across incompatible fits | invalid comparison | use compatible likelihood/inference framework |

---

# Appendix E. Guided response-model exercises

### Exercise 1. Family support

List the response support and a plausible family/link for counts, proportions from counts, positive continuous concentration, and Gaussian yield.

### Exercise 2. Weights

Construct a scenario where one formulation mean is based on 20 subsamples and another on 5. Explain when precision weights are justified.

### Exercise 3. GLS covariance

Describe the difference between heteroscedasticity across process settings and correlation among repeated observations.

### Exercise 4. Random batch

Explain why batch can be random even though the mixture components are fixed design variables.

### Exercise 5. Whole plots

Translate `.whole_plot` from Extended Vignette 27 into a random-intercept formula.

### Exercise 6. Overdispersion

Explain why a Poisson model can underestimate uncertainty when conditional variance exceeds mean.

### Exercise 7. Link interpretation

Convert a log-link coefficient contrast into a response ratio interpretation.

### Exercise 8. Bayesian prior

Choose priors for a response measured between roughly 0 and 100 and explain why `normal(0,1000)` may be less useful than a scale-aware prior.

### Exercise 9. Bayesian design distinction

Write two sentences distinguishing `criterion="BayesI"` from `mix_fit_bayes()`.

### Exercise 10. Prediction scale

Explain the difference between linear-predictor and response-scale predictions in a GLM.

### Exercise 11. Model comparison

State when ML rather than REML is required for fixed-effect comparison in Gaussian mixed models.

### Exercise 12. Reviewer exercise

A paper says “a mixed model was used” without random-effect formula or experimental unit. Draft the minimum information needed.

---

# Appendix F. Reviewer-style stochastic-model audit

Check:

1. response support and units;
2. family and link;
3. weights;
4. covariance structure;
5. variance structure;
6. fixed mixture basis;
7. process terms;
8. random effects and grouping units;
9. backend/version;
10. convergence/singularity;
11. residual/family diagnostics;
12. priors and sampling diagnostics for Bayes;
13. response-scale interpretation;
14. compatible model-comparison method.

---

# Appendix G. Interpretation language templates

### GLS

> The Scheffé quadratic mean structure was retained while residual covariance was modeled using the declared GLS structure. Thus, the composition-response estimand remained unchanged while uncertainty accounted for the observed dependence/heterogeneity.

### Random batch

> Production batch was modeled as a random intercept because batches represented a sample from a broader production process. Mixture composition remained a fixed designed predictor.

### Count model

> Expected counts were modeled on the log scale using the mixture basis. Effects are therefore interpreted through multiplicative changes in expected response rather than raw additive count differences.

### Bayesian fit

> Bayesian estimation used the same declared mixture basis with explicit priors and posterior diagnostics. Posterior intervals are reported as credible intervals and are not described as frequentist confidence intervals.


---

# Appendix H. Applied response-engine case bank

## H1. Heterogeneous assay precision

A biochemical response is measured with different laboratory replication across formulations. If known measurement precision differs, WLS can weight observations appropriately. The weight definition must come from the measurement process rather than from a desire to reduce residuals. If variability depends systematically on a process variable, GLS variance structures may be more appropriate.

## H2. Greenhouse blocks

A mixture experiment is replicated across greenhouse benches. Bench-to-bench differences can be modeled as random if benches represent a sample from a broader operational population. The mixture basis remains fixed. A random bench effect changes covariance among observations, not the definition of the formulation region.

## H3. Pest counts

Counts after treatment are nonnegative integers. A Poisson mixture GLM can be a starting point, but biological counts often show overdispersion or clustering. If variance greatly exceeds the mean, a different count distribution or generalized mixed backend is needed. Transforming `sqrt(count)` by habit can obscure the natural mean-variance structure.

## H4. Disease incidence

A response such as diseased plants out of 20 should use binomial sampling logic rather than treating the observed proportion as Gaussian automatically. If observations are grouped in blocks, the sampling family and experimental random effects both matter.

## H5. Bayesian small-sample formulation

A small expensive experiment has prior information from a previous formulation version. A Bayesian mixture fit can use that information transparently, provided prior transferability is justified. Posterior predictive checks and prior sensitivity are essential. This is separate from using a Bayesian optimal-design criterion before data collection.

---

# Appendix I. Short-answer response-engine review

1. **What does the mixture basis describe?** Systematic composition-response structure.
2. **What does the family describe?** Conditional response distribution/link.
3. **What does GLS add?** Residual covariance/heterogeneity for Gaussian responses.
4. **What does a random effect represent?** Group-level variation tied to design or sampling.
5. **Why not use random effects to improve p-values?** They must reflect experimental structure.
6. **What indicates Poisson overdispersion?** Conditional variance substantially exceeding the mean.
7. **What must a Bayesian fit report?** Priors, sampling settings, convergence, posterior checks.
8. **Are BayesI design and `mix_fit_bayes()` the same?** No; one chooses runs, the other estimates a response model.
9. **Why interpret on the response scale?** Links such as log/logit change coefficient meaning.
10. **When should complexity stop?** When the simplest scientifically plausible model adequately describes dependence and response support.


---

# Appendix J. Deeper conceptual notes on stochastic modeling

## J1. The mean model can be correct while the error model is wrong

A Scheffé quadratic surface may capture the expected response well while residual variance changes across process conditions or observations remain correlated within batches. In that case, changing to GLS or a mixed model can improve uncertainty quantification without changing the scientific mean-response hypothesis. This distinction is important when explaining why coefficient estimates remain similar but standard errors change.

## J2. Random effects do not repair confounding

If a treatment is applied only once within a batch, adding a random batch effect cannot magically separate treatment from batch. Random effects represent covariance and population heterogeneity, but estimability still depends on the design. Experimental structure must be considered before model complexity.

## J3. Link-scale versus response-scale interpretation

In Poisson or binomial models, mixture terms act on the linear-predictor scale. A coefficient difference may correspond to a response ratio or odds ratio, not an additive raw-scale difference. Publication tables should therefore include response-scale predictions for meaningful formulations in addition to link-scale coefficients.

## J4. Bayesian regularization and prior transfer

Prior information can stabilize small experiments, but only when its scale and transferability are credible. Priors from a previous crop, formulation, or assay should not be transferred automatically. Sensitivity analysis with weaker priors helps reveal how much the posterior conclusion depends on historical information.

## J5. Engine-specific diagnostics remain essential

`mixRSMflow` provides common semantics, but it does not reduce every backend to identical diagnostics. `nlme`, `lme4`, generalized mixed engines, and `brms` each have specialized convergence and residual tools. Advanced users should consult the backend diagnostics after the common mixture workflow identifies the appropriate model class.
