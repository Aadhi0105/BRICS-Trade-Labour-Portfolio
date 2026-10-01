# Correction record

## Changes

- Standardised Stata spelling in maintained text and code.
- Removed unsupported KP/Stock–Yogo diagnostics, the model-F strength check and automatic LATE claims. Distinguished HC3 first-stage errors from district-clustered IV errors and documented shared-shock inference limits.
- Kept missing trade missing; separated missing/zero/positive diagnostic counts (including Stata's numeric-missing comparison trap). Disabled the unsupported participation LPM. Qualified Russia sensitivity and corrected interaction-versus-total-slope language.
- Reframed the PLFS binary as NCO-6/9 versus other occupations, preserving legacy identifiers and estimates. Documented why the retained fields do not support an immediate harmonised NIC replacement.
- Wrote Project 4 documentation from the actual extracts and scraper code. Added an offline builder that deduplicates six repeated RBI HTML documents and combines 57 historical PDF extracts; documented date precision, heterogeneous PBOC material and incomplete failure/source manifests.
- Replaced personal absolute paths with repository-relative paths; Python uses pathlib for root/data resolution where applicable. Documented working directories for R and Stata.
- Made FinBERT's 40-document scope and 400-word/512-token truncation explicit; softened topic/sentiment interpretation and removed identical-ranking claims.
- Corrected non-farm employment-to-population terminology in maintained prose and plot-generating source, retaining legacy data fields. Clarified units per 1,000 residents and manufacturing's distinct denominator.
- Traced Project 1's baseline to raw SHRUG location data, not the Project 6 GeoPackage. Corrected 29 saved share columns versus 28 used by the final instrument, including first-match geographic-key limitations.
- Reworked the root overview and added source/dependency/run-order/runtime guidance. Removed tracked `.DS_Store` and stale Project 3 rendered HTML; corrected two pre-existing prose cells misclassified as Python code. Cleared stale output cells in Projects 1, 4 and 6.

## Validation

- Parsed every Python code cell in all notebooks (170 cells) and all Python scripts successfully.
- Extracted and parsed all six Rmd code streams with R; parsed the helper R scripts.
- Rebuilt the corpus offline and compared all six fields in all 302 records against the committed v2 snapshot, exactly equal after sorting by bank/URL. Counts: PBOC 131, RBI 63, SARB 57, CBR 51; no duplicate bank/URL or bank/text records.
- Verified saved Stata table estimates and standard errors were unchanged; only unsupported explanatory footnotes/titles changed.
- Existing CSV/RDS/GeoPackage empirical data remain unchanged. Checked whitespace with `git diff --check`.

## Remaining work requiring data review or recomputation

1. Implement and validate shift-share-appropriate inference and weak-identification diagnostics. Existing HC3/district-clustered results do not substitute for these.
2. Audit raw urban/rural PLFS industry fields and classification/codebooks before defining agriculture with NIC; then rebuild Project 3 panels and all Project 1 outcomes/estimates. Existing NCO category strings are compatibility identifiers only.
3. Audit BACI missingness and construct a validated full pair-year universe before estimating an extensive margin. No missing observation was converted to zero.
4. Review SHRUG missing-industry assumptions and duplicated/split district-key allocation (especially Delhi) before changing the instrument. No new allocation or estimate was invented.
5. Full raw-data reproduction is blocked by uncommitted BACI, IFS/GeoDist, PLFS, SHRUG and concordance inputs. Exact historical environment versions, complete outcomes-export provenance and runtime benchmarks are incomplete. No full Stata/R/Python estimation rerun was claimed.
6. Project 1’s geographic PNG still has a historical occupation label. Regeneration requires the uncommitted SHRUG location-name and district-key files; no replacement geographic join was invented. The remaining maintained figures and Project 2/4 reports were refreshed in the presentation pass below.
7. Live scraping would require a new retrieval/failure manifest and verification of original PDF URLs and approximate SARB dates; this pass reproduces the saved corpus only. FinBERT full-corpus scoring, balanced-corpus checks and multi-seed LDA validation remain unperformed.

## Presentation cleanup

- Refreshed Project 1’s descriptive plots and coefficient chart and restored its first-stage chart with coefficient, HC3 SE, t-statistic and partial R². Fixed state-and-year FE labels and distinguished the unweighted visual line from the weighted first-stage estimate.
- Re-exported Project 6 maps and four publication PDFs using the existing saved panels, with employment-to-population units and state-based corridor labels.
- Refreshed Project 5’s descriptive plots with corpus/date caveats. Replaced the FinBERT scatter export with the already-published 40-document label counts because document-level predictions were not saved; no model was rescored. The notebook can produce a separate scatter after rerunning the original sample.
- Updated all three Project 2 Word reports and the Project 4 Word/PDF report to match the corrected definitions, with readable headings, tables and pagination.
- Replayed only the existing Project 1 specifications for chart reproduction and checked the first-stage diagnostics and three IV coefficients/SEs against their published rounded values. All empirical CSV/RDS/DTA/GeoPackage/GeoJSON snapshots and saved Stata result tables remain unchanged. No new specifications, NLP fits or raw-data rebuilds were introduced.
