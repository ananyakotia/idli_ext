
/*
	Purpose: APPEND  MERGED DATASET AND LABEL VARIABLES IN FINAL DATASET . 
			 
	SECTION 1.  APPEND INDIVIDUAL CHARACTERSTICS AND HOUSEHOLD CHARACTERSTICS MERGED DATASETS 
	
	SECTION 3. 	HARMONISE THE VARIABLES
				
	SECTION 2. 	LABEL VARIABLES IN FINAL OUTPUT FILE 
	
*/

* 1. APPEND INDIVIDUAL CHARACTERSTICS AND HOUSEHOLD CHARACTERSTICS MERGED DATASETS 
	
	use "$nss_lab/intermediate/Blk_merged_1987.dta", clear

	foreach yr in "1983" "1993" "1999" "2004a" "2004b" "2005" "2007" "2009" "2011" {
		
		append using "$nss_lab/intermediate/Blk_merged_`yr'.dta"
	}

* 2. HARMONISE THE VARIABLES

	do "$code/nss/nss_lab/01_variable_clean.do"

* 3. ADD VALUE LABELS

	label define emp_type_p 1 "Self-employed worker" 2 "Regular salaried/ wage employee" 3 "Casual wage workers"
	label value emp_type emp_type_p

	label define emp_type_hh 1 "Employed in agriculture" 2 "Self-employed in non-agriculture" 3 "Regular wage/ salary earning" 4 "Casual labour" 5 "Other households"
	label value emp_type_hh emp_type_hh
	
	label define gen_edu 1 "Not literate" 2 "Literate but below primary" 3 "Primary" 4 "Middle" 5 "Secondary" 6 "Graduate and above"
	label value gen_edu gen_edu
	
	label define tech_edu 1 "No technical education" 2 "Technical degree" 3 "Technical diploma/certificate"
	label value tech_edu tech_edu

