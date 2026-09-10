/*===========================================================================
  NSO 80th Round — Schedule 25.0
  Household Social Consumption: Health, January -December 2025
  Do file no. 3: Value Label Definitions
  Author: Anfaz
  Refer to "https://microdata.gov.in/NADA/index.php/catalog/290/data-dictionary"
  for official documentation
  *Help of AI tools is used in trouble shooting and code corrections
===========================================================================*/

/*===========================================================================
  labels.do
  Run this at the start of any do-file to define all value labels
===========================================================================*/

********************************************************************************
* VALUE LABEL DEFINITIONS
* Defines categorical codes used across Levels 1 to 7 of Schedule 25.0.
********************************************************************************

*------------------------------------------------------------------------------*
* HOUSEHOLD & DEMOGRAPHIC LABELS
*------------------------------------------------------------------------------*
label define sector       1 "Rural" 2 "Urban", replace
label define surveycode   1 "Original" 2 "Substitute" 3 "Casualty", replace
label define subst_reason 1 "Informant busy" 2 "Members away" ///
                          3 "Non-cooperative" 9 "Others", replace
label define resp_code    1 "Co-operative and capable" ///
                          2 "Co-operative but not capable" ///
                          3 "Informant busy" 4 "Reluctant" 9 "Others", replace

label define relation ///
    1 "Self (head)"                               ///
    2 "Spouse of head"                            ///
    3 "Married child"                             ///
    4 "Spouse of married child"                   ///
    5 "Unmarried child"                           ///
    6 "Grandchild"                                ///
    7 "Father/mother/father-in-law/mother-in-law" ///
    8 "Brother/sister/in-laws/other relatives"    ///
    9 "Servant/employee/other non-relatives", replace

label define gender   1 "Male" 2 "Female" 3 "Transgender", replace

label define marital ///
    1 "Never married"                             ///
    2 "Currently married (incl. living together)" ///
    3 "Widowed"                                   ///
    4 "Divorced/separated", replace

label define educlevel ///
    01 "Not literate"                             ///
    02 "Literate with non-formal education"       ///
    03 "Below primary"                            ///
    04 "Primary"                                  ///
    05 "Upper primary/middle"                     ///
    06 "Secondary"                                ///
    07 "Higher secondary"                         ///
    08 "Diploma/certificate (up to secondary)"    ///
    10 "Diploma/certificate (higher secondary)"   ///
    11 "Diploma/certificate (graduation & above)" ///
    12 "Graduate"                                 ///
    13 "Postgraduate and above", replace

label define religion ///
    1 "Hinduism" 2 "Islam"  3 "Christianity" 4 "Sikhism" ///
    5 "Jainism"  6 "Buddhism" 7 "Zoroastrianism" 9 "Others", replace

label define socialgroup ///
    1 "ST"       ///
    2 "SC"       ///
    3 "OBC"      ///
    9 "Others", replace

label define stcode ///
     1 "Jammu & Kashmir"             2 "Himachal Pradesh"   3 "Punjab"      ///
     4 "Chandigarh"                  5 "Uttarakhand"        6 "Haryana"     ///
     7 "Delhi"                       8 "Rajasthan"          9 "Uttar Pradesh" ///
    10 "Bihar"                      11 "Sikkim"             12 "Arunachal Pradesh" ///
    13 "Nagaland"                   14 "Manipur"            15 "Mizoram"    ///
    16 "Tripura"                    17 "Meghalaya"          18 "Assam"      ///
    19 "West Bengal"                20 "Jharkhand"          21 "Odisha"     ///
    22 "Chhattisgarh"               23 "Madhya Pradesh"     24 "Gujarat"    ///
    25 "Dadra & NH and Daman & Diu"                         27 "Maharashtra" ///
    28 "Andhra Pradesh"             29 "Karnataka"          30 "Goa"        ///
    31 "Lakshadweep"                32 "Kerala"             33 "Tamil Nadu" ///
    34 "Puducherry"                 35 "A & N Islands"      36 "Telangana"  ///
    37 "Ladakh", replace

*------------------------------------------------------------------------------*
* GENERAL HEALTH & INSURANCE LABELS
*------------------------------------------------------------------------------*
label define yesno2 1 "Yes" 2 "No", replace

