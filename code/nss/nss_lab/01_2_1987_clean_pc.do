* Purpose: To clean data at the person-level EUS for year 1987                       

*** ---------------------------------------------------------------------------
*** Block 6: Usual Activity Status
*** ---------------------------------------------------------------------------

* Loading the dataset
use ///
	Hhold_key Person_key District Sector State Region /// Common variables
	B6_q2 B6_q5 B6_q6 B6_q7 B6_q8 B6_q11 B6_q12 B6_q13 Prsn_Slno /// Native variables
	Wgt4_pooled /// Combined weight
	using "$nss_lab/raw/1987/extracted dta files/Block-6--Persons-Usual-activity- migration-Records.dta", clear

* Renaming variables
rename *, lower
rename hhold_key		hh_key
rename b6_q2 			act_code
rename prsn_slno  		person_srl_no
rename district			dist_code
rename state			st_code
rename b6_q5 			nic_1970_3d
rename b6_q6  			nco_1968_3d
rename b6_q8			sub_act_status
rename b6_q11			sub_nic_1970_3d
rename b6_q12			sub_nco_1968_3d
rename b6_q13 			work_location
rename b6_q7 			act_code_sub
rename wgt4_pooled		weight

* Destringing variables
destring act_code work_location act_code_sub work_location sector, replace

gen nic_1970_2d = substr(nic_1970_3d,1,2)

* Generating nss region variable as it is not there in the dataset
gegen nss_region = concat(st_code region)

* Remove duplicate records per person_key
bys person_key: gen dup = cond(_N==1,0,_n)
drop if dup> 1
drop dup

drop if person_key == "" // dropping if person key is missing so data can be isid

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

* Load Block 4 dataset (demographics + current weekly activity)
use ///
	Hhold_key Person_key State District Region Sector /// Common variables
	B4_q4 B4_q5 B4_q6 B4_q7 B4_q8 B4_q11 B4_q14 B4_q15 /// Native variables
	Wgt4_pooled /// Combined weight
	using "$nss_lab/raw/1987/extracted dta files/Block-4-Persons-Demographic-current-weekly-activity- Records.dta", clear

*renaming variables
rename *, lower
rename hhold_key		hh_key
rename state			st_code
rename district			dist_code
rename b4_q4 			sex
rename b4_q5 			age
rename b4_q6  			marital_status
rename b4_q7			gen_edu_raw
rename b4_q8			tech_edu_raw
rename b4_q11			cwa_status
rename b4_q14 			cwa_nic_1970_3d
rename b4_q15 			cwa_nco_1968_3d
rename wgt4_pooled		weight

destring sector, replace

* Remove duplicate records per person_key
bys person_key: gen dup = cond(_N==1,0,_n)
drop if dup> 1
drop dup

* Generating nss region variable
gegen nss_region = concat(st_code region)

* Merge with Block 6 data (usual activity) using person_key
merge 1:m person_key using `pc'
drop _merge


* Save merged Block 4.1 + Block 6 file for later steps
tempfile demographics
save `demographics'

*** ---------------------------------------------------------------------------
*** Block 5: Persons Daily Activity Records
*** ---------------------------------------------------------------------------

* Load Block 5 dataset (daily activity details)
use ///
	Hhold_key Person_key /// Common variables
	Activity_Slno B5_q3 B5_q6 B5_q7 B5_q8 B5_q9 B5_q10 B5_q11 B5_q12 B5_q13 B5_q14 B5_q15 B5_q16 /// Native variables
	using "$nss_lab/raw/1987/extracted dta files/Block-5-Persons-Daily- activity- time-disposion-Records.dta", clear

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

* Remove duplicate records per person_key
bys person_key cda_srl_no: gen dup = cond(_N==1,0,_n) // for the same person key there are different ages and current daily activity status
drop if dup> 0 & cdas == ""
drop dup

* There are still some duplicates remaining as there are different cdas for a given person key and activity serial number
bys person_key cda_srl_no: gen dup = cond(_N==1,0,_n) // for the same person key there are different ages and current daily activity status
drop if dup> 1
drop dup

* Reshape daily activity data from long to wide format
reshape wide cdas cda_seventh cda_sixth cda_fifth cda_fourth cda_third cda_second cda_first cda_no_of_days wages_cash wages_kind wages_total, i(person_key) j(cda_srl_no) string

* Merge daily activity with demographics + usual activity dataset
merge 1:1 person_key using `demographics'
drop if _merge == 1
drop _merge

*** ---------------------------------------------------------------------------
*** Merge with Household Characteristics
*** ---------------------------------------------------------------------------

* Merge household-level characteristics to person-level dataset
merge m:1 hh_key using "$nss_lab/intermediate/Blk_hc_1987"

count if _merge !=3	
//assert `r(N)' < 10 // to ensure quality of merge

drop if _merge == 2 // dropping all those hh keys which dont have person key (125 obs dropped)
*34 observations dont have hh characteristics and certain demographics like religion against them 
drop _merge 

* Generating year and round variable
gen year = 1987
gen nss_round = 43

*** ---------------------------------------------------------------------------
*** Save Final Dataset
*** ---------------------------------------------------------------------------

save "$nss_lab/intermediate/Blk_merged_1987.dta", replace




