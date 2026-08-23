# mixRSMflow: Optimal Mixture Design, Prediction Variance, and Design Quality

**Extended instructional vignette**  
**Package:** `mixRSMflow`  
**Version targeted:** `0.1.0.9000`  
**Extended vignette:** 25  
**Format:** Markdown source only  
**Primary ownership:** optimal-design criteria, exchange/GA/hybrid search, prediction variance, FDS, VDG, IMSE, rotatability, model-robust design, Bayesian design criteria, sequential design augmentation for information quality  
**Companion material:** Extended Vignette 24 for mixture geometry; `09-optimal-design.Rmd`, `17-sequential-design.Rmd`

> This document is intentionally supplied as `.md`. It is an extended teaching monograph. Stochastic examples use explicit seeds. Final numerical performance must be confirmed in the user's local R environment.

> **Scope boundary.** This extended vignette owns the topic named in its title. Closely related methods that belong to another extended vignette are referenced rather than re-taught. This separation is deliberate so that the extended documentation remains deep without becoming repetitive.

---

## 1. Why optimal design is a scientific choice, not an algorithm contest

A constrained mixture region can be irregular, narrow, or strongly asymmetric. Classical simplex designs were developed for highly structured regions and model families. When the feasible region departs from the full simplex, a named classical design can become inefficient, unbalanced, or impossible.

Optimal design reverses the problem. Rather than beginning with a named geometric design and asking which model it can support, the researcher declares:

1. the feasible region;
2. the model basis;
3. the number of runs;
4. the scientific criterion;
5. the candidate or evaluation region;
6. the search algorithm.

The algorithm then searches for a design that scores well under that criterion.

The central principle of this vignette is:

**The optimality criterion should follow the scientific estimand. D-optimality is not a universal default.**

---

## 2. Learning objectives

After this vignette, the reader should be able to:

1. construct and inspect the model matrix of a candidate mixture design;
2. distinguish exact run selection from the continuous theoretical idea of optimal design;
3. explain D-, A-, I-, G-, E-, T-, Alias-, Bayesian D-, and Bayesian I-oriented criteria;
4. select a criterion according to parameter, prediction, discrimination, aliasing, or prior-information goals;
5. generate exchange, genetic-algorithm, and hybrid optimal designs;
6. use repeated random starts and explicit seeds;
7. evaluate rank, conditioning, leverage, average prediction variance, and maximum prediction variance;
8. interpret Fraction of Design Space curves;
9. interpret Variance Dispersion Graphs;
10. assess rotatability in mixture-independent coordinates;
11. use IMSE to study variance/bias trade-offs when the fitted model may be simpler than the true surface;
12. construct T- or Alias-oriented designs with explicit alternative model spaces;
13. incorporate prior precision through Bayesian criteria;
14. use mean or worst-case objectives for model-robust design scenarios;
15. augment an existing design to improve D, I, or G behavior;
16. distinguish design-based sequential augmentation from response-adaptive optimization;
17. report stochastic search settings and design diagnostics reproducibly.

---

## 3. Function map

| Task | Primary function |
|:--|:--|
| Standard design baseline | `mix_design()` |
| Optimal design search | `mix_optimal_design()` |
| Design diagnostics | `mix_design_eval()` |
| Integrated MSE | `mix_imse()` |
| Rotatability | `mix_rotatability()` |
| Simplex/region moments | `mix_moments()` |
| Add informative runs | `mix_augment()` |
| Inspect candidate model columns | `mix_basis()` |
| Plot design quality | `mix_plot()` |
| Record decisions | `mix_audit_trail()` |

This vignette assumes the region already exists as a validated `mix_spec`. Bounds and extreme-vertex theory are owned by Extended Vignette 24.

---

# Part I. Information matrices and prediction variance

## 4. Start from a constrained agronomic formulation

```r
library(mixRSMflow)

sp <- mix_spec(
  components = c("OrganicN", "MineralN", "Carrier"),
  lower = c(0.05, 0.05, 0.10),
  upper = c(0.75, 0.75, 0.80),
  A = matrix(c(1, 1, 0), nrow = 1),
  b = 0.85,
  dir = "<="
)

mix_vertices(sp)
```

Suppose the scientific objective is to support a Scheffé quadratic response surface.

```r
candidate_reference <- mix_design(
  sp,
  type = "extreme_vertices",
  include_centroid = TRUE,
  edge_midpoints = TRUE
)
```

The design problem is now explicit: choose a finite set of runs from the feasible region that estimates or predicts the quadratic surface efficiently.

---

## 5. Model matrix

For a quadratic three-component Scheffé model,

\[
f(x)=
\begin{bmatrix}
x_1 & x_2 & x_3 & x_1x_2 & x_1x_3 & x_2x_3
\end{bmatrix}^{T}.
\]

