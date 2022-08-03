**********************************************************************
**************** EC331 Thesis - Data Cleaning Do File ****************
**********************************************************************

/* 

* By: Wilson King
* Last Updated: 5 May 2022

This .do file downloads and cleans the datasets associated with "Medicaid
Eligibility & Mortality: Evidence from the Affordable Care Act."

All input files are available in the associated replication package zip.

Final Output Files

FINAL: Full Dataset
FINAL_10: Full Dataset (Population > 10,000)
FINAL_15: Full Dataset (Population > 15,000)
FINAL_20: Full Dataset (Population > 20,000)
FINAL_2014: 2014 Expansion States
FINAL_PAIRS: Non-Expansion/2014 Expansion Border Counties
FINAL_POST2014: No Post-2014 Expansion States
FINAL_PRE2014: No Pre-2014 Expansion States

*/

**********************************************************************
*************************** DATA CLEANING ****************************
**********************************************************************

* Define Input Directory
	
global WORKING_DIRECTORY "/Users/wilsonking/Desktop/EC331 Thesis"
cd "$WORKING_DIRECTORY"

**********************************************************************
****************** BUREAU OF LABOR STATISTICS (BLS) ******************
**********************************************************************

* Import Datasets

foreach year in 08 09 10 11 12 13 14 15 16 17 18 19 {
	import excel "laucnty`year'.xlsx", sheet("laucnty`year'") firstrow
	save "BLS_`year'"
	clear
}

* Combine Datasets
use "BLS_08", clear
append using "BLS_09" "BLS_10" "BLS_11" "BLS_12" "BLS_13" "BLS_14" "BLS_15" "BLS_16" "BLS_17" "BLS_18" "BLS_19"

* Clean Dataset

	* Drop Extraneous Information
drop if StateFIPSCode == "" & CountyFIPSCode == ""

	* Delimit County, State Variable
split CountyNameStateAbbreviation, parse(,)
drop CountyNameStateAbbreviation
rename CountyNameStateAbbreviation1 county
rename CountyNameStateAbbreviation2 post_code

	* Drop Puerto Rico
generate post_code1 = subinstr(post_code," ","", 1)
drop post_code
rename post_code1 post_code
drop if post_code == "PR"

	* Rename Variables
rename LAUSCode laus
rename StateFIPSCode state_fips
rename CountyFIPSCode county_fips
rename LaborForce labor_force
rename Employed employed
rename Unemployed unemployed
rename UnemploymentRate unemployment_rate
rename Year year

	* Destring Variables
destring state_fips county_fips year, replace

	* Clean County Names
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
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
drop if county == "Petersburg Borough"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"

* Save Full BLS Dataset
save "BLS"
clear

**********************************************************************
******************* U.S Census Bureau Demographics *******************
**********************************************************************

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
import delimited "cc-est2019-alldata", encoding(ISO-8859-9)

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
drop if county == "Bedford city"
replace county = "Doña Ana County" if county == "Dońa Ana County"
replace county = "LaSalle Parish" if county == "La Salle Parish"
drop if county == "Skagway Municipality"
replace county = "Kusilvak Census Area" if county == "Wade Hampton Census Area"
replace county = "Oglala Lakota County" if county == "Shannon County" & state == "South Dakota"
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
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
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

	* Merge Under 65 Dataset
merge 1:1 state county year using CENSUS_UNDER65
drop _merge

	* Merge Over 65 Dataset
merge 1:1 state county year using CENSUS_OVER65
drop _merge

	* Merge 20-65 Dataset
merge 1:1 state county year using CENSUS_20to65
drop _merge

* Save Final Census Dataset
save CENSUS
clear

**********************************************************************
*************** Small Area Income and Poverty Estimates **************
**********************************************************************

* Import Datasets

	* Import 2008
import excel "est08all.xls", sheet("est08ALL") firstrow

	* Generate Year Variable for 2008
generate year = 2008

	* Drop Extraneous Variables and Rows for 2008
drop CILowerBound CIUpperBound I J L M O P R S U V X Y AA AB AD AE

	* Standardize Variable Names for 2008
rename PovertyEstimateUnderAge18 PovertyEstimateAge017
rename PovertyPercentUnderAge18 PovertyPercentAge017
rename PovertyEstimateAges517 PovertyEstimateAge517
rename PovertyPercentAges517 PovertyPercentAge517
rename PovertyEstimateAges04 PovertyEstimateAge04
rename PovertyPercentAges04 PovertyPercentAge04
save "SAIPE_08"
clear

	* Import 2009
import excel "est09all.xls", sheet("est09ALL") firstrow

	* Generate Year Variable for 2009
generate year = 2009

	* Drop Extraneous Variables and Rows for 2009
drop CILowerBound CIUpperBound I J L M O P R S U V X Y AA AB AD AE

	* Standardize Variable Names for 2009
rename PovertyEstimateUnderAge18 PovertyEstimateAge017
rename PovertyPercentUnderAge18 PovertyPercentAge017
rename PovertyEstimateAges517 PovertyEstimateAge517
rename PovertyPercentAges517 PovertyPercentAge517
rename PovertyEstimateAges04 PovertyEstimateAge04
rename PovertyPercentAges04 PovertyPercentAge04
save "SAIPE_09"
clear

	* Import 2010
import excel "est10all.xls", sheet("est10ALL") firstrow

	* Generate Year Variable for 2010
generate year = 2010

	* Drop Extraneous Variables and Rows for 2010
drop CILowerBound CIUpperBound I J L M O P R S U V X Y AA AB AD AE
drop in 3196/3198

	* Standardize Variable Names for 2010
rename PovertyEstimateUnderAge18 PovertyEstimateAge017
rename PovertyPercentUnderAge18 PovertyPercentAge017
rename PovertyEstimateAges517 PovertyEstimateAge517
rename PovertyPercentAges517 PovertyPercentAge517
rename PovertyEstimateAges04 PovertyEstimateAge04
rename PovertyPercentAges04 PovertyPercentAge04
save "SAIPE_10"
clear

	* Import 2011
import excel "est11all.xls", sheet("est11ALL") firstrow

	* Generate Year Variable for 2011
generate year = 2011

	* Drop Extraneous Variables and Rows for 2011
drop CILowerBound CIUpperBound J K M N P Q S T V W Y Z AB AC
drop in 3196/3198

	* Standardize Variable Names for 2011
rename PovertyEstimateUnderAge18 PovertyEstimateAge017
rename PovertyPercentUnderAge18 PovertyPercentAge017
rename PovertyEstimateAges517 PovertyEstimateAge517
rename PovertyPercentAges517 PovertyPercentAge517
rename PovertyEstimateAges04 PovertyEstimateAge04
rename PovertyPercentAges04 PovertyPercentAge04
save "SAIPE_11"
clear

	* Import 2012
import excel "est12all.xls", sheet("est12all") firstrow

	* Generate Year Variable for 2012
generate year = 2012

	* Drop Extraneous Variables for 2012
drop CILowerBound CIUpperBound I J L M O P R S U V X Y AA AB AD AE

	* Standardize Variables for 2012
