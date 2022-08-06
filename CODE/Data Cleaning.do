**********************************************************************
**************** EC331 Thesis - Data Cleaning Do File ****************
**********************************************************************

/* 

* By: Wilson King
* Last Updated: 5 May 2022

This .do file downloads and cleans the datasets associated with "Medicaid
Eligibility & Mortality: Evidence from the Affordable Care Act."

All input files are available in the associated replication package zip.

*/

**********************************************************************
*************************** DATA CLEANING ****************************
**********************************************************************

* Define Input Directory

global user = "wilsonking"
global root = "/Users/`user'/Documents/Github/Medicaid/"

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
