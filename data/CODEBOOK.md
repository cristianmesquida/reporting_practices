# Codebook

Data dictionary for the three coded datasets used in `manuscript/manuscript.qmd`. These datasets underlie the manually-coded (pre-registered) results reported in Results Part 1 of the manuscript. Preregistration: <https://osf.io/3juyq/>. Coding procedures and the coding form are described in the manuscript Methods section and in `@tbl-checklist`.

## General notes

- Format: UTF-8 CSV, one header row.
- Unit of observation: `DATA reporting_practices - Coded Data.csv` has one row per coded study (*N* = 350). `DATA reporting_practices - ANOVA rep.csv` and `DATA reporting_practices - ttest rep.csv` have one row per statistical test that was checked for *p*-value reproducibility with *statcheck* (subsets of the 350 studies).
- `ID` is the study identifier and is consistent across all three files, allowing them to be joined.
- Blank cells indicate the item was not applicable or not recorded (e.g. an effect-size column left blank because no effect size of that type was reported).
- Yes/No fields are free-text and **not consistently capitalised** across rows (e.g. `"Yes"` and `"yes"` both occur). Treat these fields case-insensitively (e.g. `tolower(trimws(x))`) before analysis.
- `DATA reporting_practices - Coded Data.csv` contains a trailing `Colour Legend` column (and one blank column) that are not data fields — they are leftover from a legend box that sat beside the coding sheet in the original Excel file, explaining the meaning of coloured cell highlighting (`Orange` = incomplete information in paper, `Yellow` = estimated/incomplete information, `Green` = all relevant information contained for reproducibility check). Only 3 of 350 rows carry a value in these columns; they can be dropped for analysis.
- All three files were exported from the original Excel workbooks (`.xlsx`) to `.csv` for long-term, non-proprietary archival, in line with FAIR data principles.

---

## 1. `DATA reporting_practices - Coded Data.csv` (*N* = 350 rows, one per study)

Primary manually-coded dataset. Underlies Results Part 1, Aims 1 and 3, and `@tbl-summary-apa`.

| Variable | Type | Description |
|---|---|---|
| `ID` | integer | Unique study identifier. |
| `study_title` | text | Title of the coded article. |
| `hypothesis_statement` | text | Primary hypothesis statement copy-pasted from the article (coding item 1). |
| `effect_of_interest` | categorical | Type of key statistical result selected (coding item 2). Values: `main effect`, `interaction effect`, `difference of means`, `unclear`. |
| `statistical_result` | text | Statistical result text corresponding to the effect of interest, copy-pasted from the article (coding item 3). |
| `df_t` | numeric | Degrees of freedom for the *t*-test, if `effect_of_interest` = `difference of means` (coding item 5a). |
| `t_statistic` | numeric | Reported *t* statistic (coding item 5b). |
| `p_value_t` | text | Reported *p*-value associated with the *t*-test (coding item 5c). |
| `es` | categorical | Whether an effect size was reported for the *t*-test, and its type. Values: `standardised`, `unstandardised`, `both types are reported`, `not reported`. |
| `ci_es` | categorical | Whether a confidence interval was reported around the *t*-test effect size. Values: `yes, only for the unstandardised`, `not reported`, or blank. |
| `df1_f` | numeric | Numerator degrees of freedom for the *F*-test, if `effect_of_interest` = `main effect`/`interaction effect` (coding item 4a). |
| `df2_f` | numeric | Denominator degrees of freedom for the *F*-test (coding item 4a). |
| `f_statistic` | numeric | Reported *F* statistic (coding item 4b). |
| `p_value_f` | text | Reported *p*-value associated with the *F*-test (coding item 4c). |
| `es_f` | categorical | Whether an effect size was reported for the *F*-test, and its type. Values: `standardised`, `unstandardised`, `both types are reported`, `not reported`. |
| `ci_f` | categorical | Whether a confidence interval was reported around the *F*-test effect size. Values: `yes`, `yes, only for unstandadrdised` [sic], `no`, or blank. |
| `preregistration` | categorical | Whether the study was preregistered (coding item 8). Values: `yes`, `no`, `clinical trial` (preregistered as a clinical trial registration). |
| `raw_data` | categorical (`yes`/`no`) | Whether the study provides a link to a public data repository (coding item 9). |
| `access_raw_data` | categorical (`yes`/blank) | Whether the data-repository link is functional and the data are accessible (coding item 10). Only populated when `raw_data` = `yes`. |
| `Any_stats?` | categorical (`Yes`/`no`) | Whether any inferential statistics were reported for the effect of interest. |
| `p-values?` | categorical (`Yes`/`No`) | Whether a *p*-value was reported for the effect of interest. |
| `test_stats?` | categorical (`Yes`/`No`) | Whether the test statistic (*F* or *t*) was reported. |
| `Df?` | categorical (`Yes`/`No`) | Whether degrees of freedom were reported. |
| `ES?` | categorical | Summary effect-size reporting category used in `@tbl-summary-apa`. Values: `standardised`, `unstandardised`, `Both`, `No`. |
| `CI_ES?` | categorical | Summary effect-size CI reporting category used in `@tbl-summary-apa`. Values: `Yes`, `yes, only for the unstandardised`, `No`. |
| `Colour Legend` *(and one trailing unnamed column)* | — | Not a data field — see General notes above. |

