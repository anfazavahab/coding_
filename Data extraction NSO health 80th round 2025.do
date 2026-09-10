/*===========================================================================
  NSO 80th Round — Schedule 25.0
  Household Social Consumption: Health, January -December 2025
  Do file no. 1: Extracting raw data and renaming variables
  Author: Anfaz
  Refer to "https://microdata.gov.in/NADA/index.php/catalog/290/data-dictionary"
  for official documentation
  * Help of AI tools is used in trouble shooting and code corrections
===========================================================================*/

clear all
set more off
numlabel _all, add

global datapath "C:\Users\dell\Downloads\health insurance nsso\data"
global outpath  "C:\Users\dell\Downloads\health insurance nsso\output"
global hhkey    "fsu sss hhd"


********************************************************************************
* LEVEL-WISE DATA EXTRACTION
* The following sections import and prepare each level of Schedule 25.0.
********************************************************************************
*------------------------------------------------------------------------------*
* LEVEL 1 — Household
* -----------------------------------------------------------------------------*
clear
infix ///
    str rnd     1-2    ///
    str sch     3-5    ///
    str fsu     6-10   ///
    str samp    11-11  ///
    sec         12-12  ///
    state       13-14  ///
    str nssreg  15-17  ///
    str dist    18-19  ///
    strm        20-22  ///
    sstrm       23-24  ///
    subrnd      25-25  ///
    str sro     26-29  ///
    suno        30-31  ///
    sd          32-32  ///
    sss         33-33  ///
    str hhd     34-35  ///
    str level   36-37  ///
    svc         38-38  ///
    b1i16       39-39  ///
    infcode     40-41  ///
    b2i9        42-42  ///
    str date    43-50  ///
    time        51-53  ///
    hhsz        54-55  ///
    b5i2        56-56  ///
    b5i3        57-57  ///
    b5i4        58-58  ///
    b5i5        59-59  ///
    b5i6        60-67  ///
    b5i7        68-75  ///
    b5i8        76-83  ///
    b5i9        84-91  ///
    b5i10       92-99  ///
    b5i11      100-107 ///
    umce       108-115 ///
    mult       116-127 ///
    nst        128-135 ///
    nstj       136-140 ///
    subdvsn    141-143 ///
    caph       144-148 ///
    smah       149-150 ///
    using "$datapath/H80_LVL_01.TXT"
	
tostring sss, replace format(%01.0f) // Convert the sampling-sector identifier to a string for consistent use in the household identifier.

gen wgt  = mult/100 // sampling weight
gen mpce = umce / hhsz // Monthly  per capita consumer expenditure
egen stratum = group(state sec strm sstrm) // Define stratum

* Label relevant variables
label values sec   sector
label values state stcode
label values svc   surveycode
label values b1i16 subst_reason
label values b2i9  resp_code
label values b5i2  religion
label values b5i3  socialgroup
label values b5i5  yesno2
label variable wgt     "Sampling weight"
label variable mpce    "Monthly per capita consumer expenditure (Rs.)"
label variable stratum "Survey stratum"
sort $hhkey // sort by household identifier
save "$outpath/level1_hh.dta", replace
di "Level 1: " _N " households"

*------------------------------------------------------------------------------*
* LEVEL 2 — Personal charachteristics
*------------------------------------------------------------------------------*
clear
infix ///
    str rnd     1-2    ///
    str sch     3-5    ///
    str fsu     6-10   ///
    str samp    11-11  ///
    sec         12-12  ///
    state       13-14  ///
    str nssreg  15-17  ///
    str dist    18-19  ///
    strm        20-22  ///
    sstrm       23-24  ///
    subrnd      25-25  ///
    str sro     26-29  ///
    suno        30-31  ///
    sd          32-32  ///
    sss         33-33  ///
    str hhd     34-35  ///
    str level   36-37  ///
    b3c1        38-39  ///
    b3c3        40-40  ///
    b3c4        41-41  ///
    b3c5        42-44  ///
    b3c6        45-45  ///
    b3c7        46-47  ///
    b3c8        48-48  ///
    b3c9        49-49  ///
    b3c10       50-52  ///
    b3c11       53-53  ///
    b3c12       54-54  ///
    b3c13       55-56  ///
    b3c14       57-57  ///
    b3c15       58-58  ///
    b3c16       59-59  ///
    b3c17       60-61  ///
    mult        62-73  ///
    nst         74-81  ///
    nstj        82-86  ///
    subdvsn     87-89  ///
    caph        90-94  ///
    smah        95-96  ///
    using "$datapath/H80_LVL_02.TXT"
