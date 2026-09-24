# Statistical reporting practices, *p* value reproducibility, and data sharing in 350 sport and exercise science studies

Research compendium for a retrospective audit of statistical reporting practices in 350 original
research articles sampled from 10 quartile 1 applied sport and exercise science journals.

The study has three pre-registered aims — describing reporting practices for the main effect of
interest, assessing *p*-value reproducibility where sufficient information was reported, and
quantifying raw-data sharing — plus an exploratory, non-pre-registered whole-corpus analysis using
the *Metacheck* R package.

Preregistration, and supplementary materials: <https://osf.io/3juyq/>

# Reproducing the manuscript

Render `manuscript/manuscript.qmd` with Quarto. All reported numbers are computed from the files in
this repository at render time; none are typed into the prose by hand.

Requires R with: `metacheck` (>= 0.1.0), `dplyr`, `readxl`, `here`, `tidyr`, `statcheck`, `stringr`,
`tibble`, `readr`, `knitr`, `flextable`, `scales`, and `irr` (used by the interrater agreement
script).

# Repository Structure

```
reporting_practices/
├── manuscript/
│   ├── manuscript.qmd        # Quarto source containing all code to reproduce the manuscript
│   ├── references.bib        # Bibliography
│   └── elsevier-harvard.csl  # Citation style (Elsevier Harvard)
│
├── data/
│   ├── CODEBOOK.md           # Data dictionary for all coded datasets
│   ├── DATA reporting_practices - Coded Data.csv
│   ├── DATA reporting_practices - ANOVA rep.csv
│   └── DATA reporting_practices - ttest rep.csv
│
├── agreement/
│   ├── 01_intercoder_agreement_function.R   # Fleiss'/Cohen's kappa functions
│   ├── disagreements2.xlsx                  # Data extracted independently by two raters
│   └── disagreements3.xlsx                  # Data extracted independently by three raters
│
├── files/                    # Cached Metacheck outputs for the automated analysis (Part 2)
│   ├── cached_corpus_info.csv      # Number of articles successfully converted to XML
│   ├── cached_stat_p_exact.csv     # All p-values detected in results sections
│   ├── cached_stat_effect_size.csv # Effect-size reporting and coherence verdicts per test
│   ├── cached_stat_check.csv       # Recomputed p-values for all t- and F-tests
│   └── cached_ci_mentions.csv      # Papers mentioning "95% CI" / "95% confidence interval"
│
└── LICENSE
```

## A note on the cached Metacheck outputs

The automated analysis was run over GROBID-converted XML of the 348 articles that could be
converted. That intermediate object is **not** included here, because it contains the full parsed
text of copyrighted articles and cannot be redistributed. The `files/cached_*.csv` tables are the
module outputs derived from it, reduced to the columns needed to reproduce every reported number,
with all verbatim article text removed.

The code that produced them from the XML is retained in `manuscript.qmd` as a non-evaluated chunk,
so the full pipeline remains documented. Re-running it requires the source PDFs, which are likewise
not redistributable.

# License

Code (Quarto source and R scripts): MIT — see `LICENSE`.

Coded datasets (`data/`) and cached analysis outputs (`files/`): CC BY 4.0.

The audited source articles are copyright their respective publishers and are not redistributed.
