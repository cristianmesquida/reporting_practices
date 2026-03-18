#
#
#
#
#
#
#
#
#
# install.packages("devtools")
# devtools::install_github("scienceverse/metacheck")

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
library(readr)
library(knitr)
#
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
#
#
#
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
#
saveRDS(articles, "articles_xml.Rds")
#
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
exact$table |> 
  count()
#
#
#
#
#
#
exact$table |> 
  count(p_comp)
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
exact$table |> 
  filter(p_comp %in% c("<", "≤"), !str_detect(p_value, regex("0\\.001|\\.001", ignore_case = TRUE))) |> 
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
es <- module_run(
  articles_files,
  "stat_effect_size"
)

es_summary <- if (is.null(es) || is.null(es$table) || nrow(es$table) == 0L) {
  tibble()
} else {
  es$table %>%
    mutate(report_es = !is.na(es)) %>%
    filter(test %in% c("t-test", "F-test")) %>%
    group_by(test, report_es) %>%
    summarise(n = n(), .groups = "drop") %>%
    tidyr::pivot_wider(
      names_from = report_es,
      values_from = n,
      values_fill = 0
    ) %>%
    rename(reported_es = `TRUE`, missing_es = `FALSE`) %>%
    mutate(
      total = reported_es + missing_es,
      prop_reported = reported_es / total
    )
}

es_summary
#
#
#
#
#
# Search for the ± symbol in the results section and count how many papers contain it
pm_hits <- search_text(
  articles_files,
  pattern = "±",
  section = "results",
  return = "sentence"
)

if (is.null(pm_hits) || nrow(pm_hits) == 0L) {
  n_sentences_pm <- 0L
  n_papers_pm <- 0L
} else {
  n_sentences_pm <- nrow(pm_hits)
  id_candidates <- c("file", "file_name", "filename", "article", "article_id", "id", "doc_id", "doc")
  id_col <- intersect(id_candidates, names(pm_hits))
  if (length(id_col) >= 1) {
    n_papers_pm <- pm_hits %>% dplyr::pull(id_col[1]) %>% n_distinct()
  } else {
    n_papers_pm <- NA_integer_
  }
}

total_papers <- length(articles_files)

result_pm <- tibble::tibble(
  n_sentences = n_sentences_pm,
  n_papers_reporting = n_papers_pm,
  total_papers = total_papers,
  proportion = if (!is.na(n_papers_pm)) n_papers_pm / total_papers else NA_real_
)

result_pm
#
#
#
#
#
mean_sd_hits <- search_text(
  articles_files,
  pattern = "(?i)mean\\s*±\\s*(sd|s\\.d\\.|standard\\s+deviation)",
  section = NULL,
  return = "sentence"
)

if (is.null(mean_sd_hits) || nrow(mean_sd_hits) == 0L) {
  n_sentences_mean_sd <- 0L
  n_papers_reporting <- 0L
} else {
  n_sentences_mean_sd <- nrow(mean_sd_hits)
  id_candidates <- c("file", "file_name", "filename", "article", "article_id", "id", "doc_id", "doc")
  id_col <- intersect(id_candidates, names(mean_sd_hits))
  if (length(id_col) >= 1) {
    n_papers_reporting <- mean_sd_hits %>% dplyr::pull(id_col[1]) %>% n_distinct()
  } else {
    n_papers_reporting <- NA_integer_
  }
}

total_papers <- length(articles_files)

result_mean_sd <- tibble::tibble(
  n_sentences = n_sentences_mean_sd,
  n_papers_reporting = n_papers_reporting,
  total_papers = total_papers,
  proportion = if (!is.na(n_papers_reporting)) n_papers_reporting / total_papers else NA_real_
)

result_mean_sd
#
#
#
#
#
ci_hits <- search_text(
  articles_files,
  pattern = "(?i)95%\\s*(CI|confidence\\s*interval)",
  section = NULL,
  return = "sentence"
)

if (is.null(ci_hits) || nrow(ci_hits) == 0L) {
  n_sentences_ci <- 0L
  n_papers_reporting_ci <- 0L
} else {
  n_sentences_ci <- nrow(ci_hits)
  id_candidates <- c("file", "file_name", "filename", "article", "article_id", "id", "doc_id", "doc")
  id_col <- intersect(id_candidates, names(ci_hits))
  if (length(id_col) >= 1) {
    n_papers_reporting_ci <- ci_hits %>% dplyr::pull(id_col[1]) %>% n_distinct()
  } else {
    n_papers_reporting_ci <- NA_integer_
  }
}

total_papers <- length(articles_files)

result_95ci <- tibble::tibble(
  n_sentences = n_sentences_ci,
  n_papers_reporting = n_papers_reporting_ci,
  total_papers = total_papers,
  proportion = if (!is.na(n_papers_reporting_ci)) n_papers_reporting_ci / total_papers else NA_real_
)

result_95ci
#
#
#
#
#
# Run statcheck on the corpus, then count how many tests completed
# and produce a table broken down into t-tests and F-tests.
statcheck_p_values <- module_run(articles_files, "stat_check")

tbl <- statcheck_p_values$table

# define "completed" as rows where a computed p-value was produced
completed <- tbl %>%
  dplyr::filter(!is.na(computed_p))

# standardise test type labels (t-test, F-test, other)
completed <- completed %>%
  dplyr::mutate(
    test_raw = as.character(test_type),
    test_type = dplyr::case_when(
      stringr::str_detect(test_raw, stringr::regex("\\bt\\b|t-test|^t", ignore_case = TRUE)) ~ "t-test",
      stringr::str_detect(test_raw, stringr::regex("\\bf\\b|f-test|^f", ignore_case = TRUE)) ~ "F-test",
      TRUE ~ "other"
    )
  )