tostring sss, replace format(%01.0f)
* Rename all variables
rename b3c1  person_srl
rename b3c3  rel_to_head
rename b3c4  gender
rename b3c5  age
rename b3c6  marital
rename b3c7  educ
rename b3c8  vaccinated
rename b3c9  hospitalised
rename b3c10 n_hosp
rename b3c11 pregnant
rename b3c12 childbirth_pay_var
rename b3c13 comm_disease_var
rename b3c14 chronic
rename b3c15 ailment_15d
rename b3c16 ailment_yesterday
rename b3c17 insurance

* Label all renamed variables
label variable person_srl         "Person serial no."
label variable rel_to_head        "Relation to household head"
label variable gender             "Gender"
label variable age                "Age"
label variable marital            "Marital status"
label variable educ               "Highest educational level"
label variable vaccinated         "Received any vaccine"
label variable hospitalised       "Hospitalised last 365 days"
label variable n_hosp             "No. of times hospitalised"
label variable pregnant           "Whether pregnant"
label variable childbirth_pay_var "Paid major share of childbirth expenses"
label variable comm_disease_var   "Communicable disease (code)"
label variable chronic            "Suffering from chronic ailment"
label variable ailment_15d        "Ailment in last 15 days"
label variable ailment_yesterday  "Ailment day before survey"
label variable insurance          "Health insurance/financing scheme"
label values sec             sector
label values state           stcode
label values rel_to_head     relation
label values gender          gender
label values marital         marital
label values educ            educlevel
label values vaccinated      yesno2
label values hospitalised    yesno2
label values pregnant        yesno2
label values childbirth_pay_var childbirth_pay
label values comm_disease_var   comm_disease
label values chronic         yesno2
label values ailment_15d     yesno2
label values ailment_yesterday yesno2
label values insurance       instype
gen block3b = (person_srl >= 81 & person_srl <= 90) // representing guest women included for the childbirth-related module.
label variable block3b "Block 3B member (guest woman for childbirth)"
sort $hhkey person_srl
save "$outpath/level2_person.dta", replace
di "Level 2: " _N " persons"

*------------------------------------------------------------------------------*
* LEVEL 3 — Death related information
*------------------------------------------------------------------------------*

clear
infix ///
    str rnd     1-2    ///
    str sch     3-5    ///
    str fsu     6-10   ///
    str samp    11-11  ///
    sec         12-12  ///
    state       13-14  ///
    str nssreg  15-17  ///
    str dist    18-19  ///
    strm        20-22  ///
    sstrm       23-24  ///
    subrnd      25-25  ///
    str sro     26-29  ///
    suno        30-31  ///
    sd          32-32  ///
    sss         33-33  ///
    str hhd     34-35  ///
    str level   36-37  ///
    b4c1        38-39  ///
    b4c3        40-40  ///
    b4c4        41-43  ///
    b4c5        44-44  ///
    b4c6        45-45  ///
    b4c7        46-47  ///
    b4c8        48-48  ///
    b4c9        49-49  ///
    b4c10       50-50  ///
    b4c11       51-51  ///
    b4c12       52-52  ///
    mult        53-64  ///
    nst         65-72  ///
    nstj        73-77  ///
    subdvsn     78-80  ///
    caph        81-85  ///
    smah        86-87  ///
    using "$datapath/H80_LVL_03.TXT"
