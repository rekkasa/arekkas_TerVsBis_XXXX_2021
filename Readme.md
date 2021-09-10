# Treatment heterogeneity in comparative effectiveness of teriparatide vs bisphosphonates: a multi-database cohort study

![front](https://github.com/rekkasA/osteoporosis/blob/main/figures/plotMeta.png)

## About
**Background**: Bisphosphonates are first-line treatments to prevent osteoporotic fractures. Teriparatide has been recently shown to be more effective in a head-to-head RCT and is currently used for more severe cases.

**Objectives**: To study the comparative effectiveness of teriparatide vs bisphosphonates to reduce hip fracture risk. In addition, we stratified by predicted risk to assess treatment effect heterogeneity.

**Diagnostics**: Cohort diagnostics on the considered databases can be found [here](https://arekkas.shinyapps.io/ter_bis_diagnostics/).

**Results**: The most recent results of the analyses can be explored [here](https://arekkas.shinyapps.io/ter_bis_3dbs/).

## Directory structure
```bash
├── arekkas_TerVsBis_XXXX_2021.Rproj
├── code
│   ├── calibrateOverall.R
│   ├── calibrateRiskStratified.R
│   ├── extractAbsoluteHip.R
│   ├── metaCalibrateOverall.R
│   ├── metaCalibrateRiskStratified.R
│   ├── plotAbsoluteHip.R
│   └── plotMetaOverall.R
├── data
│   ├── processed
│   └── raw
├── DESCRIPTION
├── extras
│   ├── init.R
│   └── init.sh
├── figures
│   ├── plotAbsoluteHip.pdf
│   ├── plotAbsoluteHip.png
│   ├── plotAbsoluteHip.tiff
│   ├── plotMeta.pdf
│   ├── plotMeta.png
│   └── plotMeta.tiff
├── LICENSE
├── Makefile
├── out.html
├── Readme.md
└── submission
    ├── jamia.csl
    ├── manuscript.docx
    ├── manuscript.pdf
    ├── manuscript.rmd
    ├── reference.docx
    └── references.bib
```
