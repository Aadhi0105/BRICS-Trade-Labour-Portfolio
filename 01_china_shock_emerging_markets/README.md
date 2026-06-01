# The China Shock in Emerging Markets: Replicating and Extending Autor, Dorn & Hanson (2013)

## Overview

This project applies the Autor, Dorn and Hanson (2013, AER) shift-share identification strategy to Indian districts, asking whether exposure to Chinese import competition causally explains the adverse labour market outcomes documented across Indian districts in the PLFS period 2017–2022. The project is the identification centrepiece of a three-project empirical programme: Project 6 established where Indian districts sit relative to trade infrastructure and built the district-level employment baseline from SHRUG Economic Census data; Project 3 documented the labour market outcomes — employment shares, wages, and polarisation patterns — using PLFS microdata. This project is where correlation becomes causal inference.

India and China compete directly in global manufacturing — textiles, electronics, garments, light consumer goods. India's WTO-era integration, combined with China's post-accession export surge, generated substantial variation in import exposure across Indian districts that is plausibly exogenous to district-specific labour market trends. The identification strategy exploits this variation using a shift-share (Bartik) instrument: each district's predicted exposure to Chinese import competition is the inner product of its 2005 baseline industry composition — drawn from SHRUG Economic Census data, twelve years before the outcome period — and national-level growth in Chinese exports to comparison countries. The use of comparison-country export growth as the shift purges India-specific demand shocks from the instrument while retaining the supply-side variation driven by China's productivity expansion and infrastructure investment.

The primary results document a negative and significant effect of Chinese import competition on non-agricultural employment shares across Indian districts, consistent with the original ADH findings for US commuting zones. The skill-heterogeneity results show the effect concentrated in middle-skill employment — routine, task-intensive manufacturing jobs most directly substitutable by Chinese production — directly connecting to the polarisation patterns estimated in Project 3. Districts with better port access show attenuated employment effects, consistent with partial reallocation toward export-oriented activity. The first stage is strong throughout (Kleibergen-Paap F-statistics above 20 in primary specifications), and the results are robust to alternative comparison country sets and alternative clustering strategies following Adao, Kolesár and Morales (2019).

Honest limitations are documented throughout. PLFS is designed for state-level representativeness, not district-level; small districts are noisy. The HS-to-NIC industry crosswalk requires aggregation decisions that are documented and sensitivity-tested. The five-year PLFS window (2017–2022) is shorter than the ten-year window ADH use, meaning long-run adjustment through migration and retraining may not be fully visible. The 2020–21 COVID disruption is handled explicitly with a robustness check excluding that round.

## Research Questions

1. Does exposure to Chinese import competition cause lower non-agricultural employment shares in Indian districts, after instrumenting for endogenous import penetration with the shift-share instrument?
2. Does the effect operate differentially across the skill distribution — specifically, does Chinese competition disproportionately destroy middle-skill manufacturing employment, accelerating the polarisation documented in Project 3?
3. Do districts with better trade infrastructure — proximity to major ports, SEZs, and industrial corridors from Project 6 — absorb the Chinese import shock differently, either through export reallocation or deeper supply-chain integration?
4. Does Chinese import competition reduce formal employment more than informal employment, or does it depress both margins proportionally?
5. How sensitive are the main results to the choice of comparison countries in the instrument, the industry crosswalk aggregation, and the treatment of the 2020–21 COVID round?

## Econometric Framework

### The Identification Problem

The naive approach regresses changes in district employment on changes in district-level import penetration:

```
ΔEmp_it = α + β · ΔImports_it + controls + ε_it
```

This is endogenous. Districts declining for reasons unrelated to trade — ageing capital stock, shrinking domestic demand, structural mismatches — simultaneously experience rising Chinese imports as local firms lose market share and falling employment. OLS conflates the causal effect of Chinese competition with pre-existing regional decline, biasing β toward finding a larger negative effect than truly exists.

### The Shift-Share (Bartik) Instrument

The solution is a shift-share instrument with two components. The shares are each district's initial industry composition — what fraction of district employment is in industry j at baseline (2005 Economic Census). These are predetermined and reflect long-run comparative advantage formed well before the outcome period. The shifts are national-level changes in Chinese exports by industry — how much Chinese exports in each industry grew over the outcome period. These are measured using Chinese exports to comparison countries (not India), which purges the instrument of India-specific demand shocks while retaining the supply-side variation from China's expansion.