tostring sss, replace format(%01.0f)
* Rename all variables
rename b4c1  person_srl
rename b4c3  gender
rename b4c4  age
rename b4c5  medical_attention
rename b4c6  hospitalised
rename b4c7  n_hosp
rename b4c8  reason_nonhosp
rename b4c9  chronic
rename b4c10 ailment_15d
rename b4c11 pregnant
rename b4c12 time_of_death_var

* Label all renamed variables
label variable person_srl       "Deceased person serial no."
label variable gender           "Gender of deceased"
label variable age              "Age at death"
label variable medical_attention "Medical attention before death"
label variable hospitalised     "Hospitalised at least once last 365 days"
label variable n_hosp           "No. of times hospitalised before death"
label variable reason_nonhosp   "Reason for non-hospitalisation before death"
label variable chronic          "Suffered from chronic ailment"
label variable ailment_15d      "Suffered from other ailment last 15 days"
label variable pregnant         "Pregnant any time last 365 days"
label variable time_of_death_var "Time of death"
label values sec              sector
label values state            stcode
label values gender           gender
label values medical_attention yesno2
label values hospitalised     yesno2
label values reason_nonhosp   nonhosp_reason
label values chronic          yesno2
label values ailment_15d      yesno2
label values pregnant         yesno2
label values time_of_death_var time_of_death
sort $hhkey person_srl
save "$outpath/level3_death.dta", replace
di "Level 3: " _N " deaths"

*------------------------------------------------------------------------------*
* LEVEL 4 — Inpatient hospitalisation
*------------------------------------------------------------------------------*

clear
infix ///
    str rnd     1-2    ///
    str sch     3-5    ///
    str fsu     6-10   ///
    str samp    11-11  ///
    sec         12-12  ///
    state       13-14  ///
    str nssreg  15-17  ///
    str dist    18-19  ///
    strm        20-22  ///
    sstrm       23-24  ///
    subrnd      25-25  ///
    str sro     26-29  ///
    suno        30-31  ///
    sd          32-32  ///
    sss         33-33  ///
    str hhd     34-35  ///
    str level   36-37  ///
    b6i1        38-39  ///
    b6i2        40-41  ///
    b6i3        42-44  ///
    b6i4        45-47  ///
    b6i5        48-49  ///
    b6i6        50-50  ///
    b6i7        51-51  ///
    b6i8        52-52  ///
    b6i9        53-53  ///
    b6i10       54-54  ///
    b6i11       55-55  ///
    b6i12       56-58  ///
    b6i13       59-59  ///
    b6i14       60-60  ///
    b6i15       61-61  ///
    b6i16       62-62  ///
    b6i17       63-63  ///
    b6i18       64-64  ///
    b6i19       65-65  ///
    b6i20       66-68  ///
    b6i21       69-69  ///
    b6i22       70-70  ///
    b6i23       71-71  ///
    b6i24       72-74  ///
    b7i5        75-75  ///
    b7i6        76-83  ///
    b7i7        84-91  ///
    b7i8        92-99  ///
    b7i9       100-107 ///
    b7i10      108-115 ///
    b7i11      116-123 ///
    b7i12      124-131 ///
    b7i13      132-139 ///
    b7i14      140-147 ///
    b7i15      148-155 ///
    b7i16      156-163 ///
    b7i17      164-164 ///
    b7i18      165-165 ///
    b7i19      166-167 ///
    b7i20      168-175 ///
    mult       176-187 ///
    nst        188-195 ///
    nstj       196-200 ///
    subdvsn    201-203 ///
    caph       204-208 ///
    smah       209-210 ///
    using "$datapath/H80_LVL_04.TXT"
tostring sss, replace format(%01.0f)

