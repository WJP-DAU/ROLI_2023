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


********************************************************
				  /* 1.Averages */
********************************************************

egen total_score=rowmean(cc_q1_norm- ph_q14_norm)
drop if total_score==.


********************************************************
				  /* 2.Duplicates */
********************************************************

sort country question year

*------ Duplicates by login (can show duplicates for years and surveys. Ex: An expert that answered three qrq's one year)
duplicates tag WJP_login, generate(dup)
tab dup
br if dup>0


*------ Duplicates by login and score (shows duplicates of year and expert, that SHOULD be removed)
duplicates tag WJP_login total_score, generate(true_dup)
tab true_dup
br if true_dup>0


*------ Duplicates by id and year (Doesn't show the country)
duplicates tag id_alex, generate (dup_alex)
tab dup_alex
br if dup_alex>0


*------ Duplicates by id, year and score (Should be removed)
duplicates tag id_alex total_score, generate(true_dup_alex)
tab true_dup_alex
br if true_dup_alex>0


*------ Duplicates by login and questionnaire. Helps identify duplicate old experts without password. Should be removed if the country and question are the same
duplicates tag question WJP_login, generate(true_dup_question)
tab true_dup_question
br if true_dup_question>0


*------ Duplicates by login, questionnaire and year. They should be removed if the country and year are the same.
duplicates tag question WJP_login year, generate(true_dup_question_year)
tab true_dup_question_year
br if true_dup_question_year>0


*------ Check which years don't have a password
tab year if WJP_password!=.
tab year if WJP_password==.


*------ Duplicates by password and questionnaire. Some experts have changed their emails and our check with id_alex doesn't catch them. 
duplicates tag question country WJP_password, gen(dup_password)

br if dup_password>0 & WJP_password!=.
tab dup_password if WJP_password!=.

*Check the year and keep the most recent one
tab year if dup_password>0 & WJP_password!=.

bys question country WJP_password: egen year_max=max(year) if dup_password>0 & dup_password!=. & WJP_password!=.
gen dup_mark=1 if year!=year_max & dup_password>0 & dup_password!=. & WJP_password!=.
drop if dup_mark==1

drop dup_password year_max dup_mark

tab year


*------ Duplicates by login (lowercases) and questionnaire. 
/*This check drops experts that have emails with uppercases and are included 
from two different years of the same questionnaire and country (consecutive years). We should remove the 
old responses that we are including as "regular" that we think are regular because of the 
upper and lower cases. */

gen WJP_login_lower=ustrlower(WJP_login)
duplicates tag question country WJP_login_lower , generate(true_dup_question_lower)
tab true_dup_question_lower

sort country question WJP_login_lower year
br if true_dup_question_lower>0

bys country question WJP_login_lower: egen year_max=max(year) if true_dup_question_lower>0
gen dup_mark=1 if year!=year_max & true_dup_question_lower>0 & WJP_password==.

drop if dup_mark==1

*Test it again
drop true_dup_question_lower
duplicates tag question country WJP_login_lower , generate(true_dup_question_lower)
tab true_dup_question_lower

sort country question WJP_login_lower year
br if true_dup_question_lower>0

drop dup true_dup dup_alex true_dup_alex true_dup_question true_dup_question_year WJP_login_lower year_max dup_mark true_dup_question_lower


********************************************************
/* 3. Drop questionnaires with very few observations */
********************************************************

egen total_n=rownonmiss(cc_q1_norm- ph_q14_norm)

*Total number of experts by country
bysort country: gen N=_N

*Total number of experts by country and discipline
bysort country question: gen N_questionnaire=_N


*Number of questions per QRQ
*CC: 162
*CJ: 197
*LB: 134
*PH: 49

*Drops surveys with less than 25 nonmissing values. Erin cleaned empty suveys and surveys with low responses
*There are countries with low total_n because we removed the DN/NA at the beginning of the do file
br if total_n<=25
drop if total_n<=25 & N>=20


********************************************************
				 /* 4. Factor scores */
********************************************************

qui do "${path2dos}\\Routines\\scores.do"

 
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
qui do "${path2dos}\\Routines\\globals.do"


*----- Aggregate Scores - NO DELETIONS (scenario 0)

preserve

collapse (mean) $norm (sum) count_cc count_cj count_lb count_ph, by(country)

qui do "${path2dos}\\Routines\\scores.do"

save "${path2data}\2. Scenarios\qrq_country_averages_s0.dta", replace

keep country count_cc count_cj count_lb count_ph
egen total_counts=rowtotal(count_cc count_cj count_lb count_ph)

save "${path2data}\2. Scenarios\country_counts_s0.dta", replace

restore


*----- Aggregate Scores - Removing general outliers (scenario 1)

preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

collapse (mean) $norm, by(country)

qui do "${path2dos}\Routines\scores.do"

save "${path2data}\2. Scenarios\qrq_country_averages_s1.dta", replace

restore


*----- Aggregate Scores - Removing general outliers + outliers by discipline (highest/lowest) (scenario 2)

preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 2)
qui do "${path2dos}\Routines\outliers_dis.do"

*Dropping outliers by disciplines (IQR)
foreach x in cc cj lb ph {
	drop if outlier_iqr_`x'_hi==1
	drop if outlier_iqr_`x'_lo==1
}

collapse (mean) $norm, by(country)

qui do "${path2dos}\Routines\scores.do"

save "${path2data}\2. Scenarios\qrq_country_averages_s2.dta", replace

restore


*----- Aggregate Scores - Removing question outliers + general outliers + discipline outliers (scenario 3)


***** POSITIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 2)
qui do "${path2dos}\Routines\outliers_dis.do"