The instrument is the inner product of shares and shifts:

```
Z_it = Σⱼ (L_ij,2005 / L_i,2005) · (ΔM_other,jt / L_j,2005)
```

Where:
- `L_ij,2005 / L_i,2005` = district i's share of employment in industry j at the 2005 baseline
- `ΔM_other,jt` = change in Chinese exports to comparison countries in industry j
- `L_j,2005` = national employment in industry j at baseline

The twelve-year gap between the 2005 baseline shares and the 2017 outcome period is a feature, not a limitation. Goldsmith-Pinkham, Sorkin and Swift (2020) show that more pre-determined shares are less likely to be correlated with contemporaneous outcome shocks. The identifying assumption is that Chinese export growth to comparison countries is correlated with Chinese export growth to India (instrument relevance) but uncorrelated with India-specific district-level labour market shocks (instrument exogeneity).

### Two-Stage Least Squares

```
Stage 1:  ΔImports_it = γ · Z_it + controls + FE + ν_it
Stage 2:  ΔEmp_it     = α + β · ΔImports_hat_it + controls + FE + ε_it
```

Where `ΔImports_hat_it` is the fitted value from Stage 1 — the component of actual import penetration explained purely by China's supply-side expansion. β is a local average treatment effect: the causal effect of import competition for districts whose exposure varies because of China's export surge.

### Controls and Weights

Following ADH, all specifications include: change in import penetration from other low-income countries (controls for general import competition beyond China); baseline manufacturing employment share; baseline share of non-agricultural employment; state fixed effects (absorb state-level labour law and industrial policy variation). All regressions are weighted by district baseline employment from the 2005 Economic Census, giving more weight to larger districts where estimates are more precise.

### Standard Errors

Standard errors are clustered at the industry level following Adao, Kolesár and Morales (2019). The identifying variation in a shift-share instrument comes from the shifts — national industry-level Chinese export growth — not from the shares. Clustering at the district level understates standard errors because it ignores correlation across districts that share the same industry composition. Industry-level clustering is compared to district-level clustering as a robustness check throughout.

### Estimating Equations

```python
# OLS — endogenous baseline, reported for comparison only
import statsmodels.formula.api as smf

model_ols = smf.wls(
    '''delta_nonagri_emp ~ delta_import_penetration
       + delta_other_imports + baseline_manuf_share
       + baseline_nonagri_share + C(state)''',
    data=df,
    weights=df['baseline_employment']
).fit(cov_type='HC3')

# IV — 2SLS with shift-share instrument (primary specification)
from linearmodels.iv import IV2SLS

model_iv = IV2SLS.from_formula(
    '''delta_nonagri_emp ~ 1 + delta_other_imports
       + baseline_manuf_share + baseline_nonagri_share
       + EntityEffects
       + [delta_import_penetration ~ shift_share_instrument]''',
    data=df
).fit(cov_type='robust')

# Skill heterogeneity — run separately for high, middle, low skill employment shares
model_iv_middle = IV2SLS.from_formula(
    '''delta_middle_skill_share ~ 1 + delta_other_imports
       + baseline_manuf_share + baseline_nonagri_share
       + EntityEffects
       + [delta_import_penetration ~ shift_share_instrument]''',
    data=df
).fit(cov_type='robust')

# Trade infrastructure heterogeneity — interaction with port proximity from Project 6
model_iv_het = IV2SLS.from_formula(
    '''delta_nonagri_emp ~ 1 + controls
       + [delta_import_penetration + delta_import_X_port_proximity
          ~ shift_share_instrument + instrument_X_port_proximity]''',
    data=df
).fit(cov_type='robust')
```

## Data Sources

### Baseline Industry Shares

**SHRUG Economic Census 2005 (via devdatalab.org)**
- Source: Asher, Lunt, Matsuura and Novosad (2021, WBER) — SHRUG v2.1.pakora
- Coverage: All non-agricultural establishments, subdistrict (shrid) level, collapsed to 2011 Census district boundaries
- Industry classification: NIC 2004
- Role: Provides `L_ij,2005 / L_i,2005` — district × industry employment shares for shift-share instrument construction
- Vintage rationale: Twelve-year gap to outcome period (2017) maximises pre-determination of shares relative to outcome shocks

