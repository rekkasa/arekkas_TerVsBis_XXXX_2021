#!/usr/bin/env Rscript

# Author: Alexandros Rekkas
#
# Description:
#   Plots the risk stratified absolute difference for hip fracture with respect
#   to estimated hip fracture risk
# Depends:
#   data/raw/mappedOverallAbsoluteResults.rds
# Output:
#   figures/plotAbsoluteHip.pdf
#   figures/plotAbsoluteHip.tiff
#   figures/plotAbsoluteHip.png
# 
# Notes:
#   Add mean predicted risk, and rectangle limits to absolute dataframe

library(tidyverse)

absolute <- readRDS("data/raw/mappedOverallAbsoluteResults.rds") %>%
    filter(
        analysisType == "matchOnPs_1_to_4",
        stratOutcome == 101,
        estOutcome == 101
    ) %>%
    mutate(
        estimate = 100 * estimate,
        lower    = 100 * lower,
        upper    = 100 * upper,
        meanRisk = case_when(
            riskStratum == "Q1" ~1,
            riskStratum == "Q2" ~2,
            riskStratum == "Q3" ~3,
            riskStratum == "Q4" ~4
        ),
        database = case_when(
            database == "mdcr" ~ "MDCR",
            database == "optum_dod" ~ "Optum-DOD",
            database == "panther" ~ "Optum-EHR"
        )
    )

dataRect <- function(xmin, xmax) {
    data.frame(
        xmin = xmin,
        xmax = xmax,
        ymin = -Inf,
        ymax = Inf
    )
}

p <- ggplot() +
    geom_rect(
        data = dataRect(-Inf, 1.5),
        inherit.aes = FALSE,
        aes(
            xmin = xmin,
            xmax = xmax,
            ymin = ymin,
            ymax = ymax
        ),
        fill = "#ffffcc",
        alpha = .3
    ) +
    geom_rect(
        data = dataRect(1.5, 2.5),
        inherit.aes = F,
        aes(
            xmin = xmin,
            xmax = xmax,
            ymin = ymin,
            ymax = ymax
        ),
        fill = "#a1dab4",
        alpha = .3
    ) +
    geom_rect(
        data = dataRect(2.5, 3.5),
        inherit.aes = F,
        aes(
            xmin = xmin,
            xmax = xmax,
            ymin = ymin,
            ymax = ymax
        ),
        fill = "#41b6c4",
        alpha = .3
    ) +
    geom_rect(
        data = dataRect(3.5, Inf),
        inherit.aes = F,
        aes(
            xmin = xmin,
            xmax = xmax,
            ymin = ymin,
            ymax = ymax
        ),
        fill = "#225ea8",
        alpha = .3
    ) +
    geom_point(
        data = absolute,
        aes(
            x = meanRisk,           # This will be the mean predicted risk
            y = estimate
        )
        
    ) +
    geom_errorbar(
        data = absolute,
        aes(
            ymin = lower, 
            ymax = upper, 
            x = meanRisk, 
            y = estimate
        ), 
        width = 0
    ) +
    geom_hline(yintercept = 0, linetype = "dashed") +
    facet_wrap(
        ~database, 
        ncol = 1,
        strip.position = "left"
    ) +
    scale_y_continuous(
        name = "Absolute risk difference (%)"
    ) +
    scale_x_continuous(
        breaks = 1:4,
        labels = paste0("Q", 1:4),
        name = "Risk quarter"
    ) +
    theme_classic() +
    theme(
        strip.placement = "outside",
        strip.background = element_blank()
    )
    
ggsave("figures/plotAbsoluteHip.pdf", plot = p, height = 5, width = 7)
ggsave("figures/plotAbsoluteHip.tiff", plot = p, height = 5, width = 7, compression = "lzw+p")
ggsave("figures/plotAbsoluteHip.png", plot = p, height = 5, width = 7)

