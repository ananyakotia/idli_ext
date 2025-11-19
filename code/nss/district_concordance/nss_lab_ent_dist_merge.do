* Here we check that the district codes and state codes in the same round (62) of two different 
* NSS surveys 9lab and ent) have the same information

*Loadingg the districts excel for NSS labor
import excel using "$idl_git/documentation/district_concordance/nss_lab_district.xlsx", firstrow clear 
tab nss_round

*dropping since they don't have districts
drop if nss_round == 38 | nss_round == 50

*There are a couple of duplicate district codes for a given round-- for instance in round 43 (year: ), 
* we have both Darbhanga and Sitamarhi having the code 13
duplicates drop // 2 obs dropped
bys nss_round st_code dist_code nss_region: gen dup = cond(_N==1,0,_n)
drop if dup >1 // 1 obs deleted 
drop dup

tempfile nss_lab
save `nss_lab'

*Loading the districts excel for NSS enterprise
import excel using "$idl_git/documentation/district_concordance/nss_ent_district.xlsx", firstrow clear 
tab nss_round

drop dist_name_1991 // because for enterprise they are not harmonized yet

gisid nss_round st_code dist_code nss_region

*Merging nss labor and enterprise districts dataset
merge 1:1 nss_round st_code dist_code nss_region using `nss_lab'
drop _merge

order nss_round st_code dist_code st_name_raw_ent st_name_raw_lab st_name_1991 dist_name_raw_ent dist_name_raw_lab dist_name_1991

sort nss_round st_code dist_code

foreach var in st_name_raw_ent st_name_raw_lab st_name_1991 dist_name_raw_ent dist_name_raw_lab dist_name_1991 {
    replace `var' = lower(`var')
}

keep if nss_round == 62

* Since round 62 is common in both nss_ent and nss_lab I check whether the raw state names and district naes are same
assert st_name_raw_ent == st_name_raw_lab if nss_round == 62
assert dist_name_raw_ent == dist_name_raw_lab if nss_round == 62