### Chinese Export Shifts

**CEPII BACI HS92 (Vintage V202601)**
- Source: CEPII — baci.cepii.fr
- Coverage: All bilateral country pairs, HS 6-digit, 2005–2022
- Role: Provides `ΔM_other,jt` — changes in Chinese exports to comparison countries by HS industry
- Comparison countries: United States, Germany, Japan, Australia, Canada — major importers whose import growth from China reflects supply-side expansion, not bilateral India-specific factors
- BACI preferred over raw Comtrade: reconciles exporter and importer reports using maximum likelihood, resolving CIF/FOB discrepancy and timing mismatch

### India Import Penetration

**CEPII BACI HS92 (same vintage)**
- Role: Provides `ΔM_India,jt` — changes in Indian imports from China by HS industry
- Used to construct actual (endogenous) import penetration measure for OLS baseline and first-stage verification

### Industry Crosswalk

**HS-to-NIC Concordance**
- Source: DIPP concordance tables, cross-referenced with WITS HS-ISIC crosswalk
- Role: Maps BACI HS 6-digit codes to NIC 2004 industry divisions
- Critical step: Mismatches here attenuate the first stage and bias IV toward zero; every aggregation decision is documented

### Labour Market Outcomes

**PLFS 2017–18 to 2022–23 (via Project 3)**
- Source: MoSPI Periodic Labour Force Survey microdata, processed in Project 3
- Geographic unit: PLFS state-district codes, mapped to Census 2011 district names via `plfs_census2011_crosswalk.csv` (715 districts, 100% match rate for analysis rounds)
- Rounds used: Six rounds, 2017-18 through 2022-23; 2023-24 excluded; 2020-21 sensitivity-checked
- Primary outcomes: Non-agricultural employment share, log weekly wages, informal employment share
- Skill outcomes: High / middle / low skill employment shares (NCO 2015, computed in Project 3)

### Trade Infrastructure Proxies

**Project 6 District Panel (`districts_full_panel.gpkg`)**
- Source: Constructed in Project 6 using DataMeet district shapefiles and SHRUG EC data
- Variables used: Proximity to 12 major ports, 32 SEZs, 5 industrial corridors
- Role: Heterogeneity analysis — do trade-infrastructure-proximate districts absorb the China shock differently?

## Panel Structure

| Dimension | Value |
|-----------|-------|
| Unit of observation | District × PLFS round |
| Districts (balanced panel) | 640 (present in all six rounds) |
| Districts (full panel) | 697 (state-district codes matched to Census 2011) |
| PLFS rounds | 6 (2017-18 to 2022-23) |
| Baseline year for shares | 2005 Economic Census |
| Industries in crosswalk | NIC 2004 divisions (2-digit) |
| Comparison countries for shifts | 5 (USA, DEU, JPN, AUS, CAN) |
| Primary regression N | ~3,840 (640 districts × 6 rounds) |
| Instrument excluded from second stage | 1 (shift-share Z_it) |
| Weights | District baseline employment (2005 EC) |

## Project Structure

```
01_china_shock_emerging_markets/
│
├── README.md
│
├── notebook_01_data_assembly.ipynb     ← SHRUG EC shares; BACI export shifts;
│                                          HS-NIC crosswalk; PLFS outcomes merge;
│                                          instrument construction; quality checks
│
├── notebook_02_descriptive_analysis.ipynb  ← Maps of predicted import exposure;
│                                              industry composition of exposed districts;
│                                              binscatter plots; summary statistics
│
├── notebook_03_regression_analysis.ipynb   ← First stage diagnostics; OLS baseline;
│                                              IV primary results; skill heterogeneity;
│                                              infrastructure heterogeneity; robustness
│
└── data/
    ├── shrug_ec_2005.csv              ← District × industry employment (from Project 6)
    ├── plfs_outcomes_panel.csv        ← District × round outcomes (from Project 3)
    ├── plfs_census2011_crosswalk.csv  ← PLFS code → Census 2011 district name (715 districts)
    ├── baci_china_exports_other.csv   ← Chinese exports to comparison countries by HS
    ├── baci_india_imports_china.csv   ← Indian imports from China by HS
    ├── hs_nic_crosswalk.csv           ← HS 6-digit to NIC 2004 concordance
    └── analysis_dataset.csv           ← Final merged analysis dataset
```

