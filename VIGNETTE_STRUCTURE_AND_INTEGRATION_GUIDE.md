# Final Vignette Structure and Integration Guide for `mixRSMflow`

**Package:** `mixRSMflow`  
**Target version:** `0.1.0.9000`  
**Purpose:** define the final documentation hierarchy, file placement, numbering, build strategy, cross-references, topic ownership, and maintenance rules for the package vignettes and extended instructional monographs.

---

## 1. Documentation architecture

The final documentation should use **three complementary layers** rather than turning every package vignette into a long monograph.

### Layer A. Focused package vignettes

The existing `01` to `22` `.Rmd` files remain concise, buildable package vignettes. They provide quick access to one concept or workflow and should be the first destination for a user searching for a specific package feature.

### Layer B. Extended instructional monographs

The master tutorial plus Extended Vignettes `24` to `33` provide long-form teaching material. They are intentionally supplied as Markdown source and should remain topic-owned documents rather than repeating the complete package workflow in every file.

### Layer C. Function reference

The Rd documentation remains the authoritative function-level API reference. A vignette should explain *why* and *when* to use a function; the manual should define its formal arguments and return object precisely.

The intended navigation is therefore:

```text
Focused vignette
      ↓
Extended thematic tutorial
      ↓
Function manual / ?function
      ↓
Advanced references and validation material
```

---

## 2. Final numbering

### Focused vignette layer

Keep the existing files unchanged in numbering:

```text
01-getting-started.Rmd
02-mixture-geometry.Rmd
03-simplex-designs.Rmd
04-constrained-regions.Rmd
05-scheffe-models.Rmd
06-alternative-mixture-models.Rmd
07-model-diagnostics.Rmd
08-component-effects.Rmd
09-optimal-design.Rmd
10-mixture-process.Rmd
11-blocks-and-splitplots.Rmd
12-multiple-responses.Rmd
13-optimization.Rmd
14-optimum-uncertainty.Rmd
15-static-graphics.Rmd
16-interactive-graphics.Rmd
17-sequential-design.Rmd
18-modern-models.Rmd
19-teaching-workflows.Rmd
20-state-of-the-art.Rmd
21-validation-and-benchmarks.Rmd
22-reproducibility.Rmd
```

### Master tutorial

```text
23-foundations-to-advanced-tutorial-mixRSMflow.md
```

This is the main **start-to-finish teaching tutorial**. It owns the complete package workflow and is the only extended document allowed to revisit all major modules in sequence.

### Extended thematic layer

```text
24-constrained-mixture-geometry-and-pseudocomponents.md
25-optimal-mixture-design-and-design-quality.md
26-alternative-blending-models.md
27-mixture-process-and-structured-experiments.md
28-multiple-responses-desirability-and-pareto.md
29-optimum-location-uncertainty-and-near-optimal-regions.md
30-sequential-mixture-experimentation.md
31-generalized-hierarchical-and-bayesian-mixture-models.md
32-publication-graphics-for-mixture-experiments.md
33-validation-benchmarking-and-reproducibility.md
```

Do not create another extended tutorial unless it owns a genuinely distinct scientific domain that cannot be handled as a subsection or focused vignette.

---

## 3. Recommended directory tree

The safest structure for package build time and optional dependencies is:

