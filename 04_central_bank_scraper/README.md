# Central-bank communications corpus

This project collects English-language central-bank communications for Project 5's dictionary sentiment and topic analysis. The final saved corpus is **302 communications from four BRICS central banks**, not 302 comparable formal MPC statements. Brazil is absent from this collection.

## Sources and coverage

| Bank | Documents | Saved coverage | Extraction |
|---|---:|---|---|
| PBOC | 131 | 10 September 1996–27 October 2025 | BIS CBSPEECHES bulk CSV; speeches and broader central-bank communications |
| RBI | 63 | 5 April 2016–6 February 2026 | Six unique HTML records plus 57 manually downloaded historical PDFs |
| SARB | 57 | 2006–January 2026 | Selenium-rendered MPC pages; BeautifulSoup text extraction |
| CBR | 51 | 26 October 2018–13 February 2026 | HTTP extraction of key-rate press releases |

Counts were checked against `data/brics_mpc_statements_v2.csv`; dates against Project 5's cleaned CSV. SARB has 46 year-only dates assigned January placeholders in Project 5 (`date_approximate=True`); even month-level dates do not establish an exact meeting day. Coverage is uneven and is not a complete census of each bank's communications.

Sources are the [RBI policy archive](https://www.rbi.org.in/Scripts/Annualpolicy.aspx), [CBR calendar](https://www.cbr.ru/eng/dkp/cal_mp/), [SARB MPC archive](https://www.resbank.co.za/en/home/publications/statements/mpc-statements), and [BIS CBSPEECHES download](https://www.bis.org/cbspeeches/download.htm). PBOC selection matches `People's Bank of China|PBC|PBOC` in BIS descriptions. That text filter is not a formal MPC-document classifier; institutional attribution and document-type comparability require review. `pboc_scraper.py` and `bcb_scraper.py` are source notes, not working acquisition scripts.

## Extraction and assembly

1. `notebook.ipynb` calls the RBI, CBR and SARB scrapers and imports the manually obtained BIS download. RBI extracts `div.text1`; CBR extracts `div.landing-text`, title and date. SARB visits up to five index pages and joins `div.cmp-text` blocks using headless Chrome.
2. RBI archive requests historically returned the same six documents repeatedly: `rbi_statements.csv` contains 66 rows but only six unique URLs/texts. The original `brics_mpc_statements.csv` consequently contains 305 rows, including 60 repeated RBI rows. It is an intermediate snapshot, **not the analysis corpus**.
3. `scrapers/rbi_pdf_extractor.py` uses PyMuPDF page text extraction on the 57 committed PDFs in `data/rbi_pdfs/`. Dates come from filenames (`YYYY-MM-DD.pdf`); titles are generated from those dates and do not prove that all PDFs have an identical document type. No OCR is implemented. `url=local_pdf:<filename>` is a local provenance marker, not a public source URL; an original-download URL manifest is not available.
4. `build_corpus.py` combines saved bank extracts with `rbi_historical.csv`, keeps the first record for each `(central_bank, url)`, and checks required fields, blank text and duplicate text across URLs. This reconstructs all 302 saved records without changing document contents. It does not deduplicate solely by date, since distinct communications may share a date.
5. Project 5 performs boilerplate removal, date repair and language preprocessing. Project 4 retains the extracted text, including extraction artefacts.

### Failed-document handling

RBI and CBR omit requests that fail or yield no target content. SARB catches page errors and retains only extracted text longer than 100 characters. PDF extraction prints errors and skips empty/unreadable files. These failures appear in console output; the historical run has **no complete persistent failure manifest or retry audit**. Therefore 302 is the retained corpus size, not a successful-retrieval rate. For a new collection, retain execution logs and review failed/short documents before replacing the snapshot. PDF images require a separate OCR workflow; the code does not silently invent text for them.

## Schema

| Field | Meaning |
|---|---|
| `country` | Country label |
| `central_bank` | PBOC, RBI, SARB or CBR |
| `date` | Raw date string; precision and format vary by source |
| `title` | Extracted title or generated RBI PDF title |
| `text` | Extracted document text, before Project 5 preprocessing |
| `url` | Web source URL or `local_pdf:` reference |

The final raw CSV has six columns, no empty required fields, and no duplicate bank/URL or bank/text combinations in the checked snapshot. These checks do not establish that all website material was captured or that text extraction is perfect.

## Reproduction

From the repository root, install the Python dependencies described in [REPRODUCIBILITY.md](../REPRODUCIBILITY.md). Rebuild from committed extracts without network access:

```sh
python 04_central_bank_scraper/build_corpus.py --output /tmp/brics_mpc_rebuilt.csv
```

Omit `--output` only when intentionally replacing the canonical v2 CSV. Re-extract committed PDFs with `python 04_central_bank_scraper/scrapers/rbi_pdf_extractor.py`, then run the builder. A fresh live collection requires Chrome, Selenium, a compatible driver, requests/BeautifulSoup, and a BIS bulk download saved as `data/raw/speeches.zip`. Execute the notebook from the project directory. Live sites and BIS vintages can change counts and content; a fresh scrape is not expected to reproduce the historical snapshot exactly.

Offline assembly takes seconds for this corpus; live acquisition can take minutes or longer and may fail as websites change. No new live scrape or timing benchmark was performed for the corrections. Downstream order: Project 5 `notebook.ipynb` → `notebook_2_sentiment.ipynb` → `notebook_3_lda.ipynb`. FinBERT covers only a **40-document stratified sample**, while LM scoring covers all 302 documents.