* 3. LABEL VARIABLES

	la var person_key 			"Person ID"
	la var year 				"Survey Year"
	la var nss_round 			"NSS Round"
	la var rural 				"Sector: rural = 1; urban = 0"
	la var nss_region 			"NSS Region"
	la var dist_code			"District"
	la var emp_type_hh 			"Household Employment Type"
	la var male 				"Sex: male = 1; female = 0"
	la var act_code 			"Usual Principal Activity Status"
	la var nic_2004_5d			"Usual principal activity- NIC- 2004"
	la var nco_2004_3d 			"Usual principal activity- NCO- 2004"
	la var act_code_sub 		"Engaged in subsidiary activity: Yes = 1; No = 0"
	la var emp_type 			"Person Employment Type"
	la var olf 					"Person Employment Type: Out of labour force = 1, Others = 0"
	la var employed 			"Person Employment Type: Employed = 1, Others = 0"
	la var unemployed 			"Person Employment Type: Unemployed = 1, Others = 0"
	la var p_self_employed 		"Self-Employed"
	la var p_salary_earning 	"Regular Wage/ Salary Earning"
	la var p_casual_wage 		"Casual/ Daily Wage Laborer"
	la var hh_self_employed_non_agri "Self-Employed in Non-Agriculture"
	la var hh_employed_agri 	"Employed in Agriculture"
	la var hh_regular_wage 		"Regular Wage Household"
	la var hh_casual_labor 		"Casual Labour Household"
	la var muslim 				"Religion: Muslim = 1, Other = 0"
	la var hindu  				"Religion: Hindu = 1, Other = 0"
	la var religion_others 		"Religion: Others = 1, Hindu & Muslim = 0"
	la var sc					"Caste: Scheduled Caste = 1, Others = 0"
	la var st					"Caste: Scheduled Tribe = 1, Others = 0"
	la var caste_others 		"Caste: Others = 1, SC & ST = 0"
	la var weight				"Multiplier Combined"
	la var marital_status		"Marital Status"
	la var total_exp_hh 		"Total Monthly Per Capita Expenditure (INR)"
	la var not_literate 		"Not literate"
	la var below_primary 		"Below primary"
	la var primary 				"Primary"
	la var middle 				"Middle"
	la var secondary 			"Secondary"
	la var graduate_and_above 	"Graduate and above"
	la var no_tech_edu 			"No technical education"
	la var tech_degree 			"Technical degree"
	la var tech_diploma 		"Technical diploma/ certificate"
	la var nic_1987_2d			"Employed principal activity: NIC 1987 2 digit"
	la var nic_1987_3d			"Employed principal activity: NIC 1987 3 digit"
	la var nic_1998_3d			"Employed principal activity: NIC 1998 3 digit"
	la var nic_1998_4d			"Employed principal activity: NIC 1998 4 digit"
	la var nic_1998_5d			"Employed principal activity: NIC 1998 5 digit"
	la var nic_2004_3d			"Employed principal activity: NIC 2004 3 digit"
	la var nic_2004_4d			"Employed principal activity: NIC 2004 4 digit"
	la var nic_2004_5d			"Employed principal activity: NIC 2004 5 digit"
	la var nic_2008_3d			"Employed principal activity: NIC 2008 3 digit"
	la var nic_2008_4d			"Employed principal activity: NIC 2008 4 digit"
	la var nic_2008_5d			"Employed principal activity: NIC 2008 5 digit"
	
	compress
	lab data "NSS Labour: 1987- 2011"
	
	#d ;
	keep 
	hh_key
	person_key person_srl_no
	year
	nss_round
	block 
	rural
	st_code nss_region dist_code relation_to_head
	nic_1970_3d nic_1987_2d nic_1987_3d
	nic_1998_3d nic_1998_4d nic_1998_5d
	nic_2004_3d nic_2004_4d nic_2004_5d
	nic_2008_3d nic_2008_4d nic_2008_5d
	hh_size religion emp_type_hh hh_casual_labor hh_employed_agri hh_regular_wage hh_self_employed_non_agri hh_other_labor
	emp_type_hh1 total_exp_hh never_married currently_married widowed divorced_separated
	sc st caste_others muslim hindu religion_others p_self_employed p_salary_earning p_casual_wage
	age male female emp_type olf employed unemployed gen_edu tech_edu
	not_literate below_primary primary middle secondary graduate_and_above no_tech_edu tech_degree tech_diploma
	act_code act_code_sub sub_act_no
	nco_1968_3d nco_2004_3d marital_status
	wages_cash wages_kind wages_total
	//skill work_location ent_type seeking_work 
	weight;
	
	#d cr 
	
	#d ;
	order 
	hh_key
	person_key person_srl_no
	year
	nss_round
	block 
	rural
	st_code nss_region dist_code relation_to_head
	nic_1970_3d nic_1987_2d nic_1987_3d
	nic_1998_3d nic_1998_4d nic_1998_5d
	nic_2004_3d nic_2004_4d nic_2004_5d
	nic_2008_3d nic_2008_4d nic_2008_5d
	hh_size religion never_married currently_married widowed divorced_separated
	emp_type_hh hh_casual_labor hh_employed_agri hh_regular_wage hh_self_employed_non_agri hh_other_labor emp_type_hh1 
	total_exp_hh 
	gen_edu tech_edu 
	not_literate below_primary primary middle secondary graduate_and_above no_tech_edu tech_degree tech_diploma marital_status
	sc st caste_others muslim hindu religion_others
	age male female emp_type p_*
	olf employed unemployed p_self_employed p_salary_earning p_casual_wage
	act_code act_code_sub sub_act_no
	nco_1968_3d nco_2004_3d
	wages_cash wages_kind wages_total
	//skill work_location ent_type seeking_work 
	weight;
	
	#d cr 

	destring st_code dist_code, replace

* 4. SAVE THE FINAL DATASET
	save "$nss_lab/intermediate/nss_lab_clean.dta", replace

