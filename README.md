# Trade, Structural Change, and Labour Markets in Emerging Economies

This repository brings together six projects that share a common empirical focus: how globalisation, trade shocks, and structural transformation shape labour market outcomes across BRICS nations and other emerging economies.

Each project uses a distinct analytical tool — Python, STATA, R, web scraping, NLP/text analysis, and geospatial visualisation — but they are designed as a coherent body of work rather than isolated exercises. Together, they reflect core methodological competencies in quantitative economic research.

---

## Portfolio Overview

| # | Project | Tool | Theme | Status |
|---|---------|------|-------|--------|
| 1 | [The China Shock in Emerging Markets](./01_china_shock_emerging_markets/) | Python | Replicating & extending Autor, Dorn & Hanson (2013) to an emerging market context | 🔄 In Progress |
| 2 | [Exchange Rate Volatility and Export Margins](./02_exchange_rate_export_margins/) | STATA | Panel gravity evidence from BRICS on trade flow responses to currency volatility | ✅ Complete |
| 3 | [Labour Market Polarisation Across Indian Districts](./03_labour_polarisation_india/) | R | Distributional analysis of structural change and trade exposure using PLFS 2017-18 to 2023-24 | ✅ Complete |
| 4 | [Scraping Central Bank Communications](./04_central_bank_scraper/) | Web Scraping | A structured dataset of 302 BRICS monetary policy statements (1996–2026) | ✅ Complete |
| 5 | [Hawkish or Dovish? Monetary Policy Sentiment Across BRICS](./05_monetary_policy_sentiment/) | Text2Data / NLP | Sentiment analysis and LDA topic modelling on central bank communications | ✅ Complete |
| 6 | [Mapping Trade Exposure and Structural Change](./06_trade_exposure_maps/) | Geospatial | District-level visualisation of structural change and trade infrastructure proximity across India | ✅ Complete |

---

## Thematic Spine

The portfolio is organised around three connected questions:

1. **Trade shocks and labour markets** — How do import competition and export volatility translate into employment and wage changes at the local level in emerging economies? (Projects 1, 2, 3)

2. **Central bank communication and monetary fragmentation** — How have BRICS central banks communicated policy amid currency fragmentation and trade disruptions, and can text data reveal diverging monetary stances? (Projects 4, 5)

3. **Geography of structural change** — Where, spatially, are the effects of trade and structural transformation concentrated? (Project 6)

Projects 4 and 5 form a deliberate pipeline: Project 4 builds the dataset, Project 5 analyses it. Project 6 provides the spatial and visual layer that ties Projects 1–3 together — the geographic dimension of structural transformation that regression tables cannot convey.

Projects 1, 3, and 6 form a connected empirical programme on Indian districts. Project 6 establishes where districts sit relative to trade infrastructure and constructs the baseline employment panel. Project 3 documents the labour market outcomes — polarisation, skill-group shifts, urban-rural gaps. Project 1 is the identification step: it uses shift-share IV to establish whether those outcome patterns are causally driven by Chinese import competition. A reader following the three projects in sequence sees one complete research design, not three separate exercises.

---

## Tools & Methods

- **Python** — pandas, statsmodels, linearmodels, matplotlib, BeautifulSoup, spaCy, gensim, PyMuPDF, geopandas, mapclassify, shapely, pyproj
- **STATA** — panel data estimation (`ppmlhdfe`, `reghdfe`), PPML gravity, high-dimensional fixed effects, rolling volatility construction, `esttab` output
- **R** — haven, tidyverse, ggplot2, fixest, patchwork, sf, R Markdown
- **Web Scraping** — BeautifulSoup, requests, Selenium
- **NLP** — Loughran-McDonald financial dictionary, FinBERT, LDA topic modelling (gensim)
- **Geospatial** — geopandas, mapclassify, matplotlib, shapefiles, GeoPackage

---

## Data Sources

- CEPII BACI HS92 (V202601) — harmonised bilateral trade flows, 1995–2024
- IMF International Financial Statistics — monthly exchange rates, domestic currency per USD
- CEPII GeoDist — bilateral gravity controls (distance, language, colonial links, contiguity)
- PLFS (Periodic Labour Force Survey, MOSPI) — Indian employment surveys, 2017-18 to 2023-24
- SARB, RBI, Bank of Russia — central bank monetary policy statements (scraped + PDF)
- BIS CBSPEECHES database — PBOC communications
- SHRUG v2.1.pakora (Asher, Lunt, Matsuura & Novosad, 2021) — Indian district-level Economic Census and Population Census data
- DataMeet Community Maps — Census 2011 district boundary shapefiles
- Indian Ports Association / Ministry of Commerce / DPIIT — trade infrastructure coordinates

