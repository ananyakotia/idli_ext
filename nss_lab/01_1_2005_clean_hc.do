* Purpose: To clean data at the household-level for 2005-06 (July-June)                  

*** ---------------------------------------------------------------------------
*** Block 1-3: Household Records
*** ---------------------------------------------------------------------------

* Loading the household level dataset
use Hhold_key Sector State Region District /// Common variables
	B3_q1 B3_q4 B3_q5 B3_q6 B3_q15 /// Native variables
	WGT_Comb /// Weight combined
	using "$nss_lab/raw/2005/extracted dta files/Block-3-Household-Characteristics-records", clear

* Generating NSS region
gegen nss_region = concat(State Region)

* Renaming variables
rename *, lower
rename hhold_key			hh_key
rename state				st_code
rename district				dist_code
rename b3_q1				hh_size
rename b3_q6	 			caste	
rename b3_q5				religion
rename b3_q4				emp_type_hh1
rename b3_q15				total_exp_hh	
rename wgt_comb				weight

* Destringing variables
destring sector emp_type_hh1 religion caste total_exp_hh hh_size, replace

* Making Monethly expenditure per capita. Currently it is at household level
replace total_exp_hh = total_exp_hh/hh_size

* Saving the dataset
save "$nss_lab/intermediate/Blk_hc_2005", replace
