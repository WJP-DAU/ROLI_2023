/*=================================================================================================================
Project:		QRQ importing LONG
Routine:		QRQ Data Cleaning and Harmonization 2023 (master do file)
Author(s):		Natalia Rodriguez (nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	May, 2025

Description:
This do file imports the original LONG datasets for 2022.

=================================================================================================================*/

/*=================================================================================================================
					I. Importing the data
=================================================================================================================*/

/*-----------*/
/* 1. Civil  */
/*-----------*/
import excel "${path2data}/1. Original/CC Long 2023.xlsx", sheet("Worksheet") firstrow clear
drop in 1
gen longitudinal=1
gen question="cc"
rename SG_id id_original
rename Vlanguage language
rename WJP_country country

egen id=concat(language longitudinal id_original), punct(_)
egen id_alex=concat(question id), punct(_)
drop id id_original

**We are keeping the responses from last year
keep WJP_login WJP_password id_alex country question _cc*
order WJP_login WJP_password id_alex country question

*Rename variables
rename _cc* cc*

*Destring
destring cc_*, replace

/* Recoding question 26 */
foreach var of varlist cc_q26a-cc_q26k {
	replace `var'=. if `var'==99
}

/* Recoding questions */
foreach var of varlist cc_q20a cc_q20b cc_q21 {
	replace `var'=1 if `var'==0
	replace `var'=2 if `var'==5
	replace `var'=3 if `var'==25
	replace `var'=4 if `var'==50
	replace `var'=5 if `var'==75
	replace `var'=6 if `var'==100
}
/* Changing 9 for missing */
foreach var of varlist cc_q1 cc_q3a cc_q3b cc_q3c cc_q4a cc_q4b cc_q4c cc_q5a cc_q5b cc_q5c {
	replace `var'=. if `var'==9
}

foreach var of varlist cc_q7a-cc_q25  {
	replace `var'=. if `var'==9
}

foreach var of varlist cc_q27- cc_q40b{
	replace `var'=. if `var'==9
}

/* Check that all variables don't have 99s */
qui: ds , has(type numeric) 
local var_num=r(varlist)
	foreach var of local var_num{
		list `var' if `var'==9 & `var'!=.
	}

sum cc_*

/* Change names to match the MAP file and the GPP */

drop if country=="Burundi"

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

save "${path2data}/1. Original/cc_final_long_2022.dta", replace


/*--------------*/
/* 2. Criminal  */
/*--------------*/

clear
import excel "${path2data}/1. Original/CJ Long 2023", sheet("Worksheet") firstrow clear
drop in 1
gen longitudinal=1
gen question="cj"
rename SG_id id_original
rename Vlanguage language
rename WJP_country country

egen id=concat(language longitudinal id_original), punct(_)
egen id_alex=concat(question id), punct(_)
drop id id_original

**We are keeping the responses from last year
keep  WJP_login WJP_password id_alex country question _cj*
order WJP_login WJP_password id_alex country question

*Rename variables
rename _cj* cj*

*Destring
destring cj_*, replace

/* Change 99 for missing */
foreach var of varlist cj_q16a- cj_q21k cj_q27a cj_q27b cj_q37a-cj_q37d {
	replace `var'=. if `var'==99
}

/* Changing 9 for missing */
foreach var of varlist cj_q1- cj_q15 {
	replace `var'=. if `var'==9
}

/* Recoding questions */
foreach var of varlist cj_q22a-cj_q25c cj_q28 {
	replace `var'=1 if `var'==0
	replace `var'=2 if `var'==5
	replace `var'=3 if `var'==25
	replace `var'=4 if `var'==50
	replace `var'=5 if `var'==75
	replace `var'=6 if `var'==100
}

foreach var of varlist cj_q22a-cj_q36d cj_q38-cj_q42h {
	replace `var'=. if `var'==9
}

/* Check that all variables don't have 99s */
qui: ds , has(type numeric) 
local var_num=r(varlist)
	foreach var of local var_num{
		list `var' if `var'==99 & `var'!=.
	}

sum cj_*	

/* Change names to match the MAP file and the GPP */

drop if country=="Burundi"

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


save "${path2data}/1. Original/cj_final_long_2022.dta", replace

/*-----------*/
/* 3. Labor  */
/*-----------*/

clear
import excel "${path2data}/1. Original/LB Long 2023", sheet("Worksheet") firstrow clear
drop in 1
gen longitudinal=1
gen question="lb"
rename SG_id id_original
rename Vlanguage language
rename WJP_country country


egen id=concat(language longitudinal id_original), punct(_)
egen id_alex=concat(question id), punct(_)
drop id id_original

**We are keeping the responses from last year
keep  WJP_login WJP_password id_alex country question _lb*
order WJP_login WJP_password id_alex country question

*Rename variables
rename _lb* lb*

*Destring
destring lb_*, replace

/* Recoding questions */
foreach var of varlist lb_q11a lb_q11b lb_q12 {
	replace `var'=1 if `var'==0 
	replace `var'=2 if `var'==5
	replace `var'=3 if `var'==25
	replace `var'=4 if `var'==50
	replace `var'=5 if `var'==75
	replace `var'=6 if `var'==100
}

/* Changing 9 for missing */
foreach var of varlist lb_q2a- lb_q4d {
	replace `var'=. if `var'==9
}

foreach var of varlist lb_q6a- lb_q28b {
	replace `var'=. if `var'==9
}

/* Check that all variables don't have 99s */
qui: ds , has(type numeric) 
local var_num=r(varlist)
	foreach var of local var_num{
		list `var' if `var'==99 & `var'!=.
	}

sum lb_*	

/* Change names to match the MAP file and the GPP */

drop if country=="Burundi"

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

save "${path2data}/1. Original/lb_final_long_2022.dta", replace

/*------------------*/
/* 4. Public Health */
/*------------------*/

clear
import excel "${path2data}/1. Original/PH Long 2023", sheet("Worksheet") firstrow clear
gen longitudinal=1
gen question="ph"
rename ResponseID SG_id
rename Language Vlanguage
rename wjp_login WJP_login 
rename wjp_password WJP_password 
rename wjp_country WJP_country
rename SG_id id_original
rename Vlanguage language
rename WJP_country country

egen id=concat(language longitudinal id_original), punct(_)
egen id_alex=concat(question id), punct(_)
drop id id_original

**We are keeping the responses from last year
keep  WJP_login WJP_password id_alex country question _ph*
order WJP_login WJP_password id_alex country question

*Rename variables
rename _ph* ph*

*Destring
destring ph_*, replace

/* Recoding questions */
foreach var of varlist ph_q5a ph_q5b ph_q5c ph_q5d {
	replace `var'=1 if `var'==0
	replace `var'=2 if `var'==5
	replace `var'=3 if `var'==25
	replace `var'=4 if `var'==50
	replace `var'=5 if `var'==75
	replace `var'=6 if `var'==100
}

/* Changing 9 for missing */
foreach var of varlist ph_q1a- ph_q6g {
	replace `var'=. if `var'==9
}

foreach var of varlist ph_q7- ph_q14 {
	replace `var'=. if `var'==9
}

/* Check that all variables don't have 99s */
qui: ds , has(type numeric) 
local var_num=r(varlist)
	foreach var of local var_num{
		list `var' if `var'==99 & `var'!=.
	}

sum ph_*	

/* Change names to match the MAP file and the GPP */

drop if country=="Burundi"

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

save "${path2data}/1. Original/ph_final_long_2022.dta", replace