---

## Project 1 — The China Shock in Emerging Markets

**Status: 🔄 In Progress — Data Assembly**

Three-notebook Python analysis applying the Autor, Dorn and Hanson (2013, AER) shift-share identification strategy to Indian districts. This is the culminating project of the portfolio and the identification centrepiece of the three-project Indian district programme (Projects 1, 3, 6). Projects 3 and 6 built the data infrastructure — district-level labour market outcomes and baseline employment shares respectively. Project 1 is where those inputs are assembled into a causal research design.

### Research Question

Does exposure to Chinese import competition causally reduce non-agricultural employment, wages, and formal-sector employment in Indian districts, and does the effect vary by skill group and trade infrastructure access?

### Identification Strategy

The core identification challenge is endogeneity: districts declining for reasons unrelated to trade simultaneously experience rising Chinese imports and falling employment. OLS conflates the causal effect with pre-existing regional decline.

The solution is a Bartik shift-share instrument with two components. The **shares** are each district's 2005 Economic Census industry composition — predetermined twelve years before the outcome period, reflecting long-run comparative advantage rather than recent adjustment. The **shifts** are national-level changes in Chinese exports by industry, measured using Chinese exports to comparison countries (USA, Germany, Japan, Australia, Canada) rather than India-specific flows. This purges the instrument of India-specific demand shocks while retaining the supply-side variation from China's post-WTO productivity expansion. The instrument is the inner product of shares and shifts:

```
Z_it = Σⱼ (L_ij,2005 / L_i,2005) · (ΔM_other,jt / L_j,2005)
```

The twelve-year gap between the 2005 baseline shares and the 2017 outcome period is a deliberate design choice following Goldsmith-Pinkham, Sorkin and Swift (2020): more pre-determined shares are less likely to be correlated with contemporaneous shocks. Standard errors are clustered at the industry level following Adao, Kolesár and Morales (2019) — the level at which the identifying variation (the shifts) operates.

### Data Pipeline

**Pre-notebook R steps (complete):** The PLFS-Census 2011 district crosswalk (`plfs_census2011_crosswalk.csv`) was constructed by mapping PLFS state-district codes to Census 2011 district names. PLFS assigns district codes as sequential integers in alphabetical order of Census 2011 district names within each state — verified empirically against Tamil Nadu (31 districts, code 14 = Namakkal confirmed absent from sample), Uttar Pradesh (61 of 75 districts sampled), and Madhya Pradesh (45 of 51 districts sampled). The crosswalk covers 715 districts with 100% match rate for the 2017-18 to 2022-23 analysis rounds. Wage aggregation and outcome panel collapse from Project 3 RDS files are the remaining pre-notebook steps.

**notebook_01_data_assembly.ipynb:** Loads SHRUG EC 2005 district × industry employment matrix from Project 6. Downloads and cleans Chinese export data from BACI by HS industry for comparison countries and India. Applies HS-to-NIC 2004 concordance (every aggregation decision documented). Loads PLFS district-round outcomes from Project 3. Constructs shift-share instrument and actual import penetration measure. Merges all sources on harmonised 2011 district boundaries. Quality checks throughout.

**notebook_02_descriptive_analysis.ipynb:** Maps predicted import exposure across Indian districts using geopandas, inheriting the spatial infrastructure from Project 6. Maps labour market outcomes from Project 3 alongside exposure. Documents the industry composition of most- and least-exposed districts. Produces binscatter plots of the raw instrument-outcome relationship. Summary statistics table formatted in working-paper style.

**notebook_03_regression_analysis.ipynb:** First stage diagnostics (Kleibergen-Paap F-statistic, partial R², first-stage scatter). OLS baseline reported with endogeneity caveat. IV primary results for non-agricultural employment share, log wages, and informality. Skill-group heterogeneity connecting to Project 3 polarisation findings. Trade infrastructure heterogeneity interacting with port, SEZ, and corridor proximity from Project 6. Robustness checks: alternative comparison country sets, alternative clustering, COVID round exclusion, alternative baseline year.

### Panel Structure