rename PovertyEstimateUnderAge18 PovertyEstimateAge017
rename PovertyPercentUnderAge18 PovertyPercentAge017
rename PovertyEstimateAges517 PovertyEstimateAge517
rename PovertyPercentAges517 PovertyPercentAge517
rename PovertyEstimateAges04 PovertyEstimateAge04
rename PovertyPercentAges04 PovertyPercentAge04
save "SAIPE_12"
clear

	* Import 2013
import excel "est13all.xls", sheet("est13ALL") firstrow

	* Generate Year Variable for 2013
generate year = 2013

	* Drop Extraneous Variables for 2013
drop CILowerBound CIUpperBound I J L M O P R S U V X Y AA AB AD AE
save "SAIPE_13"
clear

	* Import 2014
import excel "est14all.xls", sheet("est14ALL") firstrow

	* Generate Year Variable for 2014
generate year = 2014

	* Drop Extraneous Variables for 2014
drop CILowerBound CIUpperBound I J L M O P R S U V X Y AA AB AD AE
save "SAIPE_14"
clear

	* Import 2015
import excel "est15all.xls", sheet("est15ALL") firstrow

	* Generate Year Variable for 2015
generate year = 2015

	* Drop Extraneous Variables for 2015
drop CILowerBound CIUpperBound I J L M O P R S U V X Y AA AB AD AE
save "SAIPE_15"
clear

	* Import 2016
import excel "est16all.xls", sheet("est16ALL") firstrow

	* Generate Year Variable for 2016
generate year = 2016

	* Drop Extraneous Variables for 2016
drop CILowerBound CIUpperBound I J L M O P R S U V X Y AA AB AD AE
save "SAIPE_16"
clear

	* Import 2017
import excel "est17all.xls", sheet("est17ALL") firstrow

	* Generate Year Variable for 2017
generate year = 2017

	* Drop Extraneous Variables for 2017
drop CILowerBound CIUpperBound I J L M O P R S U V X Y AA AB AD AE
save "SAIPE_17"
clear

	* Import 2018
import excel "est18all.xls", sheet("est18ALL") firstrow

	* Generate Year Variable for 2018
generate year = 2018

	* Drop Extraneous Variables for 2018
drop CILowerBound CIUpperBound I J L M O P R S U V X Y AA AB AD AE
save "SAIPE_18"
clear

	* Import 2019
import excel "est19all.xls", sheet("est19ALL") firstrow

	* Generate Year Variable for 2019
generate year = 2019

	* Drop Extraneous Variables for 2019
drop CILowerBound CIUpperBound I J L M O P R S U V X Y AA AB AD AE
save "SAIPE_19"
clear

global SAIPE "SAIPE_08 SAIPE_09 SAIPE_10 SAIPE_11 SAIPE_12 SAIPE_13 SAIPE_14 SAIPE_15 SAIPE_16 SAIPE_17 SAIPE_18 SAIPE_19"

* Clean Dataset

	* Drop Notes and Rename/Drop/Destring Variables
foreach dataset of global SAIPE {
	use `dataset'
		* Rename Variables
	rename StateFIPS state_fips
	rename CountyFIPS county_fips
	rename Postal post_code
	rename Name county
	rename PovertyEstimateAllAges pov_est_all
	rename PovertyPercentAllAges pov_pct_all
	rename PovertyEstimateAge017 pov_est_under_18
	rename PovertyPercentAge017 pov_pct_under_18
	rename PovertyEstimateAge517 pov_est_5to17
	rename PovertyPercentAge517 pov_pct_5to17
	rename MedianHouseholdIncome med_house_income
	* Clean County Names
	replace county = "Anchorage Municipality" if county == "Anchorage Borough"
	replace county = "De Baca County" if county == "DeBaca County"
	replace county = "DeKalb County" if county == "De Kalb County"
	replace county = "Doña Ana County" if county == "Dona Ana County"
	replace county = "Juneau City and Borough" if county == "Juneau Borough"
	replace county = "LaPorte County" if county == "La Porte County"
	replace county = "LaGrange County" if county == "Lagrange County"
	replace county = "LaSalle County" if county == "La Salle County" & post_code == "IL"
	replace county = "LaSalle Parish" if county == "La Salle Parish"
	replace county = "McKean County" if county == "Mc Kean County"
	replace county = "Oglala Lakota County" if county == "Shannon County" & post_code == "SD"
	replace county = "Sitka City and Borough" if county == "Sitka Borough"
	replace county = "Kusilvak Census Area" if county == "Wade Hampton Census Area"
	replace county = "Yakutat City and Borough" if county == "Yakutat Borough"
	drop if county == "Bedford city"
	drop if county == "Skagway Municipality"
	drop if county == "Prince of Wales-Hyder Census Area"
	drop if county == "Prince of Wales-Outer Ketchikan Census Area"
	drop if county == "Skagway-Hoonah-Angoon Census Area"
	drop if county == "Hoonah-Angoon Census Area"
	drop if county == "Skagway Municipality"
	drop if county == "Petersburg Borough"
	drop if county == "Petersburg Census Area"
	drop if county == "Wrangell-Petersburg Census Area"
	drop if county == "Wrangell City and Borough"
	drop if county == "Wrangell Borough/city"
	drop if county == "Petersburg Borough/Census Area"
		* Drop Extraneous Variables
	drop PovertyEstimateAge04
	drop PovertyPercentAge04
		* Convert Strings to Numeric Variables
	destring county_fips state_fips pov_est_all pov_pct_all pov_est_under_18 pov_pct_under_18 pov_est_5to17 pov_pct_5to17 med_house_income, replace
		* Drop Extraneous Observations
	drop if county_fips == 0 | state_fips == 0
	save `dataset', replace
	clear
}

* Append Datasets

use "SAIPE_08"
append using "SAIPE_09" "SAIPE_10" "SAIPE_11" "SAIPE_12" "SAIPE_13" "SAIPE_14" "SAIPE_15" "SAIPE_16" "SAIPE_17" "SAIPE_18" "SAIPE_19"
save "SAIPE"
clear

**********************************************************************
**************** Small Area Health Insurance Estimates ***************
**********************************************************************

* Import Datasets

	* Import 2008
import delimited "sahie2008", encoding(ISO-8859-9)
drop version v26
save "SAHIE_2008"
clear

	* Import 2009
import delimited "sahie2009", encoding(ISO-8859-9)
drop version v26
save "SAHIE_2009"
clear

	* Import 2010
import delimited "sahie2010", encoding(ISO-8859-9)
drop version v26
save "SAHIE_2010"
clear

	* Import 2011
import delimited "sahie2011", encoding(ISO-8859-9)
drop version v26
save "SAHIE_2011"
clear

	* Import 2012
import delimited "sahie2012", encoding(ISO-8859-9)
drop version v26
save "SAHIE_2012"
clear

	* Import 2013
import delimited "sahie2013", encoding(ISO-8859-9)
drop version v26
save "SAHIE_2013"
clear

	* Import 2014
import delimited "sahie2014", encoding(ISO-8859-9)
drop version v26
save "SAHIE_2014"
clear

	* Import 2015
import delimited "sahie2015", encoding(ISO-8859-9)
drop v26
save "SAHIE_2015"
clear

	* Import 2016
import delimited "sahie2016", encoding(ISO-8859-9)
drop v26
save "SAHIE_2016"
clear

	* Import 2017
import delimited "sahie2017", encoding(ISO-8859-9)
drop version v26
save "SAHIE_2017"
clear

	* Import 2018
