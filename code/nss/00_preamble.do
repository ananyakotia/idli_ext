* preamble
clear all
set varabbrev off
macro drop _all
set more off
pause on
set excelxlsxlargefile on

global packages_install = 1
global packages_update = 1

* install Stata packages
if $packages_install {
	foreach package in /// colrspace ///
		confirmdir ///
		distinct ///
		grstyle ///
		gtools ///
		palettes /// for grstyle
		colrspace /// for grstyle
		mipolate ///
		reghdfe ///
		estout /// 
		ftools /// needed for reghdfe
		coefplot ///
		freqindex /// required for matchit
		grc1leg2 /// graph combine with common legend
		nicelabels ///
		{
		cap which `package'
		if _rc ssc install `package', all replace
	}
	cap which renvars
	if _rc {
		net install dm88_1, from ("http://www.stata-journal.com/software/sj5-4")
		cap n net get dm88_1
		cap n net install dm88_1
	}
	cap which grc1leg2
	if _rc {
		net install grc1leg2.pkg, from (http://digital.cgdev.org/doc/stata/MO/Misc/)
	}
}

if $packages_update {
	cap n gtools, upgrade
	cap n adoupdate, update
}

* define directories /// an user add thier system path below, and access the directories
global root = ""
foreach dir in ///
	"/Users/kotia/Dropbox" /// KOTIA MAC 
	"/users/kotiaa/Documents" /// KOTIA FABIAN SERVER
	"C:/Users/bhara/Dropbox" /// BHARAT'S PC 
	"C:/Users/NAILA FATIMA" /// NAILA WINDOWS
	"/Users/gabrielhill/Dropbox" /// GABRIEL MAC 
	"/Users/nailafatima/Library/CloudStorage/Dropbox" /// NAILA'S MAC
	"C:/Users/ayush/Dropbox" /// Ayush 
	"C:/Users/Meghana/Dropbox" /// Meghana 
	{
	confirmdir "`dir'"
	if !_rc global root = "`dir'"
}

if "${root}" == "" {
	di as error "USER ERROR: Cannot find main directory (\$root)!"
	error 1
}

else if "${root}" == "C:/Users/bhara/Dropbox" {
	global idl "$root/idl"
	global idl_git "C:/Users/bhara/OneDrive/Informal_Formal_Report/Documents/Github/idli_ext"
	global nic_concordances "$root/nic_concordances/data/clean"
}

else if "${root}" == "/Users/kotia/Dropbox" {
	global idl "$root/idl"
	global idl_git "Users/kotia/Documents/Github/idl"
	global nic_concordances "$root/nic_concordances/data/clean"
}

else if "${root}" == "C:/Users/NAILA FATIMA" {
   	global idl "$root/Dropbox/idl"
	global ida "$root/Dropbox/india_labor"
	global idl_git "$root/Documents/GitHub/idl"
	global nic_concordances "$root/Dropbox/nic_concordances/data/clean"
	global asi_state_nic "$root/Dropbox/ASI state x nic3"

}

else if "${root}" == "/Users/nailafatima/Library/CloudStorage/Dropbox" {
   	global idl "$root/idl"
	global ida "$root/india_labor"
	global idl_git "/Users/nailafatima/Documents/GitHub/idl"
	global nic_concordances "$root/nic_concordances/data/clean"
	global asi_state_nic "$root/ASI state x nic3"

}
else if "${root}" == "C:/Users/ayush/Dropbox" {
	global idl "$root/idl"
	global idl_git "C:\Users\ayush\OneDrive\Documents\idl"
	global nic_concordances "$root/nic_concordances/data/clean"
}

else if "${root}" == "C:\Users\Meghana\Dropbox" {
	global idl "$root\idl"
	global idl_git "C:\Users\Meghana\OneDrive\Documents\GitHub\idl"
	global nic_concordances "$root\nic_concordances\data\clean"
}

else {
	global idl "$root/Research/idl"
}


* NSS
global nss "$idl/nss"
global nss_lab "$nss/labour"
global nss_ent "$nss/enterprise"
global nss_cons "$nss/consumption"
global dist "$nss/district"
global shrug "$nss/district/shrug"
global code "$idl_git/code"

global asi "$idl/asi"



global fig "$idl/output/fig"

* for figs
grstyle init
grstyle set plain
grstyle set color Set1
grstyle set symbol
grstyle set lpattern
grstyle set nogrid
grstyle linestyle legend none
grstyle set legend, inside
grstyle set linewidth 2.4pt: plineplot
*grstyle set graphsize 10cm 10cm
grstyle set margin "1pt 1pt 1pt 1pt": graph
graph set window fontface "Arial"



