#!/usr/bin/env Rscript

# Description:
#   Generates the plot regarding the meta-analysis of the calibrated hazard
#   ratios for the three outcomes
# Depends:
#   data/processed/calibrateOverallResults.rds 
#   data/processed/metaCalibrateOverall.rds
# Output:
#   figures/plotMeta.pdf

library(tidyverse)
suffix <- "age_50_tr_1_q_25_75"

calibrateRiskStratified <- readRDS(
    file.path(
        "data/processed",
        paste0(
            paste(
                "calibrateRiskStratified",
                suffix,
                sep = "_"
            ),
            ".rds"
        )
    )
) %>%
    filter(
      stratOutcome == 101,
      estOutcome == 101
    ) %>%
    rename("outcome" = "estOutcome")

metaCalibrateRiskStratified <- readRDS(
    file.path(
        "data/processed",
        paste0(
            paste(
                "metaCalibrateRiskStratified",
                suffix,
                sep = "_"
            ),
            ".rds"
        )
    )
) %>%
    filter(stratOutcome == 101, estOutcome == 101) %>%
    rename("outcome" = "estOutcome")

riskStratified <- calibrateRiskStratified %>%
    mutate(
        hr = exp(logRr),
        lower    = exp(logLb95Rr),
        upper    = exp(logUb95Rr)
    ) %>%
    select(-contains("Rr")) %>%
    mutate(
        type = "single",
        position = case_when(
            database == "ccae" ~ 5,
            database == "optum_extended_dod" ~ 4,
            database == "optum_ehr" ~ 3
        )
    )

metaRiskStratified <- metaCalibrateRiskStratified %>%
    mutate(
        database = "overall",
        type     = "meta",
        position = 1
    ) %>%
    relocate(database, .after = stratOutcome)

combined <- rbind(riskStratified, metaRiskStratified) %>%
    mutate(
      database = factor(
        x = database,
        levels = c("overall", "optum_extended_dod", "optum_ehr", "ccae"),
        labels = c("Overall", "OPTUM (DoD)", "Panther", "CCAE")
      ),
      riskStratum = factor(
        x = riskStratum,
        levels = c("Q1", "Q2"),
        labels = c(
          "Lower 75%\nhip fracture risk",
          "Upper 25%\nhip fracture risk"
        )
      )
    )

p <- ggplot(
    data = combined,
    aes(
        x    = hr,
        y    = position,
        xmin = lower,
        xmax = upper,
        color = type,
    )
) +
    facet_wrap(
        ~riskStratum 
    ) +
    geom_point(
        aes(
            shape = type, 
            fill  = type
        ), 
        size = 2
    ) +
    geom_errorbar(width = 0) +
    geom_vline(xintercept = 1, linetype = 2) +
    geom_text(
        label = "Favors Teriparatide", 
        x     = .45, 
        y     = -.1, 
        color = "black",
        size  = 2
    ) +
    geom_text(
        label = "Favors Bisphosphonates", 
        x     = 1.555, 
        y     = -.1, 
        color = "black",
        size  = 2
    ) +
    scale_y_continuous(
        breaks = c(1, 3, 4, 5),
        labels = c(
            "Summary",
            "Optum-EHR",
            "Optum-DOD",
            "CCAE"
        ),
        limits = c(-.2, 5)
    ) +
    scale_x_continuous(
        breaks = c(0, 1, 2),
        labels = c("0", "1", "2"),
        limits = c(0, 2.2)
    ) +
    scale_color_manual(
        breaks = c("meta", "single"),
        values = c("red", "black")
    ) +
    scale_fill_manual(
        breaks = c("meta", "single"),
        values = c("red", "black")
    ) +
    scale_shape_manual(
        breaks = c("meta", "single"),
        values = c(23, 21)
    ) +
    xlab("Calibrated hazard ratio") +
    # theme_classic() +
    ggthemes::theme_clean() +
    theme(
      legend.position    = "none",
      axis.title.y       = element_blank(),
      strip.background   = element_blank(),
      strip.text.x       = element_text(size = 10)
    )

ggsave("figures/plotMetaRiskStratified.tiff", plot = p, height = 4, width = 7, compression = "lzw+p", dpi = 1000)