```text
mixRSMflow/
│
├── vignettes/
│   ├── 01-getting-started.Rmd
│   ├── 02-mixture-geometry.Rmd
│   ├── ...
│   ├── 22-reproducibility.Rmd
│   │
│   ├── 23-foundations-to-advanced-tutorial.Rmd        # lightweight wrapper
│   ├── 24-constrained-mixture-geometry.Rmd            # lightweight wrapper
│   ├── 25-optimal-mixture-design.Rmd                  # lightweight wrapper
│   ├── 26-alternative-blending-models-extended.Rmd    # lightweight wrapper
│   ├── 27-mixture-process-structured.Rmd              # lightweight wrapper
│   ├── 28-multiple-responses-extended.Rmd             # lightweight wrapper
│   ├── 29-optimum-uncertainty-extended.Rmd            # lightweight wrapper
│   ├── 30-sequential-mixtures-extended.Rmd            # lightweight wrapper
│   ├── 31-modern-response-models-extended.Rmd         # lightweight wrapper
│   ├── 32-publication-graphics-extended.Rmd           # lightweight wrapper
│   └── 33-validation-reproducibility-extended.Rmd     # lightweight wrapper
│
├── inst/
│   └── tutorials/
│       └── extended/
│           ├── 23-foundations-to-advanced-tutorial-mixRSMflow.md
│           ├── 24-constrained-mixture-geometry-and-pseudocomponents.md
│           ├── 25-optimal-mixture-design-and-design-quality.md
│           ├── 26-alternative-blending-models.md
│           ├── 27-mixture-process-and-structured-experiments.md
│           ├── 28-multiple-responses-desirability-and-pareto.md
│           ├── 29-optimum-location-uncertainty-and-near-optimal-regions.md
│           ├── 30-sequential-mixture-experimentation.md
│           ├── 31-generalized-hierarchical-and-bayesian-mixture-models.md
│           ├── 32-publication-graphics-for-mixture-experiments.md
│           └── 33-validation-benchmarking-and-reproducibility.md
│
├── man/
├── R/
└── _pkgdown.yml
```

### Why store the long sources under `inst/tutorials/extended/`?

The long tutorials contain many code examples, including optional Bayesian, mixed-model, Plotly, Shiny, and Gaussian-process workflows. Requiring every long monograph to execute during every `R CMD check` would:

- increase build time substantially;
- make CRAN checks depend on many optional packages;
- make the documentation fragile to external backend changes;
- duplicate tests already handled by the package test and validation system.

The extended Markdown files should therefore be treated as **installed instructional sources**. Formal R vignette wrappers can expose them without executing all code blocks.

---

## 4. Lightweight Rmd wrapper strategy

For an extended Markdown file, create a small formal R vignette whose only job is to include the Markdown source as rendered text.

Example wrapper for Vignette 24:

