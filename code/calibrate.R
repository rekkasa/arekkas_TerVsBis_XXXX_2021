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


res <- data.frame(
  logRr = numeric(),
  logLb95Rr = numeric(),
  logUb95Rr = numeric(),
  seLogRr = numeric(),
  database = character()
)

for (i in seq_along(databases)) {
  ncs <- overallNegativeControls %>% 
    filter(analysisType == "matchOnPs_1_to_4", database == databases[i]) %>%
    mutate(logRr = log(estimate))
  
  mod <- EmpiricalCalibration::fitSystematicErrorModel(
    logRr =  ncs$logRr,
    seLogRr = ncs$seLogRr,
    trueLogRr = rep(0, nrow(ncs))
  )
  est <- overallMappedOverallRelativeResults %>%
    filter(
      analysisType == "matchOnPs_1_to_4",
      outcomeId == 101,
      database == database[i]
      ) %>%
    mutate(logRr = log(estimate))
  
  res <- res %>%
    dplyr::bind_rows(
    EmpiricalCalibration::calibrateConfidenceInterval(
      logRr = est$logRr,
      seLogRr = est$seLogRr,
      model = mod
    ) %>%
      dplyr::mutate(
        database = databases[i]
      )
  )
  
}