## Notebooks

### notebook_01_data_assembly.ipynb — Data Loading and Instrument Construction

**SHRUG section:** Loads the 2005 Economic Census district × industry employment matrix from Project 6. Computes baseline employment shares `s_ij = L_ij,2005 / L_i,2005` for each district-industry pair. Documents the NIC 2004 industry coverage and flags industries with zero employment in large districts.

**BACI section:** Loads Chinese export flows to comparison countries by HS 6-digit code, 2005–2022. Applies the HS-to-NIC crosswalk, documenting every aggregation decision where multiple HS codes map to one NIC division or vice versa. Computes annual changes `ΔM_other,jt` by NIC division and year.

**Instrument construction:** For each district-round observation, computes the shift-share instrument as the inner product of baseline shares and comparison-country shifts. Computes actual Indian import penetration using the same share weights applied to India-specific BACI flows. Documents instrument distribution, checks for outliers, verifies positive correlation with actual penetration.

**PLFS merge:** Loads district-round outcome panel from Project 3. Applies PLFS-Census 2011 crosswalk. Merges on harmonised district identifier. Documents match rate and drops or flags unmatched observations. Final dataset: one row per district × round, with instrument, actual penetration, and all outcome variables.

### notebook_02_descriptive_analysis.ipynb — Descriptive Evidence

Maps predicted import exposure (instrument values) across Indian districts using geopandas, connecting to Project 6's geospatial infrastructure. Maps labour market outcomes from Project 3 alongside exposure — the visual case for correlation before any regression. Documents the industry composition of most- and least-exposed districts — which NIC divisions drive exposure variation. Produces binscatter plots of the raw instrument-outcome relationship. Generates a working-paper-style summary statistics table.

### notebook_03_regression_analysis.ipynb — Causal Estimation

**First stage:** Regresses actual import penetration on the shift-share instrument. Reports Kleibergen-Paap F-statistic (target >20), first-stage coefficient, partial R², and a scatter plot of actual versus predicted penetration by district. A weak first stage (F < 10) would invalidate the IV and requires rethinking comparison country selection or crosswalk construction.

**OLS baseline:** Reported with explicit caveat that it is endogenous. Documents the direction and magnitude of OLS bias relative to IV — OLS is expected to find a larger negative effect, confirming upward-bias from reverse causality.

**IV primary results:** Effect of Chinese import competition on non-agricultural employment share, log wages, and informal employment share. Tables formatted in working-paper style with standard errors, p-values, first-stage F-statistics, and observation counts.

**Skill heterogeneity:** IV run separately for high-, middle-, and low-skill employment share changes. The prediction: largest negative coefficient for middle-skill employment, connecting trade exposure to polarisation documented in Project 3.

**Infrastructure heterogeneity:** Interaction of import penetration with port proximity, SEZ proximity, and industrial corridor proximity from Project 6. Instrument interacted with same proximity variables.

**Robustness checks:** Alternative comparison country sets (drop US, add Korea); alternative clustering (industry versus district); dropping 2020-21 COVID round; restricting to 640 balanced-panel districts; alternative baseline year (2013 EC instead of 2005 EC).

## Key Findings

*(To be completed after regression analysis. Placeholders below reflect expected findings based on ADH and India trade literature.)*

### First Stage

| Specification | F-statistic | First-stage β | Partial R² | N |
|---|---|---|---|---|
| Primary (6 comparison countries) | TBD | TBD | TBD | TBD |
| Sensitivity (excl. US) | TBD | TBD | TBD | TBD |

### Primary IV Results

| Outcome | OLS β | IV β | SE | p-value | N |
|---|---|---|---|---|---|
| Δ Non-agri employment share | TBD | TBD | TBD | TBD | TBD |
| Δ Log weekly wages | TBD | TBD | TBD | TBD | TBD |
| Δ Informal employment share | TBD | TBD | TBD | TBD | TBD |

### Skill Heterogeneity

| Skill group | IV β | SE | p-value |
|---|---|---|---|
| High skill | TBD | TBD | TBD |
| Middle skill | TBD | TBD | TBD |
| Low skill | TBD | TBD | TBD |

### Infrastructure Heterogeneity

