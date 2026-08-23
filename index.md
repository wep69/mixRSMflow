# mixRSMflow

**Integrated Design, Modeling, Optimization and Visualization for
Mixture Experiments**

Development version: **0.1.0.9000**

`mixRSMflow` is an R package for coherent workflows in mixture
experiments. It links feasible-region specification, classical and
constrained designs, Scheffé and alternative blending models,
mixture-process structures, design diagnostics, optimal-design search,
response prediction, constrained optimization, uncertainty in optimum
location, multiple-response optimization, vector publication graphics
and optional interactive/Bayesian interfaces.

## Installation

Development version from GitHub:

``` r

# fast install, without rebuilding the vignettes (pak)
pak::pak("wep69/mixRSMflow")

# full install, rebuilding all vignettes (remotes)
remotes::install_github("wep69/mixRSMflow", build_vignettes = TRUE)
```

## Core workflow

``` r

library(mixRSMflow)

spec <- mix_spec(c("A", "B", "C"))
dat  <- mix_demo_data("mixture", n_rep = 3, seed = 20260813)
fit  <- mix_fit("response", dat, spec, model = "scheffe_quadratic")

mix_anova(fit)
mix_diagnose(fit)

opt <- mix_optimize(fit, goal = "maximize", grid_resolution = 20)
opt

mix_plot(fit, type = "ternary_contour")
mix_plot(fit, type = "surface3d", engine = "base", views = 2,
         file = "mixture_surface.pdf")
```

## Major capabilities

- simplex-lattice, simplex-centroid, axial, augmented and
  symmetric-simplex designs;
- extreme-vertices and constrained mixture regions;
- lower/upper pseudocomponents and independent-coordinate
  transformations;
- multiple lattices, categorized components, mixture-of-mixtures
  construction;
- mixture-process, mixture-amount, block, Latin-square and split-plot
  structures;
- Scheffé linear through quartic bases;
- inverse, ratio, Cox, log-contrast, slack-variable, Becker H1/H2/H3 and
  fixed-exponent General Blending Model terms;
- Gaussian/weighted, GLM, optional GLS, mixed-effects and Bayesian fits;
- pure error, lack of fit, leverage, influence, collinearity, screening
  and response-direction tools;
- D/A/I/G/E/T/Alias/Bayesian D/Bayesian I optimal-design criteria;
- exchange, genetic and hybrid design search;
- FDS, VDG, prediction variance, rotatability diagnostics and sequential
  augmentation;
- integrated mean-square error under explicit model-misspecification
  assumptions;
- bounded and GA-assisted response optimization;
- optimum-location uncertainty and near-optimal regions;
- desirability, response constraints, Pareto solutions and biplots;
- optional Gaussian-process Bayesian optimization;
- vector PDF/SVG 3D surfaces and ternary contours, plus optional Plotly
  output;
- scientific Markdown/HTML reports and optional DOCX/PDF rendering;
- optional Shiny teaching interface with visible R code.

## Scientific philosophy

The package does not choose statistical procedures only because they
improve one p-value, AIC, BIC or accuracy statistic. Experimental-design
semantics, estimability, numerical conditioning, diagnostics, prediction
behavior, uncertainty and the scientific purpose of the experiment
remain explicit.

The package separates the native scientific workflow from optional
backends. Missing optional packages cause a clear message rather than a
silent change of model.

## Data policy

The source snapshot contains only simulated demonstration data generated
by package code. It **does not redistribute the Cornell textbook data**
shown in the user-supplied excerpt because redistribution rights were
not established during construction.

## Documentation

Twenty-three vignettes cover geometry, designs, models, diagnostics,
optimal design, mixture-process experiments, blocking, optimization,
graphics, modern extensions, teaching, state of the art, validation,
reproducibility and the integrated end-to-end tutorial.

## Validation status of this development snapshot

The local release gate was executed on Windows with R 4.6.0 (Rtools45,
Pandoc 3.10, LaTeX): the `testthat` suite passes, all 23 vignettes
rebuild, the frozen numerical battery passes (4/4), the tarball installs
into a clean library, and `R CMD check --as-cran` completes with 0
errors, 0 warnings and 1 environmental NOTE (new submission). Continuous
integration (GitHub Actions) checks Windows, macOS and Ubuntu (release
and devel) on every push, and the integrated PT/EN tutorial ships as a
vignette. See `VALIDATION.md`, `RELEASE_CHECKLIST.md` and the validation
dossier.

## Release metadata

Maintainer: Walter Esfrain Pereira <walterufpb@yahoo.com.br> (ORCID-free
record; see `CITATION.cff` and `DESCRIPTION`). Repository:
<https://github.com/wep69/mixRSMflow>. Issues:
<https://github.com/wep69/mixRSMflow/issues>.