| Dimension | Value |
|-----------|-------|
| Unit of observation | District × PLFS round |
| Districts (balanced panel) | 640 |
| PLFS rounds | 6 (2017-18 to 2022-23) |
| Baseline year for instrument shares | 2005 Economic Census |
| Comparison countries for shifts | 5 (USA, DEU, JPN, AUS, CAN) |
| Primary regression N | ~3,840 |

### Key Findings

*(To be completed after notebook_03_regression_analysis.ipynb)*

### Outputs

| File | Description |
|---|---|
| `data/plfs_census2011_crosswalk.csv` | PLFS code → Census 2011 district name (715 districts, complete) |
| `data/analysis_dataset.csv` | Final merged analysis dataset — district × round, instrument + outcomes |
| `notebook_01_data_assembly.ipynb` | Data assembly and instrument construction |
| `notebook_02_descriptive_analysis.ipynb` | Maps, binscatters, summary statistics |
| `notebook_03_regression_analysis.ipynb` | OLS, IV, heterogeneity, robustness |
| `Project1_Documentation.docx` | Full session-by-session documentation |

---

## Project 2 — Exchange Rate Volatility and Export Margins

**Status: ✅ Complete — 3 Do-Files**

Three-do-file STATA gravity analysis examining whether bilateral exchange rate volatility affects BRICS bilateral trade at the intensive and extensive margins, using a panel of 5 BRICS exporters, up to 232 partners, and 23 years (2000–2022).

### Research Question

Does bilateral exchange rate volatility reduce how much BRICS economies export to their partners, and whether they trade at all, after controlling for multilateral resistance and all time-invariant bilateral characteristics?

### Data Pipeline

**01_clean.do** loads and processes three raw data sources. The BACI HS92 loop processes 23 annual CSV files (7–11 million rows each), filtering immediately to BRICS exporters and collapsing to bilateral annual totals — runtime approximately 10 minutes. The IFS exchange rate section filters 902,668 raw rows to the monthly period-average domestic-currency-per-USD series using three simultaneous conditions, constructs bilateral cross-rates via `joinby`, computes rolling 12-month standard deviations using `rangestat`, and collapses to December annual observations. Outputs: `brics_trade_panel.dta` (23,940 obs) and `volatility_panel.dta` (20,565 obs).

**02_merge.do** merges the two panels (1:1 on exporter-importer-year), merges GeoDist gravity controls (m:1 on pair), and generates all analysis variables — `ln_trade`, `trade_dummy`, `ln_distw`, `pair_id`, `exporter_year`, `importer_year`, `russia_post22`. Output: `master_panel.dta` (24,579 obs, 16 variables).

**03_analysis.do** runs five regression specifications and exports three formatted results tables via `esttab`.

### Specification

The primary specification is PPML with three-way fixed effects — pair (`φ_ij`), exporter × year (`γ_it`), and importer × year (`δ_jt`) — estimated with `ppmlhdfe`. These absorb multilateral resistance (Anderson & van Wincoop 2003) and all time-invariant bilateral characteristics without requiring gravity controls to be entered explicitly. Log-OLS with the same fixed effects is reported as a robustness check. An LPM for the extensive margin is documented as infeasible (see Key Findings).

### Key Findings

**Primary result — null at the intensive margin.** Exchange rate volatility has no statistically significant effect on BRICS bilateral trade under three-way fixed effects:

| Specification | β₁ | SE | p | N |
|---|---|---|---|---|
| (1) PPML — full sample | +0.490 | 0.835 | 0.557 | 19,914 |
| (2) Log-OLS — full sample | -1.823 | 1.316 | 0.166 | 19,914 |
| (3) LPM | — | — | — | Infeasible |

The Pseudo R² of 0.9951 indicates the three-way FE absorb almost all variation in trade — the effective within-pair identifying variation for volatility is narrow with five exporters and 23 years.

**Russia outlier.** The positive PPML sign is driven by Russia post-2022. Dropping the 197 post-sanctions Russia observations flips the PPML coefficient to −0.546 (p = 0.517) — negative and directionally consistent with theory, but still insignificant:

| Specification | Full sample | Excl. Russia 2022+ |
|---|---|---|
| PPML | +0.490 | -0.546 |
| Log-OLS | -1.823 | -1.461 |

**BRICS heterogeneity.** The interaction specification recovers country-specific effects. Russia's interaction (vol_rus) is the only significant coefficient (+0.451, p = 0.037), reflecting the sanctions endogeneity problem — extreme volatility and trade redirection toward non-sanctioning partners are both consequences of the same shock. Brazil, China, and India all show the expected negative sign, consistent with regime-specific predictions.

