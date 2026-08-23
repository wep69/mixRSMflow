# mixRSMflow: Optimum Location, Uncertainty, and Near-Optimal Regions

**Extended instructional vignette**  
**Package:** `mixRSMflow`  
**Version targeted:** `0.1.0.9000`  
**Extended vignette:** 29  
**Format:** Markdown source only  
**Primary ownership:** constrained single-response optimization, maximum/minimum/target goals, exact versus practical optima, boundary solutions, near-optimal regions, parametric optimum-location uncertainty, residual bootstrap, joint optimum clouds, marginal component intervals, and decision interpretation  
**Companion material:** `13-optimization.Rmd`, `14-optimum-uncertainty.Rmd`

> This document is intentionally supplied as `.md`. An optimum is only as credible as the fitted response surface and the feasible region. Diagnose the model before using any optimization result.

> **Scope boundary.** This extended vignette owns the topic named in its title. Closely related methods that belong to another extended vignette are referenced rather than re-taught. This separation is deliberate so that the extended documentation remains deep without becoming repetitive.

---

## 1. The fitted optimum is not the end of the analysis

Response-surface software can return a mathematically exact optimum to many decimal places. That numerical precision is not the same as scientific certainty.

If the response surface is flat near the maximum, many formulations may be practically indistinguishable. If coefficients are uncertain, the optimum may move substantially when the surface is perturbed. If the best point is on a boundary, the constraint itself may define part of the result.

The central rule is:

**Report where the fitted optimum is, how uncertain its location is, and which nearby blends perform nearly as well.**

---

## 2. Learning objectives

After this vignette, the reader should be able to:

1. maximize a fitted mixture response inside the declared feasible region;
2. minimize a response or find a composition near a target value;
3. compare grid, GA, and hybrid optimization routes;
4. identify boundary versus interior optima;
5. explain why a constrained optimum can be driven by bounds;
6. define a practical near-optimal tolerance;
7. distinguish exact mathematical optimum from practical equivalent solutions;
8. construct parametric coefficient-simulation uncertainty for the optimum;
9. construct residual-bootstrap uncertainty for supported Gaussian fits;
10. interpret the joint optimum cloud;
11. interpret marginal component intervals without pretending component coordinates are independent;
12. assess whether the optimum location is stable across model choices;
13. connect flat response surfaces with broad optimum uncertainty;
14. report a recommended formulation together with feasible alternatives.

---

## 3. Function map

| Task | Function |
|:--|:--|
| Fit response surface | `mix_fit()` |
| Diagnose before optimization | `mix_anova()`, `mix_diagnose()`, `mix_collinearity()` |
| Predict on candidate blends | `mix_predict()` |
| Optimize | `mix_optimize()` |
| Optimum uncertainty | `mix_optimum_ci()` |
| Plot optimum | `mix_plot(type="optimum")` |
| Plot joint uncertainty | `mix_plot(type="optimum_ci")` |
| Design around current optimum | `mix_augment(objective="optimum_uncertainty")` — detailed in Vignette 30 |

---

# Part I. Prepare a trustworthy fitted surface

## 4. Reproducible teaching fit

```r
library(mixRSMflow)

sp <- mix_spec(
  c("A", "B", "C"),
  lower = c(0.05, 0.05, 0.05),
  upper = c(0.90, 0.90, 0.90)
)

d <- mix_demo_data(
  "mixture",
  n_rep = 3,
  seed = 29001
)

fit <- mix_fit(
  "response",
  d,
  sp,
  model = "scheffe_quadratic"
)
```

Before optimizing:

```r
mix_anova(fit)
mix_diagnose(fit)
mix_collinearity(fit)
```

### Stop conditions

Do not proceed as if the optimum were trustworthy if:

- the model is rank deficient;
- lack of fit is severe and scientifically important;
- the surface is dominated by one influential blend;
- the feasible region is nearly degenerate;
- the fitted model extrapolates far beyond experimental support.

---

# Part II. Maximum, minimum, and target goals

## 5. Maximize

```r
op_max <- mix_optimize(
  fit,
  goal = "maximize",
  method = "hybrid",
  grid_resolution = 35,
  random_candidates = 5000,
  near_tolerance = 0.01,
  seed = 29002
)

op_max
```

---

## 6. Minimize

```r
op_min <- mix_optimize(
  fit,
  goal = "minimize",
  method = "hybrid",
  seed = 29003
)
```

Minimization is relevant for:

- cost;
- toxicity;
- salinity;
- pollutant loss;
- disease severity;
- undesirable sensory attributes.

