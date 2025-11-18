* Purpose: To clean data at the person-level for year 1999                   

*** ---------------------------------------------------------------------------
*** Block 1-3: Household Records
*** ---------------------------------------------------------------------------

* Loading the household levele dataset
use ///
	Key_hhold Rec_id Sector State_Region State District /// Common variables
	B3_q1 B3_q4 B3_q5 B3_q6 B3_q8 /// Native variables
	wgt_combined /// Multiplier combined
	using "$nss_lab/raw/2003/extracted dta files/Block-3-Household-characteristics-records.dta", clear

* Apply harmonized naming convention
rename *, lower
rename key_hhold 		hh_key
rename rec_id 			block 
rename state_region 	nss_region
rename state			st_code
rename district			dist_code
rename b3_q1 			hh_size
rename b3_q6 			caste			
rename b3_q5 			religion
rename b3_q4			emp_type_hh1
rename b3_q8			total_exp_hh	
rename wgt_combined		weight

* Destringing variables
destring sector emp_type_hh1 religion caste total_exp_hh, replace

* Making Monthly expenditure per capita. Currently it is at household level
replace total_exp_hh = total_exp_hh/hh_size

* Saving the dataset
save "$nss_lab/intermediate/Blk_hc_2004a", replace