import delimited "sahie2018", encoding(ISO-8859-9)
drop version v26
save "SAHIE_2018"
clear

	* Import 2019
import delimited "sahie2019", encoding(ISO-8859-9)
drop version v26
save "SAHIE_2019"
clear

* Clean Datasets

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
drop if county == "Skagway Municipality"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
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
	rename nipr nipr_200
	rename nui nui_200
	rename nic nic_200
	rename pctui pctui_200
	rename pctic pctic_200
	rename pctelig pctelig_200
	rename pctliic pctliic_200
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
drop if county == "Skagway Municipality"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
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
	rename nipr nipr_200_18to64
	rename nui nui_200_18to64
	rename nic nic_200_18to64
	rename pctui pctui_200_18to64
	rename pctic pctic_200_18to64
	rename pctelig pctelig_200_18to64
	rename pctliic pctliic_200_18to64
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
drop if county == "Skagway Municipality"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
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
save SAHIE
clear

**********************************************************************
**************** NCHS URBAN-RURAL CLASSIFICATION SCHEME **************
**********************************************************************

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
drop if county == "Clifton Forge city"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ket"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
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
save NCHSUR
clear

**********************************************************************
*********************** SUTVA: MIGRATION RATES ***********************
**********************************************************************

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
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
label define regionlbl 1 "Northeast" 2 "Midwest" 3 "South" 4 "West"
label value region regionlbl
save MIGRATION
clear

**********************************************************************
****************************** GOVERNORS *****************************
**********************************************************************

import excel "governors.xlsx", first

* Clean Dataset
tab state if party == "Independent"
replace party = "Republican" if party == "Independent" & state == "Alaska"
replace party = "Democrat" if party == "Independent" & state == "Rhode Island"
label define governor 0 "Democrat" 1 "Republican"
encode party, generate(governor)
save GOVERNORS
clear

**********************************************************************
************************* Mortality By Cause *************************
**********************************************************************

* Import Datasets - CDC Total Death Rates for Population

foreach i of numlist 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	import delimited "All `i'.txt"
	generate year = `i'
	save CDC_ALL_`i'
	clear
}

* Clean Datasets - CDC Total Death Rates for Population

global CDCALL "CDC_ALL_2008 CDC_ALL_2009 CDC_ALL_2010 CDC_ALL_2011 CDC_ALL_2012 CDC_ALL_2013 CDC_ALL_2014 CDC_ALL_2015 CDC_ALL_2016 CDC_ALL_2017 CDC_ALL_2018 CDC_ALL_2019"

foreach dataset of global CDCALL {
	* Use Dataset
	use `dataset'
	* Drop Extraneous Variables
	drop notes
	* Split County Variable
	split county, parse(,)
	drop county
	rename county1 county
	rename county2 post_code
	* Clean Death Rate Variables
	replace cruderate = "." if cruderate == "Unreliable"
	destring cruderate, replace
	* Rename Variables
	rename population population_all
	rename deaths deaths_all
	rename cruderate cruderate_all
	* Drop Empty Observations
	drop if county == "." & post_code == "."
	drop if county == "" & post_code == ""
	* Clean Post Code Variable
	replace post_code = subinstr(post_code," ","", 1)
	* Clean County Names
	replace county = "Sitka City and Borough" if county == "Sitka Borough"
	replace county = "Kusilvak Census Area" if county == "Wade Hampton Census Area"
	replace county = "Sitka City and Borough" if county == "Sitka Borough"
	replace county = "Oglala Lakota County" if county == "Shannon County" & post_code == "SD"
	replace county = "Petersburg Borough" if county == "Petersburg Borough/Census Area"
	replace county = "McKean County" if county == "Mc Kean County"
	replace county = "LaGrange County" if county == "Lagrange County"
	replace county = "LaPorte County" if county == "La Porte County"
	replace county = "Juneau City and Borough" if county == "Juneau Borough"
	replace county = "Doña Ana County" if county == "Dona Ana County"
	replace county = "De Baca County" if county == "DeBaca County"
	replace county = "DeKalb County" if county == "De Kalb County"
	replace county = "Anchorage Municipality" if county == "Anchorage Borough"
drop if county == "Bedford city"
drop if county == "Skagway Municipality"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
	* Save Dataset
	save, replace
	clear
}

* Append Datasets - CDC Total Death Rates for Population

use CDC_ALL_2008
append using CDC_ALL_2009 CDC_ALL_2010 CDC_ALL_2011 CDC_ALL_2012 CDC_ALL_2013 CDC_ALL_2014 CDC_ALL_2015 CDC_ALL_2016 CDC_ALL_2017 CDC_ALL_2018 CDC_ALL_2019
drop ageadjustedrate
save CDC_ALL
clear

* Clean Datasets - CDC Death Rates for Population 25-64

foreach i of numlist 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	import delimited "20-64 `i'.txt"
	generate year = `i'
	save CDC_20to64_`i'
	clear
}

global CDC_20to64 "CDC_20to64_2008 CDC_20to64_2009 CDC_20to64_2010 CDC_20to64_2011 CDC_20to64_2012 CDC_20to64_2013 CDC_20to64_2014 CDC_20to64_2015 CDC_20to64_2016 CDC_20to64_2017 CDC_20to64_2018 CDC_20to64_2019"

foreach dataset of global CDC_20to64 {
	* Use Dataset
	use `dataset'
	* Drop Extraneous Variables
	drop notes
	* Split County Variable
	split county, parse(,)
	drop county
	rename county1 county
	rename county2 post_code
	* Clean Death Rate Variables
	replace cruderate = "." if cruderate == "Unreliable"
	destring cruderate, replace
	* Rename Variables
	rename population population_20to64
	rename deaths deaths_20to64
	rename cruderate cruderate_20to64
	* Drop Empty Observations
	drop if county == "." & post_code == "."
	drop if county == "" & post_code == ""
	* Clean Post Code Variable
	replace post_code = subinstr(post_code," ","", 1)
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
	drop if county == "Bedford city"
drop if county == "Skagway Municipality"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
	* Save Dataset
	save, replace
	clear
}

	* Apend Datasets - CDC Death Rates for 20-64

use CDC_20to64_2008
append using CDC_20to64_2009 CDC_20to64_2010 CDC_20to64_2011 CDC_20to64_2012 CDC_20to64_2013 CDC_20to64_2014 CDC_20to64_2015 CDC_20to64_2016 CDC_20to64_2017 CDC_20to64_2018 CDC_20to64_2019
save CDC_20to64
clear

* Clean Datasets - CDC Death Rates for Women 20-64

foreach i of numlist 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	import delimited "20-64 Women `i'.txt"
	generate year = `i'
	save CDC_20to64_WOMEN_`i'
	clear
}

global CDC_20to64_WOMEN "CDC_20to64_WOMEN_2008 CDC_20to64_WOMEN_2009 CDC_20to64_WOMEN_2010 CDC_20to64_WOMEN_2011 CDC_20to64_WOMEN_2012 CDC_20to64_WOMEN_2013 CDC_20to64_WOMEN_2014 CDC_20to64_WOMEN_2015 CDC_20to64_WOMEN_2016 CDC_20to64_WOMEN_2017 CDC_20to64_WOMEN_2018 CDC_20to64_WOMEN_2019"

