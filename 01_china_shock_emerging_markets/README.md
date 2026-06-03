# The China Shock in Emerging Markets: Replicating and Extending Autor, Dorn & Hanson (2013)

## Overview

This project applies the Autor, Dorn and Hanson (2013, AER) shift-share identification strategy to Indian districts, asking whether exposure to Chinese import competition causally explains labour market outcomes across Indian districts in the PLFS period 2017–2022. The project is the identification centrepiece of a three-project empirical programme: Project 6 established where Indian districts sit relative to trade infrastructure and built the district-level employment baseline from SHRUG Economic Census data; Project 3 documented the labour market outcomes — employment shares, wages, and polarisation patterns — using PLFS microdata. This project is where correlation becomes causal inference.

India and China compete directly in global manufacturing — textiles, electronics, garments, light consumer goods. India's WTO-era integration, combined with China's post-accession export surge, generated substantial variation in import exposure across Indian districts that is plausibly exogenous to district-specific labour market trends. The identification strategy exploits this variation using a shift-share (Bartik) instrument: each district's predicted exposure to Chinese import competition is the inner product of its 2005 baseline industry composition — drawn from SHRUG Economic Census data, twelve years before the outcome period — and national-level growth in Chinese exports to comparison countries. The use of comparison-country export growth as the shift purges India-specific demand shocks from the instrument while retaining the supply-side variation driven by China's productivity expansion and infrastructure investment.

The primary results document a null finding: the shift-share IV finds no statistically significant effect of Chinese import competition on non-agricultural employment shares, wages, or skill-group employment shares within Indian states over 2017–2022. The instrument is strong throughout (Kleibergen-Paap F-statistic ≈ 53.5), ruling out weak instrument concerns. The null is robust to alternative specifications and is interpreted as a meaningful finding in its own right — discussed in detail in the Key Findings section. The wage point estimate (−0.220, p=0.191) is directionally consistent with the ADH hypothesis and is the most suggestive result in the analysis.

Honest limitations are documented throughout. The 5-year PLFS window (2017–2022) is shorter than ADH's 10-year window; within-state instrument variance is 38% of total, with state fixed effects absorbing 62% of identifying variation; and India's higher informality may limit detectability of formal employment effects.

---

## Research Questions

1. Does exposure to Chinese import competition cause lower non-agricultural employment shares in Indian districts, after instrumenting for endogenous import penetration with the shift-share instrument?
2. Does the effect operate differentially across the skill distribution — specifically, does Chinese competition disproportionately affect middle-skill manufacturing employment?
3. Do districts with better trade infrastructure — proximity to major ports, SEZs, and industrial corridors from Project 6 — absorb the Chinese import shock differently?
4. How sensitive are the main results to the choice of comparison countries, the COVID round, and panel balance?

---

## Econometric Framework

### The Identification Problem

The naive approach regresses changes in district employment on changes in district-level import penetration:

```
ΔEmp_it = α + β · ΔImports_it + controls + ε_it
```

This is endogenous. Districts declining for reasons unrelated to trade — ageing capital stock, shrinking domestic demand — simultaneously experience rising Chinese imports as local firms lose market share and falling employment. OLS conflates the causal effect with pre-existing decline, biasing β.

### The Shift-Share (Bartik) Instrument

The instrument is the inner product of baseline district industry shares and national shifts in Chinese exports to comparison countries:

```
Z_it = Σⱼ (L_ij,2005 / L_i,2005) · (ΔM_other,jt / L_j,2005)
```

Where:
- `L_ij,2005 / L_i,2005` = district i's share of employment in industry j at the 2005 baseline
- `ΔM_other,jt` = change in Chinese exports to comparison countries in industry j, year t
- `L_j,2005` = national employment in industry j at baseline (scaling denominator)

The twelve-year gap between the 2005 baseline shares and the 2017 outcome period maximises pre-determination of shares following Goldsmith-Pinkham, Sorkin and Swift (2020).

### Two-Stage Least Squares

```
Stage 1:  Import_penetration_it = γ · Z_it + δ_s + τ_t + ν_it
Stage 2:  Outcome_it = α + β · Import_penetration_hat_it + δ_s + τ_t + ε_it
```

Where `δ_s` are state fixed effects and `τ_t` are year fixed effects. β is a local average treatment effect for districts whose exposure varies due to China's supply-side expansion.

