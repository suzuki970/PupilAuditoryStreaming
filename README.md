## Experimental data for *"Temporal dynamics of auditory bistable perception correlated with fluctuation of baseline pupil size"*
Copyright 2021 Yuta Suzuki


## Requirements
Python
- pre-peocessing (**'/[Python]PreProcessing/PupilAnalysisToolbox'**)
- numpy
- scipy
- os
- json

R
- library(rjson)
- library(ggplot2)
- library(ggpubr)
- library(Cairo)
- library(gridExtra)
- library(effsize)
- library(BayesFactor)
- library(rjson)
- library(reshape)
- library(lme4)
- library(permutes)

## Raw data
raw data can be found at **'[Python]PreProcessing/Exp1/results'** and  **'[Python]PreProcessing/Exp2/results'**

## Pre-processing
- Raw data (.asc) are pre-processed by **'[Python]PreProcessing/Exp1/parseData.py'**

	- Pre- processed data is saved as **‘data_original_xx.json’**
	- xx changes depending on the analysis mode (e.g., mm or z-scored)
	
- Artifact rejection and data epoch are performed by **'[Python]PreProcessing/Exp1/dataAnalysis.py'**

## Figure and statistics
- *‘[Rmd]Results/figure.Rmd’* and *‘[Rmd]Results/results.Rmd’* are to generate figures and statistical results.


### Article information

