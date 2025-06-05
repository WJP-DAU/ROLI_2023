/*=================================================================================================================
Project:		QRQ 2023
Routine:		QRQ Data Cleaning and Harmonization 2023 (master do file)
Author(s):		Natalia Rodriguez (nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	May, 2025

Description:
Master dofile for the cleaning and analyzing the QRQ data for the Global Index. 
This do file takes the calculations from 2023 and develops new calculations for experts (outliers)

=================================================================================================================*/


clear
cls
set maxvar 120000


/*=================================================================================================================
					Pre-settings
=================================================================================================================*/


*--- Stata Version
*version 15

*--- Required packages:
* NONE

*--- Years of analysis

global year_current "2023"
global year_previous "2022"

*--- Defining paths to SharePoint & your local Git Repo copy:

*------ (a) Natalia Rodriguez:
if (inlist("`c(username)'", "nrodriguez")) {
	global path2SP "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Data Analytics\7. WJP ROLI\\ROLI_${year_current}\\1. Cleaning\QRQ"
	global path2GH "C:\Users\nrodriguez\OneDrive - World Justice Project\Natalia\GitHub\\ROLI_${year_current}\\1. Cleaning\QRQ"
	

*--- Defining path to Data and DoFiles:

*Path2data: Path to original exports from Alchemer by QRQ team. 
global path2data "${path2SP}\\1. Data"

*Path 2dos: Path to do-files (Routines). This will include the importing routine for 2023 ONLY
global path2dos23 "${path2GH}\\2. Code"

*Path 2dos: Path to do-files (Routines). THESE ARE THE SAME ROUTINES AS 2024
global path2dos  "C:\Users\nrodriguez\OneDrive - World Justice Project\Natalia\GitHub\ROLI_2024\1. Cleaning\QRQ\2. Code"


/*=================================================================================================================
					I. Cleaning the data
=================================================================================================================*/

cls
do "${path2dos23}\\Routines\\data_import_all.do"

/*=================================================================================================================
					II. Appending the data
=================================================================================================================*/

clear
use "${path2data}\\1. Original\cc_final.dta"
append using "${path2data}\\1. Original\cj_final.dta"
append using "${path2data}\\1. Original\lb_final.dta"
append using "${path2data}\\1. Original\ph_final.dta"

save "${path2data}\\1. Original\\qrq_${year_current}.dta", replace


/*=================================================================================================================
					III. Re-scaling the data
=================================================================================================================*/

do "${path2dos23}\\Routines\\normalization.do"


/*=================================================================================================================
					IV. Creating variables common in various questionnaires
=================================================================================================================*/

do "${path2dos}\\Routines\\common_q.do"

sort country question id_alex

save "${path2data}\\1. Original\\qrq_${year_current}.dta", replace


/*=================================================================================================================
					V. Merging with 2023 data and previous years
=================================================================================================================*/

/* Responded in 2022 */
clear
use "${path2data}\\1. Original\\qrq_original_${year_previous}.dta"
rename (wjp_login wjp_password) (WJP_login WJP_password)
keep WJP_login
duplicates drop
sort WJP_login
save "${path2data}\\1. Original\\qrq_${year_previous}_login.dta", replace

/* Responded longitudinal survey in 2023 */ 
clear
use "${path2data}\\1. Original\\qrq_${year_current}.dta"
keep WJP_login
duplicates drop
sort WJP_login
save "${path2data}\\1. Original\\qrq_login.dta", replace 

/* Only answered in 2022 (and not in 2023) (Login) */
clear
use "${path2data}\\1. Original\\qrq_${year_previous}_login.dta"
merge 1:1 WJP_login using "${path2data}\\1. Original\\qrq_login.dta"
keep if _merge==1
drop _merge
sort WJP_login
save "${path2data}\\1. Original\\qrq_${year_previous}_login_unique.dta", replace 

/* Only answered in 2022 (and not in 2023) (Full data) */
clear
use "${path2data}\\1. Original\\qrq_original_${year_previous}.dta"
rename (wjp_login wjp_password) (WJP_login WJP_password)
sort WJP_login
merge m:1 WJP_login using "${path2data}\\1. Original\\qrq_${year_previous}_login_unique.dta"
replace _merge=3 if id_alex=="lb_English_1_268" // LB UAE expert that answered CC in 2023 but not LB (old LB answer from 2022)
replace _merge=3 if id_alex=="lb_English_1_28_2021" // LB Gambia expert that answered CC in 2023 but not LB (old LB answer from 2021)
keep if _merge==3
drop _merge
gen aux="${year_previous}"
egen id_alex_1=concat(id_alex aux), punct(_)
replace id_alex=id_alex_1
drop id_alex_1 aux
sort WJP_login
save "${path2data}\\1. Original\\qrq_${year_previous}.dta", replace

erase "${path2data}\\1. Original\\qrq_${year_previous}_login.dta"
erase "${path2data}\\1. Original\\qrq_login.dta"
erase "${path2data}\\1. Original\\qrq_${year_previous}_login_unique.dta"

/* Merging with 2022 data and older regular data*/
clear
use "${path2data}\\1. Original\\qrq_${year_current}.dta"
append using "${path2data}\\1. Original\\qrq_${year_previous}.dta"

*Dropping questions removed in 2023
drop cc_q2a-all_q102_norm

drop total_score total_n f_1* f_2* f_3* f_4* f_6* f_7* f_8* N total_score_mean total_score_sd outlier outlier_CO

*Observations are no longer longitudinal because the database we're appending only includes people that only answered in 2022 or before
tab year longitudinal
replace longitudinal=0 if year==2022
tab year longitudinal

/* Change names of countries according to new MAP (for the 2023 and older data) */

replace country="Congo, Rep." if country=="Republic of Congo"
replace country="Korea, Rep." if country=="Republic of Korea"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="St. Kitts and Nevis" if country=="Saint Kitts and Nevis"		
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Cote d'Ivoire" if country=="Ivory Coast"
replace country="Congo, Dem. Rep." if country=="Democratic Republic of Congo"
replace country="Gambia" if country=="The Gambia"

replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="North Macedonia" if country=="Macedonia, FYR"
replace country="Russian Federation" if country=="Russia"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Czechia" if country=="Czech Republic"
replace country="Turkiye" if country=="Turkey"

/* Merging with Cost of Lawyers 2023 clean data for new countries */
/* 
sort id_alex

merge 1:1 id_alex using "cost of lawyers_2023.dta"
tab _merge
drop if _merge==2
drop _merge 
save qrq.dta, replace
*/


/*=================================================================================================================
					VI. Checks
=================================================================================================================*/

cls 

*----- Running the checks routine (2023 checks)
do "${path2dos23}\\Routines\\check.do"


********************************************************
				 /* 6. Outliers */
********************************************************

*Total number of experts by country
bysort country: gen N=_N

*Total number of experts by country and discipline
bysort country question: gen N_questionnaire=_N

*Average score and standard deviation (for outliers)
bysort country: egen total_score_mean=mean(total_score)
bysort country: egen total_score_sd=sd(total_score)

*Define global for norm variables
do "${path2dos}\\Routines\\globals.do"


*----- Aggregate Scores - NO DELETIONS (scenario 0)

preserve

collapse (mean) $norm (sum) count_cc count_cj count_lb count_ph, by(country)

qui do "${path2dos}\\Routines\\scores.do"

save "$path2data\\2. Scenarios\\qrq_country_averages_s0.dta", replace

keep country count_cc count_cj count_lb count_ph
egen total_counts=rowtotal(count_cc count_cj count_lb count_ph)

save "$path2data\\2. Scenarios\\country_counts_s0.dta", replace

restore


*----- Aggregate Scores - Removing general outliers (scenario 1)

preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

collapse (mean) $norm, by(country)

qui do "${path2dos}\\Routines\scores.do"

save "${path2data}\\2. Scenarios\qrq_country_averages_s1.dta", replace

restore


*----- Aggregate Scores - Removing general outliers + outliers by discipline (highest/lowest) (scenario 2)

preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 2)
qui do "${path2dos}\\Routines\outliers_dis.do"

