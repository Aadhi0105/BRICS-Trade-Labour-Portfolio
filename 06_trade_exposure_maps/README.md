# Mapping Trade Exposure and Structural Change: A District-Level Analysis of India

## Overview

This project maps the spatial distribution of structural economic change across Indian districts over two decades (1990–2013), using data from India's Economic and Population Censuses. It examines how the shift from agricultural to non-farm employment — a defining feature of economic development — varies geographically, and whether districts with greater proximity to trade infrastructure experienced faster or qualitatively different structural transitions.

The analysis connects to the Autor, Dorn, and Hanson (2013) framework on the local labour market effects of trade exposure, adapted to an emerging economy context where the relevant channel is not import competition displacing manufacturing, but rather trade-linked industrialisation reshaping the employment landscape from the outside in. This project complements [Project 1](../01_china_shock_emerging_markets/) of this portfolio, which replicates the China shock methodology in an emerging market setting, by providing the spatial and visual dimension that regression tables alone cannot convey.

## Research Question

How does structural change — measured as the shift in employment shares across agriculture, manufacturing, and services — vary across Indian districts between 1990 and 2013, and is this variation spatially correlated with proximity to trade infrastructure (major ports, Special Economic Zones, and industrial corridors)?

## Motivation

India's economic liberalisation after 1991 and WTO accession in 1995 reshaped the spatial distribution of economic activity. Districts near major ports and export processing zones experienced rapid industrialisation, while interior districts remained agrarian or transitioned directly into low-productivity services. Understanding this geography matters for two reasons.

First, it provides the spatial complement to aggregate trade statistics. National-level data on manufacturing output or export growth masks enormous district-level heterogeneity. A district in coastal Gujarat and a district in central Madhya Pradesh may have experienced the same decade of liberalisation, but with radically different labour market consequences.

Second, the spatial distribution of structural change has direct policy implications for industrial strategy, infrastructure investment, and fiscal federalism — questions at the intersection of development economics and public finance that motivate the broader research agenda of this portfolio.

## Data Sources

### Socioeconomic Data

