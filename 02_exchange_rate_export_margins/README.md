# Exchange Rate Volatility and Export Margins: Panel Evidence from BRICS

## Overview

This project examines whether bilateral exchange rate volatility affects trade along the intensive and extensive margins for BRICS economies, using a panel gravity framework with country-pair, exporter-year, and importer-year fixed effects over the period 2000–2022. The five BRICS members — Brazil, Russia, India, China, and South Africa — provide a natural laboratory for this question because they represent five structurally distinct exchange rate regimes: a managed crawl (China), a selective float with central bank intervention (India), a freely floating commodity-sensitive currency (South Africa), a highly volatile risk-appetite-driven currency (Brazil), and a currency subject to severe sanctions-related disruption from February 2022 (Russia). This heterogeneity in regime type, combined with the variation in trade partner composition across BRICS members, generates identifying variation that a homogeneous-regime sample cannot provide.

The intensive margin question — whether existing trade relationships shrink under volatility — is estimated using Poisson Pseudo-Maximum Likelihood (PPML) on the full sample of bilateral flows including zeros, following Santos Silva and Tenreyro (2006). The extensive margin question — whether volatility prevents trade relationships from forming at all — is estimated as a linear probability model on the binary indicator of positive trade. Both specifications implement the three-way fixed effects structure recommended by Head and Mayer (2014), absorbing multilateral resistance terms as per Anderson and van Wincoop (2003). A log-OLS specification restricted to positive trade flows is reported as a robustness check with the explicit caveat that it estimates a sample-selected intensive margin only. The difference in observation counts between the PPML and log-OLS columns directly quantifies the zero trade flows discarded by the log-linear approach — a number that should be reported and interpreted, not glossed over.

The exchange rate volatility measure is the rolling 12-month standard deviation of monthly log bilateral exchange rate changes, constructed from IMF International Financial Statistics monthly series. BACI HS92 bilateral trade flows from CEPII form the trade panel. Gravity controls — bilateral distance, common language, colonial relationship, contiguity — are drawn from CEPII GeoDist and enter only the log-OLS specification, as the three-way fixed effects absorb all time-invariant bilateral characteristics in the PPML.

## Research Questions

1. Does bilateral exchange rate volatility reduce the value of trade between BRICS economies and their partners (the intensive margin), after controlling for multilateral resistance and pair-specific time-invariant characteristics?
2. Does volatility reduce the probability that a bilateral trade relationship exists at all (the extensive margin), and is this effect larger or smaller than the intensive margin effect?
3. Does the direction and magnitude of the volatility–trade relationship differ across BRICS members, reflecting the heterogeneity in their exchange rate regimes and trade structures?
4. Is the Russia–SWIFT exclusion episode of February 2022 a quantitatively distinct shock to the volatility–trade relationship, and how sensitive are the main results to its inclusion?

## Econometric Framework

### The Multilateral Resistance Problem

The naive gravity equation — regressing log bilateral trade on log distance, log GDP, and a bilateral volatility measure — is misspecified. Anderson and van Wincoop (2003, AER) showed that bilateral trade depends not just on the bilateral trade cost between i and j, but on how that cost compares to the multilateral resistance each country faces — its trade-cost-weighted average access to all partners. Omitting multilateral resistance biases all slope coefficients, including the coefficient of central interest on exchange rate volatility.

The correction is exporter × year fixed effects (`γ_it`) and importer × year fixed effects (`δ_jt`). These absorb the multilateral resistance terms completely, because resistance varies at the country × year level. They simultaneously absorb GDP and all other exporter- and importer-specific time-varying covariates. Pair fixed effects (`φ_ij`) absorb all time-invariant bilateral characteristics — distance, language, colonial ties, contiguity — eliminating the need to enter them explicitly. The only time-varying bilateral variable in the estimating equation is the volatility measure.

The three-way fixed effects estimating equation is:

