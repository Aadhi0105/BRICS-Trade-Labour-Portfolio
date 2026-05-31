# Labour Market Polarisation Across Indian Districts: A Distributional Analysis

## Overview

This project examines structural change in Indian labour markets across districts using seven rounds of the Periodic Labour Force Survey (PLFS) — 2017-18 to 2023-24. The original research question asked whether Indian labour markets show polarisation in the ADH sense: a hollowing out of middle-skill employment relative to high- and low-skill occupations. The analysis found that PLFS occupation coding quality prevents clean identification of this pattern using the three-way NCO skill classification. The primary analytical contribution is instead a district-level characterisation of agricultural versus non-agricultural employment structure, its gender decomposition, its urban-rural dynamics, and its correlation with the trade exposure proxies from Project 6 of this portfolio.

The project makes three substantive contributions. First, it documents a systematic NCO occupation coding break in PLFS between 2020-21 and 2021-22, which artificially shifts employment from the high-skill to the middle-skill category and makes cross-round polarisation comparisons unreliable. Second, it identifies a widening gender gap in non-agricultural employment — employed women are increasingly classified in agricultural occupations relative to men, with the urban gap widening from 11 to 19 percentage points between 2019 and 2024. Third, it establishes that district proximity to major ports is the most robust correlate of non-agricultural employment structure within states, surviving both urban and rural specifications with consistent signs and statistical significance.

## Research Questions

1. Is there evidence of labour market polarisation — declining middle-skill employment shares — across Indian districts between 2017-18 and 2023-24?
2. Does the structure of non-agricultural employment differ systematically by gender, and is the gender gap widening or narrowing?
3. Are urban and rural employment dynamics structurally distinct within the same districts?
4. Does district-level proximity to trade infrastructure — ports, SEZs, and industrial corridors — correlate with non-agricultural employment structure within states?

## Data Sources

### Primary Survey Data

**Periodic Labour Force Survey (PLFS), 2017-18 to 2023-24**
- Source: National Statistical Office (NSO), Ministry of Statistics and Programme Implementation (MOSPI), Government of India
- Access: National Data Archive — microdata.gov.in
- Coverage: All states and union territories of India, rural and urban sectors
- Rounds: Seven annual rounds (2017-18, 2018-19, 2019-20, 2020-21, 2021-22, 2022-23, 2023-24)
- Distribution format: Nesstar binary format for rounds 2017-18, 2020-21, 2021-22, 2022-23, 2023-24; direct Stata format for 2018-19 and 2019-20
- Conversion: Nesstar-format rounds converted to Stata using the `nesstar-converter` Python package (v1.0.3) under Python 3.11

**Key variables used:** District code, sector (rural/urban), sex, age, education, usual principal activity status, current weekly activity status, occupation code (NCO 2015, 1-digit), industry code (NIC 2008), survey multiplier (weight)

**Person-level file structure per round:**

| File | Content | Naming convention |
|---|---|---|
| Urban person | Person-level employment, urban sector | `hh_per_fv` (2017-18), `PerV1` (2018-19/19-20), `perv1` (2020-21 onwards) |
| Rural person | Person-level employment, rural sector | `hh_per_rv` (2017-18), `PerRV` (2018-19/19-20), `perrv` (2020-21 onwards) |

### Secondary Data — Trade Exposure

**Project 6 District Trade Exposure Panel**
- Source: Constructed in Project 6 of this portfolio using SHRUG v2.1 Economic Census data and spatial proximity to trade infrastructure
- File: `districts_full_panel.gpkg` (640 districts, 42 attribute columns)
- Variables merged: Distance to nearest major port (km), distance to nearest SEZ (km), any industrial corridor overlap indicator, nonfarm employment share (Economic Census 2013), Census 2011 population
- Geographic unit: Census 2011 district boundaries
- Merge key: Census sequential censuscode (state offset + within-state district position - 1)
- Match rate: 616 of 640 districts (96.25%)

## Key Methodological Findings

### NCO Occupation Coding Break

The NCO 2015 occupation code in PLFS is unreliable for cross-round comparisons. In rounds 2017-18 through 2020-21, code 121 (Business Services Managers) accounts for 36-40% of rural employed workers and 13-17% of urban employed workers. From 2021-22 onwards, code 121 falls to under 12%, replaced primarily by code 522 (Service and Sales Workers). This reflects a MOSPI coding revision in enumerator guidelines, not a real economic shift. The apparent rise in middle-skill employment shares from 2021-22 onwards is substantially an artefact of this reclassification.

