# Contributing to mixRSMflow

Contributions should preserve the package’s mixture-design semantics and
validation tiers.

1.  Add or modify a public method only with a documented scientific
    definition.
2.  Add unit tests and, for numerical methods, a known-truth or
    cross-backend test.
3.  Preserve experimental units, constraints, random structures and
    response support.
4.  Do not select models solely by p-value, AIC, BIC or one prediction
    metric.
5.  Add a reference to `references/package_references.bib` when a method
    depends on published theory.
6.  Mark optional backends explicitly and never silently downgrade an
    analysis.
7.  Run the complete local validation protocol before proposing a
    release.
8.  Do not include copyrighted benchmark data unless distribution rights
    are documented.
