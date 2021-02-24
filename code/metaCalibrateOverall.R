#!/usr/bin/env Rscript

# Description:
#     Generates meta-analytic estimates of negative control-calibrated estimates
#     for all outcomes
# Depends:
#     data/processed/calibrateOverallResults.rds
# Output:
#     data/processed/calibrateMetaOverall.rds


library(tidyverse)

calibrateOverallResults <- readRDS(
    here::here("data/processed/calibrateOverallResults.rds")
)

metaAnalysis <- function(data) {
    metaRes <- meta::metagen(
        TE = data$logRr,
        seTE = data$seLogRr,
        sm = "HR",
        method.tau = "PM",
        studlab = data$database
    )

   res <- tibble(
       hr = exp(metaRes$TE.random),
       lower = exp(metaRes$lower.random),
       upper = exp(metaRes$upper.random)
   ) 
   
   return(res)
    
}

calibrateOverallResults %>%
    group_by(outcome) %>%
    nest() %>%
    mutate(var = map(data, ~metaAnalysis(.x))) %>%
    unnest(cols = var) %>%
    select(-data) %>%
    saveRDS("data/processed/metaCalibrateOverall.rds")