For design points `x_1, ..., x_n`, the rows of the model matrix are `f(x_i)^T`.

```r
X <- mix_basis(
  candidate_reference$data,
  sp,
  model = "scheffe_quadratic"
)

dim(X)
head(X)
```

For ordinary equal-variance linear-model calculations, the information matrix is proportional to

\[
M=X^TX.
\]

The covariance of estimated coefficients is proportional to `M^-1` when the matrix is full rank.

---

## 6. Prediction variance

For a candidate mixture `x`, model-based prediction variance is proportional to

\[
v(x)=f(x)^T(X^TX)^{-1}f(x).
\]

Different optimality criteria summarize different aspects of this matrix or of `v(x)`.

This is why a design can be excellent for coefficient precision and less attractive for prediction, or vice versa.

---

# Part II. Optimality criteria

## 7. D-optimality

D-optimality seeks to maximize the determinant of the information matrix, equivalently minimizing the generalized volume of the coefficient covariance ellipsoid.

```r
d_D <- mix_optimal_design(
  spec = sp,
  model = "scheffe_quadratic",
  runs = 10,
  criterion = "D",
  algorithm = "hybrid",
  seed = 25001
)
```

### Appropriate scientific emphasis

Use D-oriented design when the primary concern is precise estimation of the complete parameter vector under the declared model.

### Limitation

D-optimality does not directly minimize average or worst-case prediction variance over the feasible region.

---

## 8. A-optimality

A-optimality focuses on the trace of the inverse information matrix.

```r
d_A <- mix_optimal_design(
  sp,
  "scheffe_quadratic",
  runs = 10,
  criterion = "A",
  algorithm = "hybrid",
  seed = 25002
)
```

It emphasizes average marginal coefficient variance on the scale of the selected parameterization.

Because parameterization matters, interpret A-optimality with more caution when comparing bases with very different scaling.

---

## 9. I-optimality

I-optimality minimizes integrated or average prediction variance over an evaluation region.

```r
d_I <- mix_optimal_design(
  sp,
  "scheffe_quadratic",
  runs = 10,
  criterion = "I",
  algorithm = "hybrid",
  resolution = 15,
  random_candidates = 2000,
  seed = 25003
)
```

### Appropriate scientific emphasis

Use I-optimality when the response surface will be used to predict across the feasible region or when optimization depends on a well-estimated surface throughout that region.

This is often a strong default for formulation optimization, but it is still a goal-dependent choice rather than a universal rule.

---

## 10. G-optimality

G-optimality targets the maximum prediction variance.

```r
d_G <- mix_optimal_design(
  sp,
  "scheffe_quadratic",
  runs = 10,
  criterion = "G",
  algorithm = "hybrid",
  seed = 25004
)
```

This is attractive when poor prediction anywhere in the feasible region is unacceptable.

Examples include safety envelopes, formulation specifications, and experiments intended to guarantee uniformly controlled uncertainty.

---

## 11. E-optimality

E-optimality emphasizes the smallest eigenvalue of the information matrix.

```r
d_E <- mix_optimal_design(
  sp,
  "scheffe_quadratic",
  runs = 10,
  criterion = "E",
  algorithm = "hybrid",
  seed = 25005
)
```

It protects the weakest estimable direction in parameter space.

This can be useful when near-singularity is a concern.

---

## 12. T-optimality for model discrimination

Suppose the current candidate model is quadratic but an important alternative is special cubic.

```r
d_T <- mix_optimal_design(
  sp,
  model = "scheffe_quadratic",
  runs = 12,
  criterion = "T",
  alternative_model = "scheffe_special_cubic",
  algorithm = "hybrid",
  seed = 25006
)
```

T-oriented design is a different scientific problem from ordinary coefficient precision. The purpose is to create runs where competing model spaces produce distinguishable predictions.

### Reporting rule

State both the null/base model and the alternative model. A phrase such as "T-optimal design" is incomplete without the discrimination target.

---

## 13. Alias-oriented design

If the fitted model is quadratic but higher-order terms may exist, an alias criterion can seek a design with less confounding between the fitted and omitted term spaces.

```r
d_alias <- mix_optimal_design(
  sp,
  model = "scheffe_quadratic",
  runs = 12,
  criterion = "Alias",
  alias_model = "scheffe_special_cubic",
  algorithm = "hybrid",
  seed = 25007
)
```

This can be useful for screening-like settings where effect sparsity is plausible but complete higher-order fitting is unaffordable.

---

## 14. Bayesian D and Bayesian I criteria

Prior parameter information can be incorporated through a prior precision matrix.

For a three-component quadratic Scheffé basis there are six columns.

