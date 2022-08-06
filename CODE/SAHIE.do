**********************************************************************
**************** Small Area Health Insurance Estimates ***************
**********************************************************************

cd "$root_data"

* Import Datasets


foreach year in 08 09 10 11 12 13 14 17 18 19 {
	import delimited "sahie20`year'", encoding(ISO-8859-9)
	drop version v26
	save "SAHIE_20`year'"
	clear
}

foreach year in 15 16 {
	import delimited "sahie20`year'", encoding(ISO-8859-9)
	drop v26
	save "SAHIE_20`year'"
	clear
}

global SAHIE "SAHIE_2008 SAHIE_2009 SAHIE_2010 SAHIE_2011 SAHIE_2012 SAHIE_2013 SAHIE_2014 SAHIE_2015 SAHIE_2016 SAHIE_2017 SAHIE_2018 SAHIE_2019"

foreach dataset of global SAHIE {
	use `dataset'
	* Drop Extraneous Observations
	drop if racecat != 0 | agecat != 0 | sexcat != 0 | iprcat != 0 | countyfips == 0
	* Drop Extraneous Variables
	drop agecat racecat sexcat iprcat nipr_moe nui_moe nic_moe pctui_moe pctic_moe pctelig_moe pctliic_moe
	* Rename Variables
	rename state_name state
	rename county_name county
	rename countyfips county_fips
	rename statefips state_fips
	* Remove Extraneous Blanks from String Variables
replace state = strtrim(state)
replace county = strtrim(county)
	* Standardize County Names
replace county = "Anchorage Municipality" if county == "Anchorage Borough"
replace county = "DeKalb County" if county == "De Kalb County"
replace county = "De Baca County" if county == "DeBaca County"
replace county = "Doña Ana County" if county == "Dona Ana County"
replace county = "Juneau City and Borough" if county == "Juneau Borough"
replace county = "LaPorte County" if county == "La Porte County"
replace county = "Oglala Lakota County" if county == "Shannon County" & state == "South Dakota"
replace county = "Sitka City and Borough" if county == "Sitka Borough"
replace county = "McKean County" if county == "Mc Kean County"
replace county = "Kusilvak Census Area" if county == "Wade Hampton Census Area"
replace county = "Yakutat City and Borough" if county == "Yakutat Borough"
replace county = "LaGrange County" if county == "Lagrange County"
replace county = "LaSalle Parish" if county == "La Salle Parish"
replace county = "LaSalle County" if county == "La Salle County" & state == "Illinois"
drop if county == "Bedford city"
drop if county == "Kalawao County"
drop if county == "Skagway Municipality"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
	* Save Dataset
	save "`dataset'_ALL"
	clear
}

foreach dataset of global SAHIE {
	use `dataset'
	* Drop Extraneous Observations
	drop if racecat != 0 | agecat != 0 | sexcat != 0 | iprcat != 1 | countyfips == 0
	* Drop Extraneous Variables
	drop agecat racecat sexcat iprcat nipr_moe nui_moe nic_moe pctui_moe pctic_moe pctelig_moe pctliic_moe
	* Rename Variables
	foreach var of varlist nipr nui nic pctui pctic pctelig pctliic {
		rename `var' `var'_200
	}
	rename state_name state
	rename county_name county
	rename countyfips county_fips
	rename statefips state_fips
	* Remove Extraneous Blanks from String Variables
replace state = strtrim(state)
replace county = strtrim(county)
	* Standardize County Names
replace county = "Anchorage Municipality" if county == "Anchorage Borough"
replace county = "DeKalb County" if county == "De Kalb County"
replace county = "De Baca County" if county == "DeBaca County"
replace county = "Doña Ana County" if county == "Dona Ana County"
replace county = "Juneau City and Borough" if county == "Juneau Borough"
replace county = "LaPorte County" if county == "La Porte County"
replace county = "Oglala Lakota County" if county == "Shannon County" & state == "South Dakota"
replace county = "Sitka City and Borough" if county == "Sitka Borough"
replace county = "McKean County" if county == "Mc Kean County"
replace county = "Kusilvak Census Area" if county == "Wade Hampton Census Area"
replace county = "Yakutat City and Borough" if county == "Yakutat Borough"
replace county = "LaGrange County" if county == "Lagrange County"
replace county = "LaSalle Parish" if county == "La Salle Parish"
replace county = "LaSalle County" if county == "La Salle County" & state == "Illinois"
drop if county == "Bedford city"
drop if county == "Kalawao County"
drop if county == "Skagway Municipality"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
	* Save Dataset
	save "`dataset'_200"
	clear
}