**Extensive margin — LPM infeasible.** The 639 zero-trade observations are concentrated in pairs that never trade across the full 23-year panel. Pair fixed effects perfectly predict `trade_dummy` for these pairs, leaving no within-pair variation for volatility to explain.

**Honest interpretation.** The null result is consistent with the aggregate gravity literature (Tenreyro 2007; Head & Mayer 2014) and reflects the demanding identification requirement of three-way fixed effects with a small exporter panel. The direction of the estimated effect is consistently negative once the Russia 2022 outlier is accounted for.

### Outputs

| File | Description |
|---|---|
| `brics_trade_panel.dta` | 23,940 obs — bilateral annual trade flows, BRICS exporters |
| `volatility_panel.dta` | 20,565 obs — annual bilateral volatility measures |
| `master_panel.dta` | 24,579 obs — fully merged analysis dataset, 16 variables |
| `output/results_table.csv` | Primary results — PPML and log-OLS, full sample |
| `output/sensitivity_table.csv` | Sensitivity — excluding Russia post-2022 |
| `output/heterogeneity_table.csv` | BRICS country-specific volatility interactions |
| `Project2_Documentation - 01_clean.docx` | Full documentation for 01_clean.do |
| `Project2_Documentation - 02_merge.docx` | Full documentation for 02_merge.do |
| `Project2_Documentation - 03_analysis.docx` | Full documentation for 03_analysis.do |

---

## Project 3 — Labour Market Polarisation Across Indian Districts

**Status: ✅ Complete — All 6 Notebooks**

Six-notebook R analysis pipeline examining structural change in Indian labour markets across 640 districts using seven rounds of PLFS (2017-18 to 2023-24). The project connects directly to Project 6: the district-level trade exposure panel from Project 6 is merged into the regression notebook at 96% coverage. Project 3 also provides the labour market outcome panel consumed by Project 1's shift-share IV estimation.

### Research Questions
How do employment structures vary across Indian districts, how do they differ by gender and sector, and does proximity to trade infrastructure correlate with non-agricultural employment within states?

### Data Pipeline

The PLFS is distributed by MOSPI in a proprietary Nesstar binary format for most rounds. Five rounds (2017-18, 2020-21, 2021-22, 2022-23, 2023-24) were converted from Nesstar binary to Stata using the `nesstar-converter` Python package (v1.0.3, requires Python >= 3.10). Two rounds (2018-19, 2019-20) were available as direct Stata downloads. All 14 person-level files (7 urban, 7 rural) were harmonised in R using explicit variable renaming crosswalks resolving two naming conventions (`_per_fv`/`_per_rv` for direct downloads vs `_perv1`/`_perrv` for converted files).

### Key Methodological Finding — NCO Coding Break

A systematic occupation coding break occurs in PLFS between 2020-21 and 2021-22. NCO code 121 (Business Services Managers) accounts for 36-40% of rural employed workers and 13-17% of urban employed workers in rounds 2017-18 through 2020-21, falling to under 12% from 2021-22 onwards following a MOSPI enumerator guidance revision. This makes the three-way skill classification (high: NCO 1-3; middle: NCO 4,5,7,8; low: NCO 6,9) non-comparable across the revision boundary. All primary analysis uses the agricultural versus non-agricultural binary classification (agricultural = NCO groups 6 and 9), which is internally consistent across all seven rounds.

A related coding anomaly affects urban areas throughout: NCO code 611 (Market Gardeners) accounts for approximately 42% of urban employed workers, producing an urban agricultural share of ~62% — the inverse of economic reality. Both anomalies reflect NCO 2015 coding quality limitations that are documented explicitly rather than overlooked.

### Notebook 1 — Data Loading and Harmonisation
Resolves three naming inconsistencies across rounds, applies an employment status filter retaining 1,015,760 employed workers from 6.3 million raw observations, applies skill classification, and saves `plfs_clean.rds`. The 2017-18 urban sex variable has 49.8% missing values due to the rotating panel visit structure — documented and excluded from gender analysis.

### Notebook 2 — District-Level Aggregation
Constructs the district-level panel with employment shares by skill group and by agricultural/non-agricultural classification, separately for urban and rural sectors and by sex. Applies a balanced panel filter (districts present in all seven rounds) and minimum cell size threshold (emp_n >= 25). Saves `plfs_skill_panel.rds` and `plfs_agri_panel.rds`.