```r
P <- diag(0.10, 6)

d_BD <- mix_optimal_design(
  sp,
  "scheffe_quadratic",
  runs = 10,
  criterion = "BayesD",
  prior_precision = P,
  seed = 25008
)

d_BI <- mix_optimal_design(
  sp,
  "scheffe_quadratic",
  runs = 10,
  criterion = "BayesI",
  prior_precision = P,
  seed = 25009
)
```

### Interpretation

The prior precision modifies the design criterion. This does not automatically make the subsequent response analysis Bayesian.

Document the origin and scale of prior information. A diagonal matrix chosen solely for numerical convenience is not substantive prior knowledge.

---

# Part III. Search algorithms

## 15. Exchange search

```r
d_ex <- mix_optimal_design(
  sp,
  "scheffe_quadratic",
  runs = 10,
  criterion = "I",
  algorithm = "exchange",
  starts = 5,
  max_iter = 50,
  seed = 25101
)
```

Exchange search iteratively replaces design points with candidates that improve the criterion.

### Strengths

- transparent design-point replacement logic;
- strong local refinement;
- often fast on moderate candidate sets.

### Risk

It can depend on the starting design when the criterion landscape is irregular.

---

## 16. Genetic algorithm

```r
d_ga <- mix_optimal_design(
  sp,
  "scheffe_quadratic",
  runs = 10,
  criterion = "I",
  algorithm = "ga",
  population = 60,
  generations = 80,
  seed = 25102
)
```

### Strengths

- broader stochastic exploration;
- useful in irregular regions;
- less dependent on a single local exchange path.

### Reporting requirements

State:

- seed;
- population size;
- generation count;
- candidate-set construction;
- criterion;
- number of selected runs;
- whether replicate selections were allowed.

---

## 17. Hybrid GA plus exchange

```r
d_hybrid <- mix_optimal_design(
  sp,
  "scheffe_quadratic",
  runs = 10,
  criterion = "I",
  algorithm = "hybrid",
  starts = 5,
  max_iter = 40,
  population = 60,
  generations = 80,
  seed = 25103
)
```

The hybrid workflow combines broad stochastic search with local exchange refinement.

It is a useful practical default when computation is affordable, but the result should still be compared across seeds or starts when design decisions are consequential.

---

## 18. Replicates in an optimal design

The argument

```r
allow_replicates = TRUE
```

permits a candidate point to appear more than once.

Replicates can be scientifically valuable because they estimate pure error and can improve precision where the criterion favors repeated support.

Do not automatically force all design points to be unique. Conversely, do not accept heavy replication if it leaves important parts of the region poorly supported for prediction.

---

# Part IV. Design evaluation

## 19. Evaluate all candidate designs on a common region

```r
ev_D <- mix_design_eval(
  d_D,
  model = "scheffe_quadratic",
  resolution = 20
)

ev_I <- mix_design_eval(
  d_I,
  model = "scheffe_quadratic",
  resolution = 20
)

ev_G <- mix_design_eval(
  d_G,
  model = "scheffe_quadratic",
  resolution = 20
)
```

Use the same model, evaluation resolution, and feasible region for a fair comparison.

---

## 20. Rank and estimability

A design that does not have full rank for the intended model is not adequate for ordinary coefficient estimation.

Inspect the evaluation object before comparing efficiency scores.

A criterion value from a rank-deficient design should not be interpreted as meaningful parameter precision.

---

## 21. Conditioning

Condition number measures sensitivity of the linear system to perturbation and scaling.

In a strongly constrained region, a quadratic model can be technically estimable but poorly conditioned.

A large condition number suggests that:

- some coefficient combinations are weakly determined;
- small numerical or data perturbations may produce large coefficient changes;
- high-order interpretation may be unstable.

Prediction can still be more stable than individual coefficients, so conditioning should be interpreted jointly with prediction-variance diagnostics.

---

## 22. Leverage and coverage

Leverage identifies design points with high influence on the fitted model matrix.

High leverage is not automatically bad. Extreme vertices often have high leverage because they define the boundaries of the model space.

Concern arises when:

- one point dominates a high-order term;
- the design lacks interior support;
- one accidental or hard-to-reproduce formulation becomes structurally indispensable.

---

## 23. Prediction-variance maps

```r
mix_plot(
  ev_I,
  type = "prediction_variance"
)
```

A prediction-variance map shows where the design is weak or strong.

Interpret the map relative to the actual feasible region. High variance in an impossible composition is irrelevant; high variance near the scientific target region is important.

---

# Part V. Fraction of Design Space

## 24. What FDS means

For each evaluation point, compute prediction variance. The FDS curve summarizes the proportion of the feasible region with variance below a threshold.

```r
mix_plot(ev_D, type = "fds")
mix_plot(ev_I, type = "fds")
mix_plot(ev_G, type = "fds")
```

### Interpretation

A curve that lies farther toward low variance is generally preferable for prediction.

