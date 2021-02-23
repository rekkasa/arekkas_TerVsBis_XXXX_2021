library(dplyr)

# filePath <- "/home/arekkas/Documents/Projects/osteoporosis/meta"
# files <- list.files(
#   path = filePath,
#   full.names = TRUE
# )
# 
# res <- data.frame()
# for (file in seq_along(files)) {
#   res1 <- readRDS(files[file])
#   res <- rbind(res, res1)
# }
# 

overallNegativeControls <- readRDS(
  "/home/arekkas/Documents/Projects/osteoporosis/multipleRseeAnalyses/Data/mappedOverallResultsNegativeControls.rds"
)
overallMappedOverallRelativeResults <- readRDS(
  "/home/arekkas/Documents/Projects/osteoporosis/multipleRseeAnalyses/Data/mappedOverallResults.rds"
)
databases <- unique(overallNegativeControls$database)

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

# analyze <- res %>%
#   # dplyr::filter(
#     # outcomeId == 101,
#     # analysisType == "matchOnPs_1_to_4",
#   # ) %>%
#   dplyr::select(
#     logRr, seLogRr, database, analysisType
#   )

pp = meta::metagen(
  TE = res$logRr,
  seTE = res$seLogRr,
  sm = "HR",
  method.tau = "PM",
  studlab = res$database,
  title = "Hip fracture"
)

meta::forest(
  pp,
  studlab = res$database,
  comb.fixed = FALSE,
  text.random = "Overall effect",
  leftcols = c("studlab")
)



negativeControls <- readRDS(
  "/home/arekkas/Documents/Projects/osteoporosis/multipleRseeAnalyses/Data/negativeControls.rds"
) %>%
  dplyr::rename(
    "estimate" = "HR"
  )

results <- readRDS(
  "/home/arekkas/Documents/Projects/osteoporosis/multipleRseeAnalyses/Data/mappedOverallRelativeResults.rds"
)
id <- 103

resTmp <- results %>%
  dplyr::filter(
    stratOutcome == id,
    estOutcome == id,
    riskStratum == "Q4",
    analysisType == "matchOnPs_1_to_4"
  )

res <- data.frame(
  logRr = numeric(),
  logLb95Rr = numeric(),
  logUb95Rr = numeric(),
  seLogRr = numeric(),
  database = character()
)

for (i in seq_along(databases)) {
  ncs <- negativeControls %>%
    dplyr::filter(
      analysisType == "matchOnPs_1_to_4", 
      database == databases[i],
      riskStratum == "Q4"
    ) %>%
    dplyr::mutate(logRr = log(estimate))
  
  mod <- EmpiricalCalibration::fitSystematicErrorModel(
    logRr =  ncs$logRr,
    seLogRr = ncs$seLogRr,
    trueLogRr = rep(0, nrow(ncs))
  )
  
  est <- resTmp %>%
    dplyr::filter(
      analysisType == "matchOnPs_1_to_4",
      database == database[i],
      riskStratum == "Q4"
      ) %>%
    dplyr::mutate(logRr = log(estimate))
  
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

pp = meta::metagen(
  TE = res$logRr,
  seTE = res$seLogRr,
  sm = "HR",
  method.tau = "PM",
  studlab = res$database,
  title = "Hip fracture"
)

png(
  "/home/arekkas/Documents/Projects/osteoporosis/meta/vertebral_vertebral.png",
  width = 600,
  height = 200
)
meta::forest(
  pp,
  studlab = res$database,
  comb.fixed = FALSE,
  text.random = "Overall effect",
  leftcols = c("studlab"),
  leftlabs = c("Database"),
  smlab = "Vertebral fracture",
  print.tau2 = FALSE,
  colgap.forest.left = "20mm",
  xlab.pos = 5
)
dev.off()
