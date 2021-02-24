#!/usr/bin/env Rscript

# Description:
#     Generates meta-analytic estimates of negative control-calibrated estimates
#     for all outcomes in all risk quarters
# Depends:
#     data/processed/calibrateRiskStratified.rds
# Output:
#     data/processed/metaCalibrateRiskStratified.rds

library(tidyverse)

calibrateRiskStratified <- readRDS("data/processed/calibrateRiskStratified.rds")

metaAnalysisRiskStratified <- function(data) {
    
    metaRes <- meta::metagen(
        TE         = data$logRr,
        seTE       = data$seLogRr,
        sm         = "HR",
        method.tau = "PM",
        studlab    = data$database
    )
    
    res <- tibble(
        hr    = exp(metaRes$TE.random),
        lower = exp(metaRes$lower.random),
        upper = exp(metaRes$upper.random)
    ) 
    
    return(res)
}

calibrateRiskStratified %>%
    group_by(stratOutcome, estOutcome, riskStratum) %>%
    nest() %>%
    mutate(
        meta = map(
            data,
           ~metaAnalysisRiskStratified(.x) 
        )
    ) %>%
    unnest(meta) %>%
    select(-data) %>%
    saveRDS("data/processed/metaCalibrateRiskStratified.rds")