---

## 2. `DATA reporting_practices - ANOVA rep.csv` (*n* = 119 rows, one per checkable *F*-test)

The subset of *F*-tests (main effects and interaction effects) for which degrees of freedom could be established (either as originally reported, or inferred by the research team) and a *statcheck* reproducibility report was generated. Underlies Results Part 1, Aim 2 (*F*-test reproducibility) and `@tbl-frep`.

| Variable | Type | Description |
|---|---|---|
| `ID` | integer | Study identifier, matches `Coded Data.csv`. |
| `study_title` | text | Article title. |
| `hypothesis_statement` | text | Primary hypothesis statement. |
| `effect_of_interest` | categorical | `main effect` or `interaction effect`. |
| `statistical_result` | text | Statistical result text as extracted from the article. |
| `df1_f` | numeric | Numerator degrees of freedom (as reported, or inferred where missing). |
| `df2_f` | numeric | Denominator degrees of freedom (as reported, or inferred where missing). |
| `f_statistc` [sic] | numeric | Reported *F* statistic. |
| `p_value` | text | Reported *p*-value, original format (e.g. `p = .13`, `P < 0.05`). |
| `p_number` | numeric | `p_value` parsed to a plain number for the *statcheck* input. |
| `reported_p` | text | *p*-value as formatted for *statcheck* (e.g. `<0.05`). |
| `computed_p` | numeric | *p*-value recomputed by *statcheck* from `f_statistc`, `df1_f`, and `df2_f`. |
| `Agreement?` | categorical | Reproducibility classification comparing `reported_p` to `computed_p`. Values: `Reproduced`, `Not reproducible but compatible`, `Incorrectly rounded`, `Incompatible` (decision error). See manuscript Methods, "1.1. Statistical analysis", for the operational definition of each category. |
| `APA Text statement (original)` | text | Statistical result reformatted into standardised APA notation, used as the literal input string to the `statcheck` R package. |

---

## 3. `DATA reporting_practices - ttest rep.csv` (*n* = 13 rows: 12 *t*-tests + 1 Wilcoxon signed-rank test)

The subset of difference-of-means tests for which degrees of freedom could be established and a *statcheck* reproducibility report was generated, plus one additional study whose main effect was a Wilcoxon signed-rank test (identifiable via `"Within or Between"` = `"Wilcoxon Sgned ranks - Within"` [sic]). Underlies Results Part 1, Aim 2 (*t*-test reproducibility).

| Variable | Type | Description |
|---|---|---|
| `ID` | integer | Study identifier, matches `Coded Data.csv`. |
| `study_title` | text | Article title. |
| `hypothesis_statement` | text | Primary hypothesis statement. |
| `effect_of_interest` | categorical | `difference of means` for all rows in this file. |
| `statistical_result` | text | Statistical result text as extracted from the article. |
| `Within or Between` | categorical | Design of the comparison: `Within`, `Between`, or (for the one non-parametric test) `Wilcoxon Sgned ranks - Within`. |
| `df_t` | numeric | Degrees of freedom (as reported, or inferred where missing). |
| `t_statistic` | numeric/text | Reported *t* statistic (`W = …` for the Wilcoxon row). |
| `p_value` | text | Reported *p*-value, original format. |
| `es` | categorical | Effect-size reporting for this test. Values as in `Coded Data.csv`'s `es` column. |
| `ci_es` | categorical | Effect-size CI reporting for this test. |
| `raw_data` | categorical (`yes`/`no`) | Whether the study shares raw data. |
| `access_raw_data` | categorical | Whether the shared data are accessible. |
| `df`, `t`, `p` | numeric/text | Working/duplicate copies of `df_t`, `t_statistic`, `p_value` used while preparing the *statcheck* input string; not an independent data source. |
| `df2` | numeric | Degrees of freedom as passed to *statcheck*. |
| `test_value` | numeric/text | Test statistic as passed to *statcheck* (equivalent to `t_statistic`). |
| `reported_p` | text | *p*-value as formatted for *statcheck*. |
| `computed_p` | numeric | *p*-value recomputed by *statcheck* (or, for the Wilcoxon row, computed separately from the Wilcoxon statistic and noted as `"P recomputed"` in `reported_p`). |
| `Agreement?` | categorical | Reproducibility classification comparing `reported_p` to `computed_p`. Same categories as in `ANOVA rep.csv`. |
| `APA Text statement (original)` | text | Statistical result reformatted into standardised APA notation, used as input to the `statcheck` R package (blank for the Wilcoxon row, which was checked manually). |

---

## Related files

- `agreement/01_intercoder_agreement_function.R` — functions used to compute interrater agreement (Fleiss'/Cohen's kappa) from `agreement/disagreements2.xlsx` and `agreement/disagreements3.xlsx`.
- `manuscript/manuscript.qmd` — analysis script and manuscript source; reads all three files above via the `here` package.