```
E[Trade_ijt] = exp(β₁ · Volatility_ijt + γ_it + δ_jt + φ_ij)
```

where β₁ is identified from within-pair variation in bilateral volatility over time, purged of all country-specific trends and time-invariant bilateral characteristics.

### The Zero Trade Flow Problem

Log-linearising the gravity equation requires `ln(Trade_ijt)`, which is undefined when trade is zero. Dropping zero observations is not a neutral data cleaning step — it conditions the sample on trade being strictly positive and discards the extensive margin entirely. Zero trade flows are not randomly distributed: they are concentrated precisely in high-volatility periods and thin bilateral relationships — the observations where volatility is most likely to have prevented trade from occurring. Log-OLS therefore systematically underestimates the trade-reducing effect of volatility.

Santos Silva and Tenreyro (2006, ReStat) identified a second problem: even for strictly positive flows, log-OLS is inconsistent under heteroskedasticity due to Jensen's inequality — `E[ln(Trade)] ≠ ln(E[Trade])`. The PPML estimator avoids both problems. It models trade levels directly, requires only correct specification of the conditional mean, is heteroskedasticity-consistent, and admits zero observations as valid data points. β₁ from PPML gives the semi-elasticity of trade levels with respect to volatility, inclusive of the extensive margin.

### Estimating Equations

```stata
* PPML — primary estimator
* Full sample including zero trade flows
* Absorbs pair, exporter-year, importer-year FE
ppmlhdfe trade volatility, absorb(pair_id exporter_year importer_year) vce(robust)

* Log-OLS — robustness check, intensive margin only
* Sample restricted to strictly positive trade flows
* Not directly comparable to PPML due to sample selection
reghdfe ln_trade volatility, absorb(pair_id exporter_year importer_year) vce(robust)

* Extensive margin — linear probability model
* Dependent variable: binary indicator of positive trade
reghdfe trade_dummy volatility, absorb(pair_id exporter_year importer_year) vce(robust)
```

`ppmlhdfe` and `reghdfe` are installed via SSC. Both support high-dimensional fixed effects through the Frisch-Waugh-Lovell algorithm implemented in `ftools`. Standard errors are clustered at the country-pair level unless otherwise noted.

## Data Sources

### Trade Flows

**CEPII BACI HS92, Annual Files 2000–2022**
- Source: CEPII — Centre d'Études Prospectives et d'Informations Internationales
- Access: baci.cepii.fr (free registration)
- Coverage: All reporting countries, HS 6-digit product level, 1995–2022
- Vintage: V202401 (January 2024 release)
- File structure: One CSV per year (`BACI_HS92_YYYY_V202401.csv`), approximately 1.5–2 million rows each
- Variables used: Exporter code (`i`), importer code (`j`), year (`t`), trade value in thousands USD (`v`)
- Aggregation: Collapsed to bilateral annual totals immediately after loading — product-level disaggregation is not used in this project
- Country codes: CEPII numeric — mapped to ISO3 using the companion file `country_codes_V202401.csv`

BACI is preferred over raw UN Comtrade because it reconciles export and import reports using a maximum likelihood procedure, resolving the CIF/FOB valuation discrepancy and timing mismatch that make raw Comtrade bilateral flows inconsistent.

**Partner selection:** Top 50 trading partners of any BRICS member, by average bilateral trade value over 2000–2022. This threshold covers more than 90% of BRICS total trade by value and provides meaningful extensive margin variation (some BRICS–partner pairs have zero trade in some years).

### Exchange Rates

**IMF International Financial Statistics — Monthly, 2000–2022**
- Source: IMF Data Portal — data.imf.org
- Series: Domestic currency per US dollar, period average (code: ENDA_XDC_USD_RATE)
- Frequency: Monthly
- Coverage: All BRICS members plus 50 partner countries
- Bilateral rate construction: `e_ijt = e_it/USD ÷ e_jt/USD` (cross-rate from USD-denominated series)

