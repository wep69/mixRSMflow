# Methodological implementation gates

Version: **0.1.0.9000 source snapshot**  
Audit date: **2026-08-13**

This file records boundaries between implemented methods, methods that are intentionally generalized, and historical textbook details that are not claimed as exact reproductions without an inspectable primary equation or redistribution permission. These gates are part of the scientific audit trail and should not be removed merely to make the feature list appear more complete.

## 1. Cornell source coverage gate

The user-supplied source is a 12-page excerpt from John A. Cornell's third edition of *Experiments with Mixtures: Designs, Models, and the Analysis of Mixture Data*. It contains selected contents pages and Chapter 10 material, including the fruit-punch example and Figures 10.1 and 10.2. It does not expose every equation in the full book.

Accordingly, `mixRSMflow` implements the methods whose mathematical form could be independently specified from inspectable primary literature, standard definitions, or the visible source material. It does not invent missing textbook equations.

## 2. Categorized-component / double-Scheffé gate

Implemented:

- categorized-component design geometry;
- major/minor component design support;
- mixture-of-mixtures style candidate construction;
- generic Scheffé bases that can be used after a scientifically justified reparameterization.

Not claimed as an exact historical reproduction:

- the coefficient mapping referred to in Cornell Appendix 4B between the double-Scheffé model and the interaction model.

Reason: the uploaded excerpt names this appendix but does not display the defining equation and coefficient transformation. A future release may add an explicitly named `double_scheffe` basis after the equation is verified against a legally inspectable primary source.

## 3. Historical rotatable-design / ACED gate

Implemented:

- transformation to `q - 1` independent coordinates;
- numerical rotatability diagnostics;
- prediction-variance evaluation;
- D/A/I/G/E/T/Alias design criteria;
- FDS and VDG summaries;
- numerical constrained design search and augmentation.

Not claimed as an exact line-for-line recreation:

- legacy ACED program internals;
- every historical concentric-triangle construction described in the book.

The package exposes modern numerical equivalents and diagnostics rather than emulating undocumented legacy software behavior.

## 4. Integrated mean-square error gate

`mix_imse()` implements an explicit integrated mean-square error decomposition over a declared region:

`IMSE = integrated prediction variance + integrated squared bias`.

When a larger reference model is supplied, omitted-term coefficients must be supplied or otherwise explicitly defined by the caller. The function does not infer unobserved coefficients from significance tests.

The function is therefore not described as an exact reproduction of any historical subset-selection heuristic unless the defining historical formula is independently verified.

## 5. General blending model gate

`mix_gbm_term()` and the GBM basis implement fixed-exponent general blending terms from the inspectable Brown, Donev and Bissett methodological formulation. Special cases are represented through parameter choices. Estimation of the exponents themselves is not silently performed by ordinary linear fitting. Any future nonlinear exponent-estimation layer must receive separate numerical validation.

## 6. Mixture-process fractionation gate

`mix_fractionate_process()` supports a D-information based deterministic selection from a declared candidate set and an explicit random alternative. The random alternative is labelled and warns because it is not an information-optimal fractionation method.

The function does not claim to duplicate any historical proprietary or undocumented computer-aided fractionation routine from the book.

## 7. Bayesian and surrogate-model gate

Bayesian fitting (`brms`) and Bayesian optimization (`DiceKriging`) are optional modern extensions. They are separated from classical Scheffé estimation in the capability registry. Source support is implemented, but runtime certification remains pending in this construction environment.

## 8. Non-Gaussian mixture-model gate

`mix_fit()` can route mixture bases through GLM families available in base R. This is a modern extension of the mixture linear predictor, not a claim that Cornell's classical Gaussian ANOVA theory transfers unchanged. Pure-error/lack-of-fit inference and residual interpretation must follow the fitted model class and supported diagnostic path.

## 9. Optimum uncertainty gate

`mix_optimum_ci()` implements parametric and residual-bootstrap uncertainty for the constrained optimum through repeated refitting/reoptimization. The returned cloud or intervals describe uncertainty under the selected resampling mechanism and fitted model. They must not be interpreted as an exact finite-sample confidence region without the corresponding theoretical assumptions.

## 10. Textbook datasets and figures gate

The package does **not** redistribute raw Cornell textbook datasets. Development may use visible numerical examples as human-readable validation references, but release data are simulated or independently licensed.

The Figure 10.1-style graphic is a newly computed vector 3D representation of a fitted mixture surface. It is not a copied image. The Figure 10.2-style ternary contour is likewise generated from model predictions.

## 11. Runtime certification gate

The local release gate documented in the package validation protocol was
executed on Windows with R 4.6.0, Rtools45, Pandoc and LaTeX. The recorded
runtime evidence includes: the `testthat` suite, the rebuilt 22 vignettes, the
frozen numerical battery, `R CMD build`, clean-library installation and
`R CMD check --as-cran`; details live in `LOCAL_VALIDATION_RESULTS.md` of the
validation dossier. Optional backends (`nlme`, `lme4`, `brms`, `DiceKriging`,
`plotly`, `shiny`) received local smoke tests, which are not a substitute for
scientific certification of every optional tier in production use.
