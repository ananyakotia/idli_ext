* Purpose: To clean data at the household-level for 2011-12 (July-June)                  

*** ---------------------------------------------------------------------------
*** Block 1-3: Household Records
*** ---------------------------------------------------------------------------

* Loading the household level dataset
use ///
	Sector State_Region District FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No /// Common variables
	Religion Social_Group Household_Type HH_Size Land_Owned /// Native variables
	Multiplier_comb /// Multiplier combined
	using "$nss_lab/raw/2011/extracted dta files/Block_3_Household characteristics", clear

* Generating hh_key variable
gegen hh_key = concat(FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No)

drop FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No

* Renaming variables
rename *, lower	
rename district 			dist_code
rename state_region			nss_region
rename social_group	 		caste	
rename household_type		emp_type_hh1
rename multiplier_comb		weight

* Destringing variables
destring sector emp_type_hh1 religion caste hh_size, replace

*Gnerating state code
gen st_code = substr(nss_region, 1, 2) 

* Saving the dataset
save "$nss_lab/intermediate/Blk_hc_2011", replace

