# Exchange Rate Volatility and Export Margins: Panel Evidence from BRICS

## Overview

This project examines whether bilateral exchange rate volatility affects trade along the intensive and extensive margins for BRICS economies, using a panel gravity framework with country-pair, exporter-year, and importer-year fixed effects over the period 2000–2022. The five BRICS members — Brazil, Russia, India, China, and South Africa — provide a natural laboratory for this question because they represent five structurally distinct exchange rate regimes: a managed crawl (China), a selective float with central bank intervention (India), a freely floating commodity-sensitive currency (South Africa), a highly volatile risk-appetite-driven currency (Brazil), and a currency subject to severe sanctions-related disruption from February 2022 (Russia). This heterogeneity in regime type, combined with the variation in trade partner composition across BRICS members, generates identifying variation that a homogeneous-regime sample cannot provide.

The primary finding is a null result at the intensive margin: bilateral exchange rate volatility has no statistically significant effect on BRICS bilateral trade when identified from within-pair variation under stringent three-way fixed effects. This is an honest and interpretable finding, not a failure of the research design. The direction of the effect is consistently negative across four of five country-specific specifications and in the Russia-restricted sensitivity check, consistent with the theoretical prior. The pooled full-sample PPML coefficient is positive but is driven by the Russia post-2022 sanctions episode, which simultaneously produces extreme rouble volatility and a redirection of Russian trade toward non-sanctioning partners — a spurious correlation driven by the same underlying shock. The extensive margin (LPM) is infeasible with this panel structure due to the absence of within-pair switching in trade participation across years.

The exchange rate volatility measure is the rolling 12-month standard deviation of monthly log bilateral exchange rate changes, constructed from IMF International Financial Statistics monthly series. BACI HS92 bilateral trade flows (V202601, January 2026 vintage) from CEPII form the trade panel. Gravity controls — bilateral distance, common language, colonial relationship, contiguity — are drawn from CEPII GeoDist and enter only the log-OLS specification, as the three-way fixed effects absorb all time-invariant bilateral characteristics in the PPML and LPM.

## Research Questions

1. Does bilateral exchange rate volatility reduce the value of trade between BRICS economies and their partners (the intensive margin), after controlling for multilateral resistance and pair-specific time-invariant characteristics?
2. Does volatility reduce the probability that a bilateral trade relationship exists at all (the extensive margin), and is this effect larger or smaller than the intensive margin effect?
3. Does the direction and magnitude of the volatility–trade relationship differ across BRICS members, reflecting the heterogeneity in their exchange rate regimes and trade structures?
4. Is the Russia–SWIFT exclusion episode of February 2022 a quantitatively distinct shock to the volatility–trade relationship, and how sensitive are the main results to its inclusion?

## Econometric Framework

### The Multilateral Resistance Problem

The naive gravity equation — regressing log bilateral trade on log distance, log GDP, and a bilateral volatility measure — is misspecified. Anderson and van Wincoop (2003, AER) showed that trade between i and j depends not just on bilateral trade costs but on how those costs compare to the multilateral resistance each country faces — the average trade cost each country faces with all other partners. Omitting multilateral resistance biases all coefficients including the coefficient on exchange rate volatility.

The solution is exporter × year fixed effects (`γ_it`) and importer × year fixed effects (`δ_jt`). These absorb the multilateral resistance terms completely because resistance varies at the country × year level. They simultaneously absorb GDP and all other exporter- and importer-specific time-varying covariates. Pair fixed effects (`φ_ij`) absorb all time-invariant bilateral characteristics — distance, language, colonial ties, contiguity. The correctly specified estimating equation is:

```
E[Trade_ijt] = exp(β₁ · Volatility_ijt + γ_it + δ_jt + φ_ij)
```

where β₁ is identified from within-pair variation in bilateral volatility over time, purged of all country-specific trends and time-invariant bilateral characteristics.

### The Zero Trade Flow Problem

