
/*
PURPOSE: CREATE A VARIABLE WITH CONSISTENT NIC INDUSTRY CODES FOR ALL YEARS
*/

	use "$nss_lab/intermediate/nss_lab_dist_merge.dta", clear

	
* MERGE 2004 NIC CODES FOR YEARS >= 2008
	preserve
	
	*loading the code file for nic 2008 and 2004- 5 digit codes
	use "${nic_concordances}/concordance_nic_2008_5d_2004_5d.dta", clear
	
	*trimming the codes
	foreach var in nic_2008_5d nic_2004_5d {
	    replace `var' = ustrtrim(`var' )
	}
	
	bys nic_2008_5d: gen dup = cond(_N==1,0,_n)
	drop if dup > 1 // 160 obs deleted
	gisid nic_2008_5d
	
	tempfile nic04_08
	save `nic04_08'
	restore
	
	*merging the nic concordance for nic 2008 to nic 2004 
	merge m:1 nic_2008_5d using "`nic04_08'", gen(nic_merge) keepusing(nic_2004_5d) update
	
	gen nic_2008_2d = substr(nic_2008_5d, 1, 2)
	
	//assert nic_2004_5d != "" if nic_2008_5d != ""  &  (nic_2008_2d < 32 & nic_2008_2d > 10) // assertion is false, we are only checking for manufacturing section
	
	gdistinct nic_2008_5d // 1211 obs
	
	gdistinct nic_2004_5d if nic_2008_5d != "" // 439 obs

	* whenever nic 2008 code is avail, now nic 2004 code is also avail
	*assert nic_2004_5d != "" if nic_2008_5d != "" 	
	
	drop if nic_merge == 2
	drop nic_merge 

* MERGE 1998 NIC CODES FOR YEARS >= 2004
	preserve
	use "${nic_concordances}/concordance_nic_2004_5d_1998_5d.dta", clear
	bys nic_2004_5d: gen dup = cond(_N==1,0,_n)
	drop if dup > 1
	gisid nic_2004_5d
	tempfile nic04_5d
	save `nic04_5d'
	restore

	merge m:1 nic_2004_5d using "`nic04_5d'", gen(nic_merge) keepusing(nic_1998_5d) update
	
	gen nic_2004_2d = substr(nic_2004_5d, 1, 2)
	destring nic_2004_2d, replace
	//assert nic_1998_5d != "" if nic_2004_5d != ""  &  (nic_2004_2d < 32 & nic_2004_2d > 10) // 18019 is wrong nic it shoudl be 18109
	
	drop if nic_merge == 2
	drop nic_merge
	

* MERGE 1987 NIC CODES FOR YEARS 1998
	preserve
	use "${nic_concordances}/concordnace_1987_3d_1998_4d.dta", clear
	bys nic_1987_3d: gen dup = cond(_N==1,0,_n)
	drop if dup > 1
	gisid nic_1987_3d
	tempfile nic98_87
	save `nic98_87'
	restore

	/*
	merge m:1 nic_1987_3d using "`nic98_87'", gen(nic_merge) keepusing(nic_1998_4d) update

	drop if nic_merge == 2
	drop nic_merge
	*/
* MERGE 1998 5D NIC CODES WITH 1987 4D NIC CODES 

	replace nic_1998_4d = substr(nic_1998_5d, 1, 4)

	tab year if nic_1998_4d == "" 
	
	replace nic_1998_3d = substr(nic_1998_4d, 1, 3)
	replace nic_1998_4d = substr(nic_1998_5d, 1, 4)
	
	gen nic_1998_2d = substr(nic_1998_4d, 1, 2)

	
	save "$nss_lab/intermediate/nss_consistent_ind.dta", replace


/*

Steps involved:
	1. Loading the nss labour dataset
	2. Merging the 2004 NIC codes with the corresponding 2008 NIC codes. This is done for the codes from the manufacturing sector. 
	   This is from NIC 2d > 9 and NIC 2d < 34.
	3. Then we merge the NIC Concordance (2004 to 1998) with labour dataset. This gives the the corresponding 1998 NIC codes for the NIC 2004 codes.
	   We try to ensure that all codes from the manufacturing code are merged. For some of the codes which were new in 2004 for instance the nec codes,
	   in the concordance we fill the 4 digit code against them. For eg. if a code 12519 is a new nic 2004 code, we enter 12510 as its 1998 nic counterpart. 
	4. For the year 1987, we have 1987 codes at the 3 digit level. So, we Merge NIC Concordance (1987 to 1998) with labour dataset giving us the the 
	   corresponding 1998 NIC codes at the 4 digit level. 

	# This ensures that we have 
		- nic 1998 4 digit codes against nic 1987 codes at the 3 digit level
		- nic 1998 5 digit codes against nic 2004 and nic 2008 at the 5 digit level
		- nic 1998 at the 5 digit level for all nic 1987, 2004 and 2008 for the manufacturing sector #
	