### Notebook 3 — Polarisation Analysis
National skill share trends confirm the NCO coding break dominates apparent polarisation signals. The low-skill share (NCO groups 6 and 9) is the only internally consistent component — rural: 14-15%, urban: 61-63% throughout. The agricultural/non-agricultural series is flat nationally, with substantial cross-district variation (SD ~13% rural, ~20% urban) that is stable across rounds. The COVID-19 shock produces no aggregate structural shift in either sector, though district-level changes have a standard deviation of 13-14 percentage points — heterogeneous but offsetting.

### Notebook 4 — Gender Decomposition
Within employed women, the non-agricultural share falls from 81% to 76% in rural areas and 31% to 24% in urban areas between 2017-18 and 2023-24, while male shares are stable or rising. The urban gender gap widens from 11 to 19 percentage points over the panel. Female district-level estimates are available for only 15-20% as many districts as male, reflecting low female LFPR — itself a substantive finding. The widening gap is consistent with the feminisation of agriculture documented in the Indian labour economics literature, though differential NCO coding bias cannot be excluded.

### Notebook 5 — Urban-Rural Decomposition
Urban and rural non-agricultural share distributions are almost entirely non-overlapping (rural peaks near 90%, urban near 25-45%). Within-district correlation between urban and rural non-agricultural shares is r = 0.255, indicating weak integration between the two sectors within the same geographic unit. The urban-rural gap varies from 4 percentage points (Delhi) to 62 points (Meghalaya), with southern states showing systematically smaller gaps than north-eastern and central Indian states.

### Notebook 6 — Trade Exposure Regression
Merges 616 of 640 districts (96.25% match rate) from the PLFS panel with the Project 6 trade exposure panel using the Census 2011 sequential censuscode. OLS regressions with state fixed effects and state-clustered standard errors:

| Variable | Urban β | Urban p | Rural β | Rural p |
|---|---|---|---|---|
| Log distance to port | −0.031 | 0.025* | −0.033 | 0.002** |
| Log distance to SEZ | −0.026 | 0.014* | +0.009 | 0.382 |
| Any industrial corridor | −0.055 | 0.035* | −0.132 | <0.001*** |
| Adj. R² | 0.636 | — | 0.261 | — |

Port proximity is the most robust correlate — negative and significant in both sectors. Closer districts show higher non-agricultural employment shares within states, consistent with port access facilitating structural transformation.

### Outputs

| File | Description |
|---|---|
| `plfs_clean.rds` | Harmonised person-level dataset, 1,015,760 rows, 27 columns |
| `plfs_skill_panel.rds` | District × round × sector × sex skill shares, 70,728 rows |
| `plfs_agri_panel.rds` | District × round × sector × sex agri/non-agri shares, 50,091 rows |
| `plfs_census2011_crosswalk.csv` | PLFS code → Census 2011 district name, 715 districts (used by Project 1) |
| `notebooks/01_clean.html` through `06_regression.html` | Rendered R Markdown notebooks |

---

## Project 4 — Scraping Central Bank Communications

**Status: ✅ Complete**

Scrapers built for SARB, RBI, CBR, and PBOC (via BIS). The RBI website blocks programmatic year-filtering — 57 historical statements (2016–2025) were manually downloaded as PDFs and extracted using PyMuPDF, then merged with 6 scraped statements (2025–2026). Final dataset: 302 statements from four central banks spanning 1996–2026.

| Bank | Country | Statements | Coverage |
|------|---------|------------|----------|
| PBOC | China | 131 | 1996–2025 |
| RBI | India | 63 | 2016–2026 |
| SARB | South Africa | 57 | 2006–2026 |
| CBR | Russia | 51 | 2018–2026 |

Output: `04_central_bank_scraper/data/brics_mpc_statements_v2.csv`

---

## Project 5 — Monetary Policy Sentiment Across BRICS

**Status: ✅ Complete — All 3 Notebooks**

Three-notebook NLP pipeline on the 302-statement corpus.

### Notebook 1 — Text Cleaning and Preprocessing
Boilerplate stripping, SARB date repair, date parsing, spaCy lemmatisation and stopword removal. Output: `brics_mpc_cleaned.csv`

