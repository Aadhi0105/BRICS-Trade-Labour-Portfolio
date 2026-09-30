* ============================================================
* Project 2 — Exchange Rate Volatility and Export Margins
* Do-file 03: Regression Analysis and Results
* Author: Aadhitya
* Date: June 2026
* ============================================================

clear all
set more off
capture log close

* Run from the repository root or this project directory.
capture confirm file "do-files/01_clean.do"
if _rc cd "02_exchange_rate_export_margins"
capture mkdir "log"
capture mkdir "output"

log using "log/03_analysis.log", replace text

use "data/master_panel.dta", clear

* ── Section 1: Primary Specifications ───────────────────────

* Column 1: PPML — full sample, three-way FE
* Primary estimator. Handles zeros. Heteroskedasticity-consistent.
* β₁ interpreted as semi-elasticity of trade levels w.r.t. volatility.
ppmlhdfe trade volatility, ///
    absorb(pair_id exporter_year importer_year) vce(robust)
estimates store ppml_main

* Column 2: Log-OLS — positive trade flows only, three-way FE
* Robustness check. Sample restricted to ln_trade non-missing.
* Coefficient not directly comparable to PPML due to sample selection.
reghdfe ln_trade volatility, ///
    absorb(pair_id exporter_year importer_year) vce(robust)
estimates store ols_main

* Note observation counts for table footnote
count if !missing(volatility) & !missing(trade)
local n_ppml = r(N)
count if !missing(volatility) & !missing(ln_trade)
local n_ols = r(N)
local n_zeros_dropped = `n_ppml' - `n_ols'
di "Zeros dropped by log-OLS: " `n_zeros_dropped'

* Extensive-margin estimation is not supported: absent BACI observations
* have not been validated as genuine zeros in a complete pair-year universe.
* Do not run an LPM on trade_dummy or recode missing trade to zero.

* ── Section 2: BRICS Heterogeneity ──────────────────────────

* Interact volatility with BRICS exporter dummies
* ZAF is the omitted base category
* Coefficient on volatility = ZAF effect
* Coefficients on vol_xxx = deviation from ZAF for each country

gen vol_bra = volatility * (exporter == "BRA")
gen vol_chn = volatility * (exporter == "CHN")
gen vol_ind = volatility * (exporter == "IND")
gen vol_rus = volatility * (exporter == "RUS")

ppmlhdfe trade vol_bra vol_chn vol_ind vol_rus volatility, ///
    absorb(pair_id exporter_year importer_year) vce(robust)
estimates store ppml_het

* ── Section 3: Russia Sensitivity Check ─────────────────────

* Repeat primary specifications excluding Russia in 2022 and later years (annual data)
* russia_post22 == 1 flags 197 observations where rouble volatility
* may reflect capital controls and sanctions-related trade redirection.
* This sensitivity check does not identify either mechanism.

ppmlhdfe trade volatility if russia_post22 == 0, ///
    absorb(pair_id exporter_year importer_year) vce(robust)
estimates store ppml_norus

reghdfe ln_trade volatility if russia_post22 == 0, ///
    absorb(pair_id exporter_year importer_year) vce(robust)
estimates store ols_norus

* ── Section 4: Export Results Table ─────────────────────────

* Primary results table — Columns 1 and 2
esttab ppml_main ols_main using "output/results_table.csv", ///
    replace csv ///
    keep(volatility) ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    scalars("N Observations" "r2_p Pseudo R2" "r2 R-squared") ///
    title("Table 1: Exchange Rate Volatility and BRICS Export Margins") ///
    mtitles("(1) PPML" "(2) Log-OLS") ///
    addnotes("Three-way fixed effects: pair, exporter×year, importer×year." ///
             "Robust standard errors in parentheses." ///
             "* p<0.10, ** p<0.05, *** p<0.01." ///
             "Column (2) restricted to positive trade flows (ln_trade non-missing)." ///
             "Extensive margin not estimated: missing trade cannot be classified as zero." ///
             "Results describe observed trade flows only.")

* Sensitivity check table
esttab ppml_norus ols_norus using "output/sensitivity_table.csv", ///
    replace csv ///
    keep(volatility) ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    scalars("N Observations" "r2_p Pseudo R2" "r2 R-squared") ///
    title("Table 2: Sensitivity — Excluding Russia in 2022 and Later Years") ///
    mtitles("(1) PPML" "(2) Log-OLS") ///
    addnotes("Sample excludes Russia exporter observations from 2022 onwards (N=197 dropped)." ///
             "Three-way fixed effects: pair, exporter×year, importer×year." ///
             "Robust standard errors in parentheses.")

* Heterogeneity table
esttab ppml_het using "output/heterogeneity_table.csv", ///
    replace csv ///
    keep(vol_bra vol_chn vol_ind vol_rus volatility) ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Table 3: BRICS Heterogeneity — Country-Specific Volatility Effects") ///
    mtitles("PPML") ///
    addnotes("Base category: ZAF (South Africa)." ///
             "Coefficient on volatility = ZAF effect." ///
             "Total country effect = volatility + vol_xxx." ///
             "Three-way fixed effects: pair, exporter×year, importer×year.")

di "Analysis complete. Results exported to output/."

log close