````markdown
---
title: "Extended tutorial: constrained mixture geometry and pseudocomponents"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Extended tutorial: constrained mixture geometry and pseudocomponents}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
```

```{r include-extended, results='asis', echo=FALSE}
source_file <- file.path(
  "..", "inst", "tutorials", "extended",
  "24-constrained-mixture-geometry-and-pseudocomponents.md"
)
cat(readLines(source_file, warn = FALSE, encoding = "UTF-8"), sep = "\n")
```
````

Before adopting this wrapper pattern permanently, test it under the real package build because working directories can differ among build tools. If relative-path inclusion proves fragile, copy the Markdown into the vignette build directory during a documented pre-build step or convert the long source to an `.Rmd` with all long examples nonexecuting.

The key objective is that the **long code examples are displayed but not automatically executed as part of every package check**.

---

## 5. Evaluation policy

### Focused `01` to `22` vignettes

Use `eval = TRUE` for lightweight Tier 1 examples that:

- run quickly;
- use only core dependencies;
- are already protected by tests;
- do not launch interactive sessions;
- do not require MCMC or large stochastic searches.

Use guarded or nonexecuting chunks for optional capabilities:

```r
if (requireNamespace("plotly", quietly = TRUE)) {
  # lightweight optional example
}
```

or:

```r
# eval = FALSE
```

when the example is intentionally demonstrative only.

### Extended `23` to `33` monographs

Keep them as explanatory Markdown source. Code is intended for the reader to run locally. Do not make routine CRAN build success depend on:

- `brms` sampling;
- large bootstrap counts;
- GA benchmark batteries;
- Bayesian optimization;
- Shiny app launch;
- interactive Plotly inspection;
- thousands of Monte Carlo simulations;
- complete local-release validation.

### Scientific validation

Heavy examples should be validated through:

```text
tests/testthat/
inst/scripts/run_validation_battery.R
local validation scripts
backend-specific smoke tests
simulation studies
CI jobs
```

rather than through expensive vignette execution.

---

## 6. Topic ownership matrix

The following matrix is the principal mechanism used to prevent overlap among the extended monographs.

| Topic | Owning extended vignette |
|:--|:--|
| Complete package workflow | 23 |
| Fixed-sum geometry | 24 |
| Bounds and general linear constraints | 24 |
| Extreme vertices | 24 |
| Independent coordinates | 24 |
| L/U pseudocomponents | 24 |
| Major/minor and categorized geometry | 24 |
| D/A/I/G/E/T/Alias/Bayes design criteria | 25 |
| Exchange/GA/hybrid design search | 25 |
| FDS and VDG | 25 |
| IMSE and rotatability | 25 |
| Information-based augmentation | 25, with only sequential use referenced in 30 |
| Alternative blending bases | 26 |
| Ratio/Cox/log-contrast/slack | 26 |
| Becker/GBM/Kronecker | 26 |
| Segmented mixture models | 26 |
| Mixture-process design | 27 |
| Mixture-amount design | 27 |
| Process fractionation | 27 |
| Blocks and Latin-style layouts | 27 |
| Split-plot randomization | 27 |
| Multiresponse fitting and decisions | 28 |
| Desirability | 28 |
| Pareto front | 28 |
| Single-response optimum search | 29 |
| Near-optimal region | 29 |
| Optimum-location bootstrap/simulation | 29 |
| Outcome-adaptive augmentation | 30 |
| Gaussian-process Bayesian optimization | 30 |
| Sequential stopping/provenance | 30 |
| GLM/WLS response layer | 31 |
| GLS covariance | 31 |
| Mixed-effects response layer | 31 |
| Bayesian response fitting | 31 |
| Scientific graphics and export | 32 |
| Vector dual-view 3D surface | 32 |
| Plotly interactive communication | 32 |
| Software validation architecture | 33 |
| Golden/frozen/simulation validation | 33 |
| Runtime/build/check/release gates | 33 |

When a topic must appear outside its owning vignette, use a short cross-reference rather than repeating the full explanation.

Example:

> “For the full mathematical treatment of FDS and VDG, see Extended Vignette 25.”

---

## 7. Relationship between quick and extended documents

The focused and extended files are not duplicates.

Use this mapping:

| Focused vignette | Extended continuation |
|:--|:--|
| `01-getting-started.Rmd` | 23 master tutorial |
| `02-mixture-geometry.Rmd` + `04-constrained-regions.Rmd` | 24 |
| `03-simplex-designs.Rmd` + `09-optimal-design.Rmd` | 25 |
| `05-scheffe-models.Rmd` + `06-alternative-mixture-models.Rmd` | 26 |
| `10-mixture-process.Rmd` + `11-blocks-and-splitplots.Rmd` | 27 |
| `12-multiple-responses.Rmd` | 28 |
| `13-optimization.Rmd` + `14-optimum-uncertainty.Rmd` | 29 |
| `17-sequential-design.Rmd` | 30 |
| `18-modern-models.Rmd` | 31 |
| `15-static-graphics.Rmd` + `16-interactive-graphics.Rmd` | 32 |
| `20-state-of-the-art.Rmd` + `21-validation-and-benchmarks.Rmd` + `22-reproducibility.Rmd` | 33, while state-of-the-art remains its own focused reference |

The focused files should end with a short “Continue with the extended tutorial” link once the final package paths are established.

---

## 8. Position of the master tutorial

The master tutorial must remain **first among the extended documents**.

Recommended package reading order:

```text
01-getting-started
      ↓
23-foundations-to-advanced tutorial
      ↓
24 geometry
      ↓
25 optimal design
      ↓
26 alternative models
      ↓
27 mixture-process / structured experiments
      ↓
31 generalized / hierarchical / Bayesian models
      ↓
28 multiresponse decisions
      ↓
29 optimum uncertainty
      ↓
30 sequential experimentation
      ↓
32 publication graphics
      ↓
