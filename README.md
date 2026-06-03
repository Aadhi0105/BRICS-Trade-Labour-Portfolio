# Trade, Structural Change, and Labour Markets in Emerging Economies

This repository brings together six projects that share a common empirical focus: how globalisation, trade shocks, and structural transformation shape labour market outcomes across BRICS nations and other emerging economies.

Each project uses a distinct analytical tool — Python, STATA, R, web scraping, NLP/text analysis, and geospatial visualisation — but they are designed as a coherent body of work rather than isolated exercises. Together, they reflect core methodological competencies in quantitative economic research.

---

## Portfolio Overview

| # | Project | Tool | Theme | Status |
|---|---------|------|-------|--------|
| 1 | [The China Shock in Emerging Markets](./01_china_shock_emerging_markets/) | Python | Replicating & extending Autor, Dorn & Hanson (2013) to an emerging market context | ✅ Complete |
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

**Status: ✅ Complete — All 3 Notebooks**

Three-notebook Python analysis applying the Autor, Dorn and Hanson (2013, AER) shift-share identification strategy to Indian districts. This is the culminating project of the portfolio and the identification centrepiece of the three-project Indian district programme (Projects 1, 3, 6). Projects 3 and 6 built the data infrastructure — district-level labour market outcomes and baseline employment shares respectively. Project 1 assembles those inputs into a causal research design and estimates the effect of Chinese import competition on Indian district labour markets over 2017–2022.

### Research Question

Does exposure to Chinese import competition causally reduce non-agricultural employment, wages, and formal-sector employment in Indian districts, and does the effect vary by skill group and trade infrastructure access?

### Identification Strategy

The core identification challenge is endogeneity: districts declining for reasons unrelated to trade simultaneously experience rising Chinese imports and falling employment. OLS conflates the causal effect with pre-existing regional decline.

The solution is a Bartik shift-share instrument with two components. The **shares** are each district's 2005 Economic Census industry composition — predetermined twelve years before the outcome period, reflecting long-run comparative advantage rather than recent adjustment. The **shifts** are national-level changes in Chinese exports by industry, measured using Chinese exports to comparison countries (USA, Germany, Japan, Australia, Canada) rather than India-specific flows. This purges the instrument of India-specific demand shocks while retaining the supply-side variation from China's post-WTO productivity expansion. The instrument is the inner product of shares and shifts:

```
Z_it = Σⱼ (L_ij,2005 / L_i,2005) · (ΔM_other,jt / L_j,2005)
```

The twelve-year gap between the 2005 baseline shares and the 2017 outcome period is a deliberate design choice following Goldsmith-Pinkham, Sorkin and Swift (2020): more pre-determined shares are less likely to be correlated with contemporaneous shocks. Standard errors clustered at the district level in primary specifications.

### Data Pipeline

**Pre-notebook R steps (complete):** The PLFS-Census 2011 district crosswalk (`plfs_census2011_crosswalk.csv`) maps 715 PLFS district codes to Census 2011 district names with 100% match rate for the analysis rounds. Wage panel (`plfs_wage_panel.csv`) aggregated from raw PLFS DTA files across six rounds. Outcomes panel (`plfs_outcomes_panel.csv`) collapsed from Project 3 RDS files.

**notebook_01_data_assembly.ipynb:** Constructs the shift-share instrument from SHRUG EC 2005 district × industry employment (28 manufacturing SHRIC codes) and CEPII BACI Chinese export data (comparison countries and India, 2005–2022). Builds the HS6-to-SHRIC concordance via WITS HS-ISIC mapping. Assembles the final analysis dataset: 3,675 observations, 617 districts, 6 PLFS rounds.

**notebook_02_descriptive_analysis.ipynb:** Geographic maps of instrument and outcomes across 591 Indian districts. Industry composition analysis by instrument quartile. Binscatter plots of raw instrument-outcome correlations. Time series of mean instrument and outcomes by year. Working-paper summary statistics table.

**notebook_03_regression_analysis.ipynb:** First stage diagnostics, OLS baseline, IV primary results, alternative specifications, and robustness checks.

### Panel Structure

| Dimension | Value |
|-----------|-------|
| Unit of observation | District × PLFS round |
| Districts in analysis | 617 |
| PLFS rounds | 6 (2017-18 to 2022-23) |
| Observations | 3,675 |
| Baseline year for instrument shares | 2005 Economic Census (SHRUG) |
| Manufacturing SHRIC codes | 28 |
| Comparison countries for shifts | 5 (USA, DEU, JPN, AUS, CAN) |
| Regression weights | District baseline employment (2005 EC) |

### Key Findings

**First stage (strong instrument):**

| Diagnostic | Value | Threshold | Status |
|---|---|---|---|
| Coefficient on Z | +0.125 | Positive required | ✓ |
| t-statistic | 7.32 | >3.29 (p<0.001) | ✓ |
| KP F-statistic | ~53.5 | >10 (Stock-Yogo) | ✓ Strong |
| Partial R² | 0.360 | Meaningful | ✓ |

**Primary IV results (2SLS, state + year FEs, weighted by baseline employment):**

| Outcome | OLS | IV | SE | p |
|---|---|---|---|---|
| Non-agri employment share | −0.015 | +0.051 | 0.056 | 0.364 |
| Log weekly wage (rural) | — | −0.220 | 0.168 | 0.191 |
| Middle-skill share | — | +0.023 | 0.055 | 0.680 |

