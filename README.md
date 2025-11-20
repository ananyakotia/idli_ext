# India Data Lab Initiative (IDLI)

## Overview
The India Data Lab Initiative (IDLI) harmonizes India’s flagship household and firm surveys so researchers can work with consistent, analysis-ready microdata. By standardizing layouts, reconciling evolving classification systems, and validating outputs against official benchmarks, the lab lowers the fixed cost of using datasets such as the National Sample Surveys (NSS) and the Annual Survey of Industries (ASI).

This repository provides a standardized, reproducible Stata-based pipeline for processing and cleaning publicly available NSS labour, NSS consumption, NSS enterprise and ASI datasets.{**ASI, NSS enterprise and NSS consumption datasets which are currently being cleaned and validated will be released soon**}. The goal of this project is to make high-quality, fully cleaned, analysis-ready datasets easily accessible to:

- Researchers  
- Academicians  
- Policy analysts    
- Students and data users  

The scripts convert publicly available raw data into consistent, harmonized, clean `.dta` outputs, ensuring that users can directly begin analysis without spending time on data wrangling.

## Key Features
1. Fully automated data cleaning and data processing pipeline  
2. Generates standardized clean `.dta` files  
3. Master do-files allow one-click end-to-end execution
4. Modular script structure (extract → clean → process → validate)  
5. Compatibility across systems — users only update their paths, not the code  
6. Ensures consistency, reproducibility, and minimal manual intervention

## Repository layout for NSS Labour Dataset (1987 – 2011)

This repository titled `idli_ext` contains the full codebase for cleaning, harmonizing, and preparing the NSS Labour datasets for the years **1987 to 2011**.  

idli_ext
└── code
└── nss
└── nss_lab

Within the `nss_lab` folder, there are multiple do files: 

1. 00_master_nss_lab.do                         # This is the master script, it runs the entire pipeline
2. Household-level cleaning scripts(*_hc)       # These are multiple .do files for cleaning household level NSS labor datasets for years 1987-2011
3. Person-level cleaning scripts (*_pc)         # These are multiple .do files for cleaning personal level NSS labor datasets for years 1987-2011
4. Harmonization scripts                        # These are multiple .do files for district, industry and occupation code harmonization

Additionally, there is: 

1. A **preamble** file located in the `nss` folder that initializes the coding environment to configure paths, install packages, and register shared directories
2. A **district concordance** folder in the `nss` folder used for harmonizing district identifiers across survey rounds.
                                       
**NOTE**: Household-level cleaning scripts (HC) and Person-level cleaning scripts (PC) are for cleaning the micro datasets, as an user you don't need to execute them separately. The ***Master do-files run the entire workflow.***

**Please note that, similar datasets for ASI (Annual Survey of Industries), NSS (National Sample Surveys) Consumption, and NSS enterprise will be uploaded soon on the IDLI website. The README file will get updated accordingly.**

## How to Use the Code

### Download Raw Data

Raw NSS and ASI datasets (CSV and DTA) are publicly available on the MOPSI and IDLI website (https://www.idli.dev/). Download them and store them anywhere (**preferably `Documents` folder**) on your system.

### Clone `idli_ext` GitHub repository 

Clone the repository and place it inside the shared directory referenced by your `global root` (e.g., Dropbox or OneDrive) so the relative paths defined in `00_preamble.do` resolve correctly.

### Set Your System Path

In the provided preamble script, simply enter **your local system** path ("C:/Users/username\_as\_per\_your\_system" OR "/users/username\_if\_using\_a\_mac\_device/Documents") where the raw datasets are stored.

You DO NOT need to:

- edit code logic  
- modify global macros  
- change any processing steps  

Only update the required path location where indicated.
 
### Run the master do-file on Stata

Open Stata and run the master script: do `00_master_nss_lab.do`

This will:

1. Check/install required packages (if enabled in preamble)
2. Run year-specific household and person cleaning scripts
3. Apply variable harmonization and code mappings
4. Validate outputs and export .dta and .csv files into the output folder

### Check outputs
After the master run completes, go to your output folder and verify if a `nss_lab_final.dta` dataset is saved. 

Note: District concordance spreadsheet in `documentation/district_concordance/` are imported directly by the Stata code to reconcile NSS labor district codes before merging or validation.

### How to run only part of the pipeline
If you only want to run one round’s person or household cleaning (without running everything), run that specific file after running the preamble:

do `01_1_2007_clean_hc.do`   // household for 2007
do `01_2_2007_clean_pc.do`   // person for 2007

Important:*Only run individual scripts for inspection or validation. Do not modify them.*

## Requirements 
1. Stata 17 or higher
2. Basic system path defined by the user  
3. Raw data downloaded from the MOPSI/IDLI website 
4. Internet connection optional (only for installing missing SSC packages)

All required Stata packages — including `gtools`, `reghdfe`, `grstyle`, `palettes`, `distinct`, `ftools`, `mipolate`, `nicelabels`, and others are automatically checked and installed in the script.

Users may install additional packages locally, **but project scripts should remain unchanged.**

## Best practices & rules 
1. Do not modify the cleaning scripts — edits will break consistency across years and across users.
2. Only change the small USER CONFIG block in 00_master_nss_lab.do that sets paths.
3. Keep raw data outside the repo (e.g., in ~/data/NSS_raw/) and keep outputs in ~/data/NSS_working/.
4. Add outputs/, raw data folders, and .dta files to .gitignore.

If you must change a script for research, make a personal copy and document the changes — but do not commit those changes to the main pipeline.

## Troubleshooting

1. **Missing Packages**
If any required package is missing, install it using:
*ssc install <package-name>*
eg.`ssc install gtools`, `ssc install reghdfe`, `ssc install nicelabels`

2. **Path Errors**
Make sure your system path uses correct formatting:

Windows:
*"C:/Users/username/Documents/..."*

Mac:
*"/Users/username/Documents/..."*

Linux:
*"/home/username/..."*

3. **Large File Warning**
For large NSS/ASI files, Stata may require:
*set excelxlsxlargefile on*
(This is already included in the script.)

## Best Practices
1. Always use the master do-file for full processing.
2. Use individual scripts (e.g. `code\nss\nss_lab\01_variable_clean.do`) only for reviewing logic.
3. Never change script structure, variable definitions, or processing rules.
4. Store raw and processed data in clearly separated directories.

*This project is maintained by the IDLI research and data engineering team.*

## License
This project uses publicly available NSS datasets.
Processed datasets and scripts follow IDLI licensing and documentation standards.

## Team
- **Ananya Kotia** – Founder and Director  •  [www.ananyakotia.com](https://www.ananyakotia.com)
- **Bharat Singhal** – Research Associate
- **Naila Fatima** – Research Associate (2023–25)
- **Bommi Reddy Meghana Vardhan** – Research Manager
- **Ayush Chaudhary** – Research Associate

## Contributing
1. Fork the repository and create a feature branch.
2. Run the relevant master script(s) and validation routines to ensure harmonized outputs remain consistent.
3. Submit a pull request summarizing the methodological change, affected rounds, and validation evidence.

Users may:
Submit issues
Suggest enhancements
Contribute documentation

However, core scripts must not be altered under any circumstances to maintain pipeline integrity.

Private raw data are **not** stored in this repository; only code and documentation needed to reproduce the harmonized releases are included.