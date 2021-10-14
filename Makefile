data/processed/calibrateOverallResults_age_50_tr_1_q_25_75.rds           : code/calibrateOverall.R\
	                                                                   data/raw/mappedOverallResultsNegativeControls.rds\
	                                                                   data/raw/mappedOverallResults.rds
	$< age_50_tr_1_q_25_75 ccae optum_ehr optum_extended_dod

data/processed/metaCalibrateOverall_age_50_tr_1_q_25_75.rds    : code/metaCalibrateOverall.R\
	                                                         data/processed/calibrateOverallResults_age_50_tr_1_q_25_75.rds
	$< age_50_tr_1_q_25_75 

data/processed/calibrateRiskStratified_age_50_tr_1_q_25_75.rds : code/calibrateRiskStratified.R\
	                                                         data/raw/negativeControls.rds\
	                                                         data/raw/mappedOverallRelativeResults.rds
	$< age_50_tr_1_q_25_75 ccae optum_ehr optum_extended_dod

data/processed/metaCalibrateRiskStratified_age_50_tr_1_q_25_75.rds : code/metaCalibrateRiskStratified.R\
	                                                             data/processed/calibrateRiskStratified_age_50_tr_1_q_25_75.rds
	$< age_50_tr_1_q_25_75 

data/processed/calibrateRiskStratified_age_50_tr_1_gl.rds : code/calibrateRiskStratified.R\
	                                                         data/raw/negativeControls.rds\
	                                                         data/raw/mappedOverallRelativeResults.rds
	$< age_50_tr_1_gl optum_ehr optum_extended_dod

data/processed/metaCalibrateRiskStratified_age_50_tr_1_gl.rds : code/metaCalibrateRiskStratified.R\
	                                                        data/processed/calibrateRiskStratified_age_50_tr_1_gl.rds
	$< age_50_tr_1_gl 

data/processed/hipFractureAbsolute.rds               : code/extractAbsoluteHip.R\
	                                               data/raw/mappedOverallAbsoluteResults.rds
	$<


figures/plotMeta.pdf figures/plotMeta.tiff figures/plotMeta.png &: code/plotMetaOverall.R\
	                                               data/processed/calibrateOverallResults_age_50_tr_1_q_25_75.rds\
						       data/processed/metaCalibrateOverall_age_50_tr_1_q_25_75.rds
	$<


figures/plotAbsoluteHip.pdf figures/plotAbsoluteHip.tiff figures/plotAbsoluteHip.png &: code/plotAbsoluteHip.R\
	                                               data/raw/mappedOverallAbsoluteResults.rds
	$<

submission/manuscript.pdf : submission/manuscript.rmd\
						       submission/references.bib\
						       submission/jamia.csl
	R -e 'rmarkdown::render("submission/manuscript.rmd", output_format = "all")'