foreach dataset of global CDC_20to64_WOMEN {
	* Use Dataset
	use `dataset'
	* Drop Extraneous Variables
	drop notes
	* Split County Variable
	split county, parse(,)
	drop county
	rename county1 county
	rename county2 post_code
	* Clean Death Rate Variables
	replace cruderate = "." if cruderate == "Unreliable"
	destring cruderate, replace
	* Rename Variables
	rename population population_20to64_women
	rename deaths deaths_20to64_women
	rename cruderate cruderate_20to64_women
	* Drop Empty Observations
	drop if county == "." & post_code == "."
	drop if county == "" & post_code == ""
	* Clean Post Code Variable
	replace post_code = subinstr(post_code," ","", 1)
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
	drop if county == "Bedford city"
drop if county == "Skagway Municipality"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
	* Save Dataset
	save, replace
	clear
}

	* Apend Datasets - CDC Death Rates for Women 20-64

use CDC_20to64_WOMEN_2008
append using CDC_20to64_WOMEN_2009 CDC_20to64_WOMEN_2010 CDC_20to64_WOMEN_2011 CDC_20to64_WOMEN_2012 CDC_20to64_WOMEN_2013 CDC_20to64_WOMEN_2014 CDC_20to64_WOMEN_2015 CDC_20to64_WOMEN_2016 CDC_20to64_WOMEN_2017 CDC_20to64_WOMEN_2018 CDC_20to64_WOMEN_2019
save CDC_20to64_WOMEN
clear

* Clean Datasets - CDC Death Rates for Men 25-64

foreach i of numlist 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	import delimited "20-64 Men `i'.txt"
	generate year = `i'
	save CDC_20to64_MEN_`i'
	clear
}

global CDC_20to64_MEN "CDC_20to64_MEN_2008 CDC_20to64_MEN_2009 CDC_20to64_MEN_2010 CDC_20to64_MEN_2011 CDC_20to64_MEN_2012 CDC_20to64_MEN_2013 CDC_20to64_MEN_2014 CDC_20to64_MEN_2015 CDC_20to64_MEN_2016 CDC_20to64_MEN_2017 CDC_20to64_MEN_2018 CDC_20to64_MEN_2019"

foreach dataset of global CDC_20to64_MEN {
	* Use Dataset
	use `dataset'
	* Drop Extraneous Variables
	drop notes
	* Split County Variable
	split county, parse(,)
	drop county
	rename county1 county
	rename county2 post_code
	* Clean Death Rate Variables
	replace cruderate = "." if cruderate == "Unreliable"
	destring cruderate, replace
	* Rename Variables
	rename population population_20to64_men
	rename deaths deaths_20to64_men
	rename cruderate cruderate_20to64_men
	* Drop Empty Observations
	drop if county == "." & post_code == "."
	drop if county == "" & post_code == ""
	* Clean Post Code Variable
	replace post_code = subinstr(post_code," ","", 1)
	* Clean County Names
	replace county = "Sitka City and Borough" if county == "Sitka Borough"
	replace county = "Kusilvak Census Area" if county == "Wade Hampton Census Area"
	replace county = "Skagway Municipality" if county == "Skagway-Hoonah-Angoon Census Area"
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
	drop if county == "Bedford city"
drop if county == "Skagway Municipality"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
	* Save Dataset
	save, replace
	clear
}

	* Apend Datasets - CDC Death Rates for Men 20-64

use CDC_20to64_MEN_2008
append using CDC_20to64_MEN_2009 CDC_20to64_MEN_2010 CDC_20to64_MEN_2011 CDC_20to64_MEN_2012 CDC_20to64_MEN_2013 CDC_20to64_MEN_2014 CDC_20to64_MEN_2015 CDC_20to64_MEN_2016 CDC_20to64_MEN_2017 CDC_20to64_MEN_2018 CDC_20to64_MEN_2019
save CDC_20to64_MEN
clear


* Clean Datasets - CDC Total Death Rates for Male Population

foreach i of numlist 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	import delimited "All Men `i'.txt"
	generate year = `i'
	save CDC_MEN_`i'
	clear
}

global CDCMEN "CDC_MEN_2008 CDC_MEN_2009 CDC_MEN_2010 CDC_MEN_2011 CDC_MEN_2012 CDC_MEN_2013 CDC_MEN_2014 CDC_MEN_2015 CDC_MEN_2016 CDC_MEN_2017 CDC_MEN_2018 CDC_MEN_2019"

foreach dataset of global CDCMEN {
	* Use Dataset
	use `dataset'
	* Drop Extraneous Variables
	drop notes
	* Split County Variable
	split county, parse(,)
	drop county
	rename county1 county
	rename county2 post_code
	* Clean Death Rate Variables
	replace cruderate = "." if cruderate == "Unreliable"
	destring cruderate, replace
	* Rename Variables
	rename population population_men
	rename deaths deaths_men
	rename cruderate cruderate_men
	* Drop Empty Observations
	drop if county == "." & post_code == "."
	drop if county == "" & post_code == ""
	* Clean Post Code Variable
	replace post_code = subinstr(post_code," ","", 1)
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
	drop if county == "Bedford city"
	replace county = "Anchorage Municipality" if county == "Anchorage Borough"
drop if county == "Skagway Municipality"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
	* Save Dataset
	save, replace
	clear
}

* Append Datasets - CDC Total Death Rates for Male Population

use CDC_MEN_2008
append using CDC_MEN_2009 CDC_MEN_2010 CDC_MEN_2011 CDC_MEN_2012 CDC_MEN_2013 CDC_MEN_2014 CDC_MEN_2015 CDC_MEN_2016 CDC_MEN_2017 CDC_MEN_2018 CDC_MEN_2019
drop ageadjustedrate
save CDC_MEN
clear

* Clean Datasets - CDC Total Death Rates for Female Population

foreach i of numlist 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	import delimited "All Women `i'.txt"
	generate year = `i'
	save CDC_WOMEN_`i'
	clear
}

global CDCWOMEN "CDC_WOMEN_2008 CDC_WOMEN_2009 CDC_WOMEN_2010 CDC_WOMEN_2011 CDC_WOMEN_2012 CDC_WOMEN_2013 CDC_WOMEN_2014 CDC_WOMEN_2015 CDC_WOMEN_2016 CDC_WOMEN_2017 CDC_WOMEN_2018 CDC_WOMEN_2019"

foreach dataset of global CDCWOMEN {
	* Use Dataset
	use `dataset'
	* Drop Extraneous Variables
	drop notes
	* Split County Variable
	split county, parse(,)
	drop county
	rename county1 county
	rename county2 post_code
	* Clean Death Rate Variables
	replace cruderate = "." if cruderate == "Unreliable"
	destring cruderate, replace
	* Rename Variables
	rename population population_women
	rename deaths deaths_women
	rename cruderate cruderate_women
	* Drop Empty Observations
	drop if county == "." & post_code == "."
	drop if county == "" & post_code == ""
	* Clean Post Code Variable
	replace post_code = subinstr(post_code," ","", 1)
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
	drop if county == "Bedford city"
	replace county = "Anchorage Municipality" if county == "Anchorage Borough"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
	* Save Dataset
	save, replace
	clear
}

* Append Datasets - CDC Total Death Rates for Female Population

use CDC_WOMEN_2008
append using CDC_WOMEN_2009 CDC_WOMEN_2010 CDC_WOMEN_2011 CDC_WOMEN_2012 CDC_WOMEN_2013 CDC_WOMEN_2014 CDC_WOMEN_2015 CDC_WOMEN_2016 CDC_WOMEN_2017 CDC_WOMEN_2018 CDC_WOMEN_2019
drop ageadjustedrate
save CDC_WOMEN
clear

* Clean Datasets - CDC Total Death Rates for 65+ Population

foreach i of numlist 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	import delimited "All Over 65 `i'.txt"
	generate year = `i'
	save CDC_65PLUS_`i'
	clear
}