As a result, the three-way skill classification (high: NCO 1-3; middle: NCO 4,5,7,8; low: NCO 6,9) is not used as the primary analytical variable. The agricultural versus non-agricultural binary — using NCO groups 6 and 9 as agricultural, all others as non-agricultural — is the primary measure throughout, as it is unaffected by the NCO 121 revision.

### Urban-Rural NCO Coding Paradox

PLFS occupation coding produces a counterintuitive sectoral pattern: rural non-agricultural employment shares (~82-86%) substantially exceed urban non-agricultural shares (~43-47%). This is an artefact. In rural areas, NCO 121 and 522 inflate the non-agricultural category. In urban areas, NCO 611 (Market Gardeners) accounts for approximately 42% of urban employed workers, inflating the urban agricultural category. The within-district urban-rural correlation in non-agricultural shares is only r = 0.255, confirming the two series are largely driven by different coding patterns.

### Employment Status and Earnings

PLFS records activity status in three broad categories in these rounds: 11 (self-employed), 12 (regular wage/salaried), and 21 (casual wage). Earnings (Block 6 variable b6q9) are effectively zero for almost all observations — the rural summary earnings variable is entirely zero and urban earnings are available for fewer than 0.1% of observations. Wage analysis is therefore not included in this project. This reflects the structure of PLFS Block 6 earnings, which are recorded across day-level sub-variables in the rural schedule and not aggregated reliably into the summary variable.

## Classification Framework

### Three-Way Skill Classification (urban primary analysis, with caveats)

| Skill group | NCO 2015 codes | Occupations |
|---|---|---|
| High-skill | 1, 2, 3 | Managers, professionals, technicians |
| Middle-skill | 4, 5, 7, 8 | Clerical, service/sales, craft, machine operators |
| Low-skill | 6, 9 | Skilled agricultural workers, elementary occupations |

Not used for cross-round trend analysis due to the NCO 121 coding break. Used descriptively for within-round cross-sectional comparisons.

### Agricultural vs Non-Agricultural Binary (primary measure)

- Agricultural: NCO major groups 6 and 9
- Non-agricultural: all other NCO major groups

Used for all trend analysis, gender decomposition, urban-rural comparison, and trade exposure regression. Internally consistent across all seven rounds.

## Project Structure

```
03_labour_polarisation_india/
│
├── README.md
│
├── notebooks/
│   ├── 01_clean.Rmd          ← Data loading, harmonisation, skill classification
│   ├── 01_clean.html
│   ├── 02_aggregate.Rmd      ← District-level panel construction
│   ├── 02_aggregate.html
│   ├── 03_polarisation.Rmd   ← National trends and distributional analysis
│   ├── 03_polarisation.html
│   ├── 04_gender.Rmd         ← Gender decomposition
│   ├── 04_gender.html
│   ├── 05_urban_rural.Rmd    ← Urban-rural structural comparison
│   ├── 05_urban_rural.html
│   ├── 06_regression.Rmd     ← Trade exposure regression, Project 6 merge
│   └── 06_regression.html
│
└── data/
    ├── PLFS_Data_2017-18/    ← Nesstar binary + DDI XML + converted output/
    ├── PLFS_Data_2018-19/    ← Direct Stata download
    ├── PLFS_Data_2019-20/    ← Direct Stata download
    ├── PLFS_Data_2020-21/    ← Nesstar binary + DDI XML + converted output/
    ├── PLFS_Data_2021-22/    ← Nesstar binary + DDI XML + converted output/
    ├── PLFS_Data_2022-23/    ← Nesstar binary + DDI XML + converted output/
    ├── PLFS_Data_2023-24/    ← Nesstar binary + DDI XML + converted output/
    ├── plfs_clean.rds        ← Harmonised person-level dataset (1,015,760 rows)
    ├── plfs_skill_panel.rds  ← District × round × sector × sex skill shares
    └── plfs_agri_panel.rds   ← District × round × sector × sex agri/non-agri shares
```

## Notebooks

### Notebook 1 — Data Loading, Harmonisation, and Classification

Loads all 14 PLFS person-level files across seven rounds using `haven::read_dta()`. Resolves three naming inconsistencies: the `_per_fv`/`_perv1` suffix split between direct Stata downloads and Nesstar-converted files, the district variable rename from `b1q4_per_fv` to `distcode_perv1` (and `b1q4_perrv` in 2021-22 rural specifically), and type inconsistencies between Stata formats. Applies the employment status filter retaining 1,015,760 employed workers from 6.3 million raw observations. Documents the NCO 121 coding break with empirical evidence from the NCO code frequency distributions. Saves `plfs_clean.rds`.