**Null result — honest interpretation:** The shift-share IV finds no statistically significant effect of Chinese import competition on Indian district labour markets over 2017-2022. The instrument is strong (F≈53.5) and the null is robust across alternative specifications. Within-state instrument variance is 38% of total — state fixed effects absorb 62% of identifying variation. Three explanations: (1) insufficient within-state variation after state FEs; (2) 5-year PLFS window too short for reallocation effects (ADH use 10 years); (3) India's higher informality limits detectability of formal employment effects. The wage point estimate (−0.220) is directionally consistent with ADH but does not survive conventional significance thresholds.

**Descriptive findings:**
- High-exposure districts geographically dispersed across Gujarat, Rajasthan, Maharashtra, UP/MP — good for within-state identification
- High-exposure districts more concentrated in machinery, chemicals, textiles, iron/steel; low-exposure in grain milling, tobacco/beedi, saw milling
- Instrument has substantial time-series variation (2019 trade war trough, 2021 post-COVID peak); outcomes stable over time

### Outputs

| File | Description |
|---|---|
| `data/analysis_dataset.csv` | Final merged dataset — 3,675 obs, 617 districts, 18 columns |
| `data/plfs_census2011_crosswalk.csv` | PLFS code → Census 2011 district name (715 districts) |
| `data/summary_statistics.csv` | Working-paper summary statistics table |
| `data/hs6_shric_crosswalk.csv` | HS6 → SHRIC industry concordance (4,138 codes, 28 SHRICs) |
| `data/shrug_ec05_baseline_shares.csv` | District baseline industry shares (628 districts, 28 SHRICs) |
| `figures/fig01_geographic_distribution.png` | Four-panel map: instrument, non-agri share, wages, port distance |
| `figures/fig02_industry_composition.png` | SHRIC shares by instrument quartile |
| `figures/fig03_binscatter.png` | Raw instrument-outcome correlations |
| `figures/fig04_time_series.png` | Mean instrument and outcomes by year |
| `figures/fig05_first_stage.png` | First-stage scatter: instrument vs actual import penetration |
| `figures/fig06_main_results.png` | OLS vs IV coefficient plot with 95% CIs |
| `notebook_01_data_assembly.ipynb` | Data assembly and instrument construction |
| `notebook_02_descriptive_analysis.ipynb` | Descriptive analysis |
| `notebook_03_regression_analysis.ipynb` | Regression analysis |

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

**Russia outlier.** Dropping post-sanctions Russia flips PPML to −0.546 (p=0.517) — negative, directionally consistent, still insignificant.

**Honest interpretation.** Null consistent with aggregate gravity literature. Direction consistently negative once Russia 2022 outlier removed.

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

Six-notebook R analysis pipeline examining structural change in Indian labour markets across 640 districts using seven rounds of PLFS (2017-18 to 2023-24). Project 3 also provides the labour market outcome panel consumed by Project 1's shift-share IV estimation.

### Key Findings

| Variable | Urban β | Urban p | Rural β | Rural p |
|---|---|---|---|---|
| Log distance to port | −0.031 | 0.025* | −0.033 | 0.002** |
| Log distance to SEZ | −0.026 | 0.014* | +0.009 | 0.382 |
| Any industrial corridor | −0.055 | 0.035* | −0.132 | <0.001*** |

Port proximity is the most robust correlate of non-agricultural employment share within states.

### Outputs

| File | Description |
|---|---|
| `plfs_clean.rds` | Harmonised person-level dataset, 1,015,760 rows, 27 columns |
| `plfs_skill_panel.rds` | District × round × sector × sex skill shares, 70,728 rows |
| `plfs_agri_panel.rds` | District × round × sector × sex agri/non-agri shares, 50,091 rows |
| `plfs_census2011_crosswalk.csv` | PLFS code → Census 2011 district name, 715 districts |

---

## Project 4 — Scraping Central Bank Communications

**Status: ✅ Complete**

302 statements from PBOC (131), RBI (63), SARB (57), CBR (51) spanning 1996–2026.

---

## Project 5 — Monetary Policy Sentiment Across BRICS

**Status: ✅ Complete — All 3 Notebooks**

LM dictionary sentiment, FinBERT robustness, LDA topic modelling (k=9, coherence=0.505). Key finding: PBOC's Global Economy & Currency topic carries uniquely negative sentiment (−0.008).

---

## Project 6 — Mapping Trade Exposure and Structural Change

**Status: ✅ Complete — All 4 Notebooks**

640 Indian districts, 1990–2013. Port distance r=−0.147 with non-farm share 2013. Output: `districts_full_panel.gpkg` (640 districts × 43 columns) — baseline shares input for Project 1.

---

## Status

| Project | Status |
|---------|--------|
| 01 — China Shock in Emerging Markets (Python) | ✅ Complete — All 3 Notebooks |
| 02 — Exchange Rate Volatility and Export Margins (STATA) | ✅ Complete — 3 Do-Files |
| 03 — Labour Market Polarisation Across Indian Districts (R) | ✅ Complete — All 6 Notebooks |
| 04 — Scraping Central Bank Communications | ✅ Complete |
| 05 — Monetary Policy Sentiment Across BRICS (NB1 + NB2 + NB3) | ✅ Complete |
| 06 — Mapping Trade Exposure and Structural Change (NB1–NB4) | ✅ Complete |

---