FDS is especially useful because it shows the **distribution** of prediction quality, not only one average or maximum number.

### Practical comparison questions

- Does one design improve most of the region but sacrifice a small corner?
- Does G-optimality reduce the worst-case tail at the cost of average variance?
- Does the D-optimal design have a long high-variance tail?
- Are differences meaningful relative to experimental noise and cost?

---

# Part VI. Variance Dispersion Graphs

## 25. VDG concept

VDG summarizes how prediction variance changes with radial distance from a center in the independent-coordinate representation.

```r
mix_plot(
  ev_I,
  type = "vdg"
)
```

This is particularly useful for assessing whether the design behaves similarly in different directions at similar distances from the center.

### Boundary with rotatability

VDG is a prediction-variance summary. Rotatability asks whether prediction variance depends only on radial distance rather than direction under the declared coordinate system.

---

# Part VII. Rotatability

## 26. Construct and assess a rotatable design

```r
sp_full <- mix_spec(c("A", "B", "C"))

rot <- mix_design(
  sp_full,
  type = "rotatable"
)

rot_diag <- mix_rotatability(
  rot,
  spec = sp_full,
  model = "scheffe_quadratic",
  bins = 6,
  resolution = 20
)

rot_diag
```

Rotatability is assessed in the independent-coordinate system rather than pretending the original proportions are ordinary independent axes.

### Scientific meaning

Rotatability is valuable when uncertainty should depend primarily on distance from the center of interest and not on direction.

It is not necessarily the overriding objective in a highly constrained region where the feasible geometry itself is directional.

---

# Part VIII. Simplex moments

## 27. Exact moments for a full simplex

```r
mix_moments(
  sp_full,
  powers = c(2, 0, 0),
  method = "exact"
)

mix_moments(
  sp_full,
  powers = c(1, 1, 0),
  method = "exact"
)
```

Moments are building blocks for integrated design criteria.

---

## 28. Monte Carlo moments for constrained regions

```r
mix_moments(
  sp,
  powers = c(1, 1, 0),
  method = "monte_carlo",
  n = 200000,
  seed = 25201
)
```

When numerical integration is stochastic, report `n` and `seed` and check Monte Carlo stability if the result affects a final design decision.

---

# Part IX. Integrated mean-square error

## 29. Why IMSE is different from ordinary I-optimality

Suppose the fitted model will be quadratic, but the true response might contain special-cubic terms. Prediction error has two conceptual sources:

- variance because coefficients are estimated from finite data;
- bias because the fitted model omits true structure.

```r
imse_D <- mix_imse(
  design = d_D,
  spec = sp,
  fitted_model = "scheffe_quadratic",
  true_model = "scheffe_special_cubic",
  resolution = 18
)

imse_I <- mix_imse(
  design = d_I,
  spec = sp,
  fitted_model = "scheffe_quadratic",
  true_model = "scheffe_special_cubic",
  resolution = 18
)
```

Compare the decomposition rather than only one total value.

### Interpretation

The assumed higher-order coefficients or covariance represent a sensitivity scenario. They are not knowledge of the true response surface.

---

# Part X. Model-robust design

## 30. Mean and worst-case objectives

`mix_optimal_design()` supports `robust = "mean"` and `robust = "worst"` when the design criterion is evaluated across declared model scenarios.

The idea is to avoid a design that performs extremely well for one candidate model and poorly for another plausible model.

### Workflow principle

1. define scientifically plausible candidate models before outcome inspection when possible;
2. use a mean criterion if balanced average performance is appropriate;
3. use a worst-case criterion if catastrophic weakness under any candidate model is unacceptable;
4. evaluate the selected design under each model separately afterward.

---

# Part XI. Bayesian design criteria

## 31. Prior precision as information

If the prior parameter covariance is `Sigma0`, prior precision is

\[
P_0=\Sigma_0^{-1}.
\]

Bayesian design criteria combine `P0` with experimental information.

### Practical sources of prior information

- previous experiment with the same formulation system;
- validated historical production data;
- mechanistic constraints;
- elicited plausible coefficient scale.

### Poor source

- arbitrary diagonal precision chosen only to stabilize a nearly singular design.

If stabilization is the only goal, say so explicitly and treat the result as a regularized design sensitivity analysis.

---

# Part XII. Sequential augmentation for design quality

## 32. Start from a classical design

```r
d0 <- mix_design(
  sp,
  type = "extreme_vertices",
  include_centroid = TRUE
)
```

### D-oriented augmentation

```r
d0_D <- mix_augment(
  d0,
  n_new = 3,
  model = "scheffe_quadratic",
  objective = "D",
  resolution = 18,
  seed = 25301
)
```

### I-oriented augmentation

```r
d0_I <- mix_augment(
  d0,
  n_new = 3,
  model = "scheffe_quadratic",
  objective = "I",
  resolution = 18,
  seed = 25302
)
```

