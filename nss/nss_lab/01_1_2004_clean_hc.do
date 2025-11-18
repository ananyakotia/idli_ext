* Purpose: To clean data at the household-level for 2004-05 (July-June)                  

*** ---------------------------------------------------------------------------
*** Block 1-3: Household Records
*** ---------------------------------------------------------------------------

* Loading the household level dataset
use HHID Round Sector State_region District STATE_CODE /// Common variables
	RELIGION SOCIAL_GRP MPCE Household_type_code HH_SIZE LAND_OWNED /// Native variables
	WEIGHT_COMBINED /// Weight combined
	using "$nss_lab/raw/2004/extracted dta files/Block_1_2_and_3_level_01.dta", clear

* Renaming variables
rename *, lower
rename hhid		 			hh_key
rename state_code			st_code
rename district				dist_code
rename state_region 		nss_region
rename social_grp 			caste			
rename household_type_code	emp_type_hh1
rename mpce					total_exp_hh	
rename weight_combined		weight

* Destringing variables
destring sector emp_type_hh1 religion caste total_exp_hh hh_size, replace

* Making Monthly expenditure per capita. Currently it is at household level
replace total_exp_hh = total_exp_hh/hh_size

* Saving the dataset
save "$nss_lab/intermediate/Blk_hc_2004b", replace