---

## 7. Target

```r
op_target <- mix_optimize(
  fit,
  goal = "target",
  target = 6,
  method = "grid",
  grid_resolution = 40
)
```

A target problem seeks a response close to a desired value rather than an extreme.

Examples include:

- target pH;
- target density;
- target release rate;
- target nutrient concentration.

---

# Part III. Search methods

## 8. Grid search

```r
op_grid <- mix_optimize(
  fit,
  "maximize",
  method = "grid",
  grid_resolution = 50
)
```

### Strengths

- deterministic on the declared grid;
- easy to visualize;
- transparent.

### Limitation

The optimum is restricted to evaluated grid points, so resolution controls numerical location precision.

---

## 9. Genetic algorithm

```r
op_ga <- mix_optimize(
  fit,
  "maximize",
  method = "ga",
  random_candidates = 5000,
  seed = 29101
)
```

Use a fixed seed and check stability if the precise solution matters.

---

## 10. Hybrid search

```r
op_hybrid <- mix_optimize(
  fit,
  "maximize",
  method = "hybrid",
  grid_resolution = 30,
  random_candidates = 5000,
  seed = 29102
)
```

A hybrid search combines deterministic coverage and stochastic/local refinement.

### Practical rule

When the surface is smooth and low-dimensional, different reasonable methods should converge to similar predicted optima. Large disagreement is a diagnostic signal that the search, model, or surface geometry deserves closer inspection.

---

# Part IV. Boundary and interior optima

## 11. Detect whether the optimum is on a constraint

Inspect the best composition and compare it with component bounds and general inequalities.

If a component equals its upper bound within tolerance, the solution is constrained by that boundary.

### Interpretation

A boundary optimum can mean:

1. the true best composition lies near that boundary;
2. the fitted surface continues improving outside the allowed region;
3. the experimental bounds may be limiting scientific discovery;
4. the boundary is a real safety/operational limit and should not be widened.

Do not recommend extrapolating beyond a scientifically required bound simply because the fitted gradient points outward.

---

## 12. Interior optimum

An interior optimum is surrounded by feasible alternatives in all independent-coordinate directions.

It is often easier to estimate its local shape than a corner optimum, but uncertainty can still be broad when the response surface is flat.

---

# Part V. Near-optimal regions

## 13. Why near-optimal solutions matter

Suppose the predicted maximum is 100. A formulation with predicted response 99 may be operationally preferable if it is cheaper, safer, easier to prepare, or more stable.

Set a relative tolerance:

```r
op_near <- mix_optimize(
  fit,
  goal = "maximize",
  method = "grid",
  grid_resolution = 50,
  near_tolerance = 0.02
)

head(op_near$near_optimal)
```

A 2% tolerance identifies formulations near the fitted optimum under the package's criterion.

### Scientific selection of tolerance

Use:

- minimum agronomically important difference;
- assay repeatability;
- economic equivalence;
- manufacturing tolerance;
- stakeholder decision threshold.

Do not choose 2% merely because it produces a convenient-sized cloud.

---

## 14. Practical optimum versus mathematical optimum

Recommended reporting language:

> The fitted mathematical optimum occurred at composition X. However, a broader set of formulations within the declared practical tolerance produced nearly equivalent predicted response. Formulation Y was selected from this near-optimal region because of its operational advantages.

This is often more scientifically honest than reporting only the exact maximum.

---

# Part VI. Parametric uncertainty of optimum location

## 15. Why perturb the coefficients?

The fitted coefficient vector `beta_hat` is uncertain. Under a Gaussian approximation,

\[
\beta^{(b)}\sim N(\hat\beta,\widehat{Var}(\hat\beta)).
\]

For each simulated coefficient vector:

1. construct the perturbed surface;
2. optimize it under the same mixture constraints;
3. store the resulting optimum composition.

The cloud of optima describes uncertainty in **location**, not only uncertainty in the response at one fixed composition.

---

## 16. Run parametric optimum uncertainty

```r
ci_p <- mix_optimum_ci(
  op_hybrid,
  method = "parametric",
  B = 1000,
  level = 0.95,
  grid_resolution = 25,
  seed = 29201
)

ci_p
```

Plot:

```r
mix_plot(
  ci_p,
  type = "optimum_ci"
)
```

---

## 17. Interpret the joint cloud

A compact cloud around the exact optimum indicates relatively stable location under the fitted covariance approximation.

A broad or multimodal cloud may indicate:

