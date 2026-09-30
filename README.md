# Trade, Structural Change, and Labour Markets in Emerging Economies

Six empirical projects examine trade, labour markets, central-bank communications and economic geography. They combine Python, Stata, R, text analysis and geospatial methods. Results are presented with their measurement and identification limits; statistically insignificant coefficients are not evidence that an effect is zero.

## Portfolio

| Project | Approach | Scope and interpretation |
|---|---|---|
| [1 — China Shock in Emerging Markets](01_china_shock_emerging_markets/) | Python; shift-share IV | 617 Indian districts, six PLFS rounds, 3,675 observations; IV interpretation depends on identifying assumptions and inference limitations |
| [2 — Exchange Rate Volatility and Export Margins](02_exchange_rate_export_margins/) | Stata; PPML and log-OLS gravity | Five BRICS exporters, 2000–2022; observed trade flows, with no reliable extensive-margin estimate |
| [3 — Labour Market Polarisation](03_labour_polarisation_india/) | R; PLFS occupation panels | Seven rounds, 2017-18–2023-24; occupation-based proxy and coding-break limitations |
| [4 — Central-Bank Communications](04_central_bank_scraper/) | HTML/PDF extraction | 302 central-bank communications from four BRICS central banks, 1996–2026; heterogeneous document types |
| [5 — Monetary Policy Sentiment](05_monetary_policy_sentiment/) | LM dictionary, FinBERT, LDA | LM on 302 documents; FinBERT on a 40-document stratified sample; descriptive text patterns |
| [6 — Trade Exposure Maps](06_trade_exposure_maps/) | Python; geospatial analysis | 640 districts, 1990–2013; non-farm employment-to-population ratios and infrastructure correlations |

## Results and qualifications

### Project 1: shift-share IV

The instrument combines 2005 district industry composition with changes in Chinese exports to five comparison countries (USA, Germany, Japan, Australia and Canada). Comparison-country shifts are intended to reduce contamination from India-specific demand shocks; they do not establish exclusion or eliminate common global shocks.

The reported first stage uses weighted least squares with **HC3** standard errors: coefficient **0.125**, SE **0.017**, t = **7.32**, partial R² = **0.360**. No Kleibergen–Paap F-statistic or Stock–Yogo comparison is supported by the routine. The overall model F-test and squared instrument t-statistic are not labelled as KP diagnostics.

| Outcome | OLS | IV | IV SE | IV p |
|---|---:|---:|---:|---:|
| Outside-NCO-6/9 employment share (occupation proxy) | −0.015 | +0.051 | 0.056 | 0.364 |
| Log weekly wage (rural) | — | −0.220 | 0.168 | 0.191 |
| Middle-skill share | — | +0.023 | 0.055 | 0.680 |

These are the existing estimates, with separate state and year fixed effects, baseline employment weights and district-clustered IV standard errors. District clustering does not fully address dependence induced by shared industry shocks. Shift-share-appropriate inference remains outstanding; neither a definitive causal claim nor an automatic LATE interpretation is warranted.

### Project 2: observed bilateral trade

PPML: β = **+0.490**, SE = **0.835**, p = **0.557**; log-OLS: β = **−1.823**, SE = **1.316**, p = **0.166**. Both reported estimation samples contain **19,914** observations. The merged panel has **639 missing trade values**, not 639 validated zero flows. Missing values remain missing; an extensive-margin analysis requires a validated pair-year universe and an audit of absent BACI records.

Excluding Russian exporter observations in 2022 changes PPML to **−0.546** (p = **0.517**). This is consistent with confounding from sanctions and trade redirection but does not identify those mechanisms. Annual data remove all of 2022, not just months after February. Negative country interaction coefficients are deviations from South Africa, not necessarily negative total slopes.

### Project 3: occupation composition

The legacy `agri_nonagri` classification contrasts **NCO groups 6 and 9** with groups **1–5, 7 and 8**. Group 9 includes elementary occupations across industries; the measure is an occupation-based proxy, not an agricultural/non-agricultural industry split. Existing column names and category codes are retained to avoid breaking saved datasets. A NIC-based measure requires harmonising rural and urban industry fields and recomputing downstream results.

The existing port-distance coefficients for the outside-NCO-6/9 share are **−0.031** (urban, p = **0.025**) and **−0.033** (rural, p = **0.002**). These are conditional correlations for the proxy. Occupation coding breaks, survey geography and differences in the underlying survey files limit interpretation.

### Projects 4–5: communications and text analysis

The corpus contains **PBOC 131, RBI 63, SARB 57 and CBR 51** communications. PBOC material comes from BIS CBSPEECHES and includes speeches and broader communications; it is not a homogeneous collection of formal MPC statements. Forty-six SARB dates have year-level precision only.

LM dictionary scoring covers all **302** documents. FinBERT is a **40-document stratified check (10 per bank)** using the first 400 words with tokenizer truncation at 512 tokens. Its reported Spearman correlation with LM scores is **0.441** (p = **0.004**) in that selected sample, not full-corpus validation. LDA uses **k = 9**, reported coherence **0.505**. PBOC's Global Economy & Currency topic has a comparatively negative mean LM score (**−0.008**) in that topic structure; this does not by itself reveal policy stance or causal responses to geopolitical events.

### Project 6: denominators and baseline provenance

Non-farm employment divided by total population is a **non-farm employment-to-population ratio**, displayed per **1,000 residents**. Manufacturing employment divided by non-farm employment is the **manufacturing share of non-farm employment**. “Structural change” in the non-farm measure means an absolute change in the ratio, not an employment share or annualised growth rate. Port distance has the reported correlation **r = −0.147** with the 2013 ratio.

Project 1 constructs its own industry matrix from `ec05_shrid.csv` and the SHRUG Census 2011 district key stored under Project 6's raw-data directory. Its saved baseline has **628 districts and 29 manufacturing share columns**; **28** enter the final instrument after excluding SHRIC 27. The denominator is total covered non-farm employment, so manufacturing shares need not sum to one. Project 6's GeoPackage provides geography and infrastructure measures, not that industry matrix. The first-match treatment of duplicated geographic keys, particularly Delhi, remains a limitation.

## Reproducibility and getting started

See [REPRODUCIBILITY.md](REPRODUCIBILITY.md) for data locations, dependencies, working directories, execution order and runtime guidance, and [CORRECTIONS.md](CORRECTIONS.md) for validation and remaining recomputation needs.

- **Committed data:** Project 1 analysis and baseline CSVs; Project 3 processed RDS/CSV panels; Project 4 bank extracts and RBI PDFs; Project 5 cleaned/scored corpus; Project 6 processed GeoPackages.
- **Not committed:** Raw BACI annual files, IMF/GeoDist inputs for Project 2, raw PLFS person files, SHRUG modules and district boundary inputs, and the BIS bulk archive. Obtain these from CEPII, IMF, MoSPI, Development Data Lab, DataMeet and BIS respectively; preserve source terms and versions.
- **Run order:** Project 6 → Project 3 → Project 1 for the district programme; Project 4 → Project 5 for text analysis; Project 2 runs independently. Some descriptive and estimation stages can use committed processed data directly.
- **Runtime:** Offline corpus assembly takes seconds; the original Project 2 notes report approximately 10–11 minutes for cleaning, under one minute for merging and under four minutes for estimation. These are historical timings, not fresh benchmarks. Other pipelines depend on data size, hardware, model downloads and live websites.

Existing estimates and data values are preserved. Historical figures and Word documentation may retain old labels; the corrected READMEs and executable sources define the current interpretation. Stale rendered Project 3 HTML copies were removed so they do not compete with corrected Rmd sources.
