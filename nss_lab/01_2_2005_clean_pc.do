* Purpose: To clean data at the person-level EUS for year 2005-06 (July-June)                  

*** ---------------------------------------------------------------------------
*** Block 5: Usual Activity Status
*** ---------------------------------------------------------------------------

* Loading the dataset
use Hhold_key Person_key /// Common variables
	B5_q2 B5_q3 B5_q5 B5_q6 B5_q7 /// Native variables
	WGT_Comb /// Weight combined
	using "$nss_lab/raw/2005/extracted dta files/Block-5-Persons-usual-activity-records", clear

* Renaming variables
rename *, lower
rename hhold_key		 				hh_key
rename b5_q2							age
rename b5_q3						 	act_code
rename b5_q5							nic_2004_5d
rename b5_q6							nco_1968_3d
rename b5_q7							act_code_sub 
rename wgt_comb							weight

* Destringing variables
destring age act_code act_code_sub , replace

* Generating NIC 2004 at the 3- and 4-digit level
gen nic_2004_4d = substr(nic_2004_5d,1,4)
gen nic_2004_3d = substr(nic_2004_5d,1,3)

* Save as a temporary file for later merge
tempfile pc
save `pc'

*** ---------------------------------------------------------------------------
*** Block 4: Demographics  
*** ---------------------------------------------------------------------------

* Load Block 4 dataset (demographics)
use Hhold_key Person_key /// Identification variables
	Person_slno_B4_q1 B4_q3 B4_q4 B4_q6 B4_q7 B4_q8 /// Native variables
	using "$nss_lab/raw/2005/extracted dta files/Block-4-Persons-demographic-particulars-records", clear

*renaming variables
rename *, lower
rename hhold_key		 				hh_key
rename person_slno_b4_q1				person_srl_no
rename b4_q3							relation_to_head
rename b4_q4							sex
rename b4_q6						 	marital_status
rename b4_q7							gen_edu_raw
rename b4_q8 							tech_edu_raw

* Merge demographics with usual activity dataset
merge 1:1 person_key using `pc'	
drop _merge

* Save as a temporary file for later merge 
tempfile demographics
save `demographics'

*** ---------------------------------------------------------------------------
*** Block 5: Person Daily and Weekly Activity Status
*** ---------------------------------------------------------------------------

* Load Block 5 dataset (daily + current weekly activity)
use Person_key /// Common variables
	B6_q3 B6_q4 B6_q7 B6_q8 B6_q9 B6_q10 B6_q11 B6_q12 B6_q13 B6_q14 B6_q15 B6_q16 B6_q17 B6_q18 B6_q19 B6_q20 /// Native variables
	using "$nss_lab/raw/2005/extracted dta files/Block-6-Persons-daily-activity-time-disposition-reecords", clear

* Renaming variables
rename *, lower
rename b6_q3			cda_srl_no
rename b6_q4 			cdas
rename b6_q7 			cda_seventh 
rename b6_q8			cda_sixth
rename b6_q9 			cda_fifth
rename b6_q10 			cda_fourth
rename b6_q11 			cda_third
rename b6_q12			cda_second
rename b6_q13 			cda_first
rename b6_q14 			cda_no_of_days
rename b6_q15			wages_cash
rename b6_q16 			wages_kind			
rename b6_q17			wages_total
rename b6_q18			cwa_status
rename b6_q19			cwa_nic_2004_5d
rename b6_q20			cwa_nco_1968_3d

* Reshape daily activity data from long to wide format
reshape wide cdas cda_seventh cda_sixth cda_fifth cda_fourth cda_third cda_second cda_first cda_no_of_days wages_cash wages_kind wages_total, i(person_key cwa_status cwa_nic_2004_5d cwa_nco_1968_3d) j(cda_srl_no) string


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
drop if _merge == 1
drop _merge

*** ---------------------------------------------------------------------------
*** Merge with Household Characteristics
*** ---------------------------------------------------------------------------

* Merge household-level characteristics to person-level dataset
merge m:1 hh_key using "$nss_lab/intermediate/Blk_hc_2005"
count if _merge !=3
assert `r(N)' < 10 // to ensure quality of merge
drop if _merge == 2
drop _merge 

* Generating year and round variable
gen year = 2005
gen nss_round = 62

* Clean industry codes:
*   - Remove spaces
*   - Drop records with placeholder characters (X, Y)
*   - Drop invalid or incomplete codes
replace nic_2004_5d = subinstr(nic_2004_5d, " ", "",.)
drop if regexm(nic_2004_5d, "x") | regexm(nic_2004_5d, "X") | regexm(nic_2004_5d, "Y") // 0 obs deleted
drop if strlen(nic_2004_5d)!= 5 & !mi(nic_2004_5d) // 0 obs dropped
drop if nic_2004_5d == "00000" 

* Saving final dataset
save "$nss_lab/intermediate/Blk_merged_2005.dta", replace


