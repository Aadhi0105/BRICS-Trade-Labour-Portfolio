# Reproducibility guide

This repository preserves analysis snapshots, not a fully self-contained raw-data build. Corrections change interpretation, labels, paths and diagnostics without replacing empirical estimates. Do not interpret old notebook execution outputs or figure labels as updated inference. Run into a separate checkout/output location before replacing saved outputs.

## Environments

- Python: use a dedicated environment (Python 3.10+ is a practical starting point), then `python -m pip install -r requirements.txt`. Install the NLP model with `python -m spacy download en_core_web_sm`. The requirements list direct imports, not a tested version lock; the original environment was not recorded completely. FinBERT downloads `ProsusAI/finbert` through transformers; GPU/MPS availability affects runtime, and CPU can be used. Selenium requires Chrome and a compatible driver; webdriver-manager may download the driver.
- R: install `haven`, `tidyverse`, `labelled`, `janitor`, `srvyr`, `ggplot2`, `fixest`, `patchwork`, `sf`, `rmarkdown` and `knitr`. Rendering requires Pandoc. Raw PLFS conversion uses `nesstar-converter` if starting from source formats rather than prepared DTA files. Exact historical package versions are not locked.
- Stata: a licensed installation plus `ftools`, `reghdfe`, `ppmlhdfe`, `rangestat`, `estout` and `require` (SSC). Original Stata version is not specified. No Stata execution was performed in this correction pass.

## Data inventory