**SHRUG — Socioeconomic High-resolution Rural-Urban Geographic Dataset for India (v2.1)**
- Source: [Development Data Lab](https://www.devdatalab.org/shrug)
- Coverage: ~500,000 villages and ~8,000 towns, 1990–2013
- Key variables used:
  - Total non-farm employment (Economic Census rounds: 1990, 1998, 2005, 2013)
  - Manufacturing employment
  - Total population (Population Census rounds: 1991, 2001, 2011)
- Geographic identifiers: SHRUG IDs (`shrid`) linked to Census 2011 district codes
- License: Creative Commons BY-NC-SA 4.0
- Citation: Asher, S., Lunt, T., Matsuura, R., & Novosad, P. (2021). Development Research at High Geographic Resolution: An Analysis of Night-Lights, Firms, and Poverty in India Using the SHRUG Open Data Platform. *World Bank Economic Review*, 35(4), 845–871.

### Geospatial Data

**District Boundary Shapefiles**
- Source: [DataMeet Community Maps](https://github.com/datameet/maps) / [India Geodata](https://github.com/yashveeeeeeer/india-geodata)
- Format: GeoJSON / Shapefile (WGS84, EPSG:4326)
- Coverage: 640 districts as per Census 2011 delineation
- License: Creative Commons BY 4.0

### Trade Infrastructure

**Major Port Locations**
- Source: Indian Ports Association / Ministry of Ports, Shipping and Waterways
- Coverage: 12 major ports and selected minor ports with significant cargo throughput
- Format: Point coordinates (latitude, longitude)

**Special Economic Zones (SEZs)**
- Source: Ministry of Commerce and Industry, SEZ Division
- Coverage: Operational SEZs with notification dates
- Format: Point coordinates geocoded from official gazette notifications

**Industrial Corridors**
- Source: Department for Promotion of Industry and Internal Trade (DPIIT)
- Coverage: Delhi–Mumbai Industrial Corridor (DMIC), Chennai–Bengaluru Industrial Corridor (CBIC), and other notified corridors
- Format: Corridor alignment polylines

## Methodology

### Structural Change Indicators

For each district *d* in period *t*, the following indicators are computed by aggregating SHRUG village/town-level data to the district level using Census 2011 district boundaries:

1. **Non-farm employment share**: Total non-farm employment from the Economic Census divided by total population from the nearest Population Census round. This captures the extent of the district's transition away from agriculture.

2. **Manufacturing employment share**: Manufacturing employment as a share of total non-farm employment. This distinguishes districts that industrialised (manufacturing-led structural change) from those that moved directly into services.

3. **Structural change rate**: The change in non-farm employment share between consecutive Economic Census rounds (Δ1990–1998, Δ1998–2005, Δ2005–2013), capturing the pace of transformation over time.

### Trade Exposure Proxies

In the absence of district-level industry-specific trade flow data, trade exposure is approximated using spatial proximity measures:

1. **Distance to nearest major port**: Geodesic distance (km) from each district centroid to the nearest major port. Captures access to international trade infrastructure.

2. **Distance to nearest SEZ**: Geodesic distance to the nearest operational Special Economic Zone, conditional on SEZ notification date (i.e., a district's SEZ proximity is computed only for periods after the relevant SEZ became operational).

3. **Industrial corridor alignment**: Binary indicator for whether a district's boundary intersects with or lies within a defined buffer zone of a notified industrial corridor.

These are proxy measures, not causal instruments. The analysis is descriptive and spatial, not causal — it documents correlations between trade infrastructure proximity and the pattern of structural change, without claiming to identify causal effects.

### Geospatial Methods

- All spatial operations use `geopandas` with coordinate reference system EPSG:4326 (WGS84) for storage and EPSG:7755 (India-specific projected CRS) for distance calculations
- Choropleth maps use equal-interval and quantile classification schemes; the choice is justified per variable based on the distribution of values
- Bivariate maps overlay trade exposure proxies with structural change outcomes
- Temporal comparison panels display the same geographic area across Economic Census rounds to show spatial evolution

## Project Structure

```
06_trade_exposure_maps/
│
├── README.md
│
├── data/
│   ├── raw/                          # Original downloaded files
│   │   ├── shrug/                    # SHRUG Economic Census and Population Census modules
│   │   ├── shapefiles/               # District boundary files (GeoJSON/Shapefile)
│   │   └── infrastructure/           # Port, SEZ, and corridor coordinates
│   │
│   └── processed/                    # Cleaned and merged analysis-ready files
│       ├── districts_structural_change.gpkg   # District-level panel with geometry
│       └── trade_exposure_proxies.csv         # Distance measures per district
│
├── notebooks/
│   ├── 01_data_acquisition.ipynb     # Download, load, and explore raw data
│   ├── 02_structural_change.ipynb    # Compute indicators and produce choropleth maps
│   ├── 03_trade_exposure.ipynb       # Construct proximity measures and spatial overlays
│   └── 04_publication_maps.ipynb     # Final polished figures for portfolio display
│
├── figures/                          # Exported map images (PNG/PDF)
│
└── requirements.txt                  # Python dependencies
```

## Notebooks

### Notebook 1 — Data Acquisition and Exploration

Downloads and loads the district-level shapefiles and SHRUG data modules. Introduces `geopandas` fundamentals: loading shapefiles, inspecting coordinate reference systems, and producing basic choropleth plots. Merges SHRUG socioeconomic data to district geometries using Census 2011 district codes. Outputs an exploration of variable coverage and data quality across Economic Census rounds.

### Notebook 2 — Structural Change Maps

Computes the three structural change indicators defined above for each district across the four Economic Census rounds. Produces choropleth maps showing the spatial distribution of non-farm employment share, manufacturing share, and structural change rates. Includes temporal comparison panels (1990 vs. 1998 vs. 2005 vs. 2013) to visualise how the geography of industrialisation evolved over two decades. Identifies spatial clusters and patterns: coastal vs. interior, urban peripheries vs. rural hinterland, northern plains vs. southern industrial belt.

### Notebook 3 — Trade Exposure Proxies and Spatial Analysis

Constructs the three trade exposure proxy measures (port distance, SEZ distance, corridor alignment) and merges them with the structural change panel. Produces bivariate visualisations showing the relationship between trade infrastructure proximity and the pace of structural change. Includes side-by-side and overlay maps comparing high-exposure vs. low-exposure districts. Documents spatial correlations without overclaiming causality.

### Notebook 4 — Publication-Quality Visualisation

Produces final, polished cartographic outputs suitable for inclusion in a working paper or research presentation. Applies consistent colour schemes, proper legends, scale bars, north arrows, and source annotations. Exports figures in both PNG (for GitHub display) and PDF (for print/presentation) formats. Generates multi-panel composite figures that tell a coherent spatial narrative.

## Key Analytical Periods

| Period | Economic Context | Expected Spatial Pattern |
|---|---|---|
| 1990–1998 | Post-liberalisation, early reforms | Coastal and metro-adjacent districts begin industrialising |
| 1998–2005 | IT boom, SEZ policy expansion | Southern and western corridors accelerate; interior lags |
| 2005–2013 | Pre- and post-Global Financial Crisis | Broad-based but uneven; manufacturing plateaus in some early movers |

## Limitations

1. **Trade exposure is proxied, not measured directly.** District-level industry-specific trade flows are not available in SHRUG. The proximity-based measures capture geographic access to trade infrastructure but do not measure actual trade volumes or import competition at the district level. This project is explicitly descriptive, not causal.

2. **Economic Census coverage varies across rounds.** Match rates between the Economic Census and the SHRUG are lower for earlier rounds (particularly 1990), and agricultural firms are excluded for consistency across rounds. Aggregate district-level counts may therefore undercount total employment, though cross-sectional comparisons within rounds remain valid.

3. **District boundaries changed between Census rounds.** The analysis uses Census 2011 district boundaries throughout. SHRUG's time-invariant identifiers (`shrid`) handle most boundary changes at the village/town level, but aggregation to 2011 district boundaries for earlier rounds involves imputation for split or merged districts.

4. **SHRUG does not currently provide industry-specific employment at the district level.** A time-invariant industry classification is under development by the SHRUG team. When available, it would enable construction of a proper Bartik-style trade exposure measure, which represents a natural extension of this analysis.

## Dependencies

```
geopandas>=0.13.0
pandas>=1.5.0
numpy>=1.23.0
matplotlib>=3.6.0
shapely>=2.0.0
pyproj>=3.4.0
contextily>=1.3.0        # Basemap tiles for cartographic context
mapclassify>=2.5.0       # Classification schemes for choropleth maps
```

## Connection to Portfolio

This project is the sixth and final component of a research portfolio on **Trade, Structural Change, and Labour Markets in Emerging Economies**. It provides the spatial and visual layer that complements the econometric analyses in Projects 1–3 and the text-as-data pipeline in Projects 4–5.

| Project | Link | Relationship to Project 6 |
|---|---|---|
| 01 — China Shock in Emerging Markets | [→ Link](../01_china_shock_emerging_markets/) | Project 6 maps the geography that Project 1 estimates econometrically |
| 02 — Exchange Rate and Export Margins | [→ Link](../02_exchange_rate_export_margins/) | Macro-level trade shocks whose district-level incidence Project 6 visualises |
| 03 — Labour Polarisation Across Indian Districts | [→ Link](../03_labour_polarisation_india/) | Uses the same geographic unit (Indian districts) and a complementary outcome variable |
| 04 — Central Bank Communications Scraper | [→ Link](../04_central_bank_scraper/) | Data infrastructure for the NLP pipeline; no direct spatial link |
| 05 — Monetary Policy Sentiment | [→ Link](../05_monetary_policy_sentiment/) | Text-as-data analysis of policy communication; thematic complement |

## References

- Asher, S., Lunt, T., Matsuura, R., & Novosad, P. (2021). Development Research at High Geographic Resolution: An Analysis of Night-Lights, Firms, and Poverty in India Using the SHRUG Open Data Platform. *World Bank Economic Review*, 35(4), 845–871.
- Autor, D. H., Dorn, D., & Hanson, G. H. (2013). The China Syndrome: Local Labor Market Effects of Import Competition in the United States. *American Economic Review*, 103(6), 2121–2168.
- Autor, D. H., Dorn, D., & Hanson, G. H. (2016). The China Shock: Learning from Labor-Market Adjustment to Large Changes in Trade. *Annual Review of Economics*, 8, 205–240.
- Hasan, R., Mitra, D., Ranjan, P., & Ahsan, R. N. (2012). Trade Liberalization and Unemployment: Theory and Evidence from India. *Journal of Development Economics*, 97(2), 269–280.
- Topalova, P. (2010). Factor Immobility and Regional Impacts of Trade Liberalization: Evidence on Poverty from India. *American Economic Journal: Applied Economics*, 2(4), 1–41.

## License

This project is shared for academic and non-commercial use. The underlying SHRUG data is licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/). District boundary data from DataMeet is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).