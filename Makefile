data/processed/calibrateOverallResults.rds           : code/calibrateOverall.R\
	                                               data/raw/mappedOverallResultsNegativeControls.rds\
	                                               data/raw/mappedOverallResults.rds
	$<

data/processed/metaCalibrateOverall.rds              : code/metaCalibrateOverall.R\
	                                               data/processed/calibrateOverallResults.rds
	$<

data/processed/calibrateRiskStratified.rds           : code/calibrateRiskStratified.R\
	                                               data/raw/negativeControls.rds\
	                                               data/raw/mappedOverallRelativeResults.rds
	$<

data/processed/metaCalibrateRiskStratified.rds       : code/metaCalibrateRiskStratified.R\
	                                               data/processed/calibrateRiskStratified.rds
	$<

data/processed/hipFractureAbsolute.rds               : code/extractAbsoluteHip.R\
	                                               data/raw/mappedOverallAbsoluteResults.rds
	$<


figures/plotMeta.pdf figures/plotMeta.tiff figures/plotMeta.png &: code/plotMetaOverall.R\
	                                               data/processed/calibrateOverallResults.rds\
						       data/processed/metaCalibrateOverall.rds
	$<


figures/plotAbsoluteHip.pdf figures/plotAbsoluteHip.tiff figures/plotAbsoluteHip.png &: code/plotAbsoluteHip.R\
	                                               data/raw/mappedOverallAbsoluteResults.rds
	$<

submission/manuscript.pdf submission/manuscript.docx : submission/manuscript.rmd\
						       data/raw/incidenceOverall.rds\
	                                               data/processed/metaCalibrateOverall.rds\
						       data/processed/metaCalibrateRiskStratified.rds\
						       data/processed/calibrateRiskStratified.rds\
	                                               data/processed/hipFractureAbsolute.rds\
						       figures/plotMeta.pdf\
	                                               figures/plotAbsoluteHip.png\
						       submission/references.bib\
						       submission/jamia.csl
	R -e 'rmarkdown::render("submission/manuscript.rmd", output_format = "all")'

