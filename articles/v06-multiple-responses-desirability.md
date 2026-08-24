# Multiple responses, desirability and Pareto

## mixRSMflow: Multiple Responses, Desirability, and Pareto Trade-Offs

**Extended instructional vignette**  
**Package:** `mixRSMflow`  
**Version targeted:** `0.1.0.9000`  
**Extended vignette:** 28  
**Format:** Markdown source only  
**Primary ownership:** multiple-response mixture modeling, descriptive
response biplots, response-specific goals, desirability functions,
response weights, Pareto dominance, compromise solutions, and
transparent decision reporting  
**Companion material:** `12-multiple-responses.Rmd`; Extended Vignette
29 owns uncertainty in a single fitted optimum location

> This document is intentionally supplied as `.md`. Multiple-response
> optimization contains explicit decision assumptions. Numerical
> optimization output should therefore be reported together with the
> goals, limits, and weights that generated it.

> **Scope boundary.** This extended vignette owns the topic named in its
> title. Closely related methods that belong to another extended
> vignette are referenced rather than re-taught. This separation is
> deliberate so that the extended documentation remains deep without
> becoming repetitive.

------------------------------------------------------------------------

### 1. Why several responses change the scientific question

A formulation rarely has only one relevant response. A substrate can
maximize biomass while increasing salinity. A fertilizer can improve
yield while increasing cost or nutrient loss. A pesticide mixture can
increase efficacy while also increasing crop injury. A food formulation
can improve sensory quality while reducing physical stability.

Once responses conflict, the phrase **best mixture** is incomplete. The
decision requires a rule for trading one objective against another.

The central principle is:

**Fit and diagnose each response on its own scientific scale first. Then
make the decision rule explicit.**