### Notebook 2 — Sentiment Analysis
**Layer 1 — Loughran-McDonald Dictionary (primary):** Net sentiment and uncertainty scores computed for all 302 statements.

**Layer 2 — FinBERT robustness check:** Run on a stratified 40-statement sample. Spearman correlation with LM net scores: 0.441 (p=0.004). Both methods produce identical bank-level sentiment rankings.

Key finding: post-2022 divergence between CBR (sharply more negative and uncertain) and PBOC (stable to improving) is the strongest event-driven signal in the dataset. Bank sentiment rankings — SARB ≈ CBR (most negative) > RBI > PBOC (most positive) — are consistent across both methods. The CBR sentiment collapse in 2022 aligns precisely with the rouble volatility spike documented in Project 2.

Output: `brics_mpc_sentiment.csv`

### Notebook 3 — LDA Topic Modelling
Nine topics identified via coherence scoring (k=9, c_v=0.505). Near-perfect bank-topic segregation: CBR → Monetary Policy Decisions, SARB → Inflation & Growth Outlook, RBI → Liquidity & Rate Decisions, PBOC → Financial Reform & Capital Markets.

Key finding: The **Global Economy & Currency** topic — characterised by vocabulary including crisis, currency, imbalance, trade, capital flows, and IMF — is assigned exclusively to PBOC and is the only PBOC topic with negative net sentiment (−0.008). When PBOC engages with international monetary dynamics, its tone turns negative — a signal consistent with China's exposure to trade fragmentation pressures.

Outputs: `brics_mpc_final.csv`, `lda_visualisation.html`, `topic_sentiment_interaction.png`

---

## Project 6 — Mapping Trade Exposure and Structural Change

**Status: ✅ Complete — All 4 Notebooks**

Four-notebook geospatial pipeline documenting structural change across 640 Indian districts between 1990 and 2013, and examining the spatial correlation between trade infrastructure proximity and the pace of structural transformation.

### Notebook 1 — Data Acquisition and Boundary Harmonisation
Loaded Census 2011 district shapefiles (DataMeet, 640 districts, EPSG:4326) and SHRUG Economic Census and Population Census modules. All rounds harmonised to 2011 boundaries via shrid-level crosswalk.

| Round | Districts Matched | Method |
|-------|------------------|--------|
| EC 1990 | 553 / 640 | shrid crosswalk to 2011 boundaries |
| EC 1998 | 639 / 640 | shrid crosswalk (99.3% shrid match rate) |
| EC 2005 | 636 / 640 | shrid crosswalk to 2011 boundaries |
| EC 2013 | 640 / 640 | Direct merge on pc11_district_id |

Output: `data/processed/districts_structural_change.gpkg` — 640 districts × 35 columns.

### Notebook 2 — Structural Change Maps
Key spatial finding: structural transformation in India was spatially concentrated and path-dependent. Coastal and urban districts led throughout. Manufacturing share declined across most districts even as total non-farm share rose, consistent with services-led premature deindustrialisation.

### Notebook 3 — Trade Exposure Proxies and Spatial Analysis

| Measure | Correlation with Non-Farm Share 2013 |
|---------|--------------------------------------|
| Distance to nearest major port (km) | r = −0.147, p < 0.001 |
| Distance to nearest major SEZ (km) | r = −0.128, p = 0.001 |

Output: `data/processed/districts_full_panel.gpkg` — 640 districts × 43 columns. Merged into Project 3 Notebook 6 at 96% coverage. The 2005 EC district × industry employment matrix extracted from this panel serves as the baseline shares input for Project 1's shift-share instrument.

### Notebook 4 — Publication-Quality Visualisation
Four publication-ready figures (PNG at 300 dpi + PDF) covering non-farm share evolution, manufacturing pathways, trade infrastructure proximity, and correlation scatter plots.

---

## Status

| Project | Status |
|---------|--------|
| 01 — China Shock in Emerging Markets (Python) | 🔄 In Progress — Data Assembly |
| 02 — Exchange Rate Volatility and Export Margins (STATA) | ✅ Complete — 3 Do-Files |
| 03 — Labour Market Polarisation Across Indian Districts (R) | ✅ Complete — All 6 Notebooks |
| 04 — Scraping Central Bank Communications | ✅ Complete |
| 05 — Monetary Policy Sentiment Across BRICS (NB1 + NB2 + NB3) | ✅ Complete |
| 06 — Mapping Trade Exposure and Structural Change (NB1–NB4) | ✅ Complete |

---