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
all_p <- module_run(
  articles_files, 
  "all_p_values"
  )

all_ps <- all_p$table |>
  count(text, sort = TRUE)

all_ps
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

sig_p <-exact$table |> 
  count(text, sort = TRUE)

sig_p
#
#
#
#
#
#
exact_nonsig <- module_run(
  articles_files, 
  "stat_p_nonsig"
  )

nonsig_p <-exact_nonsig$table |> 
  count(text, sort = TRUE)

nonsig_p
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
head(es$table, 5)
es$table |> 
  mutate(as.factor(test)) |> 
  filter(test == "F-test") |> 
  count(is.na(es)) |> # returns cases where es == NA (not reported)
  mutate(prop = n / sum(n)) 
```
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
statcheck_p_values <- module_run(
  articles_files, 
  "stat_check"
  )

statcheck_p_values$table
```
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
statcheck_p_values$table |> 
  mutate(flagged_p_values = round(computed_p / reported_p, 1)) |> 
           filter(flagged_p_values >= 2)
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
Coded_papers <- read_csv("DATA reporting_practices - Coded Data.csv", col_types = cols())  # returns a tibble
ANOVA_rep <- read_csv("DATA reporting_practices - ANOVA rep.csv", col_types = cols())  # returns a tibble
#
#
#
#