### G-oriented augmentation

```r
d0_G <- mix_augment(
  d0,
  n_new = 3,
  model = "scheffe_quadratic",
  objective = "G",
  resolution = 18,
  seed = 25303
)
```

Compare:

```r
mix_design_eval(d0, model = "scheffe_quadratic")
mix_design_eval(d0_D, model = "scheffe_quadratic")
mix_design_eval(d0_I, model = "scheffe_quadratic")
mix_design_eval(d0_G, model = "scheffe_quadratic")
```

### Boundary with Extended Vignette 30

This section treats **outcome-independent design augmentation**. Response-adaptive sequential design and Gaussian-process Bayesian optimization are owned by Extended Vignette 30.

---

# Part XIII. A complete fertilizer-blend design comparison

## 33. Scientific objective

Three formulation fractions will be studied:

- organic N source `O`;
- mineral N source `N`;
- inert/nutrient carrier `C`.

The response is expected to be nonlinear and the final model will be used to optimize crop response. Therefore prediction quality is central.

### Step 1: region

```r
sp_f <- mix_spec(
  c("O", "N", "C"),
  lower = c(0.10, 0.10, 0.10),
  upper = c(0.70, 0.70, 0.70)
)
```

### Step 2: baseline classical design

```r
base <- mix_design(
  sp_f,
  type = "extreme_vertices",
  include_centroid = TRUE,
  edge_midpoints = TRUE
)
```

### Step 3: competing optimal designs

```r
Ddes <- mix_optimal_design(
  sp_f,
  "scheffe_quadratic",
  runs = 12,
  criterion = "D",
  algorithm = "hybrid",
  seed = 25401
)

Ides <- mix_optimal_design(
  sp_f,
  "scheffe_quadratic",
  runs = 12,
  criterion = "I",
  algorithm = "hybrid",
  seed = 25401
)

Gdes <- mix_optimal_design(
  sp_f,
  "scheffe_quadratic",
  runs = 12,
  criterion = "G",
  algorithm = "hybrid",
  seed = 25401
)
```

### Step 4: common evaluation

```r
E0 <- mix_design_eval(base, model = "scheffe_quadratic", resolution = 25)
ED <- mix_design_eval(Ddes, model = "scheffe_quadratic", resolution = 25)
EI <- mix_design_eval(Ides, model = "scheffe_quadratic", resolution = 25)
EG <- mix_design_eval(Gdes, model = "scheffe_quadratic", resolution = 25)
```

### Step 5: inspect FDS

```r
mix_plot(ED, "fds")
mix_plot(EI, "fds")
mix_plot(EG, "fds")
```

### Step 6: inspect prediction-variance maps

```r
mix_plot(ED, "prediction_variance")
mix_plot(EI, "prediction_variance")
mix_plot(EG, "prediction_variance")
```

### Step 7: check conditioning

Compare the reported condition measures. If one design is prediction-efficient but nearly singular, evaluate whether the numerical weakness matters for the intended interpretation.

### Step 8: decide scientifically

If the primary scientific goal is reliable surface prediction for later optimization, select the design whose prediction-variance behavior best supports that goal, subject to estimability, practical run constraints, and replicate needs.

Do not select D by convention if I or G better represents the study objective.

---

# Part XIV. Stochastic-search reproducibility

## 34. Repeat across seeds

A consequential GA or hybrid design can be checked across seeds.

```r
seeds <- c(11, 22, 33, 44, 55)

designs <- lapply(
  seeds,
  function(s) {
    mix_optimal_design(
      sp_f,
      "scheffe_quadratic",
      runs = 12,
      criterion = "I",
      algorithm = "hybrid",
      seed = s
    )
  }
)
```

Evaluate each design under the same criterion and region.

A stable search should return similar objective quality even if the exact support points differ slightly.

---

# Part XV. Common mistakes

## 35. Using D-optimality because it is the most familiar

Choose the criterion from the scientific goal.

---

## 36. Comparing designs on different evaluation regions

Use the same feasible region and model basis.

---

## 37. Ignoring rank before efficiency

A rank-deficient design cannot support ordinary estimation of the full intended model.

---

## 38. Reporting only the scalar optimality score

Also report prediction variance, FDS/VDG where relevant, conditioning, leverage, and the design points themselves.

---

## 39. Allowing a stochastic search without a seed

Record the seed and search settings.

---

## 40. Assuming the best numerical design is operationally feasible

Check run order, material-change cost, replication, whole-plot restrictions, and preparation feasibility. Structured experimental constraints are treated in Extended Vignette 27.

---

## 41. Using model-robust terminology without listing the candidate models

A robustness claim must state the uncertainty set.

---

## 42. Treating a Bayesian design criterion as a Bayesian response analysis

