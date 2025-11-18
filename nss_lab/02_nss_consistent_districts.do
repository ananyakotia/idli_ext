/*

	Purpose: Merges NSS labour data with district_names data to bring district_names_91. Merges
			  has been done on round x st_code x dist_code x nss_region variables.

*/

* 1. CLEANING THE DISTRICT NAMES FILE
	
	* Loading and Cleaning Districts file 
	import excel using "$idl_git/documentation/district_concordance/nss_lab_district.xlsx", firstrow clear 
	
	drop if nss_round == 38 // dropping years 1983 which doesn't have district codes

	* Converting to lower case
	foreach var in st_name_1991 dist_name_1991 {
	    replace `var' = lower(`var')
		replace `var' = ustrtrim(`var')
	}

	/* To make consistent district names, district names for all the years have been been given respective 1991 district name. 
	In the above excel file, given that data is unique at nss_round X st_code X dist_code X nss_region, we are adding nss_round in the excel
	to merge the datasets. */
	
	**Round 60 and 61 have similar NSS regions, so we fill the nss regions for round 61 similar to the ones in round 60
	preserve
	
	keep if nss_round == 60 | nss_round == 61
	
	*For each district we take the non missing value of nss_region code and name
	bysort st_code dist_code (nss_region): egen nss_region_60 = max(nss_region) 
	bysort st_code dist_code (nss_region): gen nss_region_name_60 = nss_region_name[1]

	*Replace missing values
	replace nss_region = nss_region_60 if missing(nss_region)	
	replace nss_region_name = nss_region_name_60 if nss_region_name == ""
	
	drop nss_region_60 nss_region_name_60
	
	keep if nss_round == 61
	
	tempfile nss_region_60
	save `nss_region_60'
	
	restore
	
	*Merging the data with nss regiosn for round 61 with the original dataset we have for districts 
	merge m:1 nss_round st_code dist_code using `nss_region_60', update
	drop _merge

	duplicates drop // 2 obs dropped
	bys nss_round nss_region st_code dist_code: gen dup = cond(_N==1,0,_n)
	drop if dup >1 // 1 obs deleted 
	drop dup

	tempfile districts_91
	save `districts_91'

* 2. LOADING THE NSS LABOUR DATASET 
	use "$nss_lab/intermediate/nss_lab_clean.dta", clear

	*Dropping round 38 and 50 which don't have district codes
	drop if nss_round == 38 | nss_round == 50
		
	destring nss_region st_code dist_code, replace
			
	*Merging the district harmonization with the nss labour dataset 
	merge m:1 nss_round nss_region st_code dist_code using `districts_91', gen(dist_merge)
	
	keep if dist_merge == 3 // There are some unmerged from the nss labour dataset as the data for nss regions differs from what is tehre in the documentation
	drop dist_merge 
			
	*Saving the final dataset 
	save "$nss_lab/intermediate/nss_lab_dist_merge.dta", replace

