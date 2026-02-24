#
#
#
#
#
#
#
#
library(metacheck) 
library(dplyr) 
library(readxl)
library(here)
library(rlang)
library(purrr)
library(tidyr)
library(statcheck)
library(stringr)
library(tibble)
#
#
#
#
#
#
# List files in "pdf_files"
pdf_files <- list.files(
  path = here("files", "pdf_files"),
  pattern = "\\.pdf$", 
  full.names = TRUE
  )

# Convert PDFs to XML format
pdf2grobid(
  pdf_files, 
  save_path = here("files", "xml_files"), 
  grobid_url = "https://thesanogoeffect-grobid-papercheck.hf.space"
)
```
#
#
#
#
# List files in "xml_files"
path_files <- list.files(
  path = here("files", "xml_files"), 
  pattern = "\\.xml$", 
  full.names = TRUE
)

# Read in XML files
articles <- read(path_files)
#
#
#
#
saveRDS(articles, "articles_xml.Rds")
#
#
#
#
articles_files <- readRDS("articles_xml.Rds")
#
#
#
#
#
#
#
#
#
exact <- module_run(
  articles_files, 
  "stat_p_exact"
  )

exact$table |> 
  count(text)
#
#
#
#
#
#
#
exact$table |> 
  filter(p_comp %in% c(">", "≥")) |> 
  count()
#
#
#
#
#
#
#
exact$table |> 
  filter(p_comp %in% c("<", "≤")) |> 
  count()
#
#
#
#
#
#
#
#
#
#
#
es <- module_run(
  articles_files, 
  "stat_effect_size"
)

es$summary_text
#
#
#
#
#
head(es$table, 5)
es$table |> 
  mutate(as.factor(test)) |> 
  filter(test == "F-test") |> 
  count(is.na(es)) |> # returns cases where es == NA (not reported)
  mutate(prop = n / sum(n)) 
#
#
#
#
#
es$table |> 
  mutate(as.factor(test)) |> 
  filter(test == "t-test") |> 
  count(is.na(es)) |> # returns cases where es == NA (not reported)
  mutate(prop = n / sum(n)) 
#
#
#
#
#
  search_text(
    articles_files,
    pattern = "(?i)mean\\s*±\\s*(sd|s\\.d\\.)", 
    section = "results",
    return = "sentence"
    )
#
#
#
#
#
  search_text(
    articles_files,
    pattern = "(?i)95%\\s*(CI|confidence\\s*interval)",
    section = "results",
    return = "sentence"
    )
#
#
#
#
#
statcheck_p_values <- module_run(
  articles_files, 
  "stat_check"
  )

statcheck_p_values$table
#
#
#
#
#
#
#
statcheck_p_values$table |> 
  mutate(as.factor(error)) |> 
  count(error) |>         
  mutate(prevalence = round(n / nrow(all_ps) * 100, 1)) 
#
#
#
#
#
statcheck_p_values$table |> 
  mutate(across(ends_with("error"), as.factor)) |> 
  count(error, decision_error) |>         
  group_by(error) |> 
  mutate(prevalence = round(n / sum(n) * 100, 1)) |> 
  ungroup()
#
#
#
#
#
statcheck_p_values$table |> 
  mutate(flagged_p_values = round(computed_p / reported_p, 1)) |> 
           filter(flagged_p_values >= 2)
#
#
#
#
#
statcheck_p_values$table |> 
  filter(decision_error, round(computed_p / reported_p, 1) >= 2)
#
#
#
#
#
#
Coded_papers <- read_csv("DATA reporting_practices - Coded Data.csv", col_types = cols())  # returns a tibble
ANOVA_rep <- read_csv("DATA reporting_practices - ANOVA rep.csv", col_types = cols())  # returns a tibble
T_test_rep <- read_csv("DATA reporting_practices - ttest rep.csv", col_types = cols())  # returns a tibble

### t - tests 

colname <- "APA Text statement (original)"
txts <- coalesce(as.character(T_test_rep[[colname]]), "")

# detect candidate rows that contain stat-like patterns (t(), F(), r(), χ2/chi, or p)
stat_like <- str_detect(
  txts,
  regex("\\b(t|f|r|z|χ|chi)\\s*\\([^)]*\\)\\s*=|p\\s*[=<>]", ignore_case = TRUE)
)

candidate_idx <- which(stat_like & nzchar(str_trim(txts)))

# return empty tibble if nothing to check
if (length(candidate_idx) == 0L) {
  t_test_statcheck <- tibble()
} else {
  # normalize spacing around p-operators (helps statcheck parsing)
  texts_to_check <- txts[candidate_idx] |>
    str_replace_all(regex("p\\s*([<>=])\\s*(\\.?\\d+)"), "p \\1 \\2") |>
    str_squish()

  # run statcheck on the candidate strings
  res <- statcheck::statcheck(texts = texts_to_check)

  # convert to tibble and map back to original rows
  if (is.null(res) || nrow(as.data.frame(res)) == 0L) {
    t_test_statcheck <- tibble()
  } else {
    t_test_statcheck <- as_tibble(res) |> mutate(source_row = candidate_idx)
  }
}

t_test_statcheck

### F tests
colname <- "APA Text statement (original)"
txts <- coalesce(as.character(ANOVA_rep[[colname]]), "")

# detect candidate rows (F(), t(), r(), χ2/chi, or p)
stat_like2 <- str_detect(
  txts,
  regex("\\b(t|f|r|z|χ|chi)\\s*\\([^)]*\\)\\s*=|p\\s*[=<>]", ignore_case = TRUE)
)

candidate_idx2 <- which(stat_like2 & nzchar(str_trim(txts)))

if (length(candidate_idx2) == 0L) {
  F_test_statcheck <- tibble()
} else {
  texts_to_check <- txts[candidate_idx2] |>
    str_replace_all(regex("p\\s*([<>=])\\s*(\\.?\\d+)"), "p \\1 \\2") |>
    str_squish()

  res_f <- statcheck::statcheck(texts = texts_to_check)

  if (is.null(res_f) || nrow(as.data.frame(res_f)) == 0L) {
    F_test_statcheck <- tibble()
  } else {
    F_test_statcheck <- as_tibble(res_f) |> mutate(source_row = candidate_idx2)
  }
}

F_test_statcheck

# summarise prevalence of errors for t-tests and f-test statcheck

summarize_flags <- function(df) {
  list(
    error = df %>% count(error, .drop = FALSE, sort = TRUE),
    decision_error = df %>% count(decision_error, .drop = FALSE, sort = TRUE)
  )
}

res_t <- if (exists("t_test_statcheck")) summarize_flags(t_test_statcheck) else list(error = tibble(), decision_error = tibble())
res_F <- if (exists("F_test_statcheck")) summarize_flags(F_test_statcheck) else list(error = tibble(), decision_error = tibble())

list(t_test = res_t, F_test = res_F)
#
#
#