**BIS bilateral exchange rate statistics** used as a cross-check for the Russia rouble series. The CBR effectively suspended market-determined exchange rates through capital controls from March 2022 — the BIS series and IMF series diverge for Russia post-February 2022, and this divergence is documented in the do-file.

**Volatility construction:**

```stata
* Monthly log change in bilateral rate
gen ln_e_ij   = ln(e_i) - ln(e_j)
gen delta_ln  = ln_e_ij - l.ln_e_ij

* Rolling 12-month standard deviation (backward-looking)
* rangestat from SSC handles arbitrary rolling windows within groups
ssc install rangestat
rangestat (sd) delta_ln, interval(month -11 0) by(pair_id)
rename delta_ln_sd volatility
```

### Gravity Controls

**CEPII GeoDist**
- Source: CEPII — geodist.cepii.fr
- File: `dist_cepii.dta` (native Stata format)
- Variables used: Log bilateral distance (population-weighted great circle, `distw`), common official language (`comlang_off`), colonial relationship (`colony`), contiguity (`contig`)
- These variables enter only the log-OLS specification; pair fixed effects in PPML and the LPM absorb all time-invariant bilateral characteristics

**GDP (descriptive statistics only)**
- Source: World Bank World Development Indicators
- Not included in any regression specification — absorbed by exporter-year and importer-year fixed effects

## Panel Structure

| Dimension | Value |
|-----------|-------|
| Exporters | 5 (Brazil, Russia, India, China, South Africa) |
| Importers | 50 (top trading partners) |
| Years | 2000–2022 (23 years) |
| Unit of observation | Exporter–importer–year triplet |
| Observations (with zeros) | ~5,750 (5 × 50 × 23) |
| Observations (positive trade only) | Smaller — difference quantifies zeros discarded by log-OLS |
| Pair identifiers | 5 × 50 = 250 unique pairs |
| Pair-year identifiers | 250 × 23 = 5,750 maximum |

## Project Structure

```
02_exchange_rate_export_margins/
│
├── README.md
│
├── do-files/
│   ├── 01_clean.do         ← BACI loading, aggregation, country code merge;
│   │                          IFS exchange rate loading, bilateral rate construction,
│   │                          rolling volatility measure (rangestat)
│   ├── 02_merge.do         ← Merge trade panel, volatility, GeoDist controls;
│   │                          generate pair_id, exporter_year, importer_year identifiers;
│   │                          generate ln_trade, trade_dummy; flag Russia post-Feb 2022
│   └── 03_analysis.do      ← PPML (ppmlhdfe), log-OLS (reghdfe), LPM;
│                              BRICS-heterogeneous interaction specification;
│                              Russia sensitivity check; formatted results table export
│
├── log/
│   ├── 01_clean.log
│   ├── 02_merge.log
│   └── 03_analysis.log
│
├── output/
│   └── results_table.xlsx  ← Three-column results table formatted as working paper appendix
│
└── data/
    ├── BACI_HS92_*/         ← Annual BACI files — not committed to GitHub (>2GB)
    ├── dist_cepii.dta       ← GeoDist — committed (small)
    ├── ifs_exchange_rates.csv ← IFS monthly rates — committed
    ├── country_codes_V202401.csv ← CEPII numeric-to-ISO3 mapping — committed
    ├── brics_trade_panel.dta    ← Aggregated bilateral panel from do-file 01
    ├── volatility_panel.dta     ← Annual volatility measures from do-file 01
    └── master_panel.dta         ← Fully merged analysis dataset from do-file 02
```

## Do-Files

### 01_clean.do — Data Loading and Variable Construction

**BACI section:** Loads all annual BACI HS92 CSV files in a loop using `import delimited`, merges the CEPII country code file to recover ISO3 identifiers, restricts to observations where the exporter is one of the five BRICS members and the importer is in the partner-50 list, collapses product-level flows to bilateral annual totals using `collapse (sum) v`, and saves `brics_trade_panel.dta`. The loop processes 23 files sequentially; processing time and observation counts before and after the partner restriction are logged.

