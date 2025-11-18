* Purpose: To clean data at the person-level EUS for year 1999                      


*** ---------------------------------------------------------------------------
*** Block 5: Usual Activity Status
*** ---------------------------------------------------------------------------

* Loading the dataset
use ///
	Key_hhold Key_prsn FileID sub_round Sub_sample fsu_no visit_no seg_no Stg2_stratm Hhold_Slno Prsn_slno_B51_q1 /// Common variables
	B51_q2 B51_q3 B51_q5 B51_q6 B51_q7 B51_q8 B51_q9 B51_q10 B51_q13 B51_q19 B51_q20 /// Native variables
	Wgt_SR_comb /// Multiplier Subround Combined(generated)
	using "$nss_lab/raw/1999/extracted dta files/Block51-sch10-Persons-usual-principal-activity-Records", clear

//gegen hh_key = concat(sub_round Sub_sample fsu_no visit_no seg_no Stg2_stratm Hhold_Slno)

* Dropping irrelevant variables
drop sub_round Sub_sample fsu_no visit_no seg_no Stg2_stratm Hhold_Slno Prsn_slno_B51_q1

* Renaming variables
rename *, lower
rename key_hhold		hh_key
rename key_prsn 		person_key
rename fileid 			block
rename b51_q2			age		  			
rename b51_q3			act_code 
rename b51_q5			nic_1998_5d
rename b51_q6 			nco_1968_3d
rename b51_q7 			act_code_sub
rename b51_q8 			sub_act_no
rename b51_q9 			work_location
rename b51_q10 			ent_type
rename b51_q13			use_electricty
rename b51_q19 			skill
rename b51_q20 			seeking_work
rename wgt_sr_comb		weight

* Destringing variables
destring age skill act_code work_location act_code_sub sub_act_no seeking_work work_location ent_type, replace

gen nic_1998_4d = substr(nic_1998_5d,1,4)
gen nic_1998_3d = substr(nic_1998_5d,1,3)

* Generating hh_size variable
bysort hh_key: gen hh_size = _N

gisid person_key

* Save as a temporary file for later merge
tempfile pc
save `pc'

*** ---------------------------------------------------------------------------
*** Block 4: Demographics and Weekly Activity Status
*** ---------------------------------------------------------------------------

* Load Block 4 dataset (demographics + current weekly activity)
use ///
	key_Hhold key_prsn RecID sub_round Sub_sample fsu_no visit_no seg_no Stg2_stratm Hhold_Slno Prsn_Slno_B4_q1 /// Common variables
	B4_q3 B4_q4 B4_q6 B4_q7 B4_q8 B4_q10 /// Native variables
	Wgt_SR_Comb /// Multiplier Subround Combined(generated)
	using "$nss_lab/raw/1999/extracted dta files/Block4-sch10-persons-demographic-migration-records", clear

* Dropping irrelevant variables
drop RecID sub_round Sub_sample fsu_no visit_no seg_no Stg2_stratm Hhold_Slno 

* Renaming variables
rename *, lower
rename key_hhold		hh_key
rename key_prsn 		person_key
rename prsn_slno_b4_q1	person_srl_no
rename b4_q3			relation_to_head
rename b4_q4			sex 
rename b4_q6			marital_status
rename b4_q7 			gen_edu_raw
rename b4_q8 			tech_edu_raw
rename b4_q10 			reg_emp_exch
rename wgt_sr_comb		weight

* Merge with Block 6 data (usual activity) using person_key
merge 1:1 person_key using `pc'
drop _merge

/*
	   Result                      Number of obs
	   -----------------------------------------
	   Not matched                             0
	   Matched                           596,686  (_merge==3)
	   -----------------------------------------
*/

* Save merged Block 4.1 + Block 6 file for later steps
tempfile demographics
save `demographics'

*** ---------------------------------------------------------------------------
*** Block 5: Persons Daily Activity Records
*** ---------------------------------------------------------------------------

* Load Block 5 dataset (daily activity details)
use ///
	Key_PRSN /// Common variables
	B53_q3 B53_q4 B53_q14 B53_q15 B53_q16 B53_q17 B53_q20 B53_q21 B53_q22 /// Native variables
	using "$nss_lab/raw/1999/extracted dta files/Block53-sch10-Persons-daily-activity-time-disposition-Records", clear

* Renaming variables
rename *, lower
rename key_prsn			person_key_old
rename b53_q3			cda_srl_no
rename b53_q4 			cdas
rename b53_q14 			cda_no_of_days
rename b53_q15			wages_cash
rename b53_q16 			wages_kind			
rename b53_q17			wages_total
rename b53_q20			cwa_status
rename b53_q21			cwa_nic_1998_5d
rename b53_q22			cwa_nco_1968_3d

gen person_key = substr(person_key_old, 3, .) // in this block we have two characters extra in the beginning of the person key, so we remove them 

drop person_key_old

gduplicates drop

* Assert to check that they are constant across person key
foreach var of varlist cwa_status cwa_nic_1998_5d cwa_nco_1968_3d {
	bysort person_key: assert `var' == `var'[1]
}

destring cda_srl_no, replace
tostring cda_srl_no, replace

* Remove duplicate person-key + activity-serial combinations
bys person_key cda_srl_no (cdas): gen dup = cond(_N==1,0,_n) // this includes cdas == 97 which we drop 
drop if dup > 1
drop dup

* Reshape daily activity data from long to wide format
reshape wide cdas cda_no_of_days wages_cash wages_kind wages_total, i(person_key cwa_status cwa_nic_1998_5d cwa_nco_1968_3d) j(cda_srl_no) string

* Merge daily activity with demographics + usual activity dataset
merge 1:1 person_key using `demographics'
drop if _merge == 1
drop _merge

*** ---------------------------------------------------------------------------
*** Merge with Household Characteristics
*** ---------------------------------------------------------------------------

* Merge household-level characteristics to person-level dataset
merge m:1 hh_key using "$nss_lab/intermediate/Blk_hc_1999"
count if _merge !=3
qui assert `r(N)' < 10 // to ensure quality of merge
drop _merge 

* Clean industry codes:
*   - Remove spaces
*   - Drop records with placeholder characters (X, Y)
*   - Drop invalid or incomplete codes
replace nic_1998_5d = subinstr(nic_1998_5d, " ", "",.)
drop if regexm(nic_1998_5d, "x") | regexm(nic_1998_5d, "X") | regexm(nic_1998_5d, "Y") // 0 obs deleted
drop if strlen(nic_1998_5d)!= 5 & !mi(nic_1998_5d) // 0 obs dropped
drop if nic_1998_5d == "00000" 

* In the documentation this is how we use the weights
replace weight  = weight/4	

* Generating year and round variable 
gen year = 1999
gen nss_round = 55

*** ---------------------------------------------------------------------------
*** Save Final Dataset
*** ---------------------------------------------------------------------------

save "$nss_lab/intermediate/Blk_merged_1999.dta", replace


