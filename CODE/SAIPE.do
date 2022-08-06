**********************************************************************
*************** Small Area Income and Poverty Estimates **************
**********************************************************************

cd "$root_data"

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

* Clean Dataset

	* Drop Notes and Rename/Drop/Destring Variables
foreach dataset in SAIPE_08 SAIPE_09 SAIPE_10 SAIPE_11 SAIPE_12 SAIPE_13 SAIPE_14 SAIPE_15 SAIPE_16 SAIPE_17 SAIPE_18 SAIPE_19 {
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
save "$root_final/SAIPE"
clear
