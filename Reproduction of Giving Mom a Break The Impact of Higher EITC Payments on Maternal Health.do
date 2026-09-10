********************************************************************************
* Applied Econometrics Assignment 2025-26                                      *
* Assignment: Reproduction of Tables 1-4 from:                                 *
* "Giving Mom a Break: The Impact of Higher EITC Payments on Maternal Health"  *
* by William N. Evans and Craig L. Garthwaite                                  *
*                                                                              *
* Paper reproduced by:                                                         *
*   Anfaz Abdul Vahab    (NOMA: ********)                                      *
*   Romain Albert        (NOMA: ********)                                     *
*                                                                              *
* Data Source: Behavioral Risk Factor Surveillance System (BRFSS)              *
* Date: 08/12/2025                                                             *
********************************************************************************

*------------------------------------------------------------------------------*
* Contents                                                                     *
*------------------------------------------------------------------------------*

* 1. Descriptive Statistics
* 2. Check for parallel trends
* 3. Table 1. Sample Characteristics
* 4. Table 2. Earned Income Tax Receipt, Tax years 1993-1995 and 1998-2000
* 5. Table 3. Difference in Difference estimates
* 6. Table 4. Robostness tests
* 7. Figure 1. EITC Payments for Families, 1993 and 1996.

*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
* Set working directory and load data                                          *
*------------------------------------------------------------------------------*

cd "C:\Users\dell\Downloads\ECON2MA study materials\Applied Ecotrix\project"

use BRFSS, clear // Load BRFSS data

* Create income category variables
gen income1 = (income == 1)              // Income < $20K
gen income2 = inlist(income, 2, 3, 4)    // Income $20K-$50K
gen income5 = (income == 5)              // Income ≥ $50K
gen incomemiss = (missing(income))       // Missing income

* Create DiD variables
gen treat = (twoplus_kids == 1)  // Treatment group: mothers with 2+ children
gen post = (year >= 1996)        // Post-treatment period: 1996 and later
gen did = treat * post           // DiD interaction term

*------------------------------------------------------------------------------*
* Label variables for clear presentation                                       *
*------------------------------------------------------------------------------*
label var age "Age"
label var working "% Currently employed"
label var income "Family Income"
label var sex "Sex"
label var fips "State code"
label var month "Month of interview"
label var marital "Marital status"
label var year "Year of interview"
label var kids "Number of Kids"
label var employ "Employment status"
label var race "Race/Ethnicity"
label var educ "Education"
label var black_nh "% Black non-Hispanic"
label var white_nh "% White non-Hispanic"
label var hispanic "% Hispanic"
label var other "% Other race"
label var married "% Married"
label var div_sep_wid "% Divorced/Separated/Widowed"
label var never_married "% Never married"
label var income1 "<$20K"
label var income2 "≥$20K & <$50K"
label var income5 "≥$50K"
label var incomemiss "Income missing"
label var excel_vgood "Excellent or very good health"
label var bad_mental_30 "% With any bad mental health days"
label var bad_phys_30 "% With any bad physical health days"
label var mental_poor "Number of bad mental health days"
label var phys_poor "Number of bad physical health days"

*------------------------------------------------------------------------------*
* Descriptive Statistics: Only important variables                             *
*------------------------------------------------------------------------------*

estpost summarize age income educ sex fips month year marital kids employ working race4 ///
    bad_mental_30 bad_phys_30 excel_vgood mental_poor phys_poor

esttab using "Descriptive stats.csv", ///
    replace ///
    cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3)) min(fmt(2)) max(fmt(2))") ///
    collabels("Observations" "Mean" "SD" "Min" "Max") ///
    label ///
    nonumber ///
    noobs ///
    nomtitles ///
    title("Descriptive Statistics")
	
*------------------------------------------------------------------------------*
* Check for parallel trends for outcome at work and excel_vgood                *
*------------------------------------------------------------------------------*
preserve
* Restrict to pre-treatment years
keep if year <= 1995

* Run pre-trend regression for excellent/very good health
reg excel_vgood i.year##i.twoplus_kids

* Test whether pre-treatment trends differ
testparm i.year#i.twoplus_kids 
display "excel_vgood pre-trend p-value: " r(p)

* Run pre-trend regression for At work
reg working i.year##i.twoplus_kids

* Test whether pre-treatment trends differ
testparm i.year#i.twoplus_kids
display "working pre-trend p-value: " r(p)

restore
*------------------------------------------------------------------------------*
* Table 1 Earned Income Tax Receipt by Education and Number of Children,       * 
* Mothers Age 21–40, Tax Years 1993–1995 and 1998–2001                         *
*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
* Preparing the data for analysis                                              *
*------------------------------------------------------------------------------*

* Create the categorical variables required for Table 1

** 1. Time period (Tax years 1993–1995 vs Tax years 1998–2000)