**Exchange rate section:** Loads IMF IFS monthly series, reshapes from wide to long, constructs the bilateral cross-rate as `e_i/USD ÷ e_j/USD` for all BRICS–partner pairs, generates monthly log changes, and applies `rangestat` to compute the rolling 12-month standard deviation. Annual volatility is defined as the value at the December observation (month 12) of each year — so `volatility_2005` is the 12-month SD over January–December 2005. Saves `volatility_panel.dta`. Documents the Russia rouble anomaly post-February 2022 with a comparison of IMF and BIS series.

### 02_merge.do — Panel Construction and Variable Generation

Merges `brics_trade_panel.dta` and `volatility_panel.dta` on exporter-importer-year. Merges in GeoDist controls on country pair. Generates the fixed effect identifiers required by `reghdfe` and `ppmlhdfe`: `pair_id` (numeric, unique per exporter-importer pair), `exporter_year` (string concatenation of ISO3 exporter and year, converted to numeric), `importer_year` (analogous). Generates `ln_trade = ln(trade)` (requires trade > 0), `trade_dummy = (trade > 0)`. Generates the Russia post-sanctions indicator: `russia_post22 = (exporter == "RUS" & year >= 2022)`. Documents merge rates at each step. Saves `master_panel.dta`.

### 03_analysis.do — Regressions and Output

Runs the three primary specifications: PPML on the full sample, log-OLS on the positive-trade subsample, and LPM on the full sample. Reports the difference in N between specifications (1) and (2) explicitly as the count of discarded zeros. Runs the BRICS-heterogeneous specification by interacting `volatility` with BRICS exporter dummies to recover country-specific coefficients. Runs the Russia sensitivity check by repeating all specifications on the sample with `russia_post22 == 0`. Exports a three-column results table to `output/results_table.xlsx` using `putexcel`, formatted with variable labels, fixed effect rows, observation counts, and significance stars.

## Results Table Structure

| | (1) PPML | (2) Log-OLS | (3) Extensive Margin |
|--|---------|------------|---------------------|
| Volatility | β₁ (SE) | β₁ (SE) | β₁ (SE) |
| Pair FE | ✓ | ✓ | ✓ |
| Exporter × Year FE | ✓ | ✓ | ✓ |
| Importer × Year FE | ✓ | ✓ | ✓ |
| Observations | N (full) | N (zeros excluded) | N (full) |
| Pseudo R² / R² | | | |
| Estimator | PPML | OLS | OLS |

The difference between N in column (1) and N in column (2) is reported explicitly in the table note as the number of zero bilateral flows that the log-OLS specification discards. This is a substantive finding, not a footnote.

## Key Findings

*[To be completed after do-file 03 is run. Placeholder structure below.]*

**Intensive margin (PPML):** The coefficient β₁ on volatility in the PPML specification captures the semi-elasticity of bilateral trade value with respect to the rolling 12-month exchange rate standard deviation, inclusive of zeros, with country-pair, exporter-year, and importer-year fixed effects. Sign and magnitude relative to log-OLS reveal whether the intensive margin effect is understated when zeros are excluded.

**Extensive margin (LPM):** The coefficient on volatility in the LPM gives the percentage point change in the probability of positive trade associated with a one-unit increase in 12-month exchange rate standard deviation. A negative and significant coefficient would indicate that volatility suppresses the formation of new bilateral trade relationships, beyond its effect on existing relationships.

**BRICS heterogeneity:** The interaction specification recovers country-specific coefficients. The prior expectation, based on regime heterogeneity, is that China (managed crawl) should show the smallest negative effect and Russia post-2022 the largest. Whether India's active RBI intervention produces a measurably smaller effect than South Africa or Brazil (both floating) is the sharpest hypothesis.

**Russia sensitivity:** Repeating all specifications with Russia 2022 observations excluded tests whether the extreme post-sanctions rouble volatility is driving the aggregate result or whether the main finding holds on the pre-sanctions and non-Russia sample.

## Limitations

1. **Endogeneity of exchange rate volatility.** Countries facing economic or political stress simultaneously exhibit volatile currencies and declining trade. Without a valid instrument for bilateral volatility — Tenreyro (2007) uses lagged US monetary policy shocks — β₁ captures correlation rather than clean causation. This project does not claim causal identification. All results are presented as conditional correlations with a full set of fixed effects.

2. **Five exporters is a small N.** The BRICS exporter dimension has five countries. Country-level heterogeneity in the interaction specification is estimated with limited degrees of freedom. These results are illustrative, not statistically definitive.

3. **Rolling SD is backward-looking.** The 12-month rolling standard deviation of past monthly changes measures realised volatility, not expected volatility. Exporters may respond to expected future volatility rather than past realised volatility — GARCH-based conditional volatility would capture this better but is harder to construct and to interpret for an audience unfamiliar with time-series methods. Rolling SD is the standard in the empirical trade literature (e.g. Héricourt & Poncet 2015) and is retained here for transparency.

4. **Russia post-February 2022.** The rouble exchange rate after February 2022 reflects CBR administrative controls, not market dynamics. The IMF series and BIS series diverge sharply. The volatility measure for Russia 2022–2023 is very large but driven by an institutional shock to capital flows rather than a market determination of exchange rate uncertainty. Russia post-2022 observations should be read as a separate regime and are sensitivity-checked.

5. **BACI coverage of Russia 2022+.** Russia's Comtrade submissions became irregular after the February 2022 sanctions. The 2022 BACI vintage may have incomplete coverage for Russia. The effective clean panel for Russia may be 2000–2021.

6. **Product-level heterogeneity is not exploited.** Aggregate bilateral flows mask variation across Rauch (1999) good types — differentiated goods are more sensitive to exchange rate volatility than reference-priced or organised-exchange goods (Héricourt & Poncet 2015). Product-level disaggregation is a natural extension not pursued here.

7. **LPM as extensive margin estimator.** The linear probability model can predict probabilities outside [0,1] and is strictly incorrect for a binary outcome. A conditional fixed effects logit would be more appropriate but is computationally demanding with three-way fixed effects and has a strict incidental parameters problem. The LPM is used as a computationally tractable approximation, following standard practice in the gravity literature.

## Connection to Portfolio

This project is the second component of a six-project research portfolio on **Trade, Structural Change, and Labour Markets in Emerging Economies**.

| Project | Relationship to Project 2 |
|---------|--------------------------|
| [01 — China Shock in Emerging Markets](../01_china_shock_emerging_markets/) | Import competition and exchange rate volatility are the two primary channels through which global trade integration affects domestic labour markets; Projects 1 and 2 together provide both channels |
| [03 — Labour Market Polarisation Across Indian Districts](../03_labour_polarisation_india/) | The BRICS exchange rate volatility episodes identified here are candidate explanatory variables for the district-level structural employment shifts estimated in Project 3 |
| [04 — Central Bank Communications Scraper](../04_central_bank_scraper/) | The PBOC, RBI, SARB, CBR, and BCB statements collected in Project 4 include direct commentary on exchange rate management objectives; the volatility episodes in Project 2 are the events those statements are responding to |
| [05 — Monetary Policy Sentiment](../05_monetary_policy_sentiment/) | The post-2022 rouble shock is the sharpest volatility episode in the dataset and is also the most negative sentiment episode in Project 5; cross-referencing the two results — trade collapse and central bank sentiment shift — strengthens both narratives |
| [06 — Trade Exposure Maps](../06_trade_exposure_maps/) | Project 6's district-level trade exposure proxies for India are constructed using port proximity and SEZ access; the bilateral exchange rate volatility estimated here is the macro-level counterpart to that district-level exposure variation |