### Notebook 2 — District-Level Aggregation

Constructs the district-level panel by merging PLFS state-district codes to a consistent state_district key and aggregating weighted employment counts. Applies the balanced panel filter (640 districts present in all seven rounds) and minimum cell size threshold (emp_n ≥ 25). Saves `plfs_skill_panel.rds` (70,728 rows) and `plfs_agri_panel.rds` (50,091 rows), both with balanced panel flags. Notes that rural 2021-22 lacks a district code variable under the expected name and applies a per-round fix.

### Notebook 3 — Polarisation Analysis

Shows that national skill share trends using the three-way classification are dominated by the NCO 121 coding break rather than genuine polarisation. The low-skill share (NCO groups 6 and 9) is the only component stable across all seven rounds (rural: 14-15%, urban: 61-63%). The agri/non-agri binary series is flat nationally — rural 82-86%, urban 43-47% — reflecting the NCO coding paradox rather than genuine structural stability. District-level distributions are stable across rounds with no detectable trend shift. The COVID-19 shock produces no systematic aggregate change in non-agricultural shares, though district-level changes have a standard deviation of 13-14 percentage points.

### Notebook 4 — Gender Decomposition

Finds a consistently widening gender gap in non-agricultural employment within each sex. Of all employed women, the non-agricultural share falls from 81% to 76% in rural areas and from 31% to 24% in urban areas between 2017-18 and 2023-24, while male shares are stable or slightly rising. The urban gender gap widens from 11 to 19 percentage points. Female district-level estimates are available for only 50-147 rural and 62-80 urban districts per round — 15-20% of male coverage — reflecting India's low female labour force participation.

### Notebook 5 — Urban-Rural Decomposition

The distributions of urban and rural non-agricultural employment shares are almost entirely non-overlapping. The within-district correlation is r = 0.255, indicating weak integration between urban and rural labour markets within the same geographic unit. The urban-rural gap varies substantially by state — from 4 percentage points in Delhi to 62 points in Meghalaya — with southern and north-western states (Tamil Nadu, Punjab, Kerala) showing smaller gaps and north-eastern and central Indian states (Meghalaya, Himachal Pradesh, Chhattisgarh) showing larger gaps.

### Notebook 6 — Trade Exposure Regression

Merges 616 districts (96.25% match rate) from the PLFS panel with Project 6's trade exposure panel using the Census 2011 sequential censuscode. Regresses the district-level average non-agricultural employment share on log distance to nearest major port, log distance to nearest SEZ, and any industrial corridor indicator, with Economic Census 2013 nonfarm share and population controls and state fixed effects. Port proximity is negative and significant in both urban (β = -0.031, p = 0.025) and rural (β = -0.033, p = 0.002) regressions — the most robust finding. SEZ proximity is significant for urban only. Industrial corridor membership is negative in both sectors, likely reflecting the coarseness of the binary indicator and concentration of elementary occupation workers in active corridor zones.

## Key Findings

**On polarisation:** The three-way skill classification cannot support clean polarisation claims for the 2017-2024 PLFS period due to the NCO 121 coding revision. This is an important methodological finding about PLFS data quality that prior studies using this period have not fully documented.

**On structural transformation:** Neither the three-way classification nor the agri/non-agri binary detects national-level structural transformation trends within this seven-year window. The levels are mis-measured due to coding issues; the trends are too flat to be informative.

**On gender:** The widening gender gap in non-agricultural employment — women increasingly classified as agricultural relative to men — is the most economically significant finding. Whether this reflects genuine feminisation of agriculture or differential coding bias cannot be definitively determined from this data.

**On trade exposure:** Port proximity is the single most robust trade exposure correlate of non-agricultural employment structure, consistent across urban and rural sectors and robust to state fixed effects. Districts closer to major ports show systematically higher non-agricultural employment shares within states.

## Limitations

1. **NCO coding quality prevents polarisation identification.** The PLFS three-way skill classification cannot be used for cross-round trend analysis due to the documented 2021-22 coding revision. All trend analysis uses the agri/non-agri binary, which has its own level-measurement problems.

2. **Seven-year panel is short.** The PLFS era (2017-18 to 2023-24) covers only seven years. Detecting structural transformation trends typically requires longer panels. The pre-PLFS NSSO EUS data uses a different survey instrument and occupation classification, preventing clean extension backwards.

3. **Occupation coding is systematically unreliable.** The rural non-agricultural share of ~85% and urban agricultural share of ~62% are both implausibly large and driven by NCO coding patterns rather than economic reality. This fundamentally limits the interpretability of level estimates.

