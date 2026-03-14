# Banco Central do Brasil (BCB) — Data Source Note
#
# BCB data is sourced from the BIS CBSPEECHES database rather than direct scraping.
#
# Reason: The BCB API (dadosabertos.bcb.gov.br) provides COPOM statements only
# in Portuguese. The BCB English website is JavaScript-rendered with no accessible
# API endpoint returning English text.
#
# The BIS CBSPEECHES database aggregates central bank communications in English
# across all major central banks including BCB, making it a more reliable and
# academically defensible source for cross-country comparison.
#
# See: notebook.ipynb Section 4 (BCB) for download and processing details.
# Source: https://www.bis.org/cbspeeches/download.htm