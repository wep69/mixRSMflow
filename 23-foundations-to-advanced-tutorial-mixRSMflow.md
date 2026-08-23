# mixRSMflow: From Mixture Geometry to Advanced Design, Modeling, and Optimization Workflows

**Additional instructional vignette**  
**Package:** `mixRSMflow`  
**Version targeted:** `0.1.0.9000`  
**Format:** Markdown source only  
**Purpose:** a practical starting point for students, researchers, reviewers, and analysts who need to move from the geometry of mixtures and classical simplex designs to constrained optimal design, mixture-process modeling, multiple responses, uncertainty of the optimum, sequential experimentation, and publication-ready visualization.

> This document is intentionally supplied as `.md`. It is not a rebuilt or compiled package vignette. Inferential and optional-backend code is intended to be run locally with `mixRSMflow` and the relevant optional packages installed. The current source snapshot records static validation separately from the still-required local R runtime validation.

---

## 1. Why this tutorial exists

Mixture experiments become difficult when several decisions are introduced at the same time: the fixed-sum geometry, lower and upper component bounds, irregular feasible regions, the choice between classical and optimal designs, Scheffé versus alternative blending models, process variables, hierarchical experimental structures, collinearity, model reduction, multiple responses, optimization, uncertainty in the optimum, sequential experimentation, and static or interactive communication.

`mixRSMflow` is organized so that these decisions can be introduced in a logical order.

The central rule is:

**Define the mixture region first. Then choose a design that supports the intended model. Diagnose the fitted surface before optimizing it. Report the optimum together with uncertainty and the feasible region in which it was obtained.**

This tutorial follows that rule from an unrestricted three-component simplex to constrained regions, classical and optimal designs, Scheffé and alternative mixture models, mixture-process experiments, multiple responses, Bayesian extensions, sequential augmentation, and publication graphics.

The examples use the package's simulated teaching datasets or explicitly simulated examples. They are intended for instruction and software validation. They are **not field evidence** and should not be interpreted as agronomic, industrial, nutritional, or sensory findings.

The package also preserves an important distinction between classical mixture methodology and modern extensions. Core mixture geometry, classical designs, Scheffé modeling, diagnostics, bounded optimization, and major graphical workflows belong to the primary package layer. Optional mixed-effects, Bayesian, Gaussian-process, interactive, and Shiny backends are activated only when the corresponding packages are installed.

---

## 2. Learning objectives

After working through this tutorial, the reader should be able to:

1. explain why mixture proportions cannot be treated as independent ordinary factors;
2. define a reproducible mixture specification with total, lower bounds, upper bounds, and general linear constraints;
3. enumerate extreme vertices of a constrained feasible region;
4. transform mixture coordinates into an orthonormal set of `q - 1` independent coordinates and back;
5. generate simplex-lattice, simplex-centroid, axial, augmented-centroid, symmetric-simplex, extreme-vertices, rotatable, mixture-process, mixture-amount, and other specialized designs;
6. distinguish design generation from design evaluation;
7. fit linear, quadratic, special cubic, full cubic, special quartic, and full quartic Scheffé models;
8. fit alternative blending models when a Scheffé polynomial is not the only scientifically plausible representation;
9. separate pure error from lack of fit when replicated blends are available;
10. diagnose leverage, influence, rank, conditioning, and coefficient correlation;
11. interpret component changes through feasible paths instead of ordinary independent-factor slopes;
12. compare and reduce models without choosing only by a p-value or one information criterion;
13. construct D-, A-, I-, G-, E-, T-, Alias-, Bayesian D-, and Bayesian I-oriented designs;
14. use FDS, VDG, prediction variance, rotatability, IMSE, and conditioning to evaluate a design;
15. combine mixture proportions with process variables and preserve the distinction between mixture and process coordinates;
16. use blocking, Latin-square process layouts, fractionation, and split-plot identifiers when the experimental structure requires them;
17. fit GLS, mixed-effects, generalized-linear, and Bayesian mixture models through explicit adapters;
18. analyze several responses on a common mixture region;
19. use desirability and Pareto solutions without hiding trade-offs;
20. maximize, minimize, or target a response only inside the declared feasible region;
21. quantify uncertainty in the location of the optimum through repeated coefficient simulation or residual bootstrap;
22. distinguish the exact fitted optimum from a practically useful near-optimal region;
23. augment an existing experiment rather than automatically restarting it;
24. use Gaussian-process Bayesian optimization only when sequential experimentation is scientifically and operationally justified;
25. create ternary maps, prediction-variance displays, design diagnostics, FDS/VDG plots, vector three-dimensional surfaces, and interactive Plotly graphics;
26. generate auditable scientific reports and inspect the workflow history recorded in package objects;
27. navigate the complete exported API and the package capability registry without having to memorize every function at once.

---

## 3. The package in one map

### 3.1 Instructional stages

| Stage | Instructional focus | Main functions |
|:--|:--|:--|
| 1 | Mixture specification and geometry | `mix_spec()`, `mix_region()`, `mix_vertices()`, `mix_transform()`, `mix_inverse_transform()` |
| 2 | Pseudocomponents and reparameterization | `mix_pseudocomponents()`, `mix_reparameterize()` |
| 3 | Classical mixture designs | `mix_design()`, `mix_multiple_lattice()`, `mix_categorized_design()` |
| 4 | Structured experimental designs | `mix_block_design()`, `mix_latin_process_design()`, `mix_fractionate_process()` |
| 5 | Mixture-model basis construction | `mix_basis()`, `mix_gbm_term()` |
| 6 | Classical and generalized fitting | `mix_fit()`, `mix_fit_gls()`, `mix_fit_mixed()`, `mix_fit_bayes()` |
| 7 | Inference and diagnostics | `mix_anova()`, `mix_diagnose()`, `mix_collinearity()`, `mix_compare()` |
| 8 | Reduction, screening, and segmented surfaces | `mix_reduce()`, `mix_screen()`, `mix_segmented_fit()`, `mix_predict_segmented()` |
| 9 | Component effects and prediction | `mix_effects()`, `mix_predict()` |
| 10 | Optimal design and design quality | `mix_optimal_design()`, `mix_design_eval()`, `mix_imse()`, `mix_rotatability()` |
| 11 | Sequential augmentation | `mix_augment()` |
| 12 | Single-response optimization and uncertainty | `mix_optimize()`, `mix_optimum_ci()` |
| 13 | Multiple responses | `mix_multi_fit()`, `mix_multiopt()`, `mix_biplot()` |
| 14 | Modern sequential optimization | `mix_bo()` |
| 15 | Graphics and reporting | `mix_plot()`, `mix_report()`, `mix_audit_trail()` |
| 16 | Interactive teaching | `run_mixrsm_app()`, `mix_capabilities()` |
| 17 | Theoretical support | `mix_moments()` |

The progression is deliberate. A user should not begin with Bayesian optimization because it is modern, or with a genetic algorithm because it is flexible. The first question is always whether the mixture space, constraints, experimental objective, and intended model have been declared correctly.

### 3.2 Inspect the package programmatically

```r
library(mixRSMflow)

# Inspect every registered capability.
caps <- mix_capabilities()
head(caps)

# Restrict the registry to one area.
mix_capabilities(module = "optimal_design")
mix_capabilities(module = "optimization")
mix_capabilities(tier = "Tier 1")

# Build a small object and inspect its recorded decisions.
sp <- mix_spec(c("A", "B", "C"))
des <- mix_design(sp, "simplex_centroid")

mix_audit_trail(des)
```

**Interpretation.** `mix_capabilities()` is useful on a teaching or laboratory computer because the package distinguishes native functionality from optional backends. For example, GLS uses `nlme`, hierarchical mixture models use `lme4`, Bayesian fitting uses `brms`, Gaussian-process optimization uses `DiceKriging`, interactive graphics use `plotly`, and the graphical teaching interface uses `shiny`.

The capability registry also records a validation tier and the current runtime-certification status. This prevents an optional or experimental capability from being silently presented as equivalent to the core.

---

## 4. Teaching datasets used in this tutorial

`mixRSMflow` deliberately generates its own simulated datasets rather than redistributing textbook datasets whose reuse conditions may be uncertain.

```r
mix_demo_data("mixture")
mix_demo_data("mixture_process")
mix_demo_data("multiresponse")
```

| Dataset kind | Structure | Main concepts |
|:--|:--|:--|
| `mixture` | Three-component augmented-centroid design with replicated response | Scheffé models, pure error, lack of fit, effects, optimization |
| `mixture_process` | Three mixture components crossed with `temperature` and `time` | mixture-process interactions, process prediction, combined optimization logic |
| `multiresponse` | Common three-component design with `quality`, `cost`, and `stability` | multiple models, desirability, Pareto trade-offs, biplot |

The default simulation seed is:

```r
20260813
```

For reproducible teaching, always state the seed explicitly.

```r
d <- mix_demo_data(
  "mixture",
  n_rep = 3,
  seed = 20260813
)
```

The generated values are simulated examples. A table created from them is a descriptive summary of the simulation, not evidence about a real formulation.

---

# Part I. Foundations and the basic path

## 5. Start with the mixture region, not the response model

### 5.1 The fixed-sum constraint

For a `q`-component mixture with total `T`,

\[
x_i \ge 0,\qquad \sum_{i=1}^{q}x_i=T.
\]

For proportions, `T = 1`. For percentages, `T = 100` can be used.

The geometry changes the statistical problem. Increasing one component necessarily decreases at least one other component. Ordinary interpretations such as "the effect of increasing factor A while holding all other factors constant" are generally impossible.

### 5.2 Define the simplest three-component system

```r
library(mixRSMflow)

sp <- mix_spec(
  components = c("A", "B", "C"),
  total = 1
)

sp
```

The `mix_spec` object records:

- component names;
- mixture total;
- lower and upper bounds;
- additional linear restrictions;
- numerical tolerance;
- an orthonormal basis for independent coordinates;
- a feasible center;
- the region definition;
- an audit trail.

### 5.3 Define an agronomic formulation

Suppose a substrate amendment is to be formulated from three components:

- compost;
- biochar;
- mineral carrier.

The total fraction is one.

```r
substrate <- mix_spec(
  components = c("Compost", "Biochar", "Mineral"),
  total = 1,
  units = "proportion"
)

substrate
```

At this stage there is no response variable and no model. That is intentional. The first object represents the **scientifically allowed formulation space**.

---

## 6. Lower bounds, upper bounds, and general linear restrictions

Suppose the substrate must obey:

- compost between 0.20 and 0.70;
- biochar between 0.05 and 0.35;
- mineral carrier between 0.10 and 0.60;
- compost plus biochar no greater than 0.80.

```r
A <- matrix(
  c(1, 1, 0),
  nrow = 1,
  byrow = TRUE
)

sp_c <- mix_spec(
  components = c("Compost", "Biochar", "Mineral"),
  lower = c(0.20, 0.05, 0.10),
  upper = c(0.70, 0.35, 0.60),
  A = A,
  b = 0.80,
  dir = "<="
)

sp_c
```

### 6.1 Enumerate the extreme vertices

```r
V <- mix_vertices(sp_c)
V
```

Extreme vertices are the corner compositions of the feasible polytope. They are fundamental in constrained mixture design because an irregular region may no longer resemble the original full simplex.

### 6.2 Plot the extreme-vertices design

```r
ev <- mix_design(
  sp_c,
  type = "extreme_vertices",
  include_centroid = TRUE,
  edge_midpoints = TRUE
)

mix_plot(
  ev,
  type = "design"
)
```

### 6.3 What to interpret

Before fitting any response model, answer:

1. Is the feasible region nonempty?
2. Are all bounds scientifically realistic?
3. Do the vertices represent physically manufacturable or agronomically admissible formulations?
4. Is the region so narrow that a high-order model will be numerically unstable?
5. Will the intended design cover the interior as well as the boundary?
6. Are the constraints experimental requirements, safety requirements, cost requirements, or arbitrary conveniences?

A model cannot recover information from a region that the experiment never explores.

---

## 7. Independent coordinates and regions of interest

Mixture proportions are linearly dependent. `mixRSMflow` therefore provides an orthonormal transformation into `q - 1` independent coordinates.

```r
sp <- mix_spec(c("A", "B", "C"))

x <- data.frame(
  A = 0.20,
  B = 0.35,
  C = 0.45
)

z <- mix_transform(x, sp)
z

mix_inverse_transform(z, sp)
```

For a center \(c\) and an orthonormal contrast matrix \(H\),

\[
z=(x-c)H.
\]

The inverse transformation is

\[
x=c+zH^\mathsf{T}.
\]

These independent coordinates are useful for rotatable constructions and for defining spherical, ellipsoidal, or cuboidal regions of interest without pretending that the original mixture components are independent.

### 7.1 Spherical region

```r
rg_sphere <- mix_region(
  sp,
  type = "sphere",
  radius = 0.20
)

rg_sphere$region
```

### 7.2 Ellipsoidal region

```r
shape <- matrix(
  c(
    1.0, 0.2,
    0.2, 0.6
  ),
  nrow = 2,
  byrow = TRUE
)

rg_ellipsoid <- mix_region(
  sp,
  type = "ellipsoid",
  shape = shape
)

rg_ellipsoid$region
```

### 7.3 Cuboidal region in independent coordinates

```r
rg_box <- mix_region(
  sp,
  type = "cuboid",
  lower_y = c(-0.20, -0.10),
  upper_y = c( 0.20,  0.15)
)

rg_box$region
```

These region definitions are particularly useful when a scientific study focuses on a local neighborhood of a current formulation rather than the entire simplex.

---

## 8. Classical mixture designs

### 8.1 Simplex-lattice

```r
sp <- mix_spec(c("A", "B", "C"))

sl2 <- mix_design(
  sp,
  type = "simplex_lattice",
  degree = 2
)

sl3 <- mix_design(
  sp,
  type = "simplex_lattice",
  degree = 3
)

head(sl3$data)
```

A simplex-lattice \(\{q,m\}\) contains mixtures whose proportions are multiples of \(1/m\). For an unrestricted region, the nominal number of distinct points is

\[
N={m+q-1 \choose q-1}.
\]

### 8.2 Simplex-centroid

```r
sc <- mix_design(
  sp,
  type = "simplex_centroid"
)

sc
mix_plot(sc, type = "design")
```

A simplex-centroid design includes pure-component vertices, centroids of component subsets, and the overall centroid when feasible.

### 8.3 Axial design

```r
ax <- mix_design(
  sp,
  type = "axial"
)

mix_plot(ax)
```

### 8.4 Augmented centroid

```r
aug <- mix_design(
  sp,
  type = "augmented_centroid"
)

mix_plot(aug)
```

The augmented-centroid construction combines simplex-centroid and axial information.

### 8.5 Symmetric simplex in independent coordinates

```r
sym <- mix_design(
  sp,
  type = "symmetric_simplex"
)

mix_plot(sym)
```

### 8.6 Rotatable construction

```r
rot <- mix_design(
  sp,
  type = "rotatable"
)

rot_eval <- mix_rotatability(
  rot,
  model = "scheffe_quadratic"
)

rot_eval
```

### Design principle

A design name does not guarantee adequacy for a model. A simplex-centroid may be excellent for one purpose and insufficient for another. Design generation must therefore be followed by design evaluation.

---

## 9. Evaluate a design before collecting responses

```r
ev_sc <- mix_design_eval(
  sc,
  model = "scheffe_quadratic",
  resolution = 15
)

ev_sc
```

The evaluation object summarizes:

- rank and estimability;
- determinant/information behavior;
- average prediction variance;
- maximum prediction variance;
- FDS information;
- VDG information;
- leverage and coverage-related quantities;
- conditioning.

Plot the Fraction of Design Space curve:

```r
mix_plot(
  ev_sc,
  type = "fds"
)
```

Plot the Variance Dispersion Graph summary:

```r
mix_plot(
  ev_sc,
  type = "vdg"
)
```

### Interpretation

A design can estimate all requested coefficients and still be unattractive for prediction. Conversely, a design with correlated coefficient estimates may still predict well over a narrow constrained region.

Ask what the experiment is for:

- parameter estimation;
- prediction over the full feasible region;
- locating a maximum;
- distinguishing competing models;
- screening components;
- estimating lack of fit;
- supporting sequential refinement.

The design criterion should follow the scientific purpose.

---

## 10. The core Scheffé workflow

### 10.1 Generate replicated teaching data

```r
sp <- mix_spec(c("A", "B", "C"))

d <- mix_demo_data(
  "mixture",
  n_rep = 3,
  seed = 20260813
)

head(d)
```

### 10.2 Scheffé linear model

\[
E(Y)=\sum_{i=1}^{q}\beta_i x_i.
\]

```r
fit_linear <- mix_fit(
  "response",
  d,
  sp,
  model = "scheffe_linear"
)

summary(fit_linear)
```

### 10.3 Scheffé quadratic model

\[
E(Y)=
\sum_{i=1}^{q}\beta_i x_i+
\sum_{i<j}\beta_{ij}x_ix_j.
\]

```r
fit_quad <- mix_fit(
  "response",
  d,
  sp,
  model = "scheffe_quadratic"
)

summary(fit_quad)
```

### 10.4 Special cubic

\[
E(Y)=
\sum_i\beta_i x_i+
\sum_{i<j}\beta_{ij}x_ix_j+
\sum_{i<j<k}\beta_{ijk}x_ix_jx_k.
\]

```r
fit_scubic <- mix_fit(
  "response",
  d,
  sp,
  model = "scheffe_special_cubic"
)
```

### 10.5 Compare candidate models

```r
mix_compare(
  fit_linear,
  fit_quad,
  fit_scubic,
  criterion = "PRESS"
)
```

### Interpretation

Do not choose a higher-order model only because it has more curvature, and do not choose a lower-order model only because it is simpler.

Consider together:

1. whether the design estimates all requested terms;
2. pure error and lack of fit;
3. prediction error;
4. leverage and conditioning;
5. hierarchy;
6. scientific plausibility;
7. stability of predicted optima;
8. whether the added terms change an important conclusion.

---

## 11. Pure error and lack of fit

Replicated blends allow the residual sum of squares to be decomposed.

```r
anova_quad <- mix_anova(fit_quad)
anova_quad
```

For Gaussian fits, the package separates:

- regression;
- residual;
- lack of fit;
- pure error;
- total variation.

The lack-of-fit test compares systematic residual variation among distinct blends with the experimental variation observed among true replicates of the same blend.

### Interpretation

A non-significant lack-of-fit test is not proof that a model is true. It means that the available replicate information does not reveal lack of fit beyond the estimated pure error.

A significant lack-of-fit test is not an instruction to add the largest possible polynomial. It is evidence that the current response surface misses systematic structure. The next model should be scientifically and numerically defensible.

---

## 12. Diagnostics before interpretation

```r
dg <- mix_diagnose(fit_quad)
dg
```

The diagnostic object contains:

- fitted values;
- Pearson or response residuals;
- leverage;
- Cook distance;
- singular values;
- rank;
- condition number;
- coefficient-correlation information;
- warnings for severe ill-conditioning.

Residual plot:

```r
mix_plot(
  fit_quad,
  type = "residuals"
)
```

Normal Q-Q display:

```r
mix_plot(
  fit_quad,
  type = "qq"
)
```

Leverage versus residual view:

```r
mix_plot(
  fit_quad,
  type = "leverage"
)
```

### 12.1 Detailed collinearity diagnostics

```r
col_diag <- mix_collinearity(fit_quad)
col_diag
```

In a constrained mixture region, large coefficient correlations can arise because only a small part of the simplex is observed. This is not the same problem as ordinary multicollinearity among freely varying predictors.

### Interpretation order

1. Is the model matrix full rank?
2. Is the condition number acceptable for the intended inference?
3. Are a few blends carrying most of the leverage?
4. Are residual patterns systematic?
5. Is the fitted model sensitive to one design point?
6. Is parameter interpretation unstable while prediction remains relatively stable?
7. Would a better design or an augmented design solve the problem more directly than a different parameterization?

---

## 13. Prediction inside the feasible region

```r
new_blends <- data.frame(
  A = c(0.20, 0.40, 0.60),
  B = c(0.50, 0.30, 0.20),
  C = c(0.30, 0.30, 0.20)
)

pr <- mix_predict(
  fit_quad,
  newdata = new_blends,
  interval = "confidence",
  level = 0.95
)

pr
```

Prediction interval for a future observation:

```r
mix_predict(
  fit_quad,
  newdata = new_blends,
  interval = "prediction",
  level = 0.95
)
```

For mixture-process models, the new data must also supply the required process-variable settings.

### Interpretation

A confidence interval describes uncertainty in the estimated mean response. A prediction interval is wider because it also includes future observation variability.

Predictions should be made inside the declared feasible region unless an explicit extrapolation analysis is scientifically justified.

---

## 14. Component effects are paths, not ordinary slopes

Mixture coefficients are not interpreted as independent-factor slopes. The package therefore provides paths through the simplex.

### 14.1 Cox direction

```r
cox_A <- mix_effects(
  fit_quad,
  type = "cox",
  component = "A",
  n = 51
)

head(cox_A$path)
mix_plot(cox_A)
```

### 14.2 Piepel or pseudocomponent direction

```r
piepel_A <- mix_effects(
  fit_quad,
  type = "piepel",
  component = "A",
  n = 51
)

mix_plot(piepel_A)
```

### 14.3 Component trace

```r
trace_A <- mix_effects(
  fit_quad,
  type = "component_trace",
  component = "A",
  n = 51
)

mix_plot(trace_A)
```

### 14.4 Substitution effect

```r
sub_AB <- mix_effects(
  fit_quad,
  type = "substitution",
  from_component = "A",
  to_component = "B",
  n = 51
)

mix_plot(sub_AB)
```

### 14.5 User-defined direction

```r
dir_eff <- mix_effects(
  fit_quad,
  type = "directional",
  reference = c(A = 0.33, B = 0.33, C = 0.34),
  direction = c(A = 1, B = -0.5, C = -0.5),
  n = 51
)

mix_plot(dir_eff)
```

### Interpretation

A component effect is meaningful only together with the rule describing how the other components change.

For example, increasing A while decreasing B and C proportionally is a different scientific intervention from replacing only B with A.

---

## 15. Model screening and reduction

### 15.1 Screen components through directional behavior

```r
scr <- mix_screen(
  fit_quad,
  direction = "cox",
  level = 0.95
)

scr
```

### 15.2 Reduce a high-order model

```r
full_fit <- mix_fit(
  "response",
  d,
  sp,
  model = "scheffe_special_cubic"
)

red <- mix_reduce(
  full_fit,
  criterion = "hybrid",
  max_steps = 25
)

red
```

### 15.3 Compare the reduced fit with the original candidate

```r
mix_compare(
  full_fit,
  red$selected,
  criterion = "PRESS"
)
```

### Reduction rule

Automatic reduction is a support tool. It is not a substitute for scientific hierarchy and design logic.

