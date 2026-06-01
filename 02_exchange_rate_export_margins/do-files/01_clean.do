* ============================================================
* Project 2 — Exchange Rate Volatility and Export Margins
* Do-file 01: Data Cleaning and Variable Construction
* Author: Aadhitya
* Date: June 2026
* ============================================================

clear all
set more off
capture log close

cd "~/Desktop/UZH/Pre-Doc/Prep/BRICS-Trade-Labour-Portfolio/02_exchange_rate_export_margins"

log using "log/01_clean.log", replace text

** ── Section 1: BACI Trade Flows ─────────────────────────────

* Step 1: Save country code crosswalk as .dta for merging
import delimited "data/BACI_HS92_V202601/country_codes_V202601.csv", ///
    clear varnames(1) encoding(UTF-8)
keep country_code country_iso3
rename country_code baci_code
rename country_iso3 iso3
save "data/country_crosswalk.dta", replace

* Step 2: Loop over years, load BACI, filter, collapse, append
tempfile baci_master
save `baci_master', replace emptyok

local brics_codes "76 156 643 699 710"

forvalues yr = 2000/2022 {
    
    di "Processing year `yr'..."
    
    import delimited ///
        "data/BACI_HS92_V202601/BACI_HS92_Y`yr'_V202601.csv", ///
        clear varnames(1)
    
    keep if i == 76 | i == 156 | i == 643 | i == 699 | i == 710
    
    collapse (sum) v, by(t i j)
    
    * Merge exporter codes to ISO3
    rename i baci_code
    merge m:1 baci_code using "data/country_crosswalk.dta", ///
        keep(match) nogenerate
    rename iso3 exporter
    rename baci_code i
    
    * Merge importer codes to ISO3
    rename j baci_code
    merge m:1 baci_code using "data/country_crosswalk.dta", ///
        keep(match) nogenerate
    rename iso3 importer
    drop baci_code
    
    drop i 
    rename t year
    rename v trade
    
    append using `baci_master'
    save `baci_master', replace
}

* Step 3: Save final panel
use `baci_master', clear
save "data/brics_trade_panel.dta", replace

di "BACI section complete."
di "Observations in panel: " _N
		
	
* ── Section 2: Exchange Rate Volatility ─────────────────────

* Step 1: Load IFS, keep monthly period-average domestic currency per USD only
import delimited "data/ifs_exchange_rates.csv", ///
    clear varnames(1) encoding(UTF-8)
keep if frequencyid == "M" & indicatorid == "XDC_USD" ///
    & type_of_transformationid == "PA_RT"
drop frequencyid indicatorid type_of_transformationid

* Step 2: Parse time_period into year and month integers
gen year  = real(substr(time_period, 1, 4))
gen month = real(substr(time_period, 7, 2))
drop time_period
drop if missing(year) | missing(month)

* Step 3: Keep only countries appearing in BACI trade panel
preserve
use "data/brics_trade_panel.dta", clear
keep importer
duplicates drop
rename importer countryid
tempfile partner_ids
save `partner_ids'
restore

preserve
use "data/brics_trade_panel.dta", clear
keep exporter
duplicates drop
rename exporter countryid
append using `partner_ids'
duplicates drop
tempfile all_countries
save `all_countries'
restore

merge m:1 countryid using `all_countries', keep(match) nogenerate

* Step 4: Rename and save country-level monthly rates
rename countryid iso3
rename obs_value e_usd
keep iso3 year month e_usd
sort iso3 year month
save "data/ifs_monthly_rates.dta", replace

* Step 5: Construct bilateral cross-rates
use "data/ifs_monthly_rates.dta", clear
keep if inlist(iso3, "BRA", "CHN", "IND", "RUS", "ZAF")
rename iso3 exporter
rename e_usd e_exporter
tempfile brics_rates
save `brics_rates'

use "data/ifs_monthly_rates.dta", clear
rename iso3 importer
rename e_usd e_importer
joinby year month using `brics_rates'
drop if exporter == importer

* Step 6: Log exchange rate and monthly changes
gen ln_e = ln(e_exporter) - ln(e_importer)
egen pair_id = group(exporter importer)
gen ym = ym(year, month)
format ym %tm
xtset pair_id ym
gen delta_ln_e = d.ln_e

* Step 7: Rolling 12-month standard deviation
rangestat (sd) delta_ln_e, interval(ym -11 0) by(pair_id)
rename delta_ln_e_sd volatility

* Step 8: Collapse to annual — keep December observation
keep if month == 12
keep exporter importer year volatility
drop if missing(volatility)

save "data/volatility_panel.dta", replace
di "Exchange rate section complete."
di "Observations in volatility panel: " _N

log close