foreach dataset of global SAHIE {
	use `dataset'
	* Drop Extraneous Observations
	drop if racecat != 0 | agecat != 1 | sexcat != 0 | iprcat != 1 | countyfips == 0
	* Drop Extraneous Variables
	drop agecat racecat sexcat iprcat nipr_moe nui_moe nic_moe pctui_moe pctic_moe pctelig_moe pctliic_moe
	* Rename Variables
	foreach var of varlist nipr nui nic pctui pctic pctelig pctliic {
		rename `var' `var'_200_18to64
	}
	rename state_name state
	rename county_name county
	rename countyfips county_fips
	rename statefips state_fips
	* Remove Extraneous Blanks from String Variables
replace state = strtrim(state)
replace county = strtrim(county)
	* Standardize County Names
replace county = "Anchorage Municipality" if county == "Anchorage Borough"
replace county = "DeKalb County" if county == "De Kalb County"
replace county = "De Baca County" if county == "DeBaca County"
replace county = "Doña Ana County" if county == "Dona Ana County"
replace county = "Juneau City and Borough" if county == "Juneau Borough"
replace county = "LaPorte County" if county == "La Porte County"
replace county = "Oglala Lakota County" if county == "Shannon County" & state == "South Dakota"
replace county = "Sitka City and Borough" if county == "Sitka Borough"
replace county = "McKean County" if county == "Mc Kean County"
replace county = "Kusilvak Census Area" if county == "Wade Hampton Census Area"
replace county = "Yakutat City and Borough" if county == "Yakutat Borough"
replace county = "LaGrange County" if county == "Lagrange County"
replace county = "LaSalle Parish" if county == "La Salle Parish"
replace county = "LaSalle County" if county == "La Salle County" & state == "Illinois"
drop if county == "Bedford city"
drop if county == "Kalawao County"
drop if county == "Skagway Municipality"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
	* Save Dataset
	save "`dataset'_200_18to64"
	clear
}

* Append Datasets - Under 65 Population

use SAHIE_2008_ALL
append using SAHIE_2009_ALL SAHIE_2010_ALL SAHIE_2011_ALL SAHIE_2012_ALL SAHIE_2013_ALL SAHIE_2014_ALL SAHIE_2015_ALL SAHIE_2016_ALL SAHIE_2017_ALL SAHIE_2018_ALL SAHIE_2019_ALL
save SAHIE_ALL
clear

* Append Datasets - Under 65/Under 200% of PL Population

use SAHIE_2008_200
append using SAHIE_2009_200 SAHIE_2010_200 SAHIE_2011_200 SAHIE_2012_200 SAHIE_2013_200 SAHIE_2014_200 SAHIE_2015_200 SAHIE_2016_200 SAHIE_2017_200 SAHIE_2018_200 SAHIE_2019_200
save SAHIE_200
clear

* Append Datasets - 18 to 64/Under 200% of PL Population

use SAHIE_2008_200_18to64
append using SAHIE_2009_200_18to64 SAHIE_2010_200_18to64 SAHIE_2011_200_18to64 SAHIE_2012_200_18to64 SAHIE_2013_200_18to64 SAHIE_2014_200_18to64 SAHIE_2015_200_18to64 SAHIE_2016_200_18to64 SAHIE_2017_200_18to64 SAHIE_2018_200_18to64 SAHIE_2019_200_18to64
save SAHIE_200_18to64
clear

* Merge Datasets

use SAHIE_ALL
merge 1:1 county state year using SAHIE_200
drop _merge
merge 1:1 county state year using SAHIE_200_18to64
drop _merge

* Save Dataset
save "$root_final/SAHIE.dta"
clear
