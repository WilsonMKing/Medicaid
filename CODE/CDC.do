**********************************************************************
************************* Mortality By Cause *************************
**********************************************************************

cd "$root_data"

foreach i of numlist 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	
	import delimited "25-64 `i'.txt"
	generate year = `i'
	save CDC_25to64_`i'
	clear
	
	import delimited "25-64 Amenable `i'.txt"
	generate year = `i'
	save CDC_25to64_AMENABLE_`i'
	clear
	
	import delimited "25-64 Circulatory `i'.txt"
	generate year = `i'
	save CDC_25to64_CIRCULATORY_`i'
	clear
	
	import delimited "25-64 Men `i'.txt"
	generate year = `i'
	save CDC_25to64_MEN_`i'
	clear
	
	import delimited "25-64 Women `i'.txt"
	generate year = `i'
	save CDC_25to64_WOMEN_`i'
	clear
	
}

global CDC_25to64 "CDC_25to64_2008 CDC_25to64_2009 CDC_25to64_2010 CDC_25to64_2011 CDC_25to64_2012 CDC_25to64_2013 CDC_25to64_2014 CDC_25to64_2015 CDC_25to64_2016 CDC_25to64_2017 CDC_25to64_2018 CDC_25to64_2019"

global CDC_25to64_AMENABLE "CDC_25to64_AMENABLE_2008 CDC_25to64_AMENABLE_2009 CDC_25to64_AMENABLE_2010 CDC_25to64_AMENABLE_2011 CDC_25to64_AMENABLE_2012 CDC_25to64_AMENABLE_2013 CDC_25to64_AMENABLE_2014 CDC_25to64_AMENABLE_2015 CDC_25to64_AMENABLE_2016 CDC_25to64_AMENABLE_2017 CDC_25to64_AMENABLE_2018 CDC_25to64_AMENABLE_2019"

global CDC_25to64_MEN "CDC_25to64_MEN_2008 CDC_25to64_MEN_2009 CDC_25to64_MEN_2010 CDC_25to64_MEN_2011 CDC_25to64_MEN_2012 CDC_25to64_MEN_2013 CDC_25to64_MEN_2014 CDC_25to64_MEN_2015 CDC_25to64_MEN_2016 CDC_25to64_MEN_2017 CDC_25to64_MEN_2018 CDC_25to64_MEN_2019"

global CDC_25to64_WOMEN "CDC_25to64_WOMEN_2008 CDC_25to64_WOMEN_2009 CDC_25to64_WOMEN_2010 CDC_25to64_WOMEN_2011 CDC_25to64_WOMEN_2012 CDC_25to64_WOMEN_2013 CDC_25to64_WOMEN_2014 CDC_25to64_WOMEN_2015 CDC_25to64_WOMEN_2016 CDC_25to64_WOMEN_2017 CDC_25to64_WOMEN_2018 CDC_25to64_WOMEN_2019"

global CDC_25to64_CIRCULATORY "CDC_25to64_CIRCULATORY_2008 CDC_25to64_CIRCULATORY_2009 CDC_25to64_CIRCULATORY_2010 CDC_25to64_CIRCULATORY_2011 CDC_25to64_CIRCULATORY_2012 CDC_25to64_CIRCULATORY_2013 CDC_25to64_CIRCULATORY_2014 CDC_25to64_CIRCULATORY_2015 CDC_25to64_CIRCULATORY_2016 CDC_25to64_CIRCULATORY_2017 CDC_25to64_CIRCULATORY_2018 CDC_25to64_CIRCULATORY_2019"