### Standard Errors

Primary specifications cluster standard errors at the district level. Robustness checks compare to year-only fixed effect specifications. Industry-level clustering (Adao, Kolesár and Morales 2019) is noted as more correct but district-level is reported as the primary result.

---

## Data Sources

| Source | Role |
|--------|------|
| SHRUG EC 2005 (Asher et al. 2021, WBER) | Baseline district × industry shares (28 manufacturing SHRIC codes) |
| CEPII BACI HS92 V202601 | Chinese export shifts — comparison countries + India, 2005–2022 |
| WITS HS-ISIC concordance | HS6 → ISIC Rev 3 → NIC 2004 → SHRIC crosswalk |
| PLFS 2017-18 to 2022-23 (via Project 3) | Labour market outcomes — employment shares, wages, skill groups |
| Project 6 GeoPackage | Trade infrastructure proxies — port, SEZ, corridor distance |

---

## Panel Structure

| Dimension | Value |
|-----------|-------|
| Unit of observation | District × PLFS round |
| Districts in analysis | 617 |
| PLFS rounds | 6 (2017-18 to 2022-23) |
| Total observations | 3,675 |
| Baseline year for shares | 2005 Economic Census (SHRUG) |
| Manufacturing SHRIC codes | 28 (SHRIC 27 excluded — no HS6 mapping) |
| Comparison countries | 5 — USA (842), Germany (276), Japan (392), Australia (36), Canada (124) |
| Regression weights | District baseline employment (2005 EC) |
| State fixed effects | 35 states |
| Post-2011 new districts excluded | ~69 (Telangana, Assam splits, etc. — no EC 2005 baseline) |

---

## Project Structure

```
01_china_shock_emerging_markets/
│
├── README.md                              ← This file
│
├── notebooks/
│   ├── notebook_01_data_assembly.ipynb    ← Instrument construction, data merge
│   ├── notebook_02_descriptive_analysis.ipynb  ← Maps, charts, summary statistics
│   └── notebook_03_regression_analysis.ipynb   ← First stage, OLS, IV, robustness
│
├── data/
│   ├── analysis_dataset.csv              ← Final dataset (3,675 obs, 18 cols)
│   ├── shrug_ec05_baseline_shares.csv    ← District × SHRIC shares (628 districts)
│   ├── hs6_shric_crosswalk.csv           ← HS6 → SHRIC (4,138 codes, 28 SHRICs)
│   ├── summary_statistics.csv            ← Working-paper summary statistics
│   ├── plfs_census2011_crosswalk.csv     ← PLFS code → Census 2011 district name
│   ├── JobID-6_Concordance_H0_to_I3.CSV  ← WITS HS-ISIC concordance (source)
│   ├── shrug-shric-desc-csv/             ← SHRIC descriptions
│   └── shrug-shric-nic04-csv/            ← SHRIC-NIC04 key
│
└── figures/
    ├── fig01_geographic_distribution.png ← Four-panel map
    ├── fig02_industry_composition.png    ← SHRIC shares by quartile
    ├── fig03_binscatter.png              ← Raw instrument-outcome correlations
    ├── fig04_time_series.png             ← Instrument and outcomes by year
    ├── fig05_first_stage.png             ← First-stage scatter
    └── fig06_main_results.png            ← OLS vs IV coefficient plot
```

---

## Key Findings

### Descriptive Analysis (Notebook 2)

**Geographic distribution:** High predicted Chinese import exposure is concentrated in Gujarat, Rajasthan, Maharashtra, and select UP/MP districts — reflecting 2005 employment in machinery, chemicals, textiles, and iron/steel. The pattern is geographically dispersed across states, which is essential for within-state identification with state fixed effects.

**Industry composition:** High-exposure (Q4) districts are more concentrated in machinery and equipment (SHRIC 72, +9.2pp vs Q1), stone/cement (+1.7pp), chemicals (+1.2pp), other textiles (+1.2pp), and iron/steel (+0.7pp). Low-exposure (Q1) districts are more concentrated in grain milling (−0.7pp), tobacco/beedi (−0.2pp), and saw milling (−0.2pp). The instrument captures genuine industrial heterogeneity — not simply manufacturing intensity.