33 validation and reproducibility
```

The numeric filenames remain `28`, `29`, `30`, `31`, etc., but the pedagogical reading order may place `31` before `28` when the user's analysis first requires advanced stochastic response models.

---

## 9. Internal cross-reference style

At the start of every extended vignette include:

```text
Primary ownership:
Companion material:
```

At the first appearance of a non-owned topic, use one sentence only.

Examples:

```text
The full feasible-region treatment is provided in Extended Vignette 24.
```

```text
For the mathematical and computational treatment of I-optimality and FDS, see Extended Vignette 25.
```

```text
Single-response optimum-location uncertainty is developed in Extended Vignette 29.
```

Do not copy entire explanatory sections between files.

---

## 10. Function documentation rule

Each function should have one **primary extended home** even when it appears in several workflows.

Examples:

```text
mix_spec()             → 24
mix_optimal_design()   → 25
mix_gbm_term()         → 26
mix_block_design()     → 27
mix_multiopt()         → 28
mix_optimum_ci()       → 29
mix_bo()               → 30
mix_fit_mixed()        → 31
mix_plot()             → 32
mix_capabilities()     → 33 for validation interpretation
```

The master tutorial can call all of them, but it should not replace their thematic monographs.

---

## 11. Recommended `_pkgdown.yml` article organization

Add an `articles:` section after verifying wrapper names.

Example:

```yaml
articles:
- title: Start here
  contents:
  - 01-getting-started
  - 23-foundations-to-advanced-tutorial

- title: Mixture foundations and design
  contents:
  - 02-mixture-geometry
  - 03-simplex-designs
  - 04-constrained-regions
  - 24-constrained-mixture-geometry
  - 25-optimal-mixture-design

- title: Models and inference
  contents:
  - 05-scheffe-models
  - 06-alternative-mixture-models
  - 07-model-diagnostics
  - 08-component-effects
  - 26-alternative-blending-models-extended
  - 31-modern-response-models-extended

- title: Structured and multiple-response experiments
  contents:
  - 10-mixture-process
  - 11-blocks-and-splitplots
  - 12-multiple-responses
  - 27-mixture-process-structured
  - 28-multiple-responses-extended

- title: Optimization and sequential experimentation
  contents:
  - 13-optimization
  - 14-optimum-uncertainty
  - 17-sequential-design
  - 29-optimum-uncertainty-extended
  - 30-sequential-mixtures-extended

- title: Graphics, teaching, and reproducibility
  contents:
  - 15-static-graphics
  - 16-interactive-graphics
  - 19-teaching-workflows
  - 20-state-of-the-art
  - 21-validation-and-benchmarks
  - 22-reproducibility
  - 32-publication-graphics-extended
  - 33-validation-reproducibility-extended
