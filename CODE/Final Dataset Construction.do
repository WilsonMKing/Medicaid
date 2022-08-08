********************************************************************************
************************** Final Dataset Construction **************************
********************************************************************************

/*

Author: Wilson M. King (wikingsdomaine@gmail.com)
Affiliation: Pre-Doctoral Fellow at UC San Diego

Notes: This do file cleans and merges the constituent datasets associated with "Medicaid Eligibility & Mortality: Evidence from the Affordable Care Act". The file is easily replicable on any machine, provided the global user (first line of the code) is changed from "wilsonking" to the individual seeking to run it. The file path "root" corresponds to folder structure on my machine and may need adjustment depending on how this replication package is locally stored. However, the roots "root_data", "root_code", and "root_final" should not require adjustment unless subfolder names are manually changed.

*/

global user "wilsonking"
global root "/Users/$user/Documents/Github/Medicaid"
global root_data "$root/RAW DATA"
global root_code "$root/CODE"
global root_final "$root/FINAL DATASETS"

do "$root_code/BLS"
do "$root_code/CENSUS"
do "$root_code/SAIPE"
do "$root_code/SAHIE"
do "$root_code/NCHS"
do "$root_code/MIGRATION"
do "$root_code/GOVERNORS"
do "$root_code/CDC"

use "$root_final/BLS"
foreach dataset in CENSUS SAIPE SAHIE MIGRATION {
	merge 1:1 county state_fips year using "$root_final/`dataset'"
	drop _merge
}

merge 1:1 county post_code year using "$root_final/CDC"
drop _merge

merge m:1 post_code county using "$root_final/NCHSUR"
drop _merge

merge m:1 state year using "$root_final/GOVERNORS"
drop _merge

save "$root_final/DATA"

********************************************************************************
************************* Medicaid Expansion Variables *************************
********************************************************************************

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
save, replace

********************************************************************************
**************************** Generate New Variables ****************************
********************************************************************************

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
generate cruderate_25to64_diff = cruderate_25to64 - L1.cruderate_25to64
generate adjrate_25to64_diff = adjrate_25to64 - L1.adjrate_25to64

* Label Variables
label variable pct_tot_female "% Female"
label variable pct_bac "% Black"
label variable pct_h "% Hispanic"
label variable pct_tot_pop_20to65 "% Aged 20-65"
label variable pctui "% Uninsured"
label variable unemployment_rate "Unemployment Rate (%)"
label variable med_house_income "Median Household Income ($)"
label variable pctui_200_18to64 "% Uninsured, 18-64 & <200% of FPL"
label variable adjrate_25to64 "Age Adjusted Mortality, 25-64 (per 100,000)"
label variable adjrate_25to64_men "Age Adjusted Mortality, Men 25-64 (per 100,000)"
label variable adjrate_25to64_women "Age Adjusted Mortality, Women 25-64 (per 100,000)"
label variable adjrate_25to64_amenable "Age Adjusted Amenable Mortality, 25-64 (per 100,000)"
label variable adjrate_25to64_circulatory "Age Adjusted Circulatory Mortality, 25-64 (per 100,000)"

* Save Dataset
save, replace
clear