* Rename all variables
rename b6i1  hosp_srl
rename b6i2  person_srl
rename b6i3  age_hosp
rename b6i4  age_days_hosp
rename b6i5  ailment_code
rename b6i6  treat_type
rename b6i7  facility_type
rename b6i8  reason_no_govt
rename b6i9  ward_type
rename b6i10 when_admitted
rename b6i11 when_discharged
rename b6i12 dur_stay
rename b6i13 surgery
rename b6i14 medicine
rename b6i15 xray_scan
rename b6i16 other_diag
rename b6i17 treat_before
rename b6i18 treat_type_before
rename b6i19 care_level_before
rename b6i20 dur_before
rename b6i21 treat_after
rename b6i22 treat_type_after
rename b6i23 care_level_after
rename b6i24 dur_after
rename b7i5  free_svc
rename b7i6  cost_package
rename b7i7  cost_doctor
rename b7i8  cost_medicine
rename b7i9  cost_diag
rename b7i10 cost_bed
rename b7i11 cost_other_med
rename b7i12 cost_total_med
rename b7i13 cost_transport
rename b7i14 cost_other_nonmed
rename b7i15 cost_total
rename b7i16 reimbursed
rename b7i17 finance_source
rename b7i18 place_hosp
rename b7i19 state_treatment
rename b7i20 income_loss

* Derived variables for later analysis
gen oope         = cost_total_med - reimbursed // Out of pocket expenditure per hospitalisation
gen total_exp    = cost_total // total reported expensture for hospitalisation 
gen public_hosp  = (facility_type == 1) // Availed treatment in public hospital
gen charitable   = (facility_type == 2) // Availed treatment in charitable/trust/NGO hospital
gen private_hosp = (facility_type == 3) // Availed treatment in private hospital

gen insured_case = (reimbursed > 0 & reimbursed != .) // Hospitalisations with positive insurance reimbursement

gen childbirth   = inrange(ailment_code, 87, 89) // Treatment for childbirth relted hospitalisations

* Disease category
gen disease_cat = .
replace disease_cat = 1  if inrange(ailment_code, 1, 12)
replace disease_cat = 2  if ailment_code == 13
replace disease_cat = 3  if inrange(ailment_code, 14, 16)
replace disease_cat = 4  if inrange(ailment_code, 17, 20)
replace disease_cat = 5  if inrange(ailment_code, 21, 27)
replace disease_cat = 6  if inrange(ailment_code, 28, 32)
replace disease_cat = 7  if inrange(ailment_code, 33, 34)
replace disease_cat = 8  if inrange(ailment_code, 35, 36)
replace disease_cat = 9  if inrange(ailment_code, 37, 39)
replace disease_cat = 10 if inrange(ailment_code, 40, 43)
replace disease_cat = 11 if ailment_code == 44
replace disease_cat = 12 if inrange(ailment_code, 45, 46)
replace disease_cat = 13 if inrange(ailment_code, 47, 49)
replace disease_cat = 14 if inrange(ailment_code, 50, 52)
replace disease_cat = 15 if inrange(ailment_code, 53, 59)
replace disease_cat = 16 if ailment_code == 60
replace disease_cat = 17 if inrange(ailment_code, 61, 62)
replace disease_cat = 18 if inrange(ailment_code, 87, 89)

* Episode type
gen episode_type = 1 if person_srl <= 80
replace episode_type = 2 if inrange(person_srl, 81, 90)
replace episode_type = 3 if person_srl >= 91

