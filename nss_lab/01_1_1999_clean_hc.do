* Purpose: To clean data at the person-level for year 1999                   

*** ---------------------------------------------------------------------------
*** Block 1-3: Household Records
*** ---------------------------------------------------------------------------

* Loading the household levele dataset
use ///
	RecID Sector State Region District fsu_no Visit_no Seg_no Stg2_stratm Hhhold_Slno /// Common variables
	B3_q2 B3_q3 B3_q4 B3_q5 B3_q6 /// Native variables 
	Wgt_SR_comb 								   /// Weight variable- Sub-round pooled/sub-samples combined(0.00) 
	using "$nss_lab/raw/1999/extracted dta files/Block3-sch10--Household-Characteristics-records", clear

* Generating hh_key because the hh_key variable in the person dataset is of 11 width but the hh char block has width 13
gegen hh_key = concat(fsu_no Visit_no Seg_no Stg2_stratm Hhhold_Slno)

drop fsu_no Visit_no Seg_no Stg2_stratm Hhhold_Slno

* Renaming variables
rename *, lower
rename recid 			block 
rename state			st_code
rename district			dist_code
rename b3_q2 			caste			
rename b3_q3 			religion
rename b3_q4			emp_type_hh1
rename b3_q5 			total_exp_hh
rename b3_q6 			land_owned // (in 0.00 hectares)
rename wgt_sr_comb		weight

* Destringing variables
destring sector emp_type_hh1 religion caste total_exp_hh, replace

* Generating the nss region variable by concatenating state and region variables
gegen nss_region = concat(st_code region)

* Saving the dataset
save "$nss_lab/intermediate/Blk_hc_1999", replace