- flat surface;
- coefficient uncertainty;
- competing local maxima;
- boundary instability;
- weak design information in the optimum region.

Do not summarize a visibly multimodal cloud only by marginal intervals.

---

# Part VII. Residual bootstrap

## 18. Residual-bootstrap principle

For supported Gaussian fits, the residual bootstrap perturbs the observed response structure by resampling residual information and refitting/reoptimizing.

```r
ci_r <- mix_optimum_ci(
  op_hybrid,
  method = "residual_bootstrap",
  B = 1000,
  level = 0.95,
  grid_resolution = 25,
  seed = 29202
)
```

### Interpretation

Parametric simulation depends strongly on the estimated coefficient covariance and its approximate distribution. Residual bootstrap reflects the fitted Gaussian residual structure under its own assumptions.

If the two uncertainty clouds differ substantially, investigate why rather than averaging them.

---

# Part VIII. Marginal component intervals

## 19. Why component intervals are dependent

If

\[
A+B+C=1,
\]

then uncertainty in A cannot be interpreted independently of B and C.

`mix_optimum_ci()` can summarize marginal component quantiles, but the joint cloud remains the authoritative geometric picture.

### Bad interpretation

> A can vary independently from 0.20 to 0.50 while B and C remain at their optimal estimates.

This generally violates the mixture constraint.

### Better interpretation

> Across reoptimized surfaces, the marginal distribution of the optimal A proportion covered this interval, with joint compositions represented by the optimum cloud.

---

# Part IX. Response uncertainty versus location uncertainty

## 20. Two different uncertainties

At a fixed composition `x*`, `mix_predict()` can quantify uncertainty in the predicted mean response.

```r
mix_predict(
  fit,
  newdata = op_hybrid$best,
  interval = "confidence"
)
```

`mix_optimum_ci()` asks a different question:

> Where would the maximizing composition move if the fitted surface changed within its estimation uncertainty?

Both are scientifically useful and should not be conflated.

---

# Part X. Model-choice sensitivity

## 21. Compare quadratic and special-cubic optima

```r
fit_q <- mix_fit(
  "response", d, sp,
  model = "scheffe_quadratic"
)

fit_c <- mix_fit(
  "response", d, sp,
  model = "scheffe_special_cubic"
)

op_q <- mix_optimize(
  fit_q,
  "maximize",
  method = "hybrid",
  seed = 29301
)

op_c <- mix_optimize(
  fit_c,
  "maximize",
  method = "hybrid",
  seed = 29301
)

op_q$best
op_c$best
```

### Interpretation

If two defensible models fit similarly but yield very different optima, model uncertainty is scientifically important.

Do not present one composition as uniquely established without discussing this sensitivity.

---

# Part XI. Agronomic case: substrate formulation

## 22. Scientific setup

Substrate components:

- compost `C`;
- biochar `B`;
- mineral carrier `M`.

Response: seedling biomass.

### Step 1: region

```r
sp_sub <- mix_spec(
  c("C", "B", "M"),
  lower = c(0.20, 0.05, 0.10),
  upper = c(0.70, 0.35, 0.60)
)
```

### Step 2: design and teaching response

```r
des <- mix_design(
  sp_sub,
  "simplex_lattice",
  degree = 4
)

set.seed(29401)
dat <- des$data

dat$biomass <- with(
  dat,
  30 + 12 * C + 7 * B + 6 * M +
  8 * C * B - 4 * B * M +
  rnorm(nrow(dat), 0, 0.8)
)
```

### Step 3: fit and diagnose

```r
fit_sub <- mix_fit(
  "biomass",
  dat,
  sp_sub,
  "scheffe_quadratic"
)

mix_diagnose(fit_sub)
mix_collinearity(fit_sub)
```

### Step 4: exact optimum

```r
op_sub <- mix_optimize(
  fit_sub,
  "maximize",
  method = "hybrid",
  near_tolerance = 0.02,
  seed = 29402
)

op_sub
```

### Step 5: uncertainty cloud

```r
ci_sub <- mix_optimum_ci(
  op_sub,
  method = "parametric",
  B = 1000,
  level = 0.95,
  seed = 29403
)
```

### Step 6: inspect near-optimal formulations

```r
head(op_sub$near_optimal)
```

### Step 7: select a practical formulation

Choose from the near-optimal region using an external operational criterion such as cost or handling. If multiple responses are formally optimized together, move to Extended Vignette 28 rather than hiding an external cost rule inside this single-response analysis.

---

# Part XII. Flat surfaces and optimum uncertainty