When interaction or higher-order terms are retained, lower-order structure needed for a coherent surface should be protected. If a reduced model improves a criterion but creates implausible response behavior near the boundary, it should not be accepted automatically.

---

# Part II. Constrained regions and modern design construction

## 16. Lower-bound and upper-bound pseudocomponents

Pseudocomponents can simplify the geometry of constrained systems.

### 16.1 Lower-bound transformation

```r
sp_L <- mix_spec(
  c("A", "B", "C"),
  lower = c(0.10, 0.20, 0.10)
)

x <- data.frame(
  A = c(0.20, 0.40),
  B = c(0.30, 0.20),
  C = c(0.50, 0.40)
)

zL <- mix_pseudocomponents(
  x,
  sp_L,
  type = "L"
)

zL
```

Invert:

```r
mix_pseudocomponents(
  zL,
  sp_L,
  type = "L",
  inverse = TRUE
)
```

### 16.2 Upper-bound transformation

```r
sp_U <- mix_spec(
  c("A", "B", "C"),
  upper = c(0.70, 0.70, 0.70)
)

zU <- mix_pseudocomponents(
  x,
  sp_U,
  type = "U"
)

zU
```

### Interpretation

Pseudocomponents change coordinates. They do not remove the scientific constraints. Report final formulations in the original component scale.

---

## 17. Slack-variable reparameterization

When one component is treated as a slack component, the mixture total determines it from the others.

```r
rep_fit <- mix_reparameterize(
  fit_quad,
  slack_component = "C"
)

rep_fit
```

Slack-variable parameterization can improve interpretation in some applications, but it also changes the coefficient meaning. The selected slack component should have a scientific rationale, not merely be the component with the least attractive coefficient.

---

## 18. Optimal design criteria

Irregular constrained regions often make classical designs inefficient or impossible.

```r
sp_opt <- mix_spec(
  c("A", "B", "C"),
  lower = c(0.05, 0.05, 0.05),
  upper = c(0.80, 0.80, 0.80)
)
```

### 18.1 D-optimal design

D-optimality targets parameter-estimation volume.

```r
d_D <- mix_optimal_design(
  sp_opt,
  model = "scheffe_quadratic",
  runs = 10,
  criterion = "D",
  algorithm = "hybrid",
  seed = 101
)
```

### 18.2 A-optimal design

```r
d_A <- mix_optimal_design(
  sp_opt,
  model = "scheffe_quadratic",
  runs = 10,
  criterion = "A",
  algorithm = "hybrid",
  seed = 101
)
```

### 18.3 I-optimal design

I-optimality emphasizes average prediction variance.

```r
d_I <- mix_optimal_design(
  sp_opt,
  model = "scheffe_quadratic",
  runs = 10,
  criterion = "I",
  algorithm = "hybrid",
  seed = 101
)
```

### 18.4 G-optimal design

G-optimality focuses on worst-case prediction variance.

```r
d_G <- mix_optimal_design(
  sp_opt,
  model = "scheffe_quadratic",
  runs = 10,
  criterion = "G",
  algorithm = "hybrid",
  seed = 101
)
```

### 18.5 Other implemented criteria

```r
d_E <- mix_optimal_design(
  sp_opt,
  "scheffe_quadratic",
  runs = 10,
  criterion = "E"
)

d_T <- mix_optimal_design(
  sp_opt,
  "scheffe_quadratic",
  runs = 10,
  criterion = "T",
  alternative_model = "scheffe_special_cubic"
)

d_alias <- mix_optimal_design(
  sp_opt,
  "scheffe_quadratic",
  runs = 10,
  criterion = "Alias",
  alias_model = "scheffe_special_cubic"
)
```

The package also implements `BayesD` and `BayesI` criteria through explicit prior-precision inputs.

---

## 19. Prediction variance, FDS, VDG, and conditioning

For a model vector \(f(x)\) and information matrix \(X^\mathsf{T}X\),

\[
v(x)=f(x)^\mathsf{T}(X^\mathsf{T}X)^{-1}f(x)
\]

is proportional to the model-based prediction variance.

### 19.1 Compare two designs

```r
ev_D <- mix_design_eval(
  d_D,
  model = "scheffe_quadratic",
  resolution = 18
)

ev_I <- mix_design_eval(
  d_I,
  model = "scheffe_quadratic",
  resolution = 18
)

ev_D$measures
ev_I$measures
```

### 19.2 FDS

```r
mix_plot(
  ev_D,
  type = "fds"
)

mix_plot(
  ev_I,
  type = "fds"
)
```

FDS compares the fraction of the feasible design space below a given prediction-variance level.

### 19.3 VDG

```r
mix_plot(
  ev_D,
  type = "vdg"
)
```

VDG summarizes how prediction variance changes with radial location in the relevant independent-coordinate representation.

### Interpretation

A design should be judged using the criterion that reflects the experimental objective and then checked with additional diagnostics. Do not report "D-optimal" as a synonym for "best design."

---

## 20. Rotatability and simplex moments

### 20.1 Rotatability diagnostic

```r
rot_diag <- mix_rotatability(
  rot,
  spec = sp,
  model = "scheffe_quadratic",
  bins = 6,
  resolution = 18
)

rot_diag
```

### 20.2 Simplex moments

`mix_moments()` supports theoretical calculations needed by design criteria and response-surface calculations.

```r
mix_moments(
  sp,
  powers = c(2, 0, 0),
  method = "auto"
)

mix_moments(
  sp,
  powers = c(1, 1, 0),
  method = "exact"
)
```

For regions where exact moments are not available through the implemented route, Monte Carlo integration can be requested explicitly.

```r
mix_moments(
  sp_c,
  powers = c(1, 1, 0),
  method = "monte_carlo",
  n = 100000,
  seed = 20260813
)
```

---

## 21. Integrated mean-square error

Design selection should consider the possibility that the fitted model is simpler than the true response surface.

```r
imse <- mix_imse(
  design = d_I,
  spec = sp_opt,
  fitted_model = "scheffe_quadratic",
  true_model = "scheffe_special_cubic",
  resolution = 15
)

imse
```

This type of analysis separates variance and model-bias contributions under an explicitly declared fitted-versus-true model scenario.

### Interpretation

IMSE is a design sensitivity tool. The assumed "true" model is a scientific scenario, not a claim that the unknown data-generating mechanism has been discovered.

---

## 22. Genetic and hybrid design search

Highly constrained spaces can make exchange-only search sensitive to the starting design.

```r
d_ga <- mix_optimal_design(
  sp_opt,
  model = "scheffe_quadratic",
  runs = 10,
  criterion = "I",
  algorithm = "ga",
  population = 50,
  generations = 60,
  seed = 2201
)

d_hybrid <- mix_optimal_design(
  sp_opt,
  model = "scheffe_quadratic",
  runs = 10,
  criterion = "I",
  algorithm = "hybrid",
  starts = 5,
  max_iter = 30,
  population = 50,
  generations = 60,
  seed = 2201
)
```

Compare designs:

```r
eval_ga <- mix_design_eval(d_ga)
eval_hybrid <- mix_design_eval(d_hybrid)

eval_ga$measures
eval_hybrid$measures
```

### Interpretation

A stochastic search algorithm needs:

- a recorded seed;
- enough starts or population diversity;
- convergence or stability checks;
- evaluation on the same candidate/evaluation region;
- transparent reporting of the design criterion.

The fact that an algorithm is called genetic does not make the result automatically superior.

---

## 23. Model-robust and Bayesian optimal design

Model uncertainty can be included in design construction.

```r
d_model_uncertain <- mix_optimal_design(
  sp_opt,
  model = "scheffe_quadratic",
  runs = 12,
  criterion = "I",
  algorithm = "hybrid",
  robust = "worst",
  seed = 2301
)
```

Bayesian D and Bayesian I criteria can incorporate prior precision.

```r
prior_P <- diag(0.10, 6)

d_BD <- mix_optimal_design(
  sp_opt,
  model = "scheffe_quadratic",
  runs = 10,
  criterion = "BayesD",
  prior_precision = prior_P,
  seed = 2302
)
```

The exact dimension of `prior_precision` must correspond to the active model basis.

### Interpretation

Prior information in optimal design is not the same as a Bayesian response model. It changes the design criterion by acknowledging prior parameter precision.

---

## 24. Sequential augmentation

An experiment does not always need to be restarted.

```r
d0 <- mix_design(
  sp_opt,
  type = "simplex_centroid"
)

d1 <- mix_augment(
  d0,
  n_new = 3,
  model = "scheffe_quadratic",
  objective = "I",
  resolution = 15,
  seed = 2401
)

mix_design_eval(
  d1,
  model = "scheffe_quadratic"
)
```

Other objectives:

```r
mix_augment(
  d0,
  n_new = 2,
  model = "scheffe_quadratic",
  objective = "D"
)

mix_augment(
  d0,
  n_new = 2,
  model = "scheffe_quadratic",
  objective = "G"
)
```

When a fitted model is available, augmentation can focus on the currently estimated optimum:

```r
mix_augment(
  d0,
  n_new = 2,
  model = "scheffe_quadratic",
  objective = "optimum_uncertainty",
  fit = fit_quad,
  seed = 2402
)
```

### Interpretation

Sequential augmentation should have a declared purpose.

If new points are chosen only from the original design geometry, it is a design-efficiency problem. If new points are chosen after observing outcomes, the procedure is response-adaptive and the inferential consequences should be stated.

---

# Part III. Mixture-process and structured experiments

## 25. Mixture-process experiments

Many formulation problems depend on both composition and processing conditions.

Examples include:

- fertilizer formulation and granulation temperature;
- biostimulant composition and application rate;
- food formulation and heating time;
- animal-feed ingredients and pelleting temperature;
- pesticide mixture and spray volume;
- substrate formulation and irrigation regime.

### 25.1 Generate a mixture-process design

```r
sp <- mix_spec(c("A", "B", "C"))

mp <- mix_design(
  sp,
  type = "mixture_process",
  base_type = "simplex_centroid",
  process = list(
    temperature = c(20, 40),
    time = c(1, 3)
  ),
  degree = 2
)

head(mp$data)
```

### 25.2 Simulate a teaching response

```r
set.seed(2501)

mp$data$yield_index <- with(
  mp$data,
  4.0 * A +
  6.0 * B +
  5.0 * C +
  0.03 * temperature -
  0.15 * time +
  0.05 * B * temperature +
  rnorm(nrow(mp$data), 0, 0.10)
)
```

### 25.3 Fit the combined model

```r
fit_mp <- mix_fit(
  "yield_index",
  mp,
  model = "scheffe_quadratic",
  process = c("temperature", "time"),
  process_order = 2,
  mixture_process = TRUE
)

summary(fit_mp)
```

### Interpretation

Mixture components remain constrained and process variables do not. Their distinction is encoded in the basis.

An interaction such as B by temperature means that the blending behavior associated with B changes with temperature. It should not be interpreted as if B and temperature were two ordinary independent components.

---

## 26. Fractionating a large mixture-process design

A full crossed design can become too large.

```r
mp_full <- mix_design(
  sp,
  type = "mixture_process",
  process = list(
    temperature = c(20, 30, 40),
    time = c(1, 2, 3),
    speed = c(100, 200)
  ),
  degree = 2
)
```

Retain a fraction using model-based D-information:

```r
mp_frac <- mix_fractionate_process(
  mp_full,
  process = c("temperature", "time", "speed"),
  fraction = 0.50,
  model = "scheffe_quadratic",
  process_order = 2,
  mixture_process = TRUE,
  seed = 2601
)

mp_frac
```

The same functionality can be requested during design creation with `fraction=` and `fraction_method="D"`.