`mixRSMflow` separates those stages through
[`mix_multi_fit()`](https://wep69.github.io/mixRSMflow/reference/mix_multi_fit.md)
and
[`mix_multiopt()`](https://wep69.github.io/mixRSMflow/reference/mix_multiopt.md).

------------------------------------------------------------------------

### 2. Learning objectives

After this vignette, the reader should be able to:

1.  fit a common mixture-model specification to several responses;
2.  inspect each response fit separately before multiresponse
    optimization;
3.  explain why a common design does not imply a common optimal model
    degree;
4.  summarize predicted response relationships through
    [`mix_biplot()`](https://wep69.github.io/mixRSMflow/reference/mix_biplot.md);
5.  distinguish descriptive PCA structure from the original scientific
    response scales;
6.  define maximize, minimize, and target-like decision directions
    appropriately;
7.  construct response-specific desirability settings;
8.  explain the weighted geometric-mean desirability function;
9.  conduct sensitivity analyses to response weights and desirability
    limits;
10. identify Pareto-nondominated candidate mixtures;
11. distinguish Pareto membership from a unique preferred solution;
12. communicate trade-offs before imposing subjective weights;
13. report a compromise composition together with alternative
    nondominated solutions;
14. keep response uncertainty separate from decision preference;
15. avoid claiming an objectively optimal mixture when the result
    depends on user-defined priorities.

------------------------------------------------------------------------

### 3. Function map

| Task | Function |
|:---|:---|
| Fit several responses | [`mix_multi_fit()`](https://wep69.github.io/mixRSMflow/reference/mix_multi_fit.md) |
| Access individual fits | `object$fits` |
| Descriptive response biplot | [`mix_biplot()`](https://wep69.github.io/mixRSMflow/reference/mix_biplot.md) |
| Multiresponse optimization | [`mix_multiopt()`](https://wep69.github.io/mixRSMflow/reference/mix_multiopt.md) |
| Pareto visualization | `mix_plot(type="pareto")` |
| Desirability visualization | `mix_plot(type="desirability")` |
| Diagnose each response | [`mix_diagnose()`](https://wep69.github.io/mixRSMflow/reference/mix_diagnose.md) |
| Predict each response | [`mix_predict()`](https://wep69.github.io/mixRSMflow/reference/mix_predict.md) |
| Single-response optimum uncertainty | Extended Vignette 29 |

------------------------------------------------------------------------

## Part I. Teaching dataset and scientific roles

### 4. Load the multiresponse teaching data

``` r

library(mixRSMflow)

sp <- mix_spec(c("A", "B", "C"))

d <- mix_demo_data(
  "multiresponse",
  n_rep = 3,
  seed = 28001
)

head(d)
```

The simulated dataset contains responses such as:

- `quality`;
- `cost`;
- `stability`.

They are teaching variables, not real formulation measurements.

------------------------------------------------------------------------

### 5. Define the scientific direction before optimization

A plausible decision statement might be:

| Response  | Scientific direction |
|:----------|:---------------------|
| quality   | maximize             |
| cost      | minimize             |
| stability | maximize             |

This table should exist before the optimization call.

For a real experiment, add units and meaningful limits. For example:

- quality score, dimensionless;
- formulation cost, currency per kg;
- stability, percent retained after storage.

------------------------------------------------------------------------

## Part II. Fit each response first

### 6. Common fit call

``` r

mf <- mix_multi_fit(
  responses = c("quality", "cost", "stability"),
  data = d,
  spec = sp,
  model = "scheffe_quadratic"
)

mf
```

The object stores an individual `mix_fit` for each response.

``` r

names(mf$fits)
```

------------------------------------------------------------------------

### 7. Diagnose the quality model

``` r

mix_diagnose(mf$fits$quality)
mix_anova(mf$fits$quality)
```

Inspect the response surface:

``` r

mix_plot(
  mf$fits$quality,
  type = "ternary_contour"
)
```

------------------------------------------------------------------------

### 8. Diagnose the cost model

``` r

mix_diagnose(mf$fits$cost)
mix_anova(mf$fits$cost)
```

A cost model may be nearly linear even when the biological response
requires curvature. The fact that
[`mix_multi_fit()`](https://wep69.github.io/mixRSMflow/reference/mix_multi_fit.md)
can apply the same model family to all responses is a convenience, not a
scientific requirement to keep them identical.

For a real analysis, consider fitting each response with the most
defensible basis and then assembling the decision workflow on a common
prediction grid.

------------------------------------------------------------------------

### 9. Diagnose the stability model

``` r

mix_diagnose(mf$fits$stability)
mix_anova(mf$fits$stability)
```

#### Rule

**Multiresponse optimization should not be used to hide a poorly fitted
individual response.**

If the cost response has severe lack of fit, the overall desirability
score built from that cost prediction is not trustworthy merely because
the other models are adequate.

------------------------------------------------------------------------

## Part III. Descriptive multivariate view

### 10. Biplot of predicted response patterns

``` r

bp <- mix_biplot(
  mf,
  resolution = 20,
  scale = TRUE,
  plot = TRUE
)

bp$plot
```

The function predicts responses over a common feasible grid and applies
PCA to the response matrix.

#### 10.1 What the biplot is useful for

It can reveal:

- responses that vary in similar directions across the mixture region;
- responses that oppose one another;
- regions associated with particular response profiles;
- dimensional structure in the set of predicted response surfaces.

#### 10.2 What the biplot is not

It is not automatically an optimization criterion.

Do not maximize PC1 simply because it explains the most variation unless
PC1 itself is the scientifically declared target.

The response axes in the decision problem remain `quality`, `cost`, and
`stability`.

------------------------------------------------------------------------

## Part IV. Individual desirability

### 11. Why rescale responses?

Responses can have different units and directions. Desirability maps
each response to a unitless scale between 0 and 1.

A typical maximizing desirability assigns:

- 0 below an unacceptable lower limit;
- increasing desirability between low and high;
- 1 at or above the high target.

For minimization, the direction reverses.

------------------------------------------------------------------------

### 12. Build transparent settings from teaching data

``` r

settings <- list(
  quality = list(
    low = min(d$quality),
    high = max(d$quality)
  ),
  cost = list(
    low = min(d$cost),
    high = max(d$cost)
  ),
  stability = list(
    low = min(d$stability),
    high = max(d$stability)
  )
)
```

For teaching this uses the observed range. In a real decision analysis,
scientifically or operationally meaningful limits are preferable.

Examples:

- minimum acceptable germination;
- maximum permissible salinity;
- target cost ceiling;
- desired shelf-life threshold.

Do not let observed extrema silently define acceptability when
subject-matter thresholds exist.

------------------------------------------------------------------------

## Part V. Overall desirability

### 13. Define the goals

``` r

goals <- c(
  quality = "maximize",
  cost = "minimize",
  stability = "maximize"
)
```

Use equal response weights initially:

``` r

mo_equal <- mix_multiopt(
  mf,
  goals = goals,
  settings = settings,
  response_weights = c(
    quality = 1,
    cost = 1,
    stability = 1
  ),
  resolution = 30,
  random_candidates = 5000,
  seed = 28002
)

mo_equal
```

------------------------------------------------------------------------

### 14. Weighted geometric mean

The combined desirability is conceptually

``` math
D=
\left(
\prod_{r=1}^{R}d_r^{w_r}
\right)^{1/\sum_r w_r}.
```

This matters because any response with desirability zero can drive the
overall desirability to zero.

#### Scientific consequence

Desirability is not an empirical response. It is a decision function
constructed from the fitted responses and the analyst’s declared
preferences.

------------------------------------------------------------------------

### 15. Give biological performance more weight

``` r

mo_bio <- mix_multiopt(
  mf,
  goals = goals,
  settings = settings,
  response_weights = c(
    quality = 2,
    cost = 1,
    stability = 2
  ),
  resolution = 30,
  random_candidates = 5000,
  seed = 28003
)
```

Compare the selected compositions from `mo_equal` and `mo_bio`.

If the recommended mixture changes substantially, the decision is
preference-sensitive. That is not a software failure. It is important
decision information.

------------------------------------------------------------------------

## Part VI. Pareto dominance

### 16. Why look at Pareto solutions before weights?

A candidate is Pareto dominated if another candidate is at least as good
in every objective and better in at least one.

The Pareto front contains nondominated candidates.

``` r

mix_plot(
  mo_equal,
  type = "pareto"
)

head(mo_equal$pareto)
```

#### Interpretation

The Pareto set shows the trade-off envelope without first requiring one
unique set of response weights.

For decision meetings, this is often more transparent than presenting
only the final weighted-desirability optimum.

------------------------------------------------------------------------

### 17. A two-response example

Suppose only quality and cost matter. The Pareto front can often be
interpreted directly:

- lower cost usually sacrifices some quality;
- maximum quality may require a high-cost composition;
- an intermediate knee region may provide a practical compromise.

The package identifies nondominated candidates; the scientific team
decides which trade-off is acceptable.

------------------------------------------------------------------------

## Part VII. Constraints in multiresponse decisions

### 18. Hard constraints versus soft desirability

A requirement such as

> salinity must be below a regulatory threshold

is conceptually different from

> lower salinity is preferred.

The first is a hard feasibility requirement. The second is a soft
preference.

Use the `constraints=` mechanism in
[`mix_multiopt()`](https://wep69.github.io/mixRSMflow/reference/mix_multiopt.md)
when a response or decision condition must exclude candidates rather
than merely reduce desirability.

Because constraint specifications are project-specific, document the
exact rule and verify that the retained candidates satisfy it
numerically.

------------------------------------------------------------------------

## Part VIII. Sensitivity analysis

### 19. Weight sensitivity grid

Rather than reporting one arbitrary set of weights, compare several
defensible scenarios.

``` r

weight_sets <- list(
  balanced = c(quality = 1, cost = 1, stability = 1),
  performance = c(quality = 3, cost = 1, stability = 2),
  economy = c(quality = 2, cost = 3, stability = 1)
)

results <- lapply(
  weight_sets,
  function(w) {
    mix_multiopt(
      mf,
      goals,
      settings,
      response_weights = w,
      resolution = 25,
      random_candidates = 3000,
      seed = 28101
    )
  }
)
```

Compare selected compositions.

#### Interpretation

If the same neighborhood remains preferred across reasonable weight
sets, the decision is relatively stable. If the optimum jumps across the
simplex, report the sensitivity rather than hiding it.

------------------------------------------------------------------------

### 20. Limit sensitivity

Desirability depends on the low/high limits as well as weights.

Repeat the analysis using:

- operational minimum/maximum;
- agronomic target thresholds;
- market constraints;
- sensitivity scenarios.

A mixture that looks best only under one narrow arbitrary threshold
deserves caution.

------------------------------------------------------------------------

## Part IX. Agronomic case study: substrate performance, cost, and salinity

### 21. Scientific setup

Mixture:

- compost `C`;
- biochar `B`;
- mineral carrier `M`.

Responses:

- biomass: maximize;
- cost: minimize;
- electrical conductivity: minimize;
- physical stability: maximize.

#### Step 1: define region

``` r

sp_sub <- mix_spec(
  c("C", "B", "M"),
  lower = c(0.20, 0.05, 0.10),
  upper = c(0.70, 0.35, 0.60)
)
```

#### Step 2: generate teaching design

``` r

des <- mix_design(
  sp_sub,
  type = "simplex_lattice",
  degree = 4
)
```

#### Step 3: simulate multiple teaching responses

``` r

set.seed(28201)

dat <- des$data

dat$biomass <- with(
  dat,
  30 + 8 * C + 5 * B + 4 * M + 6 * C * B + rnorm(nrow(dat), 0, 0.8)
)

dat$cost <- with(
  dat,
  100 + 70 * C + 120 * B + 25 * M
)

dat$EC <- with(
  dat,
  0.8 + 0.6 * C + 1.2 * B + 0.3 * M + rnorm(nrow(dat), 0, 0.05)
)

dat$stability <- with(
  dat,
  50 + 5 * C + 2 * B + 8 * M + 5 * B * M + rnorm(nrow(dat), 0, 0.6)
)
```

#### Step 4: fit

``` r

mf_sub <- mix_multi_fit(
  c("biomass", "cost", "EC", "stability"),
  dat,
  sp_sub,
  model = "scheffe_quadratic"
)
```

#### Step 5: diagnose every response

``` r

lapply(mf_sub$fits, mix_diagnose)
```

#### Step 6: define goals

``` r

goals_sub <- c(
  biomass = "maximize",
  cost = "minimize",
  EC = "minimize",
  stability = "maximize"
)
```

#### Step 7: set decision limits

In a real project, use scientific thresholds. For this teaching example:

``` r

settings_sub <- list(
  biomass = list(low = min(dat$biomass), high = max(dat$biomass)),
  cost = list(low = min(dat$cost), high = max(dat$cost)),
  EC = list(low = min(dat$EC), high = max(dat$EC)),
  stability = list(low = min(dat$stability), high = max(dat$stability))
)
```

#### Step 8: optimize

``` r

mo_sub <- mix_multiopt(
  mf_sub,
  goals = goals_sub,
  settings = settings_sub,
  response_weights = c(
    biomass = 3,
    cost = 2,
    EC = 3,
    stability = 2
  ),
  resolution = 30,
  random_candidates = 5000,
  seed = 28202
)

mo_sub
```

#### Step 9: show Pareto and desirability views

``` r

mix_plot(mo_sub, "pareto")
mix_plot(mo_sub, "desirability")
```

#### Step 10: create a decision table

Report at least:

- selected composition;
- predicted value of every response;
- individual desirability of every response;
- overall desirability;
- two or more Pareto alternatives;
- response weights;
- response limits.

#### Interpretation

The final recommendation is a **decision compromise**, not a natural
constant of the fitted surfaces.

------------------------------------------------------------------------

## Part X. Uncertainty and decision preference are different

### 22. Two distinct questions

**Statistical uncertainty:** How uncertain are predicted biomass, cost,
EC, and stability?

**Decision preference:** How much does the team value biomass relative
to cost and EC?

Do not mix these concepts.

The current multiresponse desirability layer uses fitted response
surfaces and decision settings. Uncertainty in the location of a single
optimum is treated in Extended Vignette 29. A fully probabilistic
multiresponse decision analysis would require an additional
uncertainty-propagation layer and should be labeled accordingly.

------------------------------------------------------------------------

## Part XI. Common mistakes

### 23. Using observed min/max as universal desirability thresholds

Use scientific thresholds when available.

------------------------------------------------------------------------

### 24. Hiding response weights

Weights define the decision.

------------------------------------------------------------------------

### 25. Optimizing a poorly fitted response

Diagnose first.

------------------------------------------------------------------------

### 26. Calling a PCA biplot an optimization result

It is descriptive.

------------------------------------------------------------------------

### 27. Reporting only one compromise solution

Show Pareto alternatives when objectives conflict.

------------------------------------------------------------------------

### 28. Treating a hard safety limit as a soft preference

Use an exclusion constraint.

------------------------------------------------------------------------

### 29. Treating the desirability optimum as objectively best

It is conditional on the declared decision system.

------------------------------------------------------------------------

## Part XII. Function-selection guide

| Question | Function |
|:---|:---|
| Fit several responses | [`mix_multi_fit()`](https://wep69.github.io/mixRSMflow/reference/mix_multi_fit.md) |
| Inspect predicted multivariate structure | [`mix_biplot()`](https://wep69.github.io/mixRSMflow/reference/mix_biplot.md) |
| Optimize all responses under goals | [`mix_multiopt()`](https://wep69.github.io/mixRSMflow/reference/mix_multiopt.md) |
| Show compromise surface | `mix_plot(type="desirability")` |
| Show nondominated trade-offs | `mix_plot(type="pareto")` |
| Diagnose each response | [`mix_diagnose()`](https://wep69.github.io/mixRSMflow/reference/mix_diagnose.md) |
| Quantify a single optimum’s statistical location uncertainty | Extended Vignette 29 |

------------------------------------------------------------------------

## Part XIII. Reporting checklist

all responses and units;

model used for each response;

diagnostics for each response;

response goal: maximize/minimize/target as applicable;

desirability low/high/target settings;

response weights;

any hard constraints;

candidate/evaluation grid settings;

random seed;

selected compromise composition;

predicted values for every response;

individual desirabilities;

overall desirability;

Pareto-front alternatives;

sensitivity to weights/limits;

clear statement that the decision is conditional on preferences.

------------------------------------------------------------------------

## Appendix A. Compact multiresponse script

``` r

library(mixRSMflow)

sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("multiresponse", n_rep = 3, seed = 20260813)

mf <- mix_multi_fit(
  c("quality", "cost", "stability"),
  d,
  sp,
  model = "scheffe_quadratic"
)

lapply(mf$fits, mix_diagnose)

bp <- mix_biplot(mf, resolution = 20)
bp$plot

goals <- c(
  quality = "maximize",
  cost = "minimize",
  stability = "maximize"
)

settings <- list(
  quality = list(low = min(d$quality), high = max(d$quality)),
  cost = list(low = min(d$cost), high = max(d$cost)),
  stability = list(low = min(d$stability), high = max(d$stability))
)

mo <- mix_multiopt(
  mf,
  goals,
  settings,
  response_weights = c(2, 1, 2),
  seed = 20260813
)

print(mo)
mix_plot(mo, "pareto")
mix_plot(mo, "desirability")
```

------------------------------------------------------------------------

## Appendix B. Boundary with other extended vignettes

This vignette owns multiresponse decision trade-offs. It does not
re-teach optimal-design criteria (25), response-model families (26/31),
single-optimum bootstrap uncertainty (29), sequential adaptive
experiments (30), graphics engineering (32), or release validation (33).

------------------------------------------------------------------------

## Final perspective

With several responses, optimization becomes a decision problem as well
as a statistical problem.

A transparent workflow is:

**fit each response -\> diagnose each response -\> state goals -\>
define thresholds -\> inspect Pareto trade-offs -\> apply
desirability/weights -\> test sensitivity -\> report compromise and
alternatives.**

------------------------------------------------------------------------

## Appendix C. Advanced multiresponse laboratories

### C1. Laboratory: weight sensitivity map

Run at least five scientifically defensible weight sets and store the
selected composition from each.

``` r

W <- rbind(
  balanced = c(1,1,1),
  quality_first = c(3,1,1),
  stability_first = c(1,1,3),
  economy = c(1,3,1),
  performance = c(3,1,3)
)
```

For every row, call
[`mix_multiopt()`](https://wep69.github.io/mixRSMflow/reference/mix_multiopt.md)
with the same prediction grid and seed. Plot the selected compositions
on one ternary diagram.

#### Interpretation

A tight cluster means the recommendation is stable to reasonable
preference changes. A wide spread means stakeholder priorities
materially determine the selected formulation.

------------------------------------------------------------------------

### C2. Laboratory: threshold sensitivity

Hold weights fixed but change the low/high desirability thresholds based
on:

1.  observed range;
2.  agronomic target limits;
3.  conservative quality specifications.

Explain which threshold system is most defensible for a real decision
and why.

------------------------------------------------------------------------

### C3. Laboratory: Pareto knee versus desirability optimum

From the Pareto set, identify a point near a visually obvious knee.
Compare it with the weighted-desirability optimum. Explain why the two
solutions can differ and which one would be easier to defend to
stakeholders.

------------------------------------------------------------------------

### C4. Laboratory: one poor response model

Deliberately fit one response with a too-simple model. Run the
multiresponse optimizer, then correct the response model and rerun.
Quantify how the recommended mixture changes.

#### Lesson

Multiresponse optimization propagates the quality of every component
response model. One inadequate surface can distort the decision even
when the other models are excellent.

------------------------------------------------------------------------

## Appendix D. Multiresponse troubleshooting matrix

| Symptom | Likely issue | Response |
|:---|:---|:---|
| all overall desirabilities are zero | thresholds too strict or one response always unacceptable | inspect individual desirabilities |
| selected optimum changes drastically with weights | strong objective conflict | show Pareto set and sensitivity |
| biplot suggests trade-off but optimizer does not | PCA scaling/decision settings differ | remember biplot is descriptive |
| one response dominates | scale/weights/thresholds | inspect individual desirability transforms |
| cost optimum violates safety target | safety treated as soft preference | impose hard constraint |
| Pareto front very large | many nearly equivalent trade-offs | cluster or summarize alternatives transparently |
| optimum lies on boundary | response/constraint interaction | report active mixture constraints |
| one response model has severe lack of fit | inadequate component model | repair model before joint decision |

------------------------------------------------------------------------

## Appendix E. Guided multiresponse exercises

#### Exercise 1. Direction table

Create a table of five agronomic responses and classify each as
maximize, minimize, target, or hard constraint.

#### Exercise 2. Units

Explain why response units disappear after desirability transformation
but must remain in the prediction table.

#### Exercise 3. Zero desirability

Show mathematically why one zero individual desirability drives a
geometric-mean overall desirability to zero.

#### Exercise 4. Equal weights

Explain why equal numerical weights do not imply equal scientific
importance if desirability thresholds have very different widths.

#### Exercise 5. Pareto dominance

Given five hypothetical response pairs, identify dominated and
nondominated points manually.

#### Exercise 6. Biplot

Explain why two responses pointing in opposite directions in a biplot
can indicate a trade-off but not define the final optimum.

#### Exercise 7. Stakeholder scenarios

Construct agronomist, producer, and regulator weight/constraint
scenarios. Compare selected formulations.

#### Exercise 8. Hard safety limit

Convert a soft “minimize EC” preference into a strict maximum-EC
condition and describe how the feasible decision set changes.

#### Exercise 9. Model uncertainty

Fit quality with quadratic and special-cubic models. Evaluate whether
the Pareto set is stable.

#### Exercise 10. Practical alternative

Choose a Pareto solution with slightly lower desirability but simpler
formulation. Write a decision justification.

#### Exercise 11. Reporting

Create a table with composition, every predicted response, individual
desirabilities, total desirability, Pareto status, and decision label.

#### Exercise 12. Reviewer exercise

A manuscript gives “overall desirability = 0.91” but no weights or
thresholds. Draft a reviewer comment explaining why the optimization
cannot be reproduced.

------------------------------------------------------------------------

## Appendix F. Reviewer-style multiresponse audit

Require explicit reporting of:

1.  every response and unit;
2.  model for every response;
3.  diagnostics for every response;
4.  objective direction;
5.  desirability transformation and thresholds;
6.  response weights;
7.  hard constraints;
8.  candidate grid;
9.  seed;
10. selected composition;
11. original-scale predictions;
12. Pareto alternatives;
13. sensitivity to preferences;
14. statement that the optimum is preference-conditional.

------------------------------------------------------------------------

## Appendix G. Interpretation language templates

#### Weighted desirability

> The selected formulation maximized a weighted geometric mean of
> response-specific desirabilities. The solution is therefore
> conditional on the declared performance thresholds and response
> weights rather than an objective property of the fitted surfaces
> alone.

#### Pareto trade-off

> Several nondominated formulations were identified. Improving the
> predicted quality beyond the selected compromise required either
> higher cost or reduced stability, demonstrating a genuine
> multiobjective trade-off.

#### Weight sensitivity

> The preferred region remained stable across the pre-specified weight
> scenarios, indicating that the formulation recommendation was not
> driven by a single arbitrary priority vector.

#### Preference sensitivity

> The selected composition changed substantially across stakeholder
> weight scenarios; accordingly, results are presented as a Pareto
> decision set rather than a unique universally optimal formulation.

------------------------------------------------------------------------

## Appendix H. Applied multiresponse case bank

### H1. Fertilizer performance versus cost

A formulation raises crop biomass but uses an expensive micronutrient
source. Biomass is maximized while cost is minimized. A Pareto front
shows which biomass gains require extra cost. The weighted-desirability
optimum should be presented as one compromise among nondominated
options, not as an objectively best formulation independent of economic
priorities.

### H2. Pesticide efficacy versus crop injury

Two responses are both biological: pest mortality should increase, crop
injury should decrease. If injury above 10% is unacceptable, that is
better represented as a hard decision constraint than as a weak
desirability penalty. Pareto visualization can still show the trade-off
among the admissible formulations.

### H3. Substrate biomass, salinity, and stability

A high-organic formulation may increase biomass but also EC and physical
shrinkage. Three response surfaces should be diagnosed separately. If
the EC model has poor lack of fit, no weighted desirability can repair
it. The optimizer should be rerun only after the problematic response
model is addressed.

### H4. Stakeholder-dependent recommendation

An agronomist may prioritize performance, a producer cost, and a
regulator safety. Run three explicit scenarios with different weights
and constraints. If all select the same region, the recommendation is
stable. If they differ, present stakeholder-specific alternatives rather
than averaging preferences without explanation.

### H5. Pareto set as the primary result

When no defensible weight system exists, the Pareto set itself can be
the scientifically honest output. The analyst can describe several
representative solutions—maximum performance, minimum cost, balanced
knee—while leaving the final policy choice to stakeholders.

------------------------------------------------------------------------

## Appendix I. Short-answer multiresponse review

1.  **Why fit each response separately first?** Joint optimization
    inherits every response-model error.
2.  **What does desirability do?** Maps original responses to a common
    preference scale.
3.  **What does a weight represent?** Relative decision importance
    within the desirability system.
4.  **What is Pareto dominance?** One solution is no worse on all
    objectives and better on at least one.
5.  **Is every Pareto point equally preferred?** No.
6.  **Why not optimize PC1 automatically?** PCA describes variation, not
    necessarily scientific utility.
7.  **What is a hard constraint?** A rule excluding candidate solutions
    rather than merely lowering preference.
8.  **Why run sensitivity scenarios?** To reveal dependence of the
    recommendation on subjective choices.
9.  **What should always be reported on original scales?** Predicted
    response values and units.
10. **What makes the final optimum conditional?** Goals, thresholds,
    weights, constraints, and fitted response models.

------------------------------------------------------------------------

## Appendix J. Deeper conceptual notes on multiobjective decisions

### J1. Preference functions are not measurements

A desirability score is produced by the analyst’s mapping from measured
or predicted responses to a utility-like scale. It should never be
reported as though it were an observed biological response. The model
uncertainty belongs to the response surfaces; the preference assumptions
belong to the decision layer. Separating these layers makes sensitivity
analysis possible.

### J2. Thresholds can matter more than weights

Analysts often focus on response weights, but the low/high desirability
thresholds also determine trade-offs strongly. A narrow acceptable range
can effectively dominate the decision even with a moderate weight.
Therefore sensitivity analysis should vary both weights and thresholds
when they are uncertain.

### J3. Pareto fronts preserve disagreement

A single weighted optimum compresses several objectives into one number.
A Pareto front preserves the structure of conflict. This is particularly
valuable in interdisciplinary agricultural decisions where agronomists,
producers, and regulators may hold different priorities. Showing the
Pareto set allows each stakeholder to understand the cost of moving
toward their preferred objective.

### J4. Statistical uncertainty remains response-specific

The current desirability workflow uses fitted predictions. A rigorous
decision report should also summarize uncertainty of the component
response models. If one response has much greater uncertainty, equal
preference weights do not imply equal evidential certainty. A fully
probabilistic multiobjective decision framework would propagate
posterior or bootstrap response uncertainty through the utility
function; such an extension should be labeled separately rather than
assumed from point-prediction desirability.

### J5. Recommended decision meeting output

Prepare three artifacts:

1.  a table of response models and diagnostics;
2.  a Pareto figure with several labeled representative solutions;
3.  a sensitivity table showing selected compositions under alternative
    weight/threshold scenarios.

The final recommendation can then be documented as a stakeholder
decision informed by the response surfaces rather than as an opaque
optimizer output.
