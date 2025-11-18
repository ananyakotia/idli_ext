*Purpose: Have consitent occupation codes 

use "$nss_lab/intermediate/nss_consistent_ind.dta", clear

preserve

*loading the nco concordance 
import excel "${nic_concordances}/concordance_2004_3d_1968_3d_nco.xlsx", sheet("Sheet1") firstrow allstring clear
drop C // this is the description

*split in various variables as for each nco 2004 there are many nco 1968
split nco_1968_3d , parse(,)
drop nco_1968_3d

*reshaping the data
reshape long nco_1968_3d, i( nco_2004_3d ) j(nco_1968)
drop if nco_1968_3d == ""

*for now we only keep one nco 1968 against each nco 2004 so we can have a m:1 merge with nss
bys nco_2004_3d: gen dup = cond(_N==1,0,_n)
drop if dup > 1 
gisid nco_2004_3d

keep nco_1968_3d nco_2004_3d

tempfile nco04_68
save `nco04_68'

restore

*merging with nss dataset 
merge m:1 nco_2004_3d using "`nco04_68'", gen(nco_merge) update

drop nco_merge

save "$nss_lab/clean/nss_lab_final.dta", replace

// save "$ida/data/nss/nss_lab_final.dta", replace