label define comm_disease ///
    01 "Malaria"                               ///
    02 "Viral hepatitis with jaundice"         ///
    03 "Viral hepatitis without jaundice"      ///
    04 "Acute diarrhoeal diseases/dysentery"   ///
    05 "Dengue fever"                          ///
    06 "Chikungunya"                           ///
    07 "Measles"                               ///
    08 "Acute encephalitis syndrome"           ///
    09 "Others (typhoid, TB, filariasis etc.)" ///
    10 "HIV/AIDS"                              ///
    11 "STI/RTI"                               ///
    12 "Leprosy"                               ///
    19 "Not suffered", replace

label define instype ///
     1 "AB-PMJAY (Ayushman Bharat)"                              ///
     2 "State health insurance scheme"                           ///
     3 "ESIS/ESIC"                                               ///
     4 "CGHS/ECHS/other Central Govt. scheme (Railways etc.)"    ///
     5 "State govt. medical reimbursement (employees)"           ///
     6 "PSU as employer (Central and State PSUs)"                ///
     7 "Other employer health insurance/medical reimbursement"   ///
    10 "Only privately purchased commercial insurance"           ///
    19 "Not covered", replace

label define ins_cat ///
    0 "Not covered"                           ///
    1 "PMJAY/SHIP"                            ///
    2 "Employer scheme"                       ///
    3 "Private ins", replace

label define ins_cat2 ///
    0 "Not covered"                           ///
    1 "PMJAY"                                 ///
    2 "SHIPs"                                 ///
    3 "Employer scheme"                       ///
    4 "Private Ins", replace

*------------------------------------------------------------------------------*
* MORTALITY LABELS (LEVEL 3)
*------------------------------------------------------------------------------*
label define nonhosp_reason ///
    1 "Hospital care not considered satisfactory" ///
    2 "Doctor/medical attendant not available"    ///
    3 "Ailment not considered serious enough"     ///
    4 "Financial constraints"                     ///
    5 "Transportation problem"                    ///
    6 "Patient did not want to be hospitalised"   ///
    7 "Patient died before taking to hospital"    ///
    9 "Others", replace

label define time_of_death ///
    1 "During pregnancy"                    ///
    2 "During delivery"                     ///
    3 "During abortion"                     ///
    4 "Within 6 weeks of delivery/abortion" ///
    9 "Deaths due to other causes", replace

*------------------------------------------------------------------------------*
* INPATIENT & OUTPATIENT CARE LABELS (LEVELS 4 & 5)
*------------------------------------------------------------------------------*
label define nature_treat ///
    1 "Allopathy"                                                   ///
    2 "Ayurveda/Yoga/Naturopathy/Unani/Siddha/Sowa-Rigpa/Homoeopathy" ///
    3 "Both allopathy and AYUSH"                                    ///
    9 "Other", replace

label define nature_treat_op ///
    1 "Allopathy"                                                   ///
    2 "Ayurveda/Yoga/Naturopathy/Unani/Siddha/Sowa-Rigpa/Homoeopathy" ///
    3 "Both allopathy and AYUSH"                                    ///
    9 "Other", replace

label define insttype ///
    1 "Govt./public hospital (incl. PHC/CHC/AAMs etc.)" ///
    2 "Charitable/Trust/NGO run hospital"               ///
    3 "Private hospital", replace

label define nogovt_reason ///
    1 "Required specific services not available"                    ///
    2 "Available but quality not satisfactory/doctor not available" ///
    3 "Quality satisfactory but facility too far"                   ///
    4 "Quality satisfactory but involves long waiting"              ///
    5 "Financial constraint"                                        ///
    6 "Preference for a trusted doctor/hospital"                    ///
    9 "Others", replace

label define wardtype   1 "Free" 2 "Paying general" 3 "Paying special", replace

label define when_adm   1 "During last 15 days" 2 "16-365 days ago" ///
                        3 "More than 365 days ago", replace

label define when_disc  1 "Not yet discharged" 2 "During last 15 days" ///
                        3 "16-365 days ago", replace

label define services_recd ///
    1 "Not received" 2 "Free" 3 "Partly free" 4 "On payment", replace