| Input | Provider | Expected location and availability |
|---|---|---|
| BACI HS92 V202601 annual CSVs | [CEPII BACI](https://www.cepii.fr/CEPII/en/bdd_modele/bdd_modele_item.asp?id=37) | `02_exchange_rate_export_margins/data/BACI_HS92_V202601/`; not committed. Project 2 uses 2000–2022, Project 1 uses 2005–2022. Include `country_codes_V202601.csv`. |
| Monthly IFS exchange-rate export | [IMF](https://data.imf.org/) | `02_exchange_rate_export_margins/data/ifs_exchange_rates.csv`; not committed. Code expects monthly XDC_USD / PA_RT identifiers and the original export schema. |
| GeoDist | [CEPII](https://www.cepii.fr/CEPII/en/bdd_modele/presentation.asp?id=6) | `02_exchange_rate_export_margins/data/dist_cepii.dta`; not committed. |
| PLFS person microdata | [MoSPI microdata](https://microdata.gov.in/) | `03_labour_polarisation_india/data/PLFS_Data_<round>/`; raw DTA files not committed. Exact round-specific names are in `01_clean.Rmd` and `build_wage_panel.R`. Processed RDS and outcome/wage/crosswalk CSVs are committed. |
| SHRUG v2.1.pakora EC/PCA and geographic keys | [Development Data Lab](https://www.devdatalab.org/shrug) | `06_trade_exposure_maps/data/raw/shrug/`; not committed. Follow module/file names in Project 6 notebook 1 and Project 1 notebook 1. The latter additionally needs EC2005 SHRIC columns in `shrug-ec05-csv/ec05_shrid.csv` and the Census 2011 district key joined on `shrid2`. |
| District boundaries | [DataMeet maps](https://github.com/datameet/maps) | `06_trade_exposure_maps/data/raw/shapefiles/`; supply the complete geometry and companion files expected by notebook 1. Processed district GeoPackages are committed. |
| HS–ISIC concordance | [WITS concordances](https://wits.worldbank.org/product_concordance.html) | Project 1 `data/JobID-6_Concordance_H0_to_I3.CSV` is referenced but absent; obtain an equivalent HS92-to-ISIC Rev.3 mapping with the expected columns. Processed HS6–SHRIC crosswalk is committed. |
| BIS speeches bulk archive | [BIS CBSPEECHES](https://www.bis.org/cbspeeches/download.htm) | Project 4 `data/raw/speeches.zip`; not committed. Saved PBOC extract is committed. New vintages may differ. |
| Central-bank extracts and RBI PDFs | Bank sources linked in [Project 4](04_central_bank_scraper/README.md) | Committed bank CSVs and 57 RBI PDFs permit offline corpus assembly. Original download URLs for those PDFs were not recorded. |
| LM dictionary | [Notre Dame Software Repository](https://sraf.nd.edu/loughranmcdonald-master-dictionary/) | Committed under Project 5 `data/lm_dictionary/`; preserve its usage terms. |

Raw source data are subject to their providers' terms. Repository code licensing does not replace data licences. Preserve downloaded versions and checksums locally. Do not fill missing trade values with zero without source-specific validation.

## Execution order and working directories

1. **Project 6:** open notebooks from `06_trade_exposure_maps/notebooks/` and run `notebook_1_data_acquisition` → `notebook_2_structural_change` → `notebook_3_trade_exposure` → `notebook_4_publication_maps`. Notebook 1 requires missing raw inputs; subsequent notebooks use processed GeoPackages, but some mapping sections still require raw geometry/infrastructure files. Do not assume the processed snapshot makes every cell self-contained.
2. **Project 3:** knit or execute Rmds with the working directory set to `03_labour_polarisation_india/notebooks/`: `01_clean` → `02_aggregate` → `03_polarisation` → `04_gender` → `05_urban_rural` → `06_regression`. The last requires Project 6's GeoPackage. Existing RDS files allow starting after cleaning/aggregation. Run helper R scripts from the repository root (`Rscript 03_labour_polarisation_india/data/build_plfs_crosswalk.R` and `build_wage_panel.R`); wage construction requires raw PLFS. Saved `plfs_outcomes_panel.csv` is committed, but its complete separate export recipe is not supplied as a standalone script.
3. **Project 1:** run `notebook_01_data_assembly` → `notebook_02_descriptive_analysis` → `notebook_03_regression_analysis`. Root discovery uses pathlib. Notebook 1 constructs its own industry baseline from raw SHRUG data and combines BACI, concordances and Project 3 outcomes. The saved analysis CSV allows regression review without rebuilding raw data; descriptive maps also require Project 6 geography. Manual crosswalks, first-match district-key handling and missing-industry assumptions remain parts of the historical construction.
4. **Project 2 (independent):** start Stata in the repository root or Project 2 directory and run `01_clean.do` → `02_merge.do` → `03_analysis.do` from `do-files/`. Each resolves the project directory and creates `log/` and `output/`. The entire `data/` input/intermediate collection is absent from this checkout; saved result tables alone cannot reproduce estimation. Missing trade remains missing. The unsupported LPM is disabled.
5. **Project 4:** offline snapshot reproduction: `python 04_central_bank_scraper/build_corpus.py --output /tmp/brics_mpc_rebuilt.csv` from the root. See its README for optional PDF extraction and live acquisition. Live notebook working directory: `04_central_bank_scraper/`.
6. **Project 5:** working directory `05_monetary_policy_sentiment/`; run `notebook.ipynb` → `notebook_2_sentiment.ipynb` → `notebook_3_lda.ipynb`. Committed v2/cleaned/scored data allow skipping upstream acquisition. FinBERT is a 40-document check, not full-corpus scoring; LDA seed 42 is recorded but does not replace a locked environment or a multi-seed stability analysis.

## Runtime expectations

The original Project 2 documentation reports approximately 10–11 minutes for BACI/IFS cleaning, under one minute for merge and under four minutes for estimation. These are historical machine-specific timings. Offline assembly of 302 communications is a small, seconds-scale task. Scraping has deliberate request/page delays and can take minutes or longer. PLFS/SHRUG/BACI assembly, spaCy preprocessing, model downloads and the LDA coherence sweep vary substantially with hardware and source size; no reliable full-run benchmarks are available. A complete end-to-end rerun was not performed for these corrections.

## Labels and preserved outputs

- Project 3's `agricultural`/`non_agricultural` category strings and Project 1's `nonagri_share` remain compatibility identifiers for NCO-6/9 versus other occupations. They are not NIC industry categories.
- Project 6's `nonfarm_share_*` fields contain employment per **1,000 population**, with nearest-Census denominators. `delta_nonfarm_*` is an absolute difference in those units. Manufacturing shares use non-farm employment as denominator.
- Saved PNG/PDF figures and historical Word documentation retain the original run and may contain superseded terminology. Read the corrected definitions before interpreting them. Updated notebook/Rmd plot labels apply on a future render. Project 3's stale compiled HTML was removed; underlying RDS/CSV results were preserved.
- Notebook outputs containing obsolete Project 1/6 claims and Project 4 local paths were cleared. Source cells, numerical results in READMEs, and underlying data remain available.
