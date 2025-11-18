* Purpose: To clean data at the person-level EUS for year 1983                           
*

*** ---------------------------------------------------------------------------
*** Block 6: Usual Activity Status
*** ---------------------------------------------------------------------------

* Loading the dataset
use ///
	Hhold_key Person_key Sector State Region ///
	B6_q2 B6_q6 B6_q5 B6_q6 ///
	Wgt4_pooled /// Combined weight
	using "$nss_lab/raw/1983/extracted dta files/Block-6-Persons-UsualActivity-records.dta", clear

* Standardize variable names to lowercase for consistency
rename *, lower

* Apply harmonized naming convention
rename hhold_key		hh_key
rename state			st_code
rename b6_q2 			act_code
rename b6_q5 			nic_1970_3d
rename b6_q6  			nco_1968_3d
rename wgt4_pooled		weight

* Create 2-digit industry code from 3-digit NIC
gen nic_1970_2d = substr(nic_1970_3d,1,2)

sort hh_key person_key act_code

* Remove duplicate records per person_key
bys person_key: gen dup = cond(_N==1,0,_n)
drop if dup> 1
drop dup

* Clean industry codes:
*   - Remove spaces
*   - Drop records with placeholder characters (X, Y)
*   - Drop invalid or incomplete codes
replace nic_1970_3d = subinstr(nic_1970_3d, " ", "",.)
drop if regexm(nic_1970_3d, "x") | regexm(nic_1970_3d, "X") | regexm(nic_1970_3d, "Y") 
drop if strlen(nic_1970_3d)!= 3 & !mi(nic_1970_3d) 
drop if nic_1970_3d == "000" 

* Save as a temporary file for later merge
tempfile pc
save `pc'

*** ---------------------------------------------------------------------------
*** Block 4.1: Demographics and Weekly Activity Status
*** ---------------------------------------------------------------------------

* Load Block 4.1 dataset (demographics + current weekly activity)
use Hhold_key Person_key Person_slno Sector State Region Hhold_Slno ///
	B41_q4 B41_q5 B41_q6 B41_q7 B41_q8 B41_q9 B41_q13 B41_q14 B41_q17 B41_q18 ///
	Wgt4_pooled ///
	using "$nss_lab/raw/1983/extracted dta files/Block-41-Persons-Demogrphic-weelyActivity-records.dta", clear

* Standardize variable names to lowercase
rename *, lower

* Apply harmonized naming convention
rename hhold_key		hh_key
rename state			st_code
rename person_slno		person_srl_no
rename b41_q4			relation_to_head
rename b41_q5 			sex
rename b41_q6 			age
rename b41_q7  			marital_status
rename b41_q8			gen_edu_raw
rename b41_q9			tech_edu_raw
rename b41_q13			reg_emp_exch
rename b41_q14			cwa_status
rename b41_q17 			cwa_nic_1970_3d
rename b41_q18 			cwa_nco_1968_3d
rename wgt4_pooled		weight

* Remove duplicate person records
* (e.g., cases where same person_key has inconsistent demographic/activity data)
bys person_key: gen dup = cond(_N==1,0,_n) // for the same person key there are different ages and current weekly activity status
drop if dup> 1
drop dup

* Merge with Block 6 data (usual activity) using person_key
merge 1:1 person_key using `pc'
drop _merge

* Save merged Block 4.1 + Block 6 file for later steps
tempfile demographics
save `demographics'

*** ---------------------------------------------------------------------------
*** Block 5: Persons Daily Activity Records
*** ---------------------------------------------------------------------------

* Load Block 5 dataset (daily activity details)
use Sector State FSU_Slno Region Hhold_Slno Person_slno ///
	Activity_slno B5_q3 B5_q6 B5_q7 B5_q8 B5_q9 B5_q10 B5_q11 B5_q12 B5_q13 B5_q14 B5_q15 B5_q16 ///
	using "$nss_lab/raw/1983/extracted dta files/Block-5-Persons-DailyActivity-records.dta", clear

* Reconstruct person_key (as it is not properly generated in Block 5)
gegen person_key = concat(Sector State Region FSU_Slno Hhold_Slno Person_slno)

* Dropping variables which are not required after generating person key 
drop Sector State Region FSU_Slno Hhold_Slno Person_slno

* Renaming variables
rename *, lower
rename activity_slno	cda_srl_no
rename b5_q3			cdas
rename b5_q6 			cda_seventh 
rename b5_q7			cda_sixth
rename b5_q8 			cda_fifth
rename b5_q9 			cda_fourth
rename b5_q10 			cda_third
rename b5_q11			cda_second
rename b5_q12 			cda_first
rename b5_q13 			cda_no_of_days
rename b5_q14			wages_cash
rename b5_q15 			wages_kind			
rename b5_q16			wages_total

* Remove duplicate person-key + activity-serial combinations
bys person_key cda_srl_no: gen dup = cond(_N==1,0,_n) 
drop if dup> 0 & cdas == ""
drop dup

* There are still some dupliactes remaining as there are different cdas for a given person key and activity serial number
bys person_key cda_srl_no: gen dup = cond(_N==1,0,_n) 
drop if dup> 1
drop dup

* Reshape daily activity data from long to wide format
reshape wide cdas cda_seventh cda_sixth cda_fifth cda_fourth cda_third cda_second cda_first cda_no_of_days wages_cash wages_kind wages_total, i(person_key) j(cda_srl_no) string

* Merge daily activity with demographics + usual activity dataset
merge 1:1 person_key using `demographics'
drop if _merge == 1
drop _merge

* Save as temporary file for next merge
tempfile cdas
save `cdas'

*** ---------------------------------------------------------------------------
*** Block 7: Subsidiary Activity Status
*** ---------------------------------------------------------------------------

* Load Block 7 dataset (subsidiary activity details)
use Hhold_key Person_key Sector State Region ///
	B7_q3 B7_q7 B7_q10 B7_q11 ///
	Wgt4_pooled ///
	using "$nss_lab/raw/1983/extracted dta files/Block-7-Persons-Notworking-subsidiary-activity-record.dta", clear

* Standardize variable names	
rename *, lower
rename hhold_key		hh_key
rename state			st_code
rename b7_q3			act_code_sub 
rename b7_q7			sub_act_status
rename b7_q10			sub_nic_1970_3d
rename b7_q11			sub_nco_1968_3d
rename wgt4_pooled		weight

* Remove duplicate person records
bys person_key: gen dup = cond(_N==1,0,_n)
drop if dup> 1
drop dup

* Merge subsidiary activity with all prior merged person-level data
merge 1:1 person_key using `cdas'
drop _merge

*** ---------------------------------------------------------------------------
*** Merge with Household Characteristics
*** ---------------------------------------------------------------------------

* Merge household-level characteristics to person-level dataset
merge m:1 hh_key using "$nss_lab/intermediate/Blk_hc_1983"

* Check number of mismatches
count if _merge !=3	// 4,688 obs

* Drop households with no matching person record
drop if _merge == 2 

drop _merge 

* Generating year and round variable
gen year = 1983
gen nss_round = 38

* Generating nss region variable
gegen nss_region = concat(st_code region)

* Destringing variables
destring sector emp_type_hh1 religion caste act_code_sub act_code, replace

*** ---------------------------------------------------------------------------
*** Save Final Dataset
*** ---------------------------------------------------------------------------

save "$nss_lab/intermediate/Blk_merged_1983.dta", replace

