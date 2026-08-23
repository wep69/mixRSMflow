.mix_capability_registry <- function() {
  capability <- c("simplex_lattice", "simplex_centroid", "axial", "augmented_centroid", "symmetric_simplex", "extreme_vertices", "multiple_lattice", "categorized_components", "rotatable_independent_coordinates", "mixture_process", "mixture_amount", "split_plot_design", "latin_square_process", "block_balancing", "scheffe_linear", "scheffe_quadratic", "scheffe_special_cubic", "scheffe_full_cubic", "scheffe_special_quartic", "scheffe_full_quartic", "slack_variable", "inverse_terms", "ratio_models", "cox_parameterization", "logcontrast", "becker_general_blending", "general_blending_model", "additive_blending", "kronecker_quadratic", "gaussian_fit", "glm_fit", "gls_fit", "mixed_effects", "bayesian_fit", "segmented_fit", "pure_error_lack_of_fit", "integrated_mse", "model_reduction", "component_screening", "cox_effects", "piepel_effects", "collinearity", "D_optimal", "A_optimal", "I_optimal", "G_optimal", "E_optimal", "T_optimal", "alias_optimal", "bayesian_D", "bayesian_I", "model_robust_optimal", "genetic_algorithm_design", "FDS", "VDG", "rotatability_diagnostic", "sequential_augmentation", "bounded_optimization", "GA_optimization", "optimum_uncertainty", "near_optimal_region", "multiresponse_desirability", "pareto", "biplot", "bayesian_optimization", "vector_3d_surface", "ternary_contour", "interactive_plotly", "scientific_report", "shiny_interface", "simplex_moments")
  module <- c("design", "design", "design", "design", "design", "design", "design", "design", "design", "design", "design", "design", "design", "design", "models", "models", "models", "models", "models", "models", "models", "models", "models", "models", "models", "models", "models", "models", "models", "fit", "fit", "fit", "fit", "fit", "fit", "inference", "inference", "inference", "inference", "inference", "inference", "inference", "optimal_design", "optimal_design", "optimal_design", "optimal_design", "optimal_design", "optimal_design", "optimal_design", "optimal_design", "optimal_design", "optimal_design", "optimal_design", "optimal_design", "optimal_design", "optimal_design", "optimal_design", "optimization", "optimization", "optimization", "optimization", "multiresponse", "multiresponse", "multiresponse", "modern", "graphics", "graphics", "graphics", "reporting", "reporting", "theory")
  validation_tier <- c("Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 2", "Tier 2", "Tier 2", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 2", "Tier 2", "Tier 2", "Tier 2", "Tier 2", "Tier 2", "Tier 2", "Tier 2", "Tier 1", "Tier 1", "Tier 2", "Tier 2", "Tier 2", "Tier 2", "Tier 1", "Tier 2", "Tier 2", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 2", "Tier 1", "Tier 2", "Tier 2", "Tier 2", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 3", "Tier 1", "Tier 1", "Tier 1", "Tier 1", "Tier 2", "Tier 1")
  implementation <- c("native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "optional:nlme", "optional:lme4", "optional:brms", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "native", "optional:DiceKriging", "native", "native", "optional:plotly", "native", "optional:shiny", "native")
  runtime_status <- rep("local_runtime_validated", length(capability))
  data.frame(capability=capability,module=module,validation_tier=validation_tier,
             implementation=implementation,runtime_status=runtime_status,stringsAsFactors=FALSE)
}

#' Inspect the package capability registry
#'
#' @param module Optional module filter.
#' @param tier Optional validation-tier filter.
#' @return A data frame describing source-implemented capabilities, optional backends, target validation tiers, and current runtime-certification status.
#' @examples
#' head(mix_capabilities())
#' mix_capabilities(module = "optimal_design")
#' @export
mix_capabilities <- function(module = NULL, tier = NULL) {
  x <- .mix_capability_registry()
  if (!is.null(module)) x <- x[x$module %in% module,,drop=FALSE]
  if (!is.null(tier)) x <- x[x$validation_tier %in% tier,,drop=FALSE]
  rownames(x) <- NULL; x
}

#' Extract an auditable trail from a mixRSMflow object
#'
#' @param object Any mixRSMflow result object containing an `audit` field.
#' @return A normalized data frame of audit steps.
#' @examples
#' sp <- mix_spec(c("A", "B", "C"))
#' d <- mix_design(sp, "simplex_centroid")
#' mix_audit_trail(d)
#' @export
mix_audit_trail <- function(object) {
  aa <- object$audit %||% list()
  if (!length(aa)) return(data.frame(step=character(),time=character(),details=character()))
  do.call(rbind,lapply(aa,function(z){
    data.frame(step=z$step %||% NA_character_, time=as.character(z$timestamp %||% z$time %||% NA),
               details=paste(capture.output(str(z$details %||% list(),give.attr=FALSE,vec.len=10)),collapse=" "),stringsAsFactors=FALSE)
  }))
}
