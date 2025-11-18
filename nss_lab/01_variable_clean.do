/* Purpose: To generate harmonized variables and add variable and value labels
*/

********************************************************************************
*** SECTOR *********************************************************************
********************************************************************************

*generating dummy variable for rural
gen rural = .
replace rural = 1 if sector == 1
replace rural = 0 if sector == 2
drop sector 

********************************************************************************
*** HOUSEHOLD EMPLOYMENT TYPE **************************************************
********************************************************************************

*generating a categorical variable for emp_type_hh
gen emp_type_hh = .

replace emp_type_hh = 1 if inlist(emp_type_hh1, 12, 14) & year != 2011 // agricultural labourers
replace emp_type_hh = 2 if inlist(emp_type_hh1, 11, 21) & year != 2011 // self employed in non agriculture
replace emp_type_hh = 3 if inlist(emp_type_hh1, 22) & year != 2011 // regular wage/ salary earning
replace emp_type_hh = 4 if inlist(emp_type_hh1, 13, 23) & year != 2011 // casual labour
replace emp_type_hh = 5 if inlist(emp_type_hh1, 19, 29) & year != 2011 // other labour

replace emp_type_hh = 1 if inlist(emp_type_hh1, 11, 14) & year == 2011 // agricultural labourers
replace emp_type_hh = 2 if inlist(emp_type_hh1, 12, 21) & year == 2011 // self employed in non agriculture
replace emp_type_hh = 3 if inlist(emp_type_hh1, 22) & year == 2011 // regular wage/ salary earning
replace emp_type_hh = 4 if inlist(emp_type_hh1, 13, 23) & year == 2011 // casual labour in non agriculture
replace emp_type_hh = 5 if inlist(emp_type_hh1, 15, 19, 29) & year == 2011 // other labour

*Creating dummy variables for each emp type
gen hh_employed_agri = emp_type_hh == 1
gen hh_self_employed_non_agri = emp_type_hh == 2
gen hh_regular_wage = emp_type_hh == 3
gen hh_casual_labor = emp_type_hh == 4
gen hh_other_labor = emp_type_hh == 5

********************************************************************************
*** CASTE **********************************************************************
********************************************************************************

*generating dummy variable for sc
gen sc = .
replace sc = 1 if caste == 2
replace sc = 0 if inlist(caste, 1, 3, 9)

*generating dummy variable for st
gen st = .
replace st = 1 if caste == 1
replace st = 0 if inlist(caste, 2, 3, 9)

*generating dummy variable for others
gen caste_others = .
replace caste_others = 1 if caste == 3 | caste == 9
replace caste_others = 0 if caste == 1 | caste == 2
drop caste

********************************************************************************
*** RELIGION *******************************************************************
********************************************************************************

*generating dummy variable for muslim
gen muslim = .
replace muslim = 1 if religion == 2
replace muslim = 0 if religion != 2 
replace muslim = . if religion == 0

*generating dummy variable for hindu
gen hindu = .
replace hindu = 1 if religion == 1
replace hindu = 0 if religion != 1 
replace hindu = . if religion == 0

*generating dummy variable for other religions
gen religion_others = 0
replace religion_others = 1 if religion != 1 | religion != 2 
replace religion_others = . if religion == 0


********************************************************************************
*** PERSON EMPLOYMENT TYPE *****************************************************
********************************************************************************

*generating categorical variables for emp_type at the person level
gen emp_type = .
replace emp_type = 1 if inlist(act_code, 11, 21) & ( year == 1983 | year == 1987) // self-employed
replace emp_type = 2 if inlist(act_code, 31) & ( year == 1983 | year == 1987) // salaried/ wage
replace emp_type = 3 if inlist(act_code, 41, 51) & ( year == 1983 | year == 1987) // casual/ daily wage labour

replace emp_type = 1 if inlist(act_code, 11, 12, 21) & year != 1987 // self-employed
replace emp_type = 2 if inlist(act_code, 31) & year != 1987 // salaried/ wage
replace emp_type = 3 if inlist(act_code, 41, 51) & year != 1987  // casual/ daily wage labour

*Creating dummy variables for each emp type person
gen p_self_employed = emp_type == 1
gen p_salary_earning = emp_type == 2
gen p_casual_wage = emp_type == 3

********************************************************************************
*** PERSON EMPLOYMENT STATUS ***************************************************
********************************************************************************

*generating a dummy variable for people out of the labour force
gen olf = .
replace olf = 1 if inlist(act_code, 91, 92, 93, 94, 95, 96, 97, 98, 99)
replace olf = 0 if inlist(act_code, 11, 21, 31, 41, 51, 61, 62, 71, 72, 81)
replace olf = . if act_code == 99 & year == 1993