label define levelcare ///
    1 "Govt./public hospital (incl. PHC/CHC/AAMs etc.)" ///
    2 "Charitable/Trust/NGO run hospital"               ///
    3 "Private hospital"                                ///
    4 "Private doctor/clinic"                           ///
    5 "Informal health care provider", replace

label define free_service ///
    1 "Yes — govt./public"                          ///
    2 "Yes — private (incl. charitable/NGO/trust)" ///
    3 "Yes — both"                                  ///
    4 "No", replace

label define financesorc ///
    1 "Household income/savings"             ///
    2 "Borrowings"                           ///
    3 "Sale of physical assets"              ///
    4 "Contributions from friends/relatives" ///
    9 "Other sources", replace

label define placehosp ///
    1 "Same district — rural"                    ///
    2 "Same district — urban"                    ///
    3 "Within state, different district — rural" ///
    4 "Within state, different district — urban" ///
    5 "Other state", replace

label define ailment_status ///
    1 "Started >15 days ago, continuing"   ///
    2 "Started >15 days ago, ended"        ///
    3 "Started within 15 days, continuing" ///
    4 "Started within 15 days, ended", replace

label define no_advice_reason ///
    1 "No medical facility in neighbourhood" ///
    2 "Facility too expensive"               ///
    3 "Cannot afford to wait"                ///
    4 "Ailment not serious enough"           ///
    5 "Familial/religious belief"            ///
    9 "Others", replace

label define whom_consulted ///
    1 "Self/household member/friend" ///
    2 "Medicine shop"                ///
    9 "Others", replace

*------------------------------------------------------------------------------*
* VACCINATION & MATERNITY LABELS (LEVELS 6 & 7)
*------------------------------------------------------------------------------*
label define vaccsource ///
    1 "Govt./public hospital (incl. PHC/CHC/AAMs etc.)" ///
    2 "Charitable/Trust/NGO run hospital"               ///
    3 "Private doctor/clinic"                           ///
    4 "Private hospital", replace

label define childbirth_pay 1 "Yes" 2 "No" 3 "Pregnancy continuing", replace

label define anc_source ///
    1 "Govt./public hospital (incl. PHC/CHC/AAMs etc.)" ///
    2 "Charitable/Trust/NGO run hospital"               ///
    3 "Private hospital"                                ///
    4 "Private doctor/clinic"                           ///
    5 "Informal health care provider"                   ///
    8 "No care received", replace

label define anc_nature 1 "Ayush" 2 "Non-Ayush" 3 "Both", replace

label define preg_outcome ///
    1 "Pregnancy continuing"      ///
    2 "Mother alive — live birth" ///
    3 "Mother alive — stillbirth" ///
    4 "Mother alive — abortion"   ///
    5 "Mother died — live birth"  ///
    6 "Mother died — stillbirth"  ///
    7 "Mother died — abortion"    ///
    9 "Others", replace

label define delivery_place ///
    1 "Govt./public hospital (incl. PHC/CHC/AAMs etc.)" ///
    2 "Charitable/Trust/NGO run hospital"               ///
    3 "Private hospital (incl. private doctor clinic)"  ///
    4 "At home", replace

label define attendedby 1 "Doctor/nurse" 2 "ANM" 3 "Dai" 9 "Others", replace

label define agegroup     1 "0-14" 2 "15-29" 3 "30-44" 4 "45-59" 5 "60+", replace

label define episode_type ///
    1 "Usual member (Block 3A)"   ///
    2 "Guest woman (Block 3B)"    ///
    3 "Deceased member (Block 4)", replace

label define disease_cat ///
     1 "Infections"               2 "Cancer"                      ///
     3 "Blood diseases"           4 "Endocrine/metabolic/diabetes" ///
     5 "Neurological/psychiatric" 6 "Eye"                         ///
     7 "Ear"                      8 "Cardiovascular/hypertension"  ///
     9 "Respiratory/asthma"      10 "Gastro-intestinal"           ///
    11 "Skin"                    12 "Musculo-skeletal"            ///
    13 "Genito-urinary"          14 "Obstetric/newborn"           ///
    15 "Injuries/external"       16 "Kidney failures"             ///
    17 "Unspecified"             18 "Childbirth", replace

di "labels.do: all value labels defined in memory"

********************************************************************************
*                               END OF DO FILE                                 *
********************************************************************************