## 23. Curvature matters

Two fitted surfaces can have the same maximum response but very different decision certainty.

**Sharp peak:** small coefficient changes may leave the optimum near the same point.

**Flat plateau:** tiny coefficient changes can move the mathematical maximum widely while predicted response remains nearly unchanged.

In the second case, the broad optimum cloud is not necessarily a failure. It can indicate that many formulations are practically equivalent.

This is why near-optimal regions and location uncertainty should be considered together.

---

# Part XIII. Common mistakes

## 24. Reporting too many decimals

Numerical optimization precision is not experimental precision.

---

## 25. Optimizing before diagnosing

Never skip model adequacy.

---

## 26. Ignoring boundaries

State which constraints are active at the optimum.

---

## 27. Calling marginal component intervals a rectangular confidence region

The joint compositions remain constrained.

---

## 28. Choosing a near-optimal tolerance without practical meaning

Tie it to biological, economic, or operational equivalence.

---

## 29. Treating one model's optimum as certain when competing models differ

Report model-choice sensitivity.

---

## 30. Confusing response interval with optimum-location interval

They answer different questions.

---

# Part XIV. Function-selection guide

| Question | Function |
|:--|:--|
| Maximum feasible response | `mix_optimize(goal="maximize")` |
| Minimum feasible response | `mix_optimize(goal="minimize")` |
| Hit a target | `mix_optimize(goal="target")` |
| Transparent deterministic search | `method="grid"` |
| Stochastic search | `method="ga"` |
| Combined search | `method="hybrid"` |
| Practical alternatives | `near_tolerance` + `$near_optimal` |
| Predicted-response interval at fixed blend | `mix_predict()` |
| Location uncertainty | `mix_optimum_ci()` |
| Focus future runs near uncertain optimum | `mix_augment(objective="optimum_uncertainty")` in Vignette 30 |
| Multiple conflicting responses | Extended Vignette 28 |

---

# Part XV. Reporting checklist

- [ ] fitted model and diagnostics;
- [ ] mixture region and active constraints;
- [ ] optimization goal;
- [ ] target value if applicable;
- [ ] search method;
- [ ] grid resolution;
- [ ] stochastic candidate count;
- [ ] seed;
- [ ] exact optimum composition;
- [ ] predicted response at optimum;
- [ ] response confidence/prediction interval where relevant;
- [ ] active boundary constraints;
- [ ] near-optimal tolerance;
- [ ] number/range of near-optimal candidates;
- [ ] optimum-uncertainty method;
- [ ] bootstrap/simulation count `B`;
- [ ] optimum cloud;
- [ ] marginal component intervals;
- [ ] sensitivity to model family;
- [ ] practical formulation selected and why.

---

# Appendix A. Compact uncertainty-aware optimization script

```r
library(mixRSMflow)

sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 3, seed = 20260813)

fit <- mix_fit(
  "response", d, sp,
  model = "scheffe_quadratic"
)

mix_diagnose(fit)

op <- mix_optimize(
  fit,
  goal = "maximize",
  method = "hybrid",
  near_tolerance = 0.02,
  seed = 20260813
)

print(op)
head(op$near_optimal)

ci <- mix_optimum_ci(
  op,
  method = "parametric",
  B = 1000,
  level = 0.95,
  seed = 20260814
)

print(ci)
mix_plot(op, "optimum")
mix_plot(ci, "optimum_ci")
```

---

# Appendix B. Boundary with other extended vignettes

This vignette owns the uncertainty-aware **single-response** optimum. Multiple-response trade-offs are in 28. Design-focused sequential augmentation and Bayesian optimization are in 30. Optimal-design criteria are in 25. Full graphics engineering is in 32.

---

# Final perspective

The useful question is not only:

> Where is the fitted maximum?

It is:

**Which feasible formulations are credibly competitive, how much can the maximizing composition move under model uncertainty, and is an exact mathematical maximum more useful than a stable near-optimal region?**


---

# Appendix C. Advanced optimum-uncertainty laboratories

## C1. Laboratory: sharp peak versus flat plateau

Create two synthetic response surfaces with similar maximum values but different curvature. Fit both and compare `mix_optimum_ci()` clouds.

### Expected lesson

The flatter surface should produce a wider location cloud even if the standard error of the maximum response itself is modest. Location uncertainty and response uncertainty are not the same quantity.

---

## C2. Laboratory: active-boundary frequency

Use a constrained region and parametric optimum simulation. For each simulated optimum, record whether A is at its upper bound, B is at its lower bound, or a combined constraint is active.

