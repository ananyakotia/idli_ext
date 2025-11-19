
/*
We are cleaning the following surveys:
	- Employment and Unemployment Survey: NSS 43rd Round : July 1987 - June 1988
	- Employment and Unemployment Survey: NSS 50th Round : July 1993 - June 1994
	- Employment and Unemployment Survey: NSS 55th Round : July 1999 - June 2000
	- Employment and Unemployment Survey: NSS 60th Round : July 2003 - June 2004
	- Employment and Unemployment Survey: NSS 61st Round : July 2004 - June 2005
	- Employment and Unemployment Survey: NSS 62nd Round : July 2005 - June 2006
	- Employment and Unemployment Survey: NSS 64th Round : July 2007 - June 2008
	- Employment and Unemployment Survey: NSS 66th Round : July 2009 - June 2010
	- Employment and Unemployment Survey: NSS 68th Round : July 2011 - June 2012
	
*/


/* Clean and Appennd Individual and Household Characterstics datasets (yearwise), followed by labelling,
checking for misssing values, and then by making graphs on key variables to check the trend in data. */

* Clean Household Characterstics datasets of NSS Labour Surveys 
	foreach yr in "1983" "1987" "1993" "1999" "2003" "2004" "2005" "2007" "2009" "2011" {
	
		do "$code/nss/nss_lab/01_1_`yr'_clean_hc.do"
	}

* Clean Person Characterstics datasets of NSS Labour Surveys 
	foreach yr in "1983" "1987" "1993" "1999" "2003" "2004" "2005" "2007" "2009" "2011" {
	
		do "$code/nss/nss_lab/01_2_`yr'_clean_pc.do"
	}
* Append Hosuehold and Person characterstics merged datasets of NSS Labour Surveys 
do "$code/nss/nss_lab/01_clean_append_lab.do"

* Making District names consistent on 1991 district names. 
do "$code/nss/nss_lab/02_nss_consistent_districts.do"

* CONSISTENT INDUSTRY CODES 
do "$code/nss/nss_lab/03_consistent_industry_codes.do"

* CONSISTENT OCCUPATION CODES 
do "$code/nss/nss_lab/04_consistent_occupation_codes.do"