They are different layers.

---

# Part XVI. Function-selection guide

| Goal | Criterion/function |
|:--|:--|
| Estimate the whole parameter vector precisely | D with `mix_optimal_design()` |
| Reduce average coefficient variance | A |
| Predict well over the region | I |
| Control worst-case prediction variance | G |
| Protect the weakest information direction | E |
| Distinguish a base and alternative model | T + `alternative_model` |
| Reduce confounding with omitted terms | Alias + `alias_model` |
| Incorporate prior coefficient precision | BayesD/BayesI + `prior_precision` |
| Inspect all designs consistently | `mix_design_eval()` |
| Inspect FDS | `mix_plot(type="fds")` |
| Inspect VDG | `mix_plot(type="vdg")` |
| Study fitted-model bias sensitivity | `mix_imse()` |
| Check rotatability | `mix_rotatability()` |
| Add new design-based runs | `mix_augment()` |
| Do response-adaptive sequential experimentation | Extended Vignette 30 |

---

# Part XVII. Minimum optimal-design reporting checklist

- [ ] mixture region and all constraints;
- [ ] intended model basis;
- [ ] number of runs;
- [ ] whether replication was allowed;
- [ ] candidate-set construction;
- [ ] evaluation-region construction;
- [ ] optimality criterion;
- [ ] alternative/alias model if T/Alias was used;
- [ ] prior precision if BayesD/BayesI was used;
- [ ] mean or worst-case robustness rule;
- [ ] search algorithm;
- [ ] starts;
- [ ] exchange iteration limit;
- [ ] GA population;
- [ ] generations;
- [ ] random seed;
- [ ] rank;
- [ ] conditioning;
- [ ] average prediction variance;
- [ ] maximum prediction variance;
- [ ] FDS summary when prediction is central;
- [ ] VDG/rotatability when relevant;
- [ ] IMSE scenario assumptions when reported;
- [ ] final run table in original component units;
- [ ] practical preparation/randomization constraints;
- [ ] audit trail.

---

# Appendix A. Minimal reusable optimal-design script

```r
library(mixRSMflow)

sp <- mix_spec(
  c("A", "B", "C"),
  lower = c(0.05, 0.05, 0.05),
  upper = c(0.80, 0.80, 0.80)
)

od <- mix_optimal_design(
  sp,
  model = "scheffe_quadratic",
  runs = 10,
  criterion = "I",
  algorithm = "hybrid",
  resolution = 15,
  random_candidates = 2000,
  starts = 5,
  max_iter = 40,
  population = 60,
  generations = 80,
  seed = 20260813
)

print(od)

E <- mix_design_eval(
  od,
  model = "scheffe_quadratic",
  resolution = 25
)

print(E)
mix_plot(E, "fds")
mix_plot(E, "vdg")
mix_plot(E, "prediction_variance")

mix_audit_trail(od)
```

---

# Appendix B. Boundary with other extended vignettes

This vignette deliberately does not re-teach:

- how to derive or declare the feasible region, owned by 24;
- alternative response-model coefficient interpretation, owned by 26;
- blocking, Latin squares, and split plots, owned by 27;
- multiresponse desirability, owned by 28;
- bootstrap uncertainty of the fitted optimum, owned by 29;
- response-adaptive Bayesian optimization, owned by 30;
- GLM/GLS/mixed/Bayesian response engines, owned by 31;
- full publication-graphics practice, owned by 32;
- release validation, owned by 33.

---

# Final perspective

Optimal design does not ask, "Which algorithm is most sophisticated?"

It asks:

**Given this feasible region, this model, this number of runs, and this scientific purpose, where should observations be collected so that the resulting information is most useful?**

A defensible workflow is:

**region -> model basis -> scientific criterion -> candidate/evaluation set -> search -> rank/conditioning -> prediction-variance diagnostics -> practical feasibility -> final design.**


---

# Appendix C. Advanced optimal-design laboratories

## C1. Laboratory: when D and I disagree

Create one D-optimal and one I-optimal 10-run design on the same constrained region.

```r
sp_lab <- mix_spec(
  c("A", "B", "C"),
  lower = c(0.05, 0.05, 0.05),
  upper = c(0.80, 0.80, 0.80)
)

Ddes <- mix_optimal_design(
  sp_lab, "scheffe_quadratic", runs = 10,
  criterion = "D", algorithm = "hybrid", seed = 251001
)

Ides <- mix_optimal_design(
  sp_lab, "scheffe_quadratic", runs = 10,
  criterion = "I", algorithm = "hybrid", seed = 251001
)

ED <- mix_design_eval(Ddes, resolution = 25)
EI <- mix_design_eval(Ides, resolution = 25)
```

### Tasks

