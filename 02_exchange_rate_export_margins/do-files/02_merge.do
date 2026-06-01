* ============================================================
* Project 2 — Exchange Rate Volatility and Export Margins
* Do-file 02: Panel Construction and Variable Generation
* Author: Aadhitya
* Date: June 2026
* ============================================================

clear all
set more off
capture log close

cd "~/Desktop/UZH/Pre-Doc/Prep/BRICS-Trade-Labour-Portfolio/02_exchange_rate_export_margins"

log using "log/02_merge.log", replace text

* ── Section 1: Load Trade Panel and Standardise Types ────────

use "data/brics_trade_panel.dta", clear
recast int year
recast str4 exporter importer

* ── Section 2: Merge Volatility Panel ────────────────────────

merge 1:1 exporter importer year using "data/volatility_panel.dta", nogenerate
drop if missing(exporter) | missing(importer)
duplicates drop exporter importer year, force
di "After volatility merge: " _N " observations"
count if missing(volatility)

* ── Section 3: Merge GeoDist Gravity Controls ────────────────

rename exporter iso_o
rename importer iso_d
merge m:1 iso_o iso_d using "data/dist_cepii.dta", ///
    keepusing(distw comlang_off colony contig) ///
    keep(match master) nogenerate
rename iso_o exporter
rename iso_d importer
di "After GeoDist merge: " _N " observations"
count if missing(distw)

* ── Section 4: Generate Analysis Variables ───────────────────

* Dependent variables
gen ln_trade = ln(trade)
label variable ln_trade "Log bilateral trade value (USD thousands)"

gen trade_dummy = (trade > 0) if !missing(trade)
label variable trade_dummy "1 if positive bilateral trade flow"

* Log distance (for log-OLS specification only)
gen ln_distw = ln(distw)
label variable ln_distw "Log population-weighted bilateral distance (km)"

* Fixed effect identifiers
egen pair_id       = group(exporter importer)
egen exporter_year = group(exporter year)
egen importer_year = group(importer year)
label variable pair_id       "Unique numeric ID for exporter-importer pair"
label variable exporter_year "Exporter × year FE identifier"
label variable importer_year "Importer × year FE identifier"

* Russia post-sanctions sensitivity indicator
gen russia_post22 = (exporter == "RUS" & year >= 2022)
label variable russia_post22 "1 for RUS exporter observations, 2022 onwards"

* ── Section 5: Data Quality Checks ──────────────────────────

di "──────────────────────────────────────"
di "DATA QUALITY REPORT"
di "──────────────────────────────────────"
di "Total observations:              " _N
count if trade > 0
di "Observations — positive trade:   " r(N)
count if trade == 0 | missing(trade)
di "Observations — zero/missing trade: " r(N)
count if missing(volatility)
di "Observations — missing volatility: " r(N)
count if missing(distw)
di "Observations — missing distw:    " r(N)
count if russia_post22 == 1
di "Russia post-2022 observations:   " r(N)
di "──────────────────────────────────────"

tabulate exporter
tabulate year

* ── Save ─────────────────────────────────────────────────────

save "data/master_panel.dta", replace
di "Master panel saved."
di "Final observations: " _N

log close
