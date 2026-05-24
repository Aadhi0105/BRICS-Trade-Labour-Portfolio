# Labour Market Polarisation Across Indian Districts: A Distributional Analysis

## Overview

This project examines whether Indian labour markets exhibit polarisation — the hollowing out of middle-skill employment relative to high- and low-skill occupations — across districts over the period 2017–18 to 2023–24. Using seven rounds of the Periodic Labour Force Survey (PLFS), India's national annual employment survey, the analysis constructs a district-level panel of employment shares and wage distributions by skill group, decomposed by gender and by urban-rural sector. A final regression stage connects district-level polarisation patterns to the trade exposure proxies developed in Project 6 of this portfolio, testing whether districts more integrated into global trade networks experienced structurally different labour market transitions.

The analytical framework draws directly on the polarisation literature initiated by Autor, Levy, and Murnane (2003) and extended by Autor, Dorn, and Hanson (2013, 2016), adapted to an emerging economy setting where the drivers of skill-biased structural change include both trade integration and domestic economic transformation rather than import competition alone.

## Research Questions

1. Is there evidence of labour market polarisation — declining middle-skill employment shares — across Indian districts between 2017–18 and 2023–24?
2. Does polarisation differ by gender? Are women more or less exposed to middle-skill hollowing than men, given their occupational concentration across skill categories?
3. Are polarisation dynamics structurally different in urban versus rural areas, consistent with the distinction between routine-biased technological change (urban) and agricultural structural transformation (rural)?
4. Does district-level trade exposure, as proxied by spatial proximity to ports, Special Economic Zones, and industrial corridors, correlate with the intensity of polarisation?

## Motivation

The polarisation of labour markets — wage and employment growth at the top and bottom of the skill distribution at the expense of the middle — has been documented extensively for advanced economies. The mechanism, formalised in the routine-biased technological change (RBTC) hypothesis, holds that middle-skill occupations are disproportionately composed of codifiable routine tasks susceptible to automation and offshoring, while high-skill cognitive tasks and low-skill manual tasks are complementary to both technology and trade.

India provides an important and understudied test case for two reasons. First, India's occupational structure is mid-transition — a large agricultural base, a growing services sector, and a manufacturing sector that has not absorbed labour at the pace classical structural transformation models predict. This creates a different starting distribution of employment across skill groups than the US commuting zones studied by ADH, making it a meaningful emerging-market comparison. Second, trade liberalisation and global value chain integration have affected Indian districts very unevenly, generating cross-sectional variation in exposure that allows correlational analysis of trade and polarisation even in the absence of clean causal identification.

The period covered by the PLFS — 2017–18 to 2023–24 — is analytically rich despite its brevity. It spans the post-demonetisation adjustment, the introduction of GST, the COVID-19 labour market shock of 2020–21, and the subsequent uneven recovery. Each of these episodes may have had differential effects across the skill distribution, making the distributional rather than aggregate lens essential.

## Data Sources

### Primary Survey Data