global CDC65PLUS "CDC_65PLUS_2008 CDC_65PLUS_2009 CDC_65PLUS_2010 CDC_65PLUS_2011 CDC_65PLUS_2012 CDC_65PLUS_2013 CDC_65PLUS_2014 CDC_65PLUS_2015 CDC_65PLUS_2016 CDC_65PLUS_2017 CDC_65PLUS_2018 CDC_65PLUS_2019"

foreach dataset of global CDC65PLUS {
	* Use Dataset
	use `dataset'
	* Drop Extraneous Variables
	drop notes
	* Split County Variable
	split county, parse(,)
	drop county
	rename county1 county
	rename county2 post_code
	* Clean Death Rate Variables
	replace cruderate = "." if cruderate == "Unreliable"
	destring cruderate, replace
	* Rename Variables
	rename population population_65plus
	rename deaths deaths_65plus
	rename cruderate cruderate_65plus
	* Drop Empty Observations
	drop if county == "." & post_code == "."
	drop if county == "" & post_code == ""
	* Clean Post Code Variable
	replace post_code = subinstr(post_code," ","", 1)
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
	drop if county == "Bedford city"
	replace county = "Anchorage Municipality" if county == "Anchorage Borough"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
	* Save Dataset
	save, replace
	clear
}

* Append Datasets - CDC Total Death Rates for 65+ Population

use CDC_65PLUS_2008
append using CDC_65PLUS_2009 CDC_65PLUS_2010 CDC_65PLUS_2011 CDC_65PLUS_2012 CDC_65PLUS_2013 CDC_65PLUS_2014 CDC_65PLUS_2015 CDC_65PLUS_2016 CDC_65PLUS_2017 CDC_65PLUS_2018 CDC_65PLUS_2019
drop ageadjustedrate
save "CDC_65PLUS"
clear

* Clean Datasets - CDC Circulatory Deaths Rates for Population

foreach i of numlist 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	import delimited "All Circulatory `i'.txt"
	generate year = `i'
	save CDC_CIRCULATORY_ALL_`i'
	clear
}

global CDCCIRCULATORY "CDC_CIRCULATORY_ALL_2008 CDC_CIRCULATORY_ALL_2009 CDC_CIRCULATORY_ALL_2010 CDC_CIRCULATORY_ALL_2011 CDC_CIRCULATORY_ALL_2012 CDC_CIRCULATORY_ALL_2013 CDC_CIRCULATORY_ALL_2014 CDC_CIRCULATORY_ALL_2015 CDC_CIRCULATORY_ALL_2016 CDC_CIRCULATORY_ALL_2017 CDC_CIRCULATORY_ALL_2018 CDC_CIRCULATORY_ALL_2019"

foreach dataset of global CDCCIRCULATORY {
	* Use Dataset
	use `dataset'
	* Drop Extraneous Variables
	drop notes
	* Split County Variable
	split county, parse(,)
	drop county
	rename county1 county
	rename county2 post_code
	* Clean Death Rate Variables
	replace cruderate = "." if cruderate == "Unreliable"
	destring cruderate, replace
	* Rename Variables
	rename population population_circulatory
	rename deaths deaths_circulatory
	rename cruderate cruderate_circulatory
	* Drop Empty Observations
	drop if county == "." & post_code == "."
	drop if county == "" & post_code == ""
	* Clean Post Code Variable
	replace post_code = subinstr(post_code," ","", 1)
	* Clean County Names
	replace county = "Sitka City and Borough" if county == "Sitka Borough"
	replace county = "Kusilvak Census Area" if county == "Wade Hampton Census Area"
	replace county = "Oglala Lakota County" if county == "Shannon County" & post_code == "SD"
	replace county = "McKean County" if county == "Mc Kean County"
	replace county = "LaGrange County" if county == "Lagrange County"
	replace county = "LaPorte County" if county == "La Porte County"
	replace county = "Juneau City and Borough" if county == "Juneau Borough"
	replace county = "Doña Ana County" if county == "Dona Ana County"
	replace county = "De Baca County" if county == "DeBaca County"
	replace county = "DeKalb County" if county == "De Kalb County"
	drop if county == "Bedford city"
	replace county = "Anchorage Municipality" if county == "Anchorage Borough"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
	* Save Dataset
	save, replace
	clear
}

* Append Datasets - CDC Circulatory Deaths Rates for Population

use CDC_CIRCULATORY_ALL_2008
append using CDC_CIRCULATORY_ALL_2009 CDC_CIRCULATORY_ALL_2010 CDC_CIRCULATORY_ALL_2011 CDC_CIRCULATORY_ALL_2012 CDC_CIRCULATORY_ALL_2013 CDC_CIRCULATORY_ALL_2014 CDC_CIRCULATORY_ALL_2015 CDC_CIRCULATORY_ALL_2016 CDC_CIRCULATORY_ALL_2017 CDC_CIRCULATORY_ALL_2018 CDC_CIRCULATORY_ALL_2019
drop ageadjustedrate
save CDC_CIRCULATORY
clear

* Clean Datasets - CDC Neoplasm Deaths Rates for Population

foreach i of numlist 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	import delimited "All Cancer `i'.txt"
	generate year = `i'
	save CDC_CANCER_ALL_`i'
	clear
}

global CDCCANCER "CDC_CANCER_ALL_2008 CDC_CANCER_ALL_2009 CDC_CANCER_ALL_2010 CDC_CANCER_ALL_2011 CDC_CANCER_ALL_2012 CDC_CANCER_ALL_2013 CDC_CANCER_ALL_2014 CDC_CANCER_ALL_2015 CDC_CANCER_ALL_2016 CDC_CANCER_ALL_2017 CDC_CANCER_ALL_2018 CDC_CANCER_ALL_2019"

