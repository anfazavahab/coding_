********************************************************************************
* GINI INEQUALITY INDEX AND GINI SOCIAL WELFARE FUNCTION
* Author: Anfaz Abdul Vahab
********************************************************************************
*------------------------------------------------------------------------------*
* Contents
* Question 1: Gini Social Welfare and Gini Inequality Index for Finland
* Question 2.1: Historical trend of Gini SWF and Inequality index
* Question 2.2: Gini SWF and Inequality index using individual incomes
* Question 2.3: Comparison of Lithuania, Finland, Spain
*------------------------------------------------------------------------------*

********************************************************************************
* Question 1: Choose one country from EU-SILC data, take the first and last 
* years of the survey, and compute, for household disposable income (HY020), 
* the Gini social welfare and the Gini inequality index.
********************************************************************************

*==============================================================================*
* Country: Finland
* Years: 2004 and 2013
* Variable: HY020 (Household Disposable Income)
* Deflator: CPI Finland, base year 2015=100
* Help of AI is used for trouble shooting and code corrections
*==============================================================================*

clear all
set more off
capture log close
log using "C:\Users\dell\Downloads\Eurostat\gini_finland.log", replace

cd "C:\Users\dell\Downloads\Eurostat"
********************************************************************************
* PREPARE 2004 DATA FOR MERGING H-FILE and D-FILE 2004
********************************************************************************
*H-FILE
import delimited "C:\Users\dell\Downloads\Eurostat\FI_2004h_EUSILC.csv", clear
describe
keep hb030 hy020 // Keep only the household id and income variable
save "C:\Users\dell\Downloads\Eurostat\temp_2004h.dta", replace

*D-FILE
import delimited "C:\Users\dell\Downloads\Eurostat\FI_2004d_EUSILC.csv", clear
describe
keep db030 db090 // Household id and cross sectional weight
rename db030 hb030
save "C:\Users\dell\Downloads\Eurostat\temp_2004d.dta", replace
********************************************************************************
* MERGE 2004 FILES
********************************************************************************

use "C:\Users\dell\Downloads\Eurostat\temp_2004h.dta", clear
merge 1:1 hb030 using "C:\Users\dell\Downloads\Eurostat\temp_2004d.dta"
tab _merge
keep if _merge == 3
drop _merge
gen year = 2004
save "C:\Users\dell\Downloads\Eurostat\finland_2004_merged.dta", replace
********************************************************************************
* PREPARE 2013 DATA FOR MERGING H-FILE and D-FILE
********************************************************************************
* H-FILE
import delimited "C:\Users\dell\Downloads\Eurostat\FI_2013h_EUSILC.csv", clear
describe
keep hb030 hy020
save "C:\Users\dell\Downloads\Eurostat\temp_2013h.dta", replace

* D-FILE
import delimited "C:\Users\dell\Downloads\Eurostat\FI_2013d_EUSILC.csv", clear
describe
keep db030 db090
rename db030 hb030
save "C:\Users\dell\Downloads\Eurostat\temp_2013d.dta", replace
********************************************************************************
* MERGE 2013 FILES
********************************************************************************

use "C:\Users\dell\Downloads\Eurostat\temp_2013h.dta", clear
merge 1:1 hb030 using "C:\Users\dell\Downloads\Eurostat\temp_2013d.dta"
tab _merge
keep if _merge == 3
drop _merge
gen year = 2013

save "C:\Users\dell\Downloads\Eurostat\finland_2013_merged.dta", replace

********************************************************************************
* APPEND BOTH YEARS INTO ONE DATASET
********************************************************************************

use "C:\Users\dell\Downloads\Eurostat\finland_2004_merged.dta", clear
append using "C:\Users\dell\Downloads\Eurostat\finland_2013_merged.dta"

tab year
sum hy020 db090

********************************************************************************
* DATA CLEANING
********************************************************************************

* Check missing values
misstable summarize hy020 db090

* Drop zero or negative incomes
drop if hy020 <= 0 

* Verify weights are all positive
sum db090

* Summary by year after cleaning
by year, sort: sum hy020 db090

