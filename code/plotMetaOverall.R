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

calibrateOverallResults <- readRDS("data/processed/calibrateOverallResults.rds")
metaCalibrateOverall    <- readRDS("data/processed/metaCalibrateOverall.rds")

overall <- calibrateOverallResults %>%
    select(-contains("Rr")) %>%
    mutate(
        type = "single",
        position = case_when(
            database == "mdcr" ~ 5,
            database == "optum_dod" ~ 4,
            database == "panther" ~ 3
        )
    )

metaOverall <- metaCalibrateOverall %>%
    mutate(
        database = "overall",
        type     = "meta",
        position = 1
    )

combined <- rbind(overall, metaOverall) %>%
    mutate(
        database = factor(
            x = database,
            levels = c("overall", "optum_dod", "panther", "mdcr"),
            labels = c("Overall", "OPTUM (DoD)", "Panther", "MDCR")
        ),
        outcome = factor(
            x = outcome,
            levels = 101:103,
            labels = c(
                "Hip fracture",
                "Major osteoporotic fracture",
                "Vertebral fracture"
            )
        )
    )

ggplot(
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
        ~outcome
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
        label = "Favors\nTeriparatide", 
        x     = .73, 
        y     = -.1, 
        color = "black",
        size  = 2
    ) +
    geom_text(
        label = "Favors\nBisphosphonates", 
        x     = 1.3, 
        y     = -.1, 
        color = "black",
        size  = 2
    ) +
    scale_y_continuous(
        breaks = c(1, 3, 4, 5),
        labels = c(
            "Summary",
            "Optum EHR",
            "Optum (DoD)",
            "MDCR"
        ),
        limits = c(-.2, 5)
    ) +
    scale_x_continuous(
        breaks = c(.5, 1, 1.5),
        labels = c("0.5", "1", "1.5"),
        limits = c(.5, 1.5)
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
    theme_classic() +
    theme(
        legend.position  = "none",
        axis.title.y     = element_blank(),
        strip.background = element_blank()
    )

ggsave("figures/plotMeta.pdf", height = 3, width = 7)