*Dropping outliers by disciplines (IQR)
foreach x in cc cj lb ph {
	drop if outlier_iqr_`x'_hi==1
	drop if outlier_iqr_`x'_lo==1
}

collapse (mean) $norm, by(country)

qui do "${path2dos}\\Routines\scores.do"

save "${path2data}\\2. Scenarios\qrq_country_averages_s2.dta", replace

restore


*----- Aggregate Scores - Removing question outliers + general outliers + discipline outliers (scenario 3)


***** POSITIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 2)
qui do "${path2dos}\\Routines\outliers_dis.do"

*Dropping outliers by disciplines (IQR)
foreach x in cc cj lb ph {
	drop if outlier_iqr_`x'_hi==1
	drop if outlier_iqr_`x'_lo==1
}

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\\Routines\outliers_ques.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\\Routines\subfactor_questions.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\\Routines\outliers_sub.do"

*Dropping questions that are outliers (max-min values with a proportion of less than 15% only for the experts who have the extreme values in questions & sub-factor)
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 {
	display as result "`v'"
	foreach x of global `v' {
		display as error "`x'" 
		replace `x'=. if `x'==`x'_max & `x'_hi_p<0.15 & `x'_c>5 & `x'!=. & outlier_`v'_iqr_hi==1		
}
}

collapse (mean) $norm, by(country)

qui do "${path2dos}\\Routines\scores.do"

save "${path2data}\\2. Scenarios\qrq_country_averages_s3_p.dta", replace

restore


***** NEGATIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 2)
qui do "${path2dos}\\Routines\outliers_dis.do"

*Dropping outliers by disciplines (IQR)
foreach x in cc cj lb ph {
	drop if outlier_iqr_`x'_hi==1
	drop if outlier_iqr_`x'_lo==1
}

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\\Routines\outliers_ques.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\\Routines\outliers_sub.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\\Routines\subfactor_questions.do"

*Dropping questions that are outliers (max-min values with a proportion of less than 15% only for the experts who have the extreme values in questions & sub-factor)
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 {
	display as result "`v'"
	foreach x of global `v' {
		display as error "`x'" 		
		replace `x'=. if `x'==`x'_min & `x'_lo_p<0.15 & `x'_c>5 & `x'!=. & outlier_`v'_iqr_lo==1
		
}
}

collapse (mean) $norm, by(country)

qui do "${path2dos}\\Routines\scores.do"

save "${path2data}\\2. Scenarios\qrq_country_averages_s3_n.dta", replace

restore


*----- Aggregate Scores - Removing question outliers + general outliers + discipline outliers (scenario 3) ALTERNATIVE


***** POSITIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\\Routines\outliers_ques.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\\Routines\subfactor_questions.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\\Routines\outliers_sub.do"

*Dropping questions that are outliers (max-min values with a proportion of less than 15% only for the experts who have the extreme values in questions & sub-factor)
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 {
	display as result "`v'"
	foreach x of global `v' {
		display as error "`x'" 
		replace `x'=. if `x'==`x'_max & `x'_hi_p<0.15 & `x'_c>5 & `x'!=. & outlier_`v'_iqr_hi==1		
}
}

collapse (mean) $norm, by(country)

qui do "${path2dos}\\Routines\scores.do"

save "${path2data}\\2. Scenarios\qrq_country_averages_s3_p_alt.dta", replace

restore


***** NEGATIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\\Routines\outliers_ques.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\\Routines\outliers_sub.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\\Routines\subfactor_questions.do"

*Dropping questions that are outliers (max-min values with a proportion of less than 15% only for the experts who have the extreme values in questions & sub-factor)
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 {
	display as result "`v'"
	foreach x of global `v' {
		display as error "`x'" 		
		replace `x'=. if `x'==`x'_min & `x'_lo_p<0.15 & `x'_c>5 & `x'!=. & outlier_`v'_iqr_lo==1
		
}
}

collapse (mean) $norm, by(country)

qui do "${path2dos}\\Routines\scores.do"

save "${path2data}\\2. Scenarios\qrq_country_averages_s3_n_alt.dta", replace

restore


*----- Aggregate Scores - Removing sub-factor outliers + general outliers + discipline outliers (scenario 4)


***** POSITIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 2)
qui do "${path2dos}\\Routines\outliers_dis.do"

*Dropping outliers by disciplines (IQR)
foreach x in cc cj lb ph {
	drop if outlier_iqr_`x'_hi==1
	drop if outlier_iqr_`x'_lo==1
}

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\\Routines\outliers_ques.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\\Routines\outliers_sub.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\\Routines\subfactor_questions.do"

*Dropping ALL questions in sub-factor if the expert is an outlier for this indicator
#delimit ;
foreach v in 
f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 
f_2_1 f_2_2 f_2_3 f_2_4
f_3_1 f_3_2 f_3_3 f_3_4
f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8
f_5_3
f_6_1 f_6_2 f_6_3 f_6_4 f_6_5
f_7_1 f_7_2 f_7_3  f_7_4 f_7_5 f_7_6 f_7_7
f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7
{;
	display as result "`v'"	;
	foreach x of global `v' {;
		display as error "`x'" ;
		replace `x'=. if `x'_c>5 & `x'!=. & outlier_`v'_iqr_hi==1 ;	
};
};
#delimit cr

collapse (mean) $norm, by(country)

qui do "${path2dos}\\Routines\scores.do"

save "${path2data}\\2. Scenarios\qrq_country_averages_s4_p.dta", replace

restore


***** NEGATIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 2)
qui do "${path2dos}\\Routines\outliers_dis.do"

*Dropping outliers by disciplines (IQR)
foreach x in cc cj lb ph {
	drop if outlier_iqr_`x'_hi==1
	drop if outlier_iqr_`x'_lo==1
}

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\\Routines\outliers_ques.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\\Routines\outliers_sub.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\\Routines\subfactor_questions.do"

*Dropping ALL questions in sub-factor if the expert is an outlier for this indicator
#delimit ;
foreach v in 
f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 
f_2_1 f_2_2 f_2_3 f_2_4
f_3_1 f_3_2 f_3_3 f_3_4
f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8
f_5_3
f_6_1 f_6_2 f_6_3 f_6_4 f_6_5
f_7_1 f_7_2 f_7_3  f_7_4 f_7_5 f_7_6 f_7_7
f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7
{;
	display as result "`v'"	;
	foreach x of global `v' {;
		display as error "`x'" ;
		replace `x'=. if `x'_c>5 & `x'!=. & outlier_`v'_iqr_lo==1 ;	
};
};
#delimit cr

collapse (mean) $norm, by(country)

qui do "${path2dos}\\Routines\scores.do"

save "${path2data}\\2. Scenarios\qrq_country_averages_s4_n.dta", replace

restore


*----- Aggregate Scores - Removing sub-factor outliers + general outliers + discipline outliers (scenario 4) ALTERNATIVE


***** POSITIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\\Routines\outliers_ques.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\\Routines\outliers_sub.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\\Routines\subfactor_questions.do"

*Dropping ALL questions in sub-factor if the expert is an outlier for this indicator
#delimit ;
foreach v in 
f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 
f_2_1 f_2_2 f_2_3 f_2_4
f_3_1 f_3_2 f_3_3 f_3_4
f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8
f_5_3
f_6_1 f_6_2 f_6_3 f_6_4 f_6_5
f_7_1 f_7_2 f_7_3  f_7_4 f_7_5 f_7_6 f_7_7
f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7
{;
	display as result "`v'"	;
	foreach x of global `v' {;
		display as error "`x'" ;
		replace `x'=. if `x'_c>5 & `x'!=. & outlier_`v'_iqr_hi==1 ;	
};
};
#delimit cr

collapse (mean) $norm, by(country)

qui do "${path2dos}\\Routines\scores.do"

save "${path2data}\\2. Scenarios\qrq_country_averages_s4_p_alt.dta", replace

restore


***** NEGATIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\\Routines\outliers_ques.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\\Routines\outliers_sub.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\\Routines\subfactor_questions.do"

*Dropping ALL questions in sub-factor if the expert is an outlier for this indicator
#delimit ;
foreach v in 
f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 
f_2_1 f_2_2 f_2_3 f_2_4
f_3_1 f_3_2 f_3_3 f_3_4
f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8
f_5_3
f_6_1 f_6_2 f_6_3 f_6_4 f_6_5
f_7_1 f_7_2 f_7_3  f_7_4 f_7_5 f_7_6 f_7_7
f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7
{;
	display as result "`v'"	;
	foreach x of global `v' {;
		display as error "`x'" ;
		replace `x'=. if `x'_c>5 & `x'!=. & outlier_`v'_iqr_lo==1 ;	
};
};
#delimit cr

collapse (mean) $norm, by(country)

qui do "${path2dos}\\Routines\scores.do"

save "${path2data}\\2. Scenarios\qrq_country_averages_s4_n_alt.dta", replace

restore


/*=================================================================================================================
					VII. Adjustments
=================================================================================================================*/

sort country question total_score
br question year country longitudinal id_alex total_score ROLI f_1 f_2 f_3 f_4 f_6 f_7 f_8  if country=="Afghanistan" 

br question year country longitudinal id_alex total_score ROLI f_1 f_2 f_3 f_4 f_6 f_7 f_8  if country=="Vietnam" 





drop total_score_mean
bysort country: egen total_score_mean=mean(total_score)


*save "${path2data}\3. Final\qrq_{$year_current}.dta", replace


/*=================================================================================================================
					VIII. Number of surveys per discipline, year, and country
=================================================================================================================*/


/*=================================================================================================================
					IX. Country Averages
=================================================================================================================*/

//cc_q6a_usd cc_q6a_gni 
foreach var of varlist cc_q1_norm- all_q105_norm {
	bysort country: egen CO_`var'=mean(`var')
}

egen tag = tag(country)
keep if tag==1
drop cc_q1- all_q105_norm //cc_q6a_usd cc_q6a_gni

rename CO_* *
drop tag
drop question id_alex language
sort country

drop WJP_login longitudinal year regular
drop total_score- total_score_mean

*order WJP_password cc_q6a_usd cc_q6a_gni, last
order WJP_password, last
drop WJP_password
*save "${path2data}\3. Final\qrq_country_averages.dta", replace

br