- Compare rank and condition numbers.
- Compare average and maximum prediction variance.
- Plot both FDS curves.
- Identify which design is preferable if the study aims to estimate coefficients.
- Identify which is preferable if the study aims to optimize the surface by prediction.

### Lesson

The same scientific region can have different “optimal” designs because optimality is conditional on the criterion.

---

## C2. Laboratory: algorithm stability across seeds

```r
seeds <- 101:110

res <- lapply(
  seeds,
  function(s) {
    mix_optimal_design(
      sp_lab,
      "scheffe_quadratic",
      runs = 10,
      criterion = "I",
      algorithm = "ga",
      population = 50,
      generations = 60,
      seed = s
    )
  }
)
```

For every design, compute `mix_design_eval()` and summarize the I-oriented quality metric and condition number.

### Interpretation

If objective quality varies widely by seed, increase population, generations, starts, or use hybrid refinement. If exact support points differ but objective quality remains nearly identical, the design problem may have several practically equivalent solutions.

---

## C3. Laboratory: T-optimal discrimination

Construct a design to distinguish a quadratic from special-cubic model.

```r
tdes <- mix_optimal_design(
  sp_lab,
  model = "scheffe_quadratic",
  runs = 12,
  criterion = "T",
  alternative_model = "scheffe_special_cubic",
  algorithm = "hybrid",
  seed = 252001
)
```

### Questions

- Where are the selected points concentrated?
- Why might a T-optimal design look different from a D-optimal quadratic design?
- What scientific hypothesis does the alternative model represent?
- Why is “T-optimal” incomplete without the alternative model definition?

---

## C4. Laboratory: design augmentation after run loss

Suppose two planned formulations were lost during preparation. Remove them from the design and evaluate rank and prediction variance. Then restore three runs with `mix_augment()`.

```r
Dlost <- Ides
Dlost$data <- Dlost$data[-c(2, 7), , drop = FALSE]

Elost <- mix_design_eval(Dlost)

Drepair <- mix_augment(
  Dlost,
  n_new = 3,
  objective = "I",
  model = "scheffe_quadratic",
  seed = 253001
)

Erepair <- mix_design_eval(Drepair)
```

Explain why augmentation can be preferable to recreating the original run list exactly.

---

# Appendix D. Optimal-design troubleshooting matrix

| Symptom | Likely issue | Recommended check |
|:--|:--|:--|
| objective is `Inf`/undefined | rank deficiency | inspect model matrix and candidate coverage |
| GA returns different designs each run | stochastic search | set seed and compare repeated seeds |
| hybrid does not improve GA design | local optimum already reached or iteration limit | increase starts/max_iter only if scientifically warranted |
| D design predicts poorly in interior | criterion mismatch | evaluate I/G/FDS rather than assuming D is enough |
| I design has unstable coefficients | conditioning weakness | inspect condition number/eigenvalues |
| many replicated support points | criterion favors replication | decide whether pure error and coverage remain adequate |
| T-optimal design seems strange | discrimination target drives support | inspect base and alternative basis difference |
| VDG looks anisotropic | design not rotatable or constraints directional | interpret relative to feasible geometry |
| IMSE dominated by bias | fitted model too simple under scenario | reconsider model/design relationship |
| design impossible to randomize | operational restriction absent from optimization | move to structured-design workflow in Vignette 27 |

---

# Appendix E. Guided design exercises

### Exercise 1. Criterion matching

For each objective—coefficient estimation, average prediction, worst-case prediction, model discrimination—choose a primary optimality criterion and justify it in one paragraph.

### Exercise 2. Run-count sensitivity

Generate I-optimal designs with 8, 10, 12, and 16 runs. Plot FDS curves. Identify the point at which additional runs produce diminishing prediction-variance improvement.

### Exercise 3. Replication policy

Compare `allow_replicates = TRUE` and `FALSE`. Discuss pure-error estimation, region coverage, and operational repeatability.

### Exercise 4. Candidate density

Repeat an optimal-design search with different `resolution` and `random_candidates`. Determine whether the selected support and objective quality stabilize.

### Exercise 5. Worst-case robustness

Construct two plausible model scenarios and compare `robust = "mean"` with `robust = "worst"`. Explain which strategy is more conservative.

### Exercise 6. Prior precision

Use two Bayesian prior-precision matrices: weak and informative. Explain how the selected runs change and why.

### Exercise 7. E-optimality

Create an E-optimal design and compare its smallest information eigenvalue with the D-optimal design.

### Exercise 8. Alias criterion

Specify a quadratic fitted model and a special-cubic alias model. Explain which omitted terms the design seeks to separate.

### Exercise 9. Rotatability

Compare a rotatable construction with an I-optimal design on a full simplex. Decide which is preferable for a local radial prediction goal.

### Exercise 10. IMSE scenario

Increase the assumed omitted-term magnitude in `mix_imse()`. Explain how bias begins to dominate variance.

