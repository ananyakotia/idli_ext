* Purpose: To clean data at the person-level EUS for year 1993                    

*** ---------------------------------------------------------------------------
*** Block 4: Demographics and Usual Activity Status
*** ---------------------------------------------------------------------------

* Loading the dataset
use ///
	Hhold_Key Person_key Prsn_slno B4_q3  /// Common variables
	B4_q4 B4_q5 B4_q11 B4_q12 B4_q14 B4_q15 B4_q16 B4_q17 B4_q23 /// Native variables 
	WGT_Pooled 								   /// Weight variable- Sub-round pooled/sub-samples combined(0.00) 
	using "$nss_lab/raw/1993/extracted dta files/Block-4-Persons-Records", clear

* Renaming variables
rename *, lower
rename hhold_key	hh_key
rename prsn_slno	person_srl_no
rename b4_q3		relation_to_head
rename b4_q4 		sex
rename b4_q5		age 
rename b4_q11 		skill
rename b4_q12 		act_code
rename b4_q14 		nic_1987_3d
rename b4_q15 		nco_1968_3d
rename b4_q16 		work_location
rename b4_q17 		act_code_sub
rename b4_q23 		seeking_work
rename wgt_pooled	weight

* Destringing variables
destring age skill act_code work_location act_code_sub seeking_work work_location, replace

* Generating industry at the 2-digit level
gen nic_1987_2d = substr(nic_1987_3d,1,2)

* Clean industry codes:
*   - Remove spaces
*   - Drop records with placeholder characters (X, Y)
*   - Drop invalid or incomplete codes
replace nic_1987_3d = subinstr(nic_1987_3d, " ", "",.)
drop if regexm(nic_1987_3d, "x") | regexm(nic_1987_3d, "X") | regexm(nic_1987_3d, "Y") 
drop if strlen(nic_1987_3d)!= 3 & !mi(nic_1987_3d) 

* Save as a temporary file for later merge
tempfile pc
save `pc'

*** ---------------------------------------------------------------------------
*** Block 5: Weekly Activity Status
*** ---------------------------------------------------------------------------

* Load Block 4 dataset (demographics + current weekly activity)
use ///
	Hhold_Key Prsn_slno  /// Common variables
	B5_q3 B5_q4 B5_q3 B5_q7 B5_q8 B5_q9 B5_q10 B5_q11 B5_q12 B5_q13 B5_q14 B5_q15 B5_q16 B5_q17 B5_q19 B5_q20 B5_q21 /// Native variables 
	using "$nss_lab/raw/1993/extracted dta files/Block-5-Persons-Activity-Records", clear

* This block does not have person key so it is constructed by concatenating hhold key and perosn serial number 
gegen person_key = concat(Hhold_Key Prsn_slno)

drop Hhold_Key Prsn_slno

* Renaming variables
rename *, lower
rename b5_q3			cda_srl_no
rename b5_q4 			cdas
rename b5_q7 			cda_seventh 
rename b5_q8			cda_sixth
rename b5_q9 			cda_fifth
rename b5_q10 			cda_fourth
rename b5_q11 			cda_third
rename b5_q12			cda_second
rename b5_q13 			cda_first
rename b5_q14 			cda_no_of_days
rename b5_q15			wages_cash
rename b5_q16 			wages_kind			
rename b5_q17			wages_total
rename b5_q19			cwa_status
rename b5_q20			cwa_nic_1987_3d
rename b5_q21			cwa_nco_1968_3d

* Assert to check that they are constant across person key
foreach var of varlist cwa_status cwa_nic_1987_3d cwa_nco_1968_3d {
	bysort person_key: assert `var' == `var'[1]
}

* Dropping person_key duplicates
bys person_key cda_srl_no (cdas): gen dup = cond(_N==1,0,_n) // for the same person key there are different ages and current daily activity status
drop if dup> 0 & cdas == "" // Dropping only if there is no code for current daily activity status code
drop dup

*there are still some dupliactes remaining as there are different cdas for a given person key and activity serial number
bys person_key cda_srl_no: gen dup = cond(_N==1,0,_n) // for the same person key there are different ages and current daily activity status
drop if dup> 1
drop dup

* Reshape daily activity data from long to wide format
reshape wide cdas cda_seventh cda_sixth cda_fifth cda_fourth cda_third cda_second cda_first cda_no_of_days wages_cash wages_kind wages_total, i(person_key cwa_status cwa_nic_1987_3d cwa_nco_1968_3d) j(cda_srl_no) string

* Merge daily activity with demographics + usual activity dataset
merge 1:1 person_key using `pc'
drop _merge

*** ---------------------------------------------------------------------------
*** Merge with Household Characteristics
*** ---------------------------------------------------------------------------

* Merge household-level characteristics to person-level dataset
merge m:1 hh_key using "$nss_lab/intermediate/Blk_hc_1993"
count if _merge !=3
//qui assert `r(N)' < 10 // to ensure quality of merge
drop _merge 

/*
	   Result                      Number of obs
	   -----------------------------------------
	   Not matched                             3
	   from master                         3  (_merge==1)
	   from using                         	0  (_merge==2)

	   Matched                           564,369  (_merge==3)
*/ 


save "$nss_lab/intermediate/Blk_merged_1993.dta", replace