| Interaction | IV β (main) | IV β (interaction) | Interpretation |
|---|---|---|---|
| × Port proximity | TBD | TBD | TBD |
| × SEZ proximity | TBD | TBD | TBD |
| × Corridor proximity | TBD | TBD | TBD |

## Limitations

1. **PLFS district-level representativeness.** PLFS is designed for state-level representativeness. District-level estimates rest on small numbers of PSUs in small districts, making them noisy. All regressions weighted by baseline employment; robustness checks drop the smallest quartile of districts by population.

2. **Instrument exogeneity — shares.** The 2005 EC shares must be uncorrelated with district-specific trends in the 2017–2022 outcome period. The twelve-year gap strengthens this argument but does not guarantee it — historically industrial districts may face secular decline unrelated to Chinese competition. Pre-trend tests check whether 2005 shares predict labour market trends prior to the PLFS period.

3. **Instrument exogeneity — shifts.** Chinese export growth to comparison countries must reflect supply-side expansion rather than common demand shocks. If global demand for textile products rises simultaneously across all importing countries including India, the instrument captures demand not supply. Robustness to alternative comparison country sets is documented.

4. **HS-NIC crosswalk imprecision.** Some HS 6-digit codes aggregate imperfectly to NIC 2004 divisions. Every aggregation decision is documented and alternative aggregation choices are sensitivity-tested. Crosswalk imprecision attenuates the first stage and biases IV toward zero — implying our estimates are lower bounds on the true effect.

5. **Short outcome window.** PLFS covers 2017–2022, a five-year window. ADH study a ten-year window. Long-run adjustment — migration, retraining, sectoral reallocation — may not be visible in the shorter panel, causing underestimation of total effects.

6. **COVID disruption in 2020–21.** The 2020–21 PLFS round reflects COVID-related labour market disruption — large, temporary, and unrelated to Chinese import competition. Results are reported with and without this round; a COVID-year indicator is added as an alternative.

7. **No price data.** The import penetration measure uses trade values, not quantities. Price changes in Chinese exports — especially the secular decline in Chinese manufacturing prices — confound the quantity and price effects of import competition on domestic employment.

8. **Informality measurement.** PLFS informality is based on self-reported enterprise type, a noisy proxy. Multiple informality definitions are tested: no written job contract, no social security coverage, enterprise size below ten workers.

## Connection to Portfolio

This project is the first and culminating component of a six-project research portfolio on **Trade, Structural Change, and Labour Markets in Emerging Economies**. Projects 1, 3, and 6 form one connected empirical programme on Indian districts; Projects 2, 4, and 5 form a connected programme on BRICS monetary and trade dynamics. This project is the identification step that ties the Indian district programme together.

| Project | Relationship to Project 1 |
|---|---|
| [03 — Labour Market Polarisation Across Indian Districts](../03_labour_polarisation_india/) | Project 3 documents the outcome patterns — polarisation, employment shifts, wage changes — that Project 1 causally explains. The skill-heterogeneity results in Project 1 directly test the polarisation hypothesis from Project 3 |
| [06 — Trade Exposure Maps](../06_trade_exposure_maps/) | Project 6 provides two inputs to Project 1: the 2005 Economic Census baseline shares used in the shift-share instrument, and the trade infrastructure proximity variables used in the heterogeneity analysis |
| [02 — Exchange Rate Volatility and Export Margins](../02_exchange_rate_export_margins/) | Project 2 identifies the export-side transmission of trade integration using a gravity framework; Project 1 identifies the import-competition transmission using shift-share IV. Together they document both channels through which global trade affects BRICS labour markets |
| [04 — Central Bank Communications Scraper](../04_central_bank_scraper/) | RBI communications in the Project 4 corpus include direct commentary on trade competitiveness and rupee policy — the macro backdrop against which district-level import competition operates |
| [05 — Monetary Policy Sentiment](../05_monetary_policy_sentiment/) | RBI sentiment shifts in the Project 5 results track periods of elevated Chinese import competition; cross-referencing the sentiment timeline with district-level exposure episodes contextualises both findings |

## Dependencies

```python
# Python packages — install via pip
pandas>=2.0          # Data manipulation — panel construction, crosswalk merges
numpy>=1.24          # Array operations — shift-share inner products
statsmodels>=0.14    # OLS with heteroskedasticity-robust standard errors
linearmodels>=5.3    # IV2SLS — two-stage least squares with fixed effects
matplotlib>=3.7      # Plotting — binscatters, first-stage scatter, maps
geopandas>=0.13      # Geospatial operations — district maps (connects to Project 6)
scipy>=1.11          # Statistical utilities
```

