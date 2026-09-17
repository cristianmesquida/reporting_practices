## This script was used to create a function that 
## 1) reads the existing sheets from an excel file, where each sheet represents a variable
## 2) estimates the inter-coder agreement for each coded variable


# Load packages
library(readxl)
library(DescTools)
library(dplyr)  
library(irr)
library(lpSolve)

# Name variables assessed for inter-coder agreement
variable_names <- c("power_analysis", "specified_dv_power", "power_sample", 
                    "type_es", "type_standardised_es", #"type_cohen", #"type_hedge", 
                    "magnitude_es", "es_justification", "sample_previous_study", 
                    "intended_power", "software", "statistical_test_power", 
                    "alpha_level", "statistical_test_study", "match_statistical_test", 
                    "hypothesis_statement", "type_hypothesis", "support_hypothesis",
                    "study_sample", "statistical_result", "type_effect",
                    "preregistration", "public_data_repository", "link_data_repository") 


# Select variables assessed for inter-coder agreement (each sheet is a variable that was
# recorded by coders)
selected_sheets <- c("Sheet5", "Sheet8", "Sheet11", "Sheet12", "Sheet13",
                     "Sheet16", "Sheet17", "Sheet18", "Sheet19", "Sheet20", 
                     "Sheet21", "Sheet23", "Sheet24", "Sheet25", "Sheet26",
                     "Sheet27", "Sheet29", "Sheet30", "Sheet31", "Sheet33", 
                     "Sheet45", "Sheet46", "Sheet47") 

# Create a function to assess inter-coder agreement between 3 coders
calculate_kappa3_from_excel <- function(file_path) {
  results <- data.frame(variable = character(),
                        kappa_estimate = numeric(),
                        stringsAsFactors = FALSE)

  for (sheet in selected_sheets) {
    raw_sheet <- as.data.frame(read_excel(file_path, sheet = sheet))
    coders_responses <- raw_sheet[, seq_len(min(3, ncol(raw_sheet))), drop = FALSE]

    kappa_result <- kappam.fleiss(coders_responses)
    kappa_estimate <- round(kappa_result$value, 2)
    results <- rbind(results, data.frame(variable = sheet,
                                         fleiss_kappa = kappa_estimate))
  }

  results$variable <- variable_names

  return(results)
}


# Create the function to assess inter-coder agreement between 2 coders
calculate_kappa2_from_excel <- function(file_path) {
  results <- data.frame(variable = character(),
                        kappa_estimate = numeric(),
                        stringsAsFactors = FALSE)

  for (sheet in selected_sheets) {
    raw_sheet <- as.data.frame(read_excel(file_path, sheet = sheet))
    coders_responses <- raw_sheet[, seq_len(min(2, ncol(raw_sheet))), drop = FALSE]

    kappa_result <- kappa2(coders_responses)
    kappa_estimate <- round(kappa_result$value, 2)
    results <- rbind(results, data.frame(variable = sheet,
                                         cohen_kappa = kappa_estimate))
  }

  results$variable <- variable_names

  return(results)
}


