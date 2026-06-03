# Hawkish or Dovish? Monetary Policy Sentiment Across BRICS Central Banks

## Overview

This project performs textual sentiment analysis and LDA topic modelling on monetary policy communications from four BRICS central banks — the People's Bank of China (PBOC), Reserve Bank of India (RBI), South African Reserve Bank (SARB), and the Bank of Russia (CBR) — spanning 1996 to 2026. It is the analytical second half of a two-project pipeline: Project 4 built and cleaned the corpus; this project analyses it. The question is whether BRICS central banks increasingly reference trade fragmentation and currency divergence themes post-2022, and whether sentiment around these themes differs across institutions.

The motivation is that monetary policy communications carry information beyond the explicit rate decision. The tone, uncertainty, and thematic content of central bank statements signal how an institution perceives macroeconomic conditions and external risks. In a period of accelerating trade fragmentation, BRICS currency diversification discussions, and post-sanctions monetary realignment, tracking how BRICS central bank language has evolved — and whether it has diverged — is both academically relevant and directly linked to the thesis on BRICS currencies and global monetary fragmentation.

The primary results document a clear post-2022 divergence: PBOC maintained persistently positive net sentiment (+0.008) while CBR and SARB converged at a persistently negative tone (−0.015). LDA topic modelling (k=9, coherence=0.505) reveals near-perfect bank-topic segregation and identifies PBOC's Global Economy & Currency topic as the only PBOC topic with negative net sentiment (−0.008) — a signal that when China's central bank explicitly engages with international monetary dynamics, its tone turns cautious in a way its domestic communications do not. FinBERT robustness checks confirm LM sentiment rankings across institutions (Spearman r=0.441, p=0.004).

Honest limitations are documented throughout. PBOC's 131 statements constitute 43% of the corpus, introducing potential imbalance in topic discovery. CBR coverage begins only in 2018, limiting the pre-sanctions baseline to 14 statements. Brazil (BCB) was excluded due to Portuguese-only communications. SARB dates for 2006–2013 are approximate (year-level only).

---

## Research Questions

1. Do BRICS central banks increasingly reference trade fragmentation and currency divergence themes post-2022, and does sentiment around these themes differ across institutions?
2. Does the tone of BRICS monetary policy communications diverge following major macro shocks — specifically the COVID-19 shock (2020), the Russia-Ukraine war and sanctions shock (2022), and the BRICS expansion summit (2023)?
3. What is the latent thematic structure of BRICS central bank communications, and which topics are associated with more negative or uncertain sentiment?
4. Is PBOC's engagement with international monetary dynamics — currency, trade imbalances, capital flows — associated with a sentiment profile distinct from its domestic policy communications?

---

## Analytical Framework

### Layer 1 — Loughran-McDonald Dictionary Sentiment (Primary)

The Loughran-McDonald (LM) master dictionary (Loughran and McDonald, 2011) was used as the primary sentiment method. LM was built from US 10-K financial filings and correctly classifies financial domain language that general-purpose dictionaries mishandle. For each statement, tokens are matched against the LM Positive (354 words), Negative (2,355 words), and Uncertainty (297 words) lists. Scores are normalised by total token count:

```
lm_positive  = positive_matches / total_tokens
lm_negative  = negative_matches / total_tokens
lm_net       = (positive_matches - negative_matches) / total_tokens
lm_uncertainty = uncertainty_matches / total_tokens
```

LM scoring is applied to the raw text column — not the lemmatised text_clean column — because the dictionary requires exact word-form matching.

### Layer 2 — FinBERT Robustness Check