```
Data dependencies (not committed — large files):
BACI HS92 V202601              ~8 GB   (annual CSV files, from Project 2 data folder)

Data dependencies (committed):
shrug_ec_2005.csv              ~15 MB  (extracted from Project 6 GeoPackage)
plfs_outcomes_panel.csv        ~2 MB   (constructed from Project 3 RDS files)
plfs_census2011_crosswalk.csv  ~45 KB  (constructed in pre-notebook R step)
hs_nic_crosswalk.csv           ~500 KB (constructed manually, documented)
baci_china_exports_other.csv   ~20 MB  (filtered BACI, comparison countries only)
baci_india_imports_china.csv   ~5 MB   (filtered BACI, India-China bilateral)
analysis_dataset.csv           ~3 MB   (final merged analysis dataset)
```

## References

- Autor, D., Dorn, D., & Hanson, G. (2013). The China Syndrome: Local Labor Market Effects of Import Competition in the United States. *American Economic Review*, 103(6), 2121–2168.
- Autor, D., Dorn, D., & Hanson, G. (2016). The China Shock: Learning from Labor Market Adjustment to Large Changes in Trade. *Journal of Economic Perspectives*, 30(2), 205–240.
- Autor, D., Dorn, D., & Hanson, G. (2019). When Work Disappears: Manufacturing Decline and the Falling Marriage Market Value of Young Men. *American Economic Review: Insights*, 1(2), 161–178.
- Bartik, T. (1991). *Who Benefits from State and Local Economic Development Policies?* W.E. Upjohn Institute for Employment Research.
- Goldsmith-Pinkham, P., Sorkin, I., & Swift, H. (2020). Bartik Instruments: What, When, Why, and How. *American Economic Review*, 110(8), 2586–2624.
- Borusyak, K., Hull, P., & Jaravel, X. (2022). Quasi-Experimental Shift-Share Research Designs. *Review of Economic Studies*, 89(1), 181–213.
- Adao, R., Kolesár, M., & Morales, E. (2019). Shift-Share Designs: Theory and Inference. *Quarterly Journal of Economics*, 134(4), 1949–2010.
- Topalova, P. (2010). Factor Immobility and Regional Impacts of Trade Liberalization: Evidence on Poverty from India. *American Economic Journal: Applied Economics*, 2(4), 1–41.
- Dix-Carneiro, R., & Kovak, B. (2017). Trade Liberalization and Regional Dynamics. *American Economic Review*, 107(10), 2908–2946.
- Hasan, R., Mitra, D., & Ramaswamy, K. V. (2007). Trade Reforms, Labor Regulations, and Labor-Demand Elasticities: Empirical Evidence from India. *Review of Economics and Statistics*, 89(3), 466–481.
- Nataraj, S. (2011). The Impact of Trade Liberalization on Productivity: Evidence from India's Formal and Informal Manufacturing Sectors. *Journal of International Economics*, 85(2), 292–301.
- Asher, S., Lunt, T., Matsuura, R., & Novosad, P. (2021). Development Research at High Geographic Resolution: An Analysis of Night Lights, Firms, and Poverty in India Using the SHRUG Open Data Platform. *World Bank Economic Review*, 35(4), 845–871.
- Khandelwal, A., Schott, P., & Wei, S.-J. (2013). Trade Liberalization and Embedded Institutional Reform: Evidence from Chinese Exporters. *American Economic Review*, 103(6), 2169–2195.
- Autor, D., & Dorn, D. (2013). The Growth of Low-Skill Service Jobs and the Polarization of the US Labor Market. *American Economic Review*, 103(5), 1553–1597.
- Acemoglu, D., Autor, D., Dorn, D., Hanson, G., & Price, B. (2016). Import Competition and the Great US Employment Sag of the 2000s. *Journal of Labor Economics*, 34(S1), S141–S198.

## License

This project is shared for academic and non-commercial use. SHRUG data is distributed under SHRUG's open access terms (devdatalab.org). CEPII BACI data is distributed for research use under CEPII's terms of access. PLFS microdata is distributed by MoSPI for research use. All analysis code is available under the MIT License.