### Interpretation

Fractionation must protect the model terms that the experiment is intended to estimate. A smaller design is not efficient if it destroys the scientific contrasts or interactions of interest.

---

## 27. Mixture-amount experiments

Sometimes both composition and total amount matter.

```r
ma <- mix_design(
  sp,
  type = "mixture_amount",
  base_type = "simplex_centroid",
  amount = c(50, 100, 150)
)

head(ma$data)
```

For example, a foliar formulation may vary both the proportions of active ingredients and the total dose. Composition and amount should then be distinguished explicitly.

---

## 28. Blocks

Blocking is a design property.

```r
base <- mix_design(
  sp,
  type = "simplex_lattice",
  degree = 3
)

bd <- mix_block_design(
  base,
  n_blocks = 2,
  model = "scheffe_quadratic",
  iterations = 5000,
  seed = 2801
)

bd$block_diagnostics
```

The block search attempts to reduce imbalance of standardized model columns across blocks. The diagnostic output should be inspected rather than assuming that exact orthogonality was achieved.

---

## 29. Latin-square process layouts

When two process variables are to be combined with the mixture in a balanced Latin-style structure:

```r
lat <- mix_latin_process_design(
  sp,
  process1 = list(
    temperature = c(20, 30, 40)
  ),
  process2 = list(
    time = c(1, 2, 3)
  ),
  base_type = "simplex_centroid",
  degree = 2,
  seed = 2901
)

head(lat$data)
```

The design logic should reflect the actual experimental operations. A mathematically balanced process layout is not useful if the physical randomization cannot follow it.

---

## 30. Split-plot mixture-process experiments

Hard-to-change process factors often require whole plots.

```r
sp_split <- mix_design(
  sp,
  type = "split_plot",
  base_type = "simplex_centroid",
  process = list(
    temperature = c(20, 40),
    time = c(1, 3)
  ),
  hard_to_change = "temperature",
  seed = 3001
)

head(sp_split$data)
```

The design creates identifiers such as `.whole_plot` and `.subplot`.

The analysis must then respect the hierarchy. An ordinary fixed-effects model that ignores the whole-plot structure can use the wrong error information.

---

## 31. Mixed-effects mixture models

When the experimental structure contains blocks, batches, operators, or whole plots, use the explicit adapter.

```r
if (requireNamespace("lme4", quietly = TRUE)) {
  d_block <- mix_demo_data(
    "mixture",
    n_rep = 3,
    seed = 3101
  )

  d_block$block <- factor(
    rep(seq_len(3), length.out = nrow(d_block))
  )

  fit_mixed <- mix_fit_mixed(
    "response",
    d_block,
    sp,
    random = "(1 | block)",
    model = "scheffe_quadratic"
  )

  fit_mixed
}
```

### Interpretation

The mixture basis remains explicit. `lme4` estimates the hierarchical error structure.

A random term should represent a real random experimental or sampling level. Do not add random effects merely to reduce residual degrees of freedom or to obtain preferred p-values.

---

## 32. GLS for correlated or heterogeneous Gaussian errors

When the response is Gaussian but residual errors have a known covariance or variance pattern, use `mix_fit_gls()`.

```r
if (requireNamespace("nlme", quietly = TRUE)) {
  d_gls <- mix_demo_data(
    "mixture",
    n_rep = 3,
    seed = 3201
  )

  d_gls$batch <- factor(
    rep(seq_len(3), length.out = nrow(d_gls))
  )

  gls_fit <- mix_fit_gls(
    "response",
    d_gls,
    sp,
    model = "scheffe_quadratic",
    method = "REML"
  )

  gls_fit
}
```

More advanced calls can pass an `nlme` correlation or variance structure.

### Interpretation

GLS changes the error model, not the mixture geometry. It is appropriate when residual dependence or heteroscedasticity is scientifically or diagnostically supported.

---

# Part IV. Alternative and advanced model forms

## 33. Why Scheffé is not the only possible mixture model

Scheffé polynomials are central to mixture methodology, but some applications are better represented by alternative parameterizations or blending assumptions.

Inspect the basis directly:

```r
sp <- mix_spec(c("A", "B", "C"))

grid_small <- data.frame(
  A = c(0.20, 0.30, 0.40),
  B = c(0.30, 0.40, 0.20),
  C = c(0.50, 0.30, 0.40)
)

mix_basis(
  grid_small,
  sp,
  model = "scheffe_quadratic"
)
```

The basis function is useful for teaching because it exposes the columns that the model will estimate.

---

## 34. Inverse terms

```r
mix_basis(
  grid_small,
  sp,
  model = "inverse_scheffe",
  inverse_components = "A"
)
```

Inverse terms require positive component values. They should be used only when the implied behavior near zero is meaningful and the design does not make the terms numerically explosive.

---

## 35. Component ratios

```r
mix_basis(
  grid_small,
  sp,
  model = "ratio",
  denominator = "A"
)
```

Ratio models can be useful when a response is mechanistically linked to relative amounts such as nutrient ratios.

The denominator should not be chosen solely because it improves a statistical criterion. Near-zero denominators can create severe numerical instability.

---

## 36. Cox parameterizations

```r
cox2 <- mix_basis(
  grid_small,
  sp,
  model = "cox_quadratic",
  reference = c(
    A = 0.33,
    B = 0.33,
    C = 0.34
  )
)

cox2
```

Cox coordinates can support interpretation around a reference blend.

---

## 37. Log-contrast models

```r
lc <- mix_basis(
  grid_small,
  sp,
  model = "logcontrast",
  reference = "A"
)

lc
```

Log-contrast models connect mixture modeling with compositional-data thinking. Every component entering a logarithm must be strictly positive.

---

## 38. Slack-variable models

```r
slack_basis <- mix_basis(
  grid_small,
  sp,
  model = "slack_quadratic",
  slack_component = "C"
)

slack_basis
```

The omitted or slack component is reconstructed through the sum constraint.

---

## 39. Becker H1, H2, H3 and additive blending

```r
mix_basis(
  grid_small,
  sp,
  model = "becker_h1"
)

mix_basis(
  grid_small,
  sp,
  model = "becker_h2"
)

mix_basis(
  grid_small,
  sp,
  model = "becker_h3"
)

mix_basis(
  grid_small,
  sp,
  model = "additive_blending",
  additive_component = "A"
)
```

These alternatives should be introduced only after students understand the standard Scheffé basis. Otherwise the different coefficient meanings are easily confused.

---

## 40. General Blending Model terms

`mix_gbm_term()` creates an explicit fixed-exponent General Blending Model term.

```r
gbm_AB <- mix_gbm_term(
  components = c("A", "B"),
  g = c(2, 2),
  h = 0.5,
  s = 2,
  label = "AB"
)

gbm_AB
```

Use it in the basis:

```r
gbm_basis <- mix_basis(
  grid_small,
  sp,
  model = "gbm",
  gbm_terms = list(gbm_AB)
)

gbm_basis
```

For a binary GBM term, the implemented form is

\[
\left(\frac{x_i}{x_i+x_j}\right)^{g_i h}
\left(\frac{x_j}{x_i+x_j}\right)^{g_j(1-h)}
(x_i+x_j)^s.
\]

With \(g_i=g_j=2\), \(h=1/2\), and \(s=2\), the term reduces to the Scheffé product \(x_i x_j\).

### Interpretation

The exponent values are explicit inputs. Ordinary `mix_fit()` does not silently estimate nonlinear GBM exponents. This is an important transparency safeguard.

---

## 41. Kronecker quadratic basis

```r
kron <- mix_basis(
  grid_small,
  sp,
  model = "kronecker_quadratic"
)

kron
```

This basis is useful for specialized mixture-process formulations and methodological comparisons.

---

## 42. Segmented mixture surfaces

A single global polynomial may not be appropriate when blending behavior changes across a meaningful component threshold.

```r
d_seg <- mix_demo_data(
  "mixture",
  n_rep = 3,
  seed = 4201
)

seg_fit <- mix_segmented_fit(
  "response",
  d_seg,
  sp,
  split_component = "A",
  cut = 0.50,
  model_left = "scheffe_linear",
  model_right = "scheffe_quadratic"
)

seg_fit
```

Predict:

```r
seg_pred <- mix_predict_segmented(
  seg_fit,
  interval = "confidence"
)

head(seg_pred)
```

### Interpretation

A segmented model should correspond to a scientific regime change or a clearly motivated response feature. Searching many cut points until one produces a visually attractive surface risks overfitting.

---

## 43. Generalized-linear mixture models

`mix_fit()` can use an R GLM family.

### 43.1 Poisson teaching example

```r
set.seed(4301)

d_count <- mix_demo_data(
  "mixture",
  n_rep = 3,
  seed = 4301
)

lambda <- exp(
  1.0 * d_count$A +
  1.4 * d_count$B +
  0.8 * d_count$C
)

d_count$count <- rpois(
  nrow(d_count),
  lambda = lambda
)

fit_pois <- mix_fit(
  "count",
  d_count,
  sp,
  model = "scheffe_linear",
  family = poisson()
)

summary(fit_pois)
```

### 43.2 Weighted Gaussian model

```r
d_w <- mix_demo_data(
  "mixture",
  n_rep = 3,
  seed = 4302
)

d_w$w <- seq(0.8, 1.2, length.out = nrow(d_w))

fit_wls <- mix_fit(
  "response",
  d_w,
  sp,
  model = "scheffe_quadratic",
  weights = "w"
)
```

### Interpretation

The response family must match the scientific data-generating process. A mixture polynomial specifies the systematic predictor; the GLM family specifies the response distribution and link.

---

## 44. Bayesian mixture fitting

The optional `brms` adapter preserves the mixture basis and adds Bayesian estimation.

```r
if (FALSE) {
  # Requires brms and a working Stan toolchain.
  library(brms)

  d_bayes <- mix_demo_data(
    "mixture",
    n_rep = 3,
    seed = 4401
  )

  prior <- c(
    prior(normal(0, 5), class = "b"),
    prior(exponential(1), class = "sigma")
  )

  fit_bayes <- mix_fit_bayes(
    "response",
    d_bayes,
    sp,
    model = "scheffe_quadratic",
    prior = prior,
    brms_args = list(
      chains = 4,
      iter = 4000,
      seed = 4401
    )
  )

  fit_bayes
}
```

A Bayesian mixture analysis should document:

- prior rationale;
- prior predictive implications where possible;
- convergence diagnostics;
- effective sample size;
- posterior intervals;
- posterior predictive checks;
- sensitivity to consequential priors.

Bayesian fitting is not an excuse to skip mixture-design adequacy.

---

# Part V. Multiple responses and optimization

## 45. Fit several responses on the same design

```r
d_multi <- mix_demo_data(
  "multiresponse",
  n_rep = 3,
  seed = 4501
)

mf <- mix_multi_fit(
  responses = c(
    "quality",
    "cost",
    "stability"
  ),
  data = d_multi,
  spec = sp,
  model = "scheffe_quadratic"
)

mf
```

Each response has its own fitted `mix_fit` object.

```r
summary(mf$fits$quality)
summary(mf$fits$cost)
summary(mf$fits$stability)
```

### Interpretation

A common design does not imply that every response should use the same model degree. The shared semantics make comparison easier, but each response still needs diagnostics and scientific justification.

---

## 46. Biplot of predicted response patterns

```r
bp <- mix_biplot(
  mf,
  resolution = 15,
  scale = TRUE,
  plot = TRUE
)

bp$plot
```

The biplot is descriptive. It summarizes predicted response relationships on a common feasible grid.

