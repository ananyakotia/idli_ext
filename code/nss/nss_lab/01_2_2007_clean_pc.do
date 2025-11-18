* Purpose: To clean data at the person-level EUS for year 2007-08 (July-June)                  

*** ---------------------------------------------------------------------------
*** Block 4: Demographics + Usual Activity Status
*** ---------------------------------------------------------------------------

* Loading the dataset
use key_memb key_hhold Rec_id /// Common variables
	key_memb B4_c1 B4_c3 B4_c4 B4_c5 B4_c6 B4_c7 B4_c8 B4_c9 B4_c11 B4_c12 B4_c13 B4_c14 B4_c16 B4_c17 /// Native variables
	wgt_combined /// Weight combined
	using "$nss_lab/raw/2007/extracted dta files/Block-4-demographic-usual-activity-members-records", clear

* Renaming variables
rename *, lower
rename key_hhold		 				hh_key
rename key_memb							person_key
rename b4_c1							person_srl_no	
rename b4_c3							relation_to_head	
rename rec_id							block
rename b4_c4 							sex
rename b4_c5							age
rename b4_c6							marital_status
rename b4_c7							gen_edu_raw
rename b4_c8							tech_edu_raw
rename b4_c9						 	act_code
rename b4_c11							nic_2004_5d
rename b4_c12							nco_2004_3d
rename b4_c13							act_code_sub 
rename b4_c14							sub_act_status
rename b4_c16							sub_nic_2004_5d
rename b4_c17							sub_nco_2004_3d
rename wgt_combined						weight

* Destringing variables
destring age act_code act_code_sub , replace

* Generating NIC 2004 at the 3- and 4-digit level
gen nic_2004_4d = substr(nic_2004_5d,1,4)
gen nic_2004_3d = substr(nic_2004_5d,1,3)

* Save as a temporary file for later merge
tempfile demographics
save `demographics'

*** ---------------------------------------------------------------------------
*** Block 5: Person Daily and Weekly Activity Status
*** ---------------------------------------------------------------------------

* Load Block 5 dataset (daily + current weekly activity)
use key_hhold B5_c1 /// Common variables
	B5_c3 B5_c4 B5_c7 B5_c8 B5_c9 B5_c10 B5_c11 B5_c12 B5_c13 B5_c14 B5_c15 B5_c16 B5_c17 B5_c18 B5_c19 B5_c20 /// Native variables
	using "$nss_lab/raw/2007/extracted dta files/Block-5-members-time-disposition-records", clear

* Creating person key because it is not present in the dataset
gegen person_key = concat(key_hhold B5_c1)

drop key_hhold B5_c1

* Renaming variables
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
rename b5_c19			cwa_nic_2004_5d
rename b5_c20			cwa_nco_2004_3d

/*
	   *Assert to check that they are constant across person key
	   foreach var of varlist cwa_status cwa_nic_2004_5d cwa_nco_2004_3d {
	   bysort person_key: assert `var' == `var'[1] // assertion is false
	   }
*/

* Reshape daily activity data from long to wide format
reshape wide cdas cda_seventh cda_sixth cda_fifth cda_fourth cda_third cda_second cda_first cda_no_of_days wages_cash wages_kind wages_total, i(person_key cwa_status cwa_nic_2004_5d cwa_nco_2004_3d) j(cda_srl_no) string

* Since for a given person_key, the cdas is coming in two different rows for some observations, I am collapsing the data to take max for each person key when there are duplicates.

bys person_key: gen dup = cond(_N==1,0,_n) 

* Keep only duplicates
preserve

keep if dup > 0

ds person_key dup, not
local allvars `r(varlist)'

ds `allvars', has(type numeric)
local numvars `r(varlist)'

ds `allvars', has(type string)
local strvars `r(varlist)'

* Collapse numeric variables by max
collapse (max) `numvars' (first) `strvars', by(person_key)

* Save temporary results
tempfile dupmax
save `dupmax'

restore

drop if dup > 0
drop dup

* Append back the collapsed duplicates
append using `dupmax'

* Merge with demographics and usual activity dataset
merge 1:1 person_key using `demographics'
drop _merge

*** ---------------------------------------------------------------------------
*** Merge with Household Characteristics
*** ---------------------------------------------------------------------------

* Merge household-level characteristics to person-level dataset
merge m:1 hh_key using "$nss_lab/intermediate/Blk_hc_2007"
count if _merge !=3
assert `r(N)' < 10 // to ensure quality of merge
drop _merge 

/*
	   Result                      Number of obs
	   -----------------------------------------
	   Not matched                             0
	   Matched                           572,254  (_merge==3)
	   -----------------------------------------
*/

* Generating year and round variable
gen year = 2007
gen nss_round = 64

* Clean industry codes:
*   - Remove spaces
*   - Drop records with placeholder characters (X, Y)
*   - Drop invalid or incomplete codes
replace nic_2004_5d = subinstr(nic_2004_5d, " ", "",.)
drop if regexm(nic_2004_5d, "x") | regexm(nic_2004_5d, "X") | regexm(nic_2004_5d, "Y") // 0 obs deleted
drop if strlen(nic_2004_5d)!= 5 & !mi(nic_2004_5d) // 0 obs dropped
drop if nic_2004_5d == "00000" 

* Saving final dataset
save "$nss_lab/intermediate/Blk_merged_2007.dta", replace