Log-linearising the gravity equation requires `ln(Trade_ijt)`, which is undefined when trade is zero. Dropping zero observations conditions the sample on trade being strictly positive and discards the extensive margin entirely. Santos Silva and Tenreyro (2006, ReStat) identified a second problem: even for strictly positive flows, log-OLS is inconsistent under heteroskedasticity due to Jensen's inequality. The PPML estimator avoids both problems — it models trade levels directly, handles zeros, and is heteroskedasticity-consistent.

In this dataset, the PPML and log-OLS specifications run on the same effective sample (N = 19,914 after singleton drops) because the 639 zero/missing trade observations all have missing trade values — PPML also requires non-missing trade to fit the Poisson likelihood. The estimators differ in functional form and heteroskedasticity treatment, not in sample coverage for this dataset.

### Estimating Equations

```stata
* PPML — primary estimator (ppmlhdfe, Correia, Guimaraes & Zylkin 2020)
ppmlhdfe trade volatility, absorb(pair_id exporter_year importer_year) vce(robust)

* Log-OLS — robustness check (reghdfe)
reghdfe ln_trade volatility, absorb(pair_id exporter_year importer_year) vce(robust)

* LPM — extensive margin (infeasible — see Key Findings)
reghdfe trade_dummy volatility, absorb(pair_id exporter_year importer_year) vce(robust)
```

## Data Sources

### Trade Flows

**CEPII BACI HS92, Annual Files 2000–2022 (Vintage V202601)**
- Source: CEPII — baci.cepii.fr (free registration)
- Coverage: All reporting countries, HS 6-digit product level, 1995–2024
- Vintage: V202601 (January 2026 release)
- Aggregation: Collapsed to bilateral annual totals immediately after loading — product-level disaggregation not used
- Country codes: CEPII numeric — mapped to ISO3 using `country_codes_V202601.csv`
- Exporter filter: Brazil (76), China (156), Russia (643), India (699), South Africa (710)

BACI is preferred over raw UN Comtrade because it reconciles export and import reports using a maximum likelihood procedure, resolving the CIF/FOB valuation discrepancy and timing mismatch that make raw Comtrade bilateral flows inconsistent.

### Exchange Rates

**IMF International Financial Statistics — Monthly, 2000–2022**
- Source: IMF Data Portal — data.imf.org
- Series: Domestic currency per US Dollar, period average (indicator: XDC_USD, transformation: PA_RT)
- Frequency: Monthly
- Country coverage: 193 countries (filtered to BACI panel countries)
- Bilateral rate: `e_ij = e_i/USD ÷ e_j/USD` (cross-rate from USD-denominated series)
- Volatility: Rolling 12-month standard deviation of monthly log bilateral rate changes, measured at December of each year

### Gravity Controls

**CEPII GeoDist**
- Source: CEPII — geodist.cepii.fr
- File: `dist_cepii.dta` (native Stata format)
- Variables used: `distw` (population-weighted distance, km), `comlang_off`, `colony`, `contig`
- Enters log-OLS specification only — pair FE in PPML absorbs all time-invariant bilateral characteristics

## Panel Structure