```

Do not copy this block blindly until the final wrapper filenames exist. `pkgdown` article keys must match actual article sources.

---

## 12. Package-build policy for optional dependencies

Extended tutorials may show code for:

```text
nlme
lme4
brms
DiceKriging
plotly
shiny
```

but routine package checks should not require every long example to execute.

The corresponding focused vignettes should either:

```r
if (requireNamespace("backend", quietly = TRUE)) {
  # lightweight example
}
```

or use nonexecuting examples where runtime or external compilation is excessive.

Backend functionality itself belongs in automated tests and the validation matrix.

---

## 13. `eval=TRUE` policy

Recommended rule:

### `TRUE`

Use for:

- `mix_spec()`;
- simple `mix_vertices()`;
- small `mix_design()`;
- small `mix_fit()`;
- lightweight `mix_diagnose()`;
- tiny deterministic examples.

### guarded or `FALSE`

Use for:

- large GA/hybrid searches;
- `B = 1000+` bootstrap examples;
- `brms` MCMC;
- `mix_bo()` if the optional GP backend is absent;
- Plotly interaction;
- Shiny launch;
- benchmark loops;
- release-validation scripts;
- deliberately expensive simulations.

This preserves truthful examples without turning documentation into the validation framework.

---

## 14. Code and result policy

The extended Markdown files should normally show **code without frozen numerical results** unless those results are part of a validated golden/frozen teaching dataset.

Do not invent coefficient tables, p-values, optimum coordinates, or benchmark timings.

When a teaching result is simulated, label it explicitly as simulated.

When a result must be reproduced locally, state that the code generates it rather than writing an unverified number into the prose.

---

## 15. Equations and notation

Use consistent notation across all tutorials:

```text
x_i      mixture proportion
q        number of mixture components
T        mixture total
L_i/U_i  lower/upper component bound
X        model matrix
f(x)     model vector at composition x
v(x)     prediction-variance factor
β        model coefficient vector
```

The full master tutorial may define notation globally. Thematic monographs should redefine only what is needed locally.

---

## 16. Graphics policy

The extended graphics monograph `32` is the primary visual reference.

Other tutorials may generate only figures required to interpret their own method.

Examples:

```text
24 → feasible region / vertices
25 → design, FDS, VDG, prediction variance
26 → model comparison surface only when needed
27 → process-conditioned surface
28 → Pareto/desirability
29 → optimum/optimum cloud
30 → staged design points
31 → model diagnostics
32 → full publication graphics treatment
33 → graphics only as validation artifacts
```

This prevents every vignette from reproducing the same ternary contour section.

---

## 17. Final source-file placement procedure

### Step 1

Create:

```text
inst/tutorials/extended/
```

### Step 2

Copy:

```text
23-foundations-to-advanced-tutorial-mixRSMflow.md
24-constrained-mixture-geometry-and-pseudocomponents.md
25-optimal-mixture-design-and-design-quality.md
26-alternative-blending-models.md
27-mixture-process-and-structured-experiments.md
28-multiple-responses-desirability-and-pareto.md
29-optimum-location-uncertainty-and-near-optimal-regions.md
30-sequential-mixture-experimentation.md
31-generalized-hierarchical-and-bayesian-mixture-models.md
32-publication-graphics-for-mixture-experiments.md
33-validation-benchmarking-and-reproducibility.md
```

into that directory.

### Step 3

Create lightweight `.Rmd` wrappers only if the long documents are to appear as formal package vignettes/pkgdown articles.

### Step 4

Add cross-links from each focused vignette to its extended continuation.

### Step 5

Update `_pkgdown.yml`.

### Step 6

Run documentation validation locally.

---

## 18. Validation after integration

After adding the long tutorials and any wrappers, rerun:

1. static API audit;
2. Markdown/Rmd fence validation;
3. `devtools::build_vignettes()`;
4. `pkgdown::build_site()`;
5. link inspection;
6. `R CMD build`;
7. installation from the built tarball;
8. `R CMD check --as-cran`.

The extended docs contain many examples. API signatures must be re-audited after any future function renaming.

---

## 19. Maintenance rule after API changes

When a public function changes:

1. update its Rd manual;
2. update the focused vignette;
3. update its owning extended monograph;
4. search the master tutorial for cross-workflow uses;
5. search all other extended files for secondary references;
6. rerun static API checks;
7. rerun examples/tests that cover the change.

Do not manually update only one copy of an example and leave stale calls elsewhere.

---

## 20. Final expected user experience

A beginner should be able to do this:

```text
01 Getting Started
        ↓
23 Master Tutorial
        ↓
choose one specialized extended tutorial only when needed
```

An experienced analyst should be able to do this:

```text
?mix_optimal_design
        ↓
09 quick vignette
        ↓
25 extended design monograph
```

A reviewer or package developer should be able to do this:

```text
21 validation vignette
        ↓
33 validation monograph
        ↓
VALIDATION.md / METHOD_GATES.md / local validation scripts
```

This hierarchy gives the package both **fast reference documentation** and **textbook-like instructional depth** without making users read the same material repeatedly.

---

## 21. Final checklist

- [ ] retain existing focused vignettes `01`–`22`;
- [ ] place master tutorial at `23`;
- [ ] install extended thematic Markdown sources `24`–`33`;
- [ ] keep one primary owner for every major topic;
- [ ] replace duplicated explanations with cross-references;
- [ ] keep expensive code out of routine vignette execution;
- [ ] execute lightweight core examples where useful;
- [ ] guard optional backends;
- [ ] expose extended tutorials through lightweight wrappers/pkgdown if desired;
- [ ] update `_pkgdown.yml` only after wrapper names are final;
- [ ] maintain function-manual authority for formal API details;
- [ ] label simulated examples explicitly;
- [ ] never invent frozen numerical results;
- [ ] rerun API/documentation checks after public-function changes;
- [ ] rerun full local validation before a release.

---

# Final recommendation

The final `mixRSMflow` documentation should **not** consist of 33 equally long compiled vignettes.

The optimal structure is:

```text
22 focused, executable reference vignettes
+
1 master start-to-finish tutorial
+
10 extended thematic monographs
+
Rd function manuals
+
validation and method-gate files
```

This preserves pedagogical depth, avoids subject overlap, keeps package build times manageable, and makes the documentation useful to beginners, advanced analysts, reviewers, and package developers at the same time.