### Exercise 11. Lost-run repair

Delete one vertex and one interior point from a design. Which lost point damages prediction more? Use `mix_design_eval()` to support the answer.

### Exercise 12. Reviewer exercise

A manuscript states “a D-optimal design was generated” with no model, candidate set, run count, or algorithm. Draft the minimum information required to reproduce the design.

---

# Appendix F. Reviewer-style optimal-design audit

A reproducible optimal-design methods section should permit a reviewer to reconstruct:

1. the feasible mixture region;
2. the intended model basis;
3. the run budget;
4. the optimality criterion;
5. the candidate set;
6. the evaluation set;
7. whether replicates were allowed;
8. the algorithm and its settings;
9. all random seeds;
10. robust model scenarios, if any;
11. prior precision, if any;
12. the selected run table;
13. rank/conditioning diagnostics;
14. prediction-variance diagnostics;
15. any operational modification after algorithmic selection.

A design described only by its criterion name is not reproducible.

---

# Appendix G. Interpretation language templates

### D-oriented design

> The design was selected to maximize information for the full coefficient vector under the declared quadratic mixture basis. Prediction-variance diagnostics were examined separately because D-optimality was not interpreted as a universal prediction criterion.

### I-oriented design

> The primary design objective was to reduce average model-based prediction variance over the feasible mixture region, consistent with the subsequent response-surface optimization goal.

### G-oriented design

> The design emphasized control of the largest prediction variance over the evaluation region, providing protection against poorly estimated subregions.

### GA/hybrid search

> Because the constrained design space was irregular, the optimal-design search used a stochastic genetic stage followed by local exchange refinement. The random seed and search settings were fixed and reported, and solution stability was checked across repeated starts.

### Model discrimination

> The T-oriented design was constructed specifically to distinguish the quadratic base model from the declared special-cubic alternative; therefore its support should not be interpreted as a general-purpose optimal design independent of the competing models.


---

# Appendix H. Applied design case bank

## H1. I-optimal formulation development

A substrate experiment will ultimately be used to predict response throughout a constrained region and then locate a high-performing blend. This goal is more closely aligned with average prediction precision than with coefficient-ellipsoid volume. An I-oriented design should therefore be a serious candidate. The final decision should still inspect rank, conditioning, FDS, and maximum prediction variance. If a D-optimal design has slightly better coefficient precision but a substantially worse prediction-variance distribution, the I design may be more consistent with the scientific purpose.

## H2. G-optimal safety envelope

A formulation must remain below a phytotoxicity threshold everywhere in the admissible region. The study needs reliable predictions even in the least-supported subregion. A G-oriented design is attractive because the worst-case prediction variance matters directly. The report should state that worst-case control, rather than average parameter precision, motivated the criterion. If the G design is operationally expensive, compare its maximum prediction variance with a simpler design before accepting the extra complexity.

## H3. T-optimal curvature discrimination

A previous experiment suggests a quadratic model, but scientists suspect a three-way blend interaction. A T-oriented design can place runs where the quadratic and special-cubic model spaces differ most. The design is not “better” in a universal sense; it is better for the declared discrimination task. After data are collected, model adequacy and scientific interpretation must still be assessed independently.

## H4. Bayesian design using historical information

A production line has historical coefficient estimates from a previous formulation version. If those estimates are scientifically transferable, they can be translated into a prior precision matrix for BayesD or BayesI design. The historical information may reduce the need to spend new runs estimating already well-known directions. Sensitivity to weaker prior precision should be reported because overconfident historical information can make the new design too narrow.

## H5. Model-robust design under uncertain curvature

A new crop formulation has little prior response information. Both quadratic and special-cubic behavior are plausible. A robust design can seek acceptable performance across both model scenarios instead of optimizing for one. A worst-case criterion is conservative; a mean criterion balances scenarios. The uncertainty set must be stated explicitly. “Robust” without listing candidate models is not reproducible.

---

# Appendix I. Short-answer optimal-design review

1. **Why is D not always best?** Because D optimizes coefficient information, not necessarily regional prediction.
2. **What does I emphasize?** Average prediction variance over the evaluation region.
3. **What does G emphasize?** Maximum prediction variance.
4. **Why inspect rank first?** Optimality scores are meaningless for an unestimable intended model.
5. **Why use FDS?** It shows the distribution of prediction precision across the region.
6. **Why repeat GA across seeds?** To assess stochastic solution stability.
7. **What makes T-optimality reproducible?** Stating both base and alternative models.
8. **What does a prior-precision matrix affect?** The design criterion, not automatically the later response-analysis paradigm.
9. **When is augmentation useful?** When existing runs should be preserved but information can be improved with additional points.
10. **What must a final design table contain?** Original component proportions, run allocation/replication, and any structured experimental assignments.
