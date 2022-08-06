**********************************************************************
*********************** SUTVA: MIGRATION RATES ***********************
**********************************************************************

cd "$root_data"

import delimited "co-est2019-alldata.csv"

* Drop State Observations
drop if county == 0

* Rename Variables
rename county county_fips
rename state state_fips
rename stname state
rename ctyname county

* Drop Extraneous Variables
keep county_fips state_fips county state region division domesticmig* netmig* internationalmig* rdomesticmig* rnetmig* rinternationalmig*

* Generate Identification Variables
egen county_state = concat(county state), punct(,)
encode county_state, generate(county_state_id)
drop county_state

* Reshape Dataset
reshape long domesticmig netmig internationalmig rdomesticmig rnetmig rinternationalmig, i(county_state_id) j(year)
drop county_state_id

* Drop Extraneous Year
drop if year == 2010

* Save Dataset
save MIGRATION_2010_2019
clear

import delimited "co-est2009-alldata.csv"

* Drop State Observations
drop if county == 0

* Rename Variables
rename county county_fips
rename state state_fips
rename stname state
rename ctyname county

* Drop Extraneous Variables
keep county_fips state_fips county state region division domesticmig* netmig* internationalmig* rdomesticmig* rnetmig* rinternationalmig*

* Generate Identification Variables
egen county_state = concat(county state), punct(,)
encode county_state, generate(county_state_id)
drop county_state

* Reshape Dataset
reshape long domesticmig netmig internationalmig rdomesticmig rnetmig rinternationalmig, i(county_state_id) j(year)
drop county_state_id

* Remove Extraneous Years
replace year = 2010 if year == 2009
replace year = 2009 if year == 2008
replace year = 2008 if year == 2007
drop if year < 2008

* Save Dataset
save MIGRATION_2000_2009
clear

* Append Datasets
use MIGRATION_2010_2019
append using MIGRATION_2000_2009

replace county = "Sitka City and Borough" if county == "Sitka Borough"
replace county = "Kusilvak Census Area" if county == "Wade Hampton Census Area"
replace county = "Oglala Lakota County" if county == "Shannon County" & state == "South Dakota"
replace county = "McKean County" if county == "Mc Kean County"
replace county = "LaGrange County" if county == "Lagrange County"
replace county = "LaPorte County" if county == "La Porte County"
replace county = "Juneau City and Borough" if county == "Juneau Borough"
replace county = "Doña Ana County" if county == "Dona Ana County"
replace county = "De Baca County" if county == "DeBaca County"
replace county = "DeKalb County" if county == "De Kalb County"
replace county = "Anchorage Municipality" if county == "Anchorage Borough"
replace county = "LaSalle Parish" if county == "La Salle Parish"
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

label define regionlbl 1 "Northeast" 2 "Midwest" 3 "South" 4 "West"
label value region regionlbl

save "$root_final/MIGRATION.dta"
clear
