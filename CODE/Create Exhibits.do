********************************************************************************
******************************* Create Exhibits ********************************
********************************************************************************


global user "wilsonking"
global root "/Users/$user/Documents/Github/Medicaid"
global root_data "$root/RAW DATA"
global root_code "$root/CODE"
global root_final "$root/FINAL DATASETS"
global root_exhibits "$root/EXHIBITS"


*** Pre-Analysis

	* Install Packages

global MEDICAID_PACKAGES "estout statsmat matsave outtable tabstatmat outreg2 spmap shp2dta mif2dta eventstudyweights eventstudy2 drdid csdid bacondecomp eventdd matsort boottest avar refhdfe ftools coefplot did_imputation"

foreach package of global MEDICAID_PACKAGES {
	ssc install `package'
}

		* Global Variables
	
global CONTROLS "pct_h pct_bac pct_tot_female med_house_income pct_tot_pop_20to65 unemployment_rate"
global DEMOGRAPHIC_CONTROLS "pct_h pct_bac pct_tot_female pct_tot_pop_20to65"
global ECONOMIC_CONTROLS "med_househ_income unemployment_rate"
global OUTCOMES "adjrate_25to64 adjrate_25to64_men adjrate_25to64_women adjrate_25to64_circulatory adjrate_25to64_amenable pctui_200_18to64"
global DESCRIPTIVE_STATISTICS "pct_tot_female pct_bac pct_h pct_tot_pop_20to65 pctui_200_18to64 unemployment_rate med_house_income adjrate_25to64 adjrate_25to64_men adjrate_25to64_women adjrate_25to64_circulatory adjrate_25to64_amenable adjrate_25to64_diff"

* Set Analysis Seed
set seed 73