*Dropping outliers by disciplines (IQR)
foreach x in cc cj lb ph {
	drop if outlier_iqr_`x'_hi==1
	drop if outlier_iqr_`x'_lo==1
}

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\Routines\outliers_ques.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\Routines\subfactor_questions.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\Routines\outliers_sub.do"

*Dropping questions that are outliers (max-min values with a proportion of less than 15% only for the experts who have the extreme values in questions & sub-factor)
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 {
	display as result "`v'"
	foreach x of global `v' {
		display as error "`x'" 
		replace `x'=. if `x'==`x'_max & `x'_hi_p<0.15 & `x'_c>5 & `x'!=. & outlier_`v'_iqr_hi==1		
}
}

collapse (mean) $norm, by(country)

qui do "${path2dos}\Routines\scores.do"

save "${path2data}\2. Scenarios\qrq_country_averages_s3_p.dta", replace

restore


***** NEGATIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 2)
qui do "${path2dos}\Routines\outliers_dis.do"

*Dropping outliers by disciplines (IQR)
foreach x in cc cj lb ph {
	drop if outlier_iqr_`x'_hi==1
	drop if outlier_iqr_`x'_lo==1
}

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\Routines\outliers_ques.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\Routines\outliers_sub.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\Routines\subfactor_questions.do"

*Dropping questions that are outliers (max-min values with a proportion of less than 15% only for the experts who have the extreme values in questions & sub-factor)
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 {
	display as result "`v'"
	foreach x of global `v' {
		display as error "`x'" 		
		replace `x'=. if `x'==`x'_min & `x'_lo_p<0.15 & `x'_c>5 & `x'!=. & outlier_`v'_iqr_lo==1
		
}
}

collapse (mean) $norm, by(country)

qui do "${path2dos}\Routines\scores.do"

save "${path2data}\2. Scenarios\qrq_country_averages_s3_n.dta", replace

restore


*----- Aggregate Scores - Removing question outliers + general outliers + discipline outliers (scenario 3) ALTERNATIVE


***** POSITIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\Routines\outliers_ques.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\Routines\subfactor_questions.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\Routines\outliers_sub.do"

*Dropping questions that are outliers (max-min values with a proportion of less than 15% only for the experts who have the extreme values in questions & sub-factor)
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 {
	display as result "`v'"
	foreach x of global `v' {
		display as error "`x'" 
		replace `x'=. if `x'==`x'_max & `x'_hi_p<0.15 & `x'_c>5 & `x'!=. & outlier_`v'_iqr_hi==1		
}
}

collapse (mean) $norm, by(country)

qui do "${path2dos}\Routines\scores.do"

save "${path2data}\2. Scenarios\qrq_country_averages_s3_p_alt.dta", replace

restore


***** NEGATIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\Routines\outliers_ques.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\Routines\outliers_sub.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\Routines\subfactor_questions.do"

*Dropping questions that are outliers (max-min values with a proportion of less than 15% only for the experts who have the extreme values in questions & sub-factor)
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 {
	display as result "`v'"
	foreach x of global `v' {
		display as error "`x'" 		
		replace `x'=. if `x'==`x'_min & `x'_lo_p<0.15 & `x'_c>5 & `x'!=. & outlier_`v'_iqr_lo==1
		
}
}

collapse (mean) $norm, by(country)

qui do "${path2dos}\Routines\scores.do"

save "${path2data}\2. Scenarios\qrq_country_averages_s3_n_alt.dta", replace

restore


*----- Aggregate Scores - Removing sub-factor outliers + general outliers + discipline outliers (scenario 4)


***** POSITIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 2)
qui do "${path2dos}\Routines\outliers_dis.do"

*Dropping outliers by disciplines (IQR)
foreach x in cc cj lb ph {
	drop if outlier_iqr_`x'_hi==1
	drop if outlier_iqr_`x'_lo==1
}

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\Routines\outliers_ques.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\Routines\outliers_sub.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\Routines\subfactor_questions.do"

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

qui do "${path2dos}\Routines\scores.do"

save "${path2data}\2. Scenarios\qrq_country_averages_s4_p.dta", replace

restore


***** NEGATIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 2)
qui do "${path2dos}\Routines\outliers_dis.do"

*Dropping outliers by disciplines (IQR)
foreach x in cc cj lb ph {
	drop if outlier_iqr_`x'_hi==1
	drop if outlier_iqr_`x'_lo==1
}

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\Routines\outliers_ques.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\Routines\outliers_sub.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\Routines\subfactor_questions.do"

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

qui do "${path2dos}\Routines\scores.do"

save "${path2data}\2. Scenarios\qrq_country_averages_s4_n.dta", replace

restore


*----- Aggregate Scores - Removing sub-factor outliers + general outliers + discipline outliers (scenario 4) ALTERNATIVE


***** POSITIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\Routines\outliers_ques.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\Routines\outliers_sub.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\Routines\subfactor_questions.do"

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

qui do "${path2dos}\Routines\scores.do"

save "${path2data}\2. Scenarios\qrq_country_averages_s4_p_alt.dta", replace

restore


***** NEGATIVE OUTLIERS
preserve

*Outliers routine (scenario 1)
qui do "${path2dos}\Routines\outliers_gen.do"

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Outliers routine (scenario 3) - This routine defines the outliers by question
qui do "${path2dos}\Routines\outliers_ques.do"

*Outliers routine (scenario 4) - This routine defines the sub-factor outliers 
qui do "${path2dos}\Routines\outliers_sub.do"

*This routine defines the globals for each sub-factor (all questions included in the sub-factor)
qui do "${path2dos}\Routines\subfactor_questions.do"

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

qui do "${path2dos}\Routines\scores.do"

save "${path2data}\2. Scenarios\qrq_country_averages_s4_n_alt.dta", replace

restore


/*
*----- Aggregate Scores - Removing question outliers + general outliers (scenario 3)

preserve

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Dropping questions that are outliers (max-min values with a proportion of less than 15%)
foreach v in $norm {
	display as result "`v'"
	replace `v'=. if `v'_hi_p<0.15 & `v'_c>5 & `v'!=.
	replace `v'=. if `v'_lo_p<0.15 & `v'_c>5 & `v'!=. 
}