/* NOTE:
 1. Because the March CPS asks about income earned in the previous year, data 
 from the 1994–1996 CPS presents data for the 1993–1995 tax years (see footnote 10). 
 2. The variable "year" corresponds to the year of interview; therefore, for the
 analysis using this data, we start from the year 1994, which corresponds to tax
 year 1993. Tax years 1993-1995 = Interview years 1994-1996: 
 Tax years 1998-2000 = Interview years 1999-2001
 3. Data for tax year 2001 is missing because data for the year 2002 is not 
 available in the dataset.
 4. As a result, the analysis years have become Tax Years 1993–1995 vs Tax Years 1998–2000.
 5. While data for the year 1993 is given, it corresponds to tax year 1992; 
 therefore, samples from the year 1993 are removed.
 6. Samples corresponding to the years 1997 and 1998 are removed because they 
 are not needed for the analysis.
*/

preserve

drop if inlist(year, 1993, 1997, 1998) // dropping the years not required for the table

** Create indicator variable post_obra 
gen post_obra = 1 if inlist(year, 1999, 2000, 2001)  // Tax years 1998–2000
replace post_obra = 0 if inlist(year, 1994, 1995, 1996) // Tax years 1993-1995
label define post_obra_lbl 0 "Tax years 1993-1995" 1 "Tax years 1998–2000"
label values post_obra post_obra_lbl
label variable post_obra "pre and post obra93"

* 2. Education groups (≤ High school vs College graduate)

/** NOTE:
 1. Since we are using only the sample belonging to either high school or less 
 or college graduate, we drop the samples for educ = 3 (some college) to 
 maintain clear comparison groups. **/
keep if inlist(educ, 1, 2, 4) // keep only the obervations will high school or less and college graduate
** Create indicator variable colgrad
gen colgrad = 1 if educ == 4  // College graduate 
replace colgrad = 0 if inlist(educ, 1, 2)  // ≤ High school
label define colgrad_lbl 0 "<= High school" 1 "College graduate"
label values colgrad colgrad_lbl

* 3. Number of children groups ( 1 Child vs 2+ Kids)
/** NOTE:
1. Removing the samples with 0 kids. **/
keep if kids >= 1  // Restricting the samples with atleast one child

* Create indicator variable twoplus
gen twoplus = 1 if inlist(kids, 2, 3)  // 2+ Kids
replace twoplus = 0 if kids == 1          // 1 Child
label define twoplus_lbl 0 "1 Child" 1 "2+ Kids"
label values twoplus twoplus_lbl

* 4. Creating Adjusted Gross Income from Income categories by taking mid values of each category
/**NOTE: 
1. Since incomes are given as categories, we assign midpoint values as 
representative income.
2.For the top category (50k+), we use $75,000 as an arbitrary choice. Households
 with income above $50,000 are ineligible for meaningful EITC benefits, so we 
 hope this choice won't create any issues in the analysis.
3. We are not sure whether substituting midpoint values is the right way of 
doing this. [is it the rght way of doing it? need to recheck or other way of 
calculating AGI]
4. Another issue with using midpoint values is that we fail to capture those 
within income phase-in ranges since we take $10,000 as representative income for
income == 1. This might possibly affect the analysis.
**/

gen agi = 10000 if income == 1 // taking mid value of 0 to 20k
replace agi = 22500 if income == 2 // midvalue of 20-25k
replace agi = 30000 if income == 3 // midvalue of 25-35kk
replace agi = 42500 if income == 4 // midvalue of 35-50k
replace agi = 75000 if income == 5 // arbitrary choice[?]
*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
*Creating variables for EITC received by mothers                               *
*------------------------------------------------------------------------------*
/*NOTE: 
Data doesn't have variables for EITC amount received. So calculating the 
variables eitc_amount and eitc_received based on the information given in the 
paper. However, we are not sure whether the calculation method used is the 
right way of doing it.*/

* Create eitc_amount variable based on the information given below (see pg no 261 and fig 1 & 2)
gen eitc_amount = 0

// Tax year 1993-1995 (Before OBRA93 expansion)

** For 2+ Kids **
* Phase in rate = 19.5%
* Phase in range = $0 to $7,750
* Maximum EITC = $1,511
* Phase out start = $12200
* Phase out end = $23,050
* Phase out rate = $1,511/($23,050-$12,200) = 13.92%

replace eitc_amount = agi * 0.195 if post_obra == 0 & twoplus == 1 & ///
agi <= 7750 // Phase in range
replace eitc_amount = 1511 if post_obra == 0 & twoplus == 1 & ///
agi > 7750 & agi <= 12200 // max EITC
replace eitc_amount = 1511 - ((agi - 12200) * 0.1392) if post_obra == 0 & ///
twoplus == 1 & agi > 12200 & agi < 23050 // Phase out range

** For 1 child **
* Phase in rate = 18.5%
* Phase in range = $0 to $7,750
* Maximum EITC = $1,434
* Phase out start = $12,200
* Phase out end = $23,050
* Phase out rate = $1,434/($23,050-$12,200) = 13.22%