Summarize the percentage of bootstrap/simulation optima on each boundary.

### Interpretation

If most simulated optima lie on the same boundary, the recommendation is strongly conditional on that constraint. If the active boundary changes frequently, location uncertainty is structurally important.

---

## C3. Laboratory: model-choice uncertainty

Fit linear, quadratic, and special-cubic candidates when supported. For each defensible model:

1. optimize;
2. compute near-optimal region;
3. compute parametric location uncertainty;
4. compare overlap of the optimum clouds.

A narrow within-model cloud does not guarantee robustness if different plausible models place the optimum in different regions.

---

## C4. Laboratory: choose a practical formulation

From a 2% near-optimal region, add an external cost column that is **not** part of the fitted response model. Select the lowest-cost formulation within the near-optimal set.

Write a recommendation that distinguishes:

- statistical response optimum;
- practical cost-based choice.

If cost is to be formally optimized jointly rather than used as a secondary rule, move to Extended Vignette 28.

---

# Appendix D. Optimum troubleshooting matrix

| Symptom | Likely cause | Response |
|:--|:--|:--|
| grid and hybrid optima differ strongly | coarse grid or multimodal surface | increase resolution/check surface |
| optimum always at bound | outward response gradient or tight constraints | report active bound; do not extrapolate automatically |
| bootstrap cloud extremely broad | flat surface/weak design/model instability | inspect curvature, design, conditioning |
| bootstrap produces several clusters | competing local maxima | report multimodality, not only marginal intervals |
| component CIs appear incompatible | marginal summaries ignore dependence | inspect joint cloud |
| residual bootstrap fails | unsupported/non-Gaussian model | use supported parametric route or appropriate method |
| exact optimum changes by model | model uncertainty | report sensitivity or collect additional data |
| near-optimal set huge | flat response or large tolerance | define practical tolerance scientifically |

---

# Appendix E. Guided optimum exercises

### Exercise 1. Search convergence

Compare grid resolutions 20, 40, and 80. Record the best response and composition. Determine when the result stabilizes.

### Exercise 2. Seed stability

Repeat GA/hybrid optimization across ten seeds. Compare response regret relative to the best observed solution.

### Exercise 3. Boundary classification

Write code that flags which constraints are active at the optimum within `1e-6` tolerance.

### Exercise 4. Practical tolerance

Define near-optimal regions using 0.5%, 1%, 2%, and 5% response tolerance. Discuss which one corresponds to experimental repeatability.

### Exercise 5. Parametric versus residual bootstrap

Compare cloud spread and centroid under both methods for a Gaussian teaching fit.

### Exercise 6. Component dependence

Take two optimum-cloud points with similar A but different B and C. Explain why the marginal A interval does not determine a unique formulation.

### Exercise 7. Flat plateau

Simulate a surface with a broad plateau. Explain why reporting six decimals for the maximizing composition is misleading.

### Exercise 8. Model sensitivity

Compare quadratic and special-cubic optimum clouds and decide whether one formulation can be called robust.

### Exercise 9. Response versus location interval

At the exact optimum, compute a confidence interval for the predicted mean. Explain why it cannot substitute for `mix_optimum_ci()`.

### Exercise 10. Active constraint

Artificially relax one upper bound and reoptimize. Explain whether the original bound was scientifically binding.

### Exercise 11. Decision statement

Write a two-sentence recommendation that gives exact optimum, 95% location uncertainty, and a practical alternative.

### Exercise 12. Reviewer exercise

A manuscript reports only “optimal A = 0.431, B = 0.274, C = 0.295.” List the minimum uncertainty and model information a reviewer should request.

---

# Appendix F. Reviewer-style optimum audit

Check that a paper states:

1. feasible region;
2. fitted model;
3. diagnostics before optimization;
4. objective (maximize/minimize/target);
5. search method and seed;
6. exact optimum;
7. active constraints;
8. predicted response and uncertainty;
9. near-optimal tolerance;
10. optimum-location uncertainty method;
11. `B` and seed;
12. joint cloud/region;
13. model-choice sensitivity;
14. practical final recommendation.

---

# Appendix G. Interpretation language templates

### Interior stable optimum

> The fitted maximum occurred in the interior of the feasible region, and repeated coefficient simulation produced a compact joint optimum cloud around the same composition, indicating relatively stable optimum location under the fitted model.

### Boundary optimum

> The fitted maximum occurred on the declared upper bound for component A. The recommendation is therefore conditional on that formulation constraint and does not imply that extrapolation beyond the bound would be safe or scientifically valid.