**Raw correlations (binscatter):**
- Instrument vs non-agri share: slope = +0.053 (positive — reflects industrial composition, not causal effect)
- Instrument vs log wage: slope = −0.021 (directionally consistent with ADH)
- Instrument vs middle-skill share: slope = +0.019

**Time series:** Instrument shows substantial year-to-year variation (2019 trade war trough, 2021 post-COVID peak). Non-agricultural employment share is stable across rounds (0.44–0.50), confirming identifying variation is primarily cross-sectional.

### First Stage (Notebook 3)

| Diagnostic | Value | Threshold | Status |
|---|---|---|---|
| Coefficient on Z | +0.125 | Positive required | ✓ |
| Standard error | 0.017 | — | — |
| t-statistic | 7.32 | >3.29 (p<0.001) | ✓ |
| KP F-statistic | ~53.5 | >10 (Stock-Yogo) | ✓ Strong |
| Partial R² | 0.360 | Meaningful | ✓ |

The instrument is strong. A one-unit increase in Z predicts a 0.125 unit increase in actual Chinese import penetration within states and years.

### Primary IV Results (Notebook 3)

| Outcome | OLS | IV | SE | t | p |
|---|---|---|---|---|---|
| Non-agri employment share | −0.015 | +0.051 | 0.056 | 0.91 | 0.364 |
| Log weekly wage (rural) | — | −0.220 | 0.168 | −1.31 | 0.191 |
| Middle-skill share | — | +0.023 | 0.055 | 0.41 | 0.680 |

Notes: 2SLS with state + year fixed effects. Weights = district baseline employment. SEs clustered at district level. N = 3,675 (employment share, middle-skill); 3,151 (log wage).

### Alternative Specifications

| Specification | IV Coef | SE | t | p | N |
|---|---|---|---|---|---|
| Year FEs only | +0.207 | 0.124 | 1.67 | 0.094 | 3,675 |
| State + Year FEs (baseline) | +0.051 | 0.056 | 0.91 | 0.364 | 3,675 |
| Excl. COVID (2020) | +0.032 | 0.053 | 0.60 | 0.547 | 3,060 |
| Balanced panel | +0.046 | 0.056 | 0.84 | 0.404 | 3,618 |

### Instrument Variance Decomposition

| Component | Value |
|---|---|
| Total instrument SD | 1.094 |
| Within state-year SD | 0.674 |
| Within-state share of variance | 38% |
| Within-state correlation (Z, outcome) | 0.002 |

State fixed effects absorb 62% of instrument variation. The within-state identifying variation is limited — the key diagnostic for the null result.

### Honest Interpretation of the Null

The null result is robust and meaningful. Three explanations are plausible:

1. **Insufficient within-state variation:** State fixed effects — necessary to absorb state-level labour law and industrial policy variation — remove 62% of the instrument's identifying variation. The within-state correlation between the instrument and the outcome is 0.002, essentially zero.

2. **Short outcome window:** PLFS covers 2017–2022 (5 years). ADH study a 10-year window (1990–2000). Long-run labour market adjustment through migration and sectoral reallocation may not be visible in the shorter panel.

3. **Indian labour market context:** India's manufacturing sector has higher informality (~90% of manufacturing employment is informal), weaker labour market institutions, and lower internal migration rates than US commuting zones. The adjustment margin in India may be different — informal workers absorbing the shock through wage compression rather than employment loss — limiting detectability of formal employment effects.

The wage point estimate (−0.220) is the most economically meaningful result: directionally consistent with ADH, suggesting Chinese import competition compresses wages, but statistically insignificant at conventional thresholds.

---

## Outputs

