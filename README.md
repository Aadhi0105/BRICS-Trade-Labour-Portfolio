# Trade, Structural Change, and Labour Markets in Emerging Economies

This repository brings together six projects that share a common empirical focus: how globalisation, trade shocks, and structural transformation shape labour market outcomes across BRICS nations and other emerging economies.

Each project uses a distinct analytical tool — Python, STATA, R, web scraping, NLP/text analysis, and geospatial visualisation — but they are designed as a coherent body of work rather than isolated exercises. Together, they reflect core methodological competencies in quantitative economic research.

---

## Portfolio Overview

| # | Project | Tool | Theme |
|---|---------|------|-------|
| 1 | [The China Shock in Emerging Markets](./01_china_shock_emerging_markets/) | Python | Replicating & extending Autor, Dorn & Hanson (2013) to an emerging market context |
| 2 | [Exchange Rate Volatility and Export Margins](./02_exchange_rate_export_margins/) | STATA | Panel evidence from BRICS on trade flow responses to currency volatility |
| 3 | [Labour Market Polarisation Across Indian Districts](./03_labour_polarisation_india/) | R | Distributional analysis of employment and wage polarisation using NSS/PLFS data |
| 4 | [Scraping Central Bank Communications](./04_central_bank_scraper/) | Web Scraping | A structured dataset of 302 BRICS monetary policy statements (1996–2026) |
| 5 | [Hawkish or Dovish? Monetary Policy Sentiment Across BRICS](./05_monetary_policy_sentiment/) | Text2Data / NLP | Sentiment analysis and LDA topic modelling on central bank communications |
| 6 | [Mapping Trade Exposure and Structural Change](./06_trade_exposure_maps/) | Geospatial | District-level visualisation of structural change and trade infrastructure proximity across India |

---

## Thematic Spine

The portfolio is organised around three connected questions:

1. **Trade shocks and labour markets** — How do import competition and export volatility translate into employment and wage changes at the local level in emerging economies? (Projects 1, 2, 3)

2. **Central bank communication and monetary fragmentation** — How have BRICS central banks communicated policy amid currency fragmentation and trade disruptions, and can text data reveal diverging monetary stances? (Projects 4, 5)

3. **Geography of structural change** — Where, spatially, are the effects of trade and structural transformation concentrated? (Project 6)

Projects 4 and 5 form a deliberate pipeline: Project 4 builds the dataset, Project 5 analyses it. Project 6 provides the spatial and visual layer that ties Projects 1–3 together — the geographic dimension of structural transformation that regression tables cannot convey.

---

## Tools & Methods

- **Python** — pandas, statsmodels, matplotlib, BeautifulSoup, spaCy, gensim, PyMuPDF, geopandas, mapclassify, shapely, pyproj
- **STATA** — panel data estimation (xtset, xtreg, areg), IV regression, shift-share instruments
- **R** — tidyverse, ggplot2, fixest, R Markdown
- **Web Scraping** — BeautifulSoup, requests, Selenium
- **NLP** — Loughran-McDonald financial dictionary, FinBERT, LDA topic modelling (gensim)
- **Geospatial** — geopandas, mapclassify, matplotlib, shapefiles, GeoPackage

---

## Data Sources

- World Bank / UN Comtrade — bilateral trade flows
- NSS / PLFS — Indian employment and wage surveys
- SARB, RBI, Bank of Russia — central bank monetary policy statements (scraped + PDF)
- BIS CBSPEECHES database — PBOC communications
- SHRUG v2.1.pakora (Asher, Lunt, Matsuura & Novosad, 2021) — Indian district-level Economic Census and Population Census data
- DataMeet Community Maps — Census 2011 district boundary shapefiles
- Indian Ports Association / Ministry of Commerce / DPIIT — trade infrastructure coordinates

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

Key finding: post-2022 divergence between CBR (sharply more negative and uncertain) and PBOC (stable to improving) is the strongest event-driven signal in the dataset. Bank sentiment rankings — SARB ≈ CBR (most negative) > RBI > PBOC (most positive) — are consistent across both methods.

Output: `brics_mpc_sentiment.csv`

### Notebook 3 — LDA Topic Modelling
Nine topics identified via coherence scoring (k=9, c_v=0.505). Near-perfect bank-topic segregation: CBR → Monetary Policy Decisions, SARB → Inflation & Growth Outlook, RBI → Liquidity & Rate Decisions, PBOC → Financial Reform & Capital Markets.

Key finding: The **Global Economy & Currency** topic — characterised by vocabulary including crisis, currency, imbalance, trade, capital flows, and IMF — is assigned exclusively to PBOC and is the only PBOC topic with negative net sentiment (−0.008). When PBOC engages with international monetary dynamics, its tone turns negative — a signal consistent with China's exposure to trade fragmentation pressures.

Topic-sentiment interaction confirms: CBR and SARB are the most negative and uncertain institutions (lm_net=−0.015, lm_uncertainty=0.017 for both dominant topics). PBOC's domestic communications are positive and low-uncertainty; its international monetary topic is the exception.

Outputs: `brics_mpc_final.csv`, `lda_visualisation.html`, `topic_sentiment_interaction.png`

---

## Project 6 — Mapping Trade Exposure and Structural Change