foreach dataset of global CDCCANCER {
	* Use Dataset
	use `dataset'
	* Drop Extraneous Variables
	drop notes
	* Split County Variable
	split county, parse(,)
	drop county
	rename county1 county
	rename county2 post_code
	* Clean Death Rate Variables
	replace cruderate = "." if cruderate == "Unreliable"
	destring cruderate, replace
	* Rename Variables
	rename population population_cancer
	rename deaths deaths_cancer
	rename cruderate cruderate_cancer
	* Drop Empty Observations
	drop if county == "." & post_code == "."
	drop if county == "" & post_code == ""
	* Clean Post Code Variable
	replace post_code = subinstr(post_code," ","", 1)
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
	drop if county == "Bedford city"
	replace county = "Anchorage Municipality" if county == "Anchorage Borough"
drop if county == "Prince of Wales-Hyder Census Area"
drop if county == "Prince of Wales-Outer Ketchikan Census Area"
drop if county == "Skagway-Hoonah-Angoon Census Area"
drop if county == "Hoonah-Angoon Census Area"
drop if county == "Skagway Municipality"
drop if county == "Petersburg Borough"
drop if county == "Petersburg Census Area"
drop if county == "Wrangell-Petersburg Census Area"
drop if county == "Wrangell City and Borough"
drop if county == "Wrangell Borough/city"
drop if county == "Petersburg Borough/Census Area"
	* Save Dataset
	save, replace
	clear
}

* Append Datasets - CDC Neoplasm Deaths Rates for Population

use CDC_CANCER_ALL_2008
append using CDC_CANCER_ALL_2009 CDC_CANCER_ALL_2010 CDC_CANCER_ALL_2011 CDC_CANCER_ALL_2012 CDC_CANCER_ALL_2013 CDC_CANCER_ALL_2014 CDC_CANCER_ALL_2015 CDC_CANCER_ALL_2016 CDC_CANCER_ALL_2017 CDC_CANCER_ALL_2018 CDC_CANCER_ALL_2019
drop ageadjustedrate
save CDC_CANCER
clear

* Clean Datasets - CDC External Deaths Rates for Population

foreach i of numlist 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	import delimited "All External `i'.txt"
	generate year = `i'
	save CDC_EXTERNAL_ALL_`i'
	clear
}


global CDCEXTERNAL "CDC_EXTERNAL_ALL_2008 CDC_EXTERNAL_ALL_2009 CDC_EXTERNAL_ALL_2010 CDC_EXTERNAL_ALL_2011 CDC_EXTERNAL_ALL_2012 CDC_EXTERNAL_ALL_2013 CDC_EXTERNAL_ALL_2014 CDC_EXTERNAL_ALL_2015 CDC_EXTERNAL_ALL_2016 CDC_EXTERNAL_ALL_2017 CDC_EXTERNAL_ALL_2018 CDC_EXTERNAL_ALL_2019"

foreach dataset of global CDCEXTERNAL {
	* Use Dataset
	use `dataset'
	* Drop Extraneous Variables
	drop notes
	* Split County Variable
	split county, parse(,)
	drop county
	rename county1 county
	rename county2 post_code
	* Clean Death Rate Variables
	replace cruderate = "." if cruderate == "Unreliable"
	destring cruderate, replace
	* Rename Variables
	rename population population_external
	rename deaths deaths_external
	rename cruderate cruderate_external
	* Drop Empty Observations
	drop if county == "." & post_code == "."
	drop if county == "" & post_code == ""
	* Clean Post Code Variable
	replace post_code = subinstr(post_code," ","", 1)
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
	drop if county == "Bedford city"
	replace county = "Anchorage Municipality" if county == "Anchorage Borough"
	drop if county == "Prince of Wales-Hyder Census Area"
	drop if county == "Prince of Wales-Outer Ketchikan Census Area"
	drop if county == "Skagway-Hoonah-Angoon Census Area"
	drop if county == "Hoonah-Angoon Census Area"
	drop if county == "Skagway Municipality"
	drop if county == "Petersburg Borough"
	drop if county == "Petersburg Census Area"
	drop if county == "Wrangell-Petersburg Census Area"
	drop if county == "Wrangell City and Borough"
	drop if county == "Wrangell Borough/city"
	drop if county == "Petersburg Borough/Census Area"
	* Save Dataset
	save, replace
	clear
}

* Append Datasets - CDC External Deaths Rates for Population

use CDC_EXTERNAL_ALL_2008
append using CDC_EXTERNAL_ALL_2009 CDC_EXTERNAL_ALL_2010 CDC_EXTERNAL_ALL_2011 CDC_EXTERNAL_ALL_2012 CDC_EXTERNAL_ALL_2013 CDC_EXTERNAL_ALL_2014 CDC_EXTERNAL_ALL_2015 CDC_EXTERNAL_ALL_2016 CDC_EXTERNAL_ALL_2017 CDC_EXTERNAL_ALL_2018 CDC_EXTERNAL_ALL_2019
drop ageadjustedrate
save CDC_EXTERNAL
clear

**********************************************************************
************************* Merge All Datasets *************************
**********************************************************************

* List of Datasets
	* Bureau of Labor Statistics: BLS
	* U.S. Census Bureau: CENSUS_DEMOGRAPHICS_ALL
	* Small Area Income and Poverty Estimates: SAIPE
	* Small Area Health Insurance Estimates: SAHIE
	* CDC WONDER
		* CDC WONDER - All: CDC_ALL
		* CDC WONDER - Men: CDC_MEN
		* CDC WONDER - Women: CDC_WOMEN
		* CDC WONDER - Neoplasms: CDC_CANCER
		* CDC WONDER - Circulatory System: CDC_CIRCULATORY
		* CDC WONDER - Under 65: CDC_UNDER65
		* CDC WONDER - Over 65: CDC_65PLUS
		
* Merge CDC Mortality Datsets
use CDC_ALL

	* CDC_MEN
merge 1:1 county post_code year using CDC_MEN
rename _merge _merge_CDC_MEN

	* CDC_WOMEN
merge 1:1 county post_code year using CDC_WOMEN
rename _merge _merge_CDC_WOMEN

	* CDC_EXTERNAL
merge 1:1 county post_code year using CDC_EXTERNAL
rename _merge _merge_CDC_EXTERNAL

	* CDC_CANCER
merge 1:1 county post_code year using CDC_CANCER
rename _merge _merge_CDC_CANCER

	* CDC_CIRCULATORY
merge 1:1 county post_code year using CDC_CIRCULATORY
rename _merge _merge_CDC_CIRCULATORY

	* CDC_20to64
merge 1:1 county post_code year using CDC_20to64
rename _merge _merge_CDC_20to64

	* CDC_20to64_MEN
merge 1:1 county post_code year using CDC_20to64_MEN
rename _merge _merge_CDC_20to64_MEN

	* CDC_20to64_WOMEN
merge 1:1 county post_code year using CDC_20to64_WOMEN
rename _merge _merge_CDC_20to64_WOMEN

	* CDC_65PLUS
merge 1:1 county post_code year using CDC_65PLUS
rename _merge _merge_CDC_65PLUS

merge 1:1 county post_code year using CDC_CIRCULATORY_AGEADJ_UNDER65
rename _merge _merge_CDC_CIRCULATORY_AGEADJ_UNDER65

	* Save Mortality Dataset
save CDC
clear

* Merge All Datasets

	* BLS + CENSUS
use BLS
merge 1:1 county state_fips year using CENSUS
drop _merge
replace post_code = "DC" if county == "District of Columbia"
replace post_code = "HI" if county == "Kalawao County"

	* + SAIPE
merge 1:1 county post_code year using SAIPE
drop _merge

	* + SAHIE
merge 1:1 county state_fips year using SAHIE
drop _merge

	* + CDC
merge 1:1 county post_code year using CDC
drop _merge

	* + MIGRATION
merge 1:1 county state year using MIGRATION
drop _merge

	* + NCHSUR
merge m:1 county post_code using NCHSUR
drop _merge

	* + GOVERNORS
merge m:1 state year using GOVERNORS
drop _merge
save FINAL
clear

global DATA "FINAL"

**********************************************************************
************* Kaiser Family Foundation Medicaid Variables ************
**********************************************************************

use $DATA

	* Generate Medicaid Expansion Dummies
generate medicaid = 1
replace medicaid = 0 if state == "Wyoming" | state == "South Dakota" | state == "Texas" | state == "Kansas" | state == "Mississippi" | state == "Alabama" | state == "Florida" | state == "Georgia" | state == "Tennessee" | state == "North Carolina" | state == "South Carolina" | state == "Nebraska" | state == "Missouri" | state == "Oklahoma" | state == "Utah" | state == "Idaho"

	* Generate Alternative Medicaid Expansion Dummies
generate medicaid_alt = 1
replace medicaid_alt = 0 if state == "Wyoming" | state == "South Dakota" | state == "Texas" | state == "Kansas" | state == "Mississippi" | state == "Alabama" | state == "Florida" | state == "Georgia" | state == "Tennessee" | state == "North Carolina" | state == "South Carolina" | state == "Nebraska" | state == "Missouri" | state == "Oklahoma" | state == "Utah" | state == "Idaho" | state == "Maine"

	* Generate Medicaid Expansion Year Variable
generate medicaid_year = 2014
replace medicaid_year = 0 if state == "Wyoming" | state == "South Dakota" | state == "Texas" | state == "Kansas" | state == "Mississippi" | state == "Alabama" | state == "Florida" | state == "Georgia" | state == "Tennessee" | state == "North Carolina" | state == "South Carolina" | state == "Nebraska" | state == "Missouri" | state == "Oklahoma" | state == "Utah" | state == "Idaho"
replace medicaid_year = 2008 if state == "Massachusetts"
replace medicaid_year = 2011 if state == "Washington" | state == "District of Columbia"
replace medicaid_year = 2012 if state == "California"
replace medicaid_year = 2015 if state == "Indiana" | state == "Pennsylvania" | state == "New Hampshire"
replace medicaid_year = 2016 if state == "Alaska" | state == "Montana"
replace medicaid_year = 2017 if state == "Louisiana"
replace medicaid_year = 2019 if state == "Virginia" | state == "Maine"

	* Generate Alternative Medicaid Expansion Year Variables
generate medicaid_year_alt = 2014
replace medicaid_year_alt = 0 if state == "Wyoming" | state == "South Dakota" | state == "Texas" | state == "Kansas" | state == "Mississippi" | state == "Alabama" | state == "Florida" | state == "Georgia" | state == "Tennessee" | state == "North Carolina" | state == "South Carolina" | state == "Nebraska" | state == "Missouri" | state == "Oklahoma" | state == "Utah" | state == "Idaho" | state == "Maine"
replace medicaid_year_alt = 2008 if state == "Massachusetts"
replace medicaid_year_alt = 2011 if state == "Washington" | state == "District of Columbia"
replace medicaid_year_alt = 2012 if state == "California"
replace medicaid_year_alt = 2015 if state == "Michigan" | state == "New Hampshire" | state == "Pennsylvania"
replace medicaid_year_alt = 2016 if state == "Indiana" | state == "Alaska" | state == "Montana"
replace medicaid_year_alt = 2017 if state == "Louisiana"
replace medicaid_year_alt = 2019 if state == "Virginia"

	* Generate Reciprocal Medicaid Dummy
generate non_medicaid = 0
replace non_medicaid = 1 if medicaid == 0

	* Generate Alternative Reciprocal Medicaid Dummy
generate non_medicaid_alt = 0
replace non_medicaid_alt = 1 if medicaid_alt == 0

	* Generate Medicaid Expansion Status Variable
generate medicaid_status = 0
replace medicaid_status = 1 if medicaid == 1 & year >= medicaid_year 

	* Generate Alternative Medicaid Expansion Status Variable
generate medicaid_status_alt = 0
replace medicaid_status_alt = 1 if medicaid_alt == 1 & year >= medicaid_year_alt

	* Generate Years to Treatment Variable
generate years_to_expansion = .
replace years_to_expansion = year - medicaid_year if medicaid == 1

	* Generate Alternative Years to Treatment Variable
generate years_to_expansion_alt = .
replace years_to_expansion_alt = year - medicaid_year if medicaid == 1

	* Generate Relative Time Group Dummies
forvalues k = 7(-1)2 {
	generate lead`k' = years_to_expansion == -`k'
}