4. **Earnings analysis is not possible.** The PLFS Block 6 earnings summary variable is zero for almost all observations. The rural earnings variable is entirely zero. Day-level earnings sub-variables were not loaded.

5. **Female LFPR limits district-level gender analysis.** Only 15-20% as many female as male districts pass the minimum cell size threshold. District-level gender comparisons are based on a selected, high-LFPR subset of districts.

6. **Urban district-level PLFS estimates are unreliable for small cities.** The urban PLFS component is designed for state-level representativeness. Urban district estimates for smaller cities carry high sampling variance.

7. **Trade exposure regression is correlational.** No credible causal identification strategy is available with the current data. The ADH-style Bartik instrument requires district-level industry employment from SHRUG's forthcoming NIC-linked Economic Census module.

8. **2017-18 urban sex data is unreliable.** The sex variable has 49.8% missing values in the 2017-18 urban file due to the rotating panel visit structure. Urban gender analysis begins from 2018-19.

## Dependencies

```r
haven       >= 2.5.0    # Reading Stata .dta files
tidyverse   >= 2.0.0    # Data manipulation and visualisation
labelled    >= 2.12.0   # Handling Stata variable and value labels
janitor     >= 2.2.0    # Data cleaning utilities
srvyr       >= 1.2.0    # Survey-weighted analysis
fixest      >= 0.11.0   # Fast fixed effects regression
ggplot2     >= 3.4.0    # Publication-quality visualisation
patchwork   >= 1.1.0    # Combining multiple ggplot2 panels
scales      >= 1.2.0    # Axis and legend formatting
sf          >= 1.0.0    # Reading GeoPackage files
broom       >= 1.0.0    # Tidying regression output
knitr       >= 1.42     # R Markdown rendering
rmarkdown   >= 2.21     # HTML output
```

**Data conversion dependency (Python):**
```
nesstar-converter >= 1.0.3   # pip install nesstar-converter (requires Python >= 3.10)
```

## Connection to Portfolio

This project is the third component of a six-project research portfolio on **Trade, Structural Change, and Labour Markets in Emerging Economies**.

| Project | Relationship to Project 3 |
|---|---|
| [01 — China Shock in Emerging Markets](../01_china_shock_emerging_markets/) | Estimates aggregate import competition effects; Project 3 provides the district-level structural change complement |
| [02 — Exchange Rate Volatility and Export Margins](../02_exchange_rate_export_margins/) | Macro-level currency dynamics; Project 3 examines the micro-level occupational consequences |
| [04 — Central Bank Communications Scraper](../04_central_bank_scraper/) | Data infrastructure project; no direct analytical link |
| [05 — Monetary Policy Sentiment](../05_monetary_policy_sentiment/) | Text-as-data analysis at the macro level; thematic complement |
| [06 — Trade Exposure Maps](../06_trade_exposure_maps/) | Direct upstream input: provides the district trade exposure panel merged in Notebook 6; shares the Census 2011 geographic unit |

## References

- Autor, D. H., Levy, F., & Murnane, R. J. (2003). The Skill Content of Recent Technological Change: An Empirical Exploration. *Quarterly Journal of Economics*, 118(4), 1279–1333.
- Autor, D. H., Dorn, D., & Hanson, G. H. (2013). The China Syndrome: Local Labor Market Effects of Import Competition in the United States. *American Economic Review*, 103(6), 2121–2168.
- Goos, M., Manning, A., & Salomons, A. (2014). Explaining Job Polarization: Routine-Biased Technological Change and Offshoring. *American Economic Review*, 104(8), 2509–2526.
- Goldsmith-Pinkham, P., Sorkin, I., & Swift, H. (2020). Bartik Instruments: What, When, Why, and How. *American Economic Review*, 110(8), 2586–2624.
- Asher, S., Lunt, T., Matsuura, R., & Novosad, P. (2021). Development Research at High Geographic Resolution: An Analysis of Night-Lights, Firms, and Poverty in India Using the SHRUG Open Data Platform. *World Bank Economic Review*, 35(4), 845–871.
- National Statistical Office (2019 onwards). *Periodic Labour Force Survey — Annual Reports*. Ministry of Statistics and Programme Implementation, Government of India.

## License

This project is shared for academic and non-commercial use. The underlying PLFS microdata is publicly distributed by MOSPI under their data access agreement terms. District boundary data from DataMeet is licensed under CC BY 4.0. All analysis code is available under the MIT License.