global ALL_CDC_DATA "CDC_25to64_2008 CDC_25to64_2009 CDC_25to64_2010 CDC_25to64_2011 CDC_25to64_2012 CDC_25to64_2013 CDC_25to64_2014 CDC_25to64_2015 CDC_25to64_2016 CDC_25to64_2017 CDC_25to64_2018 CDC_25to64_2019 CDC_25to64_AMENABLE_2008 CDC_25to64_AMENABLE_2009 CDC_25to64_AMENABLE_2010 CDC_25to64_AMENABLE_2011 CDC_25to64_AMENABLE_2012 CDC_25to64_AMENABLE_2013 CDC_25to64_AMENABLE_2014 CDC_25to64_AMENABLE_2015 CDC_25to64_AMENABLE_2016 CDC_25to64_AMENABLE_2017 CDC_25to64_AMENABLE_2018 CDC_25to64_AMENABLE_2019 CDC_25to64_CIRCULATORY_2008 CDC_25to64_CIRCULATORY_2009 CDC_25to64_CIRCULATORY_2010 CDC_25to64_CIRCULATORY_2011 CDC_25to64_CIRCULATORY_2012 CDC_25to64_CIRCULATORY_2013 CDC_25to64_CIRCULATORY_2014 CDC_25to64_CIRCULATORY_2015 CDC_25to64_CIRCULATORY_2016 CDC_25to64_CIRCULATORY_2017 CDC_25to64_CIRCULATORY_2018 CDC_25to64_CIRCULATORY_2019 CDC_25to64_MEN_2008 CDC_25to64_MEN_2009 CDC_25to64_MEN_2010 CDC_25to64_MEN_2011 CDC_25to64_MEN_2012 CDC_25to64_MEN_2013 CDC_25to64_MEN_2014 CDC_25to64_MEN_2015 CDC_25to64_MEN_2016 CDC_25to64_MEN_2017 CDC_25to64_MEN_2018 CDC_25to64_MEN_2019 CDC_25to64_WOMEN_2008 CDC_25to64_WOMEN_2009 CDC_25to64_WOMEN_2010 CDC_25to64_WOMEN_2011 CDC_25to64_WOMEN_2012 CDC_25to64_WOMEN_2013 CDC_25to64_WOMEN_2014 CDC_25to64_WOMEN_2015 CDC_25to64_WOMEN_2016 CDC_25to64_WOMEN_2017 CDC_25to64_WOMEN_2018 CDC_25to64_WOMEN_2019"

foreach dataset of global ALL_CDC_DATA {
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
	replace ageadjustedrate = "." if ageadjustedrate == "Unreliable"
	destring cruderate, replace
	destring ageadjustedrate, replace
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
	* Save Dataset
	save `dataset', replace
	clear
}

foreach dataset of global CDC_25to64 {
	use `dataset'
	rename population population_25to64
	rename deaths deaths_25to64
	rename cruderate cruderate_25to64
	rename ageadjustedrate adjrate_25to64
	save `dataset', replace
	clear
}

foreach dataset of global CDC_25to64_AMENABLE {
	use `dataset'
	rename population population_25to64_amenable
	rename deaths deaths_25to64_amenable
	rename cruderate cruderate_25to64_amenable
	rename ageadjustedrate adjrate_25to64_amenable
	save `dataset', replace
	clear
}

foreach dataset of global CDC_25to64_MEN {
	use `dataset'
	rename population population_25to64_men
	rename deaths deaths_25to64_men
	rename cruderate cruderate_25to64_men
	rename ageadjustedrate adjrate_25to64_men
	save `dataset', replace
	clear
}

foreach dataset of global CDC_25to64_WOMEN {
	use `dataset'
	rename population population_25to64_women
	rename deaths deaths_25to64_women
	rename cruderate cruderate_25to64_women
	rename ageadjustedrate adjrate_25to64_women
	save `dataset', replace
	clear
}

foreach dataset of global CDC_25to64_CIRCULATORY {
	use `dataset'
	rename population population_25to64_circulatory
	rename deaths deaths_25to64_circulatory
	rename cruderate cruderate_25to64_circulatory
	rename ageadjustedrate adjrate_25to64_circulatory
	save `dataset', replace
	clear
}

foreach i in 25to64 25to64_AMENABLE 25to64_CIRCULATORY 25to64_WOMEN 25to64_MEN {
	use CDC_`i'_2008
	append using CDC_`i'_2009 CDC_`i'_2010 CDC_`i'_2011 CDC_`i'_2012 CDC_`i'_2013 CDC_`i'_2014 CDC_`i'_2015 CDC_`i'_2016 CDC_`i'_2017 CDC_`i'_2018 CDC_`i'_2019
	save "$root_final/CDC_`i'"
	clear
}

use "$root_final/CDC_25to64"

foreach i in MEN WOMEN AMENABLE CIRCULATORY {
	merge 1:1 county post_code year using "$root_final/CDC_25to64_`i'"
	drop _merge
}

save "$root_final/CDC.dta"
