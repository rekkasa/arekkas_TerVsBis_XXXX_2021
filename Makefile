submission/submission.pdf : submission/submission.rmd
	R -e 'rmarkdown::render("submission/submission.rmd", output_format = "all")'

submission/submission.docx : submission/submission.rmd
	R -e 'rmarkdown::render("submission/submission.rmd", output_format = "all")'
