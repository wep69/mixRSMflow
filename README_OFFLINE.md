# Offline installation strategy

`mixRSMflow` is designed so that the statistical core does not require network access at run time. Optional engines are declared in `Suggests` and are used only when the corresponding feature is requested.

## Core packages

R itself supplies the recommended/base packages used by the core. The additional mandatory imported packages are `ggplot2` and `rlang`, together with their recursive dependencies.

## Optional feature groups

- optimal-design interoperability: `AlgDesign`, `skpr`
- correlated/mixed models: `nlme`, `lme4`
- Bayesian models: `brms`
- Gaussian-process Bayesian optimization: `DiceKriging`
- interactive graphics: `plotly`
- ternary graphics interoperability: `ggtern`, `Ternary`
- reporting/interface: `rmarkdown`, `shiny`
- development and validation: `devtools`, `roxygen2`, `testthat`, `rcmdcheck`, `vdiffr`, `knitr`

## Prepare on an internet-connected R installation

Use a clean folder and the same R major/minor series intended for the offline computer. Download the required package archives and **all recursive dependencies** with a dependency resolver such as `pak` or `tools::package_dependencies`. Do not assume that copying only the directly named packages is sufficient.

For Windows, prefer matching CRAN binary ZIPs when available. For source packages containing compiled code, the offline computer also needs the matching Rtools toolchain and any native system libraries required by those packages.

## Install on the offline computer

Place downloaded archives in one directory, for example `D:\\mixRSMflow-offline\\packages`, then run the supplied installer:

```powershell
Rscript inst/scripts/install_offline.R "D:/mixRSMflow-offline/packages"
```

Finally install the built `mixRSMflow_<version>.tar.gz` or install the source snapshot with `remotes::install_local()` after all dependencies are present.

No package download is performed by `install_offline.R`.