collapse (mean) $norm, by(country)

qui do "${path2dos}\Routines\scores.do"

save "${path2data}\2. Scenarios\qrq_country_averages_s4.dta", replace

restore


foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 {
	display as result "`v'"
	foreach x of global `v' {
		display as error "`x'" 
		replace `x'=. if outlier_`v'_lo==1 & `x'_c>5 
		replace `x'=. if outlier_`v'_hi==1 & `x'_c>5 
}
}



*/


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

drop count_cc count_cj count_lb count_ph cc_total cj_total lb_total ph_total tail_cc tail_cj tail_lb tail_ph cc_total_tail cj_total_tail lb_total_tail ph_total_tail percentage_tail_cc percentage_tail_cj percentage_tail_lb percentage_tail_ph

gen aux_cc=1 if question=="cc"
gen aux_cj=1 if question=="cj"
gen aux_lb=1 if question=="lb"
gen aux_ph=1 if question=="ph"

local i=2013
	while `i'<=2024 {
		gen aux_cc_`i'=1 if question=="cc" & year==`i'
		gen aux_cj_`i'=1 if question=="cj" & year==`i'
		gen aux_lb_`i'=1 if question=="lb" & year==`i'
		gen aux_ph_`i'=1 if question=="ph" & year==`i'
	local i=`i'+1 
}	

gen aux_cc_24_long=1 if question=="cc" & year==2024 & longitudinal==1
gen aux_cj_24_long=1 if question=="cj" & year==2024 & longitudinal==1
gen aux_lb_24_long=1 if question=="lb" & year==2024 & longitudinal==1
gen aux_ph_24_long=1 if question=="ph" & year==2024 & longitudinal==1

bysort country: egen cc_total=total(aux_cc)
bysort country: egen cj_total=total(aux_cj)
bysort country: egen lb_total=total(aux_lb)
bysort country: egen ph_total=total(aux_ph)

local i=2013
	while `i'<=2024 {
		bysort country: egen cc_total_`i'=total(aux_cc_`i')
		bysort country: egen cj_total_`i'=total(aux_cj_`i')
		bysort country: egen lb_total_`i'=total(aux_lb_`i')
		bysort country: egen ph_total_`i'=total(aux_ph_`i')
	local i=`i'+1 
}	

bysort country: egen cc_total_2024_long=total(aux_cc_24_long)
bysort country: egen cj_total_2024_long=total(aux_cj_24_long)
bysort country: egen lb_total_2024_long=total(aux_lb_24_long)
bysort country: egen ph_total_2024_long=total(aux_ph_24_long)

egen tag = tag(country)

*Short counts

br country cc_total cj_total lb_total ph_total cc_total_2024 cj_total_2024 lb_total_2024 ph_total_2024 cc_total_2024_long cj_total_2024_long lb_total_2024_long ph_total_2024_long if tag==1

*All counts

br country cc_total cj_total lb_total ph_total ///
cc_total_2024 cj_total_2024 lb_total_2024 ph_total_2024 ///
cc_total_2023 cj_total_2023 lb_total_2023 ph_total_2023 ///
cc_total_2022 cj_total_2022 lb_total_2022 ph_total_2022 /// 
cc_total_2021 cj_total_2021 lb_total_2021 ph_total_2021 /// 
cc_total_2019 cj_total_2019 lb_total_2019 ph_total_2019 /// 
cc_total_2018 cj_total_2018 lb_total_2018 ph_total_2018 /// 
cc_total_2017 cj_total_2017 lb_total_2017 ph_total_2017 /// 
cc_total_2016 cj_total_2016 lb_total_2016 ph_total_2016 /// 
cc_total_2014 cj_total_2014 lb_total_2014 ph_total_2014 /// 
cc_total_2013 cj_total_2013 lb_total_2013 ph_total_2013 if tag==1


drop  aux_cc-tag


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







