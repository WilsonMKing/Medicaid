**********************************************************************
****************** BUREAU OF LABOR STATISTICS (BLS) ******************
**********************************************************************

cd "$root_data"

foreach year in 08 09 10 11 12 13 14 15 16 17 18 19 {
	import excel "laucnty`year'.xlsx", sheet("laucnty`year'") firstrow
	save "BLS_`year'"
	clear
}

use "BLS_08", clear
append using "BLS_09" "BLS_10" "BLS_11" "BLS_12" "BLS_13" "BLS_14" "BLS_15" "BLS_16" "BLS_17" "BLS_18" "BLS_19"

drop if StateFIPSCode == "" & CountyFIPSCode == ""

split CountyNameStateAbbreviation, parse(,)
rename CountyNameStateAbbreviation1 county
rename CountyNameStateAbbreviation2 post_code
drop CountyNameStateAbbreviation

generate post_code1 = subinstr(post_code," ","", 1)
drop post_code
rename post_code1 post_code
drop if post_code == "PR"

rename LAUSCode laus
rename StateFIPSCode state_fips
rename CountyFIPSCode county_fips
rename LaborForce labor_force
rename Employed employed
rename Unemployed unemployed
rename UnemploymentRate unemployment_rate
rename Year year

destring state_fips county_fips year, replace

replace post_code = "DC" if county == "District of Columbia"
replace county = "San Francisco County" if county == "San Francisco County/city"
replace county = "Honolulu County" if county == "Honolulu County/city"
replace county = "Juneau City and Borough" if county == "Juneau Borough/city"
replace county = "Nantucket County" if county == "Nantucket County/town"
replace county = "Philadelphia County" if county == "Philadelphia County/city"
replace county = "Sitka City and Borough" if county == "Sitka Borough/city"
replace county = "Yakutat City and Borough" if county == "Yakutat Borough/city"
replace county = "Doña Ana County" if county == "Dona Ana County"
replace county = "Denver County" if county == "Denver County/city"
replace county = "Broomfield County" if county == "Broomfield County/city"
replace county = "Anchorage Municipality" if county == "Anchorage Borough/municipality"
drop if county == "Bedford city"
drop if county == "Kalawao County"
drop if county == "Skagway Municipality"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"

save "$root_final/BLS"
clear
