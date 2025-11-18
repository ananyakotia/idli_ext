* Purpose: To clean data at the person-level EUS for year 2011-12 (July-June)                  

*** ---------------------------------------------------------------------------
*** Block 5: Usual Activity Status
*** ---------------------------------------------------------------------------

* Loading the dataset
use ///
	HHID Person_Serial_No /// Common variables
	Age Usual_Principal_Activity_Status Usual_Principal_Activity_NIC2008 Usual_Principal_Activity_NCO2004 Whether_in_Subsidiary_Activity Location_of_Workspace Enterprise_Type Seeking_available_for_work Enterprise_uses_Electricity  /// Native variables
	Multiplier_comb /// Multiplier- combined
	using "$nss_lab/raw/2011/extracted dta files/Block_5_1_Usual principal activity particulars of household members", clear

* Generating person_key
gegen person_key = concat(HHID Person_Serial_No)

* Dropping irrelevant variables
drop Person_Serial_No

* Renaming variables
rename *, lower
rename hhid					 				hh_key
rename usual_principal_activity_status	 	act_code
rename usual_principal_activity_nic2008		nic_2008_5d
rename usual_principal_activity_nco2004		nco_2004_3d
rename whether_in_subsidiary_activity		act_code_sub 
rename location_of_workspace				work_location
rename enterprise_type						ent_type
rename seeking_available_for_work			seeking_work
rename enterprise_uses_electricity			use_electricty
rename multiplier_comb						weight

* Destringing variables
destring age act_code act_code_sub ent_type work_location seeking_work, replace

* Generating NIC 2008 at the 3- and 4-digit level
gen nic_2008_4d = substr(nic_2008_5d,1,4)
gen nic_2008_3d = substr(nic_2008_5d,1,3)

* Save as a temporary file for later merge
tempfile pc
save `pc'

*** ---------------------------------------------------------------------------
*** Block 4: Demographics
*** ---------------------------------------------------------------------------

* Loading the dataset
use ///
	HHID Person_Serial_No /// Common variables
	Person_Serial_No Relation_to_Head Sex Marital_Status General_Education Technical_Education Registered_with_Emp_Exchange  /// Native variables
	Multiplier_comb /// Multiplier- combined
	using "$nss_lab/raw/2011/extracted dta files/Block_4_Demographic particulars of household members", clear

* Generating person_key
gegen person_key = concat(HHID Person_Serial_No)

* Renaming variables
rename *, lower
rename hhid					 				hh_key
rename person_serial_no						person_srl_no
rename general_education					gen_edu_raw
rename technical_education					tech_edu_raw
rename registered_with_emp_exchange			reg_emp_exch
rename multiplier_comb						weight

* Merge demographics and usual activity dataset
merge 1:1 person_key using `pc'
drop _merge

* Save as a temporary file for later merge
tempfile demographics
save `demographics'

*** ---------------------------------------------------------------------------
*** Block 5: Person Daily and Weekly Activity Status
*** ---------------------------------------------------------------------------

* Load Block 5 dataset (daily + current weekly activity)
use ///
	HHID Person_Serial_No /// Common variables
	Srl_no_of_Activity Status Intensity_7th_Day Intensity_6th_Day Intensity_5th_Day Intensity_4th_Day Intensity_3rd_Day Intensity_2nd_Day Intensity_1st_Day Total_no_days_in_each_activity Wage_and_Salary_Earnings_Cash Wage_and_Salary_Earnings_Kind Wage_and_Salary_Earnings_Total Current_Weekly_Activity_Status Current_Weekly_Activity_NIC_2008 Current_Weekly_Activity_NCO_2004  /// Native variables
	using "$nss_lab/raw/2011/extracted dta files/Block_5_3_Time disposition during the week ended on ...............dta", clear

* Generating person_key
gegen person_key = concat(HHID Person_Serial_No)
drop HHID Person_Serial_No

rename *, lower
rename srl_no_of_activity			cda_srl_no
rename status		 					cdas
rename intensity_7th_day				cda_seventh 
rename intensity_6th_day				cda_sixth
rename intensity_5th_day				cda_fifth
rename intensity_4th_day 				cda_fourth
rename intensity_3rd_day 				cda_third
rename intensity_2nd_day				cda_second
rename intensity_1st_day				cda_first
rename total_no_days_in_each_activity 	cda_no_of_days
rename wage_and_salary_earnings_cash	wages_cash
rename wage_and_salary_earnings_kind	wages_kind			
rename wage_and_salary_earnings_total	wages_total
rename current_weekly_activity_status	cwa_status
rename current_weekly_activity_nic_2008	cwa_nic_2008_5d
rename current_weekly_activity_nco_2004	cwa_nco_2004_3d

* Assert to check that they are constant across person key
foreach var of varlist cwa_status cwa_nic_2008_5d cwa_nco_2004_3d {
	bysort person_key: assert `var' == `var'[1] // assertion is false
}

* Reshape daily activity data from long to wide format
reshape wide cdas cda_seventh cda_sixth cda_fifth cda_fourth cda_third cda_second cda_first cda_no_of_days wages_cash wages_kind wages_total, i(person_key cwa_status cwa_nic_2008_5d cwa_nco_2004_3d) j(cda_srl_no) string

* Merge with previous blocks
merge 1:1 person_key using `demographics'
drop _merge

* Save as a temporary file for later merge
tempfile cdas
save `cdas'

*** ---------------------------------------------------------------------------
*** Merge with Household Characteristics
*** ---------------------------------------------------------------------------

* Merge household-level characteristics to person-level dataset
use ///
	HHID /// Common variables 
	Item_Group_Srl_No Value_of_Consumption_Last_30_Day /// Native variables
	using "$nss_lab/raw/2011/extracted dta files/Block_8_Household consumer expenditure", clear

* Renaming variables
rename *, lower
rename hhid					 				hh_key

* Keeping only total expenditure 
keep if inlist(item_group_srl_no, "40")

* Renaming variable
ren value_of_consumption_last_30_day exp_sum 

drop item_group_srl_no

* Merge with previous blocks
merge 1:m hh_key using `cdas'
assert _merge != 1
drop _merge

*** ---------------------------------------------------------------------------
*** Merge with Household Characteristics
*** ---------------------------------------------------------------------------

* Merge household-level characteristics to person-level dataset
merge m:1 hh_key using "$nss_lab/intermediate/Blk_hc_2011"
count if _merge !=3
assert `r(N)' < 10 // to ensure quality of merge
drop _merge 

* Generating monthly total per capita expenditure
gen total_exp_hh = exp_sum/hh_size

* Generating year and round variable
gen year = 2011
gen nss_round = 68

* Clean industry codes:
*   - Remove spaces
*   - Drop records with placeholder characters (X, Y)
*   - Drop invalid or incomplete codes
replace nic_2008_5d = subinstr(nic_2008_5d, " ", "",.)
drop if regexm(nic_2008_5d, "x") | regexm(nic_2008_5d, "X") | regexm(nic_2008_5d, "Y") 
drop if strlen(nic_2008_5d)!= 5 & !mi(nic_2008_5d) 
drop if nic_2008_5d == "00000" 

gisid person_key

* Saving final dataset
save "$nss_lab/intermediate/Blk_merged_2011.dta", replace
