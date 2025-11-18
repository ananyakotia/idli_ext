* Purpose: To clean data at the household-level for 2007-08 (July-June)                  

*** ---------------------------------------------------------------------------
*** Block 1-3: Household Records
*** ---------------------------------------------------------------------------

* Loading the household level dataset
use Key_hhold Rec_id Sector State_Region state District /// Common variables
	B3_q1 B3_Q4 B3_q5 B3_q6 B3_q17 /// Native variables
	wgt_combined /// Weight combined
	using "$nss_lab/raw/2007/extracted dta files/Block-3-household-characteristics-ecords", clear

* Renaming variables
rename *, lower
rename key_hhold			hh_key
rename state				st_code
rename district				dist_code
rename rec_id				block
rename b3_q1				hh_size
rename state_region			nss_region
rename b3_q6	 			caste	
rename b3_q5				religion
rename b3_q4				emp_type_hh1
rename b3_q17				total_exp_hh	
rename wgt_combined			weight

* Destringing variables
destring sector emp_type_hh1 religion caste total_exp_hh, replace

* Making Monethly expenditure per capita. Currently it is at household level
replace total_exp_hh = total_exp_hh/hh_size

* Saving the dataset
save "$nss_lab/intermediate/Blk_hc_2007", replace