********************************************************************************
* DEFLATE HY020 TO REAL 2015 EUROS, CPI Finland (OECD, 2015=100)
*   2004 = 83.32
*   2013 = 99.17
********************************************************************************

gen cpi = .
replace cpi = 83.32 if year == 2004
replace cpi = 99.17 if year == 2013

* Deflation formula: hy020_real = hy020 * (100 / cpi)
gen hy020_real = hy020 * (100 / cpi)

* Label variables
label variable hy020      "Nominal household disposable income (current euros)"
label variable hy020_real "Real household disposable income (2015 euros)"
label variable db090      "Household cross-sectional weight"
label variable cpi        "CPI Finland 2015=100"
label variable year       "Survey year"

* Compare nominal vs real means by year
by year, sort: sum hy020 hy020_real [aw=db090]

* Save cleaned dataset
save "C:\Users\dell\Downloads\Eurostat\finland_clean_final.dta", replace

* Export to CSV
export delimited using "C:\Users\dell\Downloads\Eurostat\finland_microdata_clean.csv", replace
********************************************************************************
* SET SURVEY DESIGN AND COMPUTE WEIGHTED MEAN (WEIGHT=DB090)
********************************************************************************

svyset [pw=db090]

* Weighted mean for 2004
quietly svy: mean hy020_real if year == 2004
scalar mu_2004 = e(b)[1,1]
display "Weighted mean real income 2004: EUR " %10.2f mu_2004

* Weighted mean for 2013
quietly svy: mean hy020_real if year == 2013
scalar mu_2013 = e(b)[1,1]
display "Weighted mean real income 2013: EUR " %10.2f mu_2013
********************************************************************************
* WEIGHTED GINI INDEX
********************************************************************************

*ssc install fastgini   

* Gini for 2004
fastgini hy020_real [pw=db090] if year == 2004
scalar G_2004 = r(gini)
display "Gini index 2004: " %6.4f G_2004

* Gini for 2013
fastgini hy020_real [pw=db090] if year == 2013
scalar G_2013 = r(gini)
display "Gini index 2013: " %6.4f G_2013
********************************************************************************
* GINI SOCIAL WELFARE FUNCTION
* Formula: W = mu * (1 - G)
********************************************************************************

scalar W_2004 = mu_2004 * (1 - G_2004)
scalar W_2013 = mu_2013 * (1 - G_2013)

display "Social Welfare 2004: EUR " %10.2f W_2004
display "Social Welfare 2013: EUR " %10.2f W_2013
********************************************************************************
* PERCENTAGE CHANGES
********************************************************************************

scalar delta_mu = ((mu_2013 - mu_2004) / mu_2004) * 100
scalar delta_G  = ((G_2013  - G_2004)  / G_2004)  * 100
scalar delta_W  = ((W_2013  - W_2004)  / W_2004)  * 100

********************************************************************************
* FINAL RESULTS TABLE
********************************************************************************

display " "
display "========================================================"
display "   RESULTS: FINLAND EU-SILC 2004 vs 2013               "
display "   Incomes in constant 2015 euros (CPI deflated)        "
display "========================================================"
display "Indicator               2004          2013      % Change"
display "--------------------------------------------------------"
display "Mean income (mu)   " %10.2f mu_2004 "  " %10.2f mu_2013 "  " %8.2f delta_mu
display "Gini index (G)     " %10.4f G_2004  "  " %10.4f G_2013  "  " %8.2f delta_G
display "Social Welfare (W) " %10.2f W_2004  "  " %10.2f W_2013  "  " %8.2f delta_W
display "--------------------------------------------------------"
display "Note: W = mu * (1 - G)"
display "Note: CPI base year 2015=100. 2004=83.32, 2013=99.17"
display "========================================================"

log close

********************************************************************************
********************************************************************************

********************************************************************************
** Quesion 2: Using the EU-SILC data, do the following:
* 2.1. Take more than two years and draw a graph of the historical trend in
* both social welfare and inequality.
* 2.2. Take individuals rather than household income. Explain which notion of individual income you have used.
* 2.3.Compare several countries.
********************************************************************************