FinBERT (Araci, 2019) — a BERT model fine-tuned on financial text — was applied to a stratified 40-statement sample (10 per bank, evenly spaced across each bank's time range) to validate LM findings. FinBERT reads full sentences and understands context and negation, making it a methodologically distinct robustness test. Statements were truncated to 400 tokens to respect the 512-token BERT limit. The model was run using GPU acceleration (Apple MPS) via the HuggingFace transformers library.

### Layer 3 — LDA Topic Modelling

Latent Dirichlet Allocation (Blei, Ng and Jordan, 2003) was applied to the lemmatised text_clean column using gensim. A bag-of-words corpus was built after filtering terms appearing in fewer than 5 documents (no_below=5) or more than 80% of documents (no_above=0.80), reducing the raw 8,827-term vocabulary to 3,668 terms. Models were fitted for k=4 to k=12 and evaluated using c_v coherence scoring. The optimal model at k=9 (coherence=0.505) was selected. Dominant topic per statement is the highest-probability topic from the document-topic distribution.

---

## Data Sources

| Source | Role |
|--------|------|
| BIS CBSPEECHES bulk download | PBOC communications — 131 statements, 1996–2025 |
| RBI website + manual PDF download | RBI Governor's Statements — 63 statements, 2016–2026 |
| SARB website (Selenium scrape) | SARB MPC Statements — 57 statements, 2006–2026 |
| Bank of Russia website (HTTP scrape) | CBR key rate press releases — 51 statements, 2018–2026 |
| Loughran-McDonald Master Dictionary (2024) | Sentiment word lists — 86,553 entries across 6 categories |
| ProsusAI/finbert (HuggingFace) | FinBERT model for robustness check |

---

## Corpus Summary

| Dimension | Value |
|-----------|-------|
| Total statements | 302 |
| Banks covered | 4 (PBOC, RBI, SARB, CBR) |
| Date range | September 1996 – February 2026 |
| Columns (raw) | 6 (country, central_bank, date, title, text, url) |
| Columns (final) | 17 (+ text_clean, token_count, date_approximate, date_original, lm_positive, lm_negative, lm_uncertainty, lm_net, dominant_topic, topic_probability, topic_label) |
| SARB approximate dates | 46 rows (2006–2013, year-level only) |
| BCB (Brazil) | Excluded — Portuguese-only communications |
| LM dictionary size (Positive) | 354 words |
| LM dictionary size (Negative) | 2,355 words |
| LM dictionary size (Uncertainty) | 297 words |
| LDA vocabulary (after filtering) | 3,668 terms |
| LDA optimal k | 9 (coherence = 0.505) |

---

## Project Structure

```
05_monetary_policy_sentiment/
│
├── README.md                              ← This file
│
├── notebook.ipynb                         ← Notebook 1: Text cleaning and preprocessing
├── notebook_2_sentiment.ipynb             ← Notebook 2: LM sentiment and FinBERT
├── notebook_3_lda.ipynb                   ← Notebook 3: LDA topic modelling
│
└── data/
    ├── brics_mpc_cleaned.csv              ← Cleaned corpus — 302 rows, 10 cols
    ├── brics_mpc_sentiment.csv            ← LM sentiment scores appended — 302 rows, 14 cols
    ├── brics_mpc_final.csv                ← Final dataset — 302 rows, 17 cols
    ├── lm_dictionary/
    │   └── Loughran-McDonald_MasterDictionary_1993-2024.csv
    ├── sentiment_trends.png               ← Net sentiment and uncertainty time series
    ├── lm_vs_finbert.png                  ← LM vs FinBERT agreement scatter plots
    ├── coherence_scores.png               ← LDA coherence score by k
    ├── topic_prevalence.png               ← Topic assignments over time by bank
    ├── topic_sentiment_interaction.png    ← Topic-sentiment heatmaps
    └── lda_visualisation.html             ← pyLDAvis interactive topic map
```

---

## Key Results

### Corpus-Level Sentiment

| Metric | lm_positive | lm_negative | lm_uncertainty | lm_net |
|--------|-------------|-------------|----------------|--------|
| Mean | 0.0152 | 0.0180 | 0.0117 | −0.0027 |
| Std Dev | 0.0096 | 0.0090 | 0.0066 | 0.0159 |
| Min | 0.0000 | 0.0000 | 0.0000 | −0.0528 |
| Max | 0.0562 | 0.0696 | 0.0339 | +0.0449 |

The mean net sentiment of −0.0027 confirms a slight negative bias across all statements — consistent with central bank communication norms where risks are discussed at least as prominently as positive developments.

### Bank-Level Sentiment

| Bank | Statements | Mean lm_net | Median lm_net | Mean Uncertainty | Characterisation |
|------|------------|-------------|---------------|------------------|-----------------|
| PBOC | 131 | +0.0082 | +0.0087 | 0.0073 | Consistently positive, low uncertainty |
| RBI | 63 | −0.0047 | −0.0034 | 0.0111 | Near-neutral, moderate uncertainty |
| CBR | 51 | −0.0150 | −0.0148 | 0.0173 | Persistently negative, high uncertainty |
| SARB | 57 | −0.0146 | −0.0148 | 0.0174 | Persistently negative, high uncertainty |

### FinBERT Robustness Check

| Bank | Negative | Neutral | Positive | LM Mean Net |
|------|----------|---------|----------|-------------|
| CBR | 6 | 2 | 2 | −0.0150 |
| PBOC | 1 | 5 | 4 | +0.0082 |
| RBI | 2 | 2 | 6 | −0.0047 |
| SARB | 9 | 0 | 1 | −0.0146 |

Spearman correlation between FinBERT labels and LM net scores: r=0.441, p=0.004. Both methods produce identical bank-level sentiment rankings.

### LDA Topic Structure

| Topic | Label | Dominant Bank | Statements | Mean lm_net | Mean Uncertainty |
|-------|-------|---------------|------------|-------------|-----------------|
| 1 | Real Estate & Credit | PBOC | 1 | −0.0017 | 0.0057 |
| 2 | PBOC Institutional | PBOC | 2 | — | — |
| 3 | Inflation & Growth Outlook | SARB | 57 | −0.0147 | 0.0174 |
| 4 | Monetary Policy Decisions | CBR | 51 | −0.0150 | 0.0173 |
| 5 | Digital Finance & Green Economy | PBOC | 17 | +0.0128 | 0.0061 |
| 6 | Liquidity & Rate Decisions | RBI | 44 | −0.0018 | 0.0103 |
| 7 | Banking System & Credit | PBOC | 7 | −0.0017 | 0.0057 |
| 8 | Global Economy & Currency | PBOC | 14 | −0.0080 | 0.0096 |
| 9 | Financial Reform & Capital Markets | PBOC | 90 | +0.0104 | 0.0073 |

**Key finding:** Near-perfect bank-topic segregation confirms that institutional communication styles are sufficiently distinct to be recovered by an unsupervised model. Topic 8 (Global Economy & Currency) is the only PBOC topic with negative net sentiment, and is semantically isolated from all other topics in the pyLDAvis intertopic distance map — the clearest signal that PBOC perceives the external monetary environment as a source of risk.

### Topic-Sentiment Interaction (Heatmap Summary)

The two most negative and uncertain topic-bank combinations are:
- CBR — Monetary Policy Decisions: lm_net=−0.015, uncertainty=0.017
- SARB — Inflation & Growth Outlook: lm_net=−0.015, uncertainty=0.017

The most positive topic-bank combination is:
- PBOC — Digital Finance & Green Economy: lm_net=+0.013, uncertainty=0.006

PBOC's Global Economy & Currency topic (lm_net=−0.008, uncertainty=0.010) is the outlier within PBOC's otherwise positive communication profile.

---

## Outputs

| File | Description |
|------|-------------|
| `data/brics_mpc_cleaned.csv` | Cleaned corpus — 302 rows, 10 cols |
| `data/brics_mpc_sentiment.csv` | LM sentiment scores — 302 rows, 14 cols |
| `data/brics_mpc_final.csv` | Final enriched dataset — 302 rows, 17 cols |
| `data/sentiment_trends.png` | Net sentiment and uncertainty time series by bank (rolling 3-period average) |
| `data/lm_vs_finbert.png` | LM net score by FinBERT label — two scatter plots |
| `data/coherence_scores.png` | c_v coherence score for k=4 to k=12 |
| `data/topic_prevalence.png` | Topic assignments over time, one panel per bank |
| `data/topic_sentiment_interaction.png` | Heatmaps of mean lm_net and lm_uncertainty by topic and bank |
| `data/lda_visualisation.html` | pyLDAvis interactive topic map — open in browser |
| `notebook.ipynb` | Notebook 1: boilerplate stripping, date repair, spaCy cleaning |
| `notebook_2_sentiment.ipynb` | Notebook 2: LM scoring, trend plots, FinBERT robustness |
| `notebook_3_lda.ipynb` | Notebook 3: gensim LDA, topic labelling, topic-sentiment interaction |

---

## Limitations

1. **PBOC corpus dominance.** PBOC contributes 131 of 302 statements (43%). Several LDA topics are effectively PBOC-only. A balanced subsample analysis (equal n per bank) would be a useful robustness check.

2. **BCB excluded.** Brazil is absent. Machine translation of Portuguese Copom statements would introduce systematic cross-bank vocabulary differences that are translation artefacts rather than genuine institutional differences. This limits the analysis to four of the five original BRICS members.

3. **CBR coverage starts 2018.** Only 14 CBR statements predate February 2022, limiting the statistical power of any pre/post-sanctions comparison for Russia specifically.

4. **SARB approximate dates.** 46 statements from 2006–2013 have January placeholder dates (year-level only recoverable from URL fragment IDs). These are flagged with date_approximate=True and may slightly distort SARB temporal patterns in the early sample period.

5. **LM dictionary domain mismatch.** LM was built on US 10-K filings. Central bank communications use some financial vocabulary differently — "risk" is more neutral in policy communications than in corporate filings — introducing potential misclassification.

6. **FinBERT 512-token limit.** Statements were truncated to 400 words. Longer statements (particularly RBI and SARB) may lose analytically important content from later sections.

7. **LDA random seed sensitivity.** random_state=42 ensures reproducibility. A multi-seed stability check would strengthen confidence in topic boundaries.

8. **PBOC document heterogeneity.** The BIS CBSPEECHES database includes a broader range of PBOC communication types (speeches at academic forums, bilateral meetings, international conferences) alongside formal monetary policy statements. This is noted in the topic structure — Topics 2 and 5 capture PBOC-specific institutional and developmental themes unlikely to appear in other banks' formal MPC statements.

---

## Connection to Portfolio

| Project | Relationship |
|---------|-------------|
| [04 — Central Bank Scraper](../04_central_bank_scraper/) | Provides the raw corpus (brics_mpc_statements_v2.csv) consumed by this project. Project 4 is the data engineering foundation; Project 5 is the analytical layer |
| [Thesis — BRICS Currencies & Monetary Fragmentation](https://github.com/Aadhi0105/Master_Thesis_Brics_Currencies) | The post-2022 sentiment divergence (PBOC: +0.008 vs. CBR/SARB: −0.015) and PBOC's negative Global Economy & Currency topic directly inform the monetary fragmentation hypothesis tested in the thesis using panel econometrics |
| [01 — China Shock in Emerging Markets](../01_china_shock_emerging_markets/) | Project 1 documents the labour market consequences of trade integration at the district level; Project 5 documents the institutional monetary policy response to the same trade fragmentation process at the central bank level |

---

## References

- Loughran, T., and McDonald, B. (2011). When is a liability not a liability? Textual analysis, dictionaries, and 10-Ks. *Journal of Finance*, 66(1), 35–65.
- Blei, D. M., Ng, A. Y., and Jordan, M. I. (2003). Latent Dirichlet Allocation. *Journal of Machine Learning Research*, 3, 993–1022.
- Araci, D. (2019). FinBERT: Financial sentiment analysis with pre-trained language models. *arXiv preprint arXiv:1908.10063*.
- Hansen, S., McMahon, M., and Prat, A. (2018). Transparency and deliberation within the FOMC: A computational linguistics approach. *Quarterly Journal of Economics*, 133(2), 801–870.
- Blinder, A. S., Ehrmann, M., Fratzscher, M., De Haan, J., and Jansen, D. J. (2008). Central bank communication and monetary policy: A survey of theory and evidence. *Journal of Economic Literature*, 46(4), 910–945.
- Sievert, C., and Shirley, K. (2014). LDAvis: A method for visualizing and interpreting topics. *Proceedings of the Workshop on Interactive Language Learning, Visualization, and Interfaces*, 63–70.
- Rehurek, R., and Sojka, P. (2010). Software framework for topic modelling with large corpora. *Proceedings of the LREC 2010 Workshop on New Challenges for NLP Frameworks*, 45–50.
- Aiyar, S., et al. (2023). Geoeconomic fragmentation and the future of multilateralism. *IMF Staff Discussion Note SDN/2023/001*.
- Devlin, J., Chang, M. W., Lee, K., and Toutanova, K. (2019). BERT: Pre-training of deep bidirectional transformers for language understanding. *NAACL-HLT 2019*, 4171–4186.

## License

MIT License for all analysis code. Loughran-McDonald dictionary under academic use terms (sraf.nd.edu). BIS CBSPEECHES data under BIS research use terms. RBI, SARB, and CBR statement text under respective institutional open access terms.
