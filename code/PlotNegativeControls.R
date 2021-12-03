#!/usr/bin/env Rscript

# =================================
# Description:
# Input:
# Output:
# Depends:
# =================================

library(tidyverse)
library(EmpiricalCalibration)

databases <- c("ccae", "optum_extended_dod", "optum_ehr")
databaseLabels <- c("CCAE", "Optum-DOD", "Optum-EHR")
mappedOverallResults <- readRDS("data/processed/mappedOverallResults.rds")
overallNegativeControls <- readRDS("data/processed/mappedOverallResultsNegativeControls.rds")
plot <- list()

for (i in seq_along(databases)) {
  positiveResults <- mappedOverallResults %>%
    filter(
      database == databases[i],
      analysisType == "age_50_tr_1_m_1_10",
      outcomeId == 101
    ) %>%
    mutate(logRr = log(estimate))
  
  negativeControls <- overallNegativeControls %>%
    filter(
      database == databases[i],
      analysisType == "age_50_tr_1_m_1_10"
    ) %>%
    mutate(logRr = log(estimate))
  
  null <- fitNull(
    logRr = negativeControls$logRr,
    seLogRr = negativeControls$seLogRr)
  
  plot[[i]] <- plotCalibrationEffect(
    null = null,
    logRrNegatives = negativeControls$logRr,
    seLogRrNegatives = negativeControls$seLogRr,
    logRrPositives = positiveResults$logRr,
    seLogRrPositives = positiveResults$seLogRr
  ) +
    ggtitle(databaseLabels[i]) +
    theme(
      plot.title = element_text(size = 38),
      axis.text.x = element_text(size = 22),
      axis.title.x  = element_text(size = 30),
    )
  if (i == 1) {
    plot[[i]] <- plot[[i]] +
      theme(axis.title.y = element_text(size = 30))
  } else {
    theme(axis.title.y = element_blank())
  }
}

res <- gridExtra::grid.arrange(plot[[1]], plot[[2]], plot[[3]], nrow = 1)


ggsave(
  file.path("figures/OverallNcPlot.tiff"),
  plot = res,
  dpi = 600,
  width = 700,
  height = 350,
  units = "mm",
  compression = "lzw"
)
