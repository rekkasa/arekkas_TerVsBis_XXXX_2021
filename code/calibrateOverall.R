#!/usr/bin/env Rscript

# Description:
#   Calculates the negative control-calibrated hazard ratios per database:outcome
#   combination.
# Depends: 
#   data/raw/mappedOverallResultsNegativeControls.rds
#   data/raw/mappedOverallResults.rds
# Output:
#   data/processed/calibrateOverallResults.rds


library(tidyverse)

overallNegativeControls <- readRDS(
  "/home/arekkas/Documents/Projects/osteoporosis/data/raw/mappedOverallResultsNegativeControls.rds"
) %>%
  dplyr::filter(
    analysisType == "matchOnPs_1_to_4"
  ) %>%
  dplyr::mutate(logRr = log(estimate))

overallMappedOverallRelativeResults <- readRDS(
  "/home/arekkas/Documents/Projects/osteoporosis/data/raw/mappedOverallResults.rds"
) %>%
  dplyr::filter(
    analysisType == "matchOnPs_1_to_4"
  ) %>%
  mutate(logRr = log(estimate))

mod <- overallNegativeControls %>%
  split(.$database) %>%
  purrr::map(
    ~EmpiricalCalibration::fitSystematicErrorModel(
      logRr = .x$logRr,
      seLogRr = .x$seLogRr,
      trueLogRr = rep(0, nrow(.x))
    )
  )


overallMappedOverallRelativeResults %>%
  split(list(.$database, .$outcomeId), sep = ":") %>%
  purrr::map_dfr(
    ~EmpiricalCalibration::calibrateConfidenceInterval(
      logRr = .x$logRr,
      seLogRr = .x$seLogRr,
      model = mod[[.x$database]]
    ),
    .id = "id"
  ) %>%
  mutate(
    hr = exp(logRr),
    lower = exp(logLb95Rr),
    upper = exp(logUb95Rr)
  ) %>%
  tidyr::separate(id, c("database", "outcome"), ":") %>%
  saveRDS("data/processed/calibrateOverallResults.rds")
