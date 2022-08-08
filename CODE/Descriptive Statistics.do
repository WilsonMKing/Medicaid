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
eststo diff: quietly estpost ttest $DESCRIPTIVE_STATISTICS, by(medicaid) unequal

esttab non_exp_desc exp_desc diff using "$root_exhibits/descriptives.tex", cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) t(pattern(0 0 0) par fmt(2))") label


/*

estpost tabstat $DESCRIPTIVE_STATISTICS if medicaid == 0 & year == 2008, c(stat) statistics(mean sd n)
est store non_expansion_descriptives

	* Expansion Counties
estpost tabstat $DESCRIPTIVE_STATISTICS if medicaid == 1 & year == 2008, c(stat) statistics(mean sd n)
est store expansion_descriptives

	* Export Descriptive Statistics to LaTeX
bysort medicaid: outreg2 using "$root_exhibits/descriptives.tex", tex replace sum(log) keep($DESCRIPTIVE_STATISTICS) eqkeep(mean sd) dec(2) sideway label addnote("Note: Computations per author. Data from the Bureau of Labor Statistics, Center for Disease Control, Kaiser Family Foundation, and U.S. Census Bureau.")


*/
