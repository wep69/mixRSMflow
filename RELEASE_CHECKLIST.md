# Release checklist

Scientific scope defined.

Dated state-of-the-art comparison written.

Package architecture and public API implemented.

Capability registry implemented.

Core and advanced source modules implemented.

Optional backend routing isolated.

All 47 public functions documented with examples.

22 layered vignettes included.

Reference and software metadata audits included.

Frozen test/simulation inputs included.

Static structural audit passes.

Static named-argument API audit passes.

Static Rd/source-formal audit passes.

Methodological source gates documented.

Offline/local validation workflow supplied.

CI source supplied.

Replace maintainer placeholder with a real routable address.

Run roxygen2 in R and inspect generated NAMESPACE/Rd diff.

Run all examples.

Run `testthat`.

Render all vignettes.

Exercise optional backends intended for the release tier.

Install into a clean temporary R library.

Run frozen validation battery and inspect numerical tolerances.

Build pkgdown site.

Run `R CMD build`.

Run `R CMD check --as-cran` and manually review output.

Refresh dated CRAN/PyPI and bibliographic metadata.

Every public function has \>= 3 examples in the manual and in the
vignettes.

Only then label the package release-ready.
