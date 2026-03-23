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
| 6 | [Mapping Trade Exposure and Structural Change](./06_trade_exposure_maps/) | Geospatial | District-level visualisation of trade exposure and labour market outcomes |

---

## Thematic Spine

The portfolio is organised around three connected questions:

1. **Trade shocks and labour markets** — How do import competition and export volatility translate into employment and wage changes at the local level in emerging economies? (Projects 1, 2, 3)

2. **Central bank communication and monetary fragmentation** — How have BRICS central banks communicated policy amid currency fragmentation and trade disruptions, and can text data reveal diverging monetary stances? (Projects 4, 5)

3. **Geography of structural change** — Where, spatially, are the effects of trade and structural transformation concentrated? (Project 6)

Projects 4 and 5 form a deliberate pipeline: Project 4 builds the dataset, Project 5 analyses it.

---

## Tools & Methods

- **Python** — pandas, statsmodels, matplotlib, BeautifulSoup, spaCy, gensim, PyMuPDF
- **STATA** — panel data estimation (xtset, xtreg, areg), IV regression, shift-share instruments
- **R** — tidyverse, ggplot2, fixest, R Markdown
- **Web Scraping** — BeautifulSoup, requests
- **NLP** — Loughran-McDonald financial dictionary, FinBERT, LDA topic modelling
- **Geospatial** — geopandas, matplotlib, shapefiles

---

## Data Sources

- World Bank / UN Comtrade — bilateral trade flows
- NSS / PLFS — Indian employment and wage surveys
- SARB, RBI, Bank of Russia — central bank monetary policy statements (scraped + PDF)
- BIS CBSPEECHES database — PBOC communications
- SHRUG / DISE — Indian district-level shapefiles and economic data

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

**Status: ✅ Notebooks 1 & 2 Complete | Notebook 3 (LDA) In Progress**

Two-layer sentiment analysis on the 302-statement corpus.

**Layer 1 — Loughran-McDonald Dictionary (primary)**
Net sentiment and uncertainty scores computed for all 302 statements. Key finding: post-2022 divergence between CBR (sharply more negative and uncertain following the Russia-Ukraine war and sanctions shock) and PBOC (stable to improving) is the strongest event-driven signal in the dataset. Bank sentiment rankings — SARB ≈ CBR (most negative) > RBI > PBOC (most positive) — are consistent with macroeconomic context and stable across time.

**Layer 2 — FinBERT (robustness check)**
Run on a stratified 40-statement sample. Spearman correlation with LM net scores: 0.441 (p=0.004). Both methods produce identical bank-level sentiment rankings, validating the LM scores as the primary measure.

**Notebook 3 (forthcoming):** LDA topic modelling on `text_clean` using gensim. Goal: identify trade fragmentation and currency divergence topics and examine how their prevalence and associated sentiment have shifted post-2022.

Outputs: `05_monetary_policy_sentiment/data/brics_mpc_sentiment.csv`

---

## Status

| Project | Status |
|---------|--------|
| 01 — Python | 🔲 Planned |
| 02 — STATA | 🔲 Planned |
| 03 — R | 🔲 Planned |
| 04 — Web Scraping | ✅ Complete |
| 05 — Text2Data (NB1 + NB2) | ✅ Complete |
| 05 — Text2Data (NB3 LDA) | 🔄 In Progress |
| 06 — Geospatial | 🔲 Planned |

---