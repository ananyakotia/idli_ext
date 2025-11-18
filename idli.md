# idli

Code base for the India Data Lab



NSS \& ASI Data Processing Pipeline (Stata)



Overview



This repository provides a standardized, reproducible Stata-based pipeline for processing and cleaning publicly available NSS and ASI datasets.  

The goal of this project is to make high-quality, fully cleaned, analysis-ready datasets easily accessible to:



\- Researchers  

\- Academicians  

\- Policy analysts    

\- Students and data users  



The scripts convert publicly available raw data into consistent, harmonized, clean `.dta` and `.csv` outputs, ensuring that users can directly begin analysis without spending time on data wrangling.





Key Features



\- Fully automated data cleaning and data processing pipeline  

\- Generates standardized clean `.dta` and `.csv` files  

\- Master do-files allow one-click end-to-end execution

\- Modular script structure (extract → clean → process → validate)  

\- Compatibility across systems — users only update their paths, not the code  

\- Ensures consistency, reproducibility, and minimal manual intervention





Repository Structure



project\_root/

├── NSS/

│ ├── 01\_extract.do

│ ├── 02\_clean.do

│ ├── 03\_process.do

│ ├── 04\_validate.do

│ └── master\_nss.do

│

├── ASI/

│ ├── 01\_extract.do

│ ├── 02\_clean.do

│ ├── 03\_process.do

│ ├── 04\_validate.do

│ └── master\_asi.do

│

└── README.md





Master do-files run the entire workflow.  

Individual scripts may be executed for validation, **but must not be altered**.



---



Requirements



\- Stata 15 or higher  

\- Basic system path defined by the user  

\- Raw data (NSS or ASI) downloaded from the **IDLI website**

\- Internet connection optional (only for installing missing SSC packages)



All required Stata packages — including `gtools`, `reghdfe`, `grstyle`, `palettes`, `distinct`, `ftools`, `mipolate`, `nicelabels`, and others — are automatically checked and installed in the script.  

Users may install additional packages locally, **but project scripts should remain unchanged.**







How to Use the Code



Step 1: Download Raw Data



Raw NSS and ASI datasets (CSV and DTA) are publicly available on the IDLI website and MOSPI website. (links to be added) 

Download them and store them anywhere (preferably documents folder) on your system.



Step 2: Set Your System Path



In the provided preamble script, simply enter **your local system** path ("C:/Users/username\_as\_per\_your\_system" OR "/users/username\_if\_using\_a\_mac\_device/Documents") where the raw datasets are stored.



You DO NOT need to:

\- edit code logic  

\- modify global macros  

\- change any processing steps  



Only update the required path location where indicated.



Step 3: Run the Master Do-File



Each dataset folder has its own master script.



For NSS:



```stata



*do master\_nss.do*



This will:



Import raw data



Clean variables



Process and transform data



Standardize formats



Validate structure and consistency



Export final .dta and .csv files





Step 4: Access Output Files



After running the master scripts, the pipeline produces:



clean\_nss.dta



clean\_nss.csv



clean\_asi.dta



clean\_asi.csv





These are fully processed datasets ready for statistical analysis in:



Stata



R



Python



Excel



PowerBI / Tableau



Any analytical environment





Important Usage Notes



**Do NOT modify any script**.



Editing the .do files will break consistency, cause compile errors, and lead to incorrect processing.



All necessary package installation checks are handled internally.



Users may install packages locally on their system, but project scripts should not be changed.



Master do-files must always be run without modification to ensure reproducibility.



Troubleshooting



1\. Missing Packages



If any required package is missing, install it using:



*ssc install <package-name>*





2\. Path Errors



Make sure your system path uses correct formatting:



Windows:



*"C:/Users/username/Documents/..."*





Mac:



*"/Users/username/Documents/..."*





Linux:



*"/home/username/..."*





3\. Large File Warning



For large NSS/ASI files, Stata may require:



*set excelxlsxlargefile on*





(This is already included in the script.)







Best Practices





Always use the master do-file for full processing.



Use individual scripts (e.g., 02\_clean.do) only for reviewing logic.



Never change script structure, variable definitions, or processing rules.



Store raw and processed data in clearly separated directories.





Contact \& Contributions



*This project is maintained by the IDLI research and data engineering team.*





Users may:



Submit issues



Suggest enhancements



Contribute documentation



However, core scripts must not be altered under any circumstances to maintain pipeline integrity.





License



This pipeline uses publicly available NSS and ASI datasets.

Processed datasets and scripts follow IDLI licensing and documentation standards.