Do not optimize directly from a PCA score unless the scientific objective truly concerns that score. Keep optimization on the original response scales whenever possible.

---

## 47. Multiresponse desirability

Suppose:

- quality should be maximized;
- cost should be minimized;
- stability should be maximized.

```r
goals <- c(
  quality = "maximize",
  cost = "minimize",
  stability = "maximize"
)

settings <- list(
  quality = list(
    low = min(d_multi$quality),
    high = max(d_multi$quality)
  ),
  cost = list(
    low = min(d_multi$cost),
    high = max(d_multi$cost)
  ),
  stability = list(
    low = min(d_multi$stability),
    high = max(d_multi$stability)
  )
)

mo <- mix_multiopt(
  mf,
  goals = goals,
  settings = settings,
  resolution = 25,
  random_candidates = 5000,
  seed = 4701
)

mo
```

The overall desirability is a weighted geometric mean:

\[
D=
\left(
\prod_{r=1}^{R}
d_r^{w_r}
\right)^{1/\sum_r w_r}.
\]

Plot the desirability map:

```r
mix_plot(
  mo,
  type = "desirability"
)
```

### Interpretation

Weights and low/high desirability limits are decision assumptions. They must be stated explicitly.

A high overall desirability does not mean every response is individually optimal.

---

## 48. Pareto trade-offs

```r
mix_plot(
  mo,
  type = "pareto"
)

head(mo$pareto)
```

A Pareto solution is non-dominated: improving one objective requires worsening at least one other objective.

### Interpretation

When responses conflict, the Pareto set is often more informative than a single weighted optimum. It shows the decision-maker which compromises are available before subjective weights are imposed.

---

## 49. Single-response optimization

```r
fit <- mix_fit(
  "response",
  d,
  sp,
  model = "scheffe_quadratic"
)
```

### 49.1 Maximize

```r
opt_max <- mix_optimize(
  fit,
  goal = "maximize",
  method = "hybrid",
  grid_resolution = 30,
  random_candidates = 5000,
  seed = 4901
)

opt_max
```

### 49.2 Minimize

```r
opt_min <- mix_optimize(
  fit,
  goal = "minimize",
  method = "grid",
  grid_resolution = 30
)

opt_min
```

### 49.3 Target a specific response

```r
opt_target <- mix_optimize(
  fit,
  goal = "target",
  target = 6.0,
  method = "hybrid",
  seed = 4902
)

opt_target
```

### 49.4 Visualize the optimum and near-optimal region

```r
mix_plot(
  opt_max,
  type = "optimum"
)
```

The returned object contains:

- best feasible composition;
- predicted response;
- model-based interval;
- near-optimal candidate points;
- search settings;
- the fitted model.

### Interpretation

The mathematical optimum of a fitted model is not automatically the recommended formulation.

A practical recommendation should also consider:

- uncertainty;
- material cost;
- manufacturability;
- safety or regulatory limits;
- sensitivity to small formulation errors;
- whether several nearby blends have practically equivalent response.

---

## 50. Uncertainty in the optimum location

A point optimum can overstate precision.

```r
ci_param <- mix_optimum_ci(
  opt_max,
  method = "parametric",
  B = 500,
  level = 0.95,
  grid_resolution = 20,
  seed = 5001
)

ci_param
```

Plot the joint cloud:

```r
mix_plot(
  ci_param,
  type = "optimum_ci"
)
```

Residual bootstrap for a Gaussian linear mixture fit:

```r
ci_resid <- mix_optimum_ci(
  opt_max,
  method = "residual_bootstrap",
  B = 500,
  level = 0.95,
  grid_resolution = 20,
  seed = 5002
)
```

### Interpretation

The component-wise intervals are marginal. Because the proportions must sum to one, they are not independent intervals.

The joint optimum cloud should be inspected together with the marginal intervals.

A broad cloud means that many compositions are statistically plausible optima even if the fitted surface has one exact mathematical maximum.

---

## 51. Near-optimal regions

`mix_optimize()` stores candidate mixtures whose predicted performance is close to the optimum according to `near_tolerance`.

```r
opt_practical <- mix_optimize(
  fit,
  goal = "maximize",
  near_tolerance = 0.02,
  method = "grid",
  grid_resolution = 40
)

head(opt_practical$near_optimal)
```

### Interpretation

A 2% near-optimal region can be more useful than an exact optimum when formulation costs, ingredient availability, or operational variability dominate tiny predicted differences.

The tolerance should have practical meaning. It should not be chosen only to produce a visually convenient region.

---

## 52. Bayesian optimization for expensive sequential experiments

`mix_bo()` is a Tier 3 optional workflow using a Gaussian-process backend.

```r
if (FALSE) {
  # Requires DiceKriging.
  d_bo <- mix_demo_data(
    "mixture",
    n_rep = 1,
    seed = 5201
  )

  bo <- mix_bo(
    data = d_bo,
    response = "response",
    spec = sp,
    goal = "maximize",
    iterations = 5,
    candidate_n = 5000,
    seed = 5201
  )

  bo
}
```

### When Bayesian optimization is useful

Use it when:

- each new experiment is expensive or slow;
- sequential decisions are operationally possible;
- a smooth surrogate model is scientifically plausible;
- exploitation and exploration must be balanced;
- the feasible mixture constraints must be respected in every proposed run.

### When not to use it

Do not use it merely because it is modern. For a small inexpensive experiment where a classical optimal design can cover the region well, a planned design may be more transparent and easier to validate.

---

# Part VI. Visualization and scientific communication

## 53. Ternary design plot

```r
mix_plot(
  sc,
  type = "design",
  engine = "ggplot2"
)
```

For three components, design points are displayed in the simplex. For more components, the package uses an alternative profile-style display.

---

## 54. Ternary response contour

```r
mix_plot(
  fit_quad,
  type = "ternary_contour",
  resolution = 40
)
```

Filled contour:

```r
mix_plot(
  fit_quad,
  type = "ternary_filled",
  resolution = 40
)
```

Heat-map style:

```r
mix_plot(
  fit_quad,
  type = "heatmap",
  resolution = 40
)
```

Prediction variance:

```r
mix_plot(
  fit_quad,
  type = "prediction_variance",
  resolution = 40
)
```

### Interpretation

A ternary contour is a geometric map of the fitted surface. It should be accompanied by information about:

- the fitted model;
- the experimental region;
- observed design points;
- uncertainty;
- whether the contours extend into poorly supported regions.

---

## 55. Cornell-style three-dimensional vector surface

The package includes a modern recalculated analogue of the dual-view wireframe used historically for three-component mixture response surfaces.

```r
mix_plot(
  fit_quad,
  type = "surface3d",
  engine = "base",
  resolution = 30,
  views = 2,
  file = "mixture_surface.pdf"
)
```

SVG:

```r
mix_plot(
  fit_quad,
  type = "surface3d",
  engine = "base",
  resolution = 30,
  views = 2,
  file = "mixture_surface.svg"
)
```

The PDF and SVG output preserve vector geometry.

The figure is generated from the fitted model. It does not contain scanned textbook artwork.

### Interpretation

Use the three-dimensional surface to understand curvature, peaks, valleys, and boundary behavior. Use the ternary contour for more precise reading of compositions.

The two views complement each other.

---

## 56. High-resolution raster output

```r
mix_plot(
  fit_quad,
  type = "ternary_contour",
  file = "mixture_contour_600dpi.tiff",
  width = 7,
  height = 6,
  dpi = 600
)
```

PNG is also supported.

```r
mix_plot(
  fit_quad,
  type = "ternary_filled",
  file = "mixture_filled_600dpi.png",
  width = 7,
  height = 6,
  dpi = 600
)
```

For publication, use vector output when possible. Use high-resolution raster output when required by the journal or when the graphic contains features that do not translate conveniently to vector form.

---

## 57. Interactive Plotly graphics

Interactive design plot:

```r
if (requireNamespace("plotly", quietly = TRUE)) {
  mix_plot(
    sc,
    type = "design",
    engine = "plotly"
  )
}
```

Interactive surface:

```r
if (requireNamespace("plotly", quietly = TRUE)) {
  mix_plot(
    fit_quad,
    type = "surface3d",
    engine = "plotly",
    resolution = 25
  )
}
```

### Interpretation

Interactive graphics are excellent for teaching, exploratory analysis, and checking specific mixtures.

They should not replace a static publication figure or the numeric prediction table that defines the statistical result.

---

## 58. Scientific reports

Create a Markdown report:

```r
rep_md <- mix_report(
  fit_quad,
  format = "markdown",
  title = "Three-component mixture analysis"
)

rep_md
```

Write to file:

```r
mix_report(
  fit_quad,
  file = "mixture_analysis.md",
  format = "markdown",
  title = "Three-component mixture analysis"
)
```

HTML:

```r
mix_report(
  fit_quad,
  file = "mixture_analysis.html",
  format = "html"
)
```

DOCX or PDF require `rmarkdown` and the corresponding rendering environment.

```r
if (requireNamespace("rmarkdown", quietly = TRUE)) {
  mix_report(
    fit_quad,
    file = "mixture_analysis.docx",
    format = "docx"
  )
}
```

The report records:

- scientific scope;
- mixture specification;
- model basis and engine;
- coefficients;
- ANOVA/lack of fit when available;
- diagnostics;
- bounded optimum;
- design quality when the design object is attached;
- limitations;
- audit trail;
- session information.

---

## 59. Audit trail and reproducibility

```r
mix_audit_trail(sp)
mix_audit_trail(sc)
mix_audit_trail(fit_quad)
```

The audit trail records package decisions such as:

- specification creation;
- design type;
- fitting model;
- algorithm choices;
- seeds when relevant.

Reproducibility also requires external information:

- R version;
- package version;
- optional-backend versions;
- operating system;
- data version;
- any preprocessing performed outside `mixRSMflow`.

---

# Part VII. Five integrated workflows

## 60. Basic integrated workflow: a three-component formulation

This is the recommended first complete analysis.

### Step 1: define the region

```r
sp <- mix_spec(
  c("A", "B", "C")
)
```

### Step 2: generate a design

```r
des <- mix_design(
  sp,
  type = "augmented_centroid"
)

mix_plot(des)
```

### Step 3: evaluate the design

```r
mix_design_eval(
  des,
  model = "scheffe_quadratic"
)
```

### Step 4: collect or simulate responses

```r
dat <- mix_demo_data(
  "mixture",
  n_rep = 3,
  seed = 6001
)
```

### Step 5: fit a quadratic model

```r
fit <- mix_fit(
  "response",
  dat,
  sp,
  model = "scheffe_quadratic"
)
```

### Step 6: pure error and lack of fit

```r
mix_anova(fit)
```

### Step 7: diagnostics

```r
mix_diagnose(fit)
mix_collinearity(fit)
```

### Step 8: component interpretation

```r
eff_A <- mix_effects(
  fit,
  type = "cox",
  component = "A"
)

mix_plot(eff_A)
```

### Step 9: response surface

```r
mix_plot(
  fit,
  type = "ternary_contour"
)
```

### Step 10: optimize

```r
opt <- mix_optimize(
  fit,
  goal = "maximize",
  method = "hybrid",
  seed = 6002
)

opt
```

### Step 11: quantify optimum uncertainty

```r
ci <- mix_optimum_ci(
  opt,
  method = "parametric",
  B = 500,
  seed = 6003
)

ci
```

### Step 12: report

```r
mix_report(
  list(
    fit = fit,
    design = des,
    optimum = opt
  ),
  file = "basic_mixture_workflow.md",
  format = "markdown",
  title = "Basic mixture workflow"
)
```

### Interpretation template

