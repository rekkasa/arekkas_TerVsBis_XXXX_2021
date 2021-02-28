# Add mean predicted risk, and rectangle limits to absolute dataframe


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
        stratum = case_when(
            riskStratum == "Q1" ~1,
            riskStratum == "Q2" ~2,
            riskStratum == "Q3" ~3,
            riskStratum == "Q4" ~4
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

ggplot() +
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
            x = stratum,           # This will be the mean predicted risk
            y = estimate
        )
        
    ) +
    geom_errorbar(
        data = absolute,
        aes(
            ymin = lower, 
            ymax = upper, 
            x = stratum, 
            y = estimate
        ), 
        width = 0
    ) +
    geom_hline(yintercept = 0, linetype = "dashed") +
    facet_wrap(~database, ncol = 1) +
    ylim(-3, 5) +
    theme_classic()
    
