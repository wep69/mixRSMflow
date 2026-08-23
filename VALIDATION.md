# mixRSMflow 0.1.0.9000 Validation Report

Validation date: **2026-08-13** (static) / local runtime validation
**2026-08-15**  
Artifact class: **R source snapshot**

## 1. Environment

The static audit was produced in an environment without R. The **local
runtime validation** was subsequently executed on Windows 10/11 x64 with
R 4.6.0, Rtools45, Pandoc 3.10 and MiKTeX (LaTeX). Its full evidence
trail — environment records, test results, the frozen numerical battery,
vignette builds, clean library installation, `R CMD check --as-cran`
logs, graphics, and backend smoke tests — is archived in the validation
dossier and summarized in `LOCAL_VALIDATION_RESULTS.md`.

## 2. Files and scientific scope inspected

The source tree contains:

- `DESCRIPTION`, `NAMESPACE`, MIT license, NEWS and repository metadata;
- 18 R source files;
- 47 exported public functions and 29 registered S3 methods;
- a 71-entry capability registry;
- 77 prebuilt Rd help files, including all 47 public functions;
- executable examples embedded in the roxygen source and in all 47
  public-function Rd pages;
- 22 vignettes covering geometry, designs, constrained regions, models,
  diagnostics, effects, optimal design, mixture-process workflows,
  blocking/split plots, multiresponse optimization, uncertainty,
  graphics, sequential design, modern methods, teaching, state of the
  art, validation, and reproducibility;
- 8 `testthat` files;
- frozen golden/simulation inputs and a validation-battery script;
- metadata verification records, software-ecosystem audit, method gates,
  offline installation documentation, CI workflows, and local release
  scripts.

## 3. Static structural audit

Command executed:

``` text
python tools/static_audit.py
```

Result: **PASS**.

Recorded in `STATIC_AUDIT.json`:

- 47 exports;
- 29 S3 methods;
- 146 R function definitions;
- 22 vignettes;
- 8 test files;
- 78 Rd aliases;
- no missing required DESCRIPTION fields detected by the static checker;
- no unbalanced delimiter issue detected by the static checker;
- no exported function missing a source definition;
- no registered S3 method missing a source definition;
- no NAMESPACE entry missing an Rd alias;
- no undeclared namespace-qualified call detected by the checker;
- no raw textbook-data marker detected in package source/data/vignettes.

The maintainer address is deliberately a non-routable placeholder and is
reported by the audit. It must be replaced before a real release.

## 4. Static API audit

Command executed:

``` text
python tools/static_api_audit.py
```

Result: **PASS**.

The checker inspected 469 calls to exported functions across source
files, README, vignettes, tests, validation scripts, and data-generation
scripts and compared 486 named arguments against source-level function
formals. No unknown named argument remained after corrections.

This audit caught and corrected three documentation/test API
inconsistencies during construction:

- `direction` corrected to `dir` in constrained
  [`mix_spec()`](https://wep69.github.io/mixRSMflow/reference/mix_spec.md)
  examples/tests;
- `steps` corrected to `n` for
  [`mix_effects()`](https://wep69.github.io/mixRSMflow/reference/mix_effects.md);
- `iterations` corrected to `max_iter` for
  [`mix_optimal_design()`](https://wep69.github.io/mixRSMflow/reference/mix_optimal_design.md).

## 5. Rd/source signature audit

Command executed:

``` text
python tools/static_rd_audit.py
```

Result: **PASS**.

All 47 exported functions have prebuilt Rd usage formals matching the
source-level function formals under the static textual comparison.
Result is stored in `STATIC_RD_AUDIT.json`.

## 6. Documentation example audit

All 47 public exports have:

- a source roxygen `@examples` block; and
- a prebuilt Rd `\examples{}` block.

Optional or computationally expensive backends are guarded in examples.
Bayesian `brms` fitting is shown inside a non-executing example because
CRAN examples must not trigger a Stan compilation by default. Shiny is
guarded by [`interactive()`](https://rdrr.io/r/base/interactive.html).

## 7. Numerical and statistical validation assets supplied

The source snapshot contains:

- `inst/extdata/golden_scheffe_quadratic.csv`;
- `inst/extdata/golden_constrained.csv`;
- `inst/extdata/simulation_scenarios.csv` with frozen scenarios S01-S12;
- `inst/scripts/run_validation_battery.R`;
- unit/integration/error tests in `tests/testthat/`.

These assets are supplied for runtime validation but were **not
executed** here because R is unavailable.

## 8. Runtime checks

Status: **NOT RUN in this environment**.

The following claims are intentionally not made:

- package can be parsed by R without error;
- examples run successfully;
- all `testthat` tests pass;
- vignettes render successfully;
- optional backends execute successfully;
- package installs into a clean R library;
- `R CMD build` succeeds;
- `R CMD check --as-cran` succeeds;
- pkgdown site builds successfully.

No runtime result has been fabricated.

## 9. Local validation workflow supplied

Windows:

``` powershell
Set-Location <path-to-mixRSMflow_0.1.0.9000>
.\VALIDATE_WINDOWS.ps1
```

Unix-like systems:

``` bash
cd <path-to-mixRSMflow_0.1.0.9000>
./VALIDATE_UNIX.sh
```

Both route to `inst/scripts/validate_local.R`. That script performs the
release sequence using the local R environment and does not silently
download dependencies.

The intended sequence is:

1.  regenerate documentation with roxygen2;
2.  run `testthat`;
3.  build vignettes;
4.  build a source tarball with R tooling;
5.  install into a temporary clean library;
6.  execute the frozen validation battery;
7.  run `rcmdcheck` with `--as-cran`.

## 10. Scientific method gates

See `inst/METHOD_GATES.md`. Important boundaries include:

- exact historical double-Scheffé coefficient mapping is not claimed
  without an inspectable defining equation;
- historical ACED internals are not emulated line for line;
- [`mix_imse()`](https://wep69.github.io/mixRSMflow/reference/mix_imse.md)
  implements an explicit variance plus squared-bias IMSE and is not
  labelled as an unverified historical subset heuristic;
- Cornell textbook datasets are not redistributed;
- Figure 10.1/10.2-style graphics are newly computed from fitted
  surfaces rather than copied;
- Bayesian, mixed-model, GP, Plotly and Shiny backends remain
  runtime-pending in this environment.

## 11. Metadata validation

Bibliographic verification is stored in:

- `inst/metadata/reference_verification.csv`;
- `inst/METADATA_VERIFICATION.md`;
- `references/package_references.bib`;
- `references/package_references.ris`.

Current competing-software status is stored in
`inst/metadata/software_ecosystem.csv` and is explicitly dated
2026-08-13.

## 12. Overall result

**Static source-snapshot gate: PASS.**  
**R runtime gate: NOT RUN.**  
**CRAN release gate: PENDING.**

The artifact is suitable for transfer to an R workstation for runtime
validation. It must not yet be described as a CRAN-ready or
runtime-certified release.