forvalues k = 0/7 {
	generate lag`k' = years_to_expansion == `k'
}

generate lag8 = years_to_expansion >= 8
generate lead8 = years_to_expansion <= -8

	* Save Dataset
save $DATA, replace
clear

**********************************************************************
*********************** Generate New Variables ***********************
**********************************************************************

* Generate New Variables

	* Use Full Sample Dataset
use $DATA

	* County, State Identification Variable
egen county_state = concat(county state), punct(,)
encode county_state, generate(county_state_id)
drop county_state

	* Set Panel Dataset
xtset county_state_id year

	* Logged Total Population
generate log_tot_pop = log(tot_pop)

	* Demographic County Proportions
foreach variable of varlist tot_* wa_* ba_* ia_* aa_* na_* tom_* wac_* bac_* iac_* aac_* nac* nh* h_* hwa_* hba_* hia_* haa_* hna_* htom_* hwac_* hbac_* hiac_* haac_* hnac_* {
	generate pct_`variable' = (`variable' / tot_pop) * 100
}

	* Proportion of Population Black
generate pct_bac = ((bac_male + bac_female) / tot_pop) * 100

	* Proportion of Population Hispanic
generate pct_h = ((h_male + h_female) / tot_pop) * 100

	* Generate Continuous Treatment Variables
	
		* Uninsured Rate (Whole Population)
xtset county_state_id years_to_expansion
generate medicaid_pctui = 0
replace medicaid_pctui = pctui if years_to_expansion == 0
foreach i of numlist 1 2 3 4 5 6 7 8 9 10 11 {
	replace medicaid_pctui = L`i'.pctui if years_to_expansion == `i'
}

		* Uninsured Rate (18-64, Under 200% of the FPL)
generate medicaid_pctui_200_18to64 = 0
replace medicaid_pctui_200_18to64 = pctui_200_18to64 if years_to_expansion == 0
foreach i of numlist 1 2 3 4 5 6 7 8 9 10 11 {
	replace medicaid_pctui_200_18to64 = L`i'.pctui_200_18to64 if years_to_expansion == `i'
}

		* Alternative Uninsured Rate (Whole Population)
xtset county_state_id years_to_expansion_alt
generate medicaid_pctui_alt = 0
foreach i of numlist 1 2 3 4 5 6 7 8 9 10 11 {
	replace medicaid_pctui_alt = pctui if years_to_expansion_alt == `i'
}

		* Alternative Uninsured Rate (18-64, Under 200% of the FPL)
generate medicaid_pctui_200_18to64_alt = 0
replace medicaid_pctui_200_18to64_alt = pctui_200_18to64 if years_to_expansion_alt == 0
foreach i of numlist 1 2 3 4 5 6 7 8 9 10 11 {
	replace medicaid_pctui_200_18to64_alt = L`i'.pctui_200_18to64 if years_to_expansion_alt == `i'
}

	* Change in All Cause Mortality per 100,000
