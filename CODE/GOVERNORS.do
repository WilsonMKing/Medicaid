**********************************************************************
****************************** GOVERNORS *****************************
**********************************************************************

cd "$root_data"

import excel "governors.xlsx", first

* Clean Dataset
tab state if party == "Independent"
replace party = "Republican" if party == "Independent" & state == "Alaska"
replace party = "Democrat" if party == "Independent" & state == "Rhode Island"
label define governor 0 "Democrat" 1 "Republican"
encode party, generate(governor)

save "$root_final/GOVERNORS.dta"
clear
