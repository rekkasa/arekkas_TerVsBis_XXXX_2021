#!/usr/bin/env Rscript

# =================================
# Description:
# Input:
# Output:
# Depends:
# =================================

library(tidyverse)
library(EmpiricalCalibration)

positiveResults <- readRDS("data/raw/mappedOverallResults.rds") %>%
  filter(
    database == "ccae",
    analysisType == "age_50_tr_1_m_1_10",
    outcomeId == 101
  ) %>%
  mutate(logRr = log(estimate))

negativeControls <- readRDS(
  "data/raw/mappedOverallResultsNegativeControls.rds"
) %>%
  filter(
    database == "ccae",
    analysisType == "age_50_tr_1_m_1_10"
  ) %>%
  mutate(logRr = log(estimate))

null <- fitNull(
  logRr = negativeControls$logRr,
  seLogRr = negativeControls$seLogRr)

plot <- plotCalibrationEffect(
  null = null,
  logRrNegatives = negativeControls$logRr,
  seLogRrNegatives = negativeControls$seLogRr,
  logRrPositives = positiveResults$logRr,
  seLogRrPositives = positiveResults$seLogRr
)

ggsave(
  file.path("figures/overallNcPlot.tiff"),
  plot = plot,
  dpi = 1200,
  width = 10,
  height = 8,
  compression = "lzw"
)
