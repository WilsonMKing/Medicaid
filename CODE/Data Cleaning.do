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