**Status: ✅ Complete — All 4 Notebooks**

Four-notebook geospatial pipeline documenting structural change across 640 Indian districts between 1990 and 2013, and examining the spatial correlation between trade infrastructure proximity and the pace of structural transformation.

### Research Question
How does structural change — measured as the shift in employment shares across agriculture, manufacturing, and services — vary across Indian districts between 1990 and 2013, and is this variation spatially correlated with proximity to trade infrastructure (major ports, SEZs, and industrial corridors)?

### Notebook 1 — Data Acquisition and Boundary Harmonisation
Loaded Census 2011 district shapefiles (DataMeet, 640 districts, EPSG:4326) and SHRUG Economic Census and Population Census modules. The core technical challenge: each EC round is keyed to a different Census district boundary vintage (1990→1991 districts, 1998→shrid only, 2005→2001 districts, 2013→2011 districts). All rounds were harmonised to 2011 boundaries via shrid-level crosswalk using `shrid_pc11dist_key.csv`.

| Round | Districts Matched | Method |
|-------|------------------|--------|
| EC 1990 | 553 / 640 | shrid crosswalk to 2011 boundaries |
| EC 1998 | 639 / 640 | shrid crosswalk (99.3% shrid match rate) |
| EC 2005 | 636 / 640 | shrid crosswalk to 2011 boundaries |
| EC 2013 | 640 / 640 | Direct merge on pc11_district_id |

Output: `data/processed/districts_structural_change.gpkg` — 640 districts × 35 columns including non-farm share, manufacturing share, and change indicators for each round.

### Notebook 2 — Structural Change Maps
Four choropleth maps (non-farm share, 1990–2013) and four manufacturing share maps on common quantile scales. Change maps (1990→2013, 2005→2013) with transparent outlier treatment: extreme observations (>3σ) diagnosed as EC1990 boundary artefacts or Delhi administrative reorganisation, winsorised for display only.

Key spatial finding: structural transformation in India was spatially concentrated and path-dependent. Coastal and urban districts led throughout. The north-south gradient — dark south, pale interior — was established by 1990 and persisted through 2013. Manufacturing share declined across most districts even as total non-farm share rose, consistent with services-led premature deindustrialisation.

### Notebook 3 — Trade Exposure Proxies and Spatial Analysis
Three proxy measures constructed for all 640 districts:

| Measure | Summary Statistics | Correlation with Non-Farm Share 2013 |
|---------|-------------------|--------------------------------------|
| Distance to nearest major port (km) | Mean: 553, Median: 496, Range: 2–1,594 | r = −0.147, p < 0.001 |
| Distance to nearest major SEZ (km) | Mean: 302, Median: 244, Range: 3–1,584 | r = −0.128, p = 0.001 |
| Industrial corridor alignment (binary) | 461 in corridor, 179 outside | t = −7.38 (confounded — see note) |

Distance calculations performed in EPSG:7755 (India projected CRS). Both proximity measures show statistically significant negative correlations with structural change — closer districts have higher non-farm employment share — but effect sizes are modest, reflecting the role of state industrial policy, agglomeration, and historical industrial base alongside geographic proximity.

Note on corridor result: outside-corridor districts show higher mean non-farm share (109.6 vs 76.4) due to ecological confounding — large agrarian states (UP, Bihar, MP, Rajasthan) dominate the corridor group, pulling its mean down. The state-level binary measure is too coarse to isolate corridor effects.

Output: `data/processed/districts_full_panel.gpkg` — 640 districts × 43 columns.

### Notebook 4 — Publication-Quality Visualisation
Four publication-ready figures (PNG at 300 dpi + PDF):

- **Figure 1:** Four-panel non-farm employment share, 1990–2013 — the core spatial narrative
- **Figure 2:** Manufacturing share 1990 vs 2013 — the two pathways (manufacturing-led vs services-led transformation)
- **Figure 3:** Three-panel trade infrastructure and structural change — port distance, SEZ proximity, non-farm share 2013
- **Figure 4:** Correlation scatter plots — port proximity (r=−0.147) and SEZ proximity (r=−0.128) vs non-farm share

All figures use serif fonts, clean map axes, consistent colour schemes, and shared colorbars suitable for direct inclusion in a working paper.

### Citations
- Asher, S., Lunt, T., Matsuura, R., & Novosad, P. (2021). *World Bank Economic Review*, 35(4), 845–871.
- Central Statistics Organisation, MoSPI, GoI. Economic Census of India. Accessed via SHRUG v2.1.pakora, March 2026.
- Office of the Registrar General and Census Commissioner, India. Census of India. Accessed via SHRUG v2.1.pakora, March 2026.

---

## Status

| Project | Status |
|---------|--------|
| 01 — China Shock in Emerging Markets (Python) | 🔲 Planned |
| 02 — Exchange Rate Volatility and Export Margins (STATA) | 🔲 Planned |
| 03 — Labour Market Polarisation Across Indian Districts (R) | 🔲 Planned |
| 04 — Scraping Central Bank Communications | ✅ Complete |
| 05 — Monetary Policy Sentiment Across BRICS (NB1 + NB2 + NB3) | ✅ Complete |
| 06 — Mapping Trade Exposure and Structural Change (NB1–NB4) | ✅ Complete |

---