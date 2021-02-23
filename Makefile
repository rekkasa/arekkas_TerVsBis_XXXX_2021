submission/manuscript.pdf submission/manunscript.docx : submission/manuscript.rmd
	R -e 'rmarkdown::render("submission/manuscript.rmd", output_format = "all")'