replace eitc_amount = agi * 0.185 if post_obra == 0 & twoplus == 0 & ///
agi <= 7750 // Phase in range
replace eitc_amount = 1434 if post_obra == 0 & twoplus == 0 & agi > 7750 & ///
agi <= 12200 // Max EITC
replace eitc_amount = 1434 - ((agi - 12200) * 0.132) if post_obra == 0 & ///
twoplus == 0 & agi > 12200 & agi < 23050 // Phase out range


// 1998-2001 post_obra (Post OBRA93 expansion)

** For 2+ Kids **
* Phase in rate = 40%
* Phase in range = $0 to $8,890
* Maximum EITC = $3,556
* Phase out start = $11,650
* Phase out end = $28,495
* Phase out rate = $3,556/($28,495-$11650) = 21.11%

replace eitc_amount = agi * 0.40 if post_obra == 1 & twoplus == 1 & ///
agi <= 8890 // Phase in range
replace eitc_amount = 3556 if post_obra == 1 & twoplus == 1 & ///
agi > 8890 & agi <= 11650 // Max EITC
replace eitc_amount = 3556 - ((agi - 11650) * 0.211) if post_obra == 1 & ///
twoplus == 1 & agi > 11650 & agi < 28495 // Phase out range 

** For 1 child **  
* Phase in rate = 34%
* Phase in range = $0 to $6,330
* Maximum EITC = $2,152
* Phase out start = $11,650
* Phase out end = $25,078
* Phase out rate = $2,152/($25,078-$11,650) = 16.03%

replace eitc_amount = agi * 0.34 if post_obra == 1 & twoplus == 0 & agi <= 6630
replace eitc_amount = 2152 if post_obra == 1 & twoplus == 0 & ///
agi > 6630 & agi <= 11650
replace eitc_amount = 2152 - ((agi - 11650) * 0.16) if post_obra == 1 & ///
twoplus == 0 & agi > 11650 & agi < 25078

replace eitc_amount = . if agi == .

** Create indicator variable eitc_received
gen eitc_received = .
replace eitc_received = 1 if eitc_amount > 0 
replace eitc_received = 0 if eitc_amount == 0 
replace eitc_received = . if eitc_amount == .
tab eitc_received
gen eitc_percent = eitc_received * 100 // To have results displayed in percent form

* Creating table by combining 3 panels                                         

collect clear

** PANEL A: Percent receiving the EITC
collect: table (post_obra) (colgrad twoplus), statistic(mean eitc_percent) /// 
name(panelA) nformat(%9.2f) nototal // how to use weights=finalwgt (aw or pw)
collect label levels collection panelA "Panel A. Percent receiving the EITC", modify
	
** PANEL B: Size of EITC payment
collect: table (post_obra) (colgrad twoplus), statistic(mean eitc_amount) ///
name(panelB) nformat(%9.2f) nototal // weights?
collect label levels collection panelB "Panel B. Size of EITC payment", modify

** PANEL C: Size of EITC payment among recipients only
collect: table (post_obra) (colgrad twoplus) if eitc_received == 1, ///
 statistic(mean eitc_amount) name(panelC) nformat(%9.2f) nototal // weights?
collect label levels collection panelC ///
 "Panel C. Size of EITC payment among recipients", modify

collect combine  all = panelA panelB panelC

