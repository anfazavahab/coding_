/*===========================================================================
  NSO 80th Round — Schedule 25.0
  Household Social Consumption: Health, January -December 2025
  Do file no. 2: Data merging and preparation for analysis
  Author: Anfaz
  Refer to "https://microdata.gov.in/NADA/index.php/catalog/290/data-dictionary"
  for official documentation
  *Help of AI tools is used in troubleshooting and code corrections
===========================================================================*/

clear all
set more off
numlabel _all, add

global datapath "C:\Users\dell\Downloads\health insurance nsso\data"
global outpath  "C:\Users\dell\Downloads\health insurance nsso\output"
global hhkey    "fsu sss hhd"


********************************************************************************
* MERGING AND DATA PREPARATION
* The following sections merge individual and household datasets and derive 
* key analytical variables for living and deceased members.
********************************************************************************

*------------------------------------------------------------------------------*
* DATASET 1 — hh_person.dta (Living persons merged with HH characteristics)
*------------------------------------------------------------------------------*
use "$outpath/level2_person.dta", clear

* Merge Level 2 (Person) with Level 1 (Household) characteristics
merge m:1 $hhkey using "$outpath/level1_hh.dta", ///
    keep(1 3) nogen ///
    keepusing(hhsz b5i2 b5i3 b5i4 b5i5 b5i6          ///
              b5i7 b5i8 b5i9 b5i10 b5i11              ///
              umce mpce wgt stratum                   ///
              mult nst nstj subdvsn caph smah)

* Rename merged household-level variables
rename b5i2  religion
rename b5i3  socialgroup
rename b5i4  hhtype
rename b5i5  comm_outbreak
rename b5i6  ins_premium
rename b5i7  hh_exp_purchase
rename b5i8  hh_exp_homegrown
rename b5i9  hh_exp_inkind
rename b5i10 hh_exp_clothing
rename b5i11 hh_exp_durables
rename umce  hh_umce

* Label all newly merged household variables
label variable religion         "Religion"
label variable socialgroup      "Social group (caste)"
label variable hhtype           "Household type"
label variable comm_outbreak    "Communicable disease outbreak in community"
label variable ins_premium      "Insurance premium paid by HH (Rs.)"
label variable hh_exp_purchase  "HH monthly exp — purchases (Rs.)"
label variable hh_exp_homegrown "HH imputed value — home grown stock (Rs.)"
label variable hh_exp_inkind    "HH imputed value — wages in kind (Rs.)"
label variable hh_exp_clothing  "HH exp — clothing/footwear last 365d (Rs.)"
label variable hh_exp_durables  "HH exp — durables last 365d (Rs.)"
label variable hh_umce          "HH usual consumer expenditure (Rs.)"

* Derived variable: Insurance coverage category (4-way classification)
gen ins_cat = .
replace ins_cat = 0 if insurance == 19
replace ins_cat = 1 if inlist(insurance, 1, 2)
replace ins_cat = 2 if inlist(insurance, 3,4,5,6,7)
replace ins_cat = 3 if insurance == 10
label values ins_cat ins_cat
label variable ins_cat "Insurance category (4-way)"

* Derived variable: Insurance coverage category (5-way classification with PMJAY split)
gen ins_cat2 = .
replace ins_cat2 = 0 if insurance == 19
replace ins_cat2 = 1 if insurance == 1
replace ins_cat2 = 2 if insurance == 2
replace ins_cat2 = 3 if inlist(insurance, 3,4,5,6,7)
replace ins_cat2 = 4 if insurance == 10
label values ins_cat2 ins_cat2
label variable ins_cat2 "Insurance category (5-way)"

* Derived variable: Age group categories
gen agegroup = 1 if age >= 0  & age <  15
replace agegroup = 2 if age >= 15 & age <  30
replace agegroup = 3 if age >= 30 & age <  45
replace agegroup = 4 if age >= 45 & age <  60
replace agegroup = 5 if age >= 60 & age != .
label values agegroup agegroup
label variable agegroup "Age group"

* Derived variable: MPCE quintile (survey weight adjusted)
xtile mpce_q = mpce [pweight=wgt], nq(5)
label variable mpce_q "MPCE quintile (1=poorest 5=richest)"

* Derived indicator flags
gen hosp_bin        = (hospitalised == 1)
gen ppra            = (chronic == 1 | ailment_15d == 1) if block3b == 0
gen govt_ins_narrow = (inlist(insurance, 1, 2))
gen any_insured     = (insurance != 19 & insurance != .)

* Label derived indicator flags
label variable hosp_bin        "Hospitalised last 365 days"
label variable ppra            "PPRA: col.14 or col.15=1, Block 3A only"
label variable govt_ins_narrow "PMJAY or state scheme"
label variable any_insured     "Any insurance scheme (codes 1-7,10)"

sort $hhkey person_srl
save "$outpath/hh_person.dta", replace
di "hh_person.dta: " _N " persons"


*------------------------------------------------------------------------------*
* DATASET 2 — hospitalisation_full.dta 
* Combines Living (Level 2) + Deceased (Level 3) + Episodes (Level 4)
*------------------------------------------------------------------------------*

* Prepare living members dataset with HH characteristics
use "$outpath/hh_person.dta", clear
gen deceased = 0 // Flag living individual
save "$outpath/living.dta", replace
di "Living members: " _N

* Prepare deceased members dataset with HH characteristics
use "$outpath/level3_death.dta", clear
merge m:1 $hhkey using "$outpath/level1_hh.dta", ///
    keep(1 3) nogen ///
    keepusing(hhsz b5i2 b5i3 b5i4 b5i5 b5i6          ///
              b5i7 b5i8 b5i9 b5i10 b5i11              ///
              umce mpce wgt stratum                   ///
              mult nst nstj subdvsn caph smah)

* Rename merged household-level variables for deceased dataset
rename b5i2  religion
rename b5i3  socialgroup
rename b5i4  hhtype
rename b5i5  comm_outbreak
rename b5i6  ins_premium
rename b5i7  hh_exp_purchase
rename b5i8  hh_exp_homegrown
rename b5i9  hh_exp_inkind
rename b5i10 hh_exp_clothing
rename b5i11 hh_exp_durables
rename umce  hh_umce

gen deceased = 1 // Flag deceased individual
save "$outpath/dead.dta", replace
di "Deceased members: " _N

* Append living and deceased individual records
use "$outpath/living.dta", clear
append using "$outpath/dead.dta"
duplicates report $hhkey person_srl
di "All persons (living + deceased): " _N
save "$outpath/all_persons.dta", replace

* Merge person-level data with Level 4 hospitalisation episodes
use "$outpath/level4_hospitalisation.dta", clear
merge m:1 $hhkey person_srl using "$outpath/all_persons.dta", ///
    keep(1 3) nogen

sort $hhkey person_srl hosp_srl
save "$outpath/hospitalisation_full.dta", replace
di "hospitalisation_full.dta: " _N " episodes"
des


********************************************************************************
*                               END OF DO FILE                                 *
********************************************************************************