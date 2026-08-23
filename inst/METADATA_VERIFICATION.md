# Reference and metadata verification

Verification date: **2026-08-13**

The reference audit follows the package-building rule that important methodological metadata should be checked against two sources whenever reasonably possible. The machine-readable record is `inst/metadata/reference_verification.csv`.

## Verified core references

- Cornell (2002), third edition of *Experiments with Mixtures*, DOI `10.1002/9781118204221`: bibliographic identity checked against the Wiley book record and the user-supplied pages from that edition.
- Brown, Donev & Bissett (2015), DOI `10.1080/00401706.2014.947003`: checked against Taylor & Francis and PubMed/PMC.
- Pradubsri, Chomtee & Borkowski (2019), DOI `10.1002/qre.2549`: checked against the publisher record used in the state-of-art review and the Consensus indexed record.
- Becerra & Goos (2021), DOI `10.1016/j.chemolab.2021.104395`: checked against ScienceDirect and the Consensus indexed record.
- Chatterjee & Lin (2023 issue; online 2022), DOI `10.1080/08982112.2022.2135444`: checked against Taylor & Francis and the Consensus indexed record.
- Becerra & Goos (2023), DOI `10.1016/j.foodqual.2023.104928`: checked against ScienceDirect and the Consensus indexed record.
- Cornell & Good (1970), DOI `10.1080/01621459.1970.10481084`: checked against the Taylor & Francis issue record and JSTOR's issue record.


## Additional classic references verified in this build

- Scheffé (1958), DOI `10.1111/j.2517-6161.1958.tb00299.x`: checked against Oxford Academic and Wiley.
- Becker (1968), DOI `10.1111/j.2517-6161.1968.tb00735.x`: checked against Oxford Academic and the Cornell/Wiley bibliography.
- Cox (1971), DOI `10.1093/biomet/58.1.155`: checked against Oxford Academic and JSTOR.
- Cornell & Ott (1975), DOI `10.1080/00401706.1975.10489367`: checked against an indexed DOI bibliographic record and the Cornell/Wiley bibliography.

## Software-ecosystem audit

Current software status is stored in `inst/metadata/software_ecosystem.csv`. The audit is dated **2026-08-13**. In particular, `mixexp` is recorded as removed from current CRAN on 2026-04-10 and retained only as a historical comparator; it is not a package dependency. The same table records the current versions/status inspected for `AlgDesign`, `skpr`, `Ternary`, `ggtern`, `DoE.wrapper`, `desirability2`, `OptimaRegion`, `pyDOE2`, `dexpy`, and `pyoptex`.

## Publisher-verified reference requiring a fresh independent check before a paper submission

- Kristoffersen & Smucker (2020), DOI `10.1080/08982112.2020.1722831`. Title, authors, volume, issue and pages were confirmed from Taylor & Francis. A second independent bibliographic source should be checked during the manuscript-release gate.

## Release rule

This audit is dated. Before CRAN release or manuscript submission, rerun metadata and software-ecosystem verification because package versions, archive status and bibliographic metadata can change.
