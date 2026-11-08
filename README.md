# Dual-ICMS

This repository contains the source code and processed data associated with the manuscript:

**Single-Cell and Population-Level Neuromodulation Dynamics in Dual-Electrode Intracortical Stimulation**

Kayeon Kim *et al.*  
https://doi.org/10.1101/2025.06.25.661479

## Repository contents

- MATLAB analysis scripts for generating the main result figures (MATLAB R2022a)
- Processed calcium imaging datasets
- Source empirical data underlying the main figures
- Files that are related to empirical analysis include as below:
- Fig2_main.m   (all_cell.mat)
- Fig3C_D_main.m  (Fig3C_E1_source_data.mat, Fig3E_source_data.mat)
- Fig4_main.m (Fig4_distanceToA.mat, Fig4_distanceToB.mat)

- Deep learning analysis scripts

## Computational modeling

The spiking cortical network model used in this study is available in a separate GitHub repository:

https://github.com/kayeonlo/Dual-ICMS-visual-cortex


## Deep Learning analysis
- ML_README.txt
- ML_Requirements.txt

Related codes are as below:

- Bimodal full analysis.ipynb
- Pre-processing.m
- X_coords.mat
- X_final_final_final.mat
- Y_response_no_subtraction.mat


## Reproducibility

The processed data and analysis scripts provided in this repository are sufficient to reproduce all analyses and figures presented in the manuscript.

---