* Labels
label variable hosp_srl          "Hospitalisation episode serial no."
label variable person_srl        "Person serial no."
label variable age_hosp          "Age at hospitalisation (years)"
label variable age_days_hosp     "Age in days (if <1 year)"
label variable ailment_code      "Nature of ailment (code)"
label variable treat_type        "Nature of treatment"
label variable facility_type     "Type of medical institution"
label variable reason_no_govt    "Reason for not using govt./public hospital"
label variable ward_type         "Type of ward"
label variable when_admitted     "When admitted"
label variable when_discharged   "When discharged"
label variable dur_stay          "Duration of hospital stay (days)"
label variable surgery           "Surgery"
label variable medicine          "Medicine"
label variable xray_scan         "X-ray/ECG/EEG/Scan"
label variable other_diag        "Other diagnostic tests"
label variable treat_before      "Treated on advice before hospitalisation"
label variable treat_type_before "Nature of treatment before hospitalisation"
label variable care_level_before "Level of care before hospitalisation"
label variable dur_before        "Duration before hospitalisation (days)"
label variable treat_after       "Treatment continued after discharge"
label variable treat_type_after  "Nature of treatment after discharge"
label variable care_level_after  "Level of care after discharge"
label variable dur_after         "Duration after discharge (days)"
label variable free_svc          "Any medical service free"
label variable cost_package      "Package component cost (Rs.)"
label variable cost_doctor       "Doctor/surgeon fee (Rs.)"
label variable cost_medicine     "Medicine cost (Rs.)"
label variable cost_diag         "Diagnostic tests cost (Rs.)"
label variable cost_bed          "Bed charges (Rs.)"
label variable cost_other_med    "Other medical expenses (Rs.)"
label variable cost_total_med    "Total medical expenditure (Rs.)"
label variable cost_transport    "Transport cost (Rs.)"
label variable cost_other_nonmed "Other non-medical expenses (Rs.)"
label variable cost_total        "Total expenditure on episode (Rs.)"
label variable reimbursed        "Amount reimbursed by insurance/employer (Rs.)"
label variable finance_source    "Major source of finance"
label variable place_hosp        "Place of hospitalisation"
label variable state_treatment   "State code for place of treatment"
label variable income_loss       "Loss of household income (Rs.)"
label variable oope              "OOPE (Rs.)"
label variable total_exp         "Total expenditure incl. transport (Rs.)"
label variable public_hosp       "Govt./public hospital"
label variable charitable        "Charitable/Trust/NGO hospital "
label variable private_hosp      "Private hospital"
label variable insured_case      "Insurance reimbursement claimed"
label variable childbirth        "Childbirth episode"
label variable disease_cat       "Broad disease category"
label variable episode_type      "Source block of hospitalised person"
label values sec              sector
label values state            stcode
label values treat_type       nature_treat
label values facility_type    insttype
label values reason_no_govt   nogovt_reason
label values ward_type        wardtype
label values when_admitted    when_adm
label values when_discharged  when_disc
label values surgery          services_recd
label values medicine         services_recd
label values xray_scan        services_recd
label values other_diag       services_recd
label values treat_before     yesno2
label values treat_type_before nature_treat
label values care_level_before levelcare
label values treat_after      yesno2
label values treat_type_after  nature_treat
label values care_level_after  levelcare
label values free_svc         free_service
label values finance_source   financesorc
label values place_hosp       placehosp
label values state_treatment  stcode
label values disease_cat      disease_cat
label values episode_type     episode_type
sort $hhkey person_srl hosp_srl
save "$outpath/level4_hospitalisation.dta", replace
di "Level 4: " _N " hospitalisation episodes"

*------------------------------------------------------------------------------*
* LEVEL 5 — Outpatient hospitalisation
*------------------------------------------------------------------------------*

clear
infix ///
    str rnd     1-2    ///
    str sch     3-5    ///
    str fsu     6-10   ///
    str samp    11-11  ///
    sec         12-12  ///
    state       13-14  ///
    str nssreg  15-17  ///
    str dist    18-19  ///
    strm        20-22  ///
    sstrm       23-24  ///
    subrnd      25-25  ///
    str sro     26-29  ///
    suno        30-31  ///
    sd          32-32  ///
    sss         33-33  ///
    str hhd     34-35  ///
    str level   36-37  ///
    b8i1        38-39  ///
    b8i2        40-41  ///
    b8i3        42-44  ///
    b8i4        45-47  ///
    b8i5        48-49  ///
    b8i6        50-50  ///
    b8i7        51-51  ///
    b8i8        52-58  ///
    b8i9        59-59  ///
    b8i10       60-60  ///
    b8i11       61-61  ///
    b8i12       62-62  ///
    b8i13       63-63  ///
    b8i14       64-64  ///
    b8i15       65-65  ///
    b9i5        66-66  ///
    b9i6        67-67  ///
    b9i7        68-68  ///
    b9i8        69-69  ///
    b9i9        70-70  ///
    b9i10       71-71  ///
    b9i11       72-79  ///
    b9i12       80-87  ///
    b9i13       88-95  ///
    b9i14       96-103 ///
    b9i15      104-111 ///
    b9i16      112-119 ///
    b9i17      120-127 ///
    b9i18      128-135 ///
    b9i19      136-143 ///
    b9i20      144-151 ///
    b9i21      152-152 ///
    b9i22      153-153 ///
    b9i23      154-155 ///
    b9i24      156-163 ///
    mult       164-175 ///
    nst        176-183 ///
    nstj       184-188 ///
    subdvsn    189-191 ///
    caph       192-196 ///
    smah       197-198 ///
    using "$datapath/H80_LVL_05.TXT"