*==============================================================================*
* Quesion 2.1 Historical trend of Gini SWF and Inequality
* Country: Finland (FI)
* Years: 2004, 2006, 2008, 2010, 2013
* Variable: HY020 (Household Disposable Income)
* Deflator: CPI Finland, base year 2015=100
*==============================================================================*

clear all
set more off
capture log close
log using "C:\Users\dell\Downloads\Eurostat\gini_finland_all_years.log", replace

cd "C:\Users\dell\Downloads\Eurostat"
********************************************************************************
* MERGING 2004, 2006, 2008, 2010, 2013 DATA
********************************************************************************

foreach y in 2004 2006 2008 2010 2013 {

    import delimited "FI_`y'h_EUSILC.csv", clear
    rename *, lower
    keep hb030 hy020
    save temp_`y'h.dta, replace

    import delimited "FI_`y'd_EUSILC.csv", clear
    rename *, lower
    keep db030 db090
    rename db030 hb030
    save temp_`y'd.dta, replace

    use temp_`y'h.dta, clear
    merge 1:1 hb030 using temp_`y'd.dta
    keep if _merge == 3
    drop _merge
    gen year = `y'
    save finland_`y'.dta, replace
    display "Year `y' ready — observations: " _N
}
********************************************************************************
* APPEND ALL YEARS
********************************************************************************

