**********************************************************************
**************** NCHS URBAN-RURAL CLASSIFICATION SCHEME **************
**********************************************************************

cd "$root_data"

import excel "NCHSURCodes2013 (1)", sheet("NCHSURCodes2013") firstrow

* Clean Dataset

	* Drop Extraneous Variables
drop J H basedcode CBSA2012pop County2012pop CBSAtitle

	* Rename Variables
rename StateAbr post_code
rename Countyname county
rename FIPScode fips
rename code nchsur_code

	* Label Variables
label define nchsur_codelbl 1 "Large central metro" 2 "Large fringe metro" 3 "Medium metro" 4 "Small metro" 5 "Micropolitan (nonmetropolitan)" 6 "Noncore (nonmetropolitan)"
label value nchsur_code nchsur_codelbl

	* Generate FIPS Variable
tostring fips, replace
replace fips = substr(5 * "0", 1, 5 - length(fips)) + fips

	* Clean County Names
replace county = "Sitka City and Borough" if county == "Sitka Borough"
replace county = "Kusilvak Census Area" if county == "Wade Hampton Census Area"
replace county = "Sitka City and Borough" if county == "Sitka Borough"
replace county = "Oglala Lakota County" if county == "Shannon County" & post_code == "SD"
replace county = "McKean County" if county == "Mc Kean County"
replace county = "LaGrange County" if county == "Lagrange County"
replace county = "LaPorte County" if county == "La Porte County"
replace county = "Juneau City and Borough" if county == "Juneau Borough"
replace county = "Doña Ana County" if county == "Dona Ana County"
replace county = "De Baca County" if county == "DeBaca County"
replace county = "DeKalb County" if county == "De Kalb County"
replace county = "Anchorage Municipality" if county == "Anchorage Borough"
replace county = "LaSalle County" if county == "La Salle County" & post_code == "IL"
drop if county == "Bedford city"
drop if county == "Kalawao County"
drop if county == "Skagway Municipality"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Prince of Wales-Outer Ket"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Clifton Forge city"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
drop if county == "Oglala Lakota County" & fips == "46113"
drop if county == "Kusilvak Census Area" & fips == "02270"

	* Generate Rural Variable
generate rural = 0
replace rural = 1 if nchsur_code > 4

* Save Dataset
save "$root_final/NCHSUR.dta"
clear