xtset county_state_id year
generate cruderate_all_diff = cruderate_all - L1.cruderate_all

	* Variables for the Missingness of Outcomes
global OUTCOMES "cruderate_all cruderate_men cruderate_women cruderate_20to64 cruderate_20to64_men cruderate_20to64_women cruderate_cancer cruderate_circulatory cruderate_external"

foreach variable of global OUTCOMES{
	generate missing_`variable' = 0
	replace missing_`variable' = 1 if cruderate_20to64 == .
}

* Label Variables
label variable pct_tot_female "% Female"
label variable pct_bac "% Black"
label variable pct_h "% Hispanic"
label variable pct_tot_pop_20to65 "% Aged 20-65"
label variable pctui "% Uninsured"
label variable unemployment_rate "Unemployment Rate (%)"
label variable med_house_income "Median Household Income ($)"
label variable cruderate_all "All Cause Mortality per 100,000"
label variable cruderate_men "All Cause Mortality per 100,000 (Men)"
label variable cruderate_women "All Cause Mortality per 100,000 (Women)"
label variable cruderate_20to64 "All Cause Mortality per 100,000 (20-64)"
label variable cruderate_20to64_men "All Cause Mortality per 100,000 (Men 20-64)"
label variable cruderate_20to64_women "All Cause Mortality per 100,000 (Women 20-64)"
label variable cruderate_65plus "All Cause Mortality per 100,000 (65+)"
label variable cruderate_cancer "Mortality per 100,000 from Neoplasms"
label variable cruderate_circulatory "Mortality per 100,000 from Diseases of the Circulatory System"
label variable cruderate_external "Mortality per 100,000 from External Causes"
label variable cruderate_all_diff "Annual Change in All Cause Mortality per 100,000"

* Save Dataset
save, replace
clear

**********************************************************************
********************* Generate Alternative Datasets ******************
**********************************************************************

* Sample Restriction: Over 10,000 Population
use $DATA
generate sample = 1 if tot_pop > 10000
bysort county state (sample): drop if missing(sample[1]) | missing(sample[_N])
drop sample
xtset county_state_id year
save "FINAL_10"
clear

* Sample Restriction: Over 15,000 Population
use $DATA
generate sample = 1 if tot_pop > 15000
bysort county state (sample): drop if missing(sample[1]) | missing(sample[_N])
drop sample
xtset county_state_id year
save "FINAL_15"
clear

* Sample Restriction: Over 20,000 Population
use $DATA
generate sample = 1 if tot_pop > 20000
bysort county state (sample): drop if missing(sample[1]) | missing(sample[_N])
drop sample
xtset county_state_id year
save "FINAL_20"
clear

* Drop Early/Late Expanders & Sample Restriction: Over 10,000 Population
use $DATA
drop if medicaid == 1 & medicaid_year != 2014
generate sample = 1 if tot_pop > 10000
bysort county state (sample): drop if missing(sample[1]) | missing(sample[_N])
drop sample
xtset county_state_id year
save "FINAL_2014"
clear

* Drop Early Expanders & Sample Restriction: Over 10,000 Population
use $DATA
drop if medicaid == 1 & medicaid_year < 2014
generate sample = 1 if tot_pop > 10000
bysort county state (sample): drop if missing(sample[1]) | missing(sample[_N])
drop sample
xtset county_state_id year
save "FINAL_POST2014"
clear

* Drop Early Expanders & Sample Restriction: Over 10,000 Population
use $DATA
drop if medicaid == 1 & medicaid_year > 2014
generate sample = 1 if tot_pop > 10000
bysort county state (sample): drop if missing(sample[1]) | missing(sample[_N])
drop sample
xtset county_state_id year
save "FINAL_PRE2014"
clear

**********************************************************************
************************ County Pairs Dataset ************************
**********************************************************************

* Create State FIPS Dataset

	* Import Dataset
use "FINAL_10"

	* Drop Extraneous Variables
keep state_fips post_code state medicaid medicaid_year
sort state_fips post_code state

	* Drop Duplicate Observations
quietly by state_fips post_code state: generate duplicate = cond(_N == 1, 0, _n)
drop if duplicate > 1
drop duplicate

	* Save Dataset
save "STATE_FIPS"
clear

* Import County Pair Dataset

import delimited "county-pair-list.txt"

* Clean Dataset

	* Split County Pair String
split countypair_id, parse("-")

	* Generate County/State Borders Identifying Variables
generate state_fips1 = substr(countypair_id1, -5, 2)
generate county_fips1 = substr(countypair_id1, -3, 3)
generate state_fips2 = substr(countypair_id2, -5, 2)
generate county_fips2 = substr(countypair_id2, -3, 3)
drop countypair_id1
drop countypair_id2

	* Destring Variables
destring state_fips1, replace
destring state_fips2, replace
destring county_fips1, replace
destring county_fips2, replace

	* Merge State1 with Medicaid Characteristics
rename state_fips1 state_fips
merge m:1 state_fips using STATE_FIPS
drop _merge
drop if state_fips == 2 | state_fips == 15

		* Rename Variables
rename state_fips state_fips1
rename state state1
rename post_code post_code1
rename medicaid medicaid1
rename medicaid_year medicaid_year1

	* Merge State2 with Medicaid Characteristics
rename state_fips2 state_fips
merge m:1 state_fips using STATE_FIPS
drop _merge
drop if state_fips == 2 | state_fips == 15

	* Rename Variables
rename state_fips state_fips2
rename state state2
rename post_code post_code2
rename medicaid medicaid2
rename medicaid_year medicaid_year2

* Construct County Borders Sample

	* Drop Non-2014 Expansion States
drop if medicaid_year1 != 2014 & medicaid_year1 != 0
drop if medicaid_year2 != 2014 & medicaid_year2 != 0
drop medicaid_year1 medicaid_year2

	* Drop Extraneous Variables
drop cbsatitle cbsacode insamplemsa county

	* Save Dataset
save "COUNTY_PAIRS"
clear

* Restrict Sample in Final Dataset

	* First Set of Counties
use "COUNTY_PAIRS"
drop state_fips2 county_fips2 post_code2 state2 medicaid2
rename county_fips1 county_fips
rename state_fips1 state_fips
rename state1 state
rename medicaid1 medicaid
rename post_code1 post_code

merge m:m county_fips state state_fips medicaid post_code using "FINAL_10"
drop if _merge != 3
drop _merge
sort state county year
save "FULL_SAMPLE_COUNTY_PAIRS_1"
clear

	* Second Set of Counties
use "COUNTY_PAIRS"
drop state_fips1 county_fips1 post_code1 state1 medicaid1
rename county_fips2 county_fips
rename state_fips2 state_fips
rename state2 state
rename medicaid2 medicaid
rename post_code2 post_code

merge m:m county_fips state state_fips medicaid post_code using "FINAL_10"
drop if _merge != 3
drop _merge
sort state county year
save "FULL_SAMPLE_COUNTY_PAIRS_2"
clear

* Append Counties Datasets

	* Append Counties Dataset
use "FULL_SAMPLE_COUNTY_PAIRS_1"
append using "FULL_SAMPLE_COUNTY_PAIRS_2"
sort state county year
order year state county medicaid
save FINAL_PAIRS
clear