use finland_2004.dta, clear
foreach y in 2006 2008 2010 2013 {
    append using finland_`y'.dta
}

tab year
sum hy020 db090
********************************************************************************
* CLEAN DATA
********************************************************************************

drop if missing(hy020)
drop if missing(db090)
drop if hy020 <= 0
assert db090 > 0

by year, sort: sum hy020 db090
********************************************************************************
* DEFLATE TO REAL 2015 EUROS (Source: OECD)
********************************************************************************

gen cpi = .
replace cpi = 83.32 if year == 2004
replace cpi = 85.15 if year == 2006
replace cpi = 90.84 if year == 2008
replace cpi = 91.92 if year == 2010
replace cpi = 99.17 if year == 2013

gen hy020_real = hy020 * (100 / cpi)

label variable hy020_real "Real household income (2015 EUR)"
label variable year       "Survey year"

save finland_all_years.dta, replace
********************************************************************************
* MEAN, GINI INDEX AND GINI SWF FOR EACH YEAR
********************************************************************************

postfile myresults     ///
    int    year        ///
    double mean_income ///
    double gini        ///
    double welfare     ///
    using results_all_years.dta, replace

svyset [pw=db090]

foreach y in 2004 2006 2008 2010 2013 {

    quietly svy: mean hy020_real if year == `y'
    scalar mu_`y' = e(b)[1,1]

    fastgini hy020_real [pw=db090] if year == `y'
    scalar G_`y' = r(gini)

    scalar W_`y' = mu_`y' * (1 - G_`y')

    post myresults (`y') (mu_`y') (G_`y') (W_`y')

    display "Year `y': mu=" %10.2f mu_`y' ///
            " G=" %6.4f G_`y'             ///
            " W=" %10.2f W_`y'
}

postclose myresults
********************************************************************************
* FINAL RESULTS
********************************************************************************

use results_all_years.dta, clear
sort year

display " "
display "============================================================"
display "   FINLAND EU-SILC: ALL YEARS RESULTS"
display "   Incomes in constant 2015 euros"
display "============================================================"
display "Year    Mean Income      Gini        Welfare"
display "------------------------------------------------------------"
list year mean_income gini welfare, noobs clean

export delimited using "finland_results_all_years.csv", replace

********************************************************************************
* GRAPH: GINI INDEX AND SOCIAL WELFARE
********************************************************************************

use results_all_years.dta, clear

twoway ///
    (line gini year, ///
        lwidth(medthick) lcolor(navy) lpattern(solid) ///
        yaxis(1)) ///
    (line welfare year, ///
        lwidth(medthick) lcolor(cranberry) lpattern(solid) ///
        yaxis(2)) ///
    , ///
    title("Finland: Gini Inequality and Social Welfare (2004-2013)", ///
        size(medsmall)) ///
    ytitle("Gini Index", axis(1) size(small)) ///
    ytitle("Social Welfare", axis(2) size(small)) ///
    xtitle("Year", size(small)) ///
    xlabel(2004 2006 2008 2010 2013, labsize(small)) ///
    ylabel(, axis(1) labsize(small) format(%5.4f)) ///
    ylabel(, axis(2) labsize(small) format(%10.0fc)) ///
    legend(order(1 "Gini Index" ///
                 2 "Social Welfare") ///
        size(small) position(6) rows(1)) ///
    graphregion(color(white)) ///
    plotregion(color(white) margin(small))

graph export "finland_gini_welfare.png", replace width(1200)
display "Graph exported: finland_gini_welfare.png"

log close

********************************************************************************
********************************************************************************

*==============================================================================*
* Question 2.2: INDIVIDUAL GINI INEQUALITY INDEX AND SOCIAL WELFARE FUNCTION
* Country: Finland (FI)
* Years: 2004, 2006, 2008, 2010, 2013
* Income: PY010G (Gross Personal Income)
* Weight: RB050 (Personal cross-sectional weight)
*==============================================================================*

clear all
set more off
capture log close

cd "C:\Users\dell\Downloads\Eurostat"
log using "finland_individual_gini.log", replace

********************************************************************************
* MERGE AND SAVE EACH YEAR USING LOOP
********************************************************************************

foreach y in 2004 2006 2008 2010 2013 {

    * Load P-file (personal income)
    import delimited "FI_`y'p_EUSILC.csv", clear
    rename *, lower
    keep pb030 py010g
    duplicates drop pb030, force
    save temp_`y'p.dta, replace

    * Load R-file (personal weights)
    import delimited "FI_`y'r_EUSILC.csv", clear
    rename *, lower
    keep rb030 rb050
    duplicates drop rb030, force
    rename rb030 pb030
    save temp_`y'r.dta, replace

    * Merge P and R files
    use temp_`y'p.dta, clear
    merge 1:1 pb030 using temp_`y'r.dta
    tab _merge
    keep if _merge == 3
    drop _merge
    gen year = `y'
    save finland_`y'.dta, replace
    display "Year `y' ready — observations: " _N
}

********************************************************************************
* APPEND ALL YEARS
********************************************************************************

use finland_2004.dta, clear
foreach y in 2006 2008 2010 2013 {
    append using finland_`y'.dta
}

display "=== Observations per year before cleaning ==="
tab year

********************************************************************************
* CLEAN DATA
********************************************************************************

drop if missing(py010g)
drop if missing(rb050)
drop if py010g <= 0
assert rb050 > 0

display "=== Observations per year after cleaning ==="
tab year
by year, sort: sum py010g rb050

********************************************************************************
* DEFLATE TO REAL 2015 EUROS
********************************************************************************

gen cpi = .
replace cpi = 83.32 if year == 2004
replace cpi = 85.15 if year == 2006
replace cpi = 90.84 if year == 2008
replace cpi = 91.92 if year == 2010
replace cpi = 99.17 if year == 2013

gen income_real = py010g * (100 / cpi)

label variable income_real "Real gross personal income (2015 EUR)"
label variable year        "Survey year"

save finland_individual_all.dta, replace

********************************************************************************
* MEAN, GINI AND WELFARE
********************************************************************************

postfile myresults     ///
    int    year        ///
    double mean_income ///
    double gini        ///
    double welfare     ///
    using results_individual.dta, replace

svyset [pw=rb050]

foreach y in 2004 2006 2008 2010 2013 {

    * Weighted mean
    quietly svy: mean income_real if year == `y'
    scalar mu_`y' = e(b)[1,1]

    * Weighted Gini
    fastgini income_real [pw=rb050] if year == `y'
    scalar G_`y' = r(gini)

    * Social welfare
    scalar W_`y' = mu_`y' * (1 - G_`y')

    * Store results
    post myresults (`y') (mu_`y') (G_`y') (W_`y')

    display "Year `y': mu=" %10.2f mu_`y' ///
            " G=" %6.4f G_`y'             ///
            " W=" %10.2f W_`y'
}

postclose myresults

********************************************************************************
* RESULTS TABLE
********************************************************************************

use results_individual.dta, clear
sort year

display " "
display "============================================================"
display "   INDIVIDUAL RESULTS — FINLAND (Real 2015 EUR)"
display "   Income: PY010G, Weight: RB050"
display "============================================================"
display "Year    Mean Income      Gini        Welfare"
display "------------------------------------------------------------"
list year mean_income gini welfare, noobs clean separator(0)

export delimited using "finland_individual_results.csv", replace

********************************************************************************
* GRAPH: GINI INDEX AND SOCIAL WELFARE 
********************************************************************************

use results_individual.dta, clear

twoway ///
    (line gini year, ///
        lwidth(medthick) lcolor(navy) lpattern(solid) ///
        yaxis(1)) ///
    (line welfare year, ///
        lwidth(medthick) lcolor(cranberry) lpattern(solid) ///
        yaxis(2)) ///
    , ///
    title("Finland: Individual Inequality and Social Welfare (2004-2013)", ///
        size(medsmall)) ///
    ytitle("Gini Index", axis(1) size(small)) ///
    ytitle("Social Welfare ", axis(2) size(small)) ///
    xtitle("Year", size(small)) ///
    xlabel(2004 2006 2008 2010 2013, labsize(small)) ///
    ylabel(, axis(1) labsize(small) format(%5.4f)) ///
    ylabel(, axis(2) labsize(small) format(%10.0fc)) ///
    legend(order(1 "Gini Index" ///
                 2 "Social Welfare") ///
        size(small) position(6) rows(1)) ///
    note("", ///
        size(vsmall)) ///
    graphregion(color(white)) ///
    plotregion(color(white) margin(small))

graph export "finland_individual_gini_welfare.png", replace width(1200)

********************************************************************************
* CLEAN UP TEMP FILES
********************************************************************************

foreach y in 2004 2006 2008 2010 2013 {
    capture erase temp_`y'p.dta
    capture erase temp_`y'r.dta
    capture erase finland_`y'.dta
}

display "Temp files deleted"

log close

********************************************************************************
********************************************************************************

*==============================================================================*
* Question 2.3: COUNTRY COMPARISON: FINLAND, LITHUANIA, SPAIN
* Income: HY020
* Weight: DB090
* Welfare: W = mu(1-G)
*==============================================================================*

clear all
set more off
capture log close

cd "C:\Users\dell\Downloads\Eurostat"

********************************************************************************
* DEFINE COUNTRY LIST
********************************************************************************

local countries FI LT ES

tempfile master_results
save `master_results', emptyok replace

********************************************************************************
* LOOP OVER COUNTRIES AND YEARS
********************************************************************************

foreach c of local countries {

    display "Processing country: `c'"

    * Define years by country
    if "`c'"=="FI" local years 2004 2006 2008 2010 2013
    if "`c'"=="ES" local years 2004 2006 2008 2010 2013
    if "`c'"=="LT" local years 2005 2008 2010 2013

    foreach y of local years {

        display "Year: `y'"

        * Import H file
        import delimited "`c'_`y'h_EUSILC.csv", clear
        keep hb030 hy020
        save temp_h.dta, replace

        * Import D file
        import delimited "`c'_`y'd_EUSILC.csv", clear
        keep db030 db090
        rename db030 hb030
        save temp_d.dta, replace

        * Merge
        use temp_h.dta, clear
        merge 1:1 hb030 using temp_d.dta
        keep if _merge==3
        drop _merge

        gen country = "`c'"
        gen year = `y'

        * Clean
        drop if missing(hy020)
        drop if missing(db090)
        drop if hy020<=0

        ********************************************************************************
        * CPI VALUES (OECD)
        ********************************************************************************

        gen cpi = .

        * -------- FINLAND --------
        replace cpi = 83.32 if country=="FI" & year==2004
        replace cpi = 85.15 if country=="FI" & year==2006
        replace cpi = 90.84 if country=="FI" & year==2008
        replace cpi = 91.92 if country=="FI" & year==2010
        replace cpi = 99.17 if country=="FI" & year==2013

        * -------- LITHUANIA -------- 
        replace cpi = 72.16 if country=="LT" & year==2005
        replace cpi = 87.80 if country=="LT" & year==2008
        replace cpi = 92.92 if country=="LT" & year==2010
        replace cpi = 100.79 if country=="LT" & year==2013

        * -------- SPAIN -------- 
        replace cpi = 80.80 if country=="ES" & year==2004
        replace cpi = 86.46 if country=="ES" & year==2006
        replace cpi = 92.49 if country=="ES" & year==2008
        replace cpi = 93.89 if country=="ES" & year==2010
        replace cpi = 100.66 if country=="ES" & year==2013

        gen income_real = hy020*(100/cpi)

        ********************************************************************************
        * SET SURVEY DESIGN
        ********************************************************************************

        svyset [pw=db090]

        quietly svy: mean income_real
        scalar mu = e(b)[1,1]

        fastgini income_real [pw=db090]
        scalar G = r(gini)

        scalar W = mu*(1-G)

        ********************************************************************************
        * STORE RESULTS
        ********************************************************************************

        clear
        set obs 1
        gen country="`c'"
        gen year=`y'
        gen mean_income=mu
        gen gini=G
        gen welfare=W

        append using `master_results'
        save `master_results', replace
    }
}

use `master_results', clear
sort country year

********************************************************************************
* TABLE OUTPUT
********************************************************************************

display "=================================================================="
display "COUNTRY COMPARISON (Real 2015 EUR)"
display "=================================================================="
list country year mean_income gini welfare, sepby(country)

********************************************************************************
* GRAPH: GINI AND WELFARE SIDE BY SIDE — COMBINED
********************************************************************************

twoway ///
    (line gini year if country=="FI", ///
        lwidth(medthick) lcolor(navy) lpattern(solid)) ///
    (line gini year if country=="LT", ///
        lwidth(medthick) lcolor(forest_green) lpattern(dash)) ///
    (line gini year if country=="ES", ///
        lwidth(medthick) lcolor(cranberry) lpattern(shortdash)) ///
    , ///
    title("Gini Inequality Index", size(medsmall)) ///
    ytitle("Gini Index", size(small)) ///
    xtitle("Year", size(small)) ///
    xlabel(2004 2006 2008 2010 2013, labsize(small)) ///
    ylabel(, labsize(small) format(%5.4f)) ///
    legend(order(1 "Finland" 2 "Lithuania" 3 "Spain") ///
        size(small) position(6) rows(1)) ///
    graphregion(color(white)) ///
    plotregion(color(white) margin(small)) ///
    nodraw name(graph_gini, replace)

twoway ///
    (line welfare year if country=="FI", ///
        lwidth(medthick) lcolor(navy) lpattern(solid)) ///
    (line welfare year if country=="LT", ///
        lwidth(medthick) lcolor(forest_green) lpattern(dash)) ///
    (line welfare year if country=="ES", ///
        lwidth(medthick) lcolor(cranberry) lpattern(shortdash)) ///
    , ///
    title("Gini Social Welfare Function", size(medsmall)) ///
    ytitle("Social Welfare (2015 EUR)", size(small)) ///
    xtitle("Year", size(small)) ///
    xlabel(2004 2006 2008 2010 2013, labsize(small)) ///
    ylabel(, labsize(small) format(%10.0fc)) ///
    legend(order(1 "Finland" 2 "Lithuania" 3 "Spain") ///
        size(small) position(6) rows(1)) ///
    graphregion(color(white)) ///
    plotregion(color(white) margin(small)) ///
    nodraw name(graph_welfare, replace)

* Combine side by side
graph combine graph_gini graph_welfare ///
    , ///
    title("Finland, Lithuania and Spain: Inequality and Welfare (2004-2013)", ///
        size(medsmall)) ///
    note(, ///
        size(vsmall)) ///
    rows(1) ///
    xsize(10) ysize(4) ///
    graphregion(color(white))

graph export "gini_welfare_combined.png", replace width(2000)

********************************************************************************
********************************************************************************
***************               END OF DO FILE                     ***************