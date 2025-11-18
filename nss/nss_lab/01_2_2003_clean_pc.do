* Purpose: To clean data at the person-level EUS for year 2004 (Jan-June)                  


*** ---------------------------------------------------------------------------
*** Block 4: Demographics + Usual Activity Status
*** ---------------------------------------------------------------------------

* Loading the dataset
use ///
	Key_memb Key_hhold Record_id /// Common variables
	B4_c1 B4_c3 B4_c4 B4_c5 B4_c6 B4_c7 B4_c8 B4_c9 B4_c10 B4_c11 B4_c12 B4_c13 B4_c14 B4_c15 /// Native variables
	wgt_combined /// Multiplier combined
	using "$nss_lab/raw/2003/extracted dta files/Block-4-Demographic-usual- activity-members-records", clear


* Apply harmonized naming convention
rename *, lower
rename key_memb 		person_key
rename key_hhold 		hh_key
rename record_id 		block
rename b4_c1 			person_srl_no
rename b4_c3			relation_to_head 
rename b4_c4 			sex
rename b4_c5			age 
rename b4_c6			marital_status 
rename b4_c7			gen_edu_raw
rename b4_c8			tech_edu_raw
rename b4_c9 			act_code
rename b4_c10 			nic_1998_5d
rename b4_c11 			nco_1968_3d
rename b4_c12 			act_code_sub 
rename b4_c13			sub_act_status 
rename b4_c14			sub_nic_1998_5d 
rename b4_c15			sub_nco_1968_3d 
rename wgt_combined		weight

* Destringing variables
destring age act_code act_code_sub, replace

gen nic_1998_4d = substr(nic_1998_5d,1,4)
gen nic_1998_3d = substr(nic_1998_5d,1,3)

* Save as a temporary file for later merge
tempfile demographics
save `demographics'

*** ---------------------------------------------------------------------------
*** Block 5: Person Daily and Weekly Activity Status
*** ---------------------------------------------------------------------------

* Load Block 5 dataset (daily + current weekly activity)
use ///
	Key_hhold B5_c1 /// Common variables
	B5_c3 B5_c4 B5_c7 B5_c8 B5_c9 B5_c10 B5_c11 B5_c12 B5_c13 B5_c14 B5_c15 B5_c16 B5_c17 B5_c18 B5_c19 B5_c20  /// Native variables
	using "$nss_lab/raw/2003/extracted dta files/Block-5-Members-time-disposition-records", clear

* This block does not have person key so i constrct by concatenating hhold key and person serial number 
gegen person_key = concat(Key_hhold B5_c1)

drop Key_hhold B5_c1

* Apply harmonized naming convention
rename *, lower
rename b5_c3			cda_srl_no
rename b5_c4 			cdas
rename b5_c7 			cda_seventh 
rename b5_c8			cda_sixth
rename b5_c9 			cda_fifth
rename b5_c10 			cda_fourth
rename b5_c11 			cda_third
rename b5_c12			cda_second
rename b5_c13 			cda_first
rename b5_c14 			cda_no_of_days
rename b5_c15			wages_cash
rename b5_c16 			wages_kind			
rename b5_c17			wages_total
rename b5_c18			cwa_status
rename b5_c19			cwa_nic_1998_5d
rename b5_c20			cwa_nco_1968_3d

drop if person_key == "43102110405"
drop if person_key == "41966110104"

/*
	   *Assert to check that they are constant across person key
	   foreach var of varlist cwa_status cwa_nic_1998_5d cwa_nco_1968_3d {
	   bysort person_key: assert `var' == `var'[1] // assertion is false
	   }

	   gen flag = 0

	   foreach var of varlist cwa_status cwa_nic_1998_5d cwa_nco_1968_3d {
	   bysort person_key: replace flag = 1 if `var' != `var'[1]
	   }
*/

* Reshape daily activity data from long to wide format
reshape wide cdas cda_seventh cda_sixth cda_fifth cda_fourth cda_third cda_second cda_first cda_no_of_days wages_cash wages_kind wages_total, i(person_key cwa_status cwa_nic_1998_5d cwa_nco_1968_3d) j(cda_srl_no) string

* Merge daily & weekly activity with demographics + usual activity dataset
merge 1:1 person_key using `demographics'
drop if _merge == 1
drop _merge

*** ---------------------------------------------------------------------------
*** Merge with Household Characteristics
*** ---------------------------------------------------------------------------

* Merge household-level characteristics to person-level dataset
merge m:1 hh_key using "$nss_lab/intermediate/Blk_hc_2004a"
count if _merge !=3
assert `r(N)' < 10 // to ensure quality of merge
drop _merge 

/*
	   Result                      Number of obs
	   -----------------------------------------
	   Not matched                             0
	   Matched                           303,828  (_merge==3)
	   -----------------------------------------
*/

* Clean industry codes:
*   - Remove spaces
*   - Drop records with placeholder characters (X, Y)
*   - Drop invalid or incomplete codes
replace nic_1998_5d = subinstr(nic_1998_5d, " ", "",.)
drop if regexm(nic_1998_5d, "x") | regexm(nic_1998_5d, "X") | regexm(nic_1998_5d, "Y") // 0 obs deleted
drop if strlen(nic_1998_5d)!= 5 & !mi(nic_1998_5d) // 0 obs dropped
drop if nic_1998_5d == "00000" 

* Generating year and round variable
gen year = 2004
gen nss_round = 60

save "$nss_lab/intermediate/Blk_merged_2004a.dta", replace