tostring sss, replace format(%01.0f)
gen oope_op = b9i16 - b9i20 // OOPE for outpatient treatment per hospitalisation episode

label variable oope_op "Outpatient OOPE (Rs.)"
label values sec   sector
label values state stcode
sort $hhkey b8i1
save "$outpath/level5_outpatient.dta", replace
di "Level 5: " _N " outpatient spells"

*------------------------------------------------------------------------------*
* LEVEL 6 — Vaccination
*------------------------------------------------------------------------------*

clear
infix ///
    str rnd     1-2    ///
    str sch     3-5    ///
    str fsu     6-10   ///
    str samp    11-11  ///
    sec         12-12  ///
    state       13-14  ///
    str nssreg  15-17  ///
    str dist    18-19  ///
    strm        20-22  ///
    sstrm       23-24  ///
    subrnd      25-25  ///
    str sro     26-29  ///
    suno        30-31  ///
    sd          32-32  ///
    sss         33-33  ///
    str hhd     34-35  ///
    str level   36-37  ///
    b10i1       38-39  ///
    b10i2       40-41  ///
    b10i3       42-44  ///
    b10i4       45-46  ///
    b10i5       47-47  ///
    b10i6       48-48  ///
    b10i7       49-56  ///
    mult        57-68  ///
    nst         69-76  ///
    nstj        77-81  ///
    subdvsn     82-84  ///
    caph        85-89  ///
    smah        90-91  ///
    using "$datapath/H80_LVL_06.TXT"
tostring sss, replace format(%01.0f)
label values sec   sector
label values b10i5 vaccsource
label values b10i6 yesno2
sort $hhkey b10i1
save "$outpath/level6_vaccination.dta", replace
di "Level 6: " _N " vaccination records"

*------------------------------------------------------------------------------*
* LEVEL 7 — Maternity
*------------------------------------------------------------------------------*

clear
infix ///
    str rnd     1-2    ///
    str sch     3-5    ///
    str fsu     6-10   ///
    str samp    11-11  ///
    sec         12-12  ///
    state       13-14  ///
    str nssreg  15-17  ///
    str dist    18-19  ///
    strm        20-22  ///
    sstrm       23-24  ///
    subrnd      25-25  ///
    str sro     26-29  ///
    suno        30-31  ///
    sd          32-32  ///
    sss         33-33  ///
    str hhd     34-35  ///
    str level   36-37  ///
    b11c1       38-39  ///
    b11c2       40-42  ///
    b11c3       43-43  ///
    b11c4       44-44  ///
    b11c5       45-45  ///
    b11c6       46-53  ///
    b11c7       54-54  ///
    b11c8       55-55  ///
    b11c9       56-56  ///
    b11c10      57-64  ///
    b11c11      65-65  ///
    b11c12      66-66  ///
    b11c13      67-74  ///
    mult        75-86  ///
    nst         87-94  ///
    nstj        95-99  ///
    subdvsn    100-102 ///
    caph       103-107 ///
    smah       108-109 ///
    using "$datapath/H80_LVL_07.TXT"
tostring sss, replace format(%01.0f)
label values sec   sector
label values state stcode
sort $hhkey b11c1
save "$outpath/level7_maternity.dta", replace
di "Level 7: " _N " maternity records"


********************************************************************************
*                           END OF DO FILE                                     *
********************************************************************************
