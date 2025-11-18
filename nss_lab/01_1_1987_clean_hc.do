* Purpose: To clean data at the person-level for year 1987                          

*** ---------------------------------------------------------------------------
*** Block 1-3: Household Records
*** ---------------------------------------------------------------------------

* Loading the household levele dataset
use ///
	Hhold_key Sector State Region District /// Common variables
	B3_q1_Hhsize B3_q3 B3_q4_Relgn B3_q5_Hgrup B3_q7 B3_q19  /// Native variables
	Wgt4_pooled /// Weight variable- Sub-round pooled
	using "$nss_lab/raw/1987/extracted dta files/Block-1-3-Household-Records.dta", clear

* Renaming variables
rename *, lower
rename b3_q1_hhsize		hh_size
rename hhold_key 		hh_key
rename b3_q3 			emp_type_hh1
rename state			st_code
rename district			dist_code
rename b3_q4_relgn	 	religion
rename b3_q5_hgrup	 	caste 
rename b3_q7			land_owned // (in 0.00 hectares) 
rename b3_q19 			total_exp_hh
rename wgt4_pooled		weight

* Destringing variables
replace caste = "." if caste == ";" 
destring sector emp_type_hh1 religion caste total_exp_hh hh_size, replace

* Generating nss region variable
gegen nss_region = concat(st_code region)

* Dropping hh_key duplicates
bys hh_key: gen dup = cond(_N==1,0,_n)
drop if dup> 1
drop dup

* Saving the dataset
save "$nss_lab/intermediate/Blk_hc_1987", replace

