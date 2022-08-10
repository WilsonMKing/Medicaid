**********************************************************************
*********************** Descriptive Statistics ***********************
**********************************************************************

*** TABLE OF DESCRIPTIVE STATISTICS

use "$root_final/DATA"

	* Non-Expansion Counties
eststo non_exp_desc: quietly estpost summarize $DESCRIPTIVE_STATISTICS if medicaid == 0 & year == 2008

	* Expansion Counties
eststo exp_desc: quietly estpost summarize $DESCRIPTIVE_STATISTICS if medicaid == 1 & year == 2008

	* Difference Expansion v. Non-Expansion
preserve
drop if year != 2008
eststo diff: quietly estpost ttest $DESCRIPTIVE_STATISTICS, by(medicaid)
restore

esttab non_exp_desc exp_desc diff using "$root_exhibits/descriptives.tex", cells("mean(pattern(1 1 0) fmt(2)) sd(par pattern(1 1)) b(star pattern(0 0 1) fmt(2)) t(pattern(0 0 0))") mtitles("Non-Expansion Counties" "Expansion Counties" "Difference") label replace onecell