**Periodic Labour Force Survey (PLFS), 2017–18 to 2023–24**
- Source: National Statistical Office (NSO), Ministry of Statistics and Programme Implementation (MOSPI), Government of India
- Access: [National Data Archive — microdata.gov.in](http://microdata.gov.in)
- Coverage: All states and union territories of India, rural and urban sectors
- Sample size: Approximately 100,000+ households per round, yielding 400,000–550,000 person-level observations annually
- Format: Unit-level microdata, distributed in Nesstar binary format (2017–18, 2020–21, 2021–22, 2022–23, 2023–24) and direct Stata format (2018–19, 2019–20)
- Key variables used: District code, sector (rural/urban), sex, age, general education level, usual principal activity status, occupation code (NCO 2015), industry code (NIC 2008), weekly earnings, survey multiplier (weight)

**File structure per round (four files):**

| File | Content | Key variables |
|---|---|---|
| Urban person (`perv1` / `hh_per_fv`) | Person-level employment, urban sector | UPS status, NCO, NIC, wages, multiplier |
| Rural person (`perrv` / `hh_per_rv`) | Person-level employment, rural sector | CWS status, NCO, NIC, wages, multiplier |
| Urban household (`hhv1` / `hhfv`) | Household characteristics, urban | Household type, social group, expenditure |
| Rural household (`hhrv` / `hh_rv`) | Household characteristics, rural | Household type, social group, expenditure |

**Note on file naming:** MOSPI changed the naming convention for PLFS files between rounds. Internal variable names are consistent across all rounds; external file names are not. The cleaning notebook documents the mapping explicitly.

### Secondary Data — Trade Exposure

**District Trade Exposure Panel (from Project 6)**
- Source: Constructed in Project 6 of this portfolio using SHRUG v2.1 Economic Census data and spatial proximity to trade infrastructure
- File: `districts_full_panel.gpkg` (640 districts, 43 columns)
- Key variables merged: Distance to nearest major port, distance to nearest SEZ, industrial corridor alignment indicator, nonfarm employment share across Economic Census rounds
- Geographic unit: Census 2011 district boundaries (2011 shrid linkage)
- Citation: Asher, S., Lunt, T., Matsuura, R., & Novosad, P. (2021). *World Bank Economic Review*, 35(4), 845–871.

## Methodology

### Skill Classification

Workers are classified into three skill groups following the standard polarisation literature, using the 1-digit National Classification of Occupations 2015 (NCO 2015) code recorded in the PLFS:

| Skill group | NCO 2015 codes | Occupations |
|---|---|---|
| High-skill | 1, 2, 3 | Managers, professionals, technicians and associate professionals |
| Middle-skill | 4, 5, 7, 8 | Clerical support workers, service and sales workers, craft and trades workers, plant and machine operators |
| Low-skill | 6, 9 | Skilled agricultural workers, elementary occupations |

Armed forces (NCO 0) are excluded. This classification maps the routine task content logic of the RBTC hypothesis onto Indian occupation categories: middle-skill occupations are those most susceptible to displacement by automation and offshoring, while high-skill cognitive and low-skill manual occupations are expected to be more resilient.

### Activity Status and Employment Definition

The employed population is defined using the Usual Principal Activity Status (UPS) code, which captures the activity in which a person was engaged for the majority of the reference year. Workers with UPS codes 11–23 (self-employed, regular wage/salaried, and casual wage workers) constitute the employed sample. Workers with codes 31 and above (students, homemakers, unemployed) are excluded.

**An important structural constraint:** The urban person file contains both UPS occupation codes (Block 5 variables, whole-year reference) and Current Weekly Status (CWS) occupation codes (Block 6 variables, reference week). The rural person file contains CWS occupation codes only — Block 5 UPS variables are absent from the rural file structure across all seven rounds. Skill classification therefore uses UPS occupation for urban workers and CWS occupation for rural workers. This inconsistency is explicitly documented as a limitation and a robustness check using CWS for both urban and rural is reported.

### Employment Share Computation

For each district, round, skill group, sex, and sector, the weighted employment share is computed as:

> Share(skill, district, year, sex, sector) = Σ(multiplier × employed_in_skill_group) / Σ(multiplier × employed_total)

Survey weights (multipliers) are applied throughout using the `srvyr` package, which provides a tidyverse-compatible interface to the `survey` package. Unweighted estimates are never reported.

### Wage Analysis

Weekly earnings are analysed for wage and salaried employees and casual workers (UPS/CWS codes 21, 22, 23). Self-employed workers — a large share of the Indian workforce, particularly in agriculture and informal manufacturing — do not report earnings in the PLFS. All wage analysis is therefore conditional on wage employment status, and the scope restriction is stated explicitly. Wages are deflated to a common price level using the Consumer Price Index for Agricultural Labourers (rural) and the Consumer Price Index for Industrial Workers (urban).

### Distributional Analysis

The core polarisation test examines whether the middle-skill employment share declines over the 2017–18 to 2023–24 panel, both nationally (weighted) and across the district distribution. Analysis includes kernel density estimates of the district-level distribution of skill shares in each year, overlaid to visualise the shift in the distribution over time, and binned scatter plots relating initial skill composition to subsequent change.

### Regression — Trade Exposure and Polarisation

The regression stage merges the PLFS district polarisation panel with Project 6's trade exposure proxies and estimates:

> ΔShare_middle(district) = α + β₁ × log(port_distance) + β₂ × log(sez_distance) + β₃ × corridor_indicator + γ × X + ε

Where ΔShare_middle is the change in middle-skill employment share between the first and last available round, X is a vector of district controls (initial education level, urbanisation rate, initial skill composition), and standard errors are clustered at the state level. Regressions are estimated using `fixest` with state fixed effects. The proxy-based approach is explicitly described as correlational, not causal — the absence of a credible instrument for trade exposure at this geographic resolution precludes causal claims.

## Project Structure

```
03_labour_polarisation_india/
│
├── README.md
│
├── notebooks/
│   ├── 01_clean.Rmd          ← Data loading, harmonisation, skill classification
│   ├── 02_aggregate.Rmd      ← District-level aggregation, panel construction
│   ├── 03_polarisation.Rmd   ← Main distributional analysis
│   ├── 04_gender.Rmd         ← Gender decomposition
│   ├── 05_urban_rural.Rmd    ← Urban-rural split analysis
│   └── 06_regression.Rmd     ← Trade exposure regression, Project 6 merge
│
└── data/
    ├── PLFS_Data_2017-18/    ← Nesstar binary + DDI XML + converted output/
    ├── PLFS_Data_2018-19/    ← Direct Stata download
    ├── PLFS_Data_2019-20/    ← Direct Stata download
    ├── PLFS_Data_2020-21/    ← Nesstar binary + DDI XML + converted output/
    ├── PLFS_Data_2021-22/    ← Nesstar binary + DDI XML + converted output/
    ├── PLFS_Data_2022-23/    ← Nesstar binary + DDI XML + converted output/
    └── PLFS_Data_2023-24/    ← Nesstar binary + DDI XML + converted output/
```

## Notebooks

### Notebook 1 — Data Loading, Harmonisation, and Skill Classification

Loads all seven rounds of PLFS person-level data (urban and rural separately) using `haven::read_dta()`. Documents the variable count discrepancy across rounds — the urban person file ranges from 129 variables (2017–18, 2018–19) to 159 variables (2020–21) — and identifies the common variable set used for analysis. Standardises variable names across rounds, handles the rural/urban file naming inconsistency, applies the NCO 2015 skill classification, constructs the employment status filter, and produces a single harmonised person-level dataset per round. Outputs a diagnostic summary of sample sizes, skill group distributions, and missing value rates before and after cleaning.

### Notebook 2 — District-Level Aggregation and Panel Construction

Aggregates the cleaned person-level microdata to the district × year × skill group × sex × sector level using survey-weighted computations. Constructs the full panel: employment shares by skill group and wage distributions by skill group, separately for urban and rural, and separately for men and women. Addresses the district harmonisation problem — districts bifurcated between rounds are collapsed to their 2011 parent boundaries to maintain a time-consistent geographic unit. Documents cell size distributions and flags district × sex × skill cells below a minimum observation threshold. Outputs the analysis-ready panel dataset.

### Notebook 3 — Polarisation Analysis

Tests the core research question: is the middle-skill employment share declining across Indian districts? Produces kernel density estimates of the district-level skill share distributions in each year, national weighted time-series plots of skill group employment shares, and binned scatter plots relating initial middle-skill share to subsequent change. Examines whether the pandemic year (2020–21) represents a structural break or a transient shock by comparing pre- and post-COVID trends. Presents all results in publication-quality `ggplot2` figures with explicit uncertainty bands derived from the survey design.

### Notebook 4 — Gender Decomposition

Repeats the polarisation analysis separately for male and female workers. Documents female labour force participation rates by skill group across districts and rounds, examines whether polarisation — if present — operates symmetrically or asymmetrically by gender, and identifies whether any skill groups show diverging trends between men and women over the panel. Produces gender-disaggregated distributional plots and difference-in-differences style visualisations comparing male and female skill share trajectories.

### Notebook 5 — Urban-Rural Split

Separates the analysis by sector. Urban polarisation is interpreted through the lens of routine-biased technological change — middle-skill manufacturing and clerical employment displaced by technology or global value chain reorganisation. Rural polarisation is interpreted through the lens of agricultural structural transformation — workers exiting low-skill agricultural employment into nonfarm occupations, and the nature of those occupations (middle or high skill). Documents the methodological distinction between the UPS-based urban analysis and the CWS-based rural analysis and assesses whether the findings are robust to using CWS throughout.

### Notebook 6 — Trade Exposure and Polarisation

Merges the district polarisation panel from Notebook 2 with the trade exposure proxies from Project 6. Estimates OLS regressions of middle-skill employment share change on trade exposure proxies, with state fixed effects and district-level controls. Presents coefficient plots with clustered standard errors, reports partial correlation plots for each proxy, and discusses the direction and magnitude of associations without overclaiming causality. Explicitly connects the regression design to the ADH framework and explains why a true Bartik instrument cannot be constructed with available data.

## Analytical Periods and Economic Context

| Period | Economic context | Analytical relevance |
|---|---|---|
| 2017–18 to 2019–20 | Post-demonetisation (Nov 2016) adjustment; GST introduction (Jul 2017); moderate growth | Baseline structural adjustment; pre-shock skill distribution |
| 2020–21 | COVID-19 pandemic; national lockdown from March 2020; severe contraction | Acute labour market disruption; likely large middle-skill shock |
| 2021–22 to 2022–23 | Post-pandemic recovery; uneven across sectors and geographies | Differential recovery by skill group; test of structural vs transient effects |
| 2023–24 | Stabilisation; India among fastest-growing large economies | Whether polarisation trends re-emerge or reverse post-recovery |

## Limitations

1. **Short panel.** Seven annual rounds spanning 2017–18 to 2023–24 is a short window for identifying structural trends in labour markets. The findings document associations over this period and cannot speak to longer-run polarisation trajectories prior to 2017.

2. **Occupation measurement inconsistency across sectors.** The urban person file records occupation under the Usual Principal Activity Status (whole-year reference). The rural person file records occupation only under the Current Weekly Status (reference week). These are conceptually distinct measures. All rural skill classifications are therefore based on CWS, while urban classifications use UPS. This inconsistency is handled by reporting robustness checks using CWS for both sectors.

3. **Urban district-level sampling.** The PLFS urban component is designed to be representative at the state level, not the district level. District-level estimates for smaller urban areas have high sampling variance and are interpreted with caution. Results for large metropolitan districts are more reliable.

4. **Wage analysis covers wage employment only.** Weekly earnings are reported in the PLFS only for regular wage-salaried workers and casual wage workers. Self-employed workers — a large fraction of the Indian workforce, particularly in agriculture and informal trade — have no wage entry. All wage-based findings are conditional on wage employment status and cannot be extrapolated to the full working population.

5. **District code harmonisation.** India created new districts through bifurcation throughout the study period. Districts bifurcated after 2011 are collapsed to their 2011 parent boundaries for analytical consistency, following the approach in Project 6. The number of affected districts is documented in Notebook 1.

6. **Trade exposure is proxied, not measured.** The regression in Notebook 6 uses spatial proximity to trade infrastructure as a proxy for trade exposure, inherited from Project 6. This is not a causal instrument — it cannot separate the effect of trade integration from other characteristics of districts that are spatially correlated with trade infrastructure. Findings are described as correlational throughout.

7. **No Bartik-style instrument.** Constructing a true ADH-style shift-share instrument for India would require district-level industry employment from the Economic Census crossed with national industry-level import growth. While the data components exist in principle (SHRUG Economic Census and DGCI&S import data), the industry classification crosswalk between the two sources introduces substantial measurement error at the required level of disaggregation. This extension is flagged for future work.

## Dependencies

```r
haven       >= 2.5.0    # Reading Stata .dta files
tidyverse   >= 2.0.0    # Data manipulation and visualisation
labelled    >= 2.12.0   # Handling Stata variable and value labels
janitor     >= 2.2.0    # Data cleaning utilities
srvyr       >= 1.2.0    # Survey-weighted analysis (tidyverse interface)
fixest      >= 0.11.0   # Fast fixed effects regression
ggplot2     >= 3.4.0    # Publication-quality visualisation
patchwork   >= 1.1.0    # Combining multiple ggplot2 panels
scales      >= 1.2.0    # Axis and legend formatting
knitr       >= 1.42     # R Markdown rendering
rmarkdown   >= 2.21     # HTML output
```

## Connection to Portfolio

This project is the third component of a six-project research portfolio on **Trade, Structural Change, and Labour Markets in Emerging Economies**.

| Project | Relationship to Project 3 |
|---|---|
| [01 — China Shock in Emerging Markets](../01_china_shock_emerging_markets/) | Estimates the aggregate labour market effect of import competition using a replication of the ADH methodology; Project 3 provides the distributional and geographic complement |
| [02 — Exchange Rate Volatility and Export Margins](../02_exchange_rate_export_margins/) | Examines how currency volatility affects firm-level export behaviour; macro-level trade dynamics whose district-level labour market incidence Project 3 begins to trace |
| [04 — Central Bank Communications Scraper](../04_central_bank_scraper/) | Data infrastructure project; no direct analytical link |
| [05 — Monetary Policy Sentiment](../05_monetary_policy_sentiment/) | Text-as-data analysis of BRICS central bank communications; thematic complement at the macro level |
| [06 — Trade Exposure Maps](../06_trade_exposure_maps/) | Provides the district-level trade exposure panel (Project 6's `districts_full_panel.gpkg`) used directly in Notebook 6 of this project; shares the same geographic unit (Census 2011 districts) and the same ADH intellectual framework |

## References

- Autor, D. H., Levy, F., & Murnane, R. J. (2003). The Skill Content of Recent Technological Change: An Empirical Exploration. *Quarterly Journal of Economics*, 118(4), 1279–1333.
- Autor, D. H., Dorn, D., & Hanson, G. H. (2013). The China Syndrome: Local Labor Market Effects of Import Competition in the United States. *American Economic Review*, 103(6), 2121–2168.
- Autor, D. H., Dorn, D., & Hanson, G. H. (2016). The China Shock: Learning from Labor-Market Adjustment to Large Changes in Trade. *Annual Review of Economics*, 8, 205–240.
- Goos, M., Manning, A., & Salomons, A. (2014). Explaining Job Polarization: Routine-Biased Technological Change and Offshoring. *American Economic Review*, 104(8), 2509–2526.
- Goldsmith-Pinkham, P., Sorkin, I., & Swift, H. (2020). Bartik Instruments: What, When, Why, and How. *American Economic Review*, 110(8), 2586–2624.
- Asher, S., Lunt, T., Matsuura, R., & Novosad, P. (2021). Development Research at High Geographic Resolution: An Analysis of Night-Lights, Firms, and Poverty in India Using the SHRUG Open Data Platform. *World Bank Economic Review*, 35(4), 845–871.
- National Statistical Office (2019). *Periodic Labour Force Survey (PLFS) — Annual Report, July 2017 – June 2018*. Ministry of Statistics and Programme Implementation, Government of India.

## License

This project is shared for academic and non-commercial use. The underlying PLFS microdata is publicly distributed by MOSPI under the terms of their data access agreement, which requires that any publications using the data cite the source and submit an electronic copy to the National Data Archive. District boundary data from DataMeet is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). All analysis code in this repository is available under the MIT License.