**********************************************************************
****************** BUREAU OF LABOR STATISTICS (BLS) ******************
**********************************************************************

global user = "wilsonking"
global root = "/Users/$user/Documents/Github/Medicaid"

foreach year in 08 09 10 11 12 13 14 15 16 17 18 19 {
	import excel "/$file_path_root/RAW DATA/laucnty`year'.xlsx", sheet("laucnty`year'") firstrow
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

drop if inlist(county, "Prince of Wales-Hyder Census Area", "Prince of Wales-Outer Ketchikan Census Area", "Skagway-Hoonah-Angoon Census Area" "Hoonah-Angoon Census Area" "Skagway Municipality" "Petersburg Borough" "Wrangell-Petersburg Census Area" "Wrangell City and Borough" "Wrangell Borough/city" "Petersburg Borough/Census Area")

save "BLS"
clear