| Dimension | Value |
|-----------|-------|
| Exporters | 5 (BRA, CHN, IND, RUS, ZAF) |
| Partner countries (importers) | Up to 232 — varies by year |
| Years | 2000–2022 (23 years) |
| Unit of observation | Exporter–importer–year triplet |
| Master panel observations | 24,579 |
| Effective regression sample | 19,914 (after singleton drops and missing volatility) |
| Observations per year | 1,057–1,081 (stable across 23 years) |
| Missing volatility (no IFS coverage) | 4,014 |
| Zero/missing trade observations | 639 (extensive margin) |
| Russia post-2022 observations | 197 (sensitivity check) |

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
│   │                          generate pair_id, exporter_year, importer_year;
│   │                          generate ln_trade, trade_dummy, russia_post22
│   └── 03_analysis.do      ← PPML, log-OLS, LPM; BRICS heterogeneity interactions;
│                              Russia sensitivity check; esttab results export
│
├── log/
│   ├── 01_clean.log
│   ├── 02_merge.log
│   └── 03_analysis.log
│
├── output/
│   ├── results_table.csv        ← Primary results — PPML and log-OLS, full sample
│   ├── sensitivity_table.csv    ← Sensitivity — excluding Russia post-2022
│   └── heterogeneity_table.csv  ← BRICS country-specific volatility interactions
│
├── Project2_Documentation - 01_clean.docx   ← Full documentation: BACI loop, IFS cleaning
├── Project2_Documentation - 02_merge.docx   ← Full documentation: panel construction
├── Project2_Documentation - 03_analysis.docx← Full documentation: regressions, results
│
└── data/
    ├── BACI_HS92_V202601/       ← Annual BACI files — not committed (>8GB)
    ├── dist_cepii.dta           ← GeoDist gravity controls — committed
    ├── ifs_exchange_rates.csv   ← IMF IFS monthly rates — committed
    ├── country_codes_V202601.csv← CEPII country crosswalk — committed
    ├── brics_trade_panel.dta    ← Intermediate: 23,940 bilateral annual trade flows
    ├── volatility_panel.dta     ← Intermediate: 20,565 annual volatility measures
    └── master_panel.dta         ← Analysis dataset: 24,579 obs, 16 variables