*generating a dummy variable for employed 
gen employed = .
replace employed = 1 if inlist(act_code, 11, 21, 31, 41, 51)
replace employed = 0 if inlist(act_code, 61, 62, 71, 72, 81, 91, 92, 93, 94, 95, 96, 97, 98, 99)
replace employed = . if act_code == 99 & year == 1993

*generating a dummy variable for unemployed
gen unemployed = .
replace unemployed = 1 if inlist(act_code, 61, 62, 71, 72, 81)
replace unemployed = 0 if inlist(act_code, 11, 21, 31, 41, 51, 91, 92, 93, 94, 95, 96, 97, 98, 99)
replace unemployed = . if act_code == 99 & year == 1993


********************************************************************************
*** SEX  ***********************************************************************
********************************************************************************

*generating dummy variable for male
gen male = .
replace male = 1 if sex == "1"
replace male = 0 if sex == "2"
drop sex

*generating dummy variable for female
gen female = male == 0


********************************************************************************
*** GENERAL EDUCATION LEVEL ****************************************************
********************************************************************************

gen gen_edu = .
replace gen_edu = 1 if gen_edu_raw == "00" & (year == 1983 | year == 1987) // not literate
replace gen_edu = 2 if inlist(gen_edu_raw, "01", "02") & (year == 1983 | year == 1987) // literate but below primary
replace gen_edu = 3 if gen_edu_raw == "03" & (year == 1983 | year == 1987) // primary 
replace gen_edu = 4 if gen_edu_raw == "04" & (year == 1983 | year == 1987) // middle
replace gen_edu = 5 if gen_edu_raw == "05" & (year == 1983 | year == 1987) // secondary
replace gen_edu = 6 if inlist(gen_edu_raw, "06", "07", "08", "09") & (year == 1983 | year == 1987) // graduate and above

replace gen_edu = 1 if gen_edu_raw == "01" & (year == 1993 | year == 1999) // not literate
replace gen_edu = 2 if inlist(gen_edu_raw, "02", "03", "04", "05") & (year == 1993 | year == 1999) // literate but below primary
replace gen_edu = 3 if gen_edu_raw == "06" & (year == 1993 | year == 1999) // primary 
replace gen_edu = 4 if gen_edu_raw == "07" & (year == 1993 | year == 1999) // middle
replace gen_edu = 5 if inlist(gen_edu_raw, "08", "09") & (year == 1993 | year == 1999) // secondary
replace gen_edu = 6 if inlist(gen_edu_raw, "10", "11", "12", "13") & (year == 1993 | year == 1999) // graduate and above

replace gen_edu = 1 if gen_edu_raw == "01" & year == 2004 & nss_round == 60 // not literate
replace gen_edu = 2 if inlist(gen_edu_raw, "02", "03") & year == 2004 & nss_round == 60 // literate but below primary
replace gen_edu = 3 if gen_edu_raw == "04" & year == 2004 & nss_round == 60 // primary 
replace gen_edu = 4 if gen_edu_raw == "05" & year == 2004 & nss_round == 60 // middle
replace gen_edu = 5 if inlist(gen_edu_raw, "06", "07", "08") & year == 2004 & nss_round == 60 // secondary, higher secondary, diploma/certificate
replace gen_edu = 6 if inlist(gen_edu_raw, "10", "11") & year == 2004 & nss_round == 60 // graduate and above

replace gen_edu = 1 if gen_edu_raw == "01" & year == 2004 & nss_round == 61 // not literate
replace gen_edu = 2 if inlist(gen_edu_raw, "02", "03", "04", "05") & year == 2004 & nss_round == 61 // literate but below primary
replace gen_edu = 3 if gen_edu_raw == "06" & year == 2004 & nss_round == 61 // primary 
replace gen_edu = 4 if gen_edu_raw == "07" & year == 2004 & nss_round == 61 // middle
replace gen_edu = 5 if inlist(gen_edu_raw, "08", "10", "11") & year == 2004 & nss_round == 61 // secondary, higher secondary, diploma/certificate
replace gen_edu = 6 if inlist(gen_edu_raw, "12", "13") & year == 2004 & nss_round == 61 // graduate and above

replace gen_edu = 1 if gen_edu_raw == "01" & inlist(year, 2005, 2009, 2011) // not literate
replace gen_edu = 2 if inlist(gen_edu_raw, "02", "03", "04", "05") & inlist(year, 2005, 2009, 2011) // literate but below primary
replace gen_edu = 3 if gen_edu_raw == "06" & inlist(year, 2005, 2009, 2011) // primary 
replace gen_edu = 4 if gen_edu_raw == "07" & inlist(year, 2005, 2009, 2011) // middle
replace gen_edu = 5 if inlist(gen_edu_raw, "08", "10", "11") & inlist(year, 2005, 2009, 2011) // secondary, higher secondary, diploma/certificate
replace gen_edu = 6 if inlist(gen_edu_raw, "12", "13") & inlist(year, 2005, 2009, 2011) // graduate and above

