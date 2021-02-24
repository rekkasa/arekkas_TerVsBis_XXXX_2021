#!/usr/bin/env Rscript

# Description:
#     Extracts the subset of analyses that estimated the absolute effects for hip
#     fracture within strata of predicted hip fracture risk
# Depends:
#     data/raw/mappedOverallAbsoluteResults.rds
# Output:
#     data/processed/hipFractureAbsolute.rds
    
    
library(tidyverse)

absoluteResults <- readRDS("data/raw/mappedOverallAbsoluteResults.rds") %>%
    tibble()

absoluteResults %>%
    filter(
        analysisType == "matchOnPs_1_to_4",
        stratOutcome == 101,
        estOutcome == 101
    ) %>%
    saveRDS("data/processed/hipFractureAbsolute.rds")
