# Package index

## Specification and geometry

- [`mix_spec()`](https://wep69.github.io/mixRSMflow/reference/mix_spec.md)
  : Define a mixture specification
- [`mix_region()`](https://wep69.github.io/mixRSMflow/reference/mix_region.md)
  : Define a curved or independent-coordinate region of interest
- [`mix_transform()`](https://wep69.github.io/mixRSMflow/reference/mix_transform.md)
  : Transform mixture coordinates to independent orthonormal coordinates
- [`mix_inverse_transform()`](https://wep69.github.io/mixRSMflow/reference/mix_inverse_transform.md)
  : Transform independent coordinates back to mixture coordinates
- [`mix_pseudocomponents()`](https://wep69.github.io/mixRSMflow/reference/mix_pseudocomponents.md)
  : Convert between original proportions and lower/upper
  pseudocomponents
- [`mix_vertices()`](https://wep69.github.io/mixRSMflow/reference/mix_vertices.md)
  : Enumerate extreme vertices of a linearly constrained mixture region
- [`mix_moments()`](https://wep69.github.io/mixRSMflow/reference/mix_moments.md)
  : Compute moments over a simplex or approximate moments over a
  constrained region

## Designs

- [`mix_design()`](https://wep69.github.io/mixRSMflow/reference/mix_design.md)
  : Generate classical and mixture-process designs
- [`mix_multiple_lattice()`](https://wep69.github.io/mixRSMflow/reference/mix_multiple_lattice.md)
  : Construct multiple-lattice designs for major and minor component
  groups
- [`mix_categorized_design()`](https://wep69.github.io/mixRSMflow/reference/mix_categorized_design.md)
  : Construct categorized-component or mixture-of-mixtures designs
- [`mix_block_design()`](https://wep69.github.io/mixRSMflow/reference/mix_block_design.md)
  : Allocate a mixture design to approximately orthogonal balanced
  blocks
- [`mix_latin_process_design()`](https://wep69.github.io/mixRSMflow/reference/mix_latin_process_design.md)
  : Generate a Latin-square crossed mixture-process design
- [`mix_fractionate_process()`](https://wep69.github.io/mixRSMflow/reference/mix_fractionate_process.md)
  : Model-based fractionation of crossed mixture-process designs
- [`mix_optimal_design()`](https://wep69.github.io/mixRSMflow/reference/mix_optimal_design.md)
  : Construct exact optimal mixture designs
- [`mix_design_eval()`](https://wep69.github.io/mixRSMflow/reference/mix_design_eval.md)
  : Evaluate information and prediction-variance properties of a mixture
  design
- [`mix_augment()`](https://wep69.github.io/mixRSMflow/reference/mix_augment.md)
  : Augment an existing design according to an information objective
- [`mix_rotatability()`](https://wep69.github.io/mixRSMflow/reference/mix_rotatability.md)
  : Assess approximate rotatability through radial prediction-variance
  dispersion

## Models and inference

- [`mix_basis()`](https://wep69.github.io/mixRSMflow/reference/mix_basis.md)
  : Build a mixture-model basis matrix
- [`mix_gbm_term()`](https://wep69.github.io/mixRSMflow/reference/mix_gbm_term.md)
  : Define one general blending model term
- [`mix_imse()`](https://wep69.github.io/mixRSMflow/reference/mix_imse.md)
  : Integrated mean-square prediction error under an explicit larger
  model
- [`mix_fit()`](https://wep69.github.io/mixRSMflow/reference/mix_fit.md)
  : Fit classical and generalized mixture response-surface models
- [`mix_fit_gls()`](https://wep69.github.io/mixRSMflow/reference/mix_fit_gls.md)
  : Fit weighted/generalized least-squares mixture models through nlme
- [`mix_fit_mixed()`](https://wep69.github.io/mixRSMflow/reference/mix_fit_mixed.md)
  : Fit a mixed-effects mixture model through lme4
- [`mix_fit_bayes()`](https://wep69.github.io/mixRSMflow/reference/mix_fit_bayes.md)
  : Fit a Bayesian mixture model through brms
- [`mix_segmented_fit()`](https://wep69.github.io/mixRSMflow/reference/mix_segmented_fit.md)
  : Fit a two-region segmented mixture model
- [`mix_anova()`](https://wep69.github.io/mixRSMflow/reference/mix_anova.md)
  : ANOVA and pure-error/lack-of-fit decomposition for mixture models
- [`mix_diagnose()`](https://wep69.github.io/mixRSMflow/reference/mix_diagnose.md)
  : Diagnose a fitted mixture model
- [`mix_collinearity()`](https://wep69.github.io/mixRSMflow/reference/mix_collinearity.md)
  : Diagnose collinearity and estimability in mixture model matrices
- [`mix_compare()`](https://wep69.github.io/mixRSMflow/reference/mix_compare.md)
  : Compare fitted mixture models without selecting solely by one metric
- [`mix_reduce()`](https://wep69.github.io/mixRSMflow/reference/mix_reduce.md)
  : Audited hierarchical model reduction for mixture response surfaces
- [`mix_screen()`](https://wep69.github.io/mixRSMflow/reference/mix_screen.md)
  : Screen component directional effects with uncertainty

## Prediction, effects, optimization

- [`mix_predict()`](https://wep69.github.io/mixRSMflow/reference/mix_predict.md)
  : Predict from a fitted mixture model with uncertainty
- [`mix_effects()`](https://wep69.github.io/mixRSMflow/reference/mix_effects.md)
  : Compute interpretable component effects and trace paths
- [`mix_optimize()`](https://wep69.github.io/mixRSMflow/reference/mix_optimize.md)
  : Optimize a fitted mixture response surface under exact mixture
  constraints
- [`mix_optimum_ci()`](https://wep69.github.io/mixRSMflow/reference/mix_optimum_ci.md)
  : Quantify uncertainty in the location of the optimum
- [`mix_multi_fit()`](https://wep69.github.io/mixRSMflow/reference/mix_multi_fit.md)
  : Fit several responses using a shared mixture specification
- [`mix_multiopt()`](https://wep69.github.io/mixRSMflow/reference/mix_multiopt.md)
  : Multiresponse desirability, constraints, and Pareto optimization
- [`mix_biplot()`](https://wep69.github.io/mixRSMflow/reference/mix_biplot.md)
  : Multiresponse prediction biplot over the feasible mixture region
- [`mix_bo()`](https://wep69.github.io/mixRSMflow/reference/mix_bo.md) :
  Gaussian-process Bayesian optimization over a mixture region

## Graphics and reporting

- [`mix_plot()`](https://wep69.github.io/mixRSMflow/reference/mix_plot.md)
  : Unified static and interactive plotting for mixture workflows
- [`mix_report()`](https://wep69.github.io/mixRSMflow/reference/mix_report.md)
  : Create a reproducible scientific mixture-analysis report
- [`run_mixrsm_app()`](https://wep69.github.io/mixRSMflow/reference/run_mixrsm_app.md)
  : Launch the interactive mixRSMflow teaching and analysis application
- [`mix_capabilities()`](https://wep69.github.io/mixRSMflow/reference/mix_capabilities.md)
  : Inspect the package capability registry
- [`mix_audit_trail()`](https://wep69.github.io/mixRSMflow/reference/mix_audit_trail.md)
  : Extract an auditable trail from a mixRSMflow object
- [`mix_demo_data()`](https://wep69.github.io/mixRSMflow/reference/mix_demo_data.md)
  : Generate reproducible pedagogical mixture datasets

## Additional utilities

- [`mix_predict_segmented()`](https://wep69.github.io/mixRSMflow/reference/mix_predict_segmented.md)
  : Predict from a segmented mixture model
- [`mix_reparameterize()`](https://wep69.github.io/mixRSMflow/reference/mix_reparameterize.md)
  : Reparameterize an equivalent Scheffe model with an intercept and
  slack component

## S3 methods and package

- [`as.data.frame(`*`<mix_design>`*`)`](https://wep69.github.io/mixRSMflow/reference/as.data.frame.mix_design.md)
  : as.data.frame.mix_design
- [`coef.mix_fit()`](https://wep69.github.io/mixRSMflow/reference/coef.mix_fit.md)
  : coef.mix_fit
- [`fitted.mix_fit()`](https://wep69.github.io/mixRSMflow/reference/fitted.mix_fit.md)
  : fitted.mix_fit
- [`residuals(`*`<mix_fit>`*`)`](https://wep69.github.io/mixRSMflow/reference/residuals.mix_fit.md)
  : residuals.mix_fit
- [`vcov.mix_fit()`](https://wep69.github.io/mixRSMflow/reference/vcov.mix_fit.md)
  : vcov.mix_fit
- [`summary(`*`<mix_fit>`*`)`](https://wep69.github.io/mixRSMflow/reference/summary.mix_fit.md)
  : summary.mix_fit
- [`predict.mix_fit()`](https://wep69.github.io/mixRSMflow/reference/predict.mix_fit.md)
  : predict.mix_fit
- [`predict.mix_segmented_fit()`](https://wep69.github.io/mixRSMflow/reference/predict.mix_segmented_fit.md)
  : predict.mix_segmented_fit
- [`plot(`*`<mix_design>`*`)`](https://wep69.github.io/mixRSMflow/reference/plot.mix_design.md)
  : plot.mix_design
- [`plot(`*`<mix_fit>`*`)`](https://wep69.github.io/mixRSMflow/reference/plot.mix_fit.md)
  : plot.mix_fit
- [`print(`*`<mix_bo>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_bo.md)
  : print.mix_bo
- [`print(`*`<mix_collinearity>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_collinearity.md)
  : print.mix_collinearity
- [`print(`*`<mix_design>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_design.md)
  : print.mix_design
- [`print(`*`<mix_design_evaluation>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_design_evaluation.md)
  : print.mix_design_evaluation
- [`print(`*`<mix_diagnostics>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_diagnostics.md)
  : print.mix_diagnostics
- [`print(`*`<mix_effect>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_effect.md)
  : print.mix_effect
- [`print(`*`<mix_fit>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_fit.md)
  : print.mix_fit
- [`print(`*`<mix_fit_gls>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_fit_gls.md)
  : print.mix_fit_gls
- [`print(`*`<mix_imse>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_imse.md)
  : print.mix_imse
- [`print(`*`<mix_multi_fit>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_multi_fit.md)
  : print.mix_multi_fit
- [`print(`*`<mix_multiopt>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_multiopt.md)
  : print.mix_multiopt
- [`print(`*`<mix_optimum>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_optimum.md)
  : print.mix_optimum
- [`print(`*`<mix_optimum_ci>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_optimum_ci.md)
  : print.mix_optimum_ci
- [`print(`*`<mix_reduction>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_reduction.md)
  : print.mix_reduction
- [`print(`*`<mix_report>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_report.md)
  : print.mix_report
- [`print(`*`<mix_rotatability>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_rotatability.md)
  : print.mix_rotatability
- [`print(`*`<mix_segmented_fit>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_segmented_fit.md)
  : print.mix_segmented_fit
- [`print(`*`<mix_spec>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.mix_spec.md)
  : print.mix_spec
- [`print(`*`<summary.mix_fit>`*`)`](https://wep69.github.io/mixRSMflow/reference/print.summary.mix_fit.md)
  : print.summary.mix_fit
- [`mixRSMflow`](https://wep69.github.io/mixRSMflow/reference/mixRSMflow-package.md)
  [`mixRSMflow-package`](https://wep69.github.io/mixRSMflow/reference/mixRSMflow-package.md)
  : mixRSMflow: Integrated Mixture Experiment Workflows
