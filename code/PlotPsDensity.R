#!/usr/bin/env Rscript

library(tidyverse)

databases <- c("ccae", "optum_extended_dod", "optum_ehr")
databaseLabels <- c("CCAE", "Optum-DOD", "Optum-EHR")
pp <- list()

for (i in seq_along(databases)) {
  pattern <- paste0("^overall_psDensity.*", databases[i], ".*101*.rds")
  pp[[i]] <- list.files(
    path = "data/processed",
    pattern = pattern,
    full.names = TRUE
  ) %>%
    map(readRDS) %>%
    bind_rows() %>%
    mutate(
      treatment = as.factor(treatment)
    ) %>%
    tibble() %>%	
    ggplot2::ggplot(
      ggplot2::aes(
        x = x,
        y = y
      )
    ) +
    ggplot2::geom_density(
      stat = "identity",
      ggplot2::aes(
        color = treatment,
        group = treatment,
        fill = treatment
      )
    ) +
    scale_x_continuous(breaks = seq(0, 1, .5)) +
    ggplot2::ylab(
      label = databaseLabels[i]
    ) +
    ggplot2::xlab(
      label = "Preference score"
    ) +
    ggplot2::scale_fill_manual(
      values = alpha(c("#fc8d59", "#91bfdb"), .6)
    ) +
    ggplot2::scale_color_manual(
      values = alpha(c("#fc8d59", "#91bfdb"), .9)
    ) +
    theme_bw() +
    ggplot2::theme(
      legend.title    = ggplot2::element_blank(),
      legend.position = "none",
      axis.title.x    = element_blank(),
      axis.line.y     = element_blank(),
      axis.ticks.y    = element_blank(),
      axis.text.y     = element_blank(),
      axis.text.x     = element_text(size = 22),
      axis.title      = element_text(size = 30),
      strip.text      = element_text(size = 25)
    )  
  if (i != 1) {
    pp[[i]] <- pp[[i]] +
      theme(
        strip.text       = element_blank(),
        strip.background = element_blank()
      )
  }
}


plot <- gridExtra::grid.arrange(pp[[1]], pp[[2]], pp[[3]], nrow = 1)
ggsave(
  "figures/OverallPsDensity.tiff",
  plot, 
  compression = "lzw", 
  width       = 700, 
  height      = 350,
  units       = "mm",
  dpi         = 600
)
