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
| 4 | [Scraping Central Bank Communications](./04_central_bank_scraper/) | Web Scraping | A structured dataset of BRICS monetary policy statements (2000–present) |
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

- **Python** — pandas, statsmodels, matplotlib, BeautifulSoup, NLTK/spaCy, gensim
- **STATA** — panel data estimation (xtset, xtreg, areg), IV regression, shift-share instruments
- **R** — tidyverse, ggplot2, fixest, R Markdown
- **Web Scraping** — BeautifulSoup, requests
- **NLP** — Loughran-McDonald financial dictionary, LDA topic modelling
- **Geospatial** — geopandas, matplotlib, shapefiles

---

## Data Sources

- World Bank / UN Comtrade — bilateral trade flows
- NSS / PLFS — Indian employment and wage surveys
- SARB, RBI, BCB, Bank of Russia — central bank monetary policy statements (scraped)
- BIS CBSPEECHES database — PBOC communications
- SHRUG / DISE — Indian district-level shapefiles and economic data

---

## Status

| Project | Status |
|---------|--------|
| 01 — Python | 🔲 Planned |
| 02 — STATA | 🔲 Planned |
| 03 — R | 🔲 Planned |
| 04 — Web Scraping | 🔄 In Progress |
| 05 — Text2Data | 🔲 Planned |
| 06 — Geospatial | 🔲 Planned |

---

## Contact

For queries or collaboration, please reach out via GitHub or LinkedIn.