A concise scientific interpretation should state:

- the three components and their feasible limits;
- the design used and why it supports the intended model;
- the fitted model family;
- whether lack of fit is detectable relative to pure error;
- whether leverage or conditioning is problematic;
- the major component-effect pattern;
- the fitted optimum;
- the uncertainty and near-optimal region;
- the range over which the conclusion is valid.

---

## 61. Integrated constrained-region workflow

### Stage A: constraints

```r
sp_c <- mix_spec(
  c("A", "B", "C"),
  lower = c(0.10, 0.05, 0.05),
  upper = c(0.70, 0.80, 0.80),
  A = matrix(c(1, 1, 0), nrow = 1),
  b = 0.75,
  dir = "<="
)
```

### Stage B: inspect vertices

```r
mix_vertices(sp_c)
```

### Stage C: create an initial extreme-vertices design

```r
d_ev <- mix_design(
  sp_c,
  "extreme_vertices"
)

mix_plot(d_ev)
```

### Stage D: build an I-optimal design

```r
d_I <- mix_optimal_design(
  sp_c,
  model = "scheffe_quadratic",
  runs = 12,
  criterion = "I",
  algorithm = "hybrid",
  seed = 6101
)
```

### Stage E: compare design quality

```r
ev1 <- mix_design_eval(
  d_ev,
  model = "scheffe_quadratic"
)

ev2 <- mix_design_eval(
  d_I,
  model = "scheffe_quadratic"
)

ev1$measures
ev2$measures
```

### Stage F: collect data and fit

```r
# Replace this teaching response with observed data in a real experiment.
set.seed(6102)

obs <- d_I$data
obs$response <- with(
  obs,
  4 * A + 6 * B + 5 * C +
  2.5 * A * B -
  1.5 * A * C +
  rnorm(nrow(obs), 0, 0.15)
)

fit_c <- mix_fit(
  "response",
  obs,
  d_I,
  model = "scheffe_quadratic"
)
```

### Stage G: diagnose and optimize

```r
mix_diagnose(fit_c)
mix_collinearity(fit_c)

opt_c <- mix_optimize(
  fit_c,
  "maximize",
  method = "hybrid",
  seed = 6103
)

opt_c
```

### Advanced interpretation template

Report the geometry of the feasible region. In a severely constrained system, a composition may look central in a ternary plot while actually being close to a boundary of the feasible polygon. The correct frame of reference is the feasible region, not the unrestricted simplex.

---

## 62. Integrated mixture-process workflow

### Stage A: combined design

```r
sp <- mix_spec(c("A", "B", "C"))

mp <- mix_design(
  sp,
  type = "mixture_process",
  base_type = "simplex_centroid",
  process = list(
    temperature = c(20, 30, 40),
    time = c(1, 2, 3)
  ),
  fraction = 0.70,
  fraction_method = "D",
  fraction_model = "scheffe_quadratic",
  fraction_process_order = 2,
  fraction_mixture_process = TRUE,
  seed = 6201
)
```

### Stage B: response

```r
set.seed(6202)

mp$data$response <- with(
  mp$data,
  5 * A + 7 * B + 6 * C +
  2 * A * B -
  2 * A * C +
  0.04 * temperature -
  0.20 * time +
  0.03 * B * temperature +
  rnorm(nrow(mp$data), 0, 0.20)
)
```

### Stage C: fit

```r
fit_mp <- mix_fit(
  "response",
  mp,
  model = "scheffe_quadratic",
  process = c("temperature", "time"),
  process_order = 2,
  mixture_process = TRUE
)
```

### Stage D: diagnose

```r
mix_diagnose(fit_mp)
mix_collinearity(fit_mp)
```

### Stage E: prediction at declared process settings

```r
new_mp <- data.frame(
  A = c(0.25, 0.40),
  B = c(0.50, 0.30),
  C = c(0.25, 0.30),
  temperature = c(30, 30),
  time = c(2, 2)
)

mix_predict(
  fit_mp,
  new_mp,
  interval = "confidence"
)
```

### Interpretation template

Separate composition effects, process effects, and mixture-process interactions in the narrative. A formulation that is optimal at one processing temperature may not remain optimal when the process changes.

---

## 63. Integrated multiresponse workflow

### Stage A: fit all responses

```r
dm <- mix_demo_data(
  "multiresponse",
  n_rep = 3,
  seed = 6301
)

mf <- mix_multi_fit(
  c("quality", "cost", "stability"),
  dm,
  sp,
  model = "scheffe_quadratic"
)
```

### Stage B: inspect each model

```r
lapply(
  mf$fits,
  mix_diagnose
)
```

### Stage C: descriptive biplot

```r
bp <- mix_biplot(
  mf,
  resolution = 15
)

bp$plot
```

### Stage D: define decision goals

```r
goals <- c(
  quality = "maximize",
  cost = "minimize",
  stability = "maximize"
)

settings <- list(
  quality = list(
    low = quantile(dm$quality, 0.10),
    high = quantile(dm$quality, 0.90)
  ),
  cost = list(
    low = quantile(dm$cost, 0.10),
    high = quantile(dm$cost, 0.90)
  ),
  stability = list(
    low = quantile(dm$stability, 0.10),
    high = quantile(dm$stability, 0.90)
  )
)
```

### Stage E: optimize

```r
mo <- mix_multiopt(
  mf,
  goals,
  settings,
  response_weights = c(
    quality = 2,
    cost = 1,
    stability = 2
  ),
  seed = 6302
)

mo
```

### Stage F: communicate trade-offs

```r
mix_plot(
  mo,
  type = "pareto"
)

mix_plot(
  mo,
  type = "desirability"
)
```

### Interpretation template

Report both the selected compromise and the Pareto alternatives. Explain why the response weights and desirability limits were chosen.

---

## 64. Integrated sequential expensive-experiment workflow

This workflow is appropriate when each experimental run is expensive.

### Stage A: initial design

```r
sp_exp <- mix_spec(
  c("A", "B", "C"),
  lower = c(0.05, 0.05, 0.05)
)

d0 <- mix_optimal_design(
  sp_exp,
  model = "scheffe_quadratic",
  runs = 8,
  criterion = "I",
  algorithm = "hybrid",
  seed = 6401
)
```

### Stage B: evaluate before collecting data

```r
mix_design_eval(
  d0,
  model = "scheffe_quadratic"
)
```

### Stage C: after the first data stage, fit and diagnose

```r
# Replace this with the observed response in a real experiment.
set.seed(6402)

stage1 <- d0$data

stage1$response <- with(
  stage1,
  5 * A + 6 * B + 7 * C +
  2 * A * B -
  2 * A * C +
  rnorm(nrow(stage1), 0, 0.15)
)

f0 <- mix_fit(
  "response",
  stage1,
  d0,
  "scheffe_quadratic"
)

mix_diagnose(f0)
```

### Stage D: augment for design precision

```r
d1 <- mix_augment(
  d0,
  n_new = 3,
  model = "scheffe_quadratic",
  objective = "I",
  seed = 6403
)
```

### Stage E: alternatively, focus around the current optimum

```r
d2 <- mix_augment(
  d0,
  n_new = 3,
  model = "scheffe_quadratic",
  objective = "optimum_uncertainty",
  fit = f0,
  seed = 6404
)
```

### Stage F: optional Gaussian-process sequential search

```r
if (FALSE) {
  bo <- mix_bo(
    stage1,
    response = "response",
    spec = sp_exp,
    goal = "maximize",
    iterations = 5,
    seed = 6405
  )

  bo
}
```

### Interpretation template

This is not a competition between classical optimal design and Bayesian optimization.

The design route is preferable when the experiment can be planned in batches and the assumed response model is appropriate. Gaussian-process sequential optimization is more attractive when each new result can inform the next run and the goal is to locate good formulations efficiently.

---

# Part VIII. Teaching and interactive exploration

## 65. Shiny interface

```r
if (requireNamespace("shiny", quietly = TRUE)) {
  run_mixrsm_app()
}
```

The Shiny application is intended as a teaching and exploratory interface. It does not replace the R objects or hide the statistical code.

Recommended use:

1. define the mixture;
2. visualize the feasible region;
3. generate a classical or optimal design;
4. inspect the model basis;
5. fit the response surface;
6. inspect diagnostics;
7. display ternary contours;
8. compare the exact optimum and near-optimal region;
9. export the corresponding R workflow.

---

## 66. Suggested classroom progression

**Class 1:** fixed-sum geometry, simplex, and feasible regions.  
**Class 2:** simplex-lattice, simplex-centroid, axial, and extreme-vertices designs.  
**Class 3:** Scheffé bases and coefficient meaning.  
**Class 4:** replication, pure error, lack of fit, and diagnostics.  
**Class 5:** component effects and ternary response surfaces.  
**Class 6:** constrained regions and pseudocomponents.  
**Class 7:** optimal design, prediction variance, FDS, and VDG.  
**Class 8:** mixture-process experiments, blocking, and split plots.  
**Class 9:** multiple responses, desirability, Pareto solutions, and uncertainty of the optimum.  
**Class 10:** sequential design, Bayesian extensions, interactive graphics, reporting, and reproducibility.

The sequence deliberately introduces geometry before optimization and diagnostics before decision-making.

---

## 67. Agronomic examples by module

| Agronomic problem | Mixture components | Additional structure | Useful starting functions |
|:--|:--|:--|:--|
| Potting substrate | compost, biochar, mineral carrier | lower/upper bounds | `mix_spec()`, `mix_vertices()`, `mix_optimal_design()` |
| Fertilizer blend | N-source A, N-source B, micronutrient carrier | nutrient-ratio restrictions | `mix_spec()`, `mix_pseudocomponents()`, `mix_fit()` |
| Seed coating | polymer, mineral filler, biological agent | process temperature | `mix_design(type="mixture_process")`, `mix_fit()` |
| Foliar biostimulant | amino acids, algae extract, humic fraction | spray volume or concentration | `mix_multi_fit()`, `mix_multiopt()` |
| Animal feed | protein, energy, fiber fractions | cost response | `mix_multiopt()`, `mix_plot(type="pareto")` |
| Pesticide formulation | active A, active B, adjuvant | efficacy and crop injury | `mix_multi_fit()`, `mix_multiopt()` |
| Nutrient solution | nitrate, ammonium, organic N source | EC or pH process variable | `mix_design(type="mixture_process")`, `mix_fit_gls()` when justified |
| Soil amendment | lime source, gypsum, organic amendment | field block | `mix_block_design()`, `mix_fit_mixed()` |
| Controlled-release granule | coating polymer fractions | temperature and curing time | `mix_fractionate_process()`, `mix_optimal_design()` |
| Expensive phenotyping formulation | three ingredients | sequential response acquisition | `mix_augment()`, `mix_bo()` |

These are workflow examples. They do not imply that one statistical model is automatically correct for every experiment in the listed domain.

---

# Part IX. Common mistakes and the corresponding functions

## 68. Treating mixture components as independent ordinary factors

The fixed-sum constraint makes ordinary factorial interpretation invalid.

Use:

```r
mix_spec()
mix_basis()
mix_effects()
```

---

## 69. Fitting a model before defining the feasible region

The response surface is scientifically meaningful only over the formulations that can actually be prepared.

Use:

```r
mix_spec()
mix_vertices()
mix_region()
```

---

## 70. Using a classical simplex design inside a severely constrained region by habit

A classical design may collapse to a poor subset after constraints are applied.

Use:

```r
mix_design(..., type = "extreme_vertices")
mix_optimal_design()
mix_design_eval()
```

---

## 71. Choosing D-optimality for every experiment

D-optimality is centered on parameter precision. Prediction-oriented work may be better served by I or G criteria.

Use:

```r
mix_optimal_design(
  criterion = "I"
)

mix_design_eval()
```

---

## 72. Reporting a high \(R^2\) without pure error and lack of fit

Replicated blends allow a more direct model-adequacy check.

Use:

```r
mix_anova()
mix_diagnose()
```

---

## 73. Interpreting a Scheffé coefficient as an ordinary slope

A coefficient belongs to a constrained blending basis.

Use:

```r
mix_effects(
  type = "cox"
)

mix_effects(
  type = "substitution"
)
```

---

## 74. Ignoring ill-conditioning in a narrow constrained region

Parameter estimates can become unstable even when the fitted surface appears smooth.

Use:

```r
mix_collinearity()
mix_design_eval()
mix_augment()
```

---

## 75. Reducing a model only by p-values

Use several sources of evidence.

```r
mix_reduce()
mix_compare()
mix_diagnose()
```

Preserve hierarchy and scientific meaning.

---

## 76. Optimizing before checking the model

An optimum is a property of the fitted response surface. A poor model can have a precisely computed but scientifically meaningless optimum.

Use:

```r
mix_diagnose()
mix_anova()
mix_optimize()
```

in that order.

---

## 77. Reporting only one exact optimum

Use:

```r
mix_optimize()
mix_optimum_ci()
```

and inspect the near-optimal region.

---

## 78. Ignoring the experimental hierarchy in a split plot

Use:

```r
mix_design(
  type = "split_plot"
)

mix_fit_mixed()
```

when a whole-plot structure is present.

---

## 79. Calling a multiresponse desirability solution objectively best

Desirability depends on declared goals, limits, and weights.

Use:

```r
mix_multiopt()
mix_plot(type = "pareto")
```

to communicate the assumptions and alternatives.

---

## 80. Using Bayesian optimization when all runs can be planned cheaply in advance

Use classical or optimal design first:

```r
mix_optimal_design()
mix_augment()
```

Reserve:

```r
mix_bo()
```

for a genuinely sequential expensive-experiment setting.

---

## 81. Using interactive graphics as the only record of the result

Use numeric objects and static publication outputs as the authoritative record.

```r
mix_predict()
mix_plot(file = "figure.pdf")
mix_report()
```

---

# Part X. Compact function-selection guide

| Scientific question | Start with | Escalate when needed |
|:--|:--|:--|
| What is the admissible formulation region? | `mix_spec()` | `mix_region()`, `mix_vertices()` |
| Can lower or upper bounds be simplified geometrically? | `mix_pseudocomponents()` | `mix_reparameterize()` |
| Which standard design should I start with? | `mix_design()` | `mix_design_eval()` |
| Is the region irregular? | `mix_vertices()` | `mix_optimal_design()` |
| Do I need a major/minor component design? | `mix_multiple_lattice()` | `mix_design_eval()` |
| Are components grouped into categories? | `mix_categorized_design()` | inspect `METHOD_GATES.md` for historical transformations not claimed by the package |
| Do I need blocks? | `mix_block_design()` | `mix_fit_mixed()` |
| Do I have two structured process factors? | `mix_latin_process_design()` | mixture-process model |
| Is the crossed process design too large? | `mix_fractionate_process()` | `mix_optimal_design()` |
| What model basis am I fitting? | `mix_basis()` | alternative models or `mix_gbm_term()` |
| Is a Scheffé quadratic adequate? | `mix_fit()` | `mix_anova()`, `mix_compare()` |
| Are errors heterogeneous or correlated? | `mix_fit_gls()` | mixed model if hierarchy is also present |
| Is there an experimental random effect? | `mix_fit_mixed()` | Bayesian hierarchical fit |
| Do I need posterior inference? | `mix_fit_bayes()` | report priors and posterior diagnostics |
| Is there pure error/lack of fit information? | `mix_anova()` | model revision |
| Is the model numerically unstable? | `mix_diagnose()` | `mix_collinearity()`, design augmentation |
| Should I reduce the model? | `mix_reduce()` | compare prediction and hierarchy |
| Which components deserve screening attention? | `mix_screen()` | `mix_effects()` |
| Does the response change regime across a component threshold? | `mix_segmented_fit()` | `mix_predict_segmented()` |
| How does a component change the fitted response? | `mix_effects()` | Cox, Piepel, substitution, directional paths |
| How do I predict a new blend? | `mix_predict()` | confidence or prediction intervals |
| Which design criterion should I use? | `mix_optimal_design()` | compare D/A/I/G/E/T/Alias/Bayesian criteria |
| How do I compare designs? | `mix_design_eval()` | FDS, VDG, IMSE, rotatability |
| What if the assumed model is uncertain? | `mix_imse()` | model-robust/Bayesian optimal design |
| Should I add runs to an existing experiment? | `mix_augment()` | optimum-focused augmentation |
| What is the best feasible composition? | `mix_optimize()` | `mix_optimum_ci()` |
| How uncertain is the optimum location? | `mix_optimum_ci()` | inspect joint optimum cloud |
| I have several responses. What next? | `mix_multi_fit()` | `mix_multiopt()`, `mix_biplot()` |
| I need to expose response trade-offs. | `mix_multiopt()` | Pareto plot |
| Experiments are extremely expensive and sequential. | `mix_bo()` | only with GP backend and explicit validation |
| I need a scientific figure. | `mix_plot()` | static vector or optional Plotly |
| I need a reproducible analysis report. | `mix_report()` | Markdown, HTML, DOCX, PDF |
| I need to know what is implemented. | `mix_capabilities()` | filter by module or tier |
| I need workflow provenance. | `mix_audit_trail()` | archive session information |
| I need an interactive teaching interface. | `run_mixrsm_app()` | always retain the underlying R code |

---

# Part XI. Minimum reporting checklist

Before a mixture result leaves the analysis notebook, thesis, report, or manuscript, document:

- [ ] all mixture components and their units;
- [ ] mixture total;
- [ ] lower and upper bounds;
- [ ] every additional linear restriction;
- [ ] whether the region is full simplex, polytope, spherical, ellipsoidal, or cuboidal;
- [ ] experimental design type;
- [ ] number of unique blends and number of replicates;
- [ ] randomization and blocking;
- [ ] whole-plot and subplot structure when applicable;
- [ ] process-variable levels for mixture-process experiments;
- [ ] intended model family and degree before data collection, when possible;
- [ ] fitted model basis;
- [ ] response distribution and link if non-Gaussian;
- [ ] residual covariance structure if GLS is used;
- [ ] random-effect structure if a mixed model is used;
- [ ] prior specification if a Bayesian model is used;
- [ ] rank and condition diagnostics;
- [ ] leverage and influential blends;
- [ ] pure error and lack of fit when replicates permit;
- [ ] model comparison or reduction rule;
- [ ] component-effect path used for interpretation;
- [ ] prediction-variance diagnostics for design evaluation;
- [ ] optimality criterion and algorithm;
- [ ] random seed for stochastic design or optimization;
- [ ] design-search settings such as candidate size, population, generations, or starts;
- [ ] optimum goal: maximize, minimize, or target;
- [ ] exact optimum composition;
- [ ] uncertainty interval or joint optimum cloud;
- [ ] near-optimal region or practical alternatives;
- [ ] multiresponse goals, desirability limits, and weights;
- [ ] Pareto alternatives when objectives conflict;
- [ ] observed data or design points shown with fitted surfaces when possible;
- [ ] vector or high-resolution figure settings;
- [ ] R and package versions;
- [ ] optional-backend versions;
- [ ] audit trail and session information;
- [ ] limits on extrapolation;
- [ ] whether every advanced capability reported in the manuscript has passed the required local validation gate.

---

# Part XII. Suggested next vignettes

After this tutorial, use the focused package material in approximately this order:

1. `01-getting-started.Rmd`
2. `02-mixture-geometry.Rmd`
3. `03-simplex-designs.Rmd`
4. `04-constrained-regions.Rmd`
5. `05-scheffe-models.Rmd`
6. `07-model-diagnostics.Rmd`
7. `08-component-effects.Rmd`
8. `09-optimal-design.Rmd`
9. `13-optimization.Rmd`
10. `14-optimum-uncertainty.Rmd`
11. `10-mixture-process.Rmd`
12. `11-blocks-and-splitplots.Rmd`
13. `12-multiple-responses.Rmd`
14. `06-alternative-mixture-models.Rmd`
15. `17-sequential-design.Rmd`
16. `18-modern-models.Rmd`
17. `15-static-graphics.Rmd`
18. `16-interactive-graphics.Rmd`
19. `19-teaching-workflows.Rmd`
20. `20-state-of-the-art.Rmd`
21. `21-validation-and-benchmarks.Rmd`
22. `22-reproducibility.Rmd`

The state-of-the-art and validation vignettes should be revisited before publication because package ecosystems, optional backend versions, and validation status can change.

---

# Appendix A. Complete exported-function registry

The following table is generated from the actual `NAMESPACE` and Rd titles in the `0.1.0.9000` source snapshot used for this tutorial.

| # | Function | Primary purpose |
|--:|:--|:--|
| 1 | `mix_pseudocomponents()` | Convert between original proportions and lower/upper pseudocomponents |
| 2 | `mix_reparameterize()` | Reparameterize an equivalent Scheffe model with an intercept and slack component |
| 3 | `mix_collinearity()` | Diagnose collinearity and estimability in mixture model matrices |
| 4 | `mix_reduce()` | Audited hierarchical model reduction for mixture response surfaces |
| 5 | `mix_screen()` | Screen component directional effects with uncertainty |
| 6 | `mix_fit_gls()` | Fit weighted/generalized least-squares mixture models through nlme |
| 7 | `mix_segmented_fit()` | Fit a two-region segmented mixture model |
| 8 | `mix_predict_segmented()` | Predict from a segmented mixture model |
| 9 | `mix_biplot()` | Multiresponse prediction biplot over the feasible mixture region |
| 10 | `mix_moments()` | Compute moments over a simplex or approximate moments over a constrained region |
| 11 | `mix_rotatability()` | Assess approximate rotatability through radial prediction-variance dispersion |
| 12 | `mix_basis()` | Build a mixture-model basis matrix |
| 13 | `mix_bo()` | Gaussian-process Bayesian optimization over a mixture region |
| 14 | `mix_capabilities()` | Inspect the package capability registry |
| 15 | `mix_audit_trail()` | Extract an auditable trail from a mixRSMflow object |
| 16 | `mix_demo_data()` | Generate reproducible pedagogical mixture datasets |
| 17 | `mix_multiple_lattice()` | Construct multiple-lattice designs for major and minor component groups |
| 18 | `mix_categorized_design()` | Construct categorized-component or mixture-of-mixtures designs |
| 19 | `mix_block_design()` | Allocate a mixture design to approximately orthogonal balanced blocks |
| 20 | `mix_latin_process_design()` | Generate a Latin-square crossed mixture-process design |
| 21 | `mix_fractionate_process()` | Model-based fractionation of crossed mixture-process designs |
| 22 | `mix_design()` | Generate classical and mixture-process designs |
| 23 | `mix_fit()` | Fit classical and generalized mixture response-surface models |
| 24 | `mix_fit_mixed()` | Fit a mixed-effects mixture model through lme4 |
| 25 | `mix_fit_bayes()` | Fit a Bayesian mixture model through brms |
| 26 | `mix_anova()` | ANOVA and pure-error/lack-of-fit decomposition for mixture models |
| 27 | `mix_diagnose()` | Diagnose a fitted mixture model |
| 28 | `mix_compare()` | Compare fitted mixture models without selecting solely by one metric |
| 29 | `mix_gbm_term()` | Define one general blending model term |
| 30 | `mix_imse()` | Integrated mean-square prediction error under an explicit larger model |
| 31 | `mix_multi_fit()` | Fit several responses using a shared mixture specification |
| 32 | `mix_multiopt()` | Multiresponse desirability, constraints, and Pareto optimization |
| 33 | `mix_optimal_design()` | Construct exact optimal mixture designs |
| 34 | `mix_design_eval()` | Evaluate information and prediction-variance properties of a mixture design |
| 35 | `mix_augment()` | Augment an existing design according to an information objective |
| 36 | `mix_optimize()` | Optimize a fitted mixture response surface under exact mixture constraints |
| 37 | `mix_optimum_ci()` | Quantify uncertainty in the location of the optimum |
| 38 | `mix_plot()` | Unified static and interactive plotting for mixture workflows |
| 39 | `mix_predict()` | Predict from a fitted mixture model with uncertainty |
| 40 | `mix_effects()` | Compute interpretable component effects and trace paths |
| 41 | `mix_report()` | Create a reproducible scientific mixture-analysis report |
| 42 | `run_mixrsm_app()` | Launch the interactive mixRSMflow teaching and analysis application |
| 43 | `mix_spec()` | Define a mixture specification |
| 44 | `mix_region()` | Define a curved or independent-coordinate region of interest |
| 45 | `mix_transform()` | Transform mixture coordinates to independent orthonormal coordinates |
| 46 | `mix_inverse_transform()` | Transform independent coordinates back to mixture coordinates |
| 47 | `mix_vertices()` | Enumerate extreme vertices of a linearly constrained mixture region |

The registry above lists exported user-facing functions. S3 methods such as `predict.mix_fit()`, `summary.mix_fit()`, `coef.mix_fit()`, and `plot.mix_fit()` are available through the corresponding generic functions and are not duplicated as separate user-facing entries here.

---

# Appendix B. Complete capability registry

The capability table below is generated from `R/capabilities.R` in the same source snapshot. The status reflects the package source at the time of construction. It must not be confused with completed runtime validation.

| # | Capability | Module | Validation tier | Implementation |
|--:|:--|:--|:--|:--|
| 1 | `simplex_lattice` | design | Tier 1 | `native` |
| 2 | `simplex_centroid` | design | Tier 1 | `native` |
| 3 | `axial` | design | Tier 1 | `native` |
| 4 | `augmented_centroid` | design | Tier 1 | `native` |
| 5 | `symmetric_simplex` | design | Tier 1 | `native` |
| 6 | `extreme_vertices` | design | Tier 1 | `native` |
| 7 | `multiple_lattice` | design | Tier 1 | `native` |
| 8 | `categorized_components` | design | Tier 1 | `native` |
| 9 | `rotatable_independent_coordinates` | design | Tier 1 | `native` |
| 10 | `mixture_process` | design | Tier 1 | `native` |
| 11 | `mixture_amount` | design | Tier 1 | `native` |
| 12 | `split_plot_design` | design | Tier 2 | `native` |
| 13 | `latin_square_process` | design | Tier 2 | `native` |
| 14 | `block_balancing` | design | Tier 2 | `native` |
| 15 | `scheffe_linear` | models | Tier 1 | `native` |
| 16 | `scheffe_quadratic` | models | Tier 1 | `native` |
| 17 | `scheffe_special_cubic` | models | Tier 1 | `native` |
| 18 | `scheffe_full_cubic` | models | Tier 1 | `native` |
| 19 | `scheffe_special_quartic` | models | Tier 1 | `native` |
| 20 | `scheffe_full_quartic` | models | Tier 1 | `native` |
| 21 | `slack_variable` | models | Tier 1 | `native` |
| 22 | `inverse_terms` | models | Tier 2 | `native` |
| 23 | `ratio_models` | models | Tier 2 | `native` |
| 24 | `cox_parameterization` | models | Tier 2 | `native` |
| 25 | `logcontrast` | models | Tier 2 | `native` |
| 26 | `becker_general_blending` | models | Tier 2 | `native` |
| 27 | `general_blending_model` | models | Tier 2 | `native` |
| 28 | `additive_blending` | models | Tier 2 | `native` |
| 29 | `kronecker_quadratic` | models | Tier 2 | `native` |
| 30 | `gaussian_fit` | fit | Tier 1 | `native` |
| 31 | `glm_fit` | fit | Tier 1 | `native` |
| 32 | `gls_fit` | fit | Tier 2 | `optional:nlme` |
| 33 | `mixed_effects` | fit | Tier 2 | `optional:lme4` |
| 34 | `bayesian_fit` | fit | Tier 2 | `optional:brms` |
| 35 | `segmented_fit` | fit | Tier 2 | `native` |
| 36 | `pure_error_lack_of_fit` | inference | Tier 1 | `native` |
| 37 | `integrated_mse` | inference | Tier 2 | `native` |
| 38 | `model_reduction` | inference | Tier 2 | `native` |
| 39 | `component_screening` | inference | Tier 1 | `native` |
| 40 | `cox_effects` | inference | Tier 1 | `native` |
| 41 | `piepel_effects` | inference | Tier 1 | `native` |
| 42 | `collinearity` | inference | Tier 1 | `native` |
| 43 | `D_optimal` | optimal_design | Tier 1 | `native` |
| 44 | `A_optimal` | optimal_design | Tier 1 | `native` |
| 45 | `I_optimal` | optimal_design | Tier 1 | `native` |
| 46 | `G_optimal` | optimal_design | Tier 1 | `native` |
| 47 | `E_optimal` | optimal_design | Tier 1 | `native` |
| 48 | `T_optimal` | optimal_design | Tier 2 | `native` |
| 49 | `alias_optimal` | optimal_design | Tier 1 | `native` |
| 50 | `bayesian_D` | optimal_design | Tier 2 | `native` |
| 51 | `bayesian_I` | optimal_design | Tier 2 | `native` |
| 52 | `model_robust_optimal` | optimal_design | Tier 2 | `native` |
| 53 | `genetic_algorithm_design` | optimal_design | Tier 1 | `native` |
| 54 | `FDS` | optimal_design | Tier 1 | `native` |
| 55 | `VDG` | optimal_design | Tier 1 | `native` |
| 56 | `rotatability_diagnostic` | optimal_design | Tier 1 | `native` |
| 57 | `sequential_augmentation` | optimal_design | Tier 1 | `native` |
| 58 | `bounded_optimization` | optimization | Tier 1 | `native` |
| 59 | `GA_optimization` | optimization | Tier 1 | `native` |
| 60 | `optimum_uncertainty` | optimization | Tier 1 | `native` |
| 61 | `near_optimal_region` | optimization | Tier 1 | `native` |
| 62 | `multiresponse_desirability` | multiresponse | Tier 1 | `native` |
| 63 | `pareto` | multiresponse | Tier 1 | `native` |
| 64 | `biplot` | multiresponse | Tier 1 | `native` |
| 65 | `bayesian_optimization` | modern | Tier 3 | `optional:DiceKriging` |
| 66 | `vector_3d_surface` | graphics | Tier 1 | `native` |
| 67 | `ternary_contour` | graphics | Tier 1 | `native` |
| 68 | `interactive_plotly` | graphics | Tier 1 | `optional:plotly` |
| 69 | `scientific_report` | reporting | Tier 1 | `native` |
| 70 | `shiny_interface` | reporting | Tier 2 | `optional:shiny` |
| 71 | `simplex_moments` | theory | Tier 1 | `native` |

---

# Appendix C. A single starter script

The following script is intentionally compact. It is suitable as the first file a new user creates after installing `mixRSMflow`.

```r
library(mixRSMflow)

# 1. Inspect package capabilities.
mix_capabilities()

# 2. Define the mixture space.
sp <- mix_spec(
  components = c("A", "B", "C"),
  lower = c(0.05, 0.05, 0.05),
  upper = c(0.90, 0.90, 0.90)
)

# 3. Inspect the feasible vertices.
mix_vertices(sp)

# 4. Generate a classical design.
des <- mix_design(
  sp,
  type = "augmented_centroid",
  seed = 20260813
)

print(des)
mix_plot(des)

# 5. Evaluate the design for the intended model.
dev <- mix_design_eval(
  des,
  model = "scheffe_quadratic",
  resolution = 15
)

print(dev)
mix_plot(dev, "fds")

# 6. Load reproducible teaching data.
dat <- mix_demo_data(
  "mixture",
  n_rep = 3,
  seed = 20260813
)

# 7. Fit a Scheffé quadratic surface.
fit <- mix_fit(
  response = "response",
  data = dat,
  spec = sp,
  model = "scheffe_quadratic"
)

summary(fit)

# 8. Check pure error and lack of fit.
mix_anova(fit)

# 9. Diagnose the fitted surface.
diag <- mix_diagnose(fit)
print(diag)

mix_collinearity(fit)

mix_plot(
  fit,
  type = "residuals"
)

# 10. Interpret one component through a feasible path.
eff <- mix_effects(
  fit,
  type = "cox",
  component = "A",
  n = 51
)

print(eff)
mix_plot(eff)

# 11. Display the fitted response surface.
mix_plot(
  fit,
  type = "ternary_contour",
  resolution = 40
)

# 12. Find the bounded optimum.
opt <- mix_optimize(
  fit,
  goal = "maximize",
  method = "hybrid",
  grid_resolution = 30,
  random_candidates = 5000,
  seed = 20260813
)

print(opt)
mix_plot(opt)

# 13. Quantify uncertainty in optimum location.
ci <- mix_optimum_ci(
  opt,
  method = "parametric",
  B = 500,
  level = 0.95,
  grid_resolution = 20,
  seed = 20260814
)

print(ci)
mix_plot(ci)

# 14. Generate an auditable report.
mix_report(
  list(
    fit = fit,
    design = des,
    optimum = opt
  ),
  file = "starter_mixRSMflow_report.md",
  format = "markdown",
  title = "Starter mixRSMflow analysis"
)

# 15. Preserve the recorded workflow decisions.
mix_audit_trail(fit)
```

---

# Final perspective

A mixture workflow is strongest when the fitted surface can be explained as a consequence of the formulation space and the experimental design.

For a beginner, the recommended sequence is:

**mixture specification -> feasible region -> classical design -> design evaluation -> Scheffé fit -> pure error/lack of fit -> diagnostics -> component effects -> prediction -> bounded optimum -> uncertainty -> report.**

For an advanced user, the sequence becomes:

**mixture specification -> constrained geometry -> optimal or structured design -> model basis -> covariance or hierarchical structure if required -> diagnostics and conditioning -> model uncertainty -> multiple responses or alternative blending models -> sequential augmentation -> optimum uncertainty -> interactive exploration and publication output.**

The exported functions are therefore not unrelated tools. They form a single analysis grammar centered on the geometry of mixtures.

The purpose of `mixRSMflow` is to keep that grammar visible while allowing an analyst to move from a textbook three-component simplex to constrained optimal design, mixture-process experiments, multiple responses, uncertainty-aware optimization, structured Gaussian errors, mixed effects, Bayesian estimation, and Gaussian-process sequential experimentation without disconnecting the final recommendation from the region and design that generated the data.

The final scientific question is never merely, "Which composition maximizes the fitted equation?"

It is:

**Within the experimentally supported and scientifically feasible mixture region, which formulations perform well, how certain are we about their relative performance, how sensitive are the conclusions to model and design assumptions, and what additional experiment would most efficiently reduce the remaining uncertainty?**