replace gen_edu = 1 if gen_edu_raw == "01" & inlist(year, 2007) // not literate
replace gen_edu = 2 if inlist(gen_edu_raw, "02", "03", "04", "05", "06") & inlist(year, 2007) // literate but below primary
replace gen_edu = 3 if gen_edu_raw == "07" & inlist(year, 2007) // primary 
replace gen_edu = 4 if gen_edu_raw == "08" & inlist(year, 2007) // middle
replace gen_edu = 5 if inlist(gen_edu_raw, "10", "11", "12") & inlist(year, 2007) // secondary, higher secondary, diploma/certificate
replace gen_edu = 6 if inlist(gen_edu_raw, "13", "14") & inlist(year, 2007) // graduate and above

*Generating dummy variables for gen edu 
gen not_literate = gen_edu == 1
gen below_primary = gen_edu == 2
gen primary = gen_edu == 3
gen middle = gen_edu == 4
gen secondary = gen_edu == 5
gen graduate_and_above = gen_edu == 6


********************************************************************************
*** TECHNICAL EDUCATION LEVEL **************************************************
********************************************************************************

gen tech_edu = .
replace tech_edu = 1 if tech_edu_raw == "15" & year == 1983 // no technical education 
replace tech_edu = 3 if inlist(tech_edu_raw, "10", "11", "12", "13", "14") & year == 1983 // diploma/certificate

replace tech_edu = 1 if tech_edu_raw == "00" & year == 1987 // no technical education 
replace tech_edu = 3 if inlist(tech_edu_raw, "01", "02", "03", "04", "05") & year == 1987 // diploma/certificate

replace tech_edu = 1 if tech_edu_raw == "1" & inlist(year, 1993) // no technical education 
replace tech_edu = 3 if inlist(tech_edu_raw, "2", "3", "4", "5", "9") & inlist(year, 1993) // diploma/certificate

replace tech_edu = 1 if tech_edu_raw == "1" & inlist(year, 1999) // no technical education 
replace tech_edu = 2 if tech_edu_raw == "2" & inlist(year, 1999) // technical degree
replace tech_edu = 3 if inlist(tech_edu_raw, "3", "4", "5", "6", "9") & inlist(year, 1999) // diploma/certificate

replace tech_edu = 1 if tech_edu_raw == "1" & nss_round == 60 // no technical education 
replace tech_edu = 2 if tech_edu_raw == "2" & nss_round == 60  // technical degree
replace tech_edu = 3 if inlist(tech_edu_raw, "3", "4", "5", "6", "9") & nss_round == 60  // diploma/certificate

replace tech_edu = 1 if tech_edu_raw == "01" & inlist(year, 2005, 2009, 2011) | nss_round == 61  // no technical education 
replace tech_edu = 2 if tech_edu_raw == "02"  & inlist(year, 2005, 2009, 2011) | nss_round == 61  // technical degree
replace tech_edu = 3 if (inlist(tech_edu_raw, "03", "04", "05", "06", "07", "08") | inlist(tech_edu_raw, "09", "10", "11", "12"))  & (inlist(year, 2005, 2009, 2011) | nss_round == 61)  // diploma/certificate

replace tech_edu = 1 if tech_edu_raw == "1" & inlist(year, 2007) // no technical education 
replace tech_edu = 2 if (tech_edu_raw == "2" | tech_edu_raw == "3") & inlist(year, 2007) // technical degree
replace tech_edu = 3 if inlist(tech_edu_raw, "4", "5", "6") & inlist(year, 2007) // diploma/certificate
//drop tech_edu_raw

*Generating dummy variables for tech edu 
gen no_tech_edu = tech_edu == 1
gen tech_degree = tech_edu == 2
gen tech_diploma = tech_edu == 3

/* Note: in 1987 we don't have any category for technical degree

	   00	No Technical Education	
	   01	Additional Diploma/Certificate in Agriculture
	   02	Additional Diploma/Certificate in Engineering/Technology
	   03	Additional Diploma/Certificate in Medicine
	   04	Additional Diploma/Certificate in Crafts
	   05	Additional Diploma/Certificate in Other Subjects

*/
********************************************************************************
*** MARITAL STATUS *************************************************************
********************************************************************************

destring marital_status, replace
replace marital_status = . if marital_status == 0
gen never_married = marital_status == 1
gen currently_married = marital_status == 2
gen widowed = marital_status == 3
gen divorced_separated = marital_status == 4

********************************************************************************
*** WAGES **********************************************************************
********************************************************************************

/* For each current daily activity performed by a person we have wages reported:
	   1. in kind
	   2. in cash

	   and the total of the above. 

	   I generate a variable for the total wages earned by a person by summing those above.
*/

gegen wages_cash = rowtotal(wages_cash*)
gegen wages_kind = rowtotal(wages_kind*)
gegen wages_total = rowtotal(wages_total*)