### Flat near-optimal region

> Although one exact maximizing composition was identified numerically, a broad near-optimal region produced responses within 2% of the fitted maximum. The practical recommendation was selected from this region rather than from the exact mathematical optimum alone.

### Model-sensitive optimum

> The optimum location differed materially between two defensible model forms despite similar global fit metrics. Accordingly, the formulation recommendation is presented as model-sensitive and motivates additional experimentation near the competing optimum regions.


---

# Appendix H. Applied optimum case bank

## H1. Flat fertilizer plateau

A nutrient blend has a broad plateau around maximum yield. Numerical optimization returns one composition, but a 2% near-optimal region spans a large part of the interior. In practice, the least expensive or easiest-to-manufacture formulation inside that plateau may be preferable. The broad optimum cloud is scientifically consistent with a flat response and should not be interpreted only as imprecision.

## H2. Regulatory boundary optimum

A pesticide active fraction is capped at 0.40 and the fitted response increases toward that cap. The optimum repeatedly occurs at A = 0.40. The scientific conclusion is that the best admissible formulation under the current model lies on the regulatory boundary—not that increasing A above 0.40 would be acceptable or necessarily effective.

## H3. Competing model optima

Quadratic and special-cubic models both pass global diagnostics but place the optimum in different regions. Within-model bootstrap clouds are narrow. This reveals model uncertainty that a single bootstrap cannot capture. Additional runs should target the regions where models disagree, connecting naturally to Extended Vignette 30.

## H4. Target formulation rather than maximum

A nutrient solution must achieve a target EC rather than maximize it. `goal="target"` is more scientifically appropriate than treating deviation in one direction as always beneficial. The recommended composition should include uncertainty in predicted EC and sensitivity to the target tolerance.

## H5. Practical substitution inside near-optimal region

A component becomes temporarily unavailable. Rather than refitting the whole experiment, search the existing near-optimal set for blends with lower use of that component. This demonstrates the practical value of retaining a cloud of good alternatives instead of archiving only one optimum row.

---

# Appendix I. Short-answer optimum review

1. **What is a mathematical optimum?** The best point on the fitted surface under the search and constraints.
2. **What is a practical optimum?** A decision-selected point that may sacrifice negligible response for other benefits.
3. **Why can an optimum be on a boundary?** The fitted gradient may point outside the admissible region.
4. **What does `near_tolerance` represent?** A practical response-loss threshold around the fitted optimum.
5. **What does `mix_optimum_ci()` perturb?** The fitted surface and then reoptimizes under the same constraints.
6. **Why is the joint cloud important?** Component coordinates are dependent.
7. **Why can a flat surface give a broad cloud?** Many nearby compositions have nearly identical response.
8. **Is a response CI at the optimum a location CI?** No.
9. **Why compare model optima?** To assess model-choice sensitivity.
10. **What should be reported for a boundary optimum?** Active constraints and conditional interpretation.


---

# Appendix J. Deeper conceptual notes on optimum inference

## J1. A maximum is a derived estimand

The optimum is not a directly estimated regression coefficient. It is a nonlinear function of all fitted coefficients and of the feasible region. Small coefficient changes can produce large location changes when curvature is weak. This is why standard errors of individual coefficients do not provide a simple substitute for optimum-location uncertainty.

## J2. Constraints are part of the estimand

The constrained optimum answers: “Which composition is best **among the allowed formulations**?” Changing a bound changes the estimand. Therefore an optimum should always be reported with the region definition. If a later regulation changes the admissible composition, the old optimum is not directly transferable even if the response model coefficients remain the same.

## J3. Flatness versus uncertainty

A broad near-optimal region can arise because the fitted response itself is flat. A broad bootstrap optimum cloud can arise because the estimated surface is uncertain. These mechanisms can coexist. The first concerns practical equivalence on the fitted surface; the second concerns uncertainty about which surface is correct. Plotting both helps distinguish them.

## J4. Multimodal location distributions

If repeated reoptimization produces several clusters, marginal quantile intervals can be misleading. For example, the median of A, B, and C may describe a composition that is rarely an optimum in any simulation. Preserve the joint cloud and, when useful, identify modes or regions rather than forcing a single elliptical summary.

## J5. Confirmatory experimentation

When the optimum is scientifically important, the analysis can motivate a follow-up experiment centered on the uncertain optimum region. Extended Vignette 30 describes augmentation. This staged workflow can be more credible than accepting a highly uncertain optimum from the first experiment.