| File | Description |
|---|---|
| `data/analysis_dataset.csv` | Final merged dataset — 3,675 obs, 617 districts, 18 columns |
| `data/shrug_ec05_baseline_shares.csv` | District × SHRIC employment shares — 628 districts, 28 SHRICs |
| `data/hs6_shric_crosswalk.csv` | HS6 → SHRIC concordance — 4,138 codes, 28 manufacturing SHRICs |
| `data/summary_statistics.csv` | Working-paper summary statistics — mean, SD, quartiles, N |
| `data/plfs_census2011_crosswalk.csv` | PLFS code → Census 2011 district name — 715 districts, 100% match |
| `figures/fig01_geographic_distribution.png` | Four-panel map: instrument, non-agri share, log wages, port distance |
| `figures/fig02_industry_composition.png` | SHRIC shares by instrument quartile (Q1 vs Q4) |
| `figures/fig03_binscatter.png` | Binscatter: instrument vs non-agri share, wages, middle-skill share |
| `figures/fig04_time_series.png` | Time series: mean instrument and outcomes by year, 2017–2022 |
| `figures/fig05_first_stage.png` | First stage scatter: instrument vs actual import penetration (residualised) |
| `figures/fig06_main_results.png` | Coefficient plot: OLS vs IV, three outcomes, 95% CIs |
| `notebooks/notebook_01_data_assembly.ipynb` | Data assembly and instrument construction |
| `notebooks/notebook_02_descriptive_analysis.ipynb` | Descriptive analysis |
| `notebooks/notebook_03_regression_analysis.ipynb` | Regression analysis |

---

## Limitations

1. **Within-state instrument variation.** Only 38% of total instrument variance is within state-year cells. State fixed effects are essential but costly in this design.

2. **Short PLFS window.** Five years (2017–2022) vs ADH's ten years (1990–2000). Long-run adjustment may not be visible.

3. **Rural-only wages.** PLFS urban blocks carry no district identifier. Log wage outcome is rural wage workers only (85.7% outcome coverage).

4. **Post-2011 district exclusions.** ~69 post-2011 new districts (all of Telangana, plus Assam/CG/Gujarat/MH splits) have no EC 2005 baseline — correctly excluded but limits geographic coverage.

5. **HS-NIC crosswalk imprecision.** SHRIC 27 (casting) excluded — no HS6 mapping. SHRIC 50 excluded — mixes tradeable spinning with non-tradeable repair. Both exclusions are documented and conservative (bias toward zero).

6. **No price deflator.** Import penetration uses trade values, not quantities. Secular decline in Chinese manufacturing prices conflates quantity and price effects.

7. **PLFS representativeness.** PLFS is designed for state-level representativeness. District-level estimates for small districts are noisy — mitigated by weighting by baseline employment.

---

## Connection to Portfolio

| Project | Relationship |
|---|---|
| [03 — Labour Market Polarisation](../03_labour_polarisation_india/) | Provides PLFS outcome panels (employment shares, wages, skill groups) consumed by Project 1. Project 3 documents the outcome patterns; Project 1 provides the causal identification |
| [06 — Trade Exposure Maps](../06_trade_exposure_maps/) | Provides EC 2005 district × industry employment matrix (baseline shares) and trade infrastructure proximity variables (heterogeneity analysis) |
| [02 — Exchange Rate Volatility](../02_exchange_rate_export_margins/) | Project 2 documents the export-side transmission of trade integration; Project 1 documents the import-competition transmission. Together they cover both channels |

---

## References

- Autor, D., Dorn, D., & Hanson, G. (2013). The China Syndrome. *American Economic Review*, 103(6), 2121–2168.
- Goldsmith-Pinkham, P., Sorkin, I., & Swift, H. (2020). Bartik Instruments. *American Economic Review*, 110(8), 2586–2624.
- Borusyak, K., Hull, P., & Jaravel, X. (2022). Quasi-Experimental Shift-Share Research Designs. *Review of Economic Studies*, 89(1), 181–213.
- Adao, R., Kolesár, M., & Morales, E. (2019). Shift-Share Designs: Theory and Inference. *Quarterly Journal of Economics*, 134(4), 1949–2010.
- Asher, S., Lunt, T., Matsuura, R., & Novosad, P. (2021). Development Research at High Geographic Resolution. *World Bank Economic Review*, 35(4), 845–871.
- Topalova, P. (2010). Factor Immobility and Regional Impacts of Trade Liberalization. *American Economic Journal: Applied Economics*, 2(4), 1–41.
- Hasan, R., Mitra, D., & Ramaswamy, K. V. (2007). Trade Reforms, Labor Regulations, and Labor-Demand Elasticities. *Review of Economics and Statistics*, 89(3), 466–481.

## License

MIT License for all analysis code. SHRUG data under SHRUG open access terms (devdatalab.org). CEPII BACI under CEPII research use terms. PLFS under MoSPI research use terms.
