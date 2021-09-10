#!/usr/bin/env Rscript

# Description:
#   Calculates the negative control-calibrated hazard ratios per database:outcome
#   combination.
# Depends: 
#   data/raw/negativeControls.rds
#   data/raw/mappedOverallRelativeResults.rds
# Output:
#   data/processed/calibrateRiskStratified.rds

library(tidyverse)

args = commandArgs(trailingOnly = TRUE)
fileName <- paste0(
    paste(
        "calibrateRiskStratified",
        args[1],
        sep = "_"
    ),
    ".rds"
)

negativeControls <- readRDS(
    "data/raw/negativeControls.rds"
) %>%
    dplyr::filter(
        analysisType == args[1],
        database %in% args[-1]
    ) %>%
    dplyr::mutate(logRr = log(estimate))

relativeResults <- readRDS(
    "data/raw/mappedOverallRelativeResults.rds"
) %>%
    filter(
        analysisType == args[1],
        database %in% args[-1]
    ) %>%
    mutate(
        logRr = log(estimate)
    )



systErrorModels <- negativeControls %>%
    filter(!is.na(seLogRr)) %>%
    group_by(database, stratOutcome, riskStratum) %>%
    nest() %>%
    mutate(
        mod = map(
            data,
            ~EmpiricalCalibration::fitSystematicErrorModel(
                logRr     = .x$logRr,
                seLogRr   = .x$seLogRr,
                trueLogRr = rep(0, nrow(.x))
            )
        )
    ) %>%
    select(-data)

tibble(relativeResults) %>%
    mutate(estimate = log(estimate)) %>%
    inner_join(systErrorModels) %>%
    group_by(database, stratOutcome, estOutcome, riskStratum) %>%
    nest() %>%
    mutate(
        pp = map(
            data,
            ~EmpiricalCalibration::calibrateConfidenceInterval(
                logRr   = .x$estimate,
                seLogRr = .x$seLogRr,
                model   = .x$mod[[1]]
            )
        )
    ) %>% 
    unnest(pp) %>%
    select(-data) %>%
    saveRDS(
        file.path(
            "data/processed",
            fileName
        )
    )
