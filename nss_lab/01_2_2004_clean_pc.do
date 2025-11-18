* Purpose: To clean data at the person-level EUS for year 2004-05 (July-June)                  

*** ---------------------------------------------------------------------------
*** Block 5: Usual Activity Status
*** ---------------------------------------------------------------------------

* Loading the dataset
use ///
	HHID PID /// Common variables
	Usual_principal_activity_status Usual_principal_activity_NIC_5_d Usual_principal_activity_NCO_3_d Whether_in_subsidiary_activity /// Native variables
	Location_of_workplace Enterprise_type Availability_of_work Age Sex Enterprise_uses_electricity /// Native variables
	WEIGHT_COMBINED /// Multiplier combined
	using "$nss_lab/raw/2004/extracted dta files/Block_5pt1_level_04.dta", clear

* Renaming variables
rename *, lower
rename pid		 						person_key
rename hhid		 						hh_key
rename usual_principal_activity_status 	act_code
rename usual_principal_activity_nic_5_d nic_1998_5d
rename usual_principal_activity_nco_3_d nco_1968_3d
rename whether_in_subsidiary_activity	act_code_sub 
rename availability_of_work				seeking_work
rename location_of_workplace			work_location
rename enterprise_type					ent_type
rename enterprise_uses_electricity		use_electricity
rename weight_combined					weight

* Destringing variables
destring age act_code act_code_sub ent_type work_location seeking_work, replace

gen nic_1998_4d = substr(nic_1998_5d,1,4)
gen nic_1998_3d = substr(nic_1998_5d,1,3)

* Drop if missing person key
drop if person_key == ""

* Save as a temporary file for later merge
tempfile pc
save `pc'

*** ---------------------------------------------------------------------------
*** Block 4: Demographics  
*** ---------------------------------------------------------------------------

* Load Block 4 dataset (demographics)
use ///
	HHID PID /// Identification variables
	Personal_serial_no Relation_to_head Marital_status General_education Technical_education Registered_with_employment_excha /// Native variables
	WEIGHT_COMBINED /// Multiplier combined
	using "$nss_lab/raw/2004/extracted dta files/Block_4_level_03.dta", clear

* Renaming variables
rename *, lower
rename pid		 						person_key
rename hhid		 						hh_key
rename personal_serial_no				person_srl_no
rename general_education				gen_edu_raw
rename technical_education				tech_edu_raw
rename registered_with_employment_excha	reg_emp_exch
rename weight_combined					weight

* Merge demographics with usual activity dataset
merge 1:1 person_key using `pc'
keep if _merge == 3
drop _merge

* Save as a temporary file for later merge 
tempfile demographics
save `demographics'

*** ---------------------------------------------------------------------------
*** Block 5: Person Daily and Weekly Activity Status
*** ---------------------------------------------------------------------------

* Load Block 5 dataset (daily + current weekly activity)
use ///
	FSU Hamlet Second_stratum Sample_hhld_no Personal_srl_no /// Identification variables
	Srl_no_of_current_day_activity Current_day_activity_Status Current_day_activity_Status Current_day_activity_intensity_7 Current_day_activity_intensity_6 Current_day_activity_intensity_5 Current_day_activity_intensity_4 Current_day_activity_intensity_3 Current_day_activity_intensity_2 Current_day_activity_intensity_1 Total_no_of_days_in_current_acti Wage_salary_cash_during_the_week Wage_salary_earnings_kind_during Wage_salary_earnings_total_durin Current_weekly_activity_status Current_weekly_activity_NIC_1998 Current_weekly_activity_NCO_1968 /// Native variables
	using "$nss_lab/raw/2004/extracted dta files/Block_5pt3_level_06.dta", clear

*This block does not have person key so it is constructed by concatenating household key and person serial number 
gegen person_key = concat(FSU Hamlet Second_stratum Sample_hhld_no Personal_srl_no)

drop FSU Hamlet Second_stratum Sample_hhld_no Personal_srl_no

* Renaming variables
rename *, lower
rename srl_no_of_current_day_activity	cda_srl_no
rename current_day_activity_status 		cdas
rename current_day_activity_intensity_7	cda_seventh 
rename current_day_activity_intensity_6	cda_sixth
rename current_day_activity_intensity_5	cda_fifth
rename current_day_activity_intensity_4	cda_fourth
rename current_day_activity_intensity_3	cda_third
rename current_day_activity_intensity_2	cda_second
rename current_day_activity_intensity_1	cda_first
rename total_no_of_days_in_current_acti	cda_no_of_days
rename wage_salary_cash_during_the_week	wages_cash
rename wage_salary_earnings_kind_during	wages_kind			
rename wage_salary_earnings_total_durin	wages_total
rename current_weekly_activity_status	cwa_status
rename current_weekly_activity_nic_1998	cwa_nic_1998_5d
rename current_weekly_activity_nco_1968	cwa_nco_1968_3d

* Reshape daily activity data from long to wide format
reshape wide cdas cda_seventh cda_sixth cda_fifth cda_fourth cda_third cda_second cda_first cda_no_of_days wages_cash wages_kind wages_total, i(person_key cwa_status cwa_nic_1998_5d cwa_nco_1968_3d) j(cda_srl_no) string

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
merge m:1 hh_key using "$nss_lab/intermediate/Blk_hc_2004b"
count if _merge !=3
//assert `r(N)' < 10 // to ensure quality of merge-- 19 are unmerged in this dataset
drop if _merge == 2
drop _merge 


* Generating year and round variable
gen year = 2004
gen nss_round = 61

* Clean industry codes:
*   - Remove spaces
*   - Drop records with placeholder characters (X, Y)
*   - Drop invalid or incomplete codes
replace nic_1998_5d = subinstr(nic_1998_5d, " ", "",.)
drop if regexm(nic_1998_5d, "x") | regexm(nic_1998_5d, "X") | regexm(nic_1998_5d, "Y") // 0 obs deleted
drop if strlen(nic_1998_5d)!= 5 & !mi(nic_1998_5d) // 0 obs dropped
drop if nic_1998_5d == "00000" 

* Saving final dataset
save "$nss_lab/intermediate/Blk_merged_2004b.dta", replace

