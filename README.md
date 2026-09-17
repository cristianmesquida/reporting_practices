# Project Title


# Project Description


# Repository Structure

```{r}
reporting_practices/
├── manuscript/
│   ├── manuscript.qmd        # Quarto document containing all code to fully reproduce the manuscript
│   └── references.bib        # Bibliography used in manuscript.qmd
│
├── data/
│   ├── ...
│   └── ...
│
├── agreement/
│   ├── 01_intercoder_agreement_function.R   # Functions to calculate Fleiss' kappa estimates
│   ├── disagreements2.xlsx                  # Data extracted independently by two raters
│   └── disagreements3.xlsx                  # Data extracted independently by three raters
│
└── files/
    └── articles_xml.RDS     # R object containing all XML articles
```
