**********************************************************************
******************* U.S Census Bureau Demographics *******************
**********************************************************************

cd "$root_data"

* Import Datasets for 2000-2009

	* 2009 By State
foreach state in 01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {
	import delimited "cc-est2009-alldata-`state'.csv"
	save "CENSUS_`state'"
	clear
}

* Clean Variables for Colorado and Alaska

	* Establish Global of Census Variables
global CENSUS_VARIABLES "tot_pop tot_male tot_female wa_male wa_female ba_male ba_female ia_male ia_female aa_male aa_female na_male na_female tom_male tom_female wac_male wac_female bac_male bac_female iac_male iac_female aac_male aac_female nac_male nac_female nh_male nh_female nhwa_male nhwa_female nhba_male nhba_female nhia_male nhia_female nhaa_male nhaa_female nhna_male nhna_female nhtom_male nhtom_female nhwac_male nhwac_female nhbac_male nhbac_female nhiac_male nhiac_female nhaac_male nhaac_female nhnac_male nhnac_female h_male h_female hwa_male hwa_female hba_male hba_female hia_male hia_female haa_male haa_female hna_male hna_female htom_male htom_female hwac_male hwac_female hbac_male hbac_female hiac_male hiac_female haac_male haac_female hnac_male hnac_female"

	* Destring Census Variables
foreach dataset in CENSUS_02 CENSUS_08 {
	* Use Dataset
use `dataset'
	foreach variable of global CENSUS_VARIABLES {
		* Recode Missing Values
	replace `variable' = "." if `variable' == "X"
		* Destring Variables
	destring `variable', replace
	}
	* Save Dataset
save, replace
clear
}

* Append Datasets from 2000-2009
use "CENSUS_01"
append using "CENSUS_02" "CENSUS_04" "CENSUS_05" "CENSUS_06" "CENSUS_08" "CENSUS_09" "CENSUS_10" "CENSUS_11" "CENSUS_12" "CENSUS_13" "CENSUS_15" "CENSUS_16" "CENSUS_17" "CENSUS_18" "CENSUS_19" "CENSUS_20" "CENSUS_21" "CENSUS_22" "CENSUS_23" "CENSUS_24" "CENSUS_25" "CENSUS_26" "CENSUS_27" "CENSUS_28" "CENSUS_29" "CENSUS_30" "CENSUS_31" "CENSUS_32" "CENSUS_33" "CENSUS_34" "CENSUS_35" "CENSUS_36" "CENSUS_37" "CENSUS_38" "CENSUS_39" "CENSUS_40" "CENSUS_41" "CENSUS_42" "CENSUS_44" "CENSUS_45" "CENSUS_46" "CENSUS_47" "CENSUS_48" "CENSUS_49" "CENSUS_50" "CENSUS_51" "CENSUS_53" "CENSUS_54" "CENSUS_55" "CENSUS_56"

	* Drop All Years Not in Panel
drop if year < 11

	* Recode Year Codes to Years
replace year = 2008 if year == 11
replace year = 2009 if year == 12

	* Save Census Dataset from 2000-2009
save "CENSUS_2009"
clear

* Import Dataset - Demographics (Whole Population)
import delimited "cc-est2019-alldata.csv", encoding(ISO-8859-9)

	* Drop All Years Not in Panel
drop if year < 3

	* Recode Year Codes to Years
replace year = 2010 if year == 3
replace year = 2011 if year == 4
replace year = 2012 if year == 5
replace year = 2013 if year == 6
replace year = 2014 if year == 7
replace year = 2015 if year == 8
replace year = 2016 if year == 9
replace year = 2017 if year == 10
replace year = 2018 if year == 11
replace year = 2019 if year == 12

	* Save Census Dataset from 2010-2019
save "CENSUS_2019"
clear

* Append Census Datasets
use "CENSUS_2009"
append using "CENSUS_2019"

	* Rename Variables
rename state state_fips
rename stname state
rename county county_fips
rename ctyname county

	* Standardize County Names
replace county = "Anchorage Municipality" if county == "Anchorage Borough/municipality"
replace county = "Broomfield County" if county == "Broomfield County/city"
replace county = "Denver County" if county == "Denver County/city"
replace county = "Doña Ana County" if county == "Dońa Ana County"
replace county = "Doña Ana County" if county == "Dona Ana County"
replace county = "Honolulu County" if county == "Honolulu County/city"
replace county = "Juneau City and Borough" if county == "Juneau Borough/city"
replace county = "Kusilvak Census Area" if county == "Wade Hampton Census Area"
replace county = "LaSalle Parish" if county == "La Salle Parish"
replace county = "Nantucket County" if county == "Nantucket County/town"
replace county = "Oglala Lakota County" if county == "Shannon County" & state == "South Dakota"
replace county = "Philadelphia County" if county == "Philadelphia County/city"
replace county = "San Francisco County" if county == "San Francisco County/city"
replace county = "Sitka City and Borough" if county == "Sitka Borough/city"
replace county = "Yakutat City and Borough" if county == "Yakutat Borough/city"
drop if county == "Kalawao County"
drop if county == "Bedford city"
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

	* Save Full Census Dataset from 2000-2019
save "CENSUS_2000_2019"

* Create Full Census Demographics Dataset
drop if agegrp != 0
drop agegrp
save "CENSUS_FULL"
clear

* Create Under 65 Demographics Dataset

	* Use Dataset
use CENSUS_2000_2019

	* Drop All Age Groups Over 65 and Totals
drop if agegrp > 13 | agegrp == 0

	* Generate Total Under 65 Population Variables
foreach variable of global CENSUS_VARIABLES {
sort state county year agegrp
bysort state county year: egen `variable'_under65 = total(`variable')
drop `variable'
}

	* Drop Extraneous Observations
drop if agegrp != 1
drop agegrp

	* Save Dataset
save "CENSUS_UNDER65"
clear

* Create Over 65 Demographics Dataset

	* Use Dataset
use CENSUS_2000_2019

	* Drop All Age Groups Over 65 and Totals
drop if agegrp < 14 | agegrp == 0

	* Generate Total Over 65 Population Variables
foreach variable of global CENSUS_VARIABLES {
sort state county year agegrp
bysort state county year: egen `variable'_over65 = total(`variable')
drop `variable'
}

	* Drop Extraneous Observations
drop if agegrp != 14
drop agegrp

	* Save Dataset
save "CENSUS_OVER65"
clear

* Create 20-65 Demographics Dataset

	* Use Dataset
use CENSUS_2000_2019

	* Drop All Age Groups Outside of 20-65 and Totals
drop if agegrp == 0 | agegrp < 5 | agegrp > 13

	* Generate Total 20-65 Population Variables
foreach variable of global CENSUS_VARIABLES {
sort state county year agegrp
bysort state county year: egen `variable'_20to65 = total(`variable')
drop `variable'
}

	* Drop Extraneous Observations
drop if agegrp != 10
drop agegrp

	* Save Dataset
save "CENSUS_20to65"
clear

* Merge Census Demographic Datasets

	* Use Full Dataset
use CENSUS_FULL

foreach i in UNDER65 OVER65 20to65 {
	merge 1:1 state county year using CENSUS_`i'
	drop _merge
}

* Save Final Census Dataset
save "$root_final/CENSUS.dta"
clear
