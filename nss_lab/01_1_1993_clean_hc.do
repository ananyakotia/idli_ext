* Purpose: To clean data at the person-level for year 1993                        

*** ---------------------------------------------------------------------------
*** Block 1-3: Household Records
*** ---------------------------------------------------------------------------

* Loading the household levele dataset
use ///
	Hhold_Key Round Sector State Region /// Common variables
	B3_q3 B3_q4_relgn_cd B3_q5_sgrup_Cd B3_q20 B3_q1_hh_size /// Native variables 
	WGT_Pooled 								   /// Weight variable- Sub-round pooled/sub-samples combined(0.00) 
	using "$nss_lab/raw/1993/extracted dta files/Block-1-3-Household-Records.dta", clear

* Renaming variables
rename *, lower
rename hhold_key 		hh_key
rename b3_q1_hh_size	hh_size
rename round 			nss_round
rename state			st_code
rename b3_q3 			emp_type_hh1
rename b3_q4_relgn_cd 	religion
rename b3_q5_sgrup_cd 	caste
rename b3_q20 			total_exp_hh
rename wgt_pooled		weight

* Destringing variables
destring nss_round sector emp_type_hh1 religion caste total_exp_hh hh_size, replace

* Saving the dataset
save "$nss_lab/intermediate/Blk_hc_1993", replace






