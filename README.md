<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://img.shields.io/badge/%F0%9F%87%A9%F0%9F%87%AA_%F0%9F%87%B0%F0%9F%87%B7-Welfare_Chauvinism_in_Divided_Societies-c0392b?style=for-the-badge&labelColor=1a1a2e">
  <img alt="Welfare Chauvinism in Divided Societies" src="https://img.shields.io/badge/%F0%9F%87%A9%F0%9F%87%AA_%F0%9F%87%B0%F0%9F%87%B7-Welfare_Chauvinism_in_Divided_Societies-c0392b?style=for-the-badge&labelColor=1a1a2e">
</picture>

### The Role of National Identity in Social Policy Preferences

**Replication Package: Job-Training Conjoint Experiment**

*Ward & Denney (2025) &mdash; Policy and Society (Oxford University Press)*

</div>

[![DOI: Paper](https://img.shields.io/badge/DOI-10.1093%2Fpolsoc%2Fpuaf027-blue?style=flat-square)](https://doi.org/10.1093/polsoc/puaf027) [![Dataverse](https://img.shields.io/badge/Harvard%20Dataverse-10.7910%2FDVN%2FWYBIAK-C22A1A?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZD0iTTEyIDJMMiAyMmgyMEwxMiAyeiIgZmlsbD0id2hpdGUiLz48L3N2Zz4=)](https://doi.org/10.7910/DVN/WYBIAK) [![Open Science](https://img.shields.io/badge/Open_Science-Replication_Materials-brightgreen?style=flat-square&logo=opensourceinitiative&logoColor=white)](https://doi.org/10.7910/DVN/WYBIAK) [![R](https://img.shields.io/badge/R-%E2%89%A5_4.0-276DC3?style=flat-square&logo=r&logoColor=white)](#requirements) [![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey?style=flat-square)](https://creativecommons.org/licenses/by/4.0/)

---

> **This is the living version** of the replication archive permanently deposited at **[Harvard Dataverse](https://doi.org/10.7910/DVN/WYBIAK)**. The Dataverse record is the citable, non-editable version of record. This GitHub repository may receive updates, corrections, or extended analyses over time.
>
> **Cite the data as:** Denney, Steven. 2025. "Replication Data for: Welfare Chauvinism in Divided Societies: The Role of National Identity in Social Policy Preferences." Harvard Dataverse. https://doi.org/10.7910/DVN/WYBIAK.

---

## Overview

This package replicates the **job-training conjoint experiment** from:

> Ward, Peter and Steven Denney. 2025. "Welfare Chauvinism in Divided Societies: The Role of National Identity in Social Policy Preferences." *Policy and Society*. DOI: [10.1093/polsoc/puaf027](https://doi.org/10.1093/polsoc/puaf027)

The experiment investigates social discrimination against co-ethnic citizens in the context of providing support for job training in Germany and South Korea. Respondents evaluate hypothetical candidate profiles for a government job-training program, with the primary attribute of interest being the candidate's **origin at birth** -- whether from the former GDR (Eastern Germany) or North Korea, versus native regions and foreign origins. The design tests whether welfare chauvinism extends to intra-national exclusion of co-nationals from historically divided regions.

## Repository Structure

```
.
├── README.md
├── run_replication.R        # One-click: installs packages + runs analysis
├── Makefile                 # make → runs analysis from command line
├── code/
│   ├── analysis.R           # Full analysis (variable derivation → models → figures)
│   └── prepare_data.R       # Data provenance (requires original Qualtrics; not needed to replicate)
├── data/
│   ├── germany_job_training.csv
│   └── korea_job_training.csv
└── docs/
    ├── data_dictionary_germany.md
    └── data_dictionary_korea.md
```

## Data

Each CSV contains **raw survey responses** in the original language (German/Korean) alongside conjoint task data. One row = one candidate profile shown in a forced-choice task.

| Category | Variables |
|----------|-----------|
| **Identifiers** | `ResponseId`, `question_profile`, `candidate_choice` |
| **Conjoint attributes** | `Age`, `Family`, `Gender`, `Occupation`, `Record`, `Origin` |
| **Demographics** | `age`, `yob`, `female`, geographic location, `education`, ethnicity/political ID |
| **Survey items** | National identity strength, ethnocentrism items, policy attitudes |

All derived analysis variables (median splits, regional classifications, partisan groups) are constructed transparently in `code/analysis.R` from these raw inputs. See `docs/` for complete variable definitions and response value translations.

## Quickstart

```r
# Option 1: One-click (installs dependencies automatically)
source("run_replication.R")

# Option 2: Manual
install.packages(c("tidyverse", "ggthemes", "remotes"))
remotes::install_github("leeper/cregg")
source("code/analysis.R")
```

```sh
# Option 3: Command line
make
```

Outputs: `output/` (CSVs + session info) and `output/figures/` (PDF + PNG).

## Figure Mapping

### Main paper figures

| Paper Figure | Description | Output files |
|:------------:|-------------|--------------|
| 3 | Marginal means & AMCEs for Record and Origin | `amce_*_main`, `mm_*_main` |
| 4 | Origin × Record interaction AMCEs | `amce_origin_by_record_*` |
| 5 | Origin AMCEs for "No record" profiles only | `amce_*_main` (filtered) |
| 6 | Origin AMCEs by ethnocentrism subgroup | `mm_*_origin_by_ethnocentric` |
| 7 | Origin AMCEs by national identity strength | `mm_*_origin_by_natidstrong` |

### Supplementary Information (Appendix C)

| SI Figure | Description | Sample |
|:---------:|-------------|--------|
| C.1 | Marginal means (all attributes) | DEU / KOR |
| C.2 | Marginal means incl. East Germany | Ethnic Germans |
| C.3 | Assistance attitudes subgroups | DEU / KOR |
| C.4 | Regional subgroups | Germany |
| C.5 | Regional subgroups | South Korea |
| C.6 | Generational cohorts | Western Germany |
| C.7 | Education subgroups | Germany |
| C.8 | Education subgroups | South Korea |
| C.9 | Political identification | Germany |
| C.10 | Political identification | South Korea |

## Samples

| Country | Respondents | Tasks per respondent | Rows |
|---------|:-----------:|:--------------------:|:----:|
| Germany | 1,882 | 6 tasks × 2 profiles | 22,584 |
| South Korea | 1,768 | 7 tasks × 2 profiles | 24,752 |

## Requirements

- **R** >= 4.0 (tested with 4.5.1)
- [`tidyverse`](https://tidyverse.tidyverse.org/), [`cregg`](https://github.com/leeper/cregg), [`ggthemes`](https://jrnold.github.io/ggthemes/)

## License

This is an Open Access article distributed under the terms of the [Creative Commons Attribution License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/), which permits unrestricted reuse, distribution, and reproduction in any medium, provided the original work is properly cited. Please cite both the paper and the Dataverse deposit when reusing.
