**********************************************************************
******************** EC331 Thesis - Analysis File ********************
**********************************************************************

/* 

By: Wilson King

This .do file conducts the analysis associated with "Medicaid Eligibility 
and Mortality: Evidence from the Affordable Care Act."

Input Files:

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
************************ Full Sample Analysis ************************
**********************************************************************,

*** PRE-ANALYSIS

* Install Packages

global PACKAGES "estout statsmat matsave outtable tabstatmat outreg2 spmap shp2dta mif2dta eventstudyweights eventstudy2 drdid csdid bacondecomp eventdd matsort boottest avar refhdfe ftools coefplot did_imputation"

foreach package of global PACKAGES {
	ssc install `package'
}

* Establish Global Variables
	
	* Vectors of Controls
global CONTROLS "pct_h pct_bac pct_tot_female med_house_income pct_tot_pop_20to65 unemployment_rate"
global DEMOGRAPHIC_CONTROLS "pct_h pct_bac pct_tot_female pct_tot_pop_20to65"
global ECONOMIC_CONTROLS "med_house_income unemployment_rate"

	* Descriptive Statistics
global DESCRIPTIVE_STATISTICS "pct_tot_female pct_bac pct_h pct_tot_pop_20to65 pctui unemployment_rate med_house_income  cruderate_all cruderate_men cruderate_women cruderate_20to64 cruderate_65plus cruderate_cancer cruderate_circulatory cruderate_external cruderate_all_diff rural"

	* Outcome Variables
global OUTCOMES "cruderate_all cruderate_men cruderate_women cruderate_20to64 cruderate_cancer cruderate_circulatory pctui pctui_200_18to64"

* Set Analysis Seed
set seed 73

**********************************************************************
*********************** Descriptive Statistics ***********************
**********************************************************************

*** TABLE OF DESCRIPTIVE STATISTICS

* Descriptive Statistics: 10,000 Sample Restriction - All States

use FINAL_10

	* Non-Expansion Counties
estpost tabstat $DESCRIPTIVE_STATISTICS if medicaid == 0 & year == 2013, c(stat) statistics(mean sd n)
est store non_expansion_descriptives

	* Expansion Counties
estpost tabstat $DESCRIPTIVE_STATISTICS if medicaid == 1 & year == 2013, c(stat) statistics(mean sd n)
est store expansion_descriptives

	* Export Descriptive Statistics to LaTeX
bysort medicaid: outreg2 using "descriptives.tex", tex replace sum(log) keep($DESCRIPTIVE_STATISTICS) eqkeep(mean sd) dec(2) sideway label addnote("Note: Computations per author. Data from the Bureau of Labor Statistics, Center for Disease Control, Kaiser Family Foundation, and U.S. Census Bureau.")

* Descriptive Statistics: 10,000 Sample Restriction - 2014 Expansion / Non-Expansion States

use FINAL_2014

	* Non-Expansion Counties
estpost tabstat $DESCRIPTIVE_STATISTICS if medicaid == 0 & year == 2013, c(stat) stat(mean sd n)
est store r_nonexpansion_descriptives

	* Expansion Counties
estpost tabstat $DESCRIPTIVE_STATISTICS if medicaid == 1 & year == 2013, c(stat) stat(mean sd n)
est store r_expansion_descriptives

	* Export Descriptive Statistics to LaTeX
bysort medicaid: outreg2 using "descriptives_restricted.tex", tex replace dec(2) sum(log) keep($DESCRIPTIVE_STATISTICS) eqkeep(mean sd) sideway label addnote("Note: Computations per author. Data from the Bureau of Labor Statistics, Center for Disease Control, Kaiser Family Foundation, and U.S. Census Bureau.")

*** VISUALISE PRE-TRENDS

* Visualize Pre-Trends: 10,000 Sample Restriction - 2014 Expansion States

use FINAL_2014

	* Pre-Trends (Raw Means) by Medicaid Expansion Status

foreach variable of global OUTCOMES {
	preserve
	collapse (mean) `variable', by (medicaid year)
	reshape wide `variable', i(year) j(medicaid)
	graph twoway connect `variable'* year if year < 2014
	graph save pretrends_`variable'
	restore
}

clear

*** TABLE OF DESCRIPTIVE STATISTICS BY MISSINGNESS

use $DATA

* Generate Indicator for Sample Inclusion

generate sample = 0
replace sample = 1 if tot_pop > 10000

* Calculate Descriptive Statistics by Missiginess

	* Included Counties
estpost tabstat $DESCRIPTIVE_STATISTICS if sample == 1 & year == 2013, c(stat) statistics(mean sd n)
est store sample_descriptives

	* Excluded Counties
estpost tabstat $DESCRIPTIVE_STATISTICS if sample == 0 & year == 2013, c(stat) statistics(mean sd n)
est store nonsample_descriptives

* Export Descriptive Statistics by Missingness

bysort sample: outreg2 using "sample_descriptives.tex", tex replace sum(log) keep($DESCRIPTIVE_STATISTICS) eqkeep(mean sd) dec(2) sideway label addnote("Note: Computations per author. Data from the Bureau of Labor Statistics, Center for Disease Control, Kaiser Family Foundation, and U.S. Census Bureau.")

*** HISTOGRAMS OF DESCRIPTIVE STATISTICS BY SAMPLE RESTRICTION

* Histograms of Descriptive Statistics

	* Uninsured Rate (%) by Missingness
histogram pctui if year == 2008 & sample == 0, start(0) width(1.5) kdensity
graph save histogram_uninsured_missing
histogram pctui if year == 2008 & sample == 1, start(0) width(1.5) kdensity
graph save histogram_uninsured_nonmissing

	* Population
twoway (histogram log_tot_pop if year == 2008 & missing_cruderate_20to64 == 0, color(gray)) (histogram log_tot_pop if year == 2008 & missing_cruderate_20to64 == 1, color(black)) (kdensity log_tot_pop if year == 2008 & missing_cruderate_20to64 == 0) (kdensity log_tot_pop if year == 2008 & missing_cruderate_20to64 == 1), legend(order(1 "Non-Censored: All Cause Mortality (20-64)" 2 "Censored: All Cause Mortality (20-64)"))
graph save histogram_population_missingness

clear

*** HISTOGRAMS OF "DOSE" FOR CONTINUOUS DIFFERENCE-IN-DIFFERENCES

use FINAL_10

histogram medicaid_pctui if year == medicaid_year, start(0) width(1) normal
graph save histogram_dose
histogram medicaid_pctui_200_18to64 if year == medicaid_year, start(0) width(1.5) normal
graph save histogram_dose_lowincadults

clear

**********************************************************************
**************** Difference-in-Differences Analysis ******************
**********************************************************************

*** OLS DIFFERENCE-IN-DIFFERENCES: STAGGERED TREATMENT

use FINAL_10

* Two-Way Fixed Effects with State-Level Fixed Effects

	* No Controls
foreach outcome of global OUTCOMES {
	didregress (`outcome') (medicaid_status), group(state_fips) time(year) vce(cluster state_fips)
	estimates store m1_`outcome'
}

	* Controls
foreach outcome of global OUTCOMES {
	didregress (`outcome' $CONTROLS) (medicaid_status), group(state_fips) time(year) vce(cluster state_fips)
	estimates store m2_`outcome'
}

* Two-Way Fixed Effects with County-Level Fixed Effects

	* No Controls
foreach outcome of global OUTCOMES {
	xtdidregress (`outcome') (medicaid_status), group(state_fips) time(year) vce(cluster state_fips)
	estimates store m3_`outcome'
}

	* Demographic Controls
foreach outcome of global OUTCOMES {
	xtdidregress (`outcome' $DEMOGRAPHIC_CONTROLS) (medicaid_status), group(state_fips) time(year) vce(cluster state_fips)
	estimates store m4_`outcome'
}

	* Economic Controls
foreach outcome of global OUTCOMES {
	xtdidregress (`outcome' $ECONOMIC_CONTROLS) (medicaid_status), group(state_fips) time(year) vce(cluster state_fips)
	estimates store m5_`outcome'
}

	* All Controls
foreach outcome of global OUTCOMES {
	xtdidregress (`outcome' $CONTROLS) (medicaid_status), group(state_fips) time(year) vce(cluster state_fips)
	estimates store m6_`outcome'
}

*** OLS RESULTS TABLES

* OLS TWFE Results Tables

	* Crude All Cause Mortality per 100,000
esttab m3_cruderate_all m4_cruderate_all m5_cruderate_all m6_cruderate_all m6_cruderate_men m6_cruderate_women m6_cruderate_20to64 using ols_staggered_did_all.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats (N, fmt(%9.0f) labels("Observations")) title("OLS Difference-in-Differences Results for All Cause Mortality (per 100,000)") mlabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)") replace

	* Crude Mortality per 100,000 from Diseases of the Circulatory System
esttab m3_cruderate_circulatory m4_cruderate_circulatory m5_cruderate_circulatory m6_cruderate_circulatory using ols_staggered_did_circulatory.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats (N, fmt(%9.0f) labels("Observations")) title("OLS Difference-in-Differences Results for Mortality from Diseases of the Circulatory System (per 100,000)") mlabels("(1)" "(2)" "(3)" "(4)") replace

	* Crude Morality per 100,000 from Neoplasms
esttab m3_cruderate_cancer m4_cruderate_cancer m5_cruderate_cancer m6_cruderate_cancer using staggered_did_cancer.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats (N, fmt(%9.0f) labels("Observations")) title("OLS Difference-in-Differences Results for Mortality from Neoplasms (per 100,000)") mlabels("(1)" "(2)" "(3)" "(4)") replace

	* Percent Uninsured
esttab m3_pctui m4_pctui m5_pctui m6_pctui using ols_staggered_did_pctui.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats (N, fmt(%9.0f) labels("Observations")) title("OLS Differences-in-Differences Results for Percent Uninsured") mlabels("(1)" "(2)" "(3)" "(4)") replace

*** BACON DECOMPOSITION

* Bacon Decomposition of OLS TWFE Results

	* Crude All Cause Mortality per 100,000
bacon cruderate_all medicaid_status $CONTROLS, vce(cluster state_fips)

	* Crude Mortality per 100,000 from Diseases of the Circulatory System
bacon cruderate_circulatory medicaid_status $CONTROLS, vce(cluster state_fips)

	* Crude Mortality per 100,000 from Neoplasms
bacon cruderate_cancer medicaid_status $CONTROLS, vce(cluster state_fips)

	* Percent Uninsured
bacon pctui medicaid_status $CONTROLS, vce(cluster state_fips)

*** CALLAWAY & SANT'ANNA (2021) DIFFERENCE-IN-DIFFERENCES

use FINAL_10

* Callaway & Sant'Anna (2021) Two Way Fixed Effects

	* No Controls
foreach outcome of global OUTCOMES {
	csdid `outcome', ivar(county_state_id) time(year) g(medicaid_year) wboot_op(bootcluster(state)) agg(simple)
	estimates store m7_`outcome'
}

	* Demographic Controls
foreach outcome of global OUTCOMES {
	csdid `outcome' $DEMOGRAPHIC_CONTROLS, ivar(county_state_id) time(year) g(medicaid_year) wboot_op(bootcluster(state)) agg(simple)
	estimates store m8_`outcome'
}

	* Economic Controls
foreach outcome of global OUTCOMES {
	csdid `outcome' $ECONOMIC_CONTROLS, ivar(county_state_id) time(year) g(medicaid_year) wboot_op(bootcluster(state)) agg(simple)
	estimates store m9_`outcome'
}

	* All Controls
foreach outcome of global OUTCOMES {
	csdid `outcome' $CONTROLS, ivar(county_state_id) time(year) g(medicaid_year) wboot_op(bootcluster(state)) agg(simple)
	estimates store m10_`outcome'
}

*** CALLAWAY & SANT'ANNA (2021) RESULTS TABLES

	* Crude All Cause Mortality per 100,000
esttab m7_cruderate_all m8_cruderate_all m9_cruderate_all m10_cruderate_all m10_cruderate_men m10_cruderate_women m10_cruderate_20to64 using cs_staggered_did_all.tex, style(tex) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("Callaway & Sant'Anna Difference-in-Differences Results for All Cause Mortality (per 100,000)") mlabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

	* Crude Mortality per 100,000 from Diseases of the Circulatory System
esttab m7_cruderate_circulatory m8_cruderate_circulatory m9_cruderate_circulatory m10_cruderate_circulatory using cs_staggered_did_circulatory.tex, style(tex) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("Callaway & Sant'Anna Difference-in-Differences Results for Mortality from Diseases of the Ciruclatory System (per 100,000)") mlabels("(1)" "(2)" "(3)" "(4)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" 	med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

	* Crude Mortality per 100,000 from Neoplasms
esttab m7_cruderate_cancer m8_cruderate_cancer m9_cruderate_cancer m10_cruderate_cancer using cs_staggered_did_cancer.tex, style(tex) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("Callaway & Sant'Anna Difference-in-Differences Results for Mortality from Neoplasms (per 100,000)") mlabels("(1)" "(2)" "(3)" "(4)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" 	med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

	* Percent Uninsured
esttab m7_pctui m8_pctui m9_pctui m10_pctui using cs_staggered_did_pctui.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("Callaway & Sant'Anna Difference-in-Differences Results for Percent Uninsured") mlabels("(1)" "(2)" "(3)" "(4)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

**********************************************************************
*********************** Continuous Treatment *************************
**********************************************************************

*** STAGGERED OLS DOSE RESPONSE DID

* Staggered DID with Continuous Treatment

	* Percent Uninsured Under 65
foreach outcome of varlist cruderate_all cruderate_men cruderate_women cruderate_20to64 cruderate_circulatory cruderate_cancer {
	* No Controls
xtreg `outcome' medicaid_pctui i.year, fe vce(cluster state_fips)
estimates store m11_`outcome'
	* Demographic Controls
xtreg `outcome' $DEMOGRAPHIC_CONTROLS medicaid_pctui i.year, fe vce(cluster state_fips)
estimates store m12_`outcome'
	* Economic Controls
xtreg `outcome' $ECONOMIC_CONTROLS medicaid_pctui i.year, fe vce(cluster state_fips)
estimates store m13_`outcome'
	* All Controls
xtreg `outcome' $CONTROLS medicaid_pctui i.year, fe vce(cluster state_fips)
estimates store m14_`outcome'
}

	* Percent Uninsured 18-64, Under 200% of the Federal Poverty Line
foreach outcome of varlist cruderate_all cruderate_men cruderate_women cruderate_20to64 cruderate_circulatory cruderate_cancer {
	* No Controls
xtreg `outcome' medicaid_pctui_200_18to64 i.year, fe vce(cluster state_fips)
estimates store m15_`outcome'
	* Demographic Controls
xtreg `outcome' $DEMOGRAPHIC_CONTROLS medicaid_pctui_200_18to64 i.year, fe vce(cluster state_fips)
estimates store m16_`outcome'
	* Economic Controls
xtreg `outcome' $ECONOMIC_CONTROLS medicaid_pctui_200_18to64 i.year, fe vce(cluster state_fips)
estimates store m17_`outcome'
	* All Controls
xtreg `outcome' $CONTROLS medicaid_pctui_200_18to64 i.year, fe vce(cluster state_fips)
estimates store m18_`outcome'
}

*** STAGGERED OLS DOSE RESPONSE DID RESULTS TABLES

	* Crude All Cause Mortality per 100,000
esttab m11_cruderate_all m12_cruderate_all m13_cruderate_all m14_cruderate_all m14_cruderate_men m14_cruderate_women m14_cruderate_20to64 using continuous_staggered_did_all.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("OLS Treatment Intensity Difference-in-Differences Results for All Cause Mortality (per 100,000)") mlabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

esttab m15_cruderate_all m16_cruderate_all m17_cruderate_all m18_cruderate_all m18_cruderate_men m18_cruderate_women m18_cruderate_20to64 using continuous_under200_staggered_did_all.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("OLS Treament Intensity (Low Income Adults) Difference-in-Differences Results for All Cause Mortality") mlabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

	* Crude Mortality per 100,000 from Diseases of the Circulatory System
esttab m11_cruderate_circulatory m12_cruderate_circulatory m13_cruderate_circulatory m14_cruderate_circulatory using continuous_staggered_did_circulatory.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("OLS Treament Intensity Difference-in-Differences Results for Mortality from Diseases of the Circulatory System (per 100,000)") mlabels("(1)" "(2)" "(3)" "(4)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

esttab m15_cruderate_circulatory m16_cruderate_circulatory m17_cruderate_circulatory m18_cruderate_circulatory using continuous_under200_staggered_did_circulatory.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("OLS Treament Intensity (Low Income Adults) Difference-in-Differences Results for Mortality from Diseases of the Circulatory System (per 100,000)") mlabels("(1)" "(2)" "(3)" "(4)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

	* Crude Mortality per 100,000 from Neoplasms
esttab m11_cruderate_cancer m12_cruderate_cancer m13_cruderate_cancer m14_cruderate_cancer using continuous_staggered_did_circulatory.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("OLS Treament Intensity Difference-in-Differences Results for Mortality from Neoplasms (per 100,000)") mlabels("(1)" "(2)" "(3)" "(4)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

esttab m15_cruderate_cancer m16_cruderate_cancer m17_cruderate_cancer m18_cruderate_cancer using continuous_did_cancer_under200.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("OLS Treament Intensity (Low Income Adults) Difference-in-Differences Results for Mortality from Neoplasms (per 100,000)") mlabels("(1)" "(2)" "(3)" "(4)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

**********************************************************************
*********************** Event Study Analysis *************************
**********************************************************************

*** EVENT STUDY ANALYSIS

* Generate Sun & Abraham (2021) / OLS Event Study Graphs

use FINAL_10

	* OLS / Sun & Abraham (2021) Event Study Graphs
foreach outcome of global OUTCOMES {
	* OLS Event Study
eventdd `outcome' i.year i.county_state_id $CONTROLS, timevar(years_to_expansion) lags(8) leads(8) ci(rline) ols wboot_op(bootcluster(state)) accum
estimates store m19_`outcome'
	* Sun & Abraham (2021) Event Study
eventstudyinteract `outcome' lead8 lead7 lead6 lead5 lead4 lead3 lead2 lag0-lag7 lag8, absorb(i.county_state_id i.year) cohort(medicaid_year) control_cohort(non_medicaid) covariates($CONTROLS) vce(cluster state_fips)
matrix C_`outcome' = e(b_iw)
mata st_matrix("A_`outcome'", sqrt(st_matrix("e(V_iw)")))
matrix C_`outcome' = C_`outcome' \ A_`outcome'
matrix list C_`outcome'
	* Create Event Study Graphs
coefplot (m19_`outcome', keep(lead8 lead7 lead6 lead5 lead4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8)) (matrix(C_`outcome'[1]), se(C_`outcome'[2])), vertical order(lead8 lead7 lead6 lead5 lead4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8) coeflabels(lead8 = "-8" lead7 = "-7" lead6 = "-6" lead5 = "-5" lead4 = "-4" lead3 = "-3" lead2 = "-2" lag0 = "0" lag1 = "1" lag2 = "2" lag3 = "3" lag4 = "4" lag5 = "5" lag6 = "6" lag7 = "7" lag8 = "8")
graph save coefplot_`outcome'
}

**********************************************************************
*********************** SUTVA: MIGRATION RATES************************
**********************************************************************

*** DESCRIPTIVE STATISTICS FOR COUNTY-LEVEL MIGRATIONS RATES

use FINAL_2014

* Descriptive Statistics for 2014 Expansion Counties

	* Expansion Counties
summarize rnetmig if year == 2013 & medicaid == 1

	* Non-Expansion Counties
summarize rnetmig if year == 2013 & medicaid == 0

	* Visualize Trends
preserve
collapse (mean) rnetmig, by (medicaid year)
reshape wide rnetmig, i(year) j(medicaid)
graph twoway connect rnetmig* year
restore

graph save sutva_descriptives

use FINAL_PAIRS

eventdd rnetmig i.year i.county_state_id $CONTROLS, timevar(years_to_expansion) lags(5) leads(6) ci(rline) ols wboot_op(bootcluster(state)) accum
estimates store m20_rnetmig

eventstudyinteract rnetmig lead6 lead5 lead4 lead3 lead2 lag0-lag5, absorb(i.county_state_id i.year) cohort(medicaid_year) control_cohort(non_medicaid) covariates($CONTROLS) vce(cluster state_fips)

matrix C_rnetmig = e(b_iw)
mata st_matrix("A_rnetmig", sqrt(st_matrix("e(V_iw)")))
matrix C_rnetmig = C_rnetmig \ A_rnetmig
matrix list C_rnetmig

coefplot (m20_rnetmig, keep(lead8 lead7 lead6 lead5 lead4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8)) (matrix(C_rnetmig[1]), se(C_rnetmig[2])), vertical order(lead8 lead7 lead6 lead5 lead4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8) coeflabels(lead6 = "-6" lead5 = "-5" lead4 = "-4" lead3 = "-3" lead2 = "-2" lag0 = "0" lag1 = "1" lag2 = "2" lag3 = "3" lag4 = "4" lag5 = "5" lag6 = "6" lag7 = "7")

graph save coefplot_rnetmig

**********************************************************************
************************* Robustness Checks **************************
**********************************************************************

*** ALTERNATIVE SAMPLE RESTRICTIONS

* Sample Restriction: Population > 15,000
use FINAL_15

foreach outcome of varlist cruderate_all cruderate_20to64 cruderate_circulatory pctui {
	csdid `outcome' $CONTROLS, ivar(county_state_id) time(year) g(medicaid_year) wboot_op(bootcluster(state)) agg(simple)
	estimates store m21_`outcome'
}

esttab m21_cruderate_all m21_cruderate_20to64 m21_cruderate_circulatory m21_pctui using cs_staggered_did_robustness_15.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("Callaway & Sant'Anna Difference-in-Differences Results: 15,000 Sample Restriction") mlabels("(1)" "(2)" "(3)" "(4)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

clear

* Sample Restriction: Population > 20,000
use FINAL_20

foreach outcome of varlist cruderate_all cruderate_20to64 cruderate_circulatory pctui {
	csdid `outcome' $CONTROLS, ivar(county_state_id) time(year) g(medicaid_year) wboot_op(bootcluster(state)) agg(simple)
	estimates store m22_`outcome'
}

esttab m22_cruderate_all m22_cruderate_20to64 m22_cruderate_circulatory m22_pctui using cs_staggered_did_robustness_20.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("Callaway & Sant'Anna Difference-in-Differences Results: 20,000 Sample Restriction") mlabels("(1)" "(2)" "(3)" "(4)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

clear

* Sample Restriction: 2014 Expansion States
use FINAL_2014

foreach outcome of varlist cruderate_all cruderate_20to64 cruderate_circulatory pctui {
	csdid `outcome' $CONTROLS, ivar(county_state_id) time(year) g(medicaid_year) wboot_op(bootcluster(state)) agg(simple)
	estimates store m23_`outcome'
}

esttab m23_cruderate_all m23_cruderate_20to64 m23_cruderate_circulatory m23_pctui using cs_staggered_did_robustness_2014.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("Callaway & Sant'Anna Difference-in-Differences Results: 2014 Expansion States") mlabels("(1)" "(2)" "(3)" "(4)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

clear

* Sample Restriction: No Population Cutoff
use FINAL
foreach outcome of varlist cruderate_all cruderate_20to64 cruderate_circulatory pctui {
	csdid `outcome' $CONTROLS, ivar(county_state_id) time(year) g(medicaid_year) wboot_op(bootcluster(state)) agg(simple)
	estimates store m24_`outcome'
}

esttab m24_cruderate_all m24_cruderate_20to64 m24_cruderate_circulatory m24_pctui using cs_staggered_did_robustness_all, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("Callaway & Sant'Anna Difference-in-Differences Results: No Sample Restriction") mlabels("(1)" "(2)" "(3)" "(4)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

clear

* Sample Restriction: No Early Expanders
use FINAL_POST2014
foreach outcome of varlist cruderate_all cruderate_20to64 cruderate_circulatory pctui {
	csdid `outcome' $CONTROLS, ivar(county_state_id) time(year) g(medicaid_year) wboot_op(bootcluster(state)) agg(simple)
	estimates store m25_`outcome'
}

esttab m25_cruderate_all m25_cruderate_20to64 m25_cruderate_circulatory m25_pctui using cs_staggered_did_robustness_nopost2014.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("Callaway & Sant'Anna Difference-in-Differences Results: No Post-2014 Expansion States") mlabels("(1)" "(2)" "(3)" "(4)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

clear

	* Sample Restriction: No Late Expanders

use FINAL_PRE2014
foreach outcome of varlist cruderate_all cruderate_20to64 cruderate_circulatory pctui {
	csdid `outcome' $CONTROLS, ivar(county_state_id) time(year) g(medicaid_year) wboot_op(bootcluster(state)) agg(simple)
	estimates store m26_`outcome'
}

esttab m26_cruderate_all m26_cruderate_20to64 m26_cruderate_circulatory m26_pctui using cs_staggered_did_robustness_nopre2014.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations")) title("Callaway & Sant'Anna Difference-in-Differences Results: No Pre-2014 Expansion States") mlabels("(1)" "(2)" "(3)" "(4)") varlabels(ATET "Medicaid by Post" pct_h "% Hispanic" pct_bac "% Black" pct_female "% Female" med_house_income "Median Household Income" pct_over65 "% Over 65" pct_20to65 "% Aged 20-65" unemployment_rate "Unemployment Rate (%)" _cons "Constant") replace

clear

*** DROPPING INDIVIDUAL STATES

foreach code in AL AK AZ AR CA CO CT DE DC FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA VI WA WV WI WY {
	* Use Dataset
use FINAL_10
drop if post_code == "`code'"
csdid cruderate_20to64 $CONTROLS, ivar(county_state_id) time(year) g(medicaid_year) wboot_op(bootcluster(state)) agg(simple)
estimates store m27_`code'
clear
}

coefplot (m27_AL) (m27_AK) (m27_AZ) (m27_AR) (m27_CA) (m27_CO) (m27_CT) (m27_DE) (m27_DC) (m27_FL) (m27_GA) (m27_HI) (m27_ID) (m27_IL) (m27_IN) (m27_IA) (m27_KS) (m27_KY) (m27_LA) (m27_ME) (m27_MD) (m27_MA) (m27_MI) (m27_MN) (m27_MS) (m27_MO) (m27_MT) (m27_NE) (m27_NV) (m27_NH) (m27_NJ) (m27_NM) (m27_NY) (m27_NC) (m27_ND) (m27_OH) (m27_OK) (m27_OR) (m27_PA) (m27_RI) (m27_SC) (m27_SD) (m27_TN) (m27_TX) (m27_UT) (m27_VT) (m27_VA) (m27_VI) (m27_WA) (m27_WV) (m27_WI) (m27_WY), legend(off) aseq swapnames eqrename(m27_AL = Alabama m27_AK = Alaska m27_AZ = Arizona m27_AR = Arkansas m27_CA = California m27_CO = Colorado m27_CT = Connecticut m27_DE = Delaware m27_DC = "District of Columbia" m27_FL = Florida m27_GA = Georgia m27_HI = Hawaii m27_IA = Iowa m27_ID = Idaho m27_IL = Illinois m27_IN = Indiana m27_IA = Iowa m27_KS = Kansas m27_KY = Kentucky m27_LA = Louisiana m27_ME = Maine m27_MD = Maryland m27_MA = Massachusetts m27_MI = Michigan m27_MN = Minnesota m27_MS = Missouri m27_MO = Missouri m27_MT = Montana m27_NE = Nebraska m27_NV = Nevada m27_NH = "New Hampshire" m27_NJ = "New Jersey" m27_NM = "New Mexico" m27_NY = "New York" m27_NC = "North Carolina" m27_ND = "North Dakota" m27_OH = Ohio m27_OK = Oklahoma m27_OR = Oregon m27_PA = Pennsylvania m27_RI = "Rhode Island" m27_SC = "South Carolina" m27_SD = "South Dakota" m27_TN = Tennessee m27_TX = Texas m27_UT = Utah m27_VA = Virginia m27_VI = Virginia m27_VT = Vermont m27_WA = Washington m27_WV = "West Virginia" m27_WI = Wisconsin m27_WY = Wyoming) msize(vsmall) nooffset color(black) ciopts(color(black))


foreach code in AL AK AZ AR CA CO CT DE DC FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA VI WA WV WI WY {
	* Use Dataset
use FINAL_10
drop if post_code == "`code'"
csdid cruderate_circulatory $CONTROLS, ivar(county_state_id) time(year) g(medicaid_year) wboot_op(bootcluster(state)) agg(simple)
estimates store m28_`code'
clear
}

coefplot (m28_AL) (m28_AK) (m28_AZ) (m28_AR) (m28_CA) (m28_CO) (m28_CT) (m28_DE) (m28_DC) (m28_FL) (m28_GA) (m28_HI) (m28_ID) (m28_IL) (m28_IN) (m28_IA) (m28_KS) (m28_KY) (m28_LA) (m28_ME) (m28_MD) (m28_MA) (m28_MI) (m28_MN) (m28_MS) (m28_MO) (m28_MT) (m28_NE) (m28_NV) (m28_NH) (m28_NJ) (m28_NM) (m28_NY) (m28_NC) (m28_ND) (m28_OH) (m28_OK) (m28_OR) (m28_PA) (m28_RI) (m28_SC) (m28_SD) (m28_TN) (m28_TX) (m28_UT) (m28_VT) (m28_VA) (m28_VI) (m28_WA) (m28_WV) (m28_WI) (m28_WY), legend(off) aseq swapnames eqrename(m28_AL = Alabama m28_AK = Alaska m28_AZ = Arizona m28_AR = Arkansas m28_CA = California m28_CO = Colorado m28_CT = Connecticut m28_DE = Delaware m28_DC = "District of Columbia" m28_FL = Florida m28_GA = Georgia m28_HI = Hawaii m28_IA = Iowa m28_ID = Idaho m28_IL = Illinois m28_IN = Indiana m28_IA = Iowa m28_KS = Kansas m28_KY = Kentucky m28_LA = Louisiana m28_ME = Maine m28_MD = Maryland m28_MA = Massachusetts m28_MI = Michigan m28_MN = Minnesota m28_MS = Missouri m28_MO = Missouri m28_MT = Montana m28_NE = Nebraska m28_NV = Nevada m28_NH = "New Hampshire" m28_NJ = "New Jersey" m28_NM = "New Mexico" m28_NY = "New York" m28_NC = "North Carolina" m28_ND = "North Dakota" m28_OH = Ohio m28_OK = Oklahoma m28_OR = Oregon m28_PA = Pennsylvania m28_RI = "Rhode Island" m28_SC = "South Carolina" m28_SD = "South Dakota" m28_TN = Tennessee m28_TX = Texas m28_UT = Utah m28_VA = Virginia m28_VI = Virginia m28_VT = Vermont m28_WA = Washington m28_WV = "West Virginia" m28_WI = Wisconsin m28_WY = Wyoming) msize(vsmall) nooffset color(black) ciopts(color(black))

*** DOUBLE LASSO VARIABLE SELECTION

foreach variable of global OUTCOMES {
	dsregress `variable' medicaid_status, controls((i.county_state_id i.year) unemployment_rate med_house_income pov_pct_under_18 log_tot_pop pct_tot_pop_20to65 pct_tot_pop_over65  pct_tot_female pct_tot_female_20to65 pct_wac_female pct_wac_female_20to65 pct_bac pct_bac_female_20to65  pct_h pct_h_female pct_h_female_20to65) vce(cluster state_fips)
	estimates store m29_`variable'
}

*** ALTERNATIVE PERCENT UNINSURED VARIABLE: ADULTS UNDER 200% OF THE FPL

eventdd pctui_200_18to64 i.year i.county_state_id $CONTROLS, timevar(years_to_expansion) lags(8) leads(8) ci(rline) ols wboot_op(bootcluster(state)) accum
estimates store m30_pctui_200_18to64

eventstudyinteract pctui_200_18to64 lead8 lead7 lead6 lead5 lead4 lead3 lead2 lag0-lag8, absorb(i.county_state_id i.year) cohort(medicaid_year) control_cohort(non_medicaid) covariates($CONTROLS) vce(cluster state_fips)

matrix C_pctui_200_18to64 = e(b_iw)
mata st_matrix("A_pctui_200_18to64", sqrt(st_matrix("e(V_iw)")))
matrix C_pctui_200_18to64 = C_pctui_200_18to64 \ A_pctui_200_18to64
matrix list C_pctui_200_18to64

coefplot (m30_pctui_200_18to64, keep(lead8 lead7 lead6 lead5 lead4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8)) (matrix(C_pctui_200_18to64[1]), se(C_pctui_200_18to64[2])), vertical order(lead8 lead7 lead6 lead5 lead4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8) coeflabels(lead8 = "<-8" lead7 = "-7" lead6 = "-6" lead5 = "-5" lead4 = "-4" lead3 = "-3" lead2 = "-2" lag0 = "0" lag1 = "1" lag2 = "2" lag3 = "3" lag4 = "4" lag5 = "5" lag6 = "6" lag7 = "7" lag8 = "8<")


* ALTERNATIVE MEDICAID EXPANSION VARIABLE

* Callaway & Sant'Anna (2021) Two Way Fixed Effects

	* No Controls
foreach outcome of global OUTCOMES {
	csdid `outcome', ivar(county_state_id) time(year) g(medicaid_year_alt) wboot_op(bootcluster(state)) agg(simple)
	estimates store m31_`outcome'
}

	* Demographic Controls
foreach outcome of global OUTCOMES {
	csdid `outcome' $DEMOGRAPHIC_CONTROLS, ivar(county_state_id) time(year) g(medicaid_year_alt) wboot_op(bootcluster(state)) agg(simple)
	estimates store m32_`outcome'
}

	* Economic Controls
foreach outcome of global OUTCOMES {
	csdid `outcome' $ECONOMIC_CONTROLS, ivar(county_state_id) time(year) g(medicaid_year_alt) wboot_op(bootcluster(state)) agg(simple)
	estimates store m33_`outcome'
}

	* All Controls
foreach outcome of global OUTCOMES {
	csdid `outcome' $CONTROLS, ivar(county_state_id) time(year) g(medicaid_year_alt) wboot_op(bootcluster(state)) agg(simple)
	estimates store m34_`outcome'
}

esttab m34_cruderate_all m34_cruderate_20to64 m34_cruderate_circulatory m34_pctui using did_cs_robustness_altmedicaid.tex, style(tex) b(%9.2f) se(%9.2f) label nonum legend stats(N, fmt(%9.0f) labels("Observations)")) title("Callway & Sant'Anna Difference-in-Differences Results: Alternative Medicaid Expansion Coding'") mlabels("(1)" "(2)" "(3)" "(4)") replace



