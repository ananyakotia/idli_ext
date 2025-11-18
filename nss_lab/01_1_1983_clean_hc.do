* Purpose: To clean data at the person-level for year 1983                           

*** ---------------------------------------------------------------------------
*** Block 1-3: Household Records
*** ---------------------------------------------------------------------------

use ///
	Hhold_key Sector State Region B3_q1_hh_size B3_q3 B3_q4_relgn B3_q5_hh_grup ///
	Wgt4_pooled /// Weight variable- Sub-round pooled
	using "$nss_lab/raw/1983/extracted dta files/Block-1-3-Household-records.dta", clear

* Renaming variables
rename *, lower
rename b3_q1_hh_size	hh_size
rename hhold_key 		hh_key
rename b3_q3 			emp_type_hh1
rename state			st_code
rename b3_q4_relgn	 	religion
rename b3_q5_hh_grup 	caste 
rename wgt4_pooled		weight

* Dropping hh_key duplicates
bys hh_key: gen dup = cond(_N==1,0,_n)
drop if dup> 1
drop dup

* Saving the dataset
save "$nss_lab/intermediate/Blk_hc_1983", replace

