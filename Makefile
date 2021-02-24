data/processed/calibrateOverallResults.rds : code/calibrateOverall.R\
	                                     data/raw/mappedOverallResultsNegativeControls.rds\
	                                     data/raw/mappedOverallResults.rds
	$<

data/processed/metaCalibrateOverall.rds : code/metaCalibrateOverall.R\
	                                  data/processed/calibrateOverallResults.rds
	$<

submission/manuscript.pdf submission/manunscript.docx : submission/manuscript.rmd\
	                                                data/processed/metaCalibrateOverall.rds
	R -e 'rmarkdown::render("submission/manuscript.rmd", output_format = "all")'