```

## Do-Files

### 01_clean.do — Data Loading and Variable Construction

**BACI section:** Saves the CEPII country code crosswalk as a `.dta` file, then loops over years 2000–2022. For each year: loads the annual BACI CSV (~7–11 million rows), filters immediately to BRICS exporters (`i ∈ {76, 156, 643, 699, 710}`), collapses across HS6 products to bilateral annual totals using `collapse (sum) v, by(t i j)`, merges exporter and importer numeric codes to ISO3 strings, and appends to a growing master tempfile. Saves `brics_trade_panel.dta` (23,940 observations). Runtime: approximately 10–11 minutes.

**Exchange rate section:** Loads IMF IFS CSV (902,668 rows). Filters to monthly period-average domestic-currency-per-USD series using three simultaneous conditions: `frequencyid == "M"`, `indicatorid == "XDC_USD"`, `type_of_transformationid == "PA_RT"`. Parses `time_period` string ("2000-M01") into numeric year and month. Filters to BACI panel countries via merge. Constructs bilateral cross-rates using `joinby year month`. Computes rolling 12-month standard deviation using `rangestat`. Keeps December observation as annual volatility measure. Saves `volatility_panel.dta` (20,565 observations).

### 02_merge.do — Panel Construction and Variable Generation

Loads `brics_trade_panel.dta`, standardises variable types (`recast`), merges `volatility_panel.dta` (1:1 on exporter-importer-year), drops one ghost row, merges `dist_cepii.dta` (m:1 on exporter-importer pair, `keepusing` four gravity variables). Generates: `ln_trade`, `trade_dummy`, `ln_distw`, `pair_id`, `exporter_year`, `importer_year`, `russia_post22`. Saves `master_panel.dta` (24,579 observations, 16 variables). Runtime: under 1 minute.

### 03_analysis.do — Regressions and Output

Runs five regression specifications: PPML full sample, log-OLS full sample, LPM (documented as infeasible), PPML BRICS interaction heterogeneity, PPML and log-OLS excluding Russia post-2022. Stores estimates with `estimates store`. Exports three formatted tables to `output/` using `esttab`. Runtime: under 4 minutes.

## Key Findings

### Primary Specifications (Full Sample)

| Specification | β₁ | SE | p-value | N |
|---|---|---|---|---|
| (1) PPML | +0.490 | 0.835 | 0.557 | 19,914 |
| (2) Log-OLS | -1.823 | 1.316 | 0.166 | 19,914 |
| (3) LPM | — | — | — | Infeasible |

**PPML (Column 1):** The coefficient on volatility is positive (+0.490) but statistically insignificant (p = 0.557). The 95% confidence interval runs from −1.15 to +2.13, spanning both large negative and positive effects. The three-way fixed effects absorb 99.51% of variation in trade levels (Pseudo R² = 0.9951), leaving very limited within-pair, within-exporter-year, within-importer-year variation for volatility to explain.

**Log-OLS (Column 2):** The coefficient is negative (−1.823) — consistent with the theoretical prior — but also insignificant (p = 0.166). The within R² of 0.0001 confirms that after the three-way FE are absorbed, volatility explains virtually none of the residual variation in log trade.

**LPM (Column 3):** The LPM is infeasible. `trade_dummy` is perfectly explained by pair fixed effects because the 639 zero-trade observations are concentrated in pairs that never trade across the full 23-year panel — there is no within-pair switching in trade participation. The volatility coefficient is omitted by `reghdfe` with a warning. This is a structural limitation of the panel, not an error.

### BRICS Heterogeneity

| Exporter | Coefficient (vs ZAF) | p-value |
|---|---|---|
| BRA | -0.781 | 0.250 |
| CHN | -0.057 | 0.430 |
| IND | -0.046 | 0.659 |
| **RUS** | **+0.451** | **0.037*** |
| ZAF (base) | +0.493 | 0.558 |

Russia is the only statistically significant result. The positive Russia interaction reflects the sanctions endogeneity problem: extreme rouble volatility and trade redirection toward non-sanctioning partners are both consequences of the same event. Brazil, China, and India all show the expected negative sign, with Brazil showing the largest effect consistent with its highly volatile real.

### Russia Sensitivity Check

| Specification | Full Sample β₁ | Excl. Russia 2022+ β₁ | Sign change? |
|---|---|---|---|
| PPML | +0.490 | -0.546 | Yes |
| Log-OLS | -1.823 | -1.461 | No |

Dropping Russia post-2022 flips the PPML coefficient from positive to negative. Neither specification achieves significance. The direction is consistent with theory once the outlier is removed.

### Honest Interpretation

The null result is consistent with the aggregate gravity literature, which finds mixed and often insignificant effects of exchange rate volatility on bilateral trade at the country-pair level under stringent fixed effects. The identification challenge is real: with five exporters, 23 years, and three-way fixed effects, the within-pair identifying variation in bilateral volatility is genuinely narrow. The direction of the effect is consistently negative across most specifications once the Russia 2022 outlier is accounted for, suggesting the theoretical mechanism is present but the panel lacks the statistical power to estimate it with precision.

## Limitations

1. **Endogeneity of exchange rate volatility.** Countries experiencing economic or political stress have both volatile currencies and declining trade. Without a valid instrument for volatility — Tenreyro (2007) uses lagged US monetary policy shocks — β₁ captures correlation not clean causation. This project does not claim causal identification.

2. **Five exporters is a small N.** The BRICS exporter dimension has only five countries. Country-level heterogeneity in the interaction specification is estimated with limited degrees of freedom.

3. **Rolling SD is backward-looking.** The 12-month rolling standard deviation of past monthly changes measures realised volatility, not expected volatility. GARCH-based conditional volatility is noted as a robustness check not pursued here.

4. **Russia post-February 2022.** The rouble exchange rate after February 2022 reflects CBR administrative controls rather than market dynamics. Russia 2022+ observations are sensitivity-checked with all specifications.

5. **LPM infeasible with this panel structure.** No within-pair switching in trade participation is observed across years. Identifying the extensive margin requires either a longer panel, product-level disaggregation, or an alternative identification strategy.

6. **Product-level heterogeneity not exploited.** Aggregate bilateral flows mask variation across Rauch (1999) good types — differentiated goods are more sensitive to exchange rate volatility than homogeneous commodities. Product-level disaggregation is a natural extension not pursued here.

## Connection to Portfolio

This project is the second component of a six-project research portfolio on **Trade, Structural Change, and Labour Markets in Emerging Economies**.

| Project | Relationship to Project 2 |
|---|---|
| [01 — China Shock in Emerging Markets](../01_china_shock_emerging_markets/) | Import competition and exchange rate volatility are the two channels through which global trade integration affects domestic labour markets; Projects 1 and 2 together provide both channels |
| [03 — Labour Market Polarisation Across Indian Districts](../03_labour_polarisation_india/) | The BRICS exchange rate volatility episodes identified here — particularly the post-2022 rouble shock — are candidate explanatory variables for the district-level structural employment shifts estimated in Project 3 |
| [04 — Central Bank Communications Scraper](../04_central_bank_scraper/) | The PBOC, RBI, SARB, and CBR statements collected in Project 4 include direct commentary on exchange rate management; the volatility episodes in Project 2 are the events those statements respond to |
| [05 — Monetary Policy Sentiment](../05_monetary_policy_sentiment/) | The post-2022 rouble shock is the sharpest volatility episode in this dataset and the most negative sentiment episode in Project 5; cross-referencing the two results strengthens both narratives |
| [06 — Trade Exposure Maps](../06_trade_exposure_maps/) | Project 6's district-level trade exposure proxies for India are constructed using port proximity and SEZ access; the bilateral exchange rate volatility estimated here is the macro-level counterpart to that district-level exposure variation |

## Dependencies

```stata
* STATA packages — installed via SSC
ssc install ppmlhdfe    // PPML with high-dimensional fixed effects (Correia et al. 2020)
ssc install reghdfe     // OLS with high-dimensional fixed effects (Correia et al.)
ssc install ftools      // Fast Frisch-Waugh-Lovell — required by both above
ssc install rangestat   // Rolling window statistics within panels
ssc install estout      // Formatted regression output tables
ssc install require     // Dependency management for reghdfe
```

```
Data dependencies (not committed — large files):
BACI HS92 V202601         ~8 GB  (30 annual CSV files, 1995–2024)