** Combined table
collect style header, title(hide) // Removing varnames from table
collect layout (collection#post_obra) (colgrad#twoplus)

collect export "eitc_results_table.xlsx", as(xlsx) replace
restore
*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
* Table 2: Sample Characteristics, Mothers Aged 21–40, 1993–1996 BRFSS         *
*------------------------------------------------------------------------------*

preserve
keep if kids > 0 // Keep only mothers with at least one child
*------------------------------------------------------------------------------*
* Define variables for the table using local macro                             *
*------------------------------------------------------------------------------*
local vars ///
    age working  /// 
    black_nh white_nh hispanic other ///       // Race
    married  div_sep_wid never_married ///     //Marital status
    income1 income2 income5 incomemiss ///     //Income categories
    excel_vgood  bad_mental_30 bad_phys_30 mental_poor phys_poor // Health status
*------------------------------------------------------------------------------*
* Estimate means and p-values for high school or less education group          *
* Tests differences between 1 child vs. 2+ kids families                       *
*------------------------------------------------------------------------------*
estpost ttest `vars' if educ <= 2 & year < 1996, by(twoplus_kids)
est store highschool
*------------------------------------------------------------------------------*
* Estimate means and p-values for college graduates group                      *
* Tests differences between 1 child vs. 2+ kids families                       *
*------------------------------------------------------------------------------*
estpost ttest `vars' if educ == 4 & year < 1996, by(twoplus_kids)
est store college
*------------------------------------------------------------------------------*
* Table combining results for high school or less and college graduates        *
*------------------------------------------------------------------------------*
esttab highschool college using "table2.csv", ///
    replace ///
    cells("mu_1(fmt(3)) mu_2(fmt(3)) p(fmt(3))") ///
    mtitle("≤ High School Education" "College Graduates") ///
    collabels("1 Child" "2+ Kids" "p-value") ///
    nonumbers label ///
    title("Table 2: Sample Characteristics, Mothers Aged 21–40, 1993–1996 BRFSS") 

/* NOTE: 
The last column of the table shows total observations for 1 child and 2+ Kids 
families by education group. We were unable to display observation 
counts column-wise in the table. However, the number of observations can be 
verified from the estpost commands above or by running the code below:   */

count if educ <= 2 & year < 1996 & twoplus_kids == 0
count if educ <= 2 & year < 1996 & twoplus_kids == 1

count if educ == 4 & year < 1996 & twoplus_kids == 0
count if educ == 4 & year < 1996 & twoplus_kids == 1

restore
*------------------------------------------------------------------------------*
* Table 3: Difference-in-Differences OLS and Negative Binomial Estimates       *
* Mothers Aged 21–40, 1993–2001 BRFSS                                          *
*------------------------------------------------------------------------------*
preserve
keep if kids > 0
local outcomes 4
local rows = `outcomes' * 3

matrix results = J(`rows', 5, .)
matrix colnames results = "Outcome" "PreMean" "Method" "Simple_DiD" "Adj_DiD"
*------------------------------------------------------------------------------*
* Preexpansion mean of outcome for treatment group                             *
*------------------------------------------------------------------------------*

summ working if educ <= 2 & year < 1996 & twoplus_kids == 1
matrix results[1,2] = r(mean)
matrix results[2,2] = r(mean)  // This step repeates the value in se row. This is done to ensure the proper formatting of the table
matrix results[3,2] = r(mean)  // Copy to p-value row

summ excel_vgood if educ <= 2 & year < 1996 & twoplus_kids == 1
matrix results[4,2] = r(mean)
matrix results[5,2] = r(mean)
matrix results[6,2] = r(mean)

summ mental_poor if educ <= 2 & year < 1996 & twoplus_kids == 1
matrix results[7,2] = r(mean)
matrix results[8,2] = r(mean)
matrix results[9,2] = r(mean)

summ phys_poor if educ <= 2 & year < 1996 & twoplus_kids == 1
matrix results[10,2] = r(mean)
matrix results[11,2] = r(mean)
matrix results[12,2] = r(mean)

*------------------------------------------------------------------------------*
* Simple DiD results                                                           *
*------------------------------------------------------------------------------*

* Outcome 1: At work (OLS)

reg working treat post did if educ <= 2, cluster(fips)
matrix results[1,4] = _b[did]
matrix results[2,4] = _se[did]
test did = 0
matrix results[3,4] = r(p)
matrix results[1,3] = 1
matrix results[2,3] = 1  // / This step repeates the value in se row. This is done to ensure the proper formatting of the table
matrix results[3,3] = 1  // Also set for p-value row

* Outcome 2: Excellent/very good health? (OLS)
reg excel_vgood treat post did if educ <= 2, cluster(fips)
matrix results[4,4] = _b[did]
matrix results[5,4] = _se[did]
test did = 0
matrix results[6,4] = r(p)
matrix results[4,3] = 1
matrix results[5,3] = 1
matrix results[6,3] = 1

* Outcome 3: Number of bad mental health days (negative binomial for count data)
nbreg mental_poor treat post did if educ <= 2, cluster(fips)
matrix results[7,4] = _b[did]
matrix results[8,4] = _se[did]
test did = 0
matrix results[9,4] = r(p)
matrix results[7,3] = 2
matrix results[8,3] = 2
matrix results[9,3] = 2

* Outcome 4: Number of bad physical health days (negative binomial for count data)
nbreg phys_poor treat post did if educ <= 2, cluster(fips)
matrix results[10,4] = _b[did]
matrix results[11,4] = _se[did]
test did = 0
matrix results[12,4] = r(p)
matrix results[10,3] = 2
matrix results[11,3] = 2
matrix results[12,3] = 2
*------------------------------------------------------------------------------*
* Regression-Adjusted DiD results                                              *
*------------------------------------------------------------------------------*

* Create dummy variables for covariates using xi prefix
xi i.educ i.year i.kids i.race4 i.marital i.age i.fips i.month

* Outcome 1: At work (OLS with controls)
reg working _I* did if educ <= 2, cluster(fips)
matrix results[1,5] = _b[did]
matrix results[2,5] = _se[did]
test did = 0
matrix results[3,5] = r(p)

* Outcome 2: Excellent/very good health? (OLS with controls)
reg excel_vgood _I* did if educ <= 2, cluster(fips)
matrix results[4,5] = _b[did]
matrix results[5,5] = _se[did]
test did = 0
matrix results[6,5] = r(p)

* Outcome 3: Number of bad mental health days (negative binomial for count data with controls)
nbreg mental_poor _I* did if educ <= 2, cluster(fips)
matrix results[7,5] = _b[did]
matrix results[8,5] = _se[did]
test did = 0
matrix results[9,5] = r(p)

* Outcome 4: Number of bad physical health days (negative binomial for count data with controls)
nbreg phys_poor _I* did if educ <= 2, cluster(fips)
matrix results[10,5] = _b[did]
matrix results[11,5] = _se[did]
test did = 0
matrix results[12,5] = r(p)

matrix list results, format(%9.4f)
*------------------------------------------------------------------------------*
* Formatting the results to obtain clean table                                 *
*------------------------------------------------------------------------------*
clear
svmat results, names(col)

* Create an outcome ID (3 rows per outcome: coef, se, p)
gen outcome_id = ceil(_n/3)

* Create row type identifier (1=coef, 2=se, 3=p)
gen row_type = mod(_n,3)
replace row_type = 3 if row_type == 0

* Extracting premean and method (columns) before reshaping and storing them in temporary variables
gen premean_temp = .
gen method_temp = .

forvalues i = 1/4 {
    local coef_row = (`i'-1)*3 + 1  // First row of each outcome (coefficient)
    
    * obtain premean from coefficient row
    local premean_val = PreMean[`coef_row']
    replace premean_temp = `premean_val' if outcome_id == `i'
    
    * obtain method from coefficient row
    local method_val = Method[`coef_row']
    replace method_temp = `method_val' if outcome_id == `i'
}

* Reshape to wide format
gen id = outcome_id
reshape wide Simple_DiD Adj_DiD, i(id) j(row_type)

* Format as strings: "coef (se) [p]"
gen simple_did_formatted = string(Simple_DiD1, "%9.4f") + " (" + ///
                          string(Simple_DiD2, "%9.4f") + ") [" + ///
                          string(Simple_DiD3, "%9.3f") + "]"

gen adj_did_formatted = string(Adj_DiD1, "%9.4f") + " (" + ///
                       string(Adj_DiD2, "%9.4f") + ") [" + ///
                       string(Adj_DiD3, "%9.3f") + "]"

* adding outcome labels
gen outcome = ""
replace outcome = "At work" if outcome_id == 1
replace outcome = "Excellent/very good health" if outcome_id == 2
replace outcome = "Number of bad mental health days in past 30 days" if outcome_id == 3
replace outcome = "Number of bad physical health days in past 30 days" if outcome_id == 4

* Convert method_temp to string
gen Method_str = ""
replace Method_str = "OLS" if method_temp == 1
replace Method_str = "Negative binomial" if method_temp == 2
* Add check for other values
replace Method_str = "Unknown" if Method_str == "" & !missing(method_temp)

* Keep only one row per outcome
keep outcome premean_temp Method_str simple_did_formatted adj_did_formatted
duplicates drop

* Rename for clarity
rename premean_temp premean
rename Method_str Method
rename simple_did_formatted Simple_DiD
rename adj_did_formatted Adj_DiD

* Order columns
order outcome premean Method Simple_DiD Adj_DiD

* Display table
list, clean noobs

export delimited using "table3_did.csv", replace
restore

/* NOTE:
The small differences in estimate for the outcome At work can be attributed to the missing values. While negative binomial regression for the last two outcomes gives significantly different results from those in the original paper. We assume this is due to the clterations made in the data. 
*/
*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
* Table 4: Robustness Tests, Women Aged 21–40, 1993–2001 BRFSS                 *
*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
* Create matrix to store results (4 outcomes × 5 specifications)               *
*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
* 1. Regression-Adjusted DiD results                                           *
*------------------------------------------------------------------------------*
preserve

local outcomes 4
local rows = `outcomes' * 3 

matrix results = J(`rows', 7, .)  // 4 outcomes × (1 outcome name + 5 specifications)
matrix colnames results = "Outcome" "Method" "Regression_Adjusted" "State_x_Year" "twoplus_vs_NoKids" "Married_Women" "Single_Women"
keep if kids > 0
* Create dummy variables for covariates 
xi i.educ i.year i.kids i.race4 i.marital i.age i.fips i.month

* Outcome 1: At work 
reg working _I* did if educ <= 2, cluster(fips)
matrix results[1,3] =_b[did]
matrix results[2,3] =_se[did]
test did = 0
matrix results[3,3] = r(p)

matrix results[1,2] = 1
matrix results[2,2] = 1  // This steps repeats the value for se row. To ensure the formatting of the table.
matrix results[3,2] = 1  // Also set for p-value row

* Outcome 2: Excellent/very good health? 
reg excel_vgood _I* did if educ <= 2, cluster(fips)
matrix results[4,3] = _b[did]
matrix results[5,3] = _se[did]
test did = 0
matrix results[6,3] = r(p)

matrix results[4,2] = 1
matrix results[5,2] = 1
matrix results[6,2] = 1

* Outcome 3: Number of bad mental health days 
nbreg mental_poor _I* did if educ <= 2, cluster(fips)
matrix results[7,3] = _b[did]
matrix results[8,3] = _se[did]
test did = 0
matrix results[9,3] = r(p)

matrix results[7,2] = 2
matrix results[8,2] = 2
matrix results[9,2] = 2

* Outcome 4: Number of bad physical health days 
nbreg phys_poor _I* did if educ <= 2, cluster(fips)
matrix results[10,3] = _b[did]
matrix results[11,3] = _se[did]
test did = 0
matrix results[12,3] = r(p)

matrix results[10,2] = 2
matrix results[11,2] = 2
matrix results[12,2] = 2

restore
*------------------------------------------------------------------------------*
* 2. State × Year DiD results                                                  *
*------------------------------------------------------------------------------*
preserve
keep if kids > 0  // Keep only mothers with at least one child

* Create state-year interaction to capture state-specific time trends
gen statexyear = year * fips

* Create dummy variables for covariates including state-year interactions
xi i.educ i.statexyear i.kids i.race4 i.marital i.age i.month

* Outcome 1: At work with state-year interactions
reg working _I* did if educ <= 2, cluster(fips)
matrix results[1,4] = _b[did]
matrix results[2,4] = _se[did]
test did = 0
matrix results[3,4] = r(p)

* Outcome 2: Excellent/very good health with state-year interactions
reg excel_vgood _I* did if educ <= 2, cluster(fips)
matrix results[4,4] = _b[did]
matrix results[5,4] = _se[did]
test did = 0
matrix results[6,4] = r(p)

* Outcome 3: Number of bad mental health days with state-year interactions
nbreg mental_poor _I* did if educ <= 2, cluster(fips)
matrix results[7,4] = _b[did]
matrix results[8,4] = _se[did]
test did = 0
matrix results[9,4] = r(p)

* Outcome 4: Number of bad physical health days with state-year interactions
nbreg phys_poor _I* did if educ <= 2, cluster(fips)
matrix results[10,4] = _b[did]
matrix results[11,4] = _se[did]
test did = 0
matrix results[12,4] = r(p)

restore
*------------------------------------------------------------------------------*
* 3. Two children vs no children DiD results                                   *
*------------------------------------------------------------------------------*
preserve
drop if kids == 1  // Keep only observations with either 0 or 2+ kids

* Create dummy variables for covariates
xi i.educ i.year i.kids i.race4 i.marital i.age i.month i.fips

* Outcome 1: At work for 2+ kids vs. no kids
reg working _I* did if educ <= 2, cluster(fips)
matrix results[1,5] = _b[did]
matrix results[2,5] = _se[did]
test did = 0
matrix results[3,5] = r(p)

* Outcome 2: Excellent/very good health for 2+ kids vs. no kids
reg excel_vgood _I* did if educ <= 2, cluster(fips)
matrix results[4,5] = _b[did]
matrix results[5,5] = _se[did]
test did = 0
matrix results[6,5] = r(p)

* Outcome 3: Number of bad mental health days for 2+ kids vs. no kids
nbreg mental_poor _I* did if educ <= 2, cluster(fips)
matrix results[7,5] = _b[did]
matrix results[8,5] = _se[did]
test did = 0
matrix results[9,5] = r(p)

* Outcome 4: Number of bad physical health days for 2+ kids vs. no kids
nbreg phys_poor _I* did if educ <= 2, cluster(fips)
matrix results[10,5] = _b[did]
matrix results[11,5] = _se[did]
test did = 0
matrix results[12,5] = r(p)

restore
*------------------------------------------------------------------------------*
* 4. Married Women DiD results                                                 *
*------------------------------------------------------------------------------*
preserve
keep if kids > 0  // Keep only mothers with at least one child

* Create dummy variables for covariates
xi i.educ i.year i.kids i.race4 i.marital i.age i.month i.fips

* Outcome 1: At Work for married women
reg working _I* did if educ <= 2 & marital == 1, cluster(fips)
matrix results[1,6] = _b[did]
matrix results[2,6] = _se[did]
test did = 0
matrix results[3,6] = r(p)

* Outcome 2: Excellent/very good health for married women
reg excel_vgood _I* did if educ <= 2 & marital == 1, cluster(fips)
matrix results[4,6] = _b[did]
matrix results[5,6] = _se[did]
test did = 0
matrix results[6,6] = r(p)

* Outcome 3: Number of bad mental health days for married women
nbreg mental_poor _I* did if educ <= 2 & marital == 1, cluster(fips)
matrix results[7,6] = _b[did]
matrix results[8,6] = _se[did]
test did = 0
matrix results[9,6] = r(p)

* Outcome 4: Number of bad physical health days for married women
nbreg phys_poor _I* did if educ <= 2 & marital == 1, cluster(fips)
matrix results[10,6] = _b[did]
matrix results[11,6] = _se[did]
test did = 0
matrix results[12,6] = r(p)

restore

*------------------------------------------------------------------------------*
* 5. Single Women DiD results                                                  *
*------------------------------------------------------------------------------*
preserve

keep if kids > 0  // Keep only mothers with at least one child

* Create dummy variables for covariates
xi i.educ i.year i.kids i.race4 i.marital i.age i.fips i.month

* Outcome 1: At work for single women
reg working _I* did if educ <= 2 & marital > 1, cluster(fips)
matrix results[1,7] = _b[did]
matrix results[2,7] = _se[did]
test did = 0
matrix results[3,7] = r(p)

* Outcome 2: Excellent/very good health for single women
reg excel_vgood _I* did if educ <= 2 & marital > 1, cluster(fips)
matrix results[4,7] = _b[did]
matrix results[5,7] = _se[did]
test did = 0
matrix results[6,7] = r(p)

* Outcome 3: Number of bad mental health days for single women
nbreg mental_poor _I* did if educ <= 2 & marital > 1, cluster(fips)
matrix results[7,7] = _b[did]
matrix results[8,7] = _se[did]
test did = 0
matrix results[9,7] = r(p)

* Outcome 4: Number of bad physical health days for single women
nbreg phys_poor _I* did if educ <= 2 & marital > 1, cluster(fips)
matrix results[10,7] = _b[did]
matrix results[11,7] = _se[did]
test did = 0
matrix results[12,7] = r(p)

restore

matrix list results, format(%9.4f)
*------------------------------------------------------------------------------*
* Export matrix to CSV                                                         *
*------------------------------------------------------------------------------*
clear
svmat results, names(col)

* Create an outcome ID (3 rows per outcome: coef, se, p)
gen outcome_id = ceil(_n/3)

* Create row type identifier (1=coef, 2=se, 3=p)
gen row_type = mod(_n,3)
replace row_type = 3 if row_type == 0

* Extracting method(column) before reshaping and storing them in temporary variables
gen method_temp = .

forvalues i = 1/4 {
    local coef_row = (`i'-1)*3 + 1  // First row of each outcome (coefficient)
    
* Obtain method from coefficient row
    local method_val = Method[`coef_row']
    replace method_temp = `method_val' if outcome_id == `i'
}

* Reshape to wide format
gen id = outcome_id
reshape wide Regression_Adjusted State_x_Year twoplus_vs_NoKids Married_Women Single_Women, i(id) j(row_type)

* Format as strings: "coef (se) [p]"
gen Regression_Adjusted_formatted = string(Regression_Adjusted1, "%9.4f") + " (" + ///
                          string(Regression_Adjusted2, "%9.4f") + ") [" + ///
                          string(Regression_Adjusted3, "%9.3f") + "]"

gen State_x_Year_formatted = string(State_x_Year1, "%9.4f") + " (" + ///
                       string(State_x_Year2, "%9.4f") + ") [" + ///
                       string(State_x_Year3, "%9.3f") + "]"
					   
gen twoplus_vs_NoKids_formatted = string(twoplus_vs_NoKids1, "%9.4f") + " (" + ///
                          string(twoplus_vs_NoKids2, "%9.4f") + ") [" + ///
                          string(twoplus_vs_NoKids3, "%9.3f") + "]"

gen Married_Women_formatted = string(Married_Women1, "%9.4f") + " (" + ///
                       string(Married_Women2, "%9.4f") + ") [" + ///
                       string(Married_Women3, "%9.3f") + "]"

gen Single_Women_formatted = string(Single_Women1, "%9.4f") + " (" + ///
                       string(Single_Women2, "%9.4f") + ") [" + ///
                       string(Single_Women3, "%9.3f") + "]"

* Add outcome labels
gen outcome = ""
replace outcome = "At work" if outcome_id == 1
replace outcome = "Excellent/very good health" if outcome_id == 2
replace outcome = "Number of bad mental health days in past 30 days" if outcome_id == 3
replace outcome = "Number of bad physical health days in past 30 days" if outcome_id == 4

* Convert method_temp to string
gen Method_str = ""
replace Method_str = "OLS" if method_temp == 1
replace Method_str = "Negative binomial" if method_temp == 2

* Keep only one row per outcome and remove duplications)
keep outcome Method_str Regression_Adjusted_formatted State_x_Year_formatted twoplus_vs_NoKids_formatted Married_Women_formatted Single_Women_formatted
duplicates drop

* Rename for clarity
rename Method_str Method
rename Regression_Adjusted_formatted Regression_Adjusted
rename State_x_Year_formatted State_x_Year
rename twoplus_vs_NoKids_formatted twoplus_vs_NoKids
rename Married_Women_formatted Married_Women
rename Single_Women_formatted Single_Women

* Order columns
order outcome Method Regression_Adjusted State_x_Year twoplus_vs_NoKids Married_Women Single_Women

list, clean noobs

export delimited using "table4_robustness.csv", replace

/* NOTE:
As noted above the difference in results for the outcome at work is due to the missing values. Whereas estimates for other two health outcomes signifcantly differ from those in the original paper, for the reasons we are not aware of. 
*/
*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
* Figure 1. EITC Payments for Families, 1993 and 1996.                         *
*------------------------------------------------------------------------------*

clear

* Creating data based on the information provided in the paper.

input year agi eitc // Data set with 3 variables "year" "average gross income" and "EITC amount"
1     0       0 // Data for 2+ Kids 1993
1  7750    1511
1 12200    1511
1 23050       0
2     0       0 // Data for 2+Kids 1996
2  8890    3556
2 11650    3556
2 28495       0
3     0       0 // Data for one child 1993
3  7750    1434
3 12200    1434
3 23050       0
4     0       0 // Data for one child 1996
4  6330    2152
4 11650    2152
4 25078       0

end

bysort year: gen point = _n
reshape wide agi eitc, i(point) j(year)

* Create variables for vertical lines for Graph 1
gen x_v1 = 7750
gen y_v1 = .
replace y_v1 = 0 in 1
replace y_v1 = 1511 in 2

gen x_v2 = 12200
gen y_v2 = .
replace y_v2 = 0 in 1
replace y_v2 = 1511 in 2

gen x_v3 = 8890
gen y_v3 = .
replace y_v3 = 0 in 1
replace y_v3 = 3556 in 2

gen x_v4 = 11650
gen y_v4 = .
replace y_v4 = 0 in 1
replace y_v4 = 3556 in 2

* Create variables for vertical lines for Graph 2
gen x_v5 = 7750
gen y_v5 = .
replace y_v5 = 0 in 1
replace y_v5 = 1434 in 2

gen x_v6 = 12200
gen y_v6 = .
replace y_v6 = 0 in 1
replace y_v6 = 1434 in 2

gen x_v7 = 6330
gen y_v7 = .
replace y_v7 = 0 in 1
replace y_v7 = 2152 in 2

gen x_v8 = 11650
gen y_v8 = .
replace y_v8 = 0 in 1
replace y_v8 = 2152 in 2

* Single graph by combining the graphs of two+ kids and one child families
twoway ///
    (line eitc2 agi2, lcolor(blue) lwidth(medthick) legend(label(1 "Two Children 1996"))) ///
    (line eitc1 agi1, lcolor(blue) lpattern(dash) lwidth(medthick) legend(label(2 "Two Children 1993"))) ///
    (line y_v1 x_v1, lcolor(black) lpattern(shortdash) lwidth(thin)) ///
    (line y_v2 x_v2, lcolor(black) lpattern(shortdash) lwidth(thin)) ///
    (line y_v3 x_v3, lcolor(black) lpattern(shortdash) lwidth(thin)) ///
    (line y_v4 x_v4, lcolor(black) lpattern(shortdash) lwidth(thin)) ///
    (function y=1511, range(0 7750) lpattern(shortdash) lcolor(black) lwidth(thin)) ///
    (function y=3556, range(0 8890) lpattern(shortdash) lcolor(black) lwidth(thin)) ///
	(line eitc4 agi4, lcolor(red) lwidth(medthick) legend(label(9 "One Child 1996"))) ///
    (line eitc3 agi3, lcolor(red) lpattern(dash) lwidth(medthick) legend(label(10 "One Child 1993"))) ///
    (line y_v5 x_v5, lcolor(black) lpattern(shortdash) lwidth(thin)) ///
    (line y_v6 x_v6, lcolor(black) lpattern(shortdash) lwidth(thin)) ///
    (line y_v7 x_v7, lcolor(black) lpattern(shortdash) lwidth(thin)) ///
    (line y_v8 x_v8, lcolor(black) lpattern(shortdash) lwidth(thin)) ///
    (function y=1434, range(0 7750) lpattern(shortdash) lcolor(black) lwidth(thin)) ///
    (function y=2152, range(0 6330) lpattern(shortdash) lcolor(black) lwidth(thin)) ///
    , ///
   xlabel(6330 "$6,330" 7750 "$7,750" 8890 "$8,890" 11650 "$11,650" 12200 "$12,200" ///
   23050 "$23,050" 25078 "$25,078" 28495 "$28,495", angle(45) labsize(small) ///
   labgap(*2) nogrid) ///
    ylabel(1434 "$1,434" 1511 "$1,511" 2152 "$2,152" 3556 "$3,556", ///
	labsize(small) labgap(*2) nogrid) ///
    xtitle("AGI", size(medsmall)) ///
    ytitle("EITC", size(medsmall)) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    legend(order(1 2 9 10) label(1 "Two Children 1996") ///
	label(2 "Two Children 1993") label(9 "One Child 1996") ///
	label(10 "One Child 1993") size(vsmall) rows(2) position(2) ring(0))

graph save fig1.jpeg, replace
*------------------------------------------------------------------------------*

********************************************************************************
*                           End of Do file                                     *
********************************************************************************