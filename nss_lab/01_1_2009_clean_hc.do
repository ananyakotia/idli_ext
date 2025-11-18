* Purpose: To clean data at the household-level for 2009-10 (July-June)                  

*** ---------------------------------------------------------------------------
*** Block 1-3: Household Records
*** ---------------------------------------------------------------------------

* Loading the household level dataset
use ///
	HHID State Sector State_Region District /// Common variables
	Religion Social_Group Household_Type HH_Size Land_Owned /// Native variables
	WEIGHT /// 	weight to attach while all sub-round combined estimation
	using "$nss_lab/raw/2009/extracted dta files/Block_3_Household characteristics", clear

* Renaming variables
rename *, lower	
rename hhid					hh_key
rename state				st_code
rename district				dist_code
rename state_region			nss_region
rename social_group	 		caste	
rename household_type		emp_type_hh1

* Destringing variables
destring sector emp_type_hh1 religion caste hh_size, replace

* Saving the dataset
save "$nss_lab/intermediate/Blk_hc_2009", replace