Data dependencies (committed):
dist_cepii.dta            ~1.5 MB
ifs_exchange_rates.csv    ~24 MB
country_codes_V202601.csv ~5 KB
```

## References

- Anderson, J. E., & van Wincoop, E. (2003). Gravity with Gravitas: A Solution to the Border Puzzle. *American Economic Review*, 93(1), 170–192.
- Santos Silva, J. M. C., & Tenreyro, S. (2006). The Log of Gravity. *Review of Economics and Statistics*, 88(4), 641–658.
- Helpman, E., Melitz, M., & Rubinstein, Y. (2008). Estimating Trade Flows: Trading Partners and Trading Volumes. *Quarterly Journal of Economics*, 123(2), 441–487.
- Head, K., & Mayer, T. (2014). Gravity Equations: Workhorse, Toolkit, and Cookbook. In G. Gopinath, E. Helpman, & K. Rogoff (Eds.), *Handbook of International Economics*, Vol. 4. Elsevier.
- Rose, A. K. (2000). One Money, One Market: The Effect of Common Currencies on Trade. *Economic Policy*, 15(30), 7–46.
- Tenreyro, S. (2007). On the Trade Impact of Nominal Exchange Rate Volatility. *Journal of Development Economics*, 82(2), 485–508.
- Héricourt, J., & Poncet, S. (2015). Exchange Rate Volatility, Financial Constraints, and Trade: Empirical Evidence from Chinese Firms. *World Bank Economic Review*, 29(3), 550–578.
- Rauch, J. E. (1999). Networks versus Markets in International Trade. *Journal of International Economics*, 48(1), 7–35.
- Correia, S., Guimarães, P., & Zylkin, T. (2020). Fast Poisson Estimation with High-Dimensional Fixed Effects. *Stata Journal*, 20(1), 95–115.
- Cuñat, A., & Zymek, R. (2024). Bilateral Trade Imbalances. *Review of Economic Studies*, 91(1), 194–231.

## License

This project is shared for academic and non-commercial use. CEPII BACI and GeoDist data are distributed for research use under CEPII's terms of access. IMF IFS data is publicly distributed. All analysis code is available under the MIT License.