**Connection to the master's thesis:** The BRICS local currency settlement (LCS) initiative, examined in the master's thesis through a TWFE panel regression on a constructed LCShare proxy, is motivated precisely by the result that volatile bilateral exchange rates measurably suppress trade. Project 2 provides the empirical micro-foundation for the thesis's macro question: if LCS reduces effective bilateral exchange rate exposure, the trade-expanding effect of stabilisation should be of the order of magnitude estimated here.

**Connection to David Dorn's research agenda:** Dorn's work on globalisation and labour market polarisation (Autor, Dorn & Hanson 2013; Dorn 2009) uses bilateral trade flows and shift-share instruments constructed from the same CEPII gravity data infrastructure used here. The panel data construction workflow in Project 2 — BACI aggregation, GeoDist merge, country-pair fixed effects — is directly transferable to that literature.

## Dependencies

```stata
* STATA packages — installed via SSC
ssc install ppmlhdfe    // PPML with high-dimensional fixed effects (Correia et al.)
ssc install reghdfe     // OLS with high-dimensional fixed effects (Correia et al.)
ssc install ftools      // Fast Frisch-Waugh-Lovell algorithm — required by both above
ssc install rangestat   // Rolling window statistics (sd, mean, etc.) within panels
ssc install estout      // Formatted regression output tables
```

```
Data dependencies (not committed to GitHub):
BACI HS92 V202401           ~2.1 GB (23 annual CSV files)
IMF IFS monthly series      ~5 MB  (download from data.imf.org)
```

```
Data dependencies (committed to GitHub):
dist_cepii.dta              ~1.5 MB
country_codes_V202401.csv   ~50 KB
```

## References

- Anderson, J. E., & van Wincoop, E. (2003). Gravity with Gravitas: A Solution to the Border Puzzle. *American Economic Review*, 93(1), 170–192.
- Santos Silva, J. M. C., & Tenreyro, S. (2006). The Log of Gravity. *Review of Economics and Statistics*, 88(4), 641–658.
- Helpman, E., Melitz, M., & Rubinstein, Y. (2008). Estimating Trade Flows: Trading Partners and Trading Volumes. *Quarterly Journal of Economics*, 123(2), 441–487.
- Head, K., & Mayer, T. (2014). Gravity Equations: Workhorse, Toolkit, and Cookbook. In G. Gopinath, E. Helpman, & K. Rogoff (Eds.), *Handbook of International Economics*, Vol. 4. Elsevier.
- Rose, A. K. (2000). One Money, One Market: The Effect of Common Currencies on Trade. *Economic Policy*, 15(30), 7–46.
- Tenreyro, S. (2007). On the Trade Impact of Nominal Exchange Rate Volatility. *Journal of Development Economics*, 82(2), 485–508.
- Héricourt, J., & Poncet, S. (2015). Exchange Rate Volatility, Financial Constraints, and Trade: Empirical Evidence from Chinese Firms. *World Bank Economic Review*, 29(3), 550–578.
- Hayakawa, K., & Kimura, F. (2009). The Effect of Exchange Rate Volatility on International Trade in East Asia. *Journal of the Japanese and International Economies*, 23(4), 395–406.
- Rauch, J. E. (1999). Networks versus Markets in International Trade. *Journal of International Economics*, 48(1), 7–35.
- Cuñat, A., & Zymek, R. (2024). Bilateral Trade Imbalances. *Review of Economic Studies*, 91(1), 194–231.
- Correia, S., Guimarães, P., & Zylkin, T. (2020). Fast Poisson Estimation with High-Dimensional Fixed Effects. *Stata Journal*, 20(1), 95–115.

## License

This project is shared for academic and non-commercial use. CEPII BACI and GeoDist data are distributed for research use under CEPII's terms of access. IMF IFS data is publicly distributed. All analysis code is available under the MIT License.