# summary table: counts and proportions
total_completed <- nrow(completed)

summary_by_test <- completed %>%
  dplyr::count(test_type, name = "n_tests") %>%
  dplyr::mutate(prop = n_tests / total_completed)

summary_table <- dplyr::bind_rows(
  summary_by_test,
  tibble::tibble(test_type = "Total_completed", n_tests = total_completed, prop = 1)
)

summary_table
#
#
#
#
#
#
#
error <- completed |>
  mutate(error = as.factor(error)) |>
  count(error) |>
  mutate(prevalence = round(n / sum(n) * 100, 1))
#
#
#
#
#
error_1dec <-completed |>
  mutate(new_error = abs(computed_p - reported_p) > 0.1) |>
  count(new_error) |>
  mutate(prevalence = round(n / sum(n) * 100, 1))

#
#
#
#
#
#
completed |>
  mutate(error = as.factor(error)) |>
  count(decision_error) |>
  mutate(prevalence = round(n / sum(n) * 100, 1))
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
#
Coded_papers <- read_csv("DATA reporting_practices - Coded Data.csv", col_types = cols())  # returns a tibble

# treat a cell as "reported" if it contains a numeric value or the letter "y"

 is_reported_value <- function(x) {
    s <- as.character(x)
    s_trim <- str_trim(s)
    is_missing <- is.na(s) | s_trim == ""
    is_y <- !is_missing & str_detect(s_trim, regex("\\by\\b", ignore_case = TRUE))
    is_num <- !is_missing & !is.na(suppressWarnings(as.numeric(s_trim)))
    is_y | is_num
  }

  if (!"Test_Type" %in% names(Coded_papers)) {
    if (any(c("t_statistic", "f_statistic") %in% names(Coded_papers))) {
      Coded_papers <- Coded_papers |>
        mutate(
          Test_Type = case_when(
            is_reported_value(t_statistic) ~ "t-test",
            is_reported_value(f_statistic) ~ "F-test",
            TRUE ~ NA_character_
          )
        )
    } else {
      stop("No Test_Type-like column found and neither t_statistic nor f_statistic exist. Run names(Coded_papers) to inspect column names.")
    }
  }


# compute summaries (uses Test_Type))
is_reported_value <- function(x) {
  s <- as.character(x)
  s_trim <- str_trim(s)
  is_missing <- is.na(s) | s_trim == ""
  is_y <- !is_missing & str_detect(s_trim, regex("\\by\\b", ignore_case = TRUE))
  is_num <- !is_missing & !is.na(suppressWarnings(as.numeric(s_trim)))
  is_y | is_num
}

total_sample <- nrow(Coded_papers)

statistic_summary <- Coded_papers |>
  group_by(Test_Type) |>
  summarise(
    reported = sum(is_reported_value(t_statistic)),
    missing = sum(!is_reported_value(t_statistic)),
    total = n(),
    proportion_reported = reported / total,
    perc_of_total_reported = reported / total_sample * 100,
    perc_of_total_missing = missing / total_sample * 100,
    .groups = "drop"
  )

list(statistic_summary = statistic_summary)


# compute percent of rows with a reported p-value (uses total_sample already defined) from the column "are p_values_reported", only if YES

 # Count YES responses
yes_count <- sum(Coded_papers$`p-values?` == "Yes", na.rm = TRUE)

# Total number of observations (non-missing)
total_n <- sum(!is.na(Coded_papers$`p-values?`))

# Print result
yes_count
total_n

# Compute proportion
if (total_n > 0) {
  yes_proportion <- yes_count / total_n
} else {
  yes_proportion <- NA
}
yes_proportion

### table for figure 1

# 1. Read data
Coded_papers <- read.csv("DATA reporting_practices - Coded Data.csv", stringsAsFactors = FALSE)

# 2. Simple YES/NO variables
yes_no_cols <- c("Any_stats.", "p.values.", "test_stats.", "Df.")

summary_yesno <- data.frame(Variable = yes_no_cols) %>%
  rowwise() %>%
  mutate(
    N = sum(Coded_papers[[Variable]] == "Yes", na.rm = TRUE),
    Total = sum(!is.na(Coded_papers[[Variable]])),
    Result = paste0(N, " (", round(100 * N / Total, 1), "%)")
  ) %>%
  ungroup() %>%
  select(Variable, Result)

# 3. ES (multiple categories)
summary_ES <- Coded_papers %>%
  filter(!is.na(`ES.`)) %>%
  group_by(Response = `ES.`) %>%
  summarise(N = n(), .groups = "drop") %>%
  mutate(
    Total = sum(N),
    Result = paste0(N, " (", round(100 * N / Total, 1), "%)"),
    Variable = paste("Effect sizes:", Response)
  ) %>%
  select(Variable, Result)

# 4. CI_ES (multiple categories)
summary_CI <- Coded_papers %>%
  filter(!is.na(`CI_ES.`)) %>%
  group_by(Response = `CI_ES.`) %>%
  summarise(N = n(), .groups = "drop") %>%
  mutate(
    Total = sum(N),
    Result = paste0(N, " (", round(100 * N / Total, 1), "%)"),
    Variable = paste("Effect size CIs:", Response)
  ) %>%
  select(Variable, Result)

# 5. Combine everything
summary_APA <- bind_rows(summary_yesno, summary_ES, summary_CI)

# 6. Clean labels
summary_APA$Variable <- recode(summary_APA$Variable,
  "Any_stats." = "Any statistics reported",
  "p.values." = "p-values reported",
  "test_stats." = "Test statistics reported",
  "Df." = "Degrees of freedom reported"
)

#
#
#
