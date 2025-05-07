clear
set more off, perm

*cd "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Index Data & Analysis\2023\QRQ"
*cd "C:\Users\poncea\Desktop\Index 2023\QRQ"

/*-------------------------------------------------------*/
/*                 QRQ CLEANING DO FILE                  */
/*-------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*=================================================================================================================
					Pre-settings
=================================================================================================================*/

*--- Required packages:
* NONE

*--- Defining paths to SharePoint & your local Git Repo copy:

*------ (a) Natalia Rodriguez:
if (inlist("`c(username)'", "nrodriguez")) {
	global path2SP "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Data Analytics\7. WJP ROLI\ROLI_2023\1. Cleaning\QRQ"
	global path2GH ""
}


*--- Defining path to Data and DoFiles:
global path2data "${path2SP}/1. Data"
global path2dos  "${path2SP}/2. Code"


/*----------------------*/
/* I. Cleaning the data */
/*----------------------*/
/*-----------*/
/* 1. Civil  */
/*-----------*/

import excel "$path2data/1. Original/CC Long 2023.xlsx", sheet("Worksheet") firstrow clear
*import excel "C:\Users\poncea\Desktop\Index 2023\QRQ\CC Long 2023.xlsx", sheet("Worksheet") firstrow clear
drop in 1
drop _cc*
order SG_id
drop cc_leftout-cc_referral3_language iVstatus
gen longitudinal=1
save "$path2data/1. Original/cc_final_long.dta", replace

clear
import excel "$path2data/1. Original/CC Reg 2023.xlsx", sheet("Worksheet") firstrow clear
*import excel "C:\Users\poncea\Desktop\Index 2023\QRQ\CC Reg 2023.xlsx", sheet("Worksheet") firstrow clear
drop in 1
drop cc_leftout-cc_referral3_language iVstatus
gen longitudinal=0

// Append the regular and the longitudinal databases
append using "$path2data/1. Original/cc_final_long.dta"
gen question="cc"

destring SG_id cc_*, replace

* Check for experts without id
count if SG_id==.

rename SG_id id_original
rename Vlanguage language
rename WJP_country country

* Create ID
egen id=concat(language longitudinal id_original), punct(_)
egen id_alex=concat(question id), punct(_)
drop id id_original

/* These 3 lines are for incorporating 2022 data */
gen year=2023
gen regular=0
drop if language=="Last_Year"

order question year regular longitudinal id_alex language country WJP_login

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

destring WJP_password, replace

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

save "$path2data/1. Original/cc_final.dta", replace
erase "$path2data/1. Original/cc_final_long.dta"


/*--------------*/
/* 2. Criminal  */
/*--------------*/

clear
import excel "$path2data/1. Original/CJ Long 2023", sheet("Worksheet") firstrow clear
*import excel "C:\Users\poncea\Desktop\Index 2023\QRQ\CJ Long 2023", sheet("Worksheet") firstrow clear
drop in 1
drop _cj*
drop GI GJ GK GL GM GT
drop cj_leftout-cj_referral3_language iVstatus cj_eu
order SG_id
gen longitudinal=1
save "$path2data/1. Original/cj_final_long.dta", replace

clear
import excel "$path2data/1. Original/CJ Reg 2023", sheet("Worksheet") firstrow clear
*import excel "C:\Users\poncea\Desktop\Index 2023\QRQ\CJ Reg 2023", sheet("Worksheet") firstrow clear
drop in 1
drop CU CV CW CX CY DC
drop cj_leftout-cj_referral3_language iVstatus
gen longitudinal=0

// Append the regular and the longitudinal databases
append using "$path2data/1. Original/cj_final_long.dta"

gen question="cj"

destring SG_id cj_*, replace

* Check for experts without id
count if SG_id==.

rename SG_id id_original
rename Vlanguage language
rename WJP_country country

* Create ID
egen id=concat(language longitudinal id_original), punct(_)
egen id_alex=concat(question id), punct(_)
drop id id_original

/* These 3 lines are for incorporating 2022 data */
gen year=2023
gen regular=0
drop if language=="Last_Year"

order question year regular longitudinal id_alex language country WJP_login

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

destring WJP_password, replace
	
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

save "$path2data/1. Original/cj_final.dta", replace
erase "$path2data/1. Original/cj_final_long.dta"

/*-----------*/
/* 3. Labor  */
/*-----------*/

clear
import excel "$path2data/1. Original/LB Long 2023", sheet("Worksheet") firstrow clear
*import excel "C:\Users\poncea\Desktop\Index 2023\QRQ\LB Long 2023", sheet("Worksheet") firstrow clear
drop in 1
drop _lb*
drop lb_teach lb_leftout-lb_referral3_language iVstatus
order SG_id
gen longitudinal=1
save "$path2data/1. Original/lb_final_long.dta", replace

clear
import excel "$path2data/1. Original/LB Reg 2023", sheet("Worksheet") firstrow clear
*import excel "C:\Users\poncea\Desktop\Index 2023\QRQ\LB Reg 2023", sheet("Worksheet") firstrow clear
drop in 1
drop lb_teach lb_leftout-lb_referral3_language iVstatus
gen longitudinal=0

// Append the regular and the longitudinal databases
append using "$path2data/1. Original/lb_final_long.dta"

gen question="lb"

destring SG_id lb_*, replace

* Check for experts without id
count if SG_id==.

rename SG_id id_original
rename Vlanguage language
rename WJP_country country

* Create ID
egen id=concat(language longitudinal id_original), punct(_)
egen id_alex=concat(question id), punct(_)
drop id id_original

/* These 3 lines are for incorporating 2022 data */
gen year=2023
gen regular=0
drop if language=="Last_Year"

order question year regular longitudinal id_alex language country WJP_login

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

destring WJP_password, replace

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

save "$path2data/1. Original/lb_final.dta", replace
erase "$path2data/1. Original/lb_final_long.dta"

/*------------------*/
/* 4. Public Health */
/*------------------*/

clear
import excel "$path2data/1. Original/PH Long 2023", sheet("Worksheet") firstrow clear
*import excel "C:\Users\poncea\Desktop\Index 2023\QRQ\PH Long 2023", sheet("Worksheet") firstrow clear
drop _ph*
rename ResponseID SG_id
rename Language Vlanguage
rename wjp_login WJP_login 
rename wjp_password WJP_password 
rename wjp_country WJP_country
order SG_id
drop ph_leftout-ph_referral3_language Status
gen longitudinal=1
save "$path2data/1. Original/ph_final_long.dta", replace

clear
import excel "$path2data/1. Original/PH Reg 2023", sheet("Worksheet") firstrow clear
*import excel "C:\Users\poncea\Desktop\Index 2023\QRQ\PH Reg 2023", sheet("Worksheet") firstrow clear
drop ph_leftout-ph_referral3_language iVstatus
gen longitudinal=0

// Append the regular and the longitudinal databases
append using "$path2data/1. Original/ph_final_long.dta"
gen question="ph"

* Check for experts without id
count if SG_id==.

rename SG_id id_original
rename Vlanguage language
rename WJP_country country

* Create ID
egen id=concat(language longitudinal id_original), punct(_)
egen id_alex=concat(question id), punct(_)
drop id id_original

/* These 3 lines are for incorporating 2022 data */
gen year=2023
gen regular=0
drop if language=="Last_Year"

order question year regular longitudinal id_alex language country WJP_login

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

save "$path2data/1. Original/ph_final.dta", replace
erase "$path2data/1. Original/ph_final_long.dta"

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------*/
/* II. Appending the data */
/*------------------------*/
clear
use "$path2data/1. Original/cc_final.dta"
append using "$path2data/1. Original/cj_final.dta"
append using "$path2data/1. Original/lb_final.dta"
append using "$path2data/1. Original/ph_final.dta"

save "$path2data/1. Original/qrq.dta", replace

erase "$path2data/1. Original/cc_final.dta"
erase "$path2data/1. Original/cj_final.dta"
erase "$path2data/1. Original/lb_final.dta"
erase "$path2data/1. Original/ph_final.dta"

/*--------------------------*/
/* III. Re-scaling the data */
/*--------------------------*/
/*----------*/
/* 1. Civil */
/*----------*/
use "$path2data/1. Original/qrq.dta", clear

foreach var of varlist cc_q1- cc_q5c cc_q7a- cc_q40b {
	gen `var'_norm=.
}

/* Cases */
replace cc_q1_norm=1 if cc_q1==1
replace cc_q1_norm=0 if cc_q1==2 | cc_q1==3

replace cc_q15_norm=(cc_q15-1)/2

/* Dummy  */
replace cc_q12_norm=0 if cc_q12==2
replace cc_q12_norm=1 if cc_q12==1

/* Likert 3 Values: Positive */
# delimit;
foreach var of varlist 
	cc_q31a cc_q31b cc_q31c cc_q31d cc_q31e cc_q31f cc_q31g cc_q31h
	cc_q33 cc_q38 {;
	replace `var'_norm=(`var'-1)/2; 
};
# delimit cr;

/* Likert 3 Values: Negative */
replace cc_q25_norm=1-((cc_q25-1)/2)
replace cc_q27_norm=1-((cc_q27-1)/2)

/* Likert 4 Values: Positive */
# delimit;
foreach var of varlist 
	cc_q5a cc_q5b cc_q5c
	cc_q8
	cc_q9a cc_q9b cc_q9c
	cc_q10
	cc_q11a cc_q11b
	cc_q13
	cc_q14a cc_q14b
	cc_q16a cc_q16b cc_q16c cc_q16d cc_q16e cc_q16f cc_q16g
	cc_q22a cc_q22b cc_q22c
	cc_q24
	cc_q29a cc_q29b cc_q29c
	cc_q30a cc_q30b cc_q30c
	cc_q32a cc_q32b cc_q32c cc_q32d cc_q32e cc_q32f cc_q32h cc_q32i cc_q32j cc_q32k cc_q32l
	cc_q34a cc_q34b cc_q34c cc_q34d cc_q34e cc_q34f cc_q34g cc_q34h cc_q34i cc_q34j cc_q34k cc_q34l
	cc_q35a cc_q35b cc_q35c cc_q35d cc_q35e cc_q35f cc_q35g
	cc_q36a cc_q36b cc_q36c cc_q36d cc_q36e cc_q36f cc_q36g 
	cc_q39a cc_q39b cc_q39c cc_q39d cc_q39e 
	cc_q40a cc_q40b {;
		replace `var'_norm=(`var'-1)/3; 
};
# delimit cr;

/* Likert 4 Values: Negative */
# delimit;
foreach var of varlist 
	cc_q7a cc_q7b cc_q7c cc_q7d
	cc_q19a cc_q19b cc_q19c cc_q19d cc_q19e cc_q19f cc_q19g cc_q19h cc_q19i cc_q19j cc_q19k cc_q19l
	cc_q23a cc_q23b cc_q23c cc_q23d cc_q23e cc_q23f
	cc_q28a cc_q28b cc_q28c cc_q28d cc_q28e cc_q28f
	cc_q29d
	cc_q36h 
	cc_q37a cc_q37b cc_q37c cc_q37d cc_q37e {;
		replace `var'_norm=1-((`var'-1)/3); 
};
# delimit cr;

/* Likert 5 Values: Positive */
# delimit;
foreach var of varlist 
	cc_q3a cc_q3b cc_q3c
	cc_q4a cc_q4b cc_q4c {;
		replace `var'_norm=(`var'-1)/4; 
};
# delimit cr;

/* Likert 6 Values: Positive */
replace cc_q20a_norm=1 if cc_q20a==6
replace cc_q20a_norm=0.75 if cc_q20a==5
replace cc_q20a_norm=0.5 if cc_q20a==4
replace cc_q20a_norm=0.25 if cc_q20a==3
replace cc_q20a_norm=0.05 if cc_q20a==2
replace cc_q20a_norm=0 if cc_q20a==1

/* Likert 6 Values: Negative */
replace cc_q20b_norm=0 if cc_q20b==6
replace cc_q20b_norm=0.05 if cc_q20b==5
replace cc_q20b_norm=0.25 if cc_q20b==4
replace cc_q20b_norm=0.5 if cc_q20b==3
replace cc_q20b_norm=0.75 if cc_q20b==2
replace cc_q20b_norm=1 if cc_q20b==1

replace cc_q21_norm=0 if cc_q21==6
replace cc_q21_norm=0.05 if cc_q21==5
replace cc_q21_norm=0.25 if cc_q21==4
replace cc_q21_norm=0.5 if cc_q21==3
replace cc_q21_norm=0.75 if cc_q21==2
replace cc_q21_norm=1 if cc_q21==1

/* Likert 10 Values: Negative */
# delimit;
foreach var of varlist 
	cc_q26a cc_q26b cc_q26c cc_q26d cc_q26e cc_q26f cc_q26g cc_q26h cc_q26i cc_q26j cc_q26k {;
		replace `var'_norm=1-((`var'-1)/9); 
};
# delimit cr;


/*-------------*/
/* 2. Criminal */
/*-------------*/
foreach var of varlist cj_q1- cj_q42h {
	gen `var'_norm=.
}

/* Cases */
gen alex=0 if cj_q38~=. 
replace alex=1 if cj_q38==4
bysort country: egen alex_co=mean(alex)
replace cj_q38_norm=1-((cj_q38-1)/2) if alex_co<0.5
replace cj_q38_norm=. if cj_q38==4
drop alex_co alex

replace cj_q8_norm=(cj_q8-1)/2
replace cj_q9_norm=(cj_q9-1)/2
replace cj_q14_norm=(cj_q14-1)

/* Likert 4 Values: Positive */
# delimit;
foreach var of varlist 
	cj_q3a cj_q3b cj_q3c
	cj_q4
	cj_q26
	cj_q35a cj_q35b cj_q35c cj_q35d
	cj_q36a cj_q36b cj_q36c cj_q36d
	cj_q39a cj_q39b cj_q39c cj_q39d cj_q39e cj_q39f cj_q39g cj_q39h cj_q39i cj_q39j cj_q39k cj_q39l
	cj_q40a cj_q40b cj_q40c cj_q40d cj_q40e cj_q40f cj_q40g cj_q40h
	cj_q41a cj_q41b cj_q41c cj_q41d cj_q41e cj_q41f cj_q41g {;
		replace `var'_norm=(`var'-1)/3; 
};
# delimit cr;

/* Likert 4 Values: Negative */
# delimit;
foreach var of varlist 
	cj_q1
	cj_q2
	cj_q6a cj_q6b cj_q6c cj_q6d
	cj_q7a cj_q7b cj_q7c 
	cj_q10
	cj_q11a cj_q11b
	cj_q12a cj_q12b cj_q12c cj_q12d cj_q12e cj_q12f
	cj_q13a cj_q13b cj_q13c cj_q13d cj_q13e cj_q13f
	cj_q15
	cj_q29a cj_q29b
	cj_q31a cj_q31b cj_q31c cj_q31d cj_q31e cj_q31f cj_q31g
	cj_q32b cj_q32c cj_q32d
	cj_q33a cj_q33b cj_q33c cj_q33d cj_q33e 
	cj_q34a cj_q34b cj_q34c cj_q34d cj_q34e 
	cj_q41h
	cj_q42a cj_q42b cj_q42c cj_q42d cj_q42e cj_q42f cj_q42g cj_q42h {;
		replace `var'_norm=1-((`var'-1)/3); 
};
# delimit cr;

/* Likert 5 Values: Positive */
# delimit;
foreach var of varlist 
	cj_q27a cj_q27b {;
		replace `var'_norm=(`var'-1)/4; 
};
# delimit cr;

/* Likert 6 Values: Positive */
# delimit;
foreach var of varlist 
	cj_q22a cj_q22b cj_q22d cj_q22e
	cj_q24a {;
		replace `var'_norm=1 if `var'==6;
		replace `var'_norm=0.75 if `var'==5;
		replace `var'_norm=0.5 if `var'==4;
		replace `var'_norm=0.25 if `var'==3;
		replace `var'_norm=0.05 if `var'==2;
		replace `var'_norm=0 if `var'==1; 
};
# delimit cr;

/* Likert 6 Values: Negative */
# delimit;
foreach var of varlist 
	cj_q22c
	cj_q24b cj_q24c
	cj_q25a cj_q25b cj_q25c
	cj_q28 {;
		replace `var'_norm=0 if `var'==6;
		replace `var'_norm=0.05 if `var'==5;
		replace `var'_norm=0.25 if `var'==4;
		replace `var'_norm=0.5 if `var'==3;
		replace `var'_norm=0.75 if `var'==2;
		replace `var'_norm=1 if `var'==1; 
};
# delimit cr;

/* Likert 10 Values: Negative */
# delimit;
foreach var of varlist 
	cj_q16a cj_q16b cj_q16c cj_q16d cj_q16e cj_q16f cj_q16g cj_q16h cj_q16i cj_q16j cj_q16k cj_q16l cj_q16m
 	cj_q18a cj_q18b cj_q18c cj_q18d cj_q18e
	cj_q19a cj_q19b cj_q19c cj_q19d cj_q19e cj_q19f cj_q19g
	cj_q20a cj_q20b cj_q20c cj_q20d cj_q20e cj_q20f cj_q20g cj_q20h cj_q20i cj_q20j cj_q20k cj_q20l cj_q20m cj_q20n cj_q20o cj_q20p
	cj_q21a cj_q21b cj_q21c cj_q21d cj_q21e cj_q21f cj_q21g cj_q21h cj_q21i cj_q21j cj_q21k 
	cj_q37a cj_q37b cj_q37c cj_q37d {;
		replace `var'_norm=1-((`var'-1)/9); 
};
# delimit cr;


/*----------*/
/* 3. Labor */
/*----------*/
foreach var of varlist lb_q2a-lb_q4d lb_q6a-lb_q28b {
	gen `var'_norm=.
}

/* Cases */
replace lb_q8_norm=(lb_q8-1)/2

replace lb_q9_norm=0 if lb_q9==1 | lb_q9==4
replace lb_q9_norm=0.5 if lb_q9==2
replace lb_q9_norm=1 if lb_q9==3

replace lb_q22_norm=1-((lb_q22-1)/2)

/* Likert 3 Values: Positive */
# delimit;
foreach var of varlist 
	lb_q15a lb_q15b lb_q15c lb_q15d lb_q15e {;
	replace `var'_norm=(`var'-1)/2; 
};
# delimit cr;

/* Likert 3 Values: Negative */
# delimit;
foreach var of varlist 
	lb_q20a lb_q20b lb_q20c lb_q20d lb_q20e lb_q20f lb_q20g lb_q20h {;
	replace `var'_norm=1-((`var'-1)/2); 
};
# delimit cr;

/* Likert 4 Values: Positive */
# delimit;
foreach var of varlist 
	lb_q4a lb_q4b lb_q4c lb_q4d
	lb_q7
	lb_q14
	lb_q18a lb_q18b lb_q18c 
	lb_q19a lb_q19b lb_q19c lb_q19d
	lb_q21a lb_q21b lb_q21c lb_q21d lb_q21e lb_q21f lb_q21g lb_q21i lb_q21j
	lb_q23a lb_q23b lb_q23c lb_q23d lb_q23e lb_q23f lb_q23g
	lb_q24a lb_q24b lb_q24c lb_q24d lb_q24e lb_q24f lb_q24g lb_q24h
	lb_q25a lb_q25b lb_q25c lb_q25d lb_q25e lb_q25f lb_q25g lb_q25h lb_q25i 
	lb_q28a lb_q28b {;
		replace `var'_norm=(`var'-1)/3; 
};
# delimit cr;

/* Likert 4 Values: Negative */
# delimit;
foreach var of varlist 
	lb_q6a lb_q6b lb_q6c lb_q6d lb_q6e
	lb_q10a lb_q10b lb_q10c lb_q10d lb_q10e lb_q10f lb_q10g lb_q10h lb_q10i lb_q10j lb_q10k lb_q10l
	lb_q13a lb_q13b lb_q13c lb_q13d lb_q13e lb_q13f
	lb_q16a lb_q16b lb_q16c lb_q16d lb_q16e lb_q16f
	lb_q17a lb_q17b lb_q17c lb_q17d lb_q17e
	lb_q18d
	lb_q25j
	lb_q26a lb_q26b lb_q26c lb_q26d lb_q26e lb_q26f lb_q26g {;
		replace `var'_norm=1-((`var'-1)/3); 
};
# delimit cr;

/* Likert 5 Values: Positive */
# delimit;
foreach var of varlist 
	lb_q2a lb_q2b lb_q2c lb_q2d
	lb_q3a lb_q3b lb_q3c lb_q3d {;
		replace `var'_norm=(`var'-1)/4; 
};
# delimit cr;

/* Likert 6 Values: Positive */
# delimit;
foreach var of varlist 
	lb_q11a {;
		replace `var'_norm=1 if `var'==6;
		replace `var'_norm=0.75 if `var'==5;
		replace `var'_norm=0.5 if `var'==4;
		replace `var'_norm=0.25 if `var'==3;
		replace `var'_norm=0.05 if `var'==2;
		replace `var'_norm=0 if `var'==1; 
};
# delimit cr;

/* Likert 6 Values: Negative */
# delimit;
foreach var of varlist 
	lb_q11b
	lb_q12 {;
		replace `var'_norm=0 if `var'==6;
		replace `var'_norm=0.05 if `var'==5;
		replace `var'_norm=0.25 if `var'==4;
		replace `var'_norm=0.5 if `var'==3;
		replace `var'_norm=0.75 if `var'==2;
		replace `var'_norm=1 if `var'==1; 
};
# delimit cr;

/*------------------*/
/* 4. Public Health */
/*------------------*/
foreach var of varlist ph_q1a - ph_q14{
	gen `var'_norm=.
}

/* Cases */
replace ph_q2_norm=(ph_q2-1)/2
replace ph_q7_norm=1-((ph_q7-1)/2)

replace ph_q3_norm=1 if ph_q3==1
replace ph_q3_norm=0 if ph_q3==2 | ph_q3==3

/* Likert 4 Values: Positive */
# delimit;
foreach var of varlist 
	ph_q1a ph_q1b ph_q1c 
	ph_q4a ph_q4b ph_q4c
	ph_q9a ph_q9b ph_q9c 
	ph_q10a ph_q10b ph_q10c ph_q10d ph_q10e ph_q10f
	ph_q13
	ph_q14 {;
		replace `var'_norm=(`var'-1)/3; 
};
# delimit cr;

/* Likert 4 Values: Negative */
# delimit;
foreach var of varlist 
	ph_q1d
	ph_q6a ph_q6b ph_q6c ph_q6d ph_q6e ph_q6f ph_q6g
	ph_q8a ph_q8b ph_q8c ph_q8d ph_q8e ph_q8f ph_q8g
	ph_q9d
	ph_q11a ph_q11b ph_q11c
	ph_q12a ph_q12b ph_q12c ph_q12d ph_q12e {;
		replace `var'_norm=1-((`var'-1)/3); 
};
# delimit cr;

/* Likert 6 Values: Positive */
# delimit;
foreach var of varlist 
	ph_q5a {;
		replace `var'_norm=1 if `var'==6;
		replace `var'_norm=0.75 if `var'==5;
		replace `var'_norm=0.5 if `var'==4;
		replace `var'_norm=0.25 if `var'==3;
		replace `var'_norm=0.05 if `var'==2;
		replace `var'_norm=0 if `var'==1; 
};
# delimit cr;

/* Likert 6 Values: Negative */
# delimit;
foreach var of varlist 
	ph_q5b ph_q5c ph_q5d {;
		replace `var'_norm=0 if `var'==6;
		replace `var'_norm=0.05 if `var'==5;
		replace `var'_norm=0.25 if `var'==4;
		replace `var'_norm=0.5 if `var'==3;
		replace `var'_norm=0.75 if `var'==2;
		replace `var'_norm=1 if `var'==1; 
};
# delimit cr;


/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------*/
/* IV. Creating variables common in various questionnaires */
/*---------------------------------------------------------*/

gen all_q1=cc_q36h_norm if question=="cc"
replace all_q1=cj_q41h_norm if question=="cj"
replace all_q1=lb_q25j_norm if question=="lb"

gen all_q2=cc_q35a_norm if question=="cc"
replace all_q2=cj_q40a_norm if question=="cj"
replace all_q2=lb_q24a_norm if question=="lb"

gen all_q3=cc_q35d_norm if question=="cc"
replace all_q3=cj_q40d_norm if question=="cj"
replace all_q3=lb_q24d_norm if question=="lb"

gen all_q4=cc_q35b_norm if question=="cc"
replace all_q4=cj_q40b_norm if question=="cj"
replace all_q4=lb_q24b_norm if question=="lb"

gen all_q5=cc_q26k_norm if question=="cc"
replace all_q5=cj_q20m_norm if question=="cj"

gen all_q6=cc_q21_norm if question=="cc"
replace all_q6=lb_q12_norm if question=="lb"

gen all_q7=cc_q35c_norm if question=="cc"
replace all_q7=cj_q40c_norm if question=="cj"
replace all_q7=lb_q24c_norm if question=="lb"

gen all_q8=cc_q36d_norm if question=="cc"
replace all_q8=cj_q41d_norm if question=="cj"
replace all_q8=lb_q25d_norm if question=="lb"

gen all_q9=cc_q35e_norm if question=="cc"
replace all_q9=cj_q40e_norm if question=="cj"
replace all_q9=lb_q24e_norm if question=="lb"

gen all_q10=cc_q35f_norm if question=="cc"
replace all_q10=cj_q40f_norm if question=="cj"
replace all_q10=lb_q24f_norm if question=="lb"

gen all_q11=cj_q40g_norm if question=="cj"
replace all_q11=lb_q24g_norm if question=="lb"

gen all_q12=cc_q35g_norm if question=="cc"
replace all_q12=cj_q40h_norm if question=="cj"
replace all_q12=lb_q24h_norm if question=="lb"

gen all_q13=cj_q42a_norm if question=="cj"
replace all_q13=lb_q26a_norm if question=="lb"

gen all_q14=cc_q34e_norm if question=="cc"
replace all_q14=cj_q39e_norm if question=="cj"

gen all_q15=cc_q34h_norm if question=="cc"
replace all_q15=cj_q39h_norm if question=="cj"

gen all_q16=cc_q34i_norm if question=="cc"
replace all_q16=cj_q39i_norm if question=="cj"

gen all_q17=cj_q42b_norm if question=="cj"
replace all_q17=lb_q26b_norm if question=="lb"

gen all_q18=cc_q34j_norm if question=="cc"
replace all_q18=cj_q39j_norm if question=="cj"

gen all_q19=cc_q34a_norm if question=="cc"
replace all_q19=cj_q39a_norm if question=="cj"

gen all_q20=cc_q34k_norm if question=="cc"
replace all_q20=cj_q39k_norm if question=="cj"
replace all_q20=lb_q25h_norm if question=="lb"

gen all_q21=cc_q34l_norm if question=="cc"
replace all_q21=cj_q39l_norm if question=="cj"
replace all_q21=lb_q25i_norm if question=="lb"

gen all_q22=cc_q36a_norm if question=="cc"
replace all_q22=cj_q41a_norm if question=="cj"
replace all_q22=lb_q25a_norm if question=="lb"

gen all_q23=cc_q36f_norm if question=="cc"
replace all_q23=cj_q41f_norm if question=="cj"
replace all_q23=lb_q25f_norm if question=="lb"

gen all_q24=cc_q36b_norm if question=="cc"
replace all_q24=cj_q41b_norm if question=="cj"
replace all_q24=lb_q25b_norm if question=="lb"

gen all_q25=cc_q36c_norm if question=="cc"
replace all_q25=cj_q41c_norm if question=="cj"
replace all_q25=lb_q25c_norm if question=="lb"

gen all_q26=cc_q36e_norm if question=="cc"
replace all_q26=cj_q41e_norm if question=="cj"
replace all_q26=lb_q25e_norm if question=="lb"

gen all_q27=cc_q36g_norm if question=="cc"
replace all_q27=cj_q41g_norm if question=="cj"
replace all_q27=lb_q25g_norm if question=="lb"

gen all_q28=cc_q20b_norm if question=="cc"
replace all_q28=lb_q11b_norm if question=="lb"

gen all_q29=cc_q34f_norm if question=="cc"
replace all_q29=cj_q39f_norm if question=="cj"

gen all_q30=cc_q34g_norm if question=="cc"
replace all_q30=cj_q39g_norm if question=="cj"

gen all_q31=cc_q34c_norm if question=="cc"
replace all_q31=cj_q39c_norm if question=="cj"

gen all_q32=cc_q34d_norm if question=="cc"
replace all_q32=cj_q39d_norm if question=="cj"

gen all_q33=cc_q32a_norm if question=="cc"
replace all_q33=cj_q35a_norm if question=="cj"
replace all_q33=lb_q21a_norm if question=="lb"
replace all_q33=ph_q10a_norm if question=="ph"

gen all_q34=cc_q32b_norm if question=="cc"
replace all_q34=cj_q35c_norm if question=="cj"
replace all_q34=lb_q21b_norm if question=="lb"

gen all_q35=cc_q32c_norm if question=="cc"
replace all_q35=cj_q35b_norm if question=="cj"
replace all_q35=lb_q21c_norm if question=="lb"
replace all_q35=ph_q10b_norm if question=="ph"

gen all_q36=cc_q32d_norm if question=="cc"
replace all_q36=lb_q21d_norm if question=="lb"
replace all_q36=ph_q10c_norm if question=="ph"

gen all_q37=cc_q32e_norm if question=="cc"
replace all_q37=lb_q21f_norm if question=="lb"
replace all_q37=ph_q10e_norm if question=="ph"

gen all_q38=cc_q32f_norm if question=="cc"
replace all_q38=cj_q35d_norm if question=="cj"
replace all_q38=lb_q21g_norm if question=="lb"

gen all_q40=cc_q31a_norm if question=="cc"
replace all_q40=lb_q20a_norm if question=="lb"

gen all_q41=cc_q31b_norm if question=="cc"
replace all_q41=lb_q20b_norm if question=="lb"

gen all_q42=cc_q31c_norm if question=="cc"
replace all_q42=lb_q20c_norm if question=="lb"

gen all_q43=cc_q31d_norm if question=="cc"
replace all_q43=lb_q20d_norm if question=="lb"

gen all_q44=cc_q31e_norm if question=="cc"
replace all_q44=lb_q20e_norm if question=="lb"

gen all_q45=cc_q31f_norm if question=="cc"
replace all_q45=lb_q20f_norm if question=="lb"

gen all_q46=cc_q31g_norm if question=="cc"
replace all_q46=lb_q20g_norm if question=="lb"

gen all_q47=cc_q31h_norm if question=="cc"
replace all_q47=lb_q20h_norm if question=="lb"

gen all_q48=cc_q30a_norm if question=="cc"
replace all_q48=lb_q19b_norm if question=="lb"

gen all_q49=cc_q30b_norm if question=="cc"
replace all_q49=lb_q19c_norm if question=="lb"

gen all_q50=cc_q30c_norm if question=="cc"
replace all_q50=lb_q19d_norm if question=="lb"

gen all_q51=cc_q20a_norm if question=="cc"
replace all_q51=lb_q11a_norm if question=="lb"

gen all_q52=cc_q15_norm if question=="cc"
replace all_q52=ph_q2_norm if question=="ph"

gen all_q53=cc_q38_norm if question=="cc"
replace all_q53=lb_q8_norm if question=="lb"

gen all_q54=cc_q1_norm if question=="cc"
replace all_q54=ph_q3_norm if question=="ph"

gen all_q55=cc_q29d_norm if question=="cc"
replace all_q55=lb_q18d_norm if question=="lb"

gen all_q56=cc_q28f_norm if question=="cc"
replace all_q56=lb_q17d_norm if question=="lb"

gen all_q57=cc_q7a_norm if question=="cc"
replace all_q57=lb_q6a_norm if question=="lb"

gen all_q58=cc_q7b_norm if question=="cc"
replace all_q58=lb_q6b_norm if question=="lb"

gen all_q59=cc_q7c_norm if question=="cc"
replace all_q59=lb_q6d_norm if question=="lb"

gen all_q60=cc_q19j_norm if question=="cc"
replace all_q60=cj_q20k_norm if question=="cj"
replace all_q60=lb_q10j_norm if question=="lb"

gen all_q61=cc_q7d_norm if question=="cc"
replace all_q61=lb_q6e_norm if question=="lb"

gen all_q62=cc_q32k_norm if question=="cc"
replace all_q62=lb_q21i_norm if question=="lb"

gen all_q63=cc_q32l_norm if question=="cc"
replace all_q63=lb_q21j_norm if question=="lb"

gen all_q64=cc_q19l_norm if question=="cc"
replace all_q64=lb_q10l_norm if question=="lb"

gen all_q65=cc_q8_norm if question=="cc"
replace all_q65=lb_q7_norm if question=="lb"

gen all_q66=cc_q19b_norm if question=="cc"
replace all_q66=lb_q10b_norm if question=="lb"

gen all_q67=cc_q19c_norm if question=="cc"
replace all_q67=lb_q10c_norm if question=="lb"

gen all_q68=cc_q19d_norm if question=="cc"
replace all_q68=lb_q10d_norm if question=="lb"

gen all_q69=cc_q19e_norm if question=="cc"
replace all_q69=lb_q10e_norm if question=="lb"

gen all_q70=cc_q19f_norm if question=="cc"
replace all_q70=lb_q10f_norm if question=="lb"

gen all_q71=cc_q5a_norm if question=="cc"
replace all_q71=lb_q4a_norm if question=="lb"

gen all_q72=cc_q5b_norm if question=="cc"
replace all_q72=lb_q4b_norm if question=="lb"

gen all_q73=cc_q19a_norm if question=="cc"
replace all_q73=lb_q10a_norm if question=="lb"

gen all_q74=cc_q19i_norm if question=="cc"
replace all_q74=lb_q10i_norm if question=="lb"

gen all_q75=cc_q19k_norm if question=="cc"
replace all_q75=lb_q10k_norm if question=="lb"

gen all_q76=cc_q23a_norm if question=="cc"
replace all_q76=lb_q13a_norm if question=="lb"

gen all_q77=cc_q23b_norm if question=="cc"
replace all_q77=lb_q13b_norm if question=="lb"

gen all_q78=cc_q23c_norm if question=="cc"
replace all_q78=lb_q13c_norm if question=="lb"

gen all_q79=cc_q23d_norm if question=="cc"
replace all_q79=lb_q13d_norm if question=="lb"

gen all_q80=cc_q23e_norm if question=="cc"
replace all_q80=lb_q13e_norm if question=="lb"

gen all_q81=cc_q23f_norm if question=="cc"
replace all_q81=lb_q13f_norm if question=="lb"

gen all_q82=cc_q19h_norm if question=="cc"
replace all_q82=lb_q10h_norm if question=="lb"

gen all_q83=cc_q19j_norm if question=="cc"
replace all_q83=lb_q10j_norm if question=="lb"

gen all_q84=cc_q3a_norm if question=="cc"
replace all_q84=lb_q2a_norm if question=="lb"

gen all_q85=cc_q3b_norm if question=="cc"
replace all_q85=lb_q2b_norm if question=="lb"

gen all_q86=cc_q4a_norm if question=="cc"
replace all_q86=lb_q3a_norm if question=="lb"

gen all_q87=cc_q4b_norm if question=="cc"
replace all_q87=lb_q3b_norm if question=="lb"

gen all_q88=cc_q19g_norm if question=="cc"
replace all_q88=lb_q10g_norm if question=="lb"

gen all_q89=cc_q5c_norm if question=="cc"
replace all_q89=lb_q4c_norm if question=="lb"

gen all_q90=cc_q3c_norm if question=="cc"
replace all_q90=lb_q2c_norm if question=="lb"

gen all_q91=cc_q4c_norm if question=="cc"
replace all_q91=lb_q3c_norm if question=="lb"

gen all_q92=cc_q24_norm if question=="cc"
replace all_q92=lb_q14_norm if question=="lb"

gen all_q93=cc_q37a_norm if question=="cc"
replace all_q93=cj_q42e_norm if question=="cj"
replace all_q93=lb_q26c_norm if question=="lb"

gen all_q94=cc_q37b_norm if question=="cc"
replace all_q94=cj_q42f_norm if question=="cj"
replace all_q94=lb_q26d_norm if question=="lb"

gen all_q95=cc_q37c_norm if question=="cc"
replace all_q95=cj_q42g_norm if question=="cj"
replace all_q95=lb_q26e_norm if question=="lb"

gen all_q96=cc_q37d_norm if question=="cc"
replace all_q96=cj_q42h_norm if question=="cj"
replace all_q96=lb_q26f_norm if question=="lb"

gen all_q97=cc_q37e_norm if question=="cc"
replace all_q97=lb_q26g_norm if question=="lb"

gen all_q103=cc_q40a_norm if question=="cc"
replace all_q103=lb_q28a_norm if question=="lb"

gen all_q104=cc_q40b_norm if question=="cc"
replace all_q104=lb_q28b_norm if question=="lb"

gen all_q105=cc_q34b_norm if question=="cc"
replace all_q105=cj_q39b_norm if question=="cj"
replace all_q105=lb_q21e_norm if question=="lb"

foreach var of varlist all_q1- all_q105 {
	rename `var' `var'_norm
}

** Check scale of NORM variables for anything greater than 1 or less than 0
foreach var of varlist *_norm {
	list `var' if `var'>1 & `var'!=.
}

foreach var of varlist *_norm {
	list `var' if `var'<0 & `var'!=.
}

sort country question id_alex

drop if id_alex=="cc__0_."
drop if id_alex=="cj__0_."
drop if id_alex=="lb__0_."
drop if id_alex=="ph__0_."
drop if id_alex=="cc__1_."
drop if id_alex=="cj__1_."
drop if id_alex=="lb__1_."
drop if id_alex=="ph__1_."

save "$path2data/1. Original/qrq.dta", replace

/*----------------------------------------------*/
/* VI. Merging with 2022 data and previous years */
/*----------------------------------------------*/
/* Responded in 2022 */
clear
use "$path2data/1. Original/qrq_original_2022.dta"
rename (wjp_login wjp_password) (WJP_login WJP_password)
keep WJP_login
duplicates drop
sort WJP_login
save "$path2data/1. Original/qrq_2022_login.dta", replace

/* Responded longitudinal survey in 2023 */ 
clear
use "$path2data/1. Original/qrq.dta"
keep WJP_login
duplicates drop
sort WJP_login
save "$path2data/1. Original/qrq_login.dta", replace 

/* Only answered in 2022 (and not in 2023) (Login) */
clear
use "$path2data/1. Original/qrq_2022_login.dta"
merge 1:1 WJP_login using "$path2data/1. Original/qrq_login.dta"
keep if _merge==1
drop _merge
sort WJP_login
save "$path2data/1. Original/qrq_2022_login_unique.dta", replace 

/* Only answered in 2022 (and not in 2023) (Full data) */
clear
use "$path2data/1. Original/qrq_original_2022.dta"
rename (wjp_login wjp_password) (WJP_login WJP_password)
sort WJP_login
merge m:1 WJP_login using "$path2data/1. Original/qrq_2022_login_unique.dta"
replace _merge=3 if id_alex=="lb_English_1_268" // LB UAE expert that answered CC in 2023 but not LB (old LB answer from 2022)
replace _merge=3 if id_alex=="lb_English_1_28_2021" // LB Gambia expert that answered CC in 2023 but not LB (old LB answer from 2021)
keep if _merge==3
drop _merge
gen aux="2022"
egen id_alex_1=concat(id_alex aux), punct(_)
replace id_alex=id_alex_1
drop id_alex_1 aux
sort WJP_login
save "$path2data/1. Original/qrq_2022.dta", replace

erase "$path2data/1. Original/qrq_2022_login.dta"
erase "$path2data/1. Original/qrq_login.dta"
erase "$path2data/1. Original/qrq_2022_login_unique.dta"

/* Merging with 2022 data and older regular data*/
clear
use "$path2data/1. Original/qrq.dta"
append using "$path2data/1. Original/qrq_2022.dta"

*Dropping questions removed in 2023
drop cc_q2a-all_q102_norm

drop total_score total_n f_1* f_2* f_3* f_4* f_6* f_7* f_8* N total_score_mean total_score_sd outlier outlier_CO

*Observations are no longer longitudinal because the database we're appending only includes people that only answered in 2022 or before
tab year longitudinal
replace longitudinal=0 if year==2022
tab year longitudinal

/* Change names of countries according to new MAP (for the 2022 and older data) */

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

/*-----------*/
/* V. Checks */
/*-----------*/

/* 1.Averages */
egen total_score=rowmean(cc_q1_norm- ph_q14_norm)
drop if total_score==.

/* 2.Duplicates */

// Duplicates by login (can show duplicates for years and surveys. Ex: An expert that answered three qrq's one year)
duplicates tag WJP_login, generate(dup)
tab dup
br if dup>0

// Duplicates by login and score (shows duplicates of year and expert, that SHOULD be removed)
duplicates tag WJP_login total_score, generate(true_dup)
tab true_dup
br if true_dup>0

// Duplicates by id and year (Doesn't show the country)
duplicates tag id_alex, generate (dup_alex)
tab dup_alex
br if dup_alex>0

//Duplicates by id, year and score (Should be removed)
duplicates tag id_alex total_score, generate(true_dup_alex)
tab true_dup_alex
br if true_dup_alex>0

//Duplicates by login and questionnaire. They should be removed if the country and year are the same.
duplicates tag question WJP_login, generate(true_dup_question)
tab true_dup_question
br if true_dup_question>0

//Duplicates by login, questionnaire and year. They should be removed if the country and year are the same.
duplicates tag question WJP_login year, generate(true_dup_question_year)
tab true_dup_question_year
br if true_dup_question_year>0
count

//Check which years don't have a password
tab year if WJP_password!=.
tab year if WJP_password==.

//Duplicates by password and questionnaire. Some experts have changed their emails and our check with id_alex doesn't catch them. 
duplicates tag question country WJP_password, gen(dup_password)
tab dup_password
tab dup_password if WJP_password!=.

*Check the year and keep the most recent one
tab year if dup_password>0 & WJP_password!=.

sort WJP_password
br if dup_password>0 & WJP_password!=.

bys question country WJP_password: egen year_max=max(year) if dup_password>0 & dup_password!=. & WJP_password!=.
gen dup_mark=1 if year!=year_max & dup_password>0 & dup_password!=. & WJP_password!=.
drop if dup_mark==1

drop dup_password year_max dup_mark

tab year

//Duplicates by login (lowercases) and questionnaire. 
/*This check drops experts that have emails with uppercases and are included 
from two different years of the same questionnaire and country (consecutive years). We should remove the 
old responses that we are including as "regular" that we think are regular because of the 
upper and lower cases. */

gen WJP_login_lower=ustrlower(WJP_login)
duplicates tag question WJP_login_lower country, generate(true_dup_question_lower)
tab true_dup_question_lower

sort WJP_login_lower year
br if true_dup_question_lower>0

bys WJP_login_lower country question country: egen year_max=max(year) if true_dup_question_lower>0

gen dup_mark=1 if year!=year_max & true_dup_question_lower>0
drop if dup_mark==1

*Test it again
drop true_dup_question_lower
duplicates tag question WJP_login_lower country, generate(true_dup_question_lower)
tab true_dup_question_lower
sort WJP_login_lower year
br if true_dup_question_lower>0

drop dup true_dup dup_alex true_dup_alex true_dup_question true_dup_question_year WJP_login_lower year_max dup_mark true_dup_question_lower


/* 3. Drop questionnaires with very few observations */

egen total_n=rownonmiss(cc_q1_norm- ph_q14_norm)

*Total number of experts by country
bysort country: gen N=_N

*Number of questions per QRQ
*CC: 162
*CJ: 197
*LB: 134
*PH: 49

*Drops surveys with less than 25 nonmissing values. Erin cleaned empty suveys and surveys with low responses
*There are countries with low total_n because we removed the DN/NA at the beginning of the do file
br if total_n<=25
drop if total_n<=25 & N>=20

/* 4.Outliers */
bysort country: egen total_score_mean=mean(total_score)
bysort country: egen total_score_sd=sd(total_score)
gen outlier=0
replace outlier=1 if total_score>=(total_score_mean+2.5*total_score_sd) & total_score~=.
replace outlier=1 if total_score<=(total_score_mean-2.5*total_score_sd) & total_score~=.
bysort country: egen outlier_CO=max(outlier)

*Shows the number of experts of low count countries have and if the country has outliers
tab country outlier_CO if N<=20

*Shows the number of outlies per each low count country
tab country outlier if N<=20

drop if outlier==1 & N>20

sort country id_alex

/* 5. Factor scores */
egen f_1_2=rowmean(all_q1_norm all_q2_norm all_q20_norm all_q21_norm)
egen f_1_3=rowmean(all_q2_norm all_q3_norm cc_q25_norm all_q4_norm all_q5_norm all_q6_norm all_q7_norm all_q8_norm)
egen f_1_4=rowmean(cc_q33_norm all_q9_norm cj_q38_norm cj_q36c_norm cj_q8_norm)
egen f_1_5=rowmean(all_q52_norm all_q53_norm all_q93_norm all_q10_norm all_q11_norm all_q12_norm cj_q36b_norm cj_q36a_norm cj_q9_norm cj_q8_norm)
egen f_1_6=rowmean(all_q13_norm all_q14_norm all_q15_norm all_q16_norm all_q17_norm cj_q10_norm all_q18_norm all_q94_norm all_q19_norm all_q20_norm all_q21_norm)
egen f_1_7=rowmean(all_q23_norm all_q27_norm all_q22_norm all_q24_norm all_q25_norm all_q26_norm all_q8_norm)
egen f_1=rowmean(f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7)

egen f_2_1=rowmean(cc_q27_norm all_q97_norm ph_q5a_norm ph_q5b_norm ph_q7_norm cc_q28a_norm cc_q28b_norm cc_q28c_norm cc_q28d_norm all_q56_norm lb_q17e_norm lb_q17c_norm ph_q8d_norm lb_q17b_norm ph_q8a_norm ph_q8b_norm ph_q8c_norm ph_q8e_norm ph_q8f_norm ph_q8g_norm ph_q9d_norm ph_q11a_norm ph_q11b_norm ph_q11c_norm ph_q12a_norm ph_q12b_norm ph_q12c_norm ph_q12d_norm ph_q12e_norm all_q54_norm all_q55_norm all_q95_norm)
egen f_2_2=rowmean(all_q57_norm all_q58_norm all_q59_norm all_q60_norm cc_q26h_norm cc_q28e_norm lb_q6c_norm cj_q32b_norm all_q28_norm all_q6_norm)
egen f_2_3=rowmean(cj_q32c_norm cj_q32d_norm all_q61_norm cj_q31a_norm cj_q31b_norm cj_q34a_norm cj_q34b_norm cj_q34c_norm cj_q34d_norm cj_q34e_norm cj_q16j_norm cj_q18a_norm)
egen f_2_4=rowmean(all_q96_norm)
egen f_2=rowmean(f_2_1 f_2_2 f_2_3 f_2_4)

egen f_3_1=rowmean(all_q33_norm all_q34_norm all_q35_norm all_q36_norm all_q37_norm all_q38_norm cc_q32h_norm cc_q32i_norm)
egen f_3_2=rowmean(cc_q9b_norm cc_q39a_norm cc_q39b_norm cc_q39b_norm cc_q39c_norm cc_q39e_norm all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm)
egen f_3_3=rowmean(all_q13_norm all_q14_norm all_q15_norm all_q16_norm all_q17_norm cj_q10_norm all_q18_norm all_q94_norm all_q19_norm all_q20_norm all_q21_norm all_q19_norm all_q31_norm all_q32_norm all_q14_norm cc_q9a_norm cc_q11b_norm cc_q32j_norm all_q105_norm)
egen f_3_4=rowmean(cc_q9c_norm cc_q40a_norm cc_q40b_norm)
egen f_3=rowmean(f_3_1 f_3_2 f_3_3 f_3_4)

egen f_4_1=rowmean(all_q76_norm lb_q16a_norm ph_q6a_norm cj_q12a_norm all_q77_norm lb_q16b_norm ph_q6b_norm cj_q12b_norm all_q78_norm lb_q16c_norm ph_q6c_norm cj_q12c_norm all_q79_norm lb_q16d_norm ph_q6d_norm cj_q12d_norm all_q80_norm lb_q16e_norm ph_q6e_norm cj_q12e_norm all_q81_norm lb_q16f_norm ph_q6f_norm cj_q12f_norm)
egen f_4_2=rowmean(cj_q11a_norm cj_q11b_norm cj_q31e_norm cj_q42c_norm cj_q42d_norm cj_q10_norm)
egen f_4_3=rowmean(cj_q22d_norm cj_q22b_norm cj_q25a_norm cj_q31c_norm cj_q22e_norm cj_q6a_norm cj_q6b_norm cj_q6c_norm cj_q29a_norm cj_q29b_norm cj_q42c_norm cj_q42d_norm cj_q22a_norm cj_q1_norm cj_q2_norm cj_q11a_norm cj_q22c_norm cj_q3a_norm cj_q3b_norm cj_q3c_norm cj_q19b_norm cj_q19c_norm cj_q4_norm cj_q21a_norm cj_q21b_norm cj_q21c_norm cj_q21d_norm cj_q21f_norm)
egen f_4_4=rowmean(all_q13_norm all_q14_norm all_q15_norm all_q16_norm all_q17_norm cj_q10_norm all_q18_norm all_q94_norm all_q19_norm all_q20_norm all_q21_norm)
egen f_4_5=rowmean(all_q29_norm all_q30_norm)
egen f_4_6=rowmean(cj_q31f_norm cj_q31g_norm cj_q42c_norm cj_q42d_norm)
egen f_4_7=rowmean(all_q19_norm all_q31_norm all_q32_norm all_q14_norm)
egen f_4_8=rowmean(lb_q16a_norm lb_q16b_norm lb_q16c_norm lb_q16d_norm lb_q16e_norm lb_q16f_norm lb_q23a_norm lb_q23b_norm lb_q23c_norm lb_q23d_norm lb_q23e_norm lb_q23f_norm lb_q23g_norm)
egen f_4=rowmean(f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8)

egen f_6_1=rowmean(lb_q8_norm lb_q9_norm lb_q22_norm lb_q15a_norm lb_q15b_norm lb_q15c_norm lb_q15d_norm lb_q15e_norm lb_q18a_norm lb_q18b_norm lb_q18c_norm cc_q1_norm cc_q29a_norm cc_q29b_norm cc_q29c_norm ph_q3_norm ph_q4a_norm ph_q4b_norm ph_q4c_norm ph_q9a_norm ph_q9b_norm ph_q9c_norm)
egen f_6_2=rowmean(all_q54_norm all_q55_norm cc_q28a_norm cc_q28b_norm cc_q28c_norm cc_q28d_norm all_q56_norm lb_q17e_norm lb_q17c_norm ph_q8d_norm lb_q17b_norm ph_q8a_norm ph_q8b_norm ph_q8c_norm ph_q8e_norm ph_q8f_norm ph_q8g_norm ph_q9d_norm ph_q11a_norm ph_q11b_norm ph_q11c_norm ph_q12a_norm ph_q12b_norm ph_q12c_norm ph_q12d_norm ph_q12e_norm)
egen f_6_3=rowmean(lb_q2d_norm lb_q3d_norm all_q62_norm all_q63_norm)
egen f_6_4=rowmean(all_q48_norm all_q49_norm all_q50_norm lb_q19a_norm)
egen f_6_5=rowmean(cc_q10_norm cc_q11a_norm cc_q16a_norm cc_q14a_norm cc_q14b_norm cc_q16b_norm cc_q16c_norm cc_q16d_norm cc_q16e_norm cc_q16f_norm cc_q16g_norm)
egen f_6=rowmean(f_6_1 f_6_2 f_6_3 f_6_4 f_6_5)

egen f_7_1=rowmean(all_q92_norm cj_q26_norm all_q75_norm all_q65_norm cc_q22a_norm cc_q22b_norm cc_q22c_norm cc_q12_norm all_q74_norm all_q75_norm all_q69_norm all_q70_norm all_q71_norm all_q72_norm)
egen f_7_2=rowmean(all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm)
egen f_7_3=rowmean(all_q57_norm all_q58_norm all_q59_norm all_q83_norm cc_q26h_norm cc_q28e_norm lb_q6c_norm all_q51_norm all_q28_norm)
egen f_7_4=rowmean(all_q6_norm cc_q11a_norm all_q3_norm all_q4_norm all_q7_norm)
egen f_7_5=rowmean(all_q84_norm all_q85_norm cc_q13_norm all_q88_norm cc_q26a_norm)
egen f_7_6=rowmean(cc_q26b_norm all_q86_norm all_q87_norm)
egen f_7_7=rowmean(all_q89_norm all_q59_norm all_q90_norm all_q91_norm cc_q14a_norm cc_q14b_norm)
egen f_7=rowmean(f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7)

egen f_8_1=rowmean(cj_q16a_norm cj_q16b_norm cj_q16c_norm cj_q16e_norm cj_q16f_norm cj_q16g_norm cj_q16h_norm cj_q16i_norm cj_q16j_norm cj_q18a_norm cj_q18d_norm cj_q25a_norm)
egen f_8_2=rowmean(cj_q27a_norm cj_q27b_norm cj_q7a_norm cj_q7b_norm cj_q7c_norm cj_q20a_norm cj_q20b_norm cj_q20e_norm)
egen f_8_3=rowmean(cj_q21a_norm cj_q21e_norm cj_q21g_norm cj_q21h_norm cj_q28_norm)
egen f_8_4=rowmean(cj_q12a_norm cj_q12b_norm cj_q12c_norm cj_q12d_norm cj_q12e_norm cj_q12f_norm cj_q20o_norm)
egen f_8_5=rowmean(cj_q32c_norm cj_q32d_norm cj_q31a_norm cj_q31b_norm cj_q34a_norm cj_q34b_norm cj_q34c_norm cj_q34d_norm cj_q34e_norm cj_q16j_norm cj_q18a_norm cj_q18d_norm cj_q32b_norm cj_q20k_norm)
egen f_8_6=rowmean(cj_q40b_norm cj_q40c_norm cj_q20m_norm)
egen f_8_7=rowmean(cj_q22d_norm cj_q22b_norm cj_q25a_norm cj_q31c_norm cj_q22e_norm cj_q6a_norm cj_q6b_norm cj_q6c_norm cj_q29a_norm cj_q29b_norm cj_q42c_norm cj_q42d_norm cj_q22a_norm cj_q1_norm cj_q2_norm cj_q11a_norm cj_q22c_norm cj_q3a_norm cj_q3b_norm cj_q3c_norm cj_q19b_norm cj_q19c_norm cj_q4_norm cj_q21a_norm cj_q21b_norm cj_q21c_norm cj_q21d_norm cj_q21f_norm)

egen f_8=rowmean(f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7)


*----- Saving original dataset BEFORE adjustments

save "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Data Analytics\8. Data\QRQ\QRQ_2023_raw.dta", replace

/* Adjustments */

sort country question year total_score

replace cj_q24b_norm=. if id_alex=="cj_English_1_254" //Afghanistan
replace cj_q24c_norm=. if id_alex=="cj_English_1_254" //Afghanistan
replace cj_q24b_norm=. if id_alex=="cj_English_0_266" //Afghanistan	 
replace cj_q24c_norm=. if id_alex=="cj_English_0_266" //Afghanistan
replace cc_q26b_norm=. if id_alex=="cc_English_1_587" //Afghanistan
replace cc_q26b_norm=. if id_alex=="cc_English_1_565" //Afghanistan
replace all_q89_norm=. if all_q89_norm==1 & country=="Afghanistan" //Afghanistan
replace cc_q14a_norm=. if cc_q14a_norm==1 & country=="Afghanistan" //Afghanistan
replace all_q86_norm=. if all_q86_norm==1 & country=="Afghanistan" //Afghanistan
replace all_q87_norm=. if all_q87_norm==1 & country=="Afghanistan" //Afghanistan
replace all_q84_norm=. if country=="Afghanistan" //Afghanistan
replace all_q87_norm=. if country=="Afghanistan" //Afghanistan
replace all_q57_norm=. if all_q57_norm==1 & country=="Afghanistan" //Afghanistan
replace cc_q28e_norm=. if country=="Afghanistan" //Afghanistan
replace lb_q6c_norm=. if country=="Afghanistan" //Afghanistan
drop if id_alex=="cc_English_1_616" //Afghanistan
drop if id_alex=="cj_English_0_266" //Afghanistan
replace cc_q33_norm=. if id_alex=="cc_English_1_587" //Afghanistan
replace cc_q33_norm=. if id_alex=="cc_English_1_565" //Afghanistan
replace cj_q38_norm=. if id_alex=="cj_English_0_810_2016_2017_2018_2019_2021_2022" //Afghanistan
replace cj_q38_norm=. if id_alex=="cj_English_1_503_2016_2017_2018_2019_2021_2022" //Afghanistan
replace cj_q38_norm=. if id_alex=="cj_English_0_227_2017_2018_2019_2021_2022" //Afghanistan
replace cc_q33_norm=0 if id_alex=="cc_English_1_202_2017_2018_2019_2021_2022" //Afghanistan
replace all_q96_norm=0 if id_alex=="cj_English_0_691" //Afghanistan
replace all_q96_norm=0 if id_alex=="cc_French_1_1324_2022" //Afghanistan
replace cc_q40a_norm=. if id_alex=="cc_English_1_202_2017_2018_2019_2021_2022" //Afghanistan
replace cc_q40b_norm=0 if id_alex=="cc_English_1_202_2017_2018_2019_2021_2022" //Afghanistan
replace all_q29_norm=0 if id_alex=="cj_English_1_385" //Afghanistan
replace all_q29_norm=0 if id_alex=="cj_English_0_1024" //Afghanistan
replace all_q62_norm=0 if id_alex=="lb_English_0_398_2017_2018_2019_2021_2022" //Afghanistan
replace all_q63_norm=0 if id_alex=="lb_English_0_398_2017_2018_2019_2021_2022" //Afghanistan
replace cc_q27_norm=. if id_alex=="cc_English_1_565" //Afghanistan
replace all_q97_norm=. if id_alex=="lb_English_1_311" //Afghanistan
replace lb_q17c_norm=. if id_alex=="lb_English_1_311" //Afghanistan
replace lb_q17b_norm=. if id_alex=="lb_English_1_311" //Afghanistan
replace ph_q11c_norm=. if id_alex=="ph_English_1_261" //Afghanistan
replace all_q96_norm=. if id_alex=="cj_English_0_691" //Afghanistan
replace cc_q28a_norm=. if id_alex=="cc_English_1_587" //Afghanistan
replace cc_q28c_norm=. if id_alex=="cc_French_1_1324_2022" //Afghanistan
replace cc_q28d_norm=. if id_alex=="cc_French_1_1324_2022" //Afghanistan
replace ph_q9d_norm=. if country=="Afghanistan" //Afghanistan
replace ph_q11b_norm=. if country=="Afghanistan" //Afghanistan
replace cc_q26h_norm=. if id_alex=="cc_English_1_587"  //Afghanistan
replace cj_q33b_norm=. if id_alex=="cj_English_1_470" //Afghanistan
replace cj_q33c_norm=. if cj_q33c_norm==1 & country=="Afghanistan" //Afghanistan
replace all_q55_norm=. if id_alex=="lb_English_1_311" //Afghanistan
replace ph_q8c_norm=. if id_alex=="ph_English_1_126" //Afghanistan
replace ph_q8e_norm=. if id_alex=="ph_English_1_261" //Afghanistan
replace ph_q8g_norm=. if id_alex=="ph_English_1_261" //Afghanistan
replace ph_q12b_norm=. if id_alex=="ph_English_1_261" //Afghanistan
replace all_q61_norm=. if all_q61_norm==1 & country=="Afghanistan" //Afghanistan
drop if id_alex=="lb_English_0_359" //Albania
drop if id_alex=="lb_English_0_358" //Albania
replace cj_q28_norm=. if cj_q28_norm==.75 & country=="Albania" //Albania
drop if id_alex=="cj_English_0_406" //Albania 
drop if id_alex=="ph_French_0_167" //Albania 
replace all_q85_norm=. if all_q85_norm==0 & country=="Albania" //Albania
foreach v in all_q84_norm all_q85_norm cc_q13_norm all_q88_norm cc_q26a_norm {
replace `v'=. if id_alex=="cc_English_1_165_2022" //Albania
replace `v'=. if id_alex=="cc_English_0_1234_2022" //Albania
replace `v'=. if id_alex=="lb_English_1_107_2022" //Albania
}
drop if id_alex=="cj_English_0_717" //Albania X
drop if id_alex=="cc_English_1_161_2017_2018_2019_2021_2022" //Albania X
replace cc_q25_norm=. if id_alex=="cc_English_1_416_2021_2022" //Albania X
replace cc_q25_norm=. if id_alex=="cc_English_1_843_2022" //Albania X
replace all_q2_norm=. if id_alex=="cj_English_1_1124_2019_2021_2022" //Albania X
replace all_q10_norm=. if id_alex=="lb_English_0_70" //Albania X
replace all_q12_norm=. if id_alex=="lb_English_0_70" //Albania X
replace cc_q26h_norm=. if id_alex=="cc_English_0_130" //Albania X
replace cc_q39a_norm=. if id_alex=="cc_English_0_119" //Albania X
replace cc_q39e_norm=. if id_alex=="cc_English_0_130" //Albania X
replace cc_q9c_norm=. if id_alex=="cc_English_0_824_2022" //Albania X
replace cc_q9c_norm=. if id_alex=="cc_English_0_119" //Albania X
replace ph_q6b_norm=.3333333 if id_alex=="ph_English_1_364" //Albania X
replace ph_q6e_norm=.3333333 if id_alex=="ph_English_1_364" //Albania X
replace cj_q12c_norm=.3333333 if id_alex=="cj_English_0_105" //Albania X
replace cj_q31f_norm=. if id_alex=="cj_English_1_1147_2019_2021_2022" //Albania X
replace lb_q2d_norm=. if id_alex=="lb_English_0_604" //Albania X
replace all_q80_norm=. if id_alex=="cc_English_1_165_2022" //Albania X
replace all_q79_norm=. if id_alex=="cc_English_1_533_2021_2022" //Albania X
replace all_q80_norm=. if id_alex=="cc_English_1_165_2022" //Albania X
replace all_q57_norm=. if id_alex=="cc_English_1_416_2021_2022" //Albania X
replace cj_q7a_norm=. if id_alex=="cj_English_0_105" //Albania X
replace cj_q7a_norm=. if id_alex=="cj_English_1_338" //Albania X
replace cj_q20e_norm=. if id_alex=="cj_English_0_105" //Albania X
replace all_q2_norm=. if id_alex=="lb_English_0_566_2016_2017_2018_2019_2021_2022" //Albania X
replace all_q2_norm=0 if id_alex=="lb_English_0_375_2017_2018_2019_2021_2022" //Albania X
replace all_q26_norm=. if id_alex=="lb_English_0_566_2016_2017_2018_2019_2021_2022" //Albania X
replace all_q26_norm=. if id_alex=="lb_English_0_375_2017_2018_2019_2021_2022" //Albania X
replace all_q26_norm=. if id_alex=="cc_English_0_720_2021_2022" //Albania X
replace cc_q40b_norm=. if id_alex=="cc_English_1_416_2021_2022" //Albania X
replace cj_q12f_norm=. if id_alex=="cj_English_0_298_2019_2021_2022" //Albania X
replace cc_q11a_norm=. if id_alex=="cc_English_0_1076_2016_2017_2018_2019_2021_2022" //Albania X
replace cj_q7b_norm=. if id_alex=="cj_English_1_673_2016_2017_2018_2019_2021_2022" //Albania X
replace cj_q7b_norm=. if id_alex=="cj_English_1_631" //Albania X
replace cj_q27a_norm=. if id_alex=="cj_English_0_1026_2017_2018_2019_2021_2022" //Albania X
replace cj_q27a_norm=. if id_alex=="cj_English_1_1124_2019_2021_2022" //Albania X
replace cj_q20e_norm=. if id_alex=="cj_English_1_338" //Albania X
replace cc_q40a_norm=. if cc_q40a_norm==1 & country=="Algeria" //Algeria
replace cc_q40b_norm=. if cc_q40b_norm==1 & country=="Algeria" //Algeria
replace all_q87_norm=. if country=="Algeria" //Algeria
drop if id_alex=="lb_French_0_188_2018_2019_2021_2022" //Algeria
drop if id_alex=="ph_French_1_606_2022" //Algeria
replace lb_q3d_norm=. if country=="Algeria" //Algeria
replace lb_q2d_norm=. if id_alex=="lb_French_0_409" //Algeria
replace all_q89_norm=. if id_alex=="cc_English_0_915_2019_2021_2022" //Algeria
replace all_q90_norm=. if id_alex=="cc_English_0_915_2019_2021_2022" //Algeria 
replace all_q59_norm=. if id_alex=="lb_French_0_409" //Algeria
drop if id_alex=="lb_English_0_334" //Algeria X
replace all_q11_norm=. if id_alex=="cj_French_0_596_2018_2019_2021_2022" //Algeria X
replace all_q12_norm=. if id_alex=="cc_French_0_255_2018_2019_2021_2022" //Algeria X
replace cj_q36b_norm=. if id_alex=="cj_English_0_56_2021_2022" //Algeria X
replace all_q25_norm=. if id_alex=="cj_French_0_785_2019_2021_2022" //Algeria X
replace cc_q33_norm=. if id_alex=="cc_French_1_1402_2022" //Algeria X
replace cj_q8_norm=. if id_alex=="cj_French_0_596_2018_2019_2021_2022" //Algeria X
replace cj_q38_norm=. if id_alex=="cj_French_0_596_2018_2019_2021_2022" //Algeria X
replace all_q26_norm=. if id_alex=="cc_French_0_539_2019_2021_2022" //Algeria X
replace all_q8_norm=. if id_alex=="cc_French_0_539_2019_2021_2022" //Algeria X
drop if id_alex=="cj_Portuguese_0_196_2018_2019_2021_2022" //Angola
drop if id_alex=="cc_Portuguese_1_1324_2019_2021_2022" //Angola
replace cc_q10_norm=. if id_alex=="cc_Portuguese_0_1178" //Angola
drop if id_alex=="cj_Portuguese_0_95_2018_2019_2021_2022" //Angola
replace cc_q33_norm=. if id_alex=="cc_Portuguese_0_864_2021_2022" //Angola X
replace cc_q28c_norm=. if id_alex=="cc_Portuguese_0_864_2021_2022" //Angola X
replace cc_q27_norm=. if id_alex=="cc_Portuguese_0_864_2021_2022" //Angola X
replace all_q96_norm=. if id_alex=="cc_Portuguese_0_864_2021_2022" //Angola X
replace all_q96_norm=. if id_alex=="lb_Portuguese_0_222_2022" //Angola X
replace cc_q39b_norm=. if id_alex=="cc_Portuguese_0_1428_2021_2022" //Angola X
replace cc_q39c_norm=. if id_alex=="cc_Portuguese_0_1428_2021_2022" //Angola X
replace cc_q39e_norm=. if id_alex=="cc_Portuguese_0_1428_2021_2022" //Angola X
replace lb_q18b_norm=. if id_alex=="lb_Portuguese_0_74" //Angola X
replace lb_q18c_norm=. if id_alex=="lb_Portuguese_0_74" //Angola X
replace cc_q14a_norm=. if id_alex=="cc_Portuguese_0_1178" //Angola X
replace cc_q14b_norm=. if id_alex=="cc_Portuguese_0_1178" //Angola X
replace cc_q16g_norm=. if id_alex=="cc_Portuguese_0_735_2019_2021_2022" //Angola X
replace all_q69_norm=. if id_alex=="cc_English_0_434" //Angola X
replace all_q76_norm=. if id_alex=="cc_Portuguese_0_457_2021_2022" //Angola X
replace all_q76_norm=. if id_alex=="lb_Portuguese_1_289_2019_2021_2022" //Angola X
replace all_q82_norm=. if id_alex=="lb_Portuguese_1_289_2019_2021_2022" //Angola X
replace all_q87_norm=. if id_alex=="lb_Portuguese_1_698_2021_2022" //Angola X
replace all_q86_norm=. if id_alex=="lb_Portuguese_1_289_2019_2021_2022" //Angola X
replace all_q86_norm=. if id_alex=="lb_Portuguese_0_617_2021_2022" //Angola X
replace cj_q21e_norm=. if id_alex=="cj_Portuguese_0_68_2022" //Angola X
replace cj_q21g_norm=. if id_alex=="cj_Portuguese_0_486" //Angola X
replace cj_q3b_norm=. if id_alex=="cj_English_0_527_2018_2019_2021_2022" //Angola X
replace cj_q3c_norm=. if id_alex=="cj_English_0_527_2018_2019_2021_2022" //Angola X
replace cj_q6c_norm=. if id_alex=="cj_English_0_527_2018_2019_2021_2022" //Angola X
replace cc_q10_norm=0.333333333 if id_alex=="cc_Portuguese_0_864_2021_2022" //Angola X
replace cc_q16g_norm=. if id_alex=="cc_Portuguese_0_864_2021_2022" //Angola X
replace cc_q39c_norm=. if id_alex=="cc_Portuguese_0_735_2019_2021_2022" //Angola X
replace cc_q39e_norm=. if id_alex=="cc_Portuguese_0_735_2019_2021_2022" //Angola X
replace all_q33_norm=. if id_alex=="lb_Portuguese_0_222_2022" //Angola X
replace cj_q38_norm=. if country=="Antigua and Barbuda" //Antigua and Barbuda
replace cj_q10_norm=. if country=="Antigua and Barbuda" //Antigua and Barbuda
replace cj_q20e_norm=. if id_alex=="cj_English_0_700_2016_2017_2018_2019_2021_2022" //Antigua and Barbuda
replace cj_q21a_norm=. if country=="Antigua and Barbuda" //Antigua and Barbuda
replace cj_q21e_norm=. if country=="Antigua and Barbuda" //Antigua and Barbuda
replace cj_q20o_norm=. if id_alex=="cj_English_0_700_2016_2017_2018_2019_2021_2022" //Antigua and Barbuda
replace cj_q11b_norm=. if id_alex=="cj_English_0_700_2016_2017_2018_2019_2021_2022" //Antigua and Barbuda X
replace all_q30_norm=. if id_alex=="cc_English_1_444_2018_2019_2021_2022" //Antigua and Barbuda X
drop if id_alex=="cj_Spanish_0_318" //Argentina X
drop if id_alex=="cc_English_0_245_2018_2019_2021_2022" //Australia
replace cc_q9c_norm=. if id_alex=="cc_English_0_1173_2016_2017_2018_2019_2021_2022" //Australia
replace cc_q9c_norm=. if id_alex=="cc_English_0_598_2017_2018_2019_2021_2022" //Australia
replace cc_q9c_norm=. if id_alex=="cc_English_1_589_2017_2018_2019_2021_2022" //Australia
replace all_q89_norm=. if id_alex=="cc_English_0_368" //Austria X
replace all_q90_norm=. if id_alex=="cc_English_0_368" //Austria X
replace all_q90_norm=. if id_alex=="cc_English_0_934_2018_2019_2021_2022" //Austria X
replace all_q86_norm=. if id_alex=="lb_English_0_743_2019_2021_2022" //Austria X
replace cj_q11a_norm=. if id_alex=="cj_English_1_817"
replace cj_q31e_norm=. if id_alex=="cj_English_1_222" //Bahamas
replace cj_q42c_norm=. if country=="Bahamas" //Bahamas
replace cj_q42d_norm=. if country=="Bahamas" //Bahamas
replace cj_q20e_norm=. if id_alex=="cj_English_1_222" //Bahamas
replace cj_q21e_norm=. if id_alex=="cj_English_1_222" //Bahamas
replace cj_q21g_norm=. if id_alex=="cj_English_1_222" //Bahamas
drop if id_alex=="cc_English_0_136_2017_2018_2019_2021_2022" //Bahamas
drop if id_alex=="cc_English_1_132" //Bangladesh
drop if id_alex=="cj_English_1_594" //Bangladesh
replace cj_q11a_norm=. if id_alex=="cj_English_0_890" //Bangladesh
replace cj_q11b_norm=. if id_alex=="cj_English_0_890" //Bangladesh
replace cj_q31e_norm=. if id_alex=="cj_English_0_890" //Bangladesh
drop if id_alex=="cc_English_0_749" //Bangladesh X
drop if id_alex=="cj_English_0_890" //Bangladesh X
replace cj_q11b_norm=. if id_alex=="cj_English_0_176_2016_2017_2018_2019_2021_2022" //Bangladesh
replace cj_q11b_norm=. if id_alex=="cj_English_0_201_2016_2017_2018_2019_2021_2022" //Bangladesh
replace cj_q10_norm=. if id_alex=="cj_English_1_880_2016_2017_2018_2019_2021_2022" //Bangladesh
drop if id_alex=="cc_English_1_245_2019_2021_2022" //Bangladesh
drop if id_alex=="cj_English_1_880_2016_2017_2018_2019_2021_2022" //Bangladesh
drop if id_alex=="lb_English_1_353" //Bangladesh
drop if id_alex=="cc_English_1_168_2017_2018_2019_2021_2022" //Barbados
replace all_q62_norm=. if id_alex=="cc_English_0_949" //Barbados X
replace all_q63_norm=. if id_alex=="cc_English_0_949" //Barbados X
replace cj_q28_norm=. if id_alex=="cj_English_0_1128_2022" //Barbados X
replace all_q76_norm=. if id_alex=="cc_English_0_300_2019_2021_2022" //Barbados X
replace all_q77_norm=. if id_alex=="cc_English_0_949" //Barbados X
replace all_q78_norm=. if id_alex=="cc_English_0_949" //Barbados X
replace all_q79_norm=. if id_alex=="cc_English_0_949" //Barbados X
replace all_q80_norm=. if id_alex=="cc_English_0_949" //Barbados X
replace all_q1_norm=. if id_alex=="cc_English_0_505" //Barbados X
replace all_q2_norm=. if id_alex=="cc_English_0_775" //Barbados X
replace cc_q40a_norm=. if id_alex=="cc_English_1_377_2021_2022" //Barbados X
replace cc_q40b_norm=. if id_alex=="cc_English_1_377_2021_2022" //Barbados X
replace all_q42_norm=. if id_alex=="cc_English_1_614_2022" //Barbados X
replace all_q42_norm=. if id_alex=="cc_English_1_631_2022" //Barbados X
replace lb_q16a_norm=. if id_alex=="lb_English_1_749_2021_2022" //Barbados X
replace lb_q16b_norm=. if id_alex=="lb_English_1_749_2021_2022" //Barbados X
replace lb_q16c_norm=. if id_alex=="lb_English_1_749_2021_2022" //Barbados X
replace lb_q16d_norm=. if id_alex=="lb_English_1_749_2021_2022" //Barbados X
replace lb_q16e_norm=. if id_alex=="lb_English_1_749_2021_2022" //Barbados X
replace lb_q16f_norm=. if id_alex=="lb_English_1_749_2021_2022" //Barbados X
replace cc_q40a_norm=. if id_alex=="cc_English_0_589" //Barbados X
replace cc_q40b_norm=. if id_alex=="cc_English_0_589" //Barbados X
replace cj_q31f_norm=. if id_alex=="cj_English_1_962_2018_2019_2021_2022" //Barbados X
replace all_q88_norm=. if id_alex=="cc_English_1_377_2021_2022" //Barbados X
replace all_q88_norm=. if id_alex=="cc_English_0_274_2021_2022" //Barbados X
replace cj_q22c_norm=. if id_alex=="cj_English_1_962_2018_2019_2021_2022" //Barbados X
replace cj_q22c_norm=. if id_alex=="cj_English_0_692_2019_2021_2022" //Barbados X
replace cj_q3a_norm=. if id_alex=="cj_English_0_107_2016_2017_2018_2019_2021_2022" //Barbados X
replace all_q75_norm=. if id_alex=="cc_English_1_1303_2017_2018_2019_2021_2022" //Barbados X
replace all_q75_norm=. if id_alex=="cc_English_1_631_2022" //Barbados X
replace all_q85_norm=. if id_alex=="cc_English_0_826" //Barbados X
replace cj_q12a_norm=. if id_alex=="cj_English_1_962_2018_2019_2021_2022" //Barbados X
replace all_q50_norm=. if id_alex=="lb_English_1_749_2021_2022" //Barbados X
drop if id_alex=="cc_Russian_1_701" //Belarus
drop if id_alex=="cj_Russian_1_474" //Belarus
replace all_q84_norm=. if country=="Belarus" //Belarus
replace all_q85_norm=. if country=="Belarus" //Belarus
replace cc_q26a_norm=. if country=="Belarus" //Belarus
replace cj_q20o_norm=. if id_alex=="cj_Russian_1_904_2021_2022" //Belarus
replace cj_q12c_norm=. if id_alex=="cj_Russian_1_99_2019_2021_2022" //Belarus
replace cj_q12d_norm=. if id_alex=="cj_Russian_1_312" //Belarus
replace cj_q8_norm=. if id_alex=="cj_English_0_731" //Belize
replace all_q87_norm=. if country=="Belize" //Belize
replace cj_q21h_norm=. if country=="Belize" //Belize
drop if id_alex=="cj_English_1_852" //Belize
replace cj_q15_norm=. if country=="Belize" //Belize
replace cj_q31e_norm=0.6666667 if id_alex=="cj_English_1_652_2021_2022" //Belize X
replace cj_q42d_norm=. if id_alex=="cj_English_1_404_2022" //Belize X
replace lb_q23a_norm=0.6666667 if id_alex=="lb_English_0_594" //Belize X
replace lb_q23b_norm=0.6666667 if id_alex=="lb_English_0_594" //Belize X
replace lb_q23c_norm=0.6666667 if id_alex=="lb_English_0_594" //Belize X
replace lb_q23d_norm=0.6666667 if id_alex=="lb_English_0_594" //Belize X
replace lb_q23e_norm=0.6666667 if id_alex=="lb_English_0_594" //Belize X
replace lb_q23f_norm=0.6666667 if id_alex=="lb_English_0_594" //Belize X
replace lb_q23g_norm=0.6666667 if id_alex=="lb_English_0_594" //Belize X
replace all_q90_norm=. if id_alex=="cc_English_0_1339_2014_2016_2017_2018_2019_2021_2022" //Belize X
replace all_q90_norm=. if id_alex=="cc_English_0_1508_2018_2019_2021_2022" //Belize X
replace cc_q14b_norm=. if id_alex=="cc_English_1_71" //Belize X
replace cj_q20o_norm=. if id_alex=="cj_English_0_731" //Belize X
replace cj_q12f_norm=. if id_alex=="cj_English_1_652_2021_2022" //Belize X
replace all_q86_norm=. if id_alex=="cc_English_0_128_2014_2016_2017_2018_2019_2021_2022" //Belize X
replace all_q86_norm=. if id_alex=="cc_English_0_201" //Belize X
replace cc_q9c_norm=. if id_alex=="cc_English_0_1339_2014_2016_2017_2018_2019_2021_2022" //Belize X
drop if id_alex=="lb_English_0_417" //Belgium X
drop if id_alex=="cc_French_0_356" //Belgium X
replace all_q78_norm=. if id_alex=="cc_English_0_801_2022" //Belgium X
replace all_q79_norm=. if id_alex=="cc_French_0_676_2021_2022" //Belgium X
replace all_q89_norm=. if id_alex=="cc_English_0_1023" //Belgium X
replace all_q59_norm=. if id_alex=="cc_French_0_676_2021_2022" //Belgium X
drop if id_alex=="cc_French_1_865" //Benin
drop if id_alex=="lb_French_0_688" //Benin
drop if id_alex=="ph_French_0_473" //Benin
drop if id_alex=="cc_French_0_1227" //Benin
drop if id_alex=="lb_French_0_375" //Benin
replace cj_q8_norm=. if country=="Benin" //Benin
replace cc_q33_norm=. if id_alex=="cc_French_0_294" //Benin
replace all_q90_norm=. if country=="Benin" //Benin
replace cc_q26b_norm=. if id_alex=="cc_French_0_299_2019_2021_2022" //Benin
drop if id_alex=="cc_French_0_294" //Benin X
drop if id_alex=="ph_French_0_46" //Benin X
drop if id_alex=="lb_French_0_240_2022" //Benin X
replace cc_q11a_norm=0.333333333 if id_alex=="cc_French_1_1193_2022" //Benin
drop if id_alex=="ph_French_0_257" //BeninX
drop if id_alex=="cc_English_1_720_2021_2022" //BeninX
replace cc_q40a_norm=. if id_alex=="cc_French_1_1193_2022" //Benin X
replace cc_q40b_norm=. if id_alex=="cc_French_1_1193_2022" //Benin X
replace lb_q19a_norm=. if country=="Benin" //Benin X
replace all_q48_norm=. if id_alex=="lb_English_0_209_2021_2022" //Benin X
replace all_q49_norm=. if id_alex=="lb_English_0_209_2021_2022" //Benin X
replace all_q48_norm=. if id_alex=="lb_French_0_264_2022" //Benin X
replace all_q49_norm=. if id_alex=="lb_French_0_264_2022" //Benin X
replace all_q78_norm=0.66666666 if id_alex=="lb_French_0_264_2022" //Benin X
replace all_q78_norm=0.66666666 if id_alex=="lb_French_1_461_2022" //Benin X
replace cc_q26b_norm=. if id_alex=="cc_French_1_994_2019_2021_2022" //Benin X
replace cc_q26b_norm=. if id_alex=="cc_French_0_160_2021_2022" //Benin X
replace all_q54_norm=. if id_alex=="ph_French_0_611_2018_2019_2021_2022" //Benin X
replace all_q54_norm=. if id_alex=="ph_French_0_464_2018_2019_2021_2022" //Benin X
replace all_q54_norm=. if id_alex=="ph_French_0_328_2018_2019_2021_2022" //Benin X
replace all_q54_norm=. if id_alex=="ph_French_0_598_2018_2019_2021_2022" //Benin X
replace all_q54_norm=. if id_alex=="ph_French_0_170_2018_2019_2021_2022" //Benin X
replace all_q55_norm=. if id_alex=="cc_French_0_160_2021_2022" //Benin X
replace cc_q9c_norm=. if id_alex=="cc_English_1_1600_2021_2022" //Benin X
replace cc_q40a_norm=. if id_alex=="cc_French_0_160_2021_2022" //Benin X
replace cc_q39c_norm=. if id_alex=="cc_French_0_1567_2019_2021_2022" //Benin X
replace all_q33_norm=. if id_alex=="ph_French_0_598_2018_2019_2021_2022" //Benin X
replace all_q33_norm=. if id_alex=="ph_French_0_170_2018_2019_2021_2022" //Benin X
replace all_q33_norm=. if id_alex=="ph_French_1_749_2019_2021_2022" //Benin X
foreach var of varlist cj_q11a_norm cj_q11b_norm cj_q31e_norm cj_q42c_norm cj_q42d_norm cj_q10_norm cj_q31f_norm cj_q31g_norm {
replace `var'=. if id_alex=="cj_Spanish_0_466" //Bolivia
}
replace cj_q6c_norm=. if id_alex=="cj_Spanish_1_591_2017_2018_2019_2021_2022" //Bolivia 
replace cj_q42c_norm=. if id_alex=="cj_Spanish_1_591_2017_2018_2019_2021_2022" //Bolivia
replace cj_q42d_norm=. if id_alex=="cj_Spanish_1_591_2017_2018_2019_2021_2022" //Bolivia
replace lb_q3d_norm=. if id_alex=="lb_French_0_489" //Bolivia
replace all_q62_norm=. if id_alex=="lb_French_0_489" //Bolivia X
replace all_q63_norm=. if id_alex=="lb_French_0_489" //Bolivia X
replace cj_q42c_norm=. if id_alex=="cj_English_0_478" //Bolivia X
replace cj_q42d_norm=. if id_alex=="cj_English_0_478" //Bolivia X
replace cj_q42d_norm=. if id_alex=="cj_Spanish_0_146" //Bolivia X
replace cj_q42c_norm=. if id_alex=="cj_Spanish_0_146" //Bolivia X
drop if id_alex=="cc_Spanish_0_1731_2022" //Bolivia
drop if id_alex=="cj_Spanish_1_53_2022" //Bolivia
replace all_q2_norm=. if all_q2_norm==1 & country=="Bolivia" //Bolivia
replace all_q3_norm=. if id_alex=="cj_Spanish_0_462" //Bolivia
replace cc_q25_norm=. if cc_q25_norm==1 & country=="Bolivia" //Bolivia
replace all_q9_norm=. if all_q9_norm==1 & country=="Bolivia" //Bolivia
replace cj_q36c_norm=. if cj_q36c_norm==1 & country=="Bolivia" //Bolivia
drop if id_alex=="cj_Spanish_1_183_2019_2021_2022" //Bolivia  
replace cc_q33_norm=. if id_alex=="cc_Spanish_0_835_2016_2017_2018_2019_2021_2022" //Bolivia
replace cj_q38_norm=. if id_alex=="cj_Spanish_0_85" //Bolivia
replace cj_q36c_norm=. if id_alex=="cj_Spanish_0_85" //Bolivia
replace cj_q36c_norm=. if id_alex=="cj_English_0_287_2016_2017_2018_2019_2021_2022" //Bolivia
replace cj_q36c_norm=. if id_alex=="cj_Spanish_1_591_2017_2018_2019_2021_2022" //Bolivia
replace cj_q36b_norm=. if cj_q36b_norm==1 & country=="Bolivia" //Bolivia
replace cj_q36a_norm=. if cj_q36a_norm==1 & country=="Bolivia" //Bolivia
replace cj_q10_norm=. if id_alex=="cj_English_0_287_2016_2017_2018_2019_2021_2022" //Bolivia
replace cj_q15_norm=. if id_alex=="cj_English_0_478" //Bolivia
replace cj_q15_norm=. if id_alex=="cj_Spanish_1_133" //Bolivia
replace cj_q15_norm=. if id_alex=="cj_Spanish_0_410" //Bolivia
foreach var of varlist lb_q2d_norm lb_q3d_norm all_q59_norm {
replace `var'=. if country=="Bosnia and Herzegovina" //Bosnia and Herzegovina
}
replace lb_q16d_norm=. if id_alex=="lb_English_0_457_2018_2019_2021_2022" //Bosnia and Herzegovina
replace lb_q16b_norm=. if id_alex=="lb_English_0_457_2018_2019_2021_2022" //Bosnia and Herzegovina
replace lb_q16e_norm=. if id_alex=="lb_English_0_457_2018_2019_2021_2022" //Bosnia and Herzegovina X
replace cj_q15_norm=0.6666667 if id_alex=="cj_English_1_599_2021_2022" //Bosnia and Herzegovina X
drop if id_alex=="cj_English_1_161" //Botswana X
replace all_q1_norm=. if id_alex=="cc_English_0_1739_2022" //Botswana X
replace all_q1_norm=. if id_alex=="cc_English_0_316" //Botswana X
replace cc_q33_norm=. if id_alex=="cc_English_0_260_2013_2014_2016_2017_2018_2019_2021_2022" //Botswana X
replace all_q8_norm=. if id_alex=="cc_English_0_260_2013_2014_2016_2017_2018_2019_2021_2022" //Botswana X
replace cc_q9a_norm=. if id_alex=="cc_English_0_1192" //Botswana X
replace cj_q42c_norm=. if id_alex=="cj_English_0_749" //Botswana X
replace cj_q31g_norm=. if id_alex=="cj_English_1_716_2016_2017_2018_2019_2021_2022" //Botswana X
replace cj_q31g_norm=. if id_alex=="cj_English_0_886_2017_2018_2019_2021_2022" //Botswana X
replace cj_q25a_norm=. if id_alex=="cj_English_0_749" //Botswana X
replace cj_q25b_norm=. if id_alex=="cj_English_0_749" //Botswana X
replace cj_q25c_norm=. if id_alex=="cj_English_0_749" //Botswana X
replace cj_q16l_norm=. if id_alex=="cj_English_0_1005" //Botswana X
replace cj_q20m_norm=. if id_alex=="cj_English_0_611_2019_2021_2022" //Botswana X
replace cj_q20m_norm=. if id_alex=="cj_English_0_544_2021_2022" //Botswana X
replace cj_q21h_norm=. if id_alex=="cj_English_0_611_2019_2021_2022" //Botswana X
replace lb_q16b_norm=. if id_alex=="lb_English_0_270_2016_2017_2018_2019_2021_2022" //Botswana X
replace all_q29_norm=. if id_alex=="cc_English_1_1192_2022" //Botswana X
replace all_q30_norm=. if id_alex=="cc_English_1_1192_2022" //Botswana X
replace all_q29_norm=. if id_alex=="cc_English_1_1270_2022" //Botswana X
replace all_q30_norm=. if id_alex=="cc_English_1_1270_2022" //Botswana X
replace all_q29_norm=. if id_alex=="cj_English_0_749" //Botswana X
replace all_q30_norm=. if id_alex=="cj_English_0_749" //Botswana X
replace cj_q6d_norm=. if id_alex=="cj_English_0_886_2017_2018_2019_2021_2022" //Botswana X
replace cc_q16f_norm=. if id_alex=="cc_English_0_1013_2021_2022" //Botswana X
replace cc_q9c_norm=. if id_alex=="cc_English_0_316" //Botswana X
replace cc_q9c_norm=. if id_alex=="cc_English_0_731" //Botswana X
replace cc_q9c_norm=. if id_alex=="cc_English_0_668_2016_2017_2018_2019_2021_2022" //Botswana X
replace cc_q40a_norm=. if id_alex=="cc_English_0_316" //Botswana X
replace cj_q31g_norm=. if id_alex=="cj_English_0_544_2021_2022" //Botswana X
replace cc_q14a_norm=. if id_alex=="cc_English_0_1165" //Botswana X
replace cj_q15_norm=. if id_alex=="cj_English_0_611_2019_2021_2022" //Botswana X
replace cc_q16a_norm=. if id_alex=="cc_English_0_731" //Botswana X
replace cc_q16e_norm=. if id_alex=="cc_English_0_203" //Botswana X
replace cc_q40a_norm=. if country=="Brazil" //Brazil
drop if id_alex=="cj_Portuguese_1_273_2021_2022" //Brazil
drop if id_alex=="cj_Portuguese_0_474_2022" //Brazil
foreach v in cj_q40b_norm cj_q40c_norm {
replace `v'=. if id_alex=="cj_Portuguese_1_536" //Brazil
replace `v'=. if id_alex=="cj_Portuguese_1_665_2019_2021_2022" //Brazil
replace `v'=. if id_alex=="cj_English_0_1204_2018_2019_2021_2022" //Brazil
replace `v'=. if id_alex=="cj_Portuguese_1_790" //Brazil
}
drop if id_alex=="cj_Portuguese_1_1100_2022" //Brazil
replace all_q22_norm=. if id_alex=="cc_Portuguese_0_979_2018_2019_2021_2022" //Brazil X
replace all_q23_norm=. if id_alex=="cc_Portuguese_0_979_2018_2019_2021_2022" //Brazil X
replace all_q24_norm=. if id_alex=="cc_Portuguese_0_979_2018_2019_2021_2022" //Brazil X
replace all_q25_norm=. if id_alex=="cc_Portuguese_0_979_2018_2019_2021_2022" //Brazil X
replace all_q26_norm=. if id_alex=="cc_Portuguese_0_979_2018_2019_2021_2022" //Brazil X
replace all_q27_norm=. if id_alex=="cc_Portuguese_0_979_2018_2019_2021_2022" //Brazil X
replace all_q8_norm=. if id_alex=="cc_Portuguese_0_979_2018_2019_2021_2022" //Brazil X
replace all_q22_norm=. if id_alex=="cj_English_1_171_2016_2017_2018_2019_2021_2022" //Brazil X
replace all_q23_norm=. if id_alex=="cj_English_1_171_2016_2017_2018_2019_2021_2022" //Brazil X
replace all_q24_norm=. if id_alex=="cj_English_1_171_2016_2017_2018_2019_2021_2022" //Brazil X
replace all_q25_norm=. if id_alex=="cj_English_1_171_2016_2017_2018_2019_2021_2022" //Brazil X
replace all_q26_norm=. if id_alex=="cj_English_1_171_2016_2017_2018_2019_2021_2022" //Brazil X
replace all_q27_norm=. if id_alex=="cj_English_1_171_2016_2017_2018_2019_2021_2022" //Brazil X
replace all_q8_norm=. if id_alex=="cj_English_1_171_2016_2017_2018_2019_2021_2022" //Brazil X
replace all_q22_norm=. if id_alex=="cc_Portuguese_1_177" //Brazil X
replace all_q23_norm=. if id_alex=="cc_Portuguese_1_177" //Brazil X
replace all_q24_norm=. if id_alex=="cc_Portuguese_1_177" //Brazil X
replace all_q25_norm=. if id_alex=="cc_Portuguese_1_177" //Brazil X
replace all_q26_norm=. if id_alex=="cc_Portuguese_1_177" //Brazil X
replace all_q27_norm=. if id_alex=="cc_Portuguese_1_177" //Brazil X
replace all_q8_norm=. if id_alex=="cc_Portuguese_1_177" //Brazil X
replace all_q96_norm=. if id_alex=="cc_English_0_984_2016_2017_2018_2019_2021_2022" //Brazil X
replace all_q96_norm=. if id_alex=="cc_English_1_980_2016_2017_2018_2019_2021_2022" //Brazil X
replace all_q96_norm=. if id_alex=="cc_English_0_654_2017_2018_2019_2021_2022" //Brazil X
replace all_q96_norm=. if id_alex=="lb_English_1_581_2019_2021_2022" //Brazil X
replace all_q96_norm=. if id_alex=="lb_Portuguese_1_112_2019_2021_2022" //Brazil X
replace all_q96_norm=. if id_alex=="cj_Portuguese_0_313_2019_2021_2022" //Brazil X
replace all_q96_norm=. if id_alex=="cc_Portuguese_0_979_2018_2019_2021_2022" //Brazil X
replace all_q96_norm=. if id_alex=="cc_Portuguese_0_776_2019_2021_2022" //Brazil X
replace all_q19_norm=. if id_alex=="cc_English_0_984_2016_2017_2018_2019_2021_2022" //Brazil X
replace all_q19_norm=. if id_alex=="cc_English_0_1658_2017_2018_2019_2021_2022" //Brazil X
replace all_q19_norm=. if id_alex=="cc_English_1_980_2016_2017_2018_2019_2021_2022" //Brazil X
replace all_q19_norm=. if id_alex=="cc_English_1_604_2017_2018_2019_2021_2022" //Brazil X
replace all_q19_norm=. if id_alex=="cc_Portuguese_1_1044_2022" //Brazil X
replace all_q19_norm=. if id_alex=="cc_Portuguese_1_119_2022" //Brazil X
replace all_q31_norm=. if id_alex=="cc_English_0_984_2016_2017_2018_2019_2021_2022" //Brazil X
replace all_q31_norm=. if id_alex=="cc_English_1_980_2016_2017_2018_2019_2021_2022" //Brazil X
replace all_q31_norm=. if id_alex=="cc_English_1_604_2017_2018_2019_2021_2022" //Brazil X
replace all_q31_norm=. if id_alex=="cc_English_0_1658_2017_2018_2019_2021_2022" //Brazil X
replace all_q31_norm=. if id_alex=="cc_Portuguese_1_1044_2022" //Brazil X
replace all_q31_norm=. if id_alex=="cc_Portuguese_1_119_2022" //Brazil X
replace cj_q42c_norm=. if id_alex=="cj_English_0_622" //Bulgaria X
replace cj_q42d_norm=. if id_alex=="cj_English_0_622" //Bulgaria X
replace cj_q11b_norm=. if country=="Burkina Faso" //Burkina Faso
replace cj_q31f_norm=. if id_alex=="cj_French_0_124" //Burkina Faso
replace cj_q31g_norm=. if id_alex=="cj_French_0_124" //Burkina Faso
drop if id_alex=="lb_French_1_290" //Burkina Faso
replace lb_q19a_norm=. if id_alex=="lb_French_0_136" //Burkina Faso
drop if id_alex=="cj_French_0_124" //Burkina Faso
drop if id_alex=="cc_French_0_70" //Burkina Faso
drop if id_alex=="cj_French_0_965" //Burkina Faso
drop if id_alex=="cc_French_1_988_2018_2019_2021_2022" //Burkina Faso X
drop if id_alex=="cj_French_0_187"  //Burkina Faso X
drop if id_alex=="lb_French_0_136"  //Burkina Faso X
drop if id_alex=="cc_French_0_1063_2017_2018_2019_2021_2022" //Burkina Faso X
drop if id_alex=="ph_French_0_269_2018_2019_2021_2022" //Burkina Faso X
replace all_q96_norm=. if id_alex=="cc_French_0_1266" //Burkina Faso X
replace all_q96_norm=. if id_alex=="cj_French_0_48_2019_2021_2022" //Burkina Faso X
replace all_q96_norm=. if id_alex=="lb_French_0_426_2018_2019_2021_2022" //Burkina Faso X
replace all_q96_norm=0 if id_alex=="cc_French_0_220_2016_2017_2018_2019_2021_2022" //Burkina Faso X
replace cj_q42d_norm=. if id_alex=="cj_French_0_238_2018_2019_2021_2022" //Burkina Faso X
replace cj_q31f_norm=. if id_alex=="cj_French_0_238_2018_2019_2021_2022" //Burkina Faso X
replace lb_q19a_norm=. if id_alex=="lb_French_0_481_2014_2016_2017_2018_2019_2021_2022" //Burkina Faso X
replace lb_q19a_norm=. if id_alex=="lb_French_0_526_2016_2017_2018_2019_2021_2022" //Burkina Faso X
replace all_q84_norm=. if id_alex=="cc_French_0_1631_2017_2018_2019_2021_2022" //Burkina Faso X
replace cc_q13_norm=. if id_alex=="cc_French_0_1631_2017_2018_2019_2021_2022" //Burkina Faso X
replace all_q84_norm=. if id_alex=="cc_French_0_1674_2018_2019_2021_2022" //Burkina Faso X
replace cc_q13_norm=. if id_alex=="cc_French_0_1674_2018_2019_2021_2022" //Burkina Faso X
replace all_q65_norm=. if id_alex=="lb_French_0_526_2016_2017_2018_2019_2021_2022" //Burkina Faso X
replace all_q59_norm=. if id_alex=="cc_French_0_1631_2017_2018_2019_2021_2022" //Burkina Faso X
replace cc_q14a_norm=. if id_alex=="cc_French_0_1631_2017_2018_2019_2021_2022" //Burkina Faso X
replace all_q59_norm=. if id_alex=="cc_French_0_907_2018_2019_2021_2022" //Burkina Faso X
replace cc_q14a_norm=. if id_alex=="cc_French_0_907_2018_2019_2021_2022" //Burkina Faso X
replace cc_q10_norm=. if id_alex=="cc_French_1_1126" //Burkina Faso X
replace cc_q16a_norm=. if id_alex=="cc_French_1_1126" //Burkina Faso X
replace cc_q11a_norm=. if id_alex=="cc_English_0_1371_2019_2021_2022" //Burkina Faso X
replace cc_q16a_norm=. if id_alex=="cc_French_0_220_2016_2017_2018_2019_2021_2022" //Burkina Faso X
replace lb_q19a_norm=.3333333 if id_alex=="lb_French_0_481_2014_2016_2017_2018_2019_2021_2022" //Burkina Faso X
replace all_q48_norm=. if id_alex=="cc_French_1_1126" //Burkina Faso X
replace all_q49_norm=. if id_alex=="cc_French_1_1126" //Burkina Faso X
replace all_q50_norm=. if id_alex=="cc_French_1_1126" //Burkina Faso X
drop if id_alex=="lb_English_1_490_2016_2017_2018_2019_2021_2022" //Cambodia
drop if id_alex=="cj_English_0_736" //Cambodia X
replace all_q24_norm=. if id_alex=="cj_English_1_863_2017_2018_2019_2021_2022" //Cambodia X
replace all_q24_norm=. if id_alex=="lb_English_0_200_2018_2019_2021_2022" //Cambodia X
replace all_q96_norm=. if id_alex=="cj_English_0_119" //Cambodia X
replace all_q96_norm=. if id_alex=="cj_English_0_736" //Cambodia X
replace cj_q28_norm=. if id_alex=="cj_English_0_56" //Cambodia X
replace cj_q28_norm=. if id_alex=="cj_English_0_231_2017_2018_2019_2021_2022" //Cambodia X
replace ph_q6b_norm=. if country=="Cameroon" /*Cameroon*/
replace ph_q6d_norm=. if country=="Cameroon" /*Cameroon*/
replace ph_q6e_norm=. if country=="Cameroon" /*Cameroon*/
replace ph_q5a_norm=. if country=="Cameroon" /*Cameroon*/
replace cc_q27_norm=. if country=="Cameroon" /*Cameroon*/
replace ph_q8d_norm=. if id_alex=="ph_French_1_327" //Cameroon
drop if id_alex=="cj_English_1_786" //Cameroon X
replace all_q80_norm=. if country=="Canada" //Canada
replace cj_q15_norm=1 if id_alex=="cj_English_0_619" //Canada X
replace cj_q15_norm=. if id_alex=="cj_English_1_856_2017_2018_2019_2021_2022" //Canada X
replace lb_q2d_norm=. if id_alex=="lb_English_0_387" //Canada X
replace all_q89_norm=. if id_alex=="lb_French_0_440_2019_2021_2022" //Canada X
replace all_q48_norm=. if id_alex=="cc_French_1_251_2016_2017_2018_2019_2021_2022" //Canada X
replace all_q48_norm=. if id_alex=="lb_French_0_301_2016_2017_2018_2019_2021_2022" //Canada X
replace all_q48_norm=. if id_alex=="cc_English_0_1092_2016_2017_2018_2019_2021_2022" //Canada X
replace cj_q40b_norm=. if id_alex=="cj_English_0_1024_2021_2022" //Canada X
replace lb_q19a_norm=. if id_alex=="lb_French_0_301_2016_2017_2018_2019_2021_2022" //Canada X
drop if id_alex=="cc_Spanish_1_1219" //Chile
replace cj_q8_norm=. if id_alex=="cj_Spanish_0_252_2016_2017_2018_2019_2021_2022" //Chile X
replace cj_q8_norm=. if id_alex=="cj_Spanish_0_383_2016_2017_2018_2019_2021_2022" //Chile X
replace all_q9_norm=. if id_alex=="cc_Spanish_1_284_2016_2017_2018_2019_2021_2022" //Chile X
replace all_q9_norm=. if id_alex=="cc_Spanish_0_707_2016_2017_2018_2019_2021_2022" //Chile X
replace lb_q19a_norm=. if id_alex=="lb_Spanish_0_752_2018_2019_2021_2022" //Chile X
replace all_q49_norm=. if id_alex=="lb_Spanish_0_109_2016_2017_2018_2019_2021_2022" //Chile X
replace all_q49_norm=. if id_alex=="cc_English_1_259_2017_2018_2019_2021_2022" //Chile X
drop if id_alex=="cj_English_0_150" //China
drop if id_alex=="cc_English_0_608" //China
drop if id_alex=="lb_English_0_656" //China
drop if id_alex=="cc_English_1_371" //China
drop if id_alex=="cc_English_0_409" //China
drop if id_alex=="cc_English_1_661" //China
replace cc_q33_norm=. if country=="China" //China
replace cj_q10_norm=. if country=="China" //China
replace cj_q15_norm=. if id_alex=="cj_English_1_318" //China
replace cj_q36c_norm=. if country=="China" //China
replace all_q84_norm=. if id_alex=="cc_English_0_495" //China
replace all_q84_norm=. if id_alex=="lb_English_1_227" //China
replace cj_q20o_norm=. if id_alex=="cj_English_0_905" //China
replace cj_q19c_norm=. if id_alex=="cj_English_0_375_2013_2014_2016_2017_2018_2019_2021_2022" //China
replace all_q74_norm=. if id_alex=="cc_English_0_1921_2018_2019_2021_2022" //China
replace all_q71_norm=. if id_alex=="cc_English_0_1384_2016_2017_2018_2019_2021_2022" //China
replace all_q71_norm=. if id_alex=="cc_Spanish_0_127_2021_2022" //China
replace all_q85_norm=. if id_alex=="cc_English_0_495" //China
replace lb_q6c_norm=. if id_alex=="lb_English_0_632_2022" //China
replace all_q28_norm=. if id_alex=="lb_English_0_542" //China
replace cj_q21h_norm=. if id_alex=="cj_English_1_714_2022" //China X
replace cj_q40c_norm=. if id_alex=="cj_English_0_375_2013_2014_2016_2017_2018_2019_2021_2022" //China X
replace cj_q21a_norm=0.1111111 if id_alex=="cj_English_0_905" //China X
replace cj_q21b_norm=0.1111111 if id_alex=="cj_English_0_905" //China X
replace cj_q21c_norm=0.1111111 if id_alex=="cj_English_0_905" //China X
replace cj_q21d_norm=0.1111111 if id_alex=="cj_English_0_905" //China X
replace cj_q21f_norm=0.1111111 if id_alex=="cj_English_0_905" //China X
replace all_q79_norm=. if id_alex=="cc_English_1_1271_2022" //China X
replace all_q79_norm=. if id_alex=="lb_English_0_342_2018_2019_2021_2022" //China X
replace lb_q6c_norm=.3333333 if id_alex=="lb_English_0_342_2018_2019_2021_2022" //China X
replace cc_q28e_norm=. if id_alex=="cc_English_0_495" //China X
replace cc_q26a_norm=. if id_alex=="cc_English_0_1384_2016_2017_2018_2019_2021_2022" //China X
replace lb_q2d_norm=. if id_alex=="lb_English_0_186" //Colombia
drop if id_alex=="lb_English_1_710" //Colombia X
drop if id_alex=="cc_French_1_1328" //Congo, Dem. Rep.
drop if id_alex=="lb_English_0_518" //Congo, Dem. Rep.
drop if id_alex=="ph_French_0_620_2019_2021_2022" //Congo, Dem. Rep.
drop if id_alex=="ph_French_1_110" //Congo, Dem. Rep.
replace lb_q2d_norm=. if id_alex=="lb_French_0_80" //Congo, Dem. Rep. X
replace lb_q3d_norm=. if id_alex=="lb_French_0_125_2021_2022" //Congo, Dem. Rep. X
replace cc_q10_norm=. if id_alex=="cc_French_1_769" //Congo, Dem. Rep. X
replace cc_q11a_norm=. if id_alex=="cc_French_1_769" //Congo, Dem. Rep. X
replace cc_q16a_norm=. if id_alex=="cc_French_1_769" //Congo, Dem. Rep. X
replace cc_q16c_norm=. if id_alex=="cc_French_0_913" //Congo, Dem. Rep. X
replace cc_q16d_norm=. if id_alex=="cc_French_0_913" //Congo, Dem. Rep. X
replace cc_q16e_norm=. if id_alex=="cc_French_0_913" //Congo, Dem. Rep. X
replace cc_q16f_norm=. if id_alex=="cc_French_0_913" //Congo, Dem. Rep. X
replace all_q77_norm=. if id_alex=="cc_French_0_1193_2018_2019_2021_2022" //Congo, Dem. Rep. X
replace all_q80_norm=. if id_alex=="cc_French_0_340_2018_2019_2021_2022" //Congo, Dem. Rep. X
replace cc_q16c_norm=. if id_alex=="cc_French_0_1193_2018_2019_2021_2022" //Congo, Dem. Rep. X
replace cc_q16d_norm=. if id_alex=="cc_French_0_1193_2018_2019_2021_2022" //Congo, Dem. Rep. X
drop if id_alex=="ph_English_1_601" //Congo, Rep.
replace cj_q40b_norm=. if id_alex=="cj_French_0_312" //Congo, Rep.
replace cj_q40c_norm=. if id_alex=="cj_French_0_312" //Congo, Rep.
replace cj_q21h_norm=. if id_alex=="cj_French_0_312" //Congo, Rep.
replace cj_q36b_norm=. if id_alex=="cj_French_0_312" //Congo, Rep. X
replace cj_q33a_norm=. if id_alex=="cj_English_1_1073" //Congo, Rep. X
replace cj_q33b_norm=. if id_alex=="cj_English_1_1073" //Congo, Rep. X
replace cj_q33c_norm=. if id_alex=="cj_English_1_1073" //Congo, Rep. X
replace cj_q34d_norm=. if id_alex=="cj_English_1_1073" //Congo, Rep. X
replace cj_q10_norm=. if id_alex=="cj_French_0_312" //Congo, Rep. X
replace lb_q16b_norm=. if id_alex=="lb_French_0_578" //Congo, Rep. X
replace lb_q16e_norm=. if id_alex=="lb_French_0_578" //Congo, Rep. X
replace lb_q16f_norm=. if id_alex=="lb_French_0_578" //Congo, Rep. X
replace lb_q19a_norm=. if id_alex=="lb_French_0_578" //Congo, Rep. X
replace lb_q2d_norm=. if id_alex=="lb_French_0_652" //Congo, Rep. X
replace cc_q40a_norm=. if id_alex=="cc_French_1_1071" //Congo, Rep. X
replace cj_q20o_norm=. if id_alex=="cj_English_0_241_2022" //Congo, Rep. X
replace all_q21_norm=. if id_alex=="cj_French_0_312" //Congo, Rep. X
replace cj_q36c_norm=. if id_alex=="cj_French_0_312" //Congo, Rep. X
replace cj_q36a_norm=. if id_alex=="cj_French_0_312" //Congo, Rep. X
replace cj_q9_norm=. if id_alex=="cj_French_0_312" //Congo, Rep. X
replace cj_q8_norm=. if id_alex=="cj_French_0_312" //Congo, Rep. X
replace cj_q10_norm=. if id_alex=="cj_French_0_312" //Congo, Rep. X
replace all_q52_norm=. if id_alex=="cc_French_0_963_2021_2022" //Congo, Rep. X
replace all_q10_norm=. if id_alex=="cj_French_0_312" //Congo, Rep. X
replace all_q11_norm=. if id_alex=="cj_French_0_312" //Congo, Rep. X
replace all_q12_norm=. if id_alex=="cj_French_0_312" //Congo, Rep. X
replace cj_q32d_norm=. if country=="Costa Rica" //Costa Rica 
replace ph_q9d_norm=. if id_alex=="ph_Spanish_0_110" //Costa Rica X
replace ph_q9d_norm=. if id_alex=="ph_Spanish_0_110" //Costa Rica X
replace ph_q12c_norm=. if id_alex=="ph_Spanish_0_647_2018_2019_2021_2022" //Costa Rica X
replace lb_q2d_norm=. if id_alex=="lb_Spanish_1_368" //Costa Rica X
replace all_q58_norm=. if id_alex=="cc_Spanish_1_360" //Costa Rica X
replace all_q59_norm=. if id_alex=="cc_Spanish_1_360" //Costa Rica X
replace all_q60_norm=. if id_alex=="cc_Spanish_1_360" //Costa Rica X
replace cc_q26b_norm=. if id_alex=="cc_English_0_1984_2018_2019_2021_2022" //Costa Rica X
replace cc_q26b_norm=. if id_alex=="cc_es-mx_0_1308_2018_2019_2021_2022" //Costa Rica X
replace all_q86_norm=. if id_alex=="cc_Spanish_1_826_2021_2022" //Costa Rica X
replace all_q89_norm=. if id_alex=="cc_English_0_1571_2018_2019_2021_2022" //Costa Rica X
replace all_q89_norm=. if id_alex=="cc_es-mx_0_1308_2018_2019_2021_2022" //Costa Rica X
replace cj_q15_norm=0.3333333 if id_alex=="cj_Spanish_0_198_2022" //Costa Rica X
replace cj_q11a_norm=. if id_alex=="cj_French_0_815_2016_2017_2018_2019_2021_2022" //Cote d'Ivoire
replace cj_q31e_norm=. if id_alex=="cj_French_0_595" //Cote d'Ivoire
replace cj_q20o_norm=. if id_alex=="cj_French_0_1012" //Cote d'Ivoire
replace cj_q20o_norm=. if id_alex=="cj_French_0_595" //Cote d'Ivoire
drop if id_alex=="cc_French_1_1417_2021_2022" //Cote d'Ivoire
replace all_q13_norm=. if id_alex=="cj_French_1_609_2016_2017_2018_2019_2021_2022" //Cote d'Ivoire X
replace all_q17_norm=. if id_alex=="cj_French_1_609_2016_2017_2018_2019_2021_2022" //Cote d'Ivoire X
replace cj_q10_norm=. if id_alex=="cj_French_0_595" //Cote d'Ivoire X
replace cj_q10_norm=. if id_alex=="cc_French_0_254_2021_2022" //Cote d'Ivoire X
replace all_q94_norm=. if id_alex=="cc_French_1_1411_2022" //Cote d'Ivoire X
replace all_q48_norm=. if id_alex=="cc_French_1_97_2017_2018_2019_2021_2022" //Cote d'Ivoire X
replace all_q48_norm=. if id_alex=="lb_French_1_374" //Cote d'Ivoire X
replace all_q49_norm=. if id_alex=="lb_French_1_374" //Cote d'Ivoire X
replace all_q50_norm=. if id_alex=="lb_French_1_374" //Cote d'Ivoire X
replace lb_q19a_norm=. if id_alex=="lb_French_1_374" //Cote d'Ivoire X
replace all_q13_norm=. if id_alex=="cj_French_0_815_2016_2017_2018_2019_2021_2022" //Cote d'Ivoire X
drop if id_alex=="cc_English_1_249" //Croatia
drop if id_alex=="lb_English_0_354" //Croatia
replace lb_q3d_norm=. if id_alex=="lb_English_0_371" //Croatia
replace lb_q2d_norm=. if id_alex=="lb_English_0_629" //Croatia
replace cj_q26_norm=. if id_alex=="cj_English_0_113" //Croatia
replace all_q86_norm=. if id_alex=="cc_English_0_1240" //Croatia
replace all_q80_norm=. if country=="Croatia" //Croatia
drop if id_alex=="cj_English_0_924" //Cyprus
replace all_q62_norm=. if country=="Cyprus" //Cyprus
replace all_q63_norm=. if country=="Cyprus" //Cyprus
replace cc_q26a_norm=. if country=="Cyprus" //Cyprus
replace cc_q26b_norm=. if country=="Cyprus" //Cyprus
replace all_q84_norm=. if country=="Cyprus" //Cyprus
replace cc_q13_norm=. if country=="Cyprus" //Cyprus
replace cj_q42c_norm=. if country=="Cyprus" //Cyprus
replace cj_q10_norm=. if country=="Cyprus" //Cyprus
replace cj_q31d_norm=. if country=="Cyprus" //Cyprus
replace cj_q31g_norm=. if country=="Cyprus" //Cyprus
replace cj_q42d_norm=. if country=="Cyprus" //Cyprus
replace cj_q25c_norm=. if country=="Cyprus" //Cyprus
replace cj_q25c_norm=. if country=="Cyprus" //Cyprus
replace cj_q25a_norm=. if country=="Cyprus" //Cyprus
replace cj_q29b_norm=. if country=="Cyprus" //Cyprus
replace cj_q22c_norm=. if country=="Cyprus" //Cyprus
replace cj_q31f_norm=. if id_alex=="cj_English_0_611" //Cyprus
replace all_q86_norm=. if id_alex=="cc_English_0_1315_2021_2022" //Cyprus
replace all_q86_norm=. if id_alex=="cc_English_0_230" //Cyprus
replace cj_q24b_norm=. if id_alex=="cj_English_0_611" //Cyprus X
replace cj_q24c_norm=1 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q33a_norm=.6666667 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q33b_norm=1 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q33c_norm=.6666667 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q33d_norm=1 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q33e_norm=1 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q34b_norm=1 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q34c_norm=1 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q34d_norm=1 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q34e_norm=1 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q21a_norm=0.4444444 if id_alex=="cj_English_0_611" //Cyprus X
replace cj_q28_norm=0.5 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q21e_norm=0.5555556 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q12a_norm=. if id_alex=="cj_English_0_611" //Cyprus X
replace cj_q12b_norm=. if id_alex=="cj_English_0_611" //Cyprus X
replace cj_q12c_norm=. if id_alex=="cj_English_0_611" //Cyprus X
replace cj_q12d_norm=. if id_alex=="cj_English_0_611" //Cyprus X
replace cj_q12e_norm=. if id_alex=="cj_English_0_611" //Cyprus X
replace cj_q20o_norm=0.6666667 if id_alex=="cj_English_0_611" //Cyprus X
replace cj_q20m_norm=0.8888889 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q34b_norm=1 if id_alex=="cj_English_0_843_2021_2022" //Cyprus X
replace cj_q34c_norm=1 if id_alex=="cj_English_0_843_2021_2022" //Cyprus X
replace cj_q34d_norm=1 if id_alex=="cj_English_0_843_2021_2022" //Cyprus X
replace cj_q33b_norm=1 if id_alex=="cj_English_0_843_2021_2022" //Cyprus X
replace cj_q33c_norm=1 if id_alex=="cj_English_0_843_2021_2022" //Cyprus X
replace cj_q33d_norm=1 if id_alex=="cj_English_0_843_2021_2022" //Cyprus X
replace cj_q20m_norm=0.7777778 if id_alex=="cj_English_0_1068_2021_2022" //Cyprus X
replace cj_q20o_norm=1 if id_alex=="cj_English_0_301_2021_2022" //Cyprus X
replace cj_q18a_norm=.5555556 if id_alex=="cj_English_0_611" //Cyprus X
replace cj_q24c_norm=1 if id_alex=="cj_English_0_843_2021_2022" //Cyprus X
replace cj_q20m_norm=0.8888889 if id_alex=="cj_English_0_843_2021_2022" //Cyprus X
replace cj_q21d_norm=. if id_alex=="cj_English_0_611" //Cyprus X
replace cj_q15_norm=0.6666667 if id_alex=="cj_English_0_611" //Cyprus X
replace all_q33_norm=. if id_alex=="lb_English_0_594_2022" //Cyprus X
replace all_q33_norm=. if id_alex=="cc_English_1_366" //Cyprus X
replace all_q36_norm=. if id_alex=="cc_English_1_366" //Cyprus X
replace cc_q32i_norm=. if id_alex=="cc_English_1_366" //Cyprus X
replace cc_q9c_norm=. if id_alex=="cc_English_0_886_2021_2022" //Cyprus X
replace cc_q40b_norm=. if id_alex=="cc_English_1_366" //Cyprus X
replace cc_q40a_norm=. if id_alex=="cc_English_1_366" //Cyprus X
replace lb_q2d_norm=1 if id_alex=="lb_English_0_766_2021_2022" //Czechia X
replace all_q48_norm=. if id_alex=="cc_English_1_578_2017_2018_2019_2021_2022" //Czechia X
replace lb_q19a_norm=. if id_alex=="lb_English_0_112_2017_2018_2019_2021_2022" //Czechia X
replace lb_q16c_norm=. if country=="Denmark" /*Denmark*/
replace lb_q16e_norm=. if country=="Denmark" /*Denmark*/
replace all_q29_norm=. if country=="Denmark" /*Denmark*/
replace all_q88_norm=. if all_q88_norm==0 & country=="Denmark" //Denmark
replace cj_q40b_norm=. if id_alex=="cj_English_0_216" //Denmark X
replace cj_q40c_norm=. if id_alex=="cj_English_0_216" //Denmark X
replace cj_q36c_norm=. if id_alex=="cj_English_0_216" //Denmark X
replace cj_q8_norm=.6666667 if id_alex=="cj_English_0_548_2018_2019_2021_2022" //Denmark X
replace all_q79_norm=. if country=="Denmark" /*Denmark*/
replace cj_q40b_norm=.6666667 if id_alex=="cj_English_0_212" //Denmark X
replace cj_q40c_norm=.6666667 if id_alex=="cj_English_0_212" //Denmark X
replace cj_q36c_norm=. if id_alex=="cj_English_0_212" //Denmark X
replace all_q9_norm=. if id_alex=="cc_English_0_1703_2019_2021_2022" //Denmark X
replace all_q9_norm=. if id_alex=="cc_English_0_1767_2019_2021_2022" //Denmark X
replace all_q9_norm=. if id_alex=="cc_English_1_181_2019_2021_2022" //Denmark X
replace cc_q26a_norm=. if id_alex=="cc_English_1_483_2018_2019_2021_2022" //Denmark X
replace cj_q15_norm=. if id_alex=="cj_English_0_548_2018_2019_2021_2022" //Denmark X
replace cj_q28_norm=. if country=="Dominica" /*Dominica*/
replace cj_q15_norm=. if id_alex=="cj_English_1_680" //Dominica
replace cj_q38_norm=. if country=="Dominica" /*Dominica*/
replace cc_q33_norm=. if id_alex=="cc_English_0_1057" //Dominica
replace cc_q14a_norm=. if id_alex=="cc_English_0_1057" //Dominica
replace cc_q14b_norm=. if id_alex=="cc_English_0_1057" //Dominica
replace all_q1_norm=. if id_alex=="cj_English_0_412_2021_2022" //Dominica X
replace cc_q25_norm=. if id_alex=="cc_English_0_1444_2016_2017_2018_2019_2021_2022" //Dominica X
replace all_q13_norm=. if id_alex=="cj_English_0_835_2016_2017_2018_2019_2021_2022" //Dominica X
replace all_q24_norm=. if id_alex=="cc_English_0_381_2018_2019_2021_2022" //Dominica X
replace all_q25_norm=. if id_alex=="cc_English_0_381_2018_2019_2021_2022" //Dominica X
replace all_q27_norm=. if id_alex=="cc_English_1_976_2017_2018_2019_2021_2022" //Dominica X
replace all_q87_norm=. if country=="Dominica" //Dominica X
replace all_q85_norm=. if country=="Dominica" //Dominica X
replace all_q6_norm=. if id_alex=="cc_English_1_976_2017_2018_2019_2021_2022" //Dominica X
replace all_q21_norm=. if id_alex=="cc_English_1_976_2017_2018_2019_2021_2022" //Dominica X
replace all_q23_norm=. if id_alex=="cc_English_1_976_2017_2018_2019_2021_2022" //Dominica X
replace all_q22_norm=. if id_alex=="cc_English_0_381_2018_2019_2021_2022" //Dominica X
replace all_q23_norm=. if id_alex=="cj_English_0_468_2018_2019_2021_2022" //Dominica X
replace all_q24_norm=. if id_alex=="cj_English_0_468_2018_2019_2021_2022" //Dominica X
replace cj_q21e_norm=. if id_alex=="cj_English_0_836_2016_2017_2018_2019_2021_2022" //Dominica X
drop if id_alex=="cc_Spanish_0_633" //Dominican Republic
drop if id_alex=="cj_Spanish_0_770" //Dominican Republic
drop if id_alex=="lb_English_0_377_2017_2018_2019_2021_2022" //Dominican Republic
drop if id_alex=="ph_Spanish_1_43_2022" //Dominican Republic
drop if id_alex=="ph_English_1_472" //Dominican Republic
replace lb_q2d_norm=. if id_alex=="lb_English_0_582" //Dominican Republic
replace all_q77_norm=. if id_alex=="lb_Spanish_0_272_2022" //Dominican Republic X
replace all_q78_norm=. if id_alex=="lb_Spanish_0_272_2022" //Dominican Republic X
replace all_q79_norm=. if id_alex=="lb_Spanish_0_272_2022" //Dominican Republic X
replace all_q80_norm=. if id_alex=="lb_Spanish_0_272_2022" //Dominican Republic X
replace all_q81_norm=. if id_alex=="lb_Spanish_0_272_2022" //Dominican Republic X
replace all_q80_norm=. if id_alex=="cc_English_0_1121" //Dominican Republic X
replace all_q81_norm=. if id_alex=="cc_English_0_1121" //Dominican Republic X
replace all_q82_norm=. if id_alex=="cc_English_0_1121" //Dominican Republic X
replace all_q77_norm=. if id_alex=="cc_Spanish_0_1200_2016_2017_2018_2019_2021_2022" //Dominican Republic X
replace all_q78_norm=. if id_alex=="cc_Spanish_0_1200_2016_2017_2018_2019_2021_2022" //Dominican Republic X
replace all_q79_norm=. if id_alex=="cc_Spanish_0_1200_2016_2017_2018_2019_2021_2022" //Dominican Republic X
replace all_q80_norm=. if id_alex=="cc_Spanish_0_1200_2016_2017_2018_2019_2021_2022" //Dominican Republic X
replace all_q81_norm=. if id_alex=="cc_Spanish_0_1200_2016_2017_2018_2019_2021_2022" //Dominican Republic X
replace all_q82_norm=. if id_alex=="cc_Spanish_0_1200_2016_2017_2018_2019_2021_2022" //Dominican Republic X
replace cj_q20o_norm=. if id_alex=="cj_Spanish_0_810_2019_2021_2022" //Dominican Republic X
replace cj_q20o_norm=. if id_alex=="cj_English_0_162_2021_2022" //Dominican Republic X
replace lb_q23d_norm=. if id_alex=="lb_English_0_582" //Dominican Republic X
replace lb_q23e_norm=. if id_alex=="lb_English_0_582" //Dominican Republic X
replace cj_q21g_norm=. if id_alex=="cj_English_0_453" //Dominican Republic X
replace all_q84_norm=. if id_alex=="cc_Spanish_1_1181_2022" //Dominican Republic X
replace all_q84_norm=. if id_alex=="cc_English_0_36_2022" //Dominican Republic X
replace cj_q21e_norm=. if id_alex=="cj_Spanish_0_473_2017_2018_2019_2021_2022" //Dominican Republic X
replace cj_q21g_norm=. if id_alex=="cj_Spanish_0_473_2017_2018_2019_2021_2022" //Dominican Republic X
replace lb_q23f_norm=. if id_alex=="lb_Spanish_0_151_2017_2018_2019_2021_2022" //Dominican Republic X
replace lb_q23g_norm=. if id_alex=="lb_Spanish_0_151_2017_2018_2019_2021_2022" //Dominican Republic X
replace lb_q23b_norm=. if id_alex=="lb_Spanish_0_747_2019_2021_2022" //Dominican Republic X
replace lb_q23c_norm=. if id_alex=="lb_Spanish_0_747_2019_2021_2022" //Dominican Republic X
replace ph_q6a_norm=. if id_alex=="ph_Spanish_0_289_2019_2021_2022" //Dominican Republic X
replace ph_q6b_norm=. if id_alex=="ph_Spanish_0_289_2019_2021_2022" //Dominican Republic X
replace ph_q6c_norm=. if id_alex=="ph_Spanish_0_289_2019_2021_2022" //Dominican Republic X
replace ph_q6d_norm=. if id_alex=="ph_Spanish_0_289_2019_2021_2022" //Dominican Republic X
replace ph_q6e_norm=. if id_alex=="ph_Spanish_0_289_2019_2021_2022" //Dominican Republic X
replace ph_q6f_norm=. if id_alex=="ph_Spanish_0_289_2019_2021_2022" //Dominican Republic X
replace ph_q6a_norm=. if id_alex=="ph_Spanish_0_383_2019_2021_2022" //Dominican Republic X
replace ph_q6b_norm=. if id_alex=="ph_Spanish_0_383_2019_2021_2022" //Dominican Republic X
replace ph_q6c_norm=. if id_alex=="ph_Spanish_0_383_2019_2021_2022" //Dominican Republic X
replace ph_q6d_norm=. if id_alex=="ph_Spanish_0_383_2019_2021_2022" //Dominican Republic X
replace ph_q6e_norm=. if id_alex=="ph_Spanish_0_383_2019_2021_2022" //Dominican Republic X
replace ph_q6f_norm=. if id_alex=="ph_Spanish_0_383_2019_2021_2022" //Dominican Republic X
replace all_q13_norm=. if id_alex=="lb_Spanish_0_272_2022" //Dominican Republic X
replace all_q13_norm=. if id_alex=="lb_Spanish_1_496_2019_2021_2022" //Dominican Republic X
replace all_q34_norm=. if id_alex=="cc_es-mx_1_561_2017_2018_2019_2021_2022" //Dominican Republic X
replace all_q34_norm=. if id_alex=="cc_es-mx_1_525_2017_2018_2019_2021_2022" //Dominican Republic X
replace all_q86_norm=. if id_alex=="cc_Spanish_0_696_2016_2017_2018_2019_2021_2022" //Dominican Republic X
replace all_q89_norm=. if id_alex=="cc_Spanish_0_1315_2016_2017_2018_2019_2021_2022" //Dominican Republic X
replace all_q89_norm=. if id_alex=="cc_English_0_1701_2019_2021_2022" //Dominican Republic X
drop if id_alex=="ph_Spanish_0_295_2014_2016_2017_2018_2019_2021_2022" //Ecuador
replace cc_q9c_norm=. if cc_q9c_norm==0 & country=="Ecuador" //Ecuador
drop if id_alex=="cc_Spanish_0_77" //Ecuador X
drop if id_alex=="cj_Spanish_0_802" //Ecuador X
replace all_q96_norm=. if id_alex=="lb_Spanish_1_91_2018_2019_2021_2022" //Ecuador X
replace all_q96_norm=. if id_alex=="lb_Spanish_0_297_2018_2019_2021_2022" //Ecuador X
replace all_q96_norm=. if id_alex=="mx_0_1404_2017_2018_2019_2021_2022" //Ecuador X
replace all_q96_norm=. if id_alex=="cc_Spanish_1_1470_2021_2022" //Ecuador X
replace all_q96_norm=. if id_alex=="cj_Spanish_0_836_2018_2019_2021_2022" //Ecuador X
replace cj_q42d_norm=. if id_alex=="cj_Spanish_0_62_2013_2014_2016_2017_2018_2019_2021_2022" //Ecuador X
replace cj_q42d_norm=. if id_alex=="cj_Spanish_0_734_2019_2021_2022" //Ecuador X
replace cj_q42c_norm=. if id_alex=="cj_Spanish_0_734_2019_2021_2022" //Ecuador X
replace all_q76_norm=. if id_alex=="lb_Spanish_1_491_2019_2021_2022" //Ecuador X
replace all_q76_norm=. if id_alex=="cc_Spanish_1_1470_2021_2022" //Ecuador X
replace all_q80_norm=. if id_alex=="cc_Spanish_0_461" //Ecuador X
replace all_q88_norm=. if id_alex=="cc_Spanish_0_384_2016_2017_2018_2019_2021_2022" //Ecuador X
replace all_q88_norm=. if id_alex=="cc_English_0_564_2016_2017_2018_2019_2021_2022" //Ecuador X
replace all_q88_norm=. if id_alex=="cc_Spanish_0_622_2016_2017_2018_2019_2021_2022" //Ecuador X
replace all_q84_norm=. if id_alex=="cc_Spanish_1_1470_2021_2022" //Ecuador X
replace all_q85_norm=. if id_alex=="cc_English_0_564_2016_2017_2018_2019_2021_2022" //Ecuador X
replace cj_q12e_norm=. if id_alex=="cj_Spanish_0_836_2018_2019_2021_2022" //Ecuador X
replace cj_q12f_norm=. if id_alex=="cj_Spanish_0_836_2018_2019_2021_2022" //Ecuador X
replace cj_q12e_norm=. if id_alex=="cj_Spanish_1_61_2018_2019_2021_2022" //Ecuador X
replace cj_q12f_norm=. if id_alex=="cj_Spanish_1_61_2018_2019_2021_2022" //Ecuador X
replace cj_q12a_norm=. if id_alex=="cj_Spanish_1_214_2017_2018_2019_2021_2022" //Ecuador X
replace all_q96_norm=. if id_alex=="cc_es-mx_0_1404_2017_2018_2019_2021_2022" //Ecuador X
replace all_q96_norm=. if id_alex=="cj_Spanish_0_224_2017_2018_2019_2021_2022" //Ecuador X
replace all_q96_norm=. if id_alex=="lb_Spanish_1_98_2019_2021_2022" //Ecuador X
replace cj_q42d_norm=. if id_alex=="cj_Spanish_1_325_2021_2022" //Ecuador X
replace cj_q42c_norm=. if id_alex=="cj_Spanish_1_325_2021_2022" //Ecuador X
replace all_q76_norm=. if id_alex=="cc_Spanish_1_1302_2022" //Ecuador X
replace all_q80_norm=. if id_alex=="cc_Spanish_0_62" //Ecuador X
replace cc_q26b_norm=. if id_alex=="cc_Spanish_0_622_2016_2017_2018_2019_2021_2022" //Ecuador X
replace cc_q26b_norm=. if id_alex=="cc_English_1_329_2017_2018_2019_2021_2022" //Ecuador X
replace cc_q26b_norm=. if id_alex=="cc_es-mx_0_1404_2017_2018_2019_2021_2022" //Ecuador X
replace all_q88_norm=. if id_alex=="cc_es-mx_0_1404_2017_2018_2019_2021_2022" //Ecuador X
replace all_q88_norm=. if id_alex=="cc_English_1_122_2017_2018_2019_2021_2022" //Ecuador X
replace all_q81_norm=. if id_alex=="cc_Spanish_0_62" //Ecuador X
replace all_q81_norm=. if id_alex=="lb_Spanish_0_490" //Ecuador X
replace all_q82_norm=. if id_alex=="lb_Spanish_0_443" //Ecuador X
drop if id_alex=="cc_English_0_612" //Egypt, Arab Rep.
drop if id_alex=="cj_Arabic_1_798" //Egypt, Arab Rep.
drop if id_alex=="lb_English_1_22" //Egypt, Arab Rep.
replace cj_q21h_norm=. if country=="Egypt, Arab Rep." //Egypt, Arab Rep.
replace cj_q32d_norm=. if id_alex=="cj_English_0_871" //Egypt, Arab Rep.
replace cj_q33a_norm=. if id_alex=="cj_English_0_871" //Egypt, Arab Rep.
replace cj_q33b_norm=. if id_alex=="cj_English_0_871" //Egypt, Arab Rep.
replace cj_q33c_norm=. if id_alex=="cj_English_0_871" //Egypt, Arab Rep.
replace cj_q33d_norm=. if id_alex=="cj_English_0_871" //Egypt, Arab Rep.
replace cj_q33e_norm=. if id_alex=="cj_English_0_871" //Egypt, Arab Rep.
replace cj_q24c_norm=. if id_alex=="cj_English_1_902" //Egypt, Arab Rep.
replace all_q30_norm=. if id_alex=="cc_English_0_1088" //Egypt, Arab Rep.
replace all_q30_norm=. if id_alex=="cc_English_0_209" //Egypt, Arab Rep.
replace all_q29_norm=. if id_alex=="cc_English_0_1088" //Egypt, Arab Rep.
replace all_q29_norm=. if id_alex=="cc_English_0_209" //Egypt, Arab Rep.
replace all_q29_norm=. if id_alex=="cj_English_1_724_2021_2022" //Egypt, Arab Rep.
replace cj_q33a_norm=. if id_alex=="cj_English_1_902" //Egypt, Arab Rep.
replace cj_q33b_norm=. if id_alex=="cj_English_1_902" //Egypt, Arab Rep.
replace cj_q33c_norm=. if id_alex=="cj_English_1_902" //Egypt, Arab Rep.
replace cj_q33d_norm=. if id_alex=="cj_English_1_902" //Egypt, Arab Rep.
replace cj_q33e_norm=. if id_alex=="cj_English_1_902" //Egypt, Arab Rep.
replace cj_q20k_norm=. if id_alex=="cj_English_0_871" //Egypt, Arab Rep.
replace cj_q32b_norm=. if id_alex=="cj_English_0_871" //Egypt, Arab Rep.
replace cj_q31b_norm=. if id_alex=="cj_English_0_871" //Egypt, Arab Rep.
replace cj_q32c_norm=. if id_alex=="cj_English_1_76_2021_2022" //Egypt, Arab Rep.
replace cj_q32d_norm=. if id_alex=="cj_English_1_76_2021_2022" //Egypt, Arab Rep.
replace all_q96_norm=0 if id_alex=="cc_English_1_750" //Egypt, Arab Rep.
replace all_q96_norm=0 if id_alex=="cc_English_0_1158_2016_2017_2018_2019_2021_2022" //Egypt, Arab Rep.
replace cj_q31a_norm=. if id_alex=="cj_English_0_555_2021_2022" //Egypt, Arab Rep.
replace cj_q34a_norm =. if id_alex=="cj_English_0_871" //Egypt, Arab Rep.
replace cj_q34b_norm =. if id_alex=="cj_English_0_871" //Egypt, Arab Rep.
replace cj_q18a_norm =. if id_alex=="cj_English_1_76_2021_2022" //Egypt, Arab Rep.
replace cj_q34e_norm =. if id_alex=="cj_English_1_902" //Egypt, Arab Rep. X
replace cj_q24c_norm =0.5 if id_alex=="cj_English_0_871" //Egypt, Arab Rep. X
replace cj_q16j_norm =. if id_alex=="cj_English_0_871" //Egypt, Arab Rep. X
drop if id_alex=="cj_Spanish_1_722" //El Salvador 
drop if id_alex=="cj_Spanish_0_793" //El Salvador
drop if id_alex=="cj_Spanish_0_447" //El Salvador
drop if id_alex=="cj_Spanish_1_56" //El Salvador
replace cj_q42c_norm=. if id_alex=="cj_Spanish_0_509" //El Salvador
replace cj_q42c_norm=. if id_alex=="cj_English_1_355" //El Salvador
drop if id_alex=="cc_Spanish_1_166" //El Salvador
drop if id_alex=="cc_Spanish_0_1178_2016_2017_2018_2019_2021_2022" //El Salvador
drop if id_alex=="cj_Spanish_0_509" //El Salvador X
replace cj_q20o_norm =. if id_alex=="cj_Spanish_1_444_2019_2021_2022" //El Salvador X
replace cj_q20o_norm =. if id_alex=="cj_Spanish_0_987_2019_2021_2022" //El Salvador X
drop if id_alex=="cc_Spanish_0_809_2021_2022" //El Salvador X
replace cj_q40b_norm =. if id_alex=="cj_Spanish_1_444_2019_2021_2022" //El Salvador X
replace cj_q40c_norm =. if id_alex=="cj_Spanish_1_444_2019_2021_2022" //El Salvador X
replace cc_q16f_norm=. if id_alex=="cc_English_0_570" //Estonia
replace all_q88_norm=. if all_q88_norm==0 & country=="Estonia" //Estonia
replace cc_q16d_norm=. if id_alex=="cc_English_0_570" //Estonia X
replace cj_q31g_norm=. if id_alex=="cj_English_0_747" //Estonia X
replace cj_q31f_norm=. if id_alex=="cj_English_0_747" //Estonia X
replace cj_q11b_norm=. if id_alex=="cj_English_0_747" //Estonia X
replace all_q62_norm=. if id_alex=="lb_English_1_568" //Estonia X
replace all_q63_norm=. if id_alex=="lb_English_1_568" //Estonia X
replace cc_q16f_norm=. if id_alex=="cc_English_0_128" //Estonia X
replace cc_q9c_norm=. if id_alex=="cc_English_0_570" //Estonia X
replace cc_q40a_norm=. if id_alex=="cc_English_0_570" //Estonia X
replace cc_q40b_norm=. if id_alex=="cc_English_0_570" //Estonia X
replace all_q20_norm=. if id_alex=="cc_English_0_573_2019_2021_2022" //Ethiopia X
replace all_q20_norm=. if id_alex=="lb_English_0_24_2022" //Ethiopia X
replace all_q1_norm=. if id_alex=="cc_English_1_540_2021_2022" //Ethiopia X
replace all_q1_norm=. if id_alex=="cc_English_0_1542_2021_2022" //Ethiopia X
replace all_q19_norm=. if id_alex=="cc_English_0_1331_2022" //Ethiopia X
replace lb_q16d_norm=. if id_alex=="lb_English_1_473_2014_2016_2017_2018_2019_2021_2022" //Ethiopia X
replace lb_q16d_norm=. if id_alex=="lb_English_0_395" //Ethiopia X
replace cj_q31g_norm=. if id_alex=="cj_English_0_155_2018_2019_2021_2022" //Ethiopia X
replace cj_q31g_norm=. if id_alex=="cj_English_0_762_2019_2021_2022" //Ethiopia X
replace cj_q40b_norm=. if id_alex=="cj_English_0_601_2017_2018_2019_2021_2022" //Ethiopia X
replace cj_q40c_norm=. if id_alex=="cj_English_0_601_2017_2018_2019_2021_2022" //Ethiopia X
replace cj_q40b_norm=. if id_alex=="cj_English_0_824_2022" //Ethiopia X
replace cj_q40c_norm=. if id_alex=="cj_English_0_824_2022" //Ethiopia X
replace cj_q40b_norm=. if id_alex=="cj_English_0_815_2022" //Ethiopia X
replace cj_q40c_norm=. if id_alex=="cj_English_0_815_2022" //Ethiopia X
replace cj_q20m_norm=. if id_alex=="cj_English_0_601_2017_2018_2019_2021_2022" //Ethiopia X
replace cj_q20m_norm=. if id_alex=="cj_English_1_747_2017_2018_2019_2021_2022" //Ethiopia X
replace cj_q42c_norm=. if id_alex=="cj_English_0_601_2017_2018_2019_2021_2022" //Ethiopia X
replace cj_q42c_norm=. if id_alex=="cj_English_0_155_2018_2019_2021_2022" //Ethiopia X
replace cj_q15_norm=. if id_alex=="cj_English_1_1124_2021_2022" //Ethiopia X
replace cj_q15_norm=. if id_alex=="cj_English_0_548" //Ethiopia X
replace cj_q28_norm=. if id_alex=="cj_English_0_423" //Ethiopia X
replace cj_q28_norm=. if id_alex=="cj_English_1_958" //Ethiopia X
replace cj_q40c_norm=. if id_alex=="cj_English_1_1155_2021_2022" //Ethiopia X
replace cj_q42c_norm=. if id_alex=="cj_English_1_1155_2021_2022" //Ethiopia X
replace cj_q15_norm=. if id_alex=="cj_English_0_437_2021_2022" //Ethiopia X
replace cj_q42c_norm=. if id_alex=="cj_English_0_824_2022" //Ethiopia X
replace cj_q42d_norm=. if id_alex=="cj_English_0_824_2022" //Ethiopia X
replace cj_q42c_norm=. if id_alex=="cj_English_0_412" //Ethiopia X
replace cj_q42d_norm=. if id_alex=="cj_English_0_412" //Ethiopia X
replace cc_q9c_norm=. if id_alex=="cc_English_0_1772_2019_2021_2022" //Finland X
drop if id_alex=="cj_French_0_261_2022" //France
drop if id_alex=="cj_French_1_39_2022" //France
drop if id_alex=="cc_English_0_827_2022" //France X
replace all_q78_norm=. if id_alex=="cc_English_1_607_2017_2018_2019_2021_2022" //France X
replace all_q78_norm=. if id_alex=="cc_French_1_285_2019_2021_2022" //France X
replace lb_q16c_norm=. if id_alex=="lb_French_1_93_2018_2019_2021_2022" //France X
replace lb_q16c_norm=. if id_alex=="lb_French_0_450_2022" //France X
replace ph_q6c_norm=. if id_alex=="ph_English_0_455_2018_2019_2021_2022" //France X
replace lb_q23a_norm=. if country=="Gabon" /*Gabon*/
replace cc_q33_norm=. if cc_q33_norm==1 & country=="Gabon" //Gabon
replace cj_q20o_norm=. if id_alex=="cj_French_0_661" //Gabon
replace cj_q11a_norm=. if id_alex=="cj_French_0_661" //Gabon X
replace cj_q11b_norm=. if id_alex=="cj_French_0_661" //Gabon X
replace cj_q31e_norm=. if id_alex=="cj_French_0_661" //Gabon X
replace cj_q42c_norm=. if id_alex=="cj_French_0_661" //Gabon X
replace cj_q42d_norm=. if id_alex=="cj_French_0_661" //Gabon X
replace cj_q10_norm=. if id_alex=="cj_French_0_661" //Gabon X
replace lb_q2d_norm=0.75 if id_alex=="lb_French_0_393_2022" //Gabon X
replace lb_q3d_norm=0.75 if id_alex=="lb_French_0_393_2022" //Gabon X
replace all_q76_norm=. if id_alex=="lb_French_1_590" //Gabon X
replace all_q77_norm=. if id_alex=="lb_French_1_590" //Gabon X
replace all_q78_norm=. if id_alex=="lb_French_1_590" //Gabon X
replace all_q79_norm=. if id_alex=="lb_French_1_590" //Gabon X
replace all_q80_norm=. if id_alex=="lb_French_1_590" //Gabon X
replace all_q81_norm=. if id_alex=="lb_French_1_590" //Gabon X
replace all_q82_norm=. if id_alex=="lb_French_1_590" //Gabon X
replace all_q76_norm=. if id_alex=="cc_French_1_851" //Gabon X
replace all_q77_norm=. if id_alex=="cc_French_1_851" //Gabon X
replace all_q78_norm=. if id_alex=="cc_French_1_851" //Gabon X
replace all_q79_norm=. if id_alex=="cc_French_1_851" //Gabon X
replace all_q80_norm=. if id_alex=="cc_French_1_851" //Gabon X
replace all_q81_norm=. if id_alex=="cc_French_1_851" //Gabon X
replace all_q82_norm=. if id_alex=="cc_French_1_851" //Gabon X
replace cc_q11a_norm=. if id_alex=="cc_French_0_380_2022" //Gabon X
replace all_q6_norm=. if id_alex=="cc_English_1_1450" //Gabon X
replace cj_q21h_norm=. if id_alex=="cj_English_1_695" //Gabon X
replace cj_q20o_norm=0.6666667 if id_alex=="cj_French_0_764_2022" //Gabon X
replace cj_q12a_norm=. if id_alex=="cj_French_0_764_2022" //Gabon X
replace ph_q6a_norm=.3333333 if id_alex=="ph_English_0_115" //Gabon X
replace ph_q6f_norm=.3333333 if id_alex=="ph_English_0_115" //Gabon X
replace ph_q6a_norm=.3333333 if id_alex=="ph_French_0_89" //Gabon X
replace ph_q6e_norm=.3333333 if id_alex=="ph_French_0_89" //Gabon X
replace ph_q6f_norm=.3333333 if id_alex=="ph_French_0_89" //Gabon X
replace all_q29_norm=. if id_alex=="cc_French_0_186_2022" //Gabon X
replace all_q62_norm=. if id_alex=="cc_French_0_186_2022" //Gabon X
replace all_q49_norm=. if id_alex=="cc_French_0_186_2022" //Gabon X
replace cj_q38_norm=. if country=="Gambia" //The Gambia
replace cj_q21d_norm=. if country=="Gambia" //The Gambia
replace cj_q6d_norm=. if country=="Gambia" //The Gambia
replace cj_q22a_norm=. if country=="Gambia" //The Gambia
drop if id_alex=="ph_English_1_291" //The Gambia
replace cj_q10_norm=. if id_alex=="cj_English_0_983" //The Gambia
replace cj_q31f_norm=. if id_alex=="cj_English_0_983" //The Gambia
replace cj_q31g_norm=. if cj_q31g_norm==1 & country=="Gambia" //The Gambia
replace cj_q42c_norm=. if id_alex=="cj_English_0_983" //The Gambia
replace cj_q42d_norm=. if id_alex=="cj_English_0_983" //The Gambia
replace cc_q33_norm=. if cc_q33_norm==1 & country=="Gambia" //The Gambia
replace all_q6_norm=. if id_alex=="cc_English_0_559_2022" //The Gambia
replace cj_q20e_norm=0 if id_alex=="cj_English_0_415" //The Gambia
replace cj_q7c_norm=. if id_alex=="cj_English_0_983" //The Gambia
replace cj_q20o_norm=. if id_alex=="cj_English_0_983" //The Gambia
replace all_q2_norm=. if id_alex=="lb_English_1_28_2021_2022" //The Gambia X
replace all_q21_norm=. if id_alex=="cj_English_0_415" //The Gambia X
replace cc_q25_norm=. if id_alex=="cc_English_1_1142" //The Gambia X
replace all_q4_norm=. if id_alex=="cc_English_1_1142" //The Gambia X
replace all_q5_norm=. if id_alex=="cc_English_1_1142" //The Gambia X
replace all_q7_norm=. if id_alex=="cc_English_1_1142" //The Gambia X
replace cc_q26h_norm =. if id_alex=="cc_English_0_1273_2022" //The Gambia X
replace cj_q32c_norm =. if id_alex=="cj_English_0_415" //The Gambia X
replace cj_q32d_norm =. if id_alex=="cj_English_0_415" //The Gambia X
replace all_q96_norm =. if id_alex=="cj_English_0_1113_2019_2021_2022" //The Gambia X
replace cj_q11b_norm =. if id_alex=="cj_English_0_415" //The Gambia X
replace cj_q31e_norm =. if id_alex=="cj_English_0_983" //The Gambia X
replace cj_q15_norm =. if id_alex=="cj_English_0_1164_2019_2021_2022" //The Gambia X
replace cc_q10_norm =. if id_alex=="cc_English_0_382" //The Gambia X
replace cc_q11a_norm =. if id_alex=="cc_English_0_382" //The Gambia X
replace cc_q14a_norm =. if id_alex=="cc_English_0_1273_2022" //The Gambia X
replace cc_q16f_norm =. if id_alex=="cc_English_0_778_2019_2021_2022" //The Gambia X
replace cj_q27a_norm =. if id_alex=="cj_English_0_415" //The Gambia X
replace cj_q27b_norm =. if id_alex=="cj_English_0_415" //The Gambia X
replace cj_q7a_norm =. if id_alex=="cj_English_0_415" //The Gambia X
replace cj_q7b_norm =. if id_alex=="cj_English_0_415" //The Gambia X
replace cj_q20e_norm =. if id_alex=="cj_English_0_415" //The Gambia X
replace cj_q12f_norm =. if id_alex=="cj_English_0_415" //The Gambia X
replace cj_q40b_norm =. if id_alex=="cj_English_0_1113_2019_2021_2022" //The Gambia X
replace cc_q39c_norm=. if cc_q39c_norm==0 & country=="Georgia" //Georgia
drop if id_alex=="lb_English_0_677_2017_2018_2019_2021_2022" //Georgia X
replace lb_q19a_norm =. if id_alex=="lb_English_1_154_2021_2022" //Georgia X
replace lb_q2d_norm =. if id_alex=="lb_English_1_99_2016_2017_2018_2019_2021_2022" //Georgia X
replace all_q96_norm =. if id_alex=="cc_English_0_1562_2019_2021_2022" //Georgia X
replace all_q96_norm =. if id_alex=="cc_English_1_180_2019_2021_2022" //Georgia X
replace cj_q15_norm =. if id_alex=="cj_English_0_219_2016_2017_2018_2019_2021_2022" //Georgia X
replace cc_q9c_norm =. if id_alex=="cc_English_0_455_2017_2018_2019_2021_2022" //Georgia X
replace cc_q40a_norm =. if id_alex=="cc_English_0_455_2017_2018_2019_2021_2022" //Georgia X
replace all_q33_norm =. if id_alex=="cc_English_1_152_2016_2017_2018_2019_2021_2022" //Georgia X
replace all_q33_norm =. if id_alex=="cj_English_0_286_2017_2018_2019_2021_2022" //Georgia X
replace all_q33_norm =. if id_alex=="cc_English_0_455_2017_2018_2019_2021_2022" //Georgia X
replace cc_q40a_norm =. if id_alex=="cc_English_1_152_2016_2017_2018_2019_2021_2022" //Georgia X
drop if id_alex=="cj_English_1_406" //Germany
drop if id_alex=="cj_English_1_1019" //Germany
drop if id_alex=="cc_English_1_1388_2021_2022" //Germany
drop if id_alex=="ph_English_0_145_2016_2017_2018_2019_2021_2022" //Germany
replace all_q96_norm=. if id_alex=="cc_English_1_219_2016_2017_2018_2019_2021_2022" //Germany
replace all_q96_norm=. if id_alex=="cc_English_0_894_2016_2017_2018_2019_2021_2022" //Germany
replace all_q96_norm=. if id_alex=="cc_English_1_132_2018_2019_2021_2022" //Germany
replace all_q96_norm=. if id_alex=="cc_English_0_1281_2019_2021_2022" //Germany
replace all_q96_norm=. if id_alex=="cc_English_0_756" //Germany
replace all_q96_norm=. if id_alex=="lb_English_0_334_2016_2017_2018_2019_2021_2022" //Germany
replace all_q96_norm=. if id_alex=="lb_English_0_332_2016_2017_2018_2019_2021_2022" //Germany
replace ph_q8d_norm=0.33333333 if id_alex=="ph_English_1_183_2016_2017_2018_2019_2021_2022" //Germany
replace all_q95_norm=. if id_alex=="cc_English_0_294_2016_2017_2018_2019_2021_2022" //Germany
replace all_q95_norm=. if id_alex=="cc_English_0_894_2016_2017_2018_2019_2021_2022" //Germany
replace all_q95_norm=. if id_alex=="cc_English_0_977_2016_2017_2018_2019_2021_2022" //Germany
replace all_q95_norm=. if id_alex=="lb_English_1_749_2022" //Germany
replace all_q95_norm=. if id_alex=="cc_English_0_136_2018_2019_2021_2022" //Germany
replace all_q95_norm=. if id_alex=="cc_English_1_921_2018_2019_2021_2022" //Germany
replace ph_q5a_norm=. if id_alex=="ph_English_0_156" //Germany
replace ph_q5b_norm=. if id_alex=="ph_English_0_156" //Germany
replace ph_q5a_norm=. if id_alex=="ph_English_0_288" //Germany
replace ph_q5b_norm=. if id_alex=="ph_English_0_288" //Germany
replace ph_q5a_norm=. if id_alex=="ph_English_0_298" //Germany
replace ph_q5b_norm=. if id_alex=="ph_English_0_298" //Germany
replace ph_q5b_norm=0.5 if id_alex=="ph_English_1_183_2016_2017_2018_2019_2021_2022" //Germany
replace all_q61_norm=. if id_alex=="cc_English_0_294_2016_2017_2018_2019_2021_2022" //Germany
replace all_q61_norm=. if id_alex=="cc_English_0_894_2016_2017_2018_2019_2021_2022" //Germany
replace all_q61_norm=. if id_alex=="cc_English_0_977_2016_2017_2018_2019_2021_2022" //Germany
replace all_q61_norm=. if id_alex=="cc_English_0_1271_2016_2017_2018_2019_2021_2022" //Germany
replace all_q61_norm=. if id_alex=="cc_English_1_219_2016_2017_2018_2019_2021_2022" //Germany
replace all_q61_norm=. if id_alex=="cc_English_0_198_2017_2018_2019_2021_2022" //Germany
replace cj_q31a_norm=. if id_alex=="cj_English_0_152_2016_2017_2018_2019_2021_2022" //Germany
replace cj_q31a_norm=. if id_alex=="cj_English_1_188_2016_2017_2018_2019_2021_2022" //Germany
replace cj_q31a_norm=. if id_alex=="cj_English_1_205_2017_2018_2019_2021_2022" //Germany
replace cj_q31a_norm=. if id_alex=="cj_English_0_686_2019_2021_2022" //Germany
replace all_q97_norm=. if id_alex=="cc_English_0_894_2016_2017_2018_2019_2021_2022" //Germany
replace all_q97_norm=. if id_alex=="cc_English_0_1271_2016_2017_2018_2019_2021_2022" //Germany
replace all_q97_norm=. if id_alex=="cc_English_1_219_2016_2017_2018_2019_2021_2022" //Germany
replace all_q97_norm=. if id_alex=="cc_English_1_1464_2022" //Germany
replace all_q96_norm=. if id_alex=="lb_English_1_317_2022" //Germany
replace all_q96_norm=. if id_alex=="lb_English_0_55_2022" //Germany
replace all_q96_norm=. if id_alex=="lb_English_1_749_2022" //Germany
replace all_q96_norm=. if id_alex=="cj_English_0_334" //Germany
replace ph_q9d_norm=0.75 if id_alex=="ph_English_1_358_2017_2018_2019_2021_2022" //Germany
replace all_q95_norm=. if id_alex=="cc_English_0_1111" //Germany
replace all_q95_norm=. if id_alex=="cc_English_0_326" //Germany
replace cj_q32b_norm=. if id_alex=="cj_English_1_142_2016_2017_2018_2019_2021_2022" //Germany
replace cj_q32b_norm=. if id_alex=="cj_English_1_133_2016_2017_2018_2019_2021_2022" //Germany
drop if id_alex=="cj_English_1_718" //Germany
drop if id_alex=="cj_English_0_385" //Germany
replace cj_q19a_norm=. if id_alex=="cj_English_0_887" //Germany
replace cj_q19a_norm=. if id_alex=="cj_English_0_334" //Germany
replace cj_q19a_norm=. if id_alex=="cj_English_0_386" //Germany
replace cj_q22b_norm=. if id_alex=="cj_English_0_386" //Germany
replace cj_q22b_norm=. if id_alex=="cj_English_1_747" //Germany
replace cj_q22e_norm=. if id_alex=="cj_English_1_142_2016_2017_2018_2019_2021_2022" //Germany
replace cj_q22e_norm=. if id_alex=="cj_English_1_133_2016_2017_2018_2019_2021_2022" //Germany
replace cj_q19a_norm=. if id_alex=="cj_English_1_1067_2021_2022" //Germany
replace cj_q19c_norm=. if id_alex=="cj_English_1_1067_2021_2022" //Germany
replace cj_q19c_norm=. if id_alex=="cj_English_1_757_2016_2017_2018_2019_2021_2022" //Germany
replace cj_q18c_norm=. if id_alex=="cj_English_0_686_2019_2021_2022" //Germany
replace cj_q18c_norm=. if id_alex=="cj_English_1_792_2021_2022" //Germany
replace cj_q20o_norm=. if id_alex=="cj_English_1_205_2017_2018_2019_2021_2022" //Germany
drop if id_alex=="cj_English_1_747" //Germany
drop if id_alex=="cj_English_1_718" //Germany 
drop if id_alex=="cj_English_0_176_2017_2018_2019_2021_2022" //Germany
replace all_q96_norm=. if id_alex=="cc_English_0_198_2017_2018_2019_2021_2022" //Germany
replace all_q96_norm=. if id_alex=="lb_English_0_76_2019_2021_2022" //Germany
replace cj_q25c_norm=. if country=="Ghana" //Ghana
drop if id_alex=="lb_English_1_659" //Ghana
drop if id_alex=="cc_English_0_1194" //Ghana
replace cc_q39c_norm=. if id_alex=="cc_English_0_877" //Ghana
replace cj_q20e_norm=. if id_alex=="cj_English_0_476" //Ghana
replace cj_q12e_norm=. if id_alex=="cj_English_1_453_2019_2021_2022" //Ghana
replace cj_q40c_norm=. if id_alex=="cj_English_0_150_2022" //Ghana
drop if id_alex=="cc_English_0_324_2022" //Ghana
drop if id_alex=="cj_English_0_150_2022"  //Ghana
replace cc_q9b_norm=. if cc_q9b_norm==0 & country=="Ghana" //Ghana
replace cc_q9a_norm=. if cc_q9a_norm==0 & country=="Ghana" //Ghana
replace cc_q11b_norm=. if cc_q11b_norm==0 & country=="Ghana" //Ghana
replace cc_q32j_norm=. if cc_q32j_norm==0 & country=="Ghana" //Ghana
replace cc_q40a_norm=. if id_alex=="cc_English_0_414_2021_2022" //Ghana
drop if id_alex=="cc_English_1_594" //Greece
replace cc_q39a_norm=. if id_alex=="cc_English_0_670" //Greece
replace cc_q39b_norm=. if id_alex=="cc_English_0_670" //Greece
replace cc_q39b_norm=. if id_alex=="cc_English_1_269" //Greece
drop if id_alex=="cc_English_1_497" //Greece
drop if id_alex=="lb_English_0_667" //Greece
replace all_q28_norm=. if id_alex=="cc_English_0_670" //Greece X
replace all_q6_norm=. if id_alex=="cc_English_0_670" //Greece X
replace all_q58_norm=. if id_alex=="cc_English_0_1264" //Greece X
replace cj_q32b_norm=. if id_alex=="cj_English_1_1270_2021_2022" //Greece X
replace lb_q2d_norm=. if country=="Grenada" /*Grenada*/
replace all_q69_norm=. if country=="Grenada" /*Grenada*/
replace all_q70_norm=. if country=="Grenada" /*Grenada*/
replace all_q84_norm=. if country=="Grenada" /*Grenada*/
replace cc_q13_norm=. if country=="Grenada" /*Grenada*/
replace cj_q22e_norm=. if country=="Grenada" /*Grenada*/
replace cj_q6b_norm=. if country=="Grenada" /*Grenada*/
replace cj_q6d_norm=. if country=="Grenada" /*Grenada*/
replace cj_q42c_norm=. if country=="Grenada" /*Grenada*/
replace cj_q42d_norm=. if country=="Grenada" /*Grenada*/
replace all_q76_norm=. if country=="Grenada" /*Grenada*/
replace cj_q24c_norm=. if country=="Grenada" /*Grenada*/
replace all_q1_norm=. if all_q1_norm==1 & country=="Grenada" //Grenada
replace all_q20_norm=. if country=="Grenada" //Grenada
replace cc_q33_norm=. if cc_q33_norm==1 & country=="Grenada" //Grenada
replace cj_q8_norm=. if id_alex=="cj_English_1_1075" //Grenada
replace all_q11_norm=. if id_alex=="cj_English_1_1075" //Grenada
replace cj_q9_norm=. if country=="Grenada"  //Grenada
replace cj_q8_norm=. if id_alex=="cj_English_1_1075" //Grenada
replace cj_q10_norm=. if id_alex=="cj_English_1_1075" //Grenada
replace cc_q9c_norm=. if id_alex=="cc_English_1_1393" //Grenada
replace cj_q10_norm=. if id_alex=="cj_English_1_1075" //Grenada
replace cj_q11b_norm=. if country=="Grenada" //Grenada
replace all_q62_norm=. if all_q62_norm==0 & country=="Grenada" //Grenada
replace all_q63_norm=. if all_q63_norm==0 & country=="Grenada" //Grenada
replace cj_q7a_norm=. if cj_q7a_norm==1 & country=="Grenada" //Grenada
replace cj_q7b_norm=. if cj_q7b_norm==1 & country=="Grenada" //Grenada
replace cj_q7c_norm=. if cj_q7c_norm==1 & country=="Grenada" //Grenada
replace cj_q28_norm=. if id_alex=="cj_English_1_1075" //Grenada
replace cj_q20o_norm=. if id_alex=="cj_English_1_1075" //Grenada
replace cj_q20k_norm=. if country=="Grenada" //Grenada
replace cj_q20m_norm=. if id_alex=="cj_English_1_547_2018_2019_2021_2022" //Grenada
replace cj_q20m_norm=. if id_alex=="cj_English_1_1075" //Grenada
replace cj_q19c_norm=. if id_alex=="cj_English_1_246" //Grenada
replace cj_q4_norm=. if cj_q4_norm==1 & country=="Grenada"  //Grenada
replace cj_q11a_norm=. if id_alex=="cj_English_1_1075" //Grenada X
replace cj_q31f_norm=. if id_alex=="cj_English_1_547_2018_2019_2021_2022" //Grenada X
replace lb_q3d_norm=. if id_alex=="lb_English_0_587_2022" //Grenada X
replace all_q62_norm=. if id_alex=="cc_English_0_374" //Grenada X
replace all_q63_norm=. if id_alex=="cc_English_0_374" //Grenada X
replace cj_q20e_norm=. if id_alex=="cj_English_1_1075" //Grenada X
replace cj_q21e_norm=. if id_alex=="cj_English_1_1075" //Grenada X
replace all_q63_norm=. if id_alex=="lb_English_1_435" //Grenada X
drop if id_alex=="cc_English_1_1393" //Grenada X
replace cj_q10_norm=.3333333 if id_alex=="cj_English_1_246" //Grenada X
replace cj_q11a_norm=.6666667 if id_alex=="cj_English_1_246" //Grenada X
replace cc_q14a_norm=. if id_alex=="cc_English_1_597" //Grenada X
replace cc_q14b_norm=. if id_alex=="cc_English_1_597" //Grenada X
replace cc_q14a_norm=. if id_alex=="cc_English_0_374" //Grenada X
replace cc_q14b_norm=. if id_alex=="cc_English_0_374" //Grenada X
replace cc_q26b_norm=. if id_alex=="cc_English_1_1108_2018_2019_2021_2022" //Grenada X
replace cj_q20e_norm=.2222222 if id_alex=="cj_English_1_1075" //Grenada X
replace cj_q21a_norm=. if id_alex=="cj_English_1_1075" //Grenada X
replace cj_q21g_norm=. if id_alex=="cj_English_1_1075" //Grenada X
replace cj_q21h_norm=. if id_alex=="cj_English_1_1075" //Grenada X
replace cj_q31a_norm=.3333333 if id_alex=="cj_English_1_246" //Grenada X
replace cj_q16j_norm=. if id_alex=="cj_English_1_1075" //Grenada X
replace cj_q18a_norm=. if id_alex=="cj_English_1_1075" //Grenada X
replace cj_q32b_norm=. if id_alex=="cj_English_1_1075" //Grenada X
replace cj_q20m_norm=.5555556 if id_alex=="cj_English_1_1075" //Grenada X
replace cj_q7c_norm=.6666667 if id_alex=="cj_English_1_246" //Grenada X
replace cj_q7c_norm=.3333333 if id_alex=="cj_English_1_1075" //Grenada X
replace cc_q14a_norm=. if id_alex=="cc_English_1_1480_2022" //Grenada X
replace cc_q14a_norm=. if id_alex=="cc_English_1_1303" //Grenada X
drop if id_alex=="cc_English_0_1254_2018_2019_2021_2022" //Guatemala X
drop if id_alex=="cc_Spanish_0_875_2021_2022" //Guatemala X
replace all_q86_norm=. if id_alex=="cc_English_1_1577_2019_2021_2022" //Guatemala X
replace all_q86_norm=. if id_alex=="cc_Spanish_0_557_2022" //Guatemala X
replace cc_q26b_norm=. if id_alex=="cc_Spanish_1_340_2016_2017_2018_2019_2021_2022" //Guatemala X
replace cc_q26b_norm=. if id_alex=="cc_Spanish_0_242_2016_2017_2018_2019_2021_2022" //Guatemala X
replace all_q9_norm=. if id_alex=="cj_Spanish_0_389" //Guatemala X
drop if id_alex=="cj_English_0_1015_2019_2021_2022" //Guatemala X
replace all_q44_norm=. if id_alex=="cc_English_1_319_2019_2021_2022" //Guatemala X
replace all_q45_norm=. if id_alex=="cc_English_1_319_2019_2021_2022" //Guatemala X
replace all_q44_norm=. if id_alex=="cc_Spanish_0_790" //Guatemala X
replace all_q45_norm=. if id_alex=="cc_Spanish_0_790" //Guatemala X
replace all_q44_norm=. if id_alex=="cc_Spanish_0_378" //Guatemala X
replace all_q45_norm=. if id_alex=="cc_Spanish_0_378" //Guatemala X
replace cc_q40a_norm=. if id_alex=="cc_Spanish_0_129" //Guatemala X
replace cc_q40a_norm=. if id_alex=="cc_Spanish_0_274" //Guatemala X
replace cc_q40b_norm=. if id_alex=="cc_English_1_319_2019_2021_2022" //Guatemala X
drop if id_alex=="lb_Spanish_0_169_2018_2019_2021_2022" //Guatemala X
replace cj_q12b_norm=. if id_alex=="cj_English_1_1000" //Guatemala X
replace cj_q12c_norm=. if id_alex=="cj_English_1_1000" //Guatemala X
replace cj_q12d_norm=. if id_alex=="cj_English_1_1000" //Guatemala X
replace cj_q12e_norm=. if id_alex=="cj_English_1_1000" //Guatemala X
replace cj_q12f_norm=. if id_alex=="cj_English_1_1000" //Guatemala X
replace cj_q16m_norm=. if id_alex=="cj_Spanish_0_608" //Guatemala X
replace cj_q18b_norm=. if id_alex=="cj_Spanish_1_439" //Guatemala X
replace cj_q18c_norm=. if id_alex=="cj_Spanish_0_909_2017_2018_2019_2021_2022" //Guatemala X
replace cj_q25b_norm=. if id_alex=="cj_Spanish_1_945" //Guatemala X
replace cj_q25b_norm=. if id_alex=="cj_Spanish_0_935" //Guatemala X
replace cj_q20o_norm=. if id_alex=="cj_English_1_1000" //Guatemala X
replace cj_q20o_norm=. if id_alex=="cj_English_1_507" //Guatemala X
replace cj_q38_norm=. if country=="Guinea" //Guinea
replace all_q48_norm=. if all_q48_norm==1 & country=="Guinea" //Guinea
replace all_q50_norm=. if all_q50_norm==1 & country=="Guinea" //Guinea
replace all_q89_norm=. if id_alex=="cc_French_0_330" //Guinea
replace all_q79_norm=. if all_q79_norm==0 & country=="Guinea" //Guinea
drop if id_alex=="cc_French_0_645" //Guinea X
replace cc_q33_norm=. if id_alex=="cc_French_0_1707_2019_2021_2022" //Guinea X
replace cc_q33_norm=. if id_alex=="cc_French_0_1097" //Guinea X
replace cj_q10_norm=. if id_alex=="cj_French_1_604_2019_2021_2022" //Guinea X
replace all_q18_norm=. if id_alex=="cj_French_1_604_2019_2021_2022" //Guinea X
replace cj_q10_norm=. if id_alex=="cj_English_1_1126_2021_2022" //Guinea X
replace all_q21_norm=. if id_alex=="cc_French_0_1707_2019_2021_2022" //Guinea X
replace all_q21_norm=. if id_alex=="cj_French_0_966_2019_2021_2022" //Guinea X
replace all_q13_norm=. if id_alex=="cj_French_1_604_2019_2021_2022" //Guinea X
replace all_q13_norm=. if id_alex=="cj_French_0_64_2019_2021_2022" //Guinea X
replace all_q19_norm=. if id_alex=="cj_French_0_1164_2018_2019_2021_2022" //Guinea X
replace all_q19_norm=. if id_alex=="cj_French_1_843_2019_2021_2022" //Guinea X
replace all_q32_norm=. if id_alex=="cj_French_0_1164_2018_2019_2021_2022" //Guinea X
replace all_q32_norm=. if id_alex=="cj_French_1_843_2019_2021_2022" //Guinea X
replace lb_q3d_norm=. if id_alex=="lb_French_0_130_2019_2021_2022" //Guinea X
replace all_q49_norm=. if id_alex=="lb_French_0_130_2019_2021_2022" //Guinea X
replace all_q69_norm=. if id_alex=="cc_French_0_135_2018_2019_2021_2022" //Guinea X
replace all_q74_norm=. if id_alex=="cc_French_1_684_2019_2021_2022" //Guinea X
replace all_q15_norm=. if id_alex=="cc_French_0_135_2018_2019_2021_2022" //Guinea X
replace cj_q28_norm=. if id_alex=="cj_French_0_951" //Guinea X
replace lb_q19a_norm=. if id_alex=="lb_English_0_159_2018_2019_2021_2022" //Guinea X
replace all_q49_norm=. if id_alex=="lb_English_0_159_2018_2019_2021_2022" //Guinea X
replace cj_q42d_norm=. if id_alex=="cj_French_1_604_2019_2021_2022" //Guinea X
replace cc_q33_norm=. if id_alex=="cc_French_0_135_2018_2019_2021_2022" //Guinea X
replace cj_q36c_norm=. if id_alex=="cj_French_0_29_2022" //Guinea X
replace cj_q8_norm=. if id_alex=="cj_French_1_604_2019_2021_2022" //Guinea X
drop if id_alex=="cc_English_1_1145_2018_2019_2021_2022" //Guyana
replace all_q70_norm=. if country=="Guyana" //Guyana
replace all_q77_norm=. if id_alex=="cc_English_0_359_2022" //Guyana
replace all_q78_norm=. if all_q78_norm==0 & country=="Guyana" //Guyana
drop if id_alex=="cc_English_1_830" //Guyana
drop if id_alex=="cj_English_1_923_2022" //Guyana
replace cc_q40a_norm=. if id_alex=="cc_English_0_1465_2016_2017_2018_2019_2021_2022" //Guyana X
replace cc_q40b_norm=. if id_alex=="cc_English_0_622" //Guyana X
replace all_q45_norm=. if id_alex=="cc_English_0_622" //Guyana X
replace all_q46_norm=. if id_alex=="cc_English_0_622" //Guyana X
replace cc_q39b_norm=. if id_alex=="cc_English_0_622" //Guyana X
replace cc_q39e_norm=. if id_alex=="cc_English_0_622" //Guyana X
replace all_q54_norm=. if id_alex=="cc_English_0_1472_2016_2017_2018_2019_2021_2022" //Guyana X
replace all_q54_norm=. if id_alex=="cc_English_0_1465_2016_2017_2018_2019_2021_2022" //Guyana X
replace all_q89_norm=. if id_alex=="cc_English_0_1312_2016_2017_2018_2019_2021_2022" //Guyana X
replace all_q89_norm=. if id_alex=="lb_English_1_538_2017_2018_2019_2021_2022" //Guyana X
replace all_q90_norm=. if id_alex=="lb_English_1_538_2017_2018_2019_2021_2022" //Guyana X
replace all_q91_norm=. if id_alex=="lb_English_1_538_2017_2018_2019_2021_2022" //Guyana X
replace all_q59_norm=. if id_alex=="cc_English_0_1312_2016_2017_2018_2019_2021_2022" //Guyana X
replace all_q59_norm=. if id_alex=="lb_English_0_247_2017_2018_2019_2021_2022" //Guyana X
replace all_q90_norm=. if country=="Haiti" //Haiti
replace all_q89_norm=. if country=="Haiti" //Haiti
replace cc_q14b_norm=. if country=="Haiti" //Haiti
drop if id_alex=="cj_English_0_783" //Haiti
replace cj_q38_norm=. if id_alex=="cj_French_0_992" //Haiti
replace cj_q11b_norm=. if id_alex=="cj_French_0_392" //Haiti
replace cj_q31e_norm=. if id_alex=="cj_English_0_783" //Haiti
replace cj_q42d_norm=. if id_alex=="cj_English_0_783" //Haiti
replace cj_q31f_norm=. if country=="Haiti" //Haiti
replace cj_q31g_norm=. if country=="Haiti" //Haiti
replace cj_q15_norm=. if id_alex=="cj_French_0_392" //Haiti
replace all_q62_norm=. if id_alex=="lb_English_1_535" //Haiti
replace all_q63_norm=. if id_alex=="lb_English_1_535" //Haiti
drop if id_alex=="cc_English_0_278" //Haiti X
replace cc_q10_norm=. if id_alex=="cc_English_0_1119_2022" //Haiti X
replace cc_q11a_norm=. if id_alex=="cc_English_0_1119_2022" //Haiti X
replace cc_q16a_norm=. if id_alex=="cc_English_0_1119_2022" //Haiti X
replace all_q59_norm=. if id_alex=="lb_English_1_535" //Haiti X
replace cc_q40a_norm=. if id_alex=="cc_English_0_459_2021_2022" //Haiti X
replace cj_q38_norm=. if id_alex=="cj_French_0_275" //Haiti X
replace cj_q8_norm=. if id_alex=="cj_French_0_392" //Haiti X
replace cc_q14a_norm=. if id_alex=="cc_English_0_156" //Haiti X
replace cj_q28_norm=. if id_alex=="cj_French_0_278" //Haiti X
replace cj_q27a_norm=. if id_alex=="cj_French_1_110" //Haiti X
replace cj_q27b_norm=. if id_alex=="cj_French_1_110" //Haiti X
replace cj_q40b_norm=. if id_alex=="cj_French_0_392" //Haiti X
replace cj_q20e_norm=. if id_alex=="cj_French_1_110" //Haiti X
replace cc_q16b_norm=. if id_alex=="cc_English_0_156" //Haiti X
replace cc_q10_norm=. if id_alex=="cc_French_0_1193_2021_2022" //Haiti X
replace cj_q15_norm=0 if id_alex=="cj_French_0_392" //Haiti X
replace lb_q2d_norm=. if id_alex=="lb_Spanish_0_361" //Honduras
replace cj_q18b_norm=. if id_alex=="cj_Spanish_1_1002" //Honduras
replace cj_q18b_norm=. if id_alex=="cj_Spanish_0_482" //Honduras
replace cj_q18c_norm=. if id_alex=="cj_Spanish_1_1002" //Honduras
replace cj_q18c_norm=. if id_alex=="cj_Spanish_0_482"  //Honduras
replace cj_q19c_norm=. if id_alex=="cj_Spanish_1_344_2016_2017_2018_2019_2021_2022" //Honduras
replace cj_q6d_norm=. if country=="Honduras" //Honduras
replace cj_q20m_norm=. if id_alex=="cj_Spanish_0_482" //Honduras
replace cj_q20e_norm=. if id_alex=="cj_Spanish_0_482" //Honduras
replace cj_q22a_norm=. if country=="Honduras" //Honduras
replace cj_q24b_norm=. if cj_q24b_norm==1 & country=="Honduras" //Honduras
replace cj_q24c_norm=. if cj_q24c_norm==1 & country=="Honduras" //Honduras
replace all_q96_norm=. if id_alex=="cc_Spanish_0_1628_2021_2022"  //Honduras X
replace all_q96_norm=. if id_alex=="cc_Spanish_1_1083_2021_2022"  //Honduras X
replace all_q96_norm=. if id_alex=="cc_Spanish_0_93_2021_2022"  //Honduras X
replace lb_q2d_norm=. if id_alex=="lb_Spanish_0_167"  //Honduras X
replace lb_q3d_norm=. if id_alex=="lb_Spanish_0_361"  //Honduras X
drop if id_alex=="cj_Spanish_0_482" //Honduras X
replace all_q63_norm=. if id_alex=="cc_English_0_141_2017_2018_2019_2021_2022"  //Honduras X
replace all_q63_norm=. if id_alex=="cc_es-mx_1_679_2018_2019_2021_2022"  //Honduras X
replace ph_q12a_norm=. if id_alex=="ph_Spanish_1_650_2021_2022"  //Honduras X
replace ph_q12b_norm=. if id_alex=="ph_Spanish_1_650_2021_2022"  //Honduras X
replace ph_q12c_norm=. if id_alex=="ph_Spanish_1_650_2021_2022"  //Honduras X
replace ph_q12d_norm=. if id_alex=="ph_Spanish_1_650_2021_2022"  //Honduras X
replace ph_q12e_norm=. if id_alex=="ph_Spanish_1_650_2021_2022"  //Honduras X
replace all_q96_norm=. if id_alex=="cc_Spanish_1_220_2021_2022"  //Honduras X
replace all_q96_norm=. if id_alex=="cc_English_0_627_2022"  //Honduras X
replace all_q96_norm=. if id_alex=="cc_Spanish_1_32_2022"  //Honduras X
replace all_q60_norm=. if id_alex=="cc_English_0_141_2017_2018_2019_2021_2022"  //Honduras X
replace all_q60_norm=. if id_alex=="cc_es-mx_1_679_2018_2019_2021_2022"  //Honduras X
replace all_q60_norm=. if id_alex=="cc_English_0_264_2018_2019_2021_2022"  //Honduras X
replace all_q60_norm=. if id_alex=="cc_Spanish (Mexico)_0_1387_2019_2021_2022"  //Honduras X
replace lb_q6c_norm=. if id_alex=="lb_English_0_72_2019_2021_2022"  //Honduras X
replace lb_q6c_norm=. if id_alex=="lb_Spanish_1_396_2016_2017_2018_2019_2021_2022"  //Honduras X
replace all_q58_norm=. if id_alex=="lb_English_0_72_2019_2021_2022"  //Honduras X
replace cj_q24c_norm=. if id_alex=="cj_Spanish_0_165_2019_2021_2022"  //Honduras X
replace cj_q24c_norm=. if id_alex=="cj_Spanish_1_293_2019_2021_2022"  //Honduras X
replace all_q61_norm=. if id_alex=="cc_Spanish_0_83"  //Honduras X
replace all_q61_norm=. if id_alex=="cc_Spanish_0_917"  //Honduras X
replace all_q57_norm=. if id_alex=="cc_Spanish_0_83"  //Honduras X
replace all_q60_norm=. if id_alex=="cc_Spanish_1_1267_2022"  //Honduras X
replace all_q57_norm=. if id_alex=="cc_Spanish_0_917"  //Honduras X
replace all_q58_norm=. if id_alex=="cc_Spanish_0_917"  //Honduras X
replace all_q60_norm=1 if id_alex=="cc_Spanish_0_1628_2021_2022"  //Honduras X
replace all_q58_norm=. if id_alex=="cc_Spanish (Mexico)_0_1387_2019_2021_2022"  //Honduras X
replace cj_q24c_norm=. if id_alex=="cj_Spanish_1_451_2021_2022"  //Honduras X
replace cj_q24c_norm=. if id_alex=="cj_Spanish_0_651_2018_2019_2021_2022"  //Honduras X
replace all_q96_norm=. if id_alex=="cj_Spanish_0_165_2019_2021_2022"  //Honduras X
replace all_q96_norm=. if id_alex=="cj_Spanish_1_293_2019_2021_2022"  //Honduras X
replace all_q96_norm=. if id_alex=="cj_Spanish_1_678_2019_2021_2022"  //Honduras X
replace all_q96_norm=. if id_alex=="lb_Spanish_0_105_2018_2019_2021_2022"  //Honduras X
replace all_q96_norm=. if id_alex=="lb_English_0_72_2019_2021_2022"  //Honduras X
replace ph_q11b_norm=. if id_alex=="ph_Spanish_0_268_2017_2018_2019_2021_2022"  //Honduras X
replace ph_q11c_norm=. if id_alex=="ph_Spanish_0_268_2017_2018_2019_2021_2022"  //Honduras X
replace ph_q12a_norm=. if id_alex=="ph_Spanish_0_228_2021_2022"  //Honduras X
replace ph_q12b_norm=. if id_alex=="ph_Spanish_0_228_2021_2022"  //Honduras X
replace ph_q12c_norm=. if id_alex=="ph_Spanish_0_228_2021_2022"  //Honduras X
replace ph_q12d_norm=. if id_alex=="ph_Spanish_0_228_2021_2022"  //Honduras X
replace ph_q12e_norm=. if id_alex=="ph_Spanish_0_228_2021_2022"  //Honduras X
replace all_q56_norm=. if id_alex=="lb_Spanish_0_234_2021_2022"  //Honduras X
replace lb_q17b_norm=. if id_alex=="lb_Spanish_0_234_2021_2022"  //Honduras X
replace all_q95_norm=. if id_alex=="cc_English_0_141_2017_2018_2019_2021_2022"  //Honduras X
replace all_q95_norm=. if id_alex=="cc_es-mx_1_679_2018_2019_2021_2022"  //Honduras X
replace all_q95_norm=. if id_alex=="cc_English_0_264_2018_2019_2021_2022"  //Honduras X
replace all_q95_norm=. if id_alex=="cc_Spanish (Mexico)_0_1387_2019_2021_2022"  //Honduras X
replace cj_q24c_norm=. if id_alex=="cj_Spanish_1_678_2019_2021_2022"  //Honduras X
replace all_q61_norm=. if id_alex=="cc_Spanish_1_862"  //Honduras X
replace all_q61_norm=. if id_alex=="cc_Spanish_1_718"  //Honduras X
replace cj_q31a_norm=. if id_alex=="cj_English_0_122_2018_2019_2021_2022"  //Honduras X
replace cj_q31b_norm=. if id_alex=="cj_English_0_122_2018_2019_2021_2022"  //Honduras X
replace cj_q31a_norm=. if id_alex=="cj_Spanish_0_165_2019_2021_2022"  //Honduras X
replace cj_q31b_norm=. if id_alex=="cj_Spanish_0_165_2019_2021_2022"  //Honduras X
drop if id_alex=="cj_Spanish_0_651_2018_2019_2021_2022" //Honduras X
drop if id_alex=="cc_Spanish (Mexico)_0_1387_2019_2021_2022" //Honduras X
drop if id_alex=="lb_Spanish_0_234_2021_2022" //Honduras X
drop if id_alex=="ph_Spanish_0_228_2021_2022" //Honduras X
replace all_q56_norm=. if id_alex=="lb_Spanish_0_278_2017_2018_2019_2021_2022"  //Honduras X
replace all_q56_norm=. if id_alex=="lb_English_1_339_2021_2022"  //Honduras X
replace all_q61_norm=. if id_alex=="lb_Spanish_0_535_2021_2022"  //Honduras X
replace all_q61_norm=. if id_alex=="lb_English_1_339_2021_2022"  //Honduras X
replace all_q61_norm=. if id_alex=="lb_English_0_72_2019_2021_2022"  //Honduras X
replace cj_q18a_norm=. if id_alex=="cj_Spanish_0_165_2019_2021_2022"  //Honduras X
replace cj_q18a_norm=. if id_alex=="cj_Spanish_1_344_2016_2017_2018_2019_2021_2022"  //Honduras X
replace cj_q33a_norm=. if id_alex=="cj_Spanish_0_165_2019_2021_2022"  //Honduras X
replace cj_q33b_norm=. if id_alex=="cj_Spanish_0_165_2019_2021_2022"  //Honduras X
replace cj_q33c_norm=. if id_alex=="cj_Spanish_0_165_2019_2021_2022"  //Honduras X
replace cj_q33d_norm=. if id_alex=="cj_Spanish_0_165_2019_2021_2022"  //Honduras X
replace cj_q33e_norm=. if id_alex=="cj_Spanish_0_165_2019_2021_2022"  //Honduras X
replace all_q57_norm=. if id_alex=="cc_English_0_1269"  //Honduras X
replace all_q58_norm=. if id_alex=="cc_English_0_1269"  //Honduras X
replace all_q95_norm=. if id_alex=="cc_Spanish_0_1628_2021_2022"  //Honduras X
replace all_q95_norm=. if id_alex=="cc_Spanish_1_1083_2021_2022"  //Honduras X
replace all_q95_norm=. if id_alex=="cc_Spanish_0_93_2021_2022"  //Honduras X
replace lb_q6c_norm=. if id_alex=="lb_Spanish_0_535_2021_2022"  //Honduras X
replace cj_q18a_norm=. if id_alex=="cj_Spanish_1_293_2019_2021_2022"  //Honduras X
replace cj_q18a_norm=. if id_alex=="cj_Spanish_0_530_2021_2022"  //Honduras X
replace all_q61_norm=. if id_alex=="lb_Spanish_0_150_2022"  //Honduras X
replace cj_q31a_norm=. if id_alex=="cj_Spanish_1_293_2019_2021_2022"  //Honduras X
replace cj_q31a_norm=. if id_alex=="cj_Spanish_0_240_2019_2021_2022"  //Honduras X
replace cj_q24c_norm=. if id_alex=="cj_Spanish_1_1184_2019_2021_2022"  //Honduras X
replace cj_q24b_norm=. if id_alex=="cj_Spanish_0_165_2019_2021_2022"  //Honduras X
replace cj_q24b_norm=. if id_alex=="cj_Spanish_1_293_2019_2021_2022"  //Honduras X
replace cj_q24b_norm=. if id_alex=="cj_Spanish_1_451_2021_2022"  //Honduras X
replace all_q58_norm=. if id_alex=="cc_English_1_1521_2019_2021_2022"  //Honduras X
replace ph_q12a_norm=. if id_alex=="ph_Spanish_1_128"  //Honduras X
replace ph_q12b_norm=. if id_alex=="ph_Spanish_1_128"  //Honduras X
replace ph_q12c_norm=. if id_alex=="ph_Spanish_1_128"  //Honduras X
replace ph_q12d_norm=. if id_alex=="ph_Spanish_1_128"  //Honduras X
replace ph_q12e_norm=. if id_alex=="ph_Spanish_1_128"  //Honduras X
replace cc_q28c_norm=. if id_alex=="cc_Spanish_1_32_2022"  //Honduras X
replace ph_q12e_norm=. if id_alex=="ph_Spanish_0_246_2017_2018_2019_2021_2022"  //Honduras X
replace ph_q12e_norm=. if id_alex=="ph_Spanish_0_651_2018_2019_2021_2022"  //Honduras X
replace cj_q42c_norm=. if id_alex=="cj_Spanish_1_344_2016_2017_2018_2019_2021_2022"  //Honduras X
replace cj_q42c_norm=. if id_alex=="cj_Spanish_0_530_2021_2022"  //Honduras X
replace all_q78_norm=. if id_alex=="cc_Spanish_1_718"  //Honduras X
drop if id_alex=="cc_English_0_404" //Hong Kong SAR, China
drop if id_alex=="cj_English_0_911" //Hong Kong SAR, China
drop if id_alex=="cj_English_0_726" //Hong Kong SAR, China
drop if id_alex=="cc_English_1_240" //Hong Kong SAR, China
replace cc_q40b_norm=. if id_alex=="cc_English_0_1081" //Hong Kong SAR, China
replace all_q84_norm=. if id_alex=="cc_English_0_1081" //Hong Kong SAR, China
replace all_q85_norm=. if id_alex=="cc_English_0_149" //Hong Kong SAR, China
replace cc_q26a_norm=. if id_alex=="cc_English_1_37" //Hong Kong SAR, China
replace cj_q40b_norm=. if id_alex=="cj_English_1_550" //Hong Kong SAR, China
replace cj_q40c_norm=. if id_alex=="cj_English_1_550" //Hong Kong SAR, China
replace cj_q20m_norm=. if id_alex=="cj_English_1_550" //Hong Kong SAR, China
replace cj_q40b_norm=. if id_alex=="cj_English_1_264_2022" //Hong Kong SAR, China
replace cj_q40c_norm=. if id_alex=="cj_English_1_264_2022" //Hong Kong SAR, China
replace cj_q20m_norm=. if id_alex=="cj_English_1_264_2022" //Hong Kong SAR, China
drop if id_alex=="cj_English_1_201" //Hungary
drop if id_alex=="ph_English_0_291_2013_2014_2016_2017_2018_2019_2021_2022" //Hungary
drop if id_alex=="cc_English_0_199" //Hungary
replace cj_q32d_norm=. if country=="Hungary" //Hungary
replace cj_q31e_norm=. if country=="Hungary" //Hungary
replace cj_q11b_norm=. if country=="Hungary" //Hungary
replace cj_q12b_norm=. if country=="Hungary" //Hungary
replace cj_q34a_norm=. if country=="Hungary" //Hungary
replace cj_q34b_norm=. if country=="Hungary" //Hungary
replace cj_q34e_norm=. if country=="Hungary" //Hungary
replace cj_q33a_norm=. if country=="Hungary" //Hungary
replace cj_q33b_norm=. if country=="Hungary" //Hungary
replace cj_q22e_norm=. if country=="Hungary" //Hungary
replace cj_q31c_norm=. if country=="Hungary" //Hungary
replace cj_q6c_norm=. if country=="Hungary" //Hungary
replace cj_q6d_norm=. if country=="Hungary" //Hungary
replace cj_q22a_norm=. if country=="Hungary" //Hungary
replace all_q77_norm=. if country=="Hungary" //Hungary
replace cc_q26a_norm=. if country=="Hungary" //Hungary
replace cc_q39a_norm=. if id_alex=="cc_English_0_522" //Hungary
replace cc_q39b_norm=. if id_alex=="cc_English_0_522" //Hungary
replace cc_q39c_norm=. if id_alex=="cc_English_0_522" //Hungary
replace cc_q39e_norm=. if id_alex=="cc_English_0_522" //Hungary
replace all_q40_norm=. if id_alex=="cc_English_0_522" //Hungary
replace all_q43_norm=. if id_alex=="cc_English_0_522" //Hungary
replace all_q44_norm=. if id_alex=="cc_English_0_522" //Hungary
replace all_q45_norm=. if id_alex=="cc_English_0_522" //Hungary
replace cc_q40b_norm=. if id_alex=="cc_English_0_522" //Hungary
replace all_q30_norm=. if all_q30_norm==1 & country=="Hungary" //Hungary
replace cj_q7c_norm=. if country=="Hungary" //Hungary
replace cj_q12a_norm=. if id_alex=="cj_English_1_811" //Hungary
replace cj_q12f_norm=. if id_alex=="cj_English_0_710" //Hungary
drop if id_alex=="cj_English_0_632_2018_2019_2021_2022" //Hungary X
drop if id_alex=="cc_English_1_1442" //Hungary X
replace all_q29_norm=. if id_alex=="cc_English_0_511_2022" //Hungary X
replace all_q29_norm=. if id_alex=="cj_English_1_378_2021_2022" //Hungary X
replace cj_q15_norm=. if id_alex=="cj_English_1_811" //Hungary X
replace cj_q15_norm=. if id_alex=="cj_English_0_1377_2018_2019_2021_2022" //Hungary X
replace all_q54_norm=. if id_alex=="cc_English_0_522" //Hungary X
replace all_q85_norm=. if id_alex=="cc_English_1_952" //Hungary X
replace cc_q13_norm=. if id_alex=="cc_English_0_522" //Hungary X
replace cj_q21f_norm=. if id_alex=="cj_English_1_811" //Hungary X
replace cj_q21b_norm=. if id_alex=="cj_English_1_811" //Hungary X
replace cj_q3a_norm=. if id_alex=="cj_English_0_639_2019_2021_2022" //Hungary X
replace cj_q3b_norm=. if id_alex=="cj_English_0_639_2019_2021_2022" //Hungary X
replace cj_q3c_norm=. if id_alex=="cj_English_0_639_2019_2021_2022" //Hungary X
replace cj_q20m_norm=. if id_alex=="cj_English_1_58_2016_2017_2018_2019_2021_2022" //Hungary X
replace cj_q20m_norm=. if id_alex=="cj_English_0_613" //Hungary X
drop if id_alex=="cc_English_0_684" //India
drop if id_alex=="cc_English_1_560" //India
replace cj_q11b_norm=. if id_alex=="cj_English_1_538_2019_2021_2022" //India X
replace cj_q31f_norm=. if id_alex=="cj_English_0_684_2017_2018_2019_2021_2022" //India X
replace cj_q31g_norm=. if id_alex=="cj_English_0_684_2017_2018_2019_2021_2022" //India X
replace cj_q40b_norm=. if id_alex=="cj_English_0_933" //India X
replace cj_q40c_norm=. if id_alex=="cj_English_0_933" //India X
replace cj_q20o_norm=. if id_alex=="cj_English_0_1340_2018_2019_2021_2022" //India X
replace cj_q20o_norm=. if id_alex=="cj_English_0_245_2018_2019_2021_2022" //India X
drop if id_alex=="cc_English_0_793" //Indonesia
drop if id_alex=="cj_English_0_238" //Indonesia
drop if id_alex=="cj_English_1_508" //Indonesia
drop if id_alex=="cj_English_0_308" //Indonesia
replace cj_q8_norm=. if cj_q8_norm==0 & country=="Indonesia" //Indonesia
replace cc_q9c_norm=. if id_alex=="cc_English_1_1326_2021_2022" //Indonesia X
replace cc_q40a_norm=. if id_alex=="cc_English_1_1326_2021_2022" //Indonesia X
replace cc_q40b_norm=. if id_alex=="cc_English_1_1326_2021_2022" //Indonesia X
replace cc_q40b_norm=. if id_alex=="cc_English_0_1190" //Indonesia X
replace all_q80_norm=. if id_alex=="lb_English_0_278" //Iran X
replace all_q81_norm=. if id_alex=="lb_English_0_278" //Iran X
replace all_q80_norm=. if id_alex=="lb_English_0_505" //Iran X
replace all_q81_norm=. if id_alex=="lb_English_0_505" //Iran X
replace all_q76_norm=. if id_alex=="lb_English_1_135_2017_2018_2019_2021_2022" //Iran X
replace all_q76_norm=. if id_alex=="cc_English_0_582" //Iran X
replace cj_q15_norm=. if country=="Ireland" //Ireland
replace cj_q7a_norm=. if country=="Ireland" //Ireland
replace all_q96_norm=. if id_alex=="cj_English_0_225" //Ireland X
replace all_q96_norm=. if id_alex=="lb_English_0_81" //Ireland X
replace cc_q12_norm=. if id_alex=="cc_English_0_1506_2021_2022" //Ireland X
replace lb_q3d_norm=. if id_alex=="lb_English_0_81" //Ireland X
replace all_q62_norm=. if id_alex=="lb_English_0_81" //Ireland X
replace all_q63_norm=. if id_alex=="lb_English_0_81" //Ireland X
replace all_q80_norm=. if country=="Italy" // Italy
drop if id_alex=="cj_French_1_498" // Italy
drop if id_alex=="cj_English_0_148_2021_2022" //Jamaica
drop if id_alex=="cc_English_0_274_2022" //Jamaica
replace all_q1_norm=. if country=="Jamaica" /*Jamaica*/
replace all_q20_norm=. if country=="Jamaica" /*Jamaica*/
replace cj_q25c_norm=. if country=="Jamaica"
replace cj_q16f_norm=. if id_alex=="cj_English_0_852" //Jamaica
replace cj_q25a_norm=. if id_alex=="cj_English_0_71" //Jamaica
replace cj_q25b_norm=. if country=="Jamaica" //Jamaica
replace cj_q25a_norm=. if id_alex=="cj_English_0_566" //Jamaica X
replace all_q96_norm=. if id_alex=="cc_English_1_812_2018_2019_2021_2022" //Jamaica X
replace all_q96_norm=. if id_alex=="cc_English_1_474_2021_2022" //Jamaica X
replace all_q96_norm=. if id_alex=="cc_English_1_913_2018_2019_2021_2022" //Jamaica X
replace cj_q34c_norm=. if id_alex=="cj_English_0_71" //Jamaica X
replace cj_q34d_norm=. if id_alex=="cj_English_0_71" //Jamaica X
replace cj_q34e_norm=. if id_alex=="cj_English_0_71" //Jamaica X
replace cj_q34e_norm=. if id_alex=="cj_English_0_71" //Jamaica X
replace cj_q34e_norm=. if id_alex=="cj_English_0_71" //Jamaica X
replace cj_q15_norm=. if id_alex=="cj_English_0_422_2017_2018_2019_2021_2022" //Jamaica X
replace cj_q15_norm=. if id_alex=="cj_English_0_375_2017_2018_2019_2021_2022" //Jamaica X
replace cj_q20o_norm=. if id_alex=="cj_English_0_422_2017_2018_2019_2021_2022" //Jamaica X
replace cj_q20o_norm=. if id_alex=="cj_English_0_375_2017_2018_2019_2021_2022" //Jamaica X
replace all_q29_norm=. if id_alex=="cc_English_0_1023_2021_2022" //Jamaica X
replace all_q30_norm=. if id_alex=="cc_English_1_710_2019_2021_2022" //Jamaica X
replace all_q29_norm=. if id_alex=="cc_English_0_668" //Jamaica X
drop if id_alex=="cc_English_1_1382" //Japan
replace all_q62_norm=. if id_alex=="cc_English_1_1174_2018_2019_2021_2022" //Japan
replace cc_q11a_norm=. if id_alex=="cc_English_0_848_2014_2016_2017_2018_2019_2021_2022" //Japan X
replace cc_q13_norm=. if id_alex=="cc_English_0_283" //Japan X
replace all_q88_norm=. if id_alex=="cc_English_0_283" //Japan X
replace cc_q26a_norm=. if id_alex=="cc_English_0_283" //Japan X
replace all_q88_norm=. if id_alex=="cc_English_0_494" //Japan X
replace cc_q26b_norm=. if id_alex=="cc_English_0_283" //Japan X
replace cc_q26b_norm=. if id_alex=="cc_English_1_976_2022" //Japan X
replace all_q90_norm=. if id_alex=="cc_English_1_976_2022" //Japan X
replace all_q91_norm=. if id_alex=="cc_English_1_976_2022" //Japan X
replace all_q96_norm=. if id_alex=="cc_English_1_896_2018_2019_2021_2022" //Japan X
replace all_q96_norm=. if id_alex=="cc_English_0_494" //Japan X
replace lb_q23g_norm=. if id_alex=="lb_English_1_204" //Japan X
replace cj_q15_norm=1 if id_alex=="cj_English_1_261_2017_2018_2019_2021_2022" //Japan X
replace cj_q15_norm=. if id_alex=="cj_English_1_924" //Japan X
replace lb_q19a_norm=. if id_alex=="lb_English_1_260_2018_2019_2021_2022" //Japan X
replace all_q63_norm=1 if id_alex=="lb_English_1_169_2013_2014_2016_2017_2018_2019_2021_2022" //Japan X
replace lb_q2d_norm=1 if id_alex=="lb_English_1_169_2013_2014_2016_2017_2018_2019_2021_2022" //Japan X
replace cc_q11a_norm=. if id_alex=="cc_English_1_1174_2018_2019_2021_2022" //Japan X
replace lb_q23f_norm=. if country=="Jordan" //Jordan
replace lb_q23g_norm=. if country=="Jordan" //Jordan
replace cc_q33_norm=. if country=="Jordan" //Jordan
replace lb_q2d_norm=. if country=="Jordan" //Jordan
replace cj_q7c_norm=. if country=="Jordan" //Jordan
drop if id_alex=="cj_English_0_970" //Jordan
drop if id_alex=="cc_English_0_767" //Jordan
drop if id_alex=="lb_English_1_232" //Jordan
replace cj_q28_norm=. if id_alex=="cj_English_1_596" //Jordan
replace cj_q21e_norm=. if id_alex=="cj_English_1_596" //Jordan
replace all_q96_norm=. if id_alex=="cc_English_0_1492_2017_2018_2019_2021_2022" //Jordan X
replace cj_q33a_norm=. if id_alex=="cj_English_1_596" //Jordan X
replace cj_q33b_norm=. if id_alex=="cj_English_1_596" //Jordan X
replace cj_q33e_norm=. if id_alex=="cj_English_1_596" //Jordan X
replace cj_q28_norm=. if id_alex=="cj_English_1_143" //Jordan X
replace cj_q21e_norm=. if id_alex=="cj_English_1_143" //Jordan X
replace cj_q21g_norm=. if id_alex=="cj_English_1_143" //Jordan X
replace cj_q8_norm=. if country=="Kazakhstan" //Kazakhstan
foreach v of varlist ph_q6a_norm ph_q6b_norm ph_q6c_norm ph_q6d_norm ph_q6e_norm ph_q6f_norm {
replace `v'=. if id_alex=="ph_Russian_0_246_2022" //Kazakhstan
replace `v'=. if id_alex=="ph_Russian_1_17" //Kazakhstan
}
replace all_q62_norm=. if all_q62_norm==1 & country=="Kazakhstan" //Kazakhstan
replace all_q63_norm=. if all_q63_norm==1 & country=="Kazakhstan" //Kazakhstan
replace all_q76_norm=. if id_alex=="cc_Russian_1_961" //Kazakhstan X
replace all_q77_norm=. if id_alex=="cc_Russian_1_961" //Kazakhstan X
replace all_q78_norm=. if id_alex=="cc_Russian_1_961" //Kazakhstan X
replace all_q79_norm=. if id_alex=="cc_Russian_1_961" //Kazakhstan X
replace all_q80_norm=. if id_alex=="cc_Russian_1_961" //Kazakhstan X
replace all_q81_norm=. if id_alex=="cc_Russian_1_961" //Kazakhstan X
replace all_q82_norm=. if id_alex=="cc_Russian_1_961" //Kazakhstan X
replace all_q76_norm=. if id_alex=="cc_Russian_1_438" //Kazakhstan X
replace all_q77_norm=. if id_alex=="cc_Russian_1_438" //Kazakhstan X
replace all_q78_norm=. if id_alex=="cc_Russian_1_438" //Kazakhstan X
replace ph_q6a_norm=0.6666667 if id_alex=="ph_Russian_0_582_2019_2021_2022" //Kazakhstan X
replace ph_q6b_norm=0.6666667 if id_alex=="ph_Russian_0_582_2019_2021_2022" //Kazakhstan X
replace ph_q6c_norm=0.6666667 if id_alex=="ph_Russian_0_582_2019_2021_2022" //Kazakhstan X
replace ph_q6d_norm=0.6666667 if id_alex=="ph_Russian_0_582_2019_2021_2022" //Kazakhstan X
replace ph_q6e_norm=0.6666667 if id_alex=="ph_Russian_0_582_2019_2021_2022" //Kazakhstan X
replace ph_q6f_norm=0.6666667 if id_alex=="ph_Russian_0_582_2019_2021_2022" //Kazakhstan X
replace all_q96_norm=. if id_alex=="cc_Russian_1_781_2018_2019_2021_2022" //Kazakhstan X
replace cj_q12a_norm=. if id_alex=="cj_Russian_1_517" //Kazakhstan X
replace cj_q12b_norm=. if id_alex=="cj_Russian_1_517" //Kazakhstan X
replace cj_q12c_norm=. if id_alex=="cj_Russian_1_517" //Kazakhstan X
replace cj_q12d_norm=. if id_alex=="cj_Russian_1_517" //Kazakhstan X
replace cj_q12e_norm=. if id_alex=="cj_Russian_1_517" //Kazakhstan X
replace cj_q12e_norm=. if id_alex=="cj_English_0_290_2013_2014_2016_2017_2018_2019_2021_2022" //Kazakhstan X
replace cj_q15_norm=. if id_alex=="cj_English_0_662" //Kazakhstan X
replace cj_q12c_norm=. if country=="Kenya" //Kenya
replace cj_q12d_norm=. if country=="Kenya" //Kenya
drop if id_alex=="lb_English_0_408" //Kenya
drop if id_alex=="cj_English_0_554_2021_2022" //Kenya
drop if id_alex=="cc_English_0_540" //Kenya
replace cj_q20o_norm=. if id_alex=="cj_English_1_391" //Kenya
replace cj_q42c_norm=. if id_alex=="cj_English_1_1090_2021_2022" //Kenya X
replace cj_q42d_norm=. if id_alex=="cj_English_1_1090_2021_2022" //Kenya X
replace cj_q42d_norm=. if id_alex=="cj_English_1_1101_2022" //Kenya X
replace cj_q31g_norm=. if id_alex=="cj_English_0_626_2016_2017_2018_2019_2021_2022" //Kenya X
replace cj_q31g_norm=. if id_alex=="cj_English_0_983_2017_2018_2019_2021_2022" //Kenya X
replace all_q48_norm=. if id_alex=="lb_English_0_424" //Kenya X
replace all_q49_norm=. if id_alex=="lb_English_0_424" //Kenya X
replace all_q50_norm=. if id_alex=="lb_English_0_424" //Kenya X
replace lb_q19a_norm=. if id_alex=="lb_English_0_424" //Kenya X
replace all_q49_norm=. if id_alex=="lb_English_0_269" //Kenya X
replace all_q50_norm=. if id_alex=="lb_English_0_269" //Kenya X
replace lb_q19a_norm=. if id_alex=="lb_English_0_269" //Kenya X
replace all_q89_norm=. if id_alex=="cc_English_1_356" //Korea X
replace all_q90_norm=. if id_alex=="cc_English_1_356" //Korea X
replace cj_q15_norm=. if id_alex=="cj_English_0_1047_2017_2018_2019_2021_2022" //Korea X
drop if id_alex=="cc_English_1_156" //Kosovo
drop if id_alex=="cc_English_1_154" //Kosovo
drop if id_alex=="cc_Arabic_0_1052" //Kuwait
drop if id_alex=="cc_English_0_303" //Kuwait
replace cc_q1_norm=. if country=="Kuwait" //Kuwait
replace ph_q3_norm=. if country=="Kuwait" //Kuwait
drop if id_alex=="lb_English_0_691" //Kuwait X
replace all_q57_norm=.6666667 if id_alex=="cc_English_0_1252" //Kuwait X
replace lb_q16a_norm=.6666667 if id_alex=="lb_Arabic_0_466" //Kuwait X
replace lb_q16b_norm=.6666667 if id_alex=="lb_Arabic_0_466" //Kuwait X
replace lb_q16c_norm=.6666667 if id_alex=="lb_Arabic_0_466" //Kuwait X
replace lb_q16d_norm=.6666667 if id_alex=="lb_Arabic_0_466" //Kuwait X
replace lb_q16e_norm=.3333333 if id_alex=="lb_Arabic_0_466" //Kuwait X
replace lb_q16f_norm=.3333333 if id_alex=="lb_Arabic_0_466" //Kuwait X
replace lb_q23f_norm=.3333333 if id_alex=="lb_English_0_535" //Kuwait X
replace lb_q23g_norm=0 if id_alex=="lb_English_0_535" //Kuwait X
replace cc_q40a_norm=. if country=="Kyrgyz Republic" //Kyrgyz Republic
drop if id_alex=="cj_Russian_1_573_2022" //Kyrgyz Republic
drop if id_alex=="cc_Russian_0_1583_2017_2018_2019_2021_2022" //Kyrgyz Republic X 
replace all_q48_norm=. if id_alex=="cc_English_0_155_2017_2018_2019_2021_2022" //Kyrgyz Republic X
replace all_q49_norm=. if id_alex=="cc_English_0_155_2017_2018_2019_2021_2022" //Kyrgyz Republic X
replace all_q85_norm=. if id_alex=="cc_Russian_0_341" //Kyrgyz Republic X
replace all_q87_norm=. if id_alex=="cc_Russian_0_341" //Kyrgyz Republic X
replace cj_q10_norm=. if id_alex=="cj_English_1_940_2018_2019_2021_2022" //Kyrgyz Republic X
replace all_q49_norm=. if country=="Latvia" //Latvia
drop if id_alex=="cc_English_0_836" //Latvia
drop if id_alex=="cj_Russian_1_497" //Latvia
drop if id_alex=="cc_English_1_142" //Latvia
replace all_q89_norm=. if country=="Lebanon" //Lebanon
replace cj_q31g_norm=. if id_alex=="cj_English_1_1062" //Lebanon
replace all_q77_norm=. if country=="Lebanon" //Lebanon
drop if id_alex=="cc_English_1_308_2018_2019_2021_2022" //Lebanon
replace cc_q40a_norm=. if id_alex=="cc_English_0_470" //Lebanon X
replace cc_q40a_norm=. if id_alex=="cc_English_1_274" //Lebanon X
replace cc_q40a_norm=. if id_alex=="cc_English_1_333_2018_2019_2021_2022" //Lebanon X
replace cj_q31f_norm=. if id_alex=="cj_English_1_1062" //Lebanon X
replace all_q81_norm=. if id_alex=="cc_English_1_274" //Lebanon X
replace all_q81_norm=. if id_alex=="cc_English_0_163" //Lebanon X
replace all_q88_norm=. if id_alex=="cc_English_0_403" //Lebanon X
replace cc_q26a_norm=. if id_alex=="cc_English_0_403" //Lebanon X
replace all_q88_norm=. if id_alex=="cc_English_1_1130" //Lebanon X
replace cc_q26a_norm=. if id_alex=="cc_English_1_1130" //Lebanon X
replace all_q84_norm=. if id_alex=="cc_English_0_163" //Lebanon X
replace all_q85_norm=. if id_alex=="cc_English_0_163" //Lebanon X
replace cj_q21g_norm=. if id_alex=="cj_English_0_576_2022" //Lebanon X
replace cj_q21h_norm=. if id_alex=="cj_English_0_576_2022" //Lebanon X
replace cj_q28_norm=. if id_alex=="cj_English_0_576_2022" //Lebanon X
replace cj_q21g_norm=. if id_alex=="cj_English_0_463" //Lebanon X
replace all_q86_norm=. if id_alex=="cc_English_1_917_2022" //Lebanon X
drop if id_alex=="cc_English_0_1099" //Liberia
drop if id_alex=="cj_English_0_670" //Liberia
replace all_q62_norm=. if id_alex=="cc_English_1_360_2022" //Liberia X
replace all_q63_norm=. if id_alex=="cc_English_1_360_2022" //Liberia X
replace cj_q31f_norm=. if id_alex=="cj_English_0_587_2016_2017_2018_2019_2021_2022" //Liberia X
replace cj_q31g_norm=. if id_alex=="cj_English_0_587_2016_2017_2018_2019_2021_2022" //Liberia X
replace all_q62_norm=. if id_alex=="cc_English_0_659_2021_2022" //Liberia X
replace all_q63_norm=. if id_alex=="cc_English_0_659_2021_2022" //Liberia X
replace cc_q16f_norm=. if country=="Lithuania" //Lithuania
replace lb_q16c_norm=. if id_alex=="lb_English_0_347_2022" //Lithuania X
replace lb_q16d_norm=. if id_alex=="lb_English_0_347_2022" //Lithuania X
replace lb_q16f_norm=. if id_alex=="lb_English_0_347_2022" //Lithuania X
replace cj_q15_norm=. if id_alex=="cj_English_0_952_2022" //Lithuania X
replace all_q62_norm=. if id_alex=="lb_English_0_498" //Lithuania X
replace all_q63_norm=. if id_alex=="lb_English_0_498" //Lithuania X
replace lb_q16f_norm=. if id_alex=="lb_English_0_498" //Lithuania X
replace all_q63_norm=. if id_alex=="cc_English_0_455_2022" //Lithuania X
replace lb_q16c_norm=.6666667 if id_alex=="lb_English_0_347_2022" //Lithuania X
replace all_q63_norm=.3333333 if id_alex=="cc_English_0_455_2022" //Lithuania X
replace cj_q7a_norm=. if country=="Luxembourg" //Luxembourg
drop if id_alex=="cc_French_0_65_2021_2022" //Luxembourg
drop if id_alex=="cj_English_0_517_2021_2022" //Luxembourg
drop if id_alex=="cc_English_0_1355_2022" //Luxembourg
replace all_q89_norm=. if country=="Luxembourg" //Luxembourg
replace cj_q21g_norm=. if id_alex=="cj_English_1_1069" //Luxembourg
drop if id_alex=="lb_English_0_224_2022" //Luxembourg X
replace all_q96_norm=. if id_alex=="cj_English_1_1069" //Luxembourg
replace all_q96_norm=. if id_alex=="cc_English_0_1518_2021_2022" //Luxembourg
replace cc_q39a_norm=. if id_alex=="cc_Spanish_0_1112_2022" //Luxembourg
replace cc_q39b_norm=. if id_alex=="cc_Spanish_0_1112_2022" //Luxembourg
replace cc_q39c_norm=. if id_alex=="cc_Spanish_0_1112_2022" //Luxembourg
replace cc_q39d_norm=. if id_alex=="cc_Spanish_0_1112_2022" //Luxembourg
replace lb_q16a_norm=. if id_alex=="lb_English_1_517" //Luxembourg
replace lb_q16b_norm=. if id_alex=="lb_English_1_517" //Luxembourg
replace lb_q16c_norm=. if id_alex=="lb_English_1_517" //Luxembourg
replace lb_q16d_norm=. if id_alex=="lb_English_1_517" //Luxembourg
replace lb_q16e_norm=. if id_alex=="lb_English_1_517" //Luxembourg
replace lb_q16f_norm=. if id_alex=="lb_English_1_517" //Luxembourg
replace cj_q15_norm=. if id_alex=="cj_French_0_395_2021_2022" //Luxembourg
replace all_q63_norm=. if id_alex=="cc_French_0_1739_2021_2022" //Luxembourg
replace cc_q26a_norm=. if id_alex=="cc_French_0_1739_2021_2022" //Luxembourg
replace all_q90_norm=. if id_alex=="cc_French_0_1739_2021_2022" //Luxembourg
replace cj_q15_norm=. if id_alex=="cj_French_0_535_2022" //Luxembourg
drop if id_alex=="cc_French_0_141" //Madagascar
foreach v of varlist cc_q13_norm cc_q26a_norm {
replace `v'=. if id_alex=="cc_French_0_933_2022" //Madagascar
}
replace all_q77_norm=. if id_alex=="lb_French_0_534_2017_2018_2019_2021_2022" //Madagascar
replace all_q82_norm=. if id_alex=="lb_French_0_534_2017_2018_2019_2021_2022" //Madagascar
replace all_q84_norm=. if id_alex=="cc_French_0_933_2022" //Madagascar
replace cc_q11a_norm=. if id_alex=="cc_French_0_933_2022" //Madagascar
foreach v of varlist all_q6_norm cc_q11a_norm all_q3_norm all_q4_norm all_q7_norm { 
replace `v'=. if id_alex=="cc_English_0_396_2021_2022" //Madagascar
replace `v'=. if id_alex=="cc_French_1_369" //Madagascar
}
replace cc_q14a_norm=. if id_alex=="cc_English_0_616" //Madagascar
replace cj_q16j_norm=. if id_alex=="cj_French_0_728"  //Madagascar
replace cj_q33d_norm=. if id_alex=="cj_French_0_66_2021_2022" //Madagascar
replace cj_q33d_norm=. if id_alex=="cj_French_1_729_2022" //Madagascar
replace cj_q21h_norm=. if cj_q21h_norm==1 & country=="Madagascar" //Madagascar
replace cj_q21e_norm=. if id_alex=="cj_French_0_728" //Madagascar
drop if id_alex=="cj_French_0_66_2021_2022" //Madagascar
replace all_q76_norm=. if country=="Malawi" //Malawi
replace all_q77_norm=. if country=="Malawi" //Malawi
replace cc_q25_norm=. if country=="Malawi" //Malawi
replace cj_q38_norm=. if country=="Malawi" //Malawi
drop if id_alex=="cc_English_1_1002" //Malawi
replace all_q41_norm=. if id_alex=="cc_English_0_121" //Malawi
replace all_q43_norm=. if id_alex=="cc_English_0_817_2021_2022" //Malawi
replace cc_q9c_norm=. if cc_q9c_norm==1 & country=="Malawi" //Malawi
replace all_q96_norm=. if id_alex=="cj_English_0_367_2018_2019_2021_2022" //Malawi X
replace all_q96_norm=. if id_alex=="cc_English_0_121" //Malawi X
replace cc_q39b_norm=. if id_alex=="cc_English_0_842_2017_2018_2019_2021_2022" //Malawi X
replace cc_q39b_norm=. if id_alex=="cc_English_0_509" //Malawi X
replace cc_q39c_norm=. if id_alex=="cc_English_0_842_2017_2018_2019_2021_2022" //Malawi X
replace cc_q39c_norm=. if id_alex=="cc_English_0_509" //Malawi X
replace all_q80_norm=. if id_alex=="cc_English_1_1293_2019_2021_2022" //Malawi X
replace all_q81_norm=. if id_alex=="cc_English_1_1293_2019_2021_2022" //Malawi X
replace cc_q26b_norm=. if id_alex=="cc_English_0_121" //Malawi X
replace all_q86_norm=. if id_alex=="cc_English_0_121" //Malawi X
replace all_q87_norm=. if id_alex=="cc_English_0_121" //Malawi X
replace cc_q26b_norm=. if id_alex=="cc_English_1_51_2018_2019_2021_2022" //Malawi X
replace all_q86_norm=. if id_alex=="cc_English_1_51_2018_2019_2021_2022" //Malawi X
replace all_q87_norm=. if id_alex=="cc_English_1_51_2018_2019_2021_2022" //Malawi X
replace all_q89_norm=. if id_alex=="cc_English_0_121" //Malawi X
replace all_q90_norm=. if id_alex=="cc_English_0_121" //Malawi X
replace all_q89_norm=. if id_alex=="cc_English_1_595_2019_2021_2022" //Malawi X
replace cj_q21e_norm=. if id_alex=="cj_English_1_971_2017_2018_2019_2021_2022" //Malawi X
replace cj_q21e_norm=. if id_alex=="cj_English_0_234_2018_2019_2021_2022" //Malawi X
replace cj_q28_norm=. if country=="Malaysia" //Malaysia
drop if id_alex=="cj_English_1_459" //Malaysia
drop if id_alex=="ph_English_0_215" //Malaysia
replace lb_q18c_norm=. if id_alex=="lb_English_0_186_2016_2017_2018_2019_2021_2022" //Malaysia X
replace ph_q9c_norm=.6666667 if id_alex=="ph_English_0_99_2017_2018_2019_2021_2022" //Malaysia X
replace cc_q10_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022" //Malaysia X
replace cc_q33_norm=. if country=="Mali" //Mali
replace all_q24_norm=. if country=="Mali" //Mali 
drop if id_alex=="ph_French_1_714_2021_2022" //Mali
replace cj_q15_norm=. if id_alex=="cj_French_1_996" //Mali
replace cj_q15_norm=. if id_alex=="cj_French_0_155" //Mali
drop if id_alex=="cc_French_0_1197_2021_2022" //Mali X
replace cc_q28e_norm=. if id_alex=="cc_French_0_62_2018_2019_2021_2022" //Mali X
replace cj_q33d_norm=. if id_alex=="cj_French_0_458_2018_2019_2021_2022" //Mali X
replace all_q1_norm=. if id_alex=="cc_French_0_1501_2018_2019_2021_2022" //Mali X
replace all_q20_norm=. if id_alex=="cc_French_0_762_2022" //Mali X
replace all_q21_norm=. if id_alex=="cc_French_0_69_2018_2019_2021_2022" //Mali X
replace all_q20_norm=. if id_alex=="cc_French_0_207_2022" //Mali X
replace cj_q34a_norm=. if id_alex=="cj_French_0_1348_2018_2019_2021_2022" //Mali X
replace cj_q34b_norm=. if id_alex=="cj_French_0_1348_2018_2019_2021_2022" //Mali X
replace all_q20_norm=. if id_alex=="lb_French_0_311_2022" //Mali X
replace cc_q25_norm=. if id_alex=="cc_French_0_149_2018_2019_2021_2022" //Mali X
replace all_q4_norm=. if id_alex=="cc_French_0_69_2018_2019_2021_2022" //Mali X
replace all_q4_norm=. if id_alex=="cj_French_1_1104_2021_2022" //Mali X
replace all_q8_norm=. if id_alex=="cc_French_0_1501_2018_2019_2021_2022" //Mali X
replace all_q1_norm=. if id_alex=="cc_French_0_69_2018_2019_2021_2022" //Mali X
replace all_q19_norm=. if id_alex=="cc_French_1_1190" //Mali X
replace all_q19_norm=. if id_alex=="cc_French_0_1501_2018_2019_2021_2022" //Mali X
replace cj_q10_norm=. if id_alex=="cj_French_0_649_2018_2019_2021_2022" //Mali X
replace all_q15_norm=. if id_alex=="cc_French_0_1501_2018_2019_2021_2022" //Mali X
replace all_q16_norm=. if id_alex=="cc_French_0_1501_2018_2019_2021_2022" //Mali X
replace lb_q17c_norm=. if id_alex=="lb_French_0_583_2018_2019_2021_2022" //Mali X
replace cc_q28b_norm=. if id_alex=="cc_French_0_54_2018_2019_2021_2022" //Mali X
replace cc_q28c_norm=. if id_alex=="cc_French_0_62_2018_2019_2021_2022" //Mali X
replace ph_q12c_norm=. if id_alex=="ph_French_1_62_2019_2021_2022" //Mali X
replace cj_q11a_norm=. if id_alex=="cj_French_0_649_2018_2019_2021_2022" //Mali X
replace cj_q11b_norm=. if id_alex=="cj_French_0_649_2018_2019_2021_2022" //Mali X
replace cc_q26a_norm=. if id_alex=="cc_French_0_1078" //Mali X
replace all_q88_norm=. if id_alex=="cc_French_0_207_2022" //Mali X
replace cc_q11a_norm=. if id_alex=="cc_French_0_62_2018_2019_2021_2022" //Mali X
replace cc_q11a_norm=. if id_alex=="cc_French_0_56_2018_2019_2021_2022" //Mali X
replace cj_q40b_norm=. if id_alex=="cj_French_1_1104_2021_2022" //Mali X
replace cj_q20e_norm=. if id_alex=="cj_French_0_155" //Mali X
replace cj_q21e_norm=. if id_alex=="cj_French_1_1049" //Mali X
replace lb_q19a_norm=. if country=="Malta" //Malta
replace cc_q26b_norm=. if id_alex=="cc_English_0_355" //Malta
replace all_q86_norm=. if id_alex=="cc_English_0_355" //Malta
replace cj_q7a_norm=. if id_alex=="cj_English_1_681" //Malta
replace cj_q27a_norm=. if country=="Malta" //Malta
replace cj_q20b_norm=. if country=="Malta" //Malta
replace cj_q21g_norm=. if id_alex=="cj_English_1_681" //Malta
replace cj_q28_norm=. if id_alex=="cj_English_0_786" //Malta
replace all_q58_norm=. if id_alex=="cc_English_1_908" //Malta X
replace all_q61_norm=. if id_alex=="cc_English_0_40_2022" //Malta X
replace cj_q15_norm=. if id_alex=="cj_English_0_786" //Malta X
replace all_q62_norm=. if id_alex=="lb_English_1_637" //Malta X
replace all_q63_norm=. if id_alex=="lb_English_1_637" //Malta X
replace all_q82_norm=. if id_alex=="lb_English_0_326_2022" //Malta X
replace cj_q40b_norm=. if id_alex=="cj_English_0_550_2021_2022" //Malta X
drop if id_alex=="ph_English_0_266" //Malta X
replace cc_q39b_norm=. if id_alex=="cc_English_0_355" //Malta X
replace all_q63_norm=. if id_alex=="cc_English_0_1463_2022" //Malta X
replace all_q49_norm=. if id_alex=="cc_English_0_534_2021_2022" //Malta X
replace all_q50_norm=. if id_alex=="cc_English_0_534_2021_2022" //Malta X
replace cj_q21a_norm=. if id_alex=="cj_English_0_351_2021_2022" //Malta X
replace cj_q40b_norm=0.66666667 if id_alex=="cj_English_0_550_2021_2022" //Malta X
replace cj_q12a_norm=. if cj_q12a_norm==0 & country=="Mauritania" //Mauritania
drop if id_alex=="cj_French_0_325_2021_2022" //Mauritania X
replace cj_q21e_norm=. if id_alex=="cj_French_1_1261_2019_2021_2022" //Mauritania X
replace cj_q21g_norm=. if id_alex=="cj_French_1_1261_2019_2021_2022" //Mauritania X
replace cj_q12c_norm=. if id_alex=="cj_English_0_542_2018_2019_2021_2022" //Mauritania X
replace cj_q12d_norm=. if id_alex=="cj_English_0_542_2018_2019_2021_2022" //Mauritania X
replace cj_q12e_norm=. if id_alex=="cj_English_0_542_2018_2019_2021_2022" //Mauritania X
replace cj_q12f_norm=. if id_alex=="cj_English_0_542_2018_2019_2021_2022" //Mauritania X
replace cj_q31f_norm=. if id_alex=="cj_French_1_1261_2019_2021_2022" //Mauritania X
replace cj_q21e_norm=. if id_alex=="cj_French_1_1181_2019_2021_2022" //Mauritania X
replace all_q31_norm=. if id_alex=="cc_French_1_1345_2019_2021_2022" //Mauritania X
replace all_q32_norm=. if id_alex=="cc_French_1_1345_2019_2021_2022" //Mauritania X
replace all_q14_norm=. if id_alex=="cc_French_1_1345_2019_2021_2022" //Mauritania X
replace all_q31_norm=. if id_alex=="cc_French_0_1654_2021_2022" //Mauritania X
replace all_q32_norm=. if id_alex=="cc_French_0_1654_2021_2022" //Mauritania X
replace all_q14_norm=. if id_alex=="cc_French_0_1654_2021_2022" //Mauritania X
replace all_q31_norm=. if id_alex=="cc_French_0_532_2021_2022" //Mauritania X
replace all_q32_norm=. if id_alex=="cc_French_0_532_2021_2022" //Mauritania X
replace all_q14_norm=. if id_alex=="cc_French_0_532_2021_2022" //Mauritania X
replace cj_q12f_norm=0.33333333 if id_alex=="cj_English_0_542_2018_2019_2021_2022" //Mauritania X
drop if id_alex=="ph_English_1_57_2019_2021_2022" //Mauritius
replace cj_q31e_norm=. if id_alex=="cj_English_0_441" //Mauritius
replace cj_q42d_norm=. if cj_q42d_norm==0 & country=="Mauritius" //Mauritius
replace cj_q31f_norm=. if cj_q31f_norm==0 & country=="Mauritius" //Mauritius
drop if id_alex=="cc_English_1_678" //Mauritius
drop if id_alex=="cj_English_1_684" //Mauritius
replace cj_q15_norm=. if id_alex=="cj_English_1_986_2019_2021_2022" //Mauritius
replace cj_q15_norm=. if id_alex=="cj_English_1_730" //Mauritius
drop if id_alex=="cc_English_0_649_2018_2019_2021_2022" //Marutius X
replace cj_q15_norm=. if id_alex=="cj_English_1_330_2019_2021_2022" //Marutius X
replace cj_q15_norm=. if id_alex=="cj_English_0_428" //Marutius X
replace all_q96_norm=. if id_alex=="cc_English_1_310" //Marutius X
replace all_q96_norm=. if id_alex=="cj_English_0_880_2021_2022" //Marutius X
replace ph_q12e_norm=. if id_alex=="ph_English_0_218_2018_2019_2021_2022" //Marutius X
replace cj_q29a_norm=. if country=="Mexico" //Mexico
replace cj_q29b_norm=. if country=="Mexico" //Mexico
replace all_q78_norm=. if country=="Mexico" //Mexico
replace all_q86_norm=. if country=="Mexico" //Mexico
drop if id_alex=="cc_Spanish_1_1354_2022" //Mexico
drop if id_alex=="cc_es-mx_1_613_2017_2018_2019_2021_2022" //Mexico
drop if id_alex=="cc_English_1_760_2017_2018_2019_2021_2022" //Mexico
drop if id_alex=="cj_Spanish_1_58" //Mexico
drop if id_alex=="cj_Spanish_1_202" //Mexico 
replace all_q21_norm=. if id_alex=="cc_Spanish (Mexico)_1_184_2019_2021_2022" //Mexico X
replace all_q21_norm=. if id_alex=="cc_Spanish_0_487_2022" //Mexico X
replace all_q21_norm=. if id_alex=="lb_Spanish_1_359_2019_2021_2022" //Mexico X
replace all_q7_norm=. if id_alex=="lb_Spanish_0_614_2017_2018_2019_2021_2022" //Mexico X
replace all_q2_norm=. if id_alex=="lb_Spanish_0_572_2018_2019_2021_2022" //Mexico X
replace cc_q33_norm=. if id_alex=="cc_Spanish_1_83_2021_2022" //Mexico X
replace cj_q33a_norm=. if id_alex=="cj_Spanish_0_955_2017_2018_2019_2021_2022" //Mexico X
replace all_q29_norm=. if id_alex=="cc_Spanish_1_148" //Mexico X
replace all_q29_norm=. if id_alex=="cj_Spanish_1_78" //Mexico X
replace all_q30_norm=. if id_alex=="cj_Spanish_1_78" //Mexico X
replace all_q29_norm=. if id_alex=="cj_Spanish_0_224_2022" //Mexico X
replace all_q30_norm=. if id_alex=="cc_English_1_1001_2022" //Mexico X
drop if id_alex=="cj_English_0_671" //Moldova
drop if id_alex=="ph_Russian_0_103" //Moldova
drop if id_alex=="lb_English_0_519_2022" //Moldova
replace all_q96_norm=. if id_alex=="cc_English_0_1024_2017_2018_2019_2021_2022" //Moldova X
replace all_q96_norm=. if id_alex=="cc_Russian_0_150_2018_2019_2021_2022" //Moldova X
replace all_q96_norm=. if id_alex=="cj_Russian_1_720_2021_2022" //Moldova X
replace cc_q39a_norm=. if id_alex=="cc_English_0_780_2018_2019_2021_2022" //Moldova X
replace cc_q39b_norm=. if id_alex=="cc_English_0_780_2018_2019_2021_2022" //Moldova X
replace cc_q39c_norm=. if id_alex=="cc_English_0_780_2018_2019_2021_2022" //Moldova X
replace all_q30_norm=. if id_alex=="cc_English_0_689_2021_2022" //Moldova X
replace cj_q40b_norm=. if id_alex=="cj_English_1_486" //Moldova X
replace cj_q40c_norm=. if id_alex=="cj_English_1_486" //Moldova X
replace cj_q20m_norm=. if id_alex=="cj_English_1_486" //Moldova X
drop if  id_alex=="cj_English_0_91" //Moldova X
replace cj_q40c_norm=. if id_alex=="cj_Russian_0_1174_2019_2021_2022" //Moldova X
replace cj_q33e_norm=. if id_alex=="cj_English_0_776" //Montenegro X
replace all_q57_norm=. if id_alex=="cc_English_0_413" //Montenegro X
replace all_q58_norm=. if id_alex=="cj_English_0_413" //Montenegro X
replace all_q59_norm=. if id_alex=="cj_English_0_413" //Montenegro X
replace cj_q40b_norm=. if cj_q40b_norm==0 & country=="Mongolia" //Mongolia
drop if id_alex=="cc_English_0_1151_2018_2019_2021_2022" //Mongolia X
replace all_q49_norm=. if country=="Montenegro" //Montenegro
replace cj_q27b_norm=. if country=="Morocco" //Morocco
replace all_q1_norm=. if country=="Morocco" //Morocco
drop if id_alex=="cc_French_1_646" //Morocco
drop if id_alex=="cc_French_1_562" //Morocco
drop if id_alex=="cc_French_0_788" //Morocco
drop if id_alex=="cj_Arabic_0_544" //Morocco
replace cj_q38_norm=. if id_alex=="cj_Arabic_0_966" //Morocco
replace cj_q36c_norm=. if id_alex=="cj_French_1_514" //Morocco
replace cj_q8_norm=. if cj_q8_norm==1 & country=="Morocco" //Morocco
replace cj_q11a_norm=. if cj_q11a_norm==1 & country=="Morocco" //Morocco
replace cj_q11b_norm=. if cj_q11b_norm==1 & country=="Morocco" //Morocco
replace cj_q31e_norm=. if cj_q31e_norm==1 & country=="Morocco" //Morocco
replace cj_q42c_norm=. if cj_q42c_norm==1 & country=="Morocco" //Morocco
replace cj_q42d_norm=. if cj_q42d_norm==1 & country=="Morocco" //Morocco
replace cj_q15_norm=. if id_alex=="cj_Arabic_0_966" //Morocco
drop if id_alex=="cj_French_1_668" //Morocco
replace lb_q2d_norm=. if id_alex=="lb_Arabic_0_649" //Morocco X
replace lb_q3d_norm=. if id_alex=="lb_Arabic_0_649" //Morocco X
replace cj_q40b_norm=. if id_alex=="cj_Arabic_1_574_2021_2022" //Morocco X
replace cj_q40c_norm=. if id_alex=="cj_Arabic_0_966" //Morocco X
replace cj_q3b_norm=. if country=="Mozambique" //Mozambique
replace cj_q3c_norm=. if country=="Mozambique" //Mozambique
replace cj_q6d_norm=. if country=="Mozambique" //Mozambique
replace cj_q21h_norm=. if country=="Mozambique" //Mozambique
replace all_q1_norm=. if country=="Mozambique" //Mozambique
replace cj_q20m_norm=. if country=="Mozambique" //Mozambique
replace all_q85_norm=. if id_alex=="cc_English_0_1130" //Mozambique
replace all_q87_norm=. if id_alex=="lb_English_1_272_2019_2021_2022" //Mozambique
drop if id_alex=="cc_English_0_695" //Mozambique
replace all_q90_norm=. if country=="Mozambique" //Mozambique
replace cj_q40b_norm=. if id_alex=="cj_English_1_976" //Mozambique
replace cj_q40c_norm=. if id_alex=="cj_English_1_976" //Mozambique
drop if id_alex=="cc_Portuguese_0_147_2018_2019_2021_2022" //Mozambique X
replace cj_q11b_norm=. if id_alex=="cj_Portuguese_0_188_2021_2022" //Mozambique X
replace cj_q31e_norm=. if id_alex=="cj_Portuguese_0_188_2021_2022" //Mozambique X
replace cj_q42c_norm=. if id_alex=="cj_Portuguese_0_188_2021_2022" //Mozambique X
replace cj_q42d_norm=. if id_alex=="cj_Portuguese_0_188_2021_2022" //Mozambique X
replace cj_q42d_norm=. if id_alex=="cj_Portuguese_0_889" //Mozambique X
replace cj_q31f_norm=. if id_alex=="cj_Portuguese_0_188_2021_2022" //Mozambique X
replace cj_q31g_norm=. if id_alex=="cj_Portuguese_0_188_2021_2022" //Mozambique X
replace all_q87_norm=. if id_alex=="cc_Portuguese_1_1545_2019_2021_2022" //Mozambique X
replace all_q87_norm=. if id_alex=="cc_English_0_335_2021_2022" //Mozambique X
replace cj_q42c_norm=. if id_alex=="cj_English_1_976" //Mozambique X
replace cj_q42d_norm=. if id_alex=="cj_English_1_976" //Mozambique X
replace cj_q31f_norm=. if id_alex=="cj_Portuguese_0_647" //Mozambique X
replace cj_q20o_norm=. if id_alex=="cj_Portuguese_0_889" //Mozambique X
replace cj_q34e_norm=. if id_alex=="cj_Portuguese_0_889" //Mozambique X
replace cj_q11a_norm=. if country=="Myanmar" //Myanmar
replace cj_q11b_norm=. if country=="Myanmar" //Myanmar
replace cj_q6b_norm=. if country=="Myanmar" //Myanmar
replace cj_q6c_norm=. if country=="Myanmar" //Myanmar
replace cj_q6d_norm=. if country=="Myanmar" //Myanmar
drop if id_alex=="cc_English_0_233_2019_2021_2022" //Myanmar
drop if id_alex=="cc_English_1_1011_2021_2022" //Myanmar
drop if id_alex=="lb_English_1_245" //Myanmar
replace cj_q16a_norm=. if id_alex=="cj_English_0_795" //Myanmar
replace cj_q16f_norm=. if id_alex=="cj_English_0_795" //Myanmar
replace cj_q16f_norm=. if id_alex=="cj_English_1_303" //Myanmar
replace cj_q27a_norm=. if id_alex=="cj_English_0_973" //Myanmar
replace cj_q7b_norm=. if cj_q7b_norm==1 & country=="Myanmar" //Myanmar 
replace cj_q28_norm=. if id_alex=="cj_English_0_973" //Myanmar
replace cj_q22d_norm=. if id_alex=="cj_English_0_497" //Myanmar
replace cj_q22e_norm=. if id_alex=="cj_English_0_497" //Myanmar
replace cj_q22e_norm=. if id_alex=="cj_English_1_303"  //Myanmar
replace cj_q3c_norm=. if cj_q3c_norm==1 & country=="Myanmar" //Myanmar
drop if id_alex=="cj_English_0_973" //Myanmar X
drop if id_alex=="cc_English_0_548_2017_2018_2019_2021_2022" //Myanmar X
replace cj_q40b_norm=. if id_alex=="cj_English_0_795" //Myanmar
replace cj_q40c_norm=. if id_alex=="cj_English_0_795" //Myanmar
replace cj_q3a_norm=. if id_alex=="cj_English_0_795" //Myanmar
replace cj_q3b_norm=. if id_alex=="cj_English_0_795" //Myanmar
replace all_q15_norm=. if id_alex=="cj_English_0_795" //Myanmar
replace all_q16_norm=. if id_alex=="cj_English_0_795" //Myanmar
replace all_q18_norm=. if id_alex=="cj_English_0_795" //Myanmar
replace all_q19_norm=. if id_alex=="cj_English_0_795" //Myanmar
replace all_q20_norm=. if id_alex=="cj_English_0_795" //Myanmar
replace all_q21_norm=. if id_alex=="cj_English_0_795" //Myanmar
replace all_q89_norm=. if id_alex=="cc_English_0_1081_2017_2018_2019_2021_2022" //Myanmar
replace all_q90_norm=. if id_alex=="cc_English_0_769" //Myanmar
replace all_q76_norm=. if country=="Namibia" // Namibia
drop if id_alex=="cc_English_1_464" //Namibia
replace cj_q28_norm=. if id_alex=="cj_English_0_157" //Namibia
replace cj_q21e_norm=. if id_alex=="cj_English_0_157" //Namibia 
replace cj_q21g_norm=. if id_alex=="cj_English_0_157" //Namibia
replace cj_q21a_norm=. if id_alex=="cj_English_0_157" //Namibia
replace cj_q20m_norm=. if id_alex=="cj_English_0_723" //Namibia X
drop if id_alex=="cj_English_0_787" //Nepal
drop if id_alex=="cc_English_1_231_2017_2018_2019_2021_2022" //Nepal
drop if id_alex=="cc_English_1_585" //Nepal
drop if id_alex=="cc_English_1_214" //Nepal
replace cc_q33_norm=. if country=="Nepal" //Nepal
replace cj_q11b_norm=. if country=="Nepal" //Nepal
replace cj_q31f_norm=. if cj_q31f_norm==1 & country=="Nepal" //Nepal
replace cj_q31g_norm=. if cj_q31g_norm==1 & country=="Nepal" //Nepal
replace cj_q42c_norm=. if cj_q42c_norm==1 & country=="Nepal" //Nepal 
replace cj_q42d_norm=. if cj_q42d_norm==1 & country=="Nepal" //Nepal
replace cj_q32b_norm=. if cj_q32b_norm==1 & country=="Nepal" //Nepal 
replace cj_q24b_norm=. if cj_q24b_norm==0.75 & country=="Nepal" //Nepal
replace cj_q33b_norm=. if cj_q33b_norm==1 & country=="Nepal" //Nepal
replace cj_q33d_norm=. if cj_q33d_norm==1 & country=="Nepal" //Nepal
replace cj_q33e_norm=. if cj_q33e_norm==1 & country=="Nepal" //Nepal
replace cj_q32d_norm=. if country=="Nepal"
replace cj_q34a_norm=. if cj_q34a_norm==1 & country=="Nepal" //Nepal
replace cj_q34b_norm=. if cj_q34b_norm==1 & country=="Nepal" //Nepal
replace cj_q34d_norm=. if cj_q34d_norm==1 & country=="Nepal" //Nepal
replace cj_q33a_norm=. if cj_q33a_norm==1 & country=="Nepal" //Nepal
replace cj_q24c_norm=. if cj_q24c_norm==0.75 & country=="Nepal" //Nepal
drop if id_alex=="cj_English_0_715" //Nepal X
drop if id_alex=="cj_English_0_442" //Nepal X
replace all_q89_norm=. if id_alex=="cc_English_0_1328_2019_2021_2022" //Nepal X
replace all_q89_norm=. if id_alex=="cc_English_0_232" //Nepal X
replace all_q59_norm=. if id_alex=="cc_English_1_1560_2021_2022" //Nepal X
replace all_q59_norm=. if id_alex=="cc_English_1_975" //Nepal X
replace all_q90_norm=. if id_alex=="cc_English_0_744" //Nepal X
replace all_q86_norm=. if id_alex=="cc_English_0_856_2021_2022" //Nepal X
replace all_q86_norm=. if id_alex=="cc_English_0_1922_2018_2019_2021_2022" //Nepal X
replace all_q86_norm=. if id_alex=="cj_English_0_738" //Nepal X
replace cj_q28_norm=. if id_alex=="cj_English_0_738" //Nepal X
replace cj_q28_norm=. if id_alex=="cj_English_0_577" //Nepal X
replace cj_q20o_norm=. if id_alex=="cj_English_0_108" //Nepal X
replace cj_q20k_norm=. if id_alex=="cj_English_0_377" //Nepal X
replace cj_q28_norm=.25 if id_alex=="cj_English_1_772" //Nepal X
replace cj_q15_norm=. if id_alex=="cj_English_0_108" //Nepal X
replace cj_q15_norm=0.6666667 if id_alex=="cj_English_0_547_2016_2017_2018_2019_2021_2022" //Nepal X
replace all_q89_norm=. if id_alex=="cc_English_0_847" //Netherlands X
replace cj_q27b_norm=. if id_alex=="cj_English_0_372" //Netherlands X
drop if id_alex=="cc_Spanish_0_85" //Nicaragua
drop if id_alex=="cj_Spanish_0_897_2014_2016_2017_2018_2019_2021_2022" //Nicaragua
replace cc_q39b_norm=. if id_alex=="cc_Spanish_0_499_2016_2017_2018_2019_2021_2022" //Nicaragua X
replace cc_q39b_norm=. if id_alex=="cc_Spanish_1_527_2016_2017_2018_2019_2021_2022" //Nicaragua X
replace cc_q39c_norm=. if id_alex=="cc_Spanish_0_499_2016_2017_2018_2019_2021_2022" //Nicaragua X
replace cc_q39c_norm=. if id_alex=="cc_Spanish_1_527_2016_2017_2018_2019_2021_2022" //Nicaragua X
replace all_q30_norm=. if id_alex=="cc_English_1_1490_2021_2022" //Nicaragua X
replace all_q30_norm=. if id_alex=="cc_Spanish_0_955" //Nicaragua X
replace all_q78_norm=. if id_alex=="cc_Spanish_0_207_2021_2022" //Nicaragua X
replace all_q80_norm=. if id_alex=="cc_Spanish_0_207_2021_2022" //Nicaragua X
replace cj_q21d_norm=. if id_alex=="cj_Spanish_1_982_2021_2022" //Nicaragua X
replace cj_q19a_norm=. if id_alex=="cj_Spanish_0_565" //Nicaragua X
replace cj_q3b_norm=. if id_alex=="cj_Spanish_0_101_2017_2018_2019_2021_2022" //Nicaragua X
replace cj_q11a_norm=. if id_alex=="cj_English_1_229" //Nicaragua X
replace cj_q22b_norm=. if id_alex=="cj_Spanish_0_567" //Nicaragua X
replace cj_q22d_norm=. if id_alex=="cj_Spanish_0_567" //Nicaragua X
replace cj_q19a_norm=. if id_alex=="cj_Spanish_0_200_2019_2021_2022" //Nicaragua X
replace cj_q19b_norm=. if id_alex=="cj_Spanish_0_200_2019_2021_2022" //Nicaragua X
replace cj_q19c_norm=. if id_alex=="cj_Spanish_0_200_2019_2021_2022" //Nicaragua X
replace cj_q3a_norm=. if id_alex=="cj_Spanish_0_101_2017_2018_2019_2021_2022" //Nicaragua X
replace cj_q21d_norm=. if id_alex=="cj_Spanish_0_567" //Nicaragua X
replace cj_q21f_norm=. if id_alex=="cj_Spanish_1_982_2021_2022" //Nicaragua X
replace cj_q21d_norm=. if id_alex=="cj_English_1_1064" //Nicaragua X
replace lb_q19a_norm=. if country=="Niger" /*Niger*/ 
replace all_q84_norm=. if country=="Niger"  /*Niger*/
replace all_q85_norm=. if country=="Niger" /*Niger*/
replace all_q2_norm=. if country=="Niger"  /*Niger*/
replace all_q46_norm=. if country=="Niger"  /*Niger*/
replace all_q47_norm=. if country=="Niger"  /*Niger*/
replace lb_q2d_norm=. if country=="Niger" //Niger
replace cc_q16b_norm=. if country=="Niger" //Niger
replace cc_q16e_norm=. if country=="Niger" //Niger
drop if id_alex=="ph_French_1_612_2022" //Niger
drop if id_alex=="cj_French_0_484" //Niger
drop if id_alex=="cc_French_0_442" //Niger
drop if id_alex=="cc_French_0_293" //Niger
drop if id_alex=="cc_French_0_210_2022" //Niger
replace cj_q20o_norm=. if id_alex=="cj_French_0_224" //Niger
replace cc_q11a_norm=. if country=="Niger" /*Niger*/
replace cc_q13_norm=. if id_alex=="cc_French_0_352" //Niger
replace cc_q40a_norm=. if id_alex=="cc_French_0_352" //Niger
replace cc_q40b_norm=. if id_alex=="cc_French_0_352" //Niger
replace cj_q15_norm=. if id_alex=="cj_French_1_921" //Niger
drop if id_alex=="lb_English_1_529_2018_2019_2021_2022" //Nigeria
replace all_q96_norm=. if id_alex=="cc_English_1_39" //North Macedonia
replace cc_q40a_norm=. if country=="North Macedonia" //North Macedonia
replace lb_q2d_norm=. if id_alex=="lb_English_0_92"  //North Macedonia
replace all_q1_norm=. if all_q1_norm==0 & country=="North Macedonia" //North Macedonia
replace all_q3_norm=. if all_q3_norm==0 & country=="North Macedonia" //North Macedonia
replace all_q1_norm=1 if id_alex=="cc_English_0_1713_2017_2018_2019_2021_2022" //North Macedonia X
replace all_q1_norm=. if id_alex=="lb_English_1_387_2018_2019_2021_2022" //North Macedonia X
replace all_q2_norm=. if id_alex=="lb_English_1_580_2017_2018_2019_2021_2022" //North Macedonia X
replace all_q20_norm=. if id_alex=="lb_English_1_580_2017_2018_2019_2021_2022" //North Macedonia X
replace all_q21_norm=. if id_alex=="lb_English_1_580_2017_2018_2019_2021_2022" //North Macedonia X
replace all_q2_norm=. if id_alex=="cj_English_1_220_2021_2022" //North Macedonia X
replace all_q2_norm=. if id_alex=="cc_English_0_367" //North Macedonia X
replace all_q4_norm=. if id_alex=="cj_English_1_220_2021_2022" //North Macedonia X
replace all_q5_norm=. if id_alex=="cj_English_1_220_2021_2022" //North Macedonia X
replace all_q6_norm=. if id_alex=="cj_English_1_220_2021_2022" //North Macedonia X
replace all_q7_norm=. if id_alex=="cj_English_1_220_2021_2022" //North Macedonia X
replace all_q8_norm=. if id_alex=="cj_English_1_220_2021_2022" //North Macedonia X
replace all_q4_norm=. if id_alex=="cc_English_0_367" //North Macedonia X
replace all_q5_norm=. if id_alex=="cc_English_0_367" //North Macedonia X
replace all_q6_norm=. if id_alex=="cc_English_0_367" //North Macedonia X
replace all_q7_norm=. if id_alex=="cc_English_0_367" //North Macedonia X
replace all_q8_norm=. if id_alex=="cc_English_0_367" //North Macedonia X
replace all_q4_norm=. if id_alex=="lb_English_1_580_2017_2018_2019_2021_2022" //North Macedonia X
replace all_q5_norm=. if id_alex=="lb_English_1_580_2017_2018_2019_2021_2022" //North Macedonia X
replace all_q6_norm=. if id_alex=="lb_English_1_580_2017_2018_2019_2021_2022" //North Macedonia X
replace all_q7_norm=. if id_alex=="lb_English_1_580_2017_2018_2019_2021_2022" //North Macedonia X
replace all_q8_norm=. if id_alex=="lb_English_1_580_2017_2018_2019_2021_2022" //North Macedonia X
replace cc_q25_norm=. if id_alex=="cc_English_0_615_2018_2019_2021_2022" //North Macedonia X
replace cc_q25_norm=. if id_alex=="cc_English_1_403_2017_2018_2019_2021_2022" //North Macedonia X
replace cc_q25_norm=. if id_alex=="cc_English_1_384_2018_2019_2021_2022" //North Macedonia X
replace cc_q25_norm=. if id_alex=="cc_English_1_1374_2021_2022" //North Macedonia X
replace lb_q3d_norm=. if id_alex=="lb_English_0_92" //North Macedonia X
replace all_q8_norm=. if id_alex=="cc_English_0_395_2021_2022" //North Macedonia X
replace all_q89_norm=. if country=="Norway" /*Norway*/
drop if id_alex=="cj_English_0_407" //Norway X
drop if id_alex=="cc_English_0_840" //Norway X
replace all_q86_norm=. if id_alex=="cc_English_0_952" //Norway X
replace all_q86_norm=. if id_alex=="lb_English_0_672" //Norway X
replace cj_q11b_norm=. if id_alex=="cj_English_1_649" //Pakistan
replace cj_q31e_norm=. if id_alex=="cj_English_1_649" //Pakistan
replace cj_q42c_norm=. if id_alex=="cj_English_0_398" //Pakistan
replace cj_q15_norm=. if id_alex=="cj_English_0_276_2016_2017_2018_2019_2021_2022" //Pakistan X
replace cj_q15_norm=. if id_alex=="cj_English_1_369_2018_2019_2021_2022" //Pakistan X
replace cj_q8_norm=. if id_alex=="cj_English_0_625_2016_2017_2018_2019_2021_2022" //Pakistan X
drop if id_alex=="cj_English_1_791" //Pakistan X
replace cj_q40b_norm=. if id_alex=="cj_English_0_1152_2022" //Pakistan X
replace cj_q40c_norm=. if id_alex=="cj_English_0_1152_2022" //Pakistan X
replace all_q3_norm=. if id_alex=="cj_English_0_1152_2022" //Pakistan X
replace all_q4_norm=. if id_alex=="cj_English_0_1152_2022" //Pakistan X
replace all_q7_norm=. if id_alex=="cj_English_0_1152_2022" //Pakistan X
replace all_q84_norm=. if id_alex=="cc_English_0_668_2018_2019_2021_2022" //Pakistan X
replace all_q84_norm=. if id_alex=="cc_English_1_1301_2019_2021_2022" //Pakistan X
replace all_q96_norm=. if id_alex=="cc_English_0_1473_2016_2017_2018_2019_2021_2022" //Pakistan X
replace all_q96_norm=. if id_alex=="cc_English_0_1285_2017_2018_2019_2021_2022" //Pakistan X
replace cj_q11b_norm=. if id_alex=="cj_English_0_625_2016_2017_2018_2019_2021_2022" //Pakistan X
replace cj_q11b_norm=. if id_alex=="cj_English_1_369_2018_2019_2021_2022" //Pakistan X
drop if id_alex=="cj_English_1_1079_2022" //Panama
drop if id_alex=="lb_English_1_726" //Panama
replace cj_q40c_norm=. if id_alex=="cj_Spanish_0_572_2021_2022" //Panama
drop if id_alex=="cc_Spanish_0_1062" //Panama X
replace lb_q19a_norm=. if id_alex=="lb_Spanish_0_184" //Panama X
replace cj_q42c_norm=. if country=="Paraguay" /*Paraguay*/
replace cj_q42d_norm=. if country=="Paraguay" /*Paraguay*/
replace cj_q6d_norm=. if country=="Paraguay" /*Paraguay*/
replace cc_q14b_norm=. if country=="Paraguay" /*Paraguay*/
drop if id_alex=="cc_English_1_366_2022" //Paraguay
drop if id_alex=="lb_Spanish_0_363_2021_2022" //Paraguay
replace cc_q33_norm=. if id_alex=="cc_Spanish_1_421" //Paraguay
replace cj_q36c_norm=. if id_alex=="cj_Spanish_0_669" //Paraguay
replace cj_q36c_norm=. if id_alex=="cj_Spanish_0_448" //Paraguay
replace cj_q34a_norm=. if id_alex=="cj_Spanish_0_182" //Paraguay
replace all_q86_norm=. if id_alex=="cc_Spanish_0_721_2021_2022" //Paraguay
replace cj_q34a_norm=. if id_alex=="cj_Spanish_0_182" //Paraguay
replace cj_q33e_norm=. if id_alex=="cj_Spanish_0_669" //Paraguay
replace all_q57_norm=. if all_q57_norm==0 & country=="Paraguay" //Paraguay
replace all_q58_norm=. if id_alex=="cc_Spanish_0_1128" //Paraguay
replace cc_q28e_norm=. if cc_q28e_norm==0 & country=="Paraguay" //Paraguay
replace all_q51_norm=. if id_alex=="cc_Spanish_0_1128" //Paraguay
drop if id_alex=="cj_Spanish_0_669" //Paraguay
drop if id_alex=="cc_Spanish_0_988_2021_2022" //Paraguay
foreach v in cc_q26b_norm all_q86_norm all_q87_norm {
replace `v'=. if id_alex=="cc_Spanish_0_1128" //Paraguay
replace `v'=. if id_alex=="cc_Spanish_0_1025" //Paraguay
}
replace cc_q33_norm=0 if id_alex=="cc_Spanish_1_133" //Paraguay X
replace all_q9_norm=. if id_alex=="cj_Spanish_0_448" //Paraguay X
replace cj_q8_norm=. if id_alex=="cj_Spanish_0_718" //Paraguay X
replace cj_q32b_norm=. if id_alex=="cj_Spanish_0_301" //Paraguay X
replace cj_q34b_norm=. if id_alex=="cj_Spanish_0_182" //Paraguay X
replace cj_q18a_norm=. if id_alex=="cj_Spanish_0_301" //Paraguay X
replace lb_q23b_norm=. if id_alex=="lb_Spanish_0_807_2021_2022" //Paraguay X
replace lb_q23c_norm=. if id_alex=="lb_Spanish_0_807_2021_2022" //Paraguay X
replace lb_q23d_norm=. if id_alex=="lb_Spanish_0_807_2021_2022" //Paraguay X
replace lb_q23e_norm=. if id_alex=="lb_Spanish_0_807_2021_2022" //Paraguay X
replace lb_q23f_norm=. if id_alex=="lb_Spanish_0_613" //Paraguay X
replace cj_q15_norm=. if id_alex=="cj_Spanish_0_448" //Paraguay X
replace cj_q21e_norm=. if id_alex=="cj_Spanish_0_301" //Paraguay X
replace cj_q15_norm=. if id_alex=="cj_Spanish_0_301" //Paraguay X
drop if id_alex=="cc_Spanish_0_721_2021_2022" //Paraguay X
replace cj_q9_norm=. if id_alex=="cj_Spanish_0_182" //Paraguay X
replace cj_q9_norm=. if id_alex=="cj_Spanish_0_718" //Paraguay X
replace all_q10_norm=. if id_alex=="cc_Spanish_1_765" //Paraguay X
replace all_q93_norm=. if id_alex=="cj_Spanish_1_770" //Paraguay X
replace cj_q8_norm=. if id_alex=="cj_Spanish_0_448" //Paraguay X
replace all_q42_norm=. if id_alex=="cc_Spanish_1_421" //Paraguay X
replace all_q43_norm=. if id_alex=="cc_Spanish_1_421" //Paraguay X
replace all_q44_norm=. if id_alex=="cc_Spanish_1_421" //Paraguay X
replace all_q45_norm=. if id_alex=="cc_Spanish_1_421" //Paraguay X
replace all_q46_norm=. if id_alex=="cc_Spanish_1_421" //Paraguay X
replace all_q42_norm=. if id_alex=="cc_Spanish_1_765" //Paraguay X
replace all_q43_norm=. if id_alex=="cc_Spanish_1_765" //Paraguay X
replace all_q44_norm=. if id_alex=="cc_Spanish_1_765" //Paraguay X
replace all_q45_norm=. if id_alex=="cc_Spanish_1_765" //Paraguay X
replace all_q46_norm=. if id_alex=="cc_Spanish_1_765" //Paraguay X
replace lb_q23c_norm=. if id_alex=="lb_Spanish_0_613" //Paraguay X
replace lb_q23e_norm=. if id_alex=="lb_Spanish_0_613" //Paraguay X
replace cj_q15_norm=0.3333333 if id_alex=="cj_Spanish_1_113" //Paraguay X
replace all_q62_norm=. if id_alex=="cc_Spanish_0_1128" //Paraguay X
replace all_q63_norm=. if id_alex=="cc_Spanish_0_1128" //Paraguay X
replace all_q62_norm=. if id_alex=="cc_Spanish_0_1025" //Paraguay X
replace all_q63_norm=. if id_alex=="cc_Spanish_0_1025" //Paraguay X
replace cc_q10_norm=. if id_alex=="cc_Spanish_0_940_2022" //Paraguay X
replace cc_q10_norm=. if id_alex=="cc_Spanish_0_1025" //Paraguay X
drop if id_alex=="cc_Spanish_1_406_2016_2017_2018_2019_2021_2022" //Peru X
drop if id_alex=="cj_Spanish_1_1252_2019_2021_2022" //Peru X
replace all_q22_norm=. if id_alex=="cj_Spanish_1_736" //Peru X
replace all_q23_norm=. if id_alex=="cj_Spanish_1_736" //Peru X
replace all_q24_norm=. if id_alex=="cj_Spanish_1_736" //Peru X
replace all_q25_norm=. if id_alex=="cj_Spanish_1_736" //Peru X
replace all_q26_norm=. if id_alex=="cj_Spanish_1_736" //Peru X
replace all_q27_norm=. if id_alex=="cj_Spanish_1_736" //Peru X
replace all_q8_norm=. if id_alex=="cj_Spanish_1_736" //Peru X
replace all_q15_norm=. if id_alex=="cc_Spanish_1_406_2016_2017_2018_2019_2021_2022" //Peru X
replace all_q15_norm=. if id_alex=="cc_English_1_878_2018_2019_2021_2022" //Peru X
replace all_q20_norm=. if id_alex=="cc_Spanish_1_406_2016_2017_2018_2019_2021_2022" //Peru X
replace all_q20_norm=. if id_alex=="cc_English_1_878_2018_2019_2021_2022" //Peru X
replace all_q21_norm=. if id_alex=="cc_Spanish_1_406_2016_2017_2018_2019_2021_2022" //Peru X
replace all_q21_norm=. if id_alex=="cc_English_1_878_2018_2019_2021_2022" //Peru X
replace all_q24_norm=. if id_alex=="lb_English_0_570_2021_2022" //Peru X
replace all_q26_norm=. if id_alex=="lb_English_0_570_2021_2022" //Peru X
replace all_q8_norm=. if id_alex=="lb_English_0_570_2021_2022" //Peru X
replace all_q22_norm=. if id_alex=="lb_Spanish_0_113_2021_2022" //Peru X
replace all_q22_norm=. if id_alex=="cc_Spanish_1_970" //Peru X
replace all_q23_norm=. if id_alex=="cc_Spanish_1_970" //Peru X
replace all_q24_norm=. if id_alex=="cc_Spanish_1_970" //Peru X
replace all_q25_norm=. if id_alex=="cc_Spanish_1_970" //Peru X
replace all_q26_norm=. if id_alex=="cc_Spanish_1_970" //Peru X
replace all_q8_norm=. if id_alex=="cc_Spanish_1_970" //Peru X
replace all_q25_norm=1 if id_alex=="lb_Spanish_0_113_2021_2022" //Peru X
replace all_q25_norm=. if id_alex=="cc_Spanish_0_715" //Peru X
replace all_q26_norm=. if id_alex=="cc_Spanish_0_715" //Peru X
replace all_q27_norm=. if id_alex=="cc_Spanish_0_715" //Peru X
replace all_q8_norm=. if id_alex=="cc_Spanish_0_715" //Peru X
drop if id_alex=="cc_Spanish_0_794" //Peru X
replace all_q30_norm=. if id_alex=="cj_Spanish_0_316" //Peru X
replace all_q30_norm=. if id_alex=="cj_Spanish_0_789" //Peru X
replace all_q30_norm=. if id_alex=="cj_Spanish_0_685" //Peru X
replace all_q30_norm=. if id_alex=="cj_Spanish_0_860" //Peru X
replace all_q29_norm=. if id_alex=="cj_Spanish_0_316" //Peru X
replace all_q88_norm=. if country=="Philippines" /*Philippines*/
replace cc_q26a_norm=. if country=="Philippines" /*Philippines*/
replace all_q46_norm=. if country=="Philippines" //Philippines
replace all_q47_norm=. if country=="Philippines" //Philippines
replace cc_q39a_norm=. if cc_q39a_norm==0 & country=="Philippines" //Philippines
replace cc_q39b_norm=. if cc_q39b_norm==0 & country=="Philippines" //Philippines
replace all_q9_norm=. if id_alex=="cc_English_0_1473_2017_2018_2019_2021_2022" //Philippines X
replace all_q9_norm=. if id_alex=="cc_English_0_1213_2017_2018_2019_2021_2022" //Philippines X
replace all_q44_norm=. if id_alex=="cc_English_1_697" //Philippines X
replace all_q45_norm=. if id_alex=="cc_English_1_697" //Philippines X
replace cc_q39e_norm=. if id_alex=="cc_English_1_106" //Philippines X
replace cc_q39e_norm=. if id_alex=="cc_English_0_394" //Philippines X
replace cc_q9b_norm=. if id_alex=="cc_English_0_394" //Philippines X
replace cc_q39b_norm=. if id_alex=="cc_English_0_1204" //Philippines X
replace lb_q16a_norm=. if id_alex=="lb_English_0_570" //Philippines X
replace lb_q16b_norm=. if id_alex=="lb_English_0_570" //Philippines X
replace lb_q16c_norm=. if id_alex=="lb_English_0_570" //Philippines X
replace lb_q16d_norm=. if id_alex=="lb_English_0_570" //Philippines X
replace lb_q16f_norm=. if id_alex=="lb_English_0_570" //Philippines X
replace lb_q23a_norm=. if id_alex=="lb_English_0_570" //Philippines X
replace lb_q23b_norm=. if id_alex=="lb_English_0_570" //Philippines X
replace lb_q23c_norm=. if id_alex=="lb_English_0_570" //Philippines X
replace lb_q23f_norm=. if id_alex=="lb_English_0_570" //Philippines X
replace cc_q40a_norm=. if country=="Poland" /*Poland*/
replace cc_q25_norm=. if country=="Poland" /* Poland */
replace cj_q8_norm=. if country=="Poland" //Poland
replace all_q42_norm=. if country=="Poland" //Poland
drop if id_alex=="cc_English_0_296" //Poland
drop if id_alex=="cc_English_1_564" //Poland
drop if id_alex=="cc_English_0_1100" //Poland
replace cc_q9b_norm=. if id_alex=="cc_English_1_1080" //Poland
replace cc_q40b_norm=. if id_alex=="cc_English_1_1080"  //Poland
replace cc_q39e_norm=. if country=="Poland" //Poland
replace all_q34_norm=. if country=="Poland" //Poland
drop if id_alex=="cc_English_0_1260_2022" //Poland X
replace cc_q33_norm=. if id_alex=="cc_English_1_1462_2022" //Poland X
replace all_q9_norm=. if id_alex=="cc_English_1_1462_2022" //Poland X
replace cj_q36c_norm=. if id_alex=="cj_English_1_458_2016_2017_2018_2019_2021_2022" //Poland X
replace all_q21_norm=. if id_alex=="cc_English_1_1080" //Poland X
replace all_q80_norm=1 if id_alex=="lb_English_1_394" //Poland X
replace cc_q26b_norm=. if id_alex=="cc_English_1_1080" //Poland X
drop if id_alex=="cc_English_1_1080" //Poland X
drop if id_alex=="cj_Portuguese_1_125" //Portugal
drop if id_alex=="cc_English_1_299" //Romania
drop if id_alex=="cc_English_1_458" //Romania
foreach v in all_q48_norm all_q49_norm all_q50_norm {
replace `v'=. if id_alex=="cc_English_0_1535_2018_2019_2021_2022" //Romania
replace `v'=. if id_alex=="cc_English_0_1167" //Romania
}
foreach v in cj_q40b_norm cj_q40c_norm cj_q20m_norm {
replace `v'=. if id_alex=="cj_Spanish_0_664" //Romania
}
replace cj_q20m_norm=. if id_alex=="cj_English_1_398" //Romania
drop if id_alex=="cc_English_0_138" //Romania X
replace all_q88_norm=. if id_alex=="cc_English_0_52_2016_2017_2018_2019_2021_2022" //Romania X
replace cc_q26a_norm=. if id_alex=="cc_English_0_52_2016_2017_2018_2019_2021_2022" //Romania X
replace all_q88_norm=. if id_alex=="cc_English_0_1395_2022" //Romania X
replace cc_q26a_norm=. if id_alex=="cc_English_0_1395_2022" //Romania X
replace lb_q6c_norm=. if id_alex=="lb_English_1_635_2022" //Romania X
replace cj_q21h_norm=. if country=="Russian Federation" /* Russia */
replace cj_q31e_norm=. if id_alex=="cj_English_1_799" //Russia
replace cj_q42d_norm=. if id_alex=="cj_English_1_799" //Russia
replace cj_q42d_norm=. if country=="Russian Federation" //Russia
replace cj_q11b_norm=. if country=="Russian Federation" //Russia

replace all_q1_norm=. if id_alex=="cc_English_0_1231_2018_2019_2021_2022" //Russia X
replace all_q1_norm=. if id_alex=="cc_Russian_1_1243_2019_2021_2022" //Russia X
replace all_q1_norm=. if id_alex=="cc_English_1_1454" //Russia X
replace cc_q25_norm=. if id_alex=="cc_English_1_837_2016_2017_2018_2019_2021_2022" //Russia X
replace cj_q10_norm=. if id_alex=="cj_English_1_799" //Russia X
replace all_q13_norm=. if id_alex=="cj_English_0_931_2017_2018_2019_2021_2022" //Russia X
replace cc_q40a_norm=. if id_alex=="cc_Russian_1_1243_2019_2021_2022" //Russia X
replace cj_q31e_norm=0 if id_alex=="cj_English_0_336_2021_2022" //Russia X
replace cj_q42c_norm=. if id_alex=="cj_Russian_0_503_2021_2022" //Russia X
replace all_q21_norm=. if id_alex=="cj_English_1_799" //Russia X
replace all_q94_norm=. if id_alex=="lb_Russian_1_701_2021_2022" //Russia X
replace all_q18_norm=. if id_alex=="cj_English_1_799" //Russia X
replace all_q19_norm=. if id_alex=="cj_English_1_799" //Russia X
replace all_q31_norm=. if id_alex=="cj_English_1_799" //Russia X
replace all_q32_norm=. if id_alex=="cj_English_1_799" //Russia X
replace all_q14_norm=. if id_alex=="cj_English_1_799" //Russia X
replace cj_q8_norm=. if id_alex=="cj_English_1_799" //Russia X
replace all_q19_norm=0 if id_alex=="cc_Russian_0_1076_2019_2021_2022" //Russia X
replace all_q31_norm=0 if id_alex=="cc_Russian_0_1076_2019_2021_2022" //Russia X
replace all_q32_norm=0 if id_alex=="cc_Russian_0_1076_2019_2021_2022" //Russia X
replace all_q14_norm=0 if id_alex=="cc_Russian_0_1076_2019_2021_2022" //Russia X
replace all_q31_norm=. if id_alex=="cc_English_1_1006_2017_2018_2019_2021_2022" //Russia X
replace cc_q39a_norm=. if id_alex=="cc_English_0_930_2022" //Russia X
replace cc_q39b_norm=. if id_alex=="cc_English_0_930_2022" //Russia X
replace cc_q39c_norm=. if id_alex=="cc_English_0_930_2022" //Russia X
replace cj_q10_norm=. if id_alex=="cj_Russian_0_535_2018_2019_2021_2022" //Russia X
replace cj_q11a_norm=. if id_alex=="cj_English_0_486_2018_2019_2021_2022" //Russia X
drop if id_alex=="cc_English_0_1063" //Rwanda
drop if id_alex=="cc_English_1_46" //Rwanda
drop if id_alex=="cc_English_1_1043" //Rwanda
drop if id_alex=="cj_English_0_67" //Rwanda
drop if id_alex=="cj_English_1_1029" //Rwanda
drop if id_alex=="cj_French_0_460" //Rwanda
drop if id_alex=="cj_English_0_884" //Rwanda
drop if id_alex=="lb_English_0_577" //Rwanda
replace cc_q33_norm=. if country=="Rwanda" //Rwanda
replace cc_q9c_norm=. if country=="Rwanda" //Rwanda
replace ph_q6a_norm=. if country=="Rwanda" //Rwanda
replace ph_q6b_norm=. if country=="Rwanda" //Rwanda
replace ph_q6c_norm=. if country=="Rwanda" //Rwanda
replace ph_q6d_norm=. if country=="Rwanda" //Rwanda
replace ph_q6e_norm=. if country=="Rwanda" //Rwanda
replace ph_q6f_norm=. if country=="Rwanda" //Rwanda
replace cj_q31e_norm=. if id_alex=="cj_French_1_1084_2022" //Rwanda
replace cj_q31e_norm=. if id_alex=="cj_English_0_479" //Rwanda
replace cj_q11a_norm=. if id_alex=="cj_English_0_655" //Rwanda
replace cj_q11b_norm=. if id_alex=="cj_English_0_655" //Rwanda
replace cj_q42c_norm=. if id_alex=="cj_English_1_702" //Rwanda
replace all_q29_norm=. if country=="Rwanda" //Rwanda
replace all_q54_norm=. if country=="Rwanda" //Rwanda
replace all_q78_norm=. if country=="Rwanda" //Rwanda
replace all_q79_norm=. if country=="Rwanda" //Rwanda
replace cc_q26a_norm=. if country=="Rwanda" //Rwanda
replace all_q90_norm=. if country=="Rwanda" //Rwanda
replace cj_q20o_norm=. if id_alex=="cj_English_0_479" //Rwanda
replace cj_q20o_norm=. if id_alex=="cj_English_0_655" //Rwanda
replace cj_q21h_norm=. if id_alex=="cj_English_0_479" //Rwanda
replace cj_q28_norm=. if id_alex=="cj_English_0_479" //Rwanda
replace cj_q40b_norm=. if id_alex=="cj_English_0_479" //Rwanda
replace cj_q40c_norm=. if id_alex=="cj_English_0_479" //Rwanda
replace cj_q40b_norm=. if id_alex=="cj_French_0_69_2019_2021_2022" //Rwanda
replace cj_q40c_norm=. if id_alex=="cj_French_0_69_2019_2021_2022" //Rwanda
replace lb_q16a_norm=. if id_alex=="lb_English_0_143_2022" //Rwanda
replace lb_q16b_norm=. if id_alex=="lb_English_0_143_2022" //Rwanda
replace lb_q16c_norm=. if id_alex=="lb_English_0_143_2022" //Rwanda
replace lb_q16d_norm=. if id_alex=="lb_English_0_143_2022" //Rwanda
replace lb_q16e_norm=. if id_alex=="lb_English_0_143_2022" //Rwanda
replace lb_q16f_norm=. if id_alex=="lb_English_0_143_2022" //Rwanda
replace cj_q21g_norm=. if id_alex=="cj_English_0_655" //Rwanda
replace cj_q21h_norm=. if id_alex=="cj_English_0_655" //Rwanda
replace all_q30_norm=. if id_alex=="cj_English_0_479" //Rwanda
replace all_q30_norm=. if id_alex=="cj_English_1_702" //Rwanda
replace lb_q16d_norm=0 if id_alex=="lb_English_0_374_2019_2021_2022" //Rwanda
replace cj_q10_norm=. if id_alex=="cj_English_0_655" //Rwanda
replace cj_q42c_norm=. if id_alex=="cj_English_0_479" //Rwanda
replace cj_q42c_norm=. if id_alex=="cj_English_0_655" //Rwanda
replace all_q18_norm=. if id_alex=="cj_English_1_1230_2019_2021_2022" //Rwanda
replace all_q94_norm=. if id_alex=="lb_English_0_197" //Rwanda
replace all_q94_norm=. if id_alex=="cj_French_0_924_2022" //Rwanda
replace all_q15_norm=. if id_alex=="cj_English_1_702" //Rwanda
replace all_q16_norm=. if id_alex=="cj_English_1_702" //Rwanda
replace all_q17_norm=. if id_alex=="cj_English_1_702" //Rwanda
drop if id_alex=="lb_English_0_197" 
replace cj_q38_norm=. if id_alex=="cj_English_1_929_2019_2021_2022" //Rwanda
replace cj_q11a_norm=. if id_alex=="cj_French_0_69_2019_2021_2022" //Rwanda
replace cj_q11b_norm=. if id_alex=="cj_French_0_69_2019_2021_2022" //Rwanda
replace all_q21_norm=. if id_alex=="cc_French_1_984_2019_2021_2022" //Rwanda
replace all_q21_norm=. if id_alex=="cc_English_0_1678_2022" //Rwanda
replace all_q25_norm=. if id_alex=="cc_French_1_984_2019_2021_2022" //Rwanda
replace lb_q23f_norm=. if id_alex=="lb_French_1_460" //Rwanda
replace lb_q23g_norm=. if id_alex=="lb_French_1_460" //Rwanda
replace lb_q23c_norm=. if id_alex=="lb_English_0_312" //Rwanda
replace all_q75_norm=. if id_alex=="lb_French_1_460" //Rwanda
replace all_q75_norm=. if id_alex=="lb_English_0_312" //Rwanda
replace all_q15_norm=. if id_alex=="cj_French_0_69_2019_2021_2022" //Rwanda
replace all_q15_norm=. if id_alex=="cc_English_1_869" //Rwanda
replace all_q18_norm=. if id_alex=="cc_English_0_498" //Rwanda
replace cj_q40b_norm=. if id_alex=="cj_English_0_655" //Rwanda
replace cj_q40c_norm=. if id_alex=="cj_English_0_655" //Rwanda
replace cj_q40b_norm=. if id_alex=="cj_English_1_702" //Rwanda
replace cj_q40c_norm=. if id_alex=="cj_English_1_702" //Rwanda
replace all_q19_norm=. if id_alex=="cj_English_0_655" //Rwanda
replace all_q19_norm=. if id_alex=="cj_English_1_702" //Rwanda
replace all_q21_norm=. if id_alex=="lb_English_1_740_2022" //Rwanda
replace cj_q21e_norm=. if id_alex=="cj_English_0_655" //Rwanda
replace lb_q16d_norm=1 if id_alex=="lb_English_0_222_2018_2019_2021_2022" //Rwanda
replace lb_q23e_norm=.6666667 if id_alex=="lb_English_0_306_2021_2022" //Rwanda
replace lb_q23c_norm=. if id_alex=="lb_English_0_306_2021_2022" //Rwanda
replace lb_q16a_norm=. if id_alex=="lb_English_0_222_2018_2019_2021_2022" //Rwanda
replace cj_q28_norm=. if country=="Senegal" //Senegal
drop if id_alex=="cj_French_1_865" //Senegal
drop if id_alex=="cj_French_0_995" //Senegal
replace cj_q42c_norm=. if id_alex=="cj_French_0_849" //Senegal
replace cj_q10_norm=. if id_alex=="cj_French_0_849" //Senegal
replace cj_q38_norm=. if id_alex=="cj_French_0_849" //Senegal
replace cj_q10_norm=. if id_alex=="cj_French_0_745" //Senegal
replace all_q19_norm=. if all_q19_norm==0 & country=="Senegal" //Senegal
foreach v in all_q13_norm all_q14_norm all_q15_norm all_q16_norm all_q17_norm all_q18_norm all_q94_norm all_q19_norm all_q20_norm all_q21_norm all_q19_norm all_q31_norm all_q32_norm all_q14_norm cc_q9a_norm cc_q11b_norm cc_q32j_norm {
replace `v'=. if id_alex=="cc_French_0_933" //Senegal
replace `v'=. if id_alex=="cc_French_1_439_2022" //Senegal
}
replace cc_q9c_norm=. if id_alex=="cc_French_0_933" //Senegal
drop if id_alex=="cc_French_0_204_2021_2022" //Senegal X
replace cc_q11a_norm=. if id_alex=="cc_French_0_1829_2018_2019_2021_2022" //Senegal X
replace all_q4_norm=. if id_alex=="cc_English_0_1625_2017_2018_2019_2021_2022" //Senegal X
replace all_q7_norm=. if id_alex=="cc_English_0_1625_2017_2018_2019_2021_2022" //Senegal X
replace all_q4_norm=. if id_alex=="cj_English_0_1027_2017_2018_2019_2021_2022" //Senegal X
replace all_q7_norm=. if id_alex=="cj_English_0_1027_2017_2018_2019_2021_2022" //Senegal X
replace all_q62_norm=. if id_alex=="cc_French_0_1553_2022" //Senegal X
replace cj_q15_norm=. if id_alex=="cj_French_0_172_2019_2021_2022" //Senegal X
replace cc_q11a_norm=. if id_alex=="cc_French_0_1829_2018_2019_2021_2022" //Senegal X
replace cc_q11a_norm=. if id_alex=="cc_French_1_439_2022" //Senegal X
replace cc_q26b_norm=. if id_alex=="cc_French_1_1305_2021_2022" //Senegal X
replace cj_q31g_norm=. if id_alex=="cj_French_1_686_2016_2017_2018_2019_2021_2022" //Senegal X
replace all_q62_norm=. if id_alex=="cc_French_1_1549_2021_2022" //Senegal X
replace cc_q26a_norm=. if id_alex=="cc_French_1_439_2022" //Senegal X
replace all_q19_norm=. if id_alex=="cc_French_0_669_2016_2017_2018_2019_2021_2022" //Senegal X
replace all_q19_norm=. if id_alex=="cc_English_0_1625_2017_2018_2019_2021_2022" //Senegal X
replace all_q19_norm=. if id_alex=="cc_French_0_1674_2019_2021_2022" //Senegal X
replace all_q32_norm=. if id_alex=="cc_French_0_669_2016_2017_2018_2019_2021_2022" //Senegal X
replace all_q32_norm=. if id_alex=="cc_English_0_1625_2017_2018_2019_2021_2022" //Senegal X
replace all_q19_norm=. if id_alex=="cj_English_0_1027_2017_2018_2019_2021_2022" //Senegal X
drop if id_alex=="cj_English_1_918" //Serbia
replace cj_q42d_norm=. if id_alex=="cj_English_0_777" //Serbia
replace cj_q10_norm=. if id_alex=="cj_English_1_606" //Serbia
drop if id_alex=="cc_English_1_423_2018_2019_2021_2022" //Serbia X
replace cj_q36c_norm=. if id_alex=="cj_English_0_148_2018_2019_2021_2022" //Serbia X
replace cj_q31e_norm=. if id_alex=="cj_English_0_777" //Serbia X
replace cj_q11a_norm=. if id_alex=="cj_English_0_148_2018_2019_2021_2022" //Serbia X
replace all_q20_norm=. if id_alex=="cc_English_1_1016_2016_2017_2018_2019_2021_2022" //Serbia X
replace all_q20_norm=. if id_alex=="cc_English_1_344_2016_2017_2018_2019_2021_2022" //Serbia X
replace all_q19_norm=. if id_alex=="cc_English_1_1016_2016_2017_2018_2019_2021_2022" //Serbia X
replace all_q14_norm=. if id_alex=="cc_English_1_1016_2016_2017_2018_2019_2021_2022" //Serbia X
replace all_q17_norm=. if id_alex=="cj_English_0_777" //Serbia X
replace cj_q31e_norm=. if id_alex=="cj_English_0_777" //Serbia X
replace cj_q42c_norm=. if id_alex=="cj_English_0_777" //Serbia X
replace cj_q15_norm=. if id_alex=="cj_English_1_250" //Serbia X
replace cj_q31e_norm=. if id_alex=="cj_English_1_250" //Serbia X
replace cj_q10_norm=. if id_alex=="cj_English_0_148_2018_2019_2021_2022" //Serbia X
replace cj_q36c_norm=. if id_alex=="cj_English_0_777" //Serbia X
replace all_q9_norm=. if id_alex=="lb_English_1_590_2021_2022" //Serbia X
replace cj_q21h_norm=. if country=="Sierra Leone" /*Sierra Leone*/
replace cj_q31g_norm=. if id_alex=="cj_English_0_810" //Sierra Leone
replace all_q48_norm=. if all_q48_norm==0 & country=="Sierra Leone" //Sierra Leone
replace all_q49_norm=. if all_q49_norm==0 & country=="Sierra Leone" //Sierra Leone
replace all_q77_norm=. if id_alex=="lb_English_0_85" //Sierra Leone
replace all_q78_norm=. if id_alex=="lb_English_0_85"  //Sierra Leone
drop if id_alex=="cc_English_1_542" //Sierra Leone
replace cj_q42c_norm=. if id_alex=="cj_English_0_146_2017_2018_2019_2021_2022" //Sierra Leone X
replace cj_q42d_norm=. if id_alex=="cj_English_0_146_2017_2018_2019_2021_2022" //Sierra Leone X
replace cj_q15_norm=. if id_alex=="cj_English_0_146_2017_2018_2019_2021_2022" //Sierra Leone X
replace all_q62_norm=. if id_alex=="lb_English_0_553_2018_2019_2021_2022" //Sierra Leone X
replace all_q6_norm=0.5 if id_alex=="lb_English_0_85" //Sierra Leone X
replace all_q17_norm=. if country=="Singapore" //Singapore
replace cj_q10_norm=. if country=="Singapore" //Singapore
replace all_q6_norm=. if country=="Singapore" //Singapore
replace cj_q36c_norm=. if id_alex=="cj_English_1_524" //Singapore
drop if id_alex=="cj_English_0_605" //Singapore
drop if id_alex=="ph_English_1_246" //Singapore
drop if id_alex=="cc_English_0_145" //Singapore
drop if id_alex=="cj_English_0_103" //Singapore
replace cj_q28_norm=. if id_alex=="cj_English_0_698_2022" //Singapore X
replace cj_q15_norm=0.6666667 if id_alex=="cj_English_0_519_2018_2019_2021_2022" //Singapore X
replace cj_q32d_norm=. if country=="Slovak Republic" //Slovak Republic
replace cj_q34a_norm=. if country=="Slovak Republic" //Slovak Republic
replace cj_q34e_norm=. if country=="Slovak Republic" //Slovak Republic
replace cj_q7c_norm=. if country=="Slovak Republic" //Slovak Republic
replace cj_q12b_norm=. if country=="Slovak Republic"  //Slovak Republic
drop if id_alex=="cj_English_1_670" //Slovak Republic
drop if id_alex=="cj_English_1_149"  //Slovak Republic
replace cj_q20m_norm=. if id_alex=="cj_English_1_197" //Slovak Republic
replace cj_q20m_norm=. if id_alex=="cj_English_0_257" //Slovak Republic
replace cj_q28_norm=. if id_alex=="cj_English_0_587_2021_2022" //Slovak Republic
replace cj_q21g_norm=. if id_alex=="cj_English_0_587_2021_2022" //Slovak Republic
replace all_q6_norm=. if id_alex=="cc_English_0_783" //Slovak Republic
replace all_q57_norm=. if id_alex=="cc_English_0_70_2021_2022" //Slovak Republic
replace all_q58_norm=. if id_alex=="cc_English_0_70_2021_2022" //Slovak Republic
replace all_q59_norm=. if id_alex=="cc_English_0_70_2021_2022" //Slovak Republic
replace lb_q6c_norm=. if id_alex=="lb_English_0_687_2021_2022" //Slovak Republic
replace cj_q18e_norm=. if id_alex=="cj_English_0_257" //Slovak Republic
replace cj_q20e_norm=. if id_alex=="cj_English_0_257" //Slovak Republic
replace cj_q33e_norm=. if id_alex=="cj_English_0_257" //Slovak Republic
replace cj_q22d_norm=. if id_alex=="cj_English_0_587_2021_2022" //Slovak Republic
replace cj_q22b_norm=. if id_alex=="cj_English_1_197" //Slovak Republic
replace cj_q29a_norm=. if id_alex=="cj_English_0_587_2021_2022" //Slovak Republic
replace cj_q1_norm=. if id_alex=="cj_English_0_587_2021_2022" //Slovak Republic
replace cj_q3a_norm=. if id_alex=="cj_English_0_587_2021_2022" //Slovak Republic
replace cj_q20m_norm =.8888889 if id_alex=="cj_English_0_587_2021_2022" //Slovak Republic
replace all_q28_norm=. if id_alex=="cc_English_0_1642_2021_2022" //Slovak Republic
replace cj_q32b_norm=. if id_alex=="cj_English_0_137_2022" //Slovak Republic
replace all_q6_norm=. if id_alex=="lb_English_0_651" //Slovak Republic
replace cj_q24b_norm=. if id_alex=="cj_English_0_257" //Slovak Republic
replace cj_q24c_norm=.5 if id_alex=="cj_English_0_257" //Slovak Republic
replace cj_q24c_norm=.5 if id_alex=="cj_English_0_587_2021_2022" //Slovak Republic
replace cj_q33e_norm=.6666667 if id_alex=="cj_English_0_587_2021_2022" //Slovak Republic
replace cj_q40b_norm=. if id_alex=="cj_English_0_257" //Slovak Republic
replace all_q6_norm=. if id_alex=="lb_English_0_45" //Slovak Republic
replace all_q57_norm=. if id_alex=="cc_English_0_1595_2021_2022" //Slovak Republic
replace cc_q28e_norm=. if id_alex=="cc_English_0_1642_2021_2022" //Slovak Republic
replace lb_q6c_norm=. if id_alex=="lb_English_0_446_2021_2022" //Slovak Republic
replace cc_q40a_norm=. if country=="Slovenia" /* Slovenia */
replace lb_q2d_norm=. if country=="Slovenia" /* Slovenia */
drop if id_alex=="cc_English_1_475" //Slovenia
drop if id_alex=="cj_English_1_205" //Slovenia
drop if id_alex=="lb_English_0_568" //Slovenia
drop if id_alex=="ph_English_0_635_2018_2019_2021_2022" //Slovenia
replace all_q76_norm=. if id_alex=="cc_English_1_960_2022" //Slovenia X
replace all_q77_norm=. if id_alex=="cc_English_1_960_2022" //Slovenia X
replace all_q78_norm=. if id_alex=="cc_English_1_960_2022" //Slovenia X
replace all_q79_norm=. if id_alex=="cc_English_1_960_2022" //Slovenia X
replace all_q80_norm=. if id_alex=="cc_English_1_960_2022" //Slovenia X
replace all_q81_norm=. if id_alex=="cc_English_1_960_2022" //Slovenia X
replace lb_q3d_norm=. if id_alex=="lb_English_0_413" //Slovenia X
drop if id_alex=="cc_English_1_328_2021_2022" //South Africa
drop if id_alex=="cj_English_0_235" //South Africa
drop if id_alex=="lb_English_0_636_2019_2021_2022" //South Africa
drop if id_alex=="ph_English_1_179" //South Africa
replace cj_q11a_norm=. if cj_q11a_norm==1 & country=="South Africa" //South Africa
replace lb_q16e_norm=. if lb_q16e_norm==1 & country=="South Africa" //South Africa
drop if id_alex=="cj_Spanish_0_290" //Spain
drop if id_alex=="cj_Spanish_0_322" //Spain
drop if id_alex=="lb_Spanish_0_296_2017_2018_2019_2021_2022" //Spain
drop if id_alex=="ph_Spanish_1_106_2018_2019_2021_2022" //Spain
drop if id_alex=="ph_Spanish_1_86" //Spain
drop if id_alex=="cj_Spanish_1_480" //Spain
drop if id_alex=="cj_Spanish_1_803_2018_2019_2021_2022" //Spain
drop if id_alex=="cj_Spanish_1_311" //Spain
drop if id_alex=="cj_Spanish_1_532" //Spain
drop if id_alex=="cj_Spanish_0_369" //Spain
replace all_q87_norm=. if country=="Sri Lanka" /* Sri Lanka */
replace cj_q11b_norm=. if country=="Sri Lanka" /* Sri Lanka */
drop if id_alex=="cc_English_0_1220" //Sri Lanka
drop if id_alex=="cj_English_1_775" //Sri Lanka
drop if id_alex=="lb_English_0_416_2019_2021_2022" //Sri Lanka
drop if id_alex=="ph_English_0_573_2021_2022" //Sri Lanka
drop if id_alex=="ph_English_1_71_2018_2019_2021_2022" //Sri Lanka
replace cc_q40b_norm=. if id_alex=="cc_English_1_1428" //Sri Lanka
drop if id_alex=="cc_English_1_1428" //Sri Lanka
foreach v in cc_q10_norm cc_q11a_norm cc_q16a_norm cc_q14a_norm cc_q14b_norm cc_q16b_norm cc_q16c_norm cc_q16d_norm cc_q16e_norm cc_q16f_norm cc_q16g_norm {
replace `v'=. if id_alex=="cc_English_0_1037" //Sri Lanka
replace `v'=. if id_alex=="cc_English_0_580" //Sri Lanka
replace `v'=. if id_alex=="cc_English_0_1017_2019_2021_2022" //Sri Lanka
}
replace all_q55_norm=. if id_alex=="cc_English_0_1037" //Sri Lanka
drop if id_alex=="cc_English_0_1037" //Sri Lanka X
replace cj_q31g_norm=. if id_alex=="cj_English_1_727_2021_2022" //Sri Lanka X
replace all_q29_norm=. if id_alex=="cj_English_1_809_2021_2022" //Sri Lanka X
replace all_q30_norm=. if id_alex=="cj_English_1_809_2021_2022" //Sri Lanka X
replace all_q85_norm=. if id_alex=="cc_English_0_1141" //Sri Lanka X
replace all_q85_norm=. if id_alex=="cc_English_1_557" //Sri Lanka X
replace cj_q15_norm=. if id_alex=="cj_English_0_758_2022" //Sri Lanka X
replace all_q19_norm=. if id_alex=="cc_English_0_1017_2019_2021_2022" //Sri Lanka X
replace all_q31_norm=. if id_alex=="cc_English_0_1017_2019_2021_2022" //Sri Lanka X
replace all_q32_norm=. if id_alex=="cc_English_0_1017_2019_2021_2022" //Sri Lanka X
replace all_q14_norm=. if id_alex=="cc_English_0_1017_2019_2021_2022" //Sri Lanka X
replace all_q19_norm=. if id_alex=="cc_English_0_1407_2019_2021_2022" //Sri Lanka X
replace all_q31_norm=. if id_alex=="cc_English_0_1407_2019_2021_2022" //Sri Lanka X
replace all_q32_norm=. if id_alex=="cc_English_0_1407_2019_2021_2022" //Sri Lanka X
replace all_q14_norm=. if id_alex=="cc_English_0_1407_2019_2021_2022" //Sri Lanka X
replace all_q19_norm=. if id_alex=="cc_English_1_557" //Sri Lanka X
replace all_q31_norm=. if id_alex=="cc_English_1_557" //Sri Lanka X
replace all_q32_norm=. if id_alex=="cc_English_1_557" //Sri Lanka X
replace all_q14_norm=. if id_alex=="cc_English_1_557" //Sri Lanka X
replace all_q21_norm=. if id_alex=="cc_English_1_587_2019_2021_2022" //Sri Lanka X
replace all_q21_norm=. if id_alex=="cj_English_1_809_2021_2022" //Sri Lanka X
replace all_q15_norm=. if id_alex=="cj_English_0_228" //Sri Lanka X
replace all_q84_norm=. if id_alex=="cc_English_0_1141" //Sri Lanka X
replace all_q19_norm=. if id_alex=="cj_English_1_809_2021_2022" //Sri Lanka X
replace all_q31_norm=. if id_alex=="cj_English_1_809_2021_2022" //Sri Lanka X
replace all_q32_norm=. if id_alex=="cj_English_1_809_2021_2022" //Sri Lanka X
replace all_q14_norm=. if id_alex=="cj_English_1_809_2021_2022" //Sri Lanka X
replace cc_q13_norm=. if id_alex=="cc_English_0_1141" //Sri Lanka X
replace all_q85_norm=. if id_alex=="lb_English_0_389" //Sri Lanka X
replace cj_q42c_norm=. if id_alex=="cj_English_0_228" //Sri Lanka X
replace cj_q42d_norm=. if id_alex=="cj_English_0_228" //Sri Lanka X
replace all_q18_norm=. if id_alex=="cj_English_0_228" //Sri Lanka X
replace all_q13_norm=. if id_alex=="cj_English_0_245_2021_2022" //Sri Lanka X
replace all_q14_norm=. if id_alex=="cc_English_0_51" //Sri Lanka X
replace lb_q16b_norm=. if id_alex=="lb_English_0_661" //Sri Lanka X
replace lb_q16f_norm=. if id_alex=="lb_English_1_374_2019_2021_2022" //Sri Lanka X
replace all_q48_norm=. if id_alex=="cc_English_0_872_2022" //St Kitts
replace all_q50_norm=. if id_alex=="cc_English_0_872_2022" //St Kitts
drop if id_alex=="cj_English_1_278" //St Kitts
drop if id_alex=="cj_English_1_360_2022" //St Kitts
replace lb_q16f_norm=. if id_alex=="cj_English_0_139_2016_2017_2018_2019_2021_2022" //St Kitts X
replace all_q96_norm=. if id_alex=="cj_English_1_1058_2021_2022" //St Kitts X
replace all_q29_norm=. if id_alex=="cj_English_1_1237_2021_2022" //St Kitts X
replace cj_q40b_norm=. if id_alex=="cj_English_0_146_2016_2017_2018_2019_2021_2022" //St Kitts X
replace cj_q7a_norm=. if id_alex=="cj_English_0_146_2016_2017_2018_2019_2021_2022" //St Kitts X
replace cj_q7b_norm=. if id_alex=="cj_English_0_146_2016_2017_2018_2019_2021_2022" //St Kitts X
replace lb_q2d_norm=1 if id_alex=="lb_English_0_162_2016_2017_2018_2019_2021_2022" //St Kitts X
replace cc_q29b_norm=. if country=="St. Lucia" /* St. Lucia */
drop if id_alex=="cc_English_0_1182" //St Lucia
replace all_q30_norm=. if id_alex=="cc_English_0_1031" //St Lucia
replace all_q30_norm=. if id_alex=="cc_English_1_1315" //St Lucia
replace all_q62_norm=. if all_q62_norm==0 & country=="St. Lucia" //St Lucia
replace all_q63_norm=. if all_q63_norm==0 & country=="St. Lucia" //St Lucia
drop if id_alex=="cc_English_0_1031" //St Lucia
replace cc_q40a_norm=. if id_alex=="cc_English_1_1256" //St Lucia X
replace cc_q40b_norm=. if id_alex=="cc_English_1_1256" //St Lucia X
replace cc_q33_norm=. if id_alex=="cc_English_0_1172_2016_2017_2018_2019_2021_2022" //St Lucia X
replace cj_q15_norm=. if id_alex=="cj_English_0_1225_2019_2021_2022" //St Lucia X
replace all_q90_norm=. if country=="St. Vincent and the Grenadines" /* St. Vincent and the Grenadines */
replace all_q91_norm=. if country=="St. Vincent and the Grenadines" /* St. Vincent and the Grenadines */
replace all_q78_norm=. if country=="St. Vincent and the Grenadines" /* St. Vincent and the Grenadines */
replace all_q21_norm=. if country=="St. Vincent and the Grenadines" /* St. Vincent and the Grenadines */
replace cc_q40b_norm=. if country=="St. Vincent and the Grenadines" /* St. Vincent and the Grenadines */
replace all_q19_norm=. if country=="St. Vincent and the Grenadines" /* St. Vincent and the Grenadines */
replace lb_q15b_norm=. if country=="St. Vincent and the Grenadines" /* St. Vincent and the Grenadines */
replace lb_q15c_norm=. if country=="St. Vincent and the Grenadines" /* St. Vincent and the Grenadines */
replace cc_q29a_norm=. if country=="St. Vincent and the Grenadines" /* St. Vincent and the Grenadines */
drop if id_alex=="cc_English_1_1050" /* St. Vincent and the Grenadines */
replace cc_q39a_norm=. if id_alex=="cc_English_1_980" /* St. Vincent and the Grenadines */
replace cc_q9c_norm=. if id_alex=="cc_English_0_1181" /* St. Vincent and the Grenadines */
foreach v in cc_q9b_norm cc_q39a_norm cc_q39b_norm cc_q39c_norm cc_q39e_norm all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
replace `v'=. if id_alex=="cc_English_0_1258" /* St. Vincent and the Grenadines */
}
replace cc_q33_norm=. if id_alex=="cc_English_0_620" /* St. Vincent and the Grenadines */
replace cc_q11a_norm=. if cc_q11a_norm==1 & country=="St. Vincent and the Grenadines" /* St. Vincent and the Grenadines */
replace cc_q14b_norm=. if cc_q14b_norm==1 & country=="St. Vincent and the Grenadines" /* St. Vincent and the Grenadines */
replace cc_q16b_norm=. if id_alex=="cc_English_0_620"  /* St. Vincent and the Grenadines */
replace cc_q16e_norm=. if cc_q16e_norm==1 & country=="St. Vincent and the Grenadines" /* St. Vincent and the Grenadines */
replace all_q86_norm=. if id_alex=="cc_English_1_980" /* St. Vincent and the Grenadines */
replace all_q86_norm=. if id_alex=="lb_English_0_546" /* St. Vincent and the Grenadines */
replace all_q87_norm=. if id_alex=="cc_English_1_980" /* St. Vincent and the Grenadines */
replace cj_q20o_norm=. if id_alex=="cj_English_0_1046_2017_2018_2019_2021_2022" /* St. Vincent and the Grenadines */

replace all_q53_norm=. if id_alex=="lb_English_1_527" // St. Vincent and the Grenadines X
replace all_q93_norm=. if id_alex=="cj_English_0_1046_2017_2018_2019_2021_2022" // St. Vincent and the Grenadines X
replace all_q11_norm=. if id_alex=="lb_English_0_546" // St. Vincent and the Grenadines X
replace all_q12_norm=. if id_alex=="lb_English_1_527" // St. Vincent and the Grenadines X
replace all_q88_norm=. if id_alex=="lb_English_0_546" // St. Vincent and the Grenadines X
replace cc_q13_norm=. if id_alex=="cc_English_0_1589_2018_2019_2021_2022" // St. Vincent and the Grenadines X
replace all_q89_norm=. if id_alex=="cc_English_1_980" // St. Vincent and the Grenadines X
replace cj_q40b_norm=0.6666667 if id_alex=="cj_English_0_250_2021_2022" // St. Vincent and the Grenadines X
replace cj_q40c_norm=0.6666667 if id_alex=="cj_English_0_250_2021_2022" // St. Vincent and the Grenadines X 
replace cj_q40b_norm=0.6666667 if id_alex=="cj_English_0_531" // St. Vincent and the Grenadines X
replace cj_q40c_norm=0.6666667 if id_alex=="cj_English_0_531" // St. Vincent and the Grenadines X 
replace all_q12_norm=. if id_alex=="cc_English_0_1181" // St. Vincent and the Grenadines X
replace all_q12_norm=. if id_alex=="cc_English_0_1258" // St. Vincent and the Grenadines X
replace all_q12_norm=. if id_alex=="cc_English_0_1181" // St. Vincent and the Grenadines X
replace all_q53_norm=. if id_alex=="cc_English_0_1258" // St. Vincent and the Grenadines X
drop if id_alex=="cc_Arabic_0_708" //Sudan
drop if id_alex=="lb_Arabic_1_390" //Sudan
drop if id_alex=="cj_Arabic_1_160" //Sudan
drop if id_alex=="ph_English_0_294" //Sudan
replace all_q93_norm=. if country=="Sudan" //Sudan
replace all_q22_norm=. if country=="Sudan" //Sudan
replace all_q23_norm=. if country=="Sudan" //Sudan
replace all_q48_norm=. if id_alex=="lb_Arabic_0_158" //Sudan
replace all_q48_norm=. if id_alex=="cj_English_0_72" //Sudan
replace cc_q9c_norm=. if id_alex=="cc_English_0_305" //Sudan
replace all_q10_norm=. if id_alex=="lb_Arabic_0_158" //Sudan
replace all_q11_norm=. if id_alex=="lb_Arabic_0_158" //Sudan
replace all_q12_norm=. if id_alex=="lb_Arabic_0_158" //Sudan
replace all_q96_norm=. if id_alex=="lb_Arabic_0_158" //Sudan
replace cc_q40b_norm=. if id_alex=="cc_English_0_305" //Sudan
replace cj_q42c_norm=. if country=="Sudan" //Sudan
replace cj_q42d_norm=. if country=="Sudan" //Sudan
replace lb_q19a_norm=. if id_alex=="lb_Arabic_0_158" //Sudan
replace cc_q16g_norm=. if country=="Sudan" //Sudan
replace cc_q10_norm=. if id_alex=="cc_English_0_305" //Sudan
replace cc_q11a_norm=. if id_alex=="cc_English_0_305" //Sudan
replace cc_q16c_norm=0.666666666 if id_alex=="cc_English_1_451_2022" //Sudan
replace cc_q12_norm=. if country=="Sudan" //Sudan
replace all_q71_norm=. if country=="Sudan" //Sudan
replace all_q72_norm=. if country=="Sudan" //Sudan
replace all_q89_norm=. if country=="Sudan" //Sudan
replace all_q76_norm=. if id_alex=="cc_English_0_305" //Sudan
replace all_q77_norm=. if id_alex=="cc_English_0_305" //Sudan
replace all_q78_norm=. if id_alex=="cc_English_0_305" //Sudan
replace all_q79_norm=. if id_alex=="cc_English_0_305" //Sudan
replace all_q80_norm=. if id_alex=="cc_English_0_305" //Sudan
replace all_q81_norm=. if id_alex=="cc_English_0_305" //Sudan
replace cc_q26h_norm=. if id_alex=="cc_Arabic_1_779" //Sudan
replace cc_q28e_norm=. if id_alex=="cc_Arabic_1_779" //Sudan
replace all_q57_norm=. if id_alex=="cc_English_0_305" //Sudan
replace all_q59_norm=. if id_alex=="cc_English_0_305" //Sudan
replace all_q51_norm=. if id_alex=="lb_Arabic_0_158" //Sudan
replace all_q51_norm=. if id_alex=="cc_English_0_305" //Sudan
replace cc_q25_norm=. if id_alex=="cc_English_0_305" //Sudan
replace all_q10_norm=. if id_alex=="lb_English_0_61_2022" //Sudan
replace all_q11_norm=. if id_alex=="lb_English_0_61_2022" //Sudan
replace all_q12_norm=. if id_alex=="lb_English_0_61_2022" //Sudan
replace all_q29_norm=1 if id_alex=="cj_English_0_339_2022" //Sudan
replace all_q30_norm=1 if id_alex=="cj_English_0_339_2022" //Sudan
replace all_q1_norm=1 if id_alex=="cj_Arabic_0_309_2022" //Sudan X
replace all_q2_norm=. if id_alex=="cj_Arabic_0_309_2022" //Sudan X
replace all_q20_norm=. if id_alex=="cj_Arabic_0_309_2022" //Sudan X
replace all_q21_norm=. if id_alex=="cj_Arabic_0_309_2022" //Sudan X
replace all_q1_norm=1 if id_alex=="cc_English_1_451_2022" //Sudan X
replace all_q2_norm=. if id_alex=="cc_English_1_451_2022" //Sudan X
replace all_q20_norm=. if id_alex=="cc_English_1_451_2022" //Sudan X
replace all_q21_norm=. if id_alex=="cc_English_1_451_2022" //Sudan X
replace all_q2_norm=. if id_alex=="cj_English_0_830" //Sudan X
replace all_q3_norm=. if id_alex=="cj_English_0_830" //Sudan X
replace cc_q25_norm=. if id_alex=="cj_English_0_830" //Sudan X
replace all_q2_norm=. if id_alex=="cc_English_0_383_2022" //Sudan X
replace all_q3_norm=. if id_alex=="cc_English_0_383_2022" //Sudan X
replace cc_q25_norm=. if id_alex=="cc_English_0_383_2022" //Sudan X
replace all_q3_norm=. if id_alex=="cj_Arabic_0_309_2022" //Sudan X
replace all_q96_norm=. if id_alex=="cj_Arabic_0_379_2022" //Sudan X
replace cc_q9c_norm=.6666667 if id_alex=="cc_English_0_305" //Sudan X
replace lb_q8_norm=. if id_alex=="lb_Arabic_0_158" //Sudan X
replace ph_q9b_norm=. if id_alex=="ph_English_0_170" //Sudan X
replace cc_q16c_norm=.3333333 if id_alex=="cc_English_0_305" //Sudan X
replace cc_q10_norm=.3333333 if id_alex=="cc_Arabic_1_779" //Sudan X
replace cc_q11a_norm=.3333333 if id_alex=="cc_Arabic_1_779" //Sudan X
replace all_q83_norm=. if id_alex=="lb_Arabic_0_158" //Sudan X
replace cc_q26h_norm=. if id_alex=="cc_English_0_305" //Sudan X
replace all_q57_norm=. if id_alex=="lb_Arabic_0_158" //Sudan X
replace all_q51_norm=. if id_alex=="cc_English_1_451_2022" //Sudan X
replace all_q28_norm=. if id_alex=="cc_English_1_451_2022" //Sudan X
replace cj_q21g_norm=. if id_alex=="cj_English_0_72" //Sudan X
replace cj_q21h_norm=. if id_alex=="cj_English_0_72" //Sudan X
replace cj_q28_norm=. if id_alex=="cj_English_0_72" //Sudan X
replace cj_q21h_norm=. if id_alex=="cj_Arabic_0_379_2022" //Sudan X
replace all_q96_norm=. if id_alex=="cj_English_0_72" //Sudan X
replace cc_q40b_norm=.6666667 if id_alex=="cc_English_0_305" //Sudan X
replace cc_q26h_norm=.3333333 if id_alex=="cc_English_0_305" //Sudan X
replace all_q76_norm=. if id_alex=="lb_Arabic_0_158" //Sudan X
replace all_q9_norm=. if id_alex=="cc_English_1_451_2022" //Sudan X
replace all_q12_norm=. if id_alex=="cj_English_0_971_2021_2022" //Sudan X
replace all_q11_norm=. if id_alex=="cj_English_0_145_2022" //Sudan X
replace cc_q40b_norm=.6666667 if id_alex=="cc_Arabic_1_779" //Sudan X
replace cc_q9b_norm=. if id_alex=="cc_English_0_305" //Sudan X
replace cc_q9c_norm=. if id_alex=="cc_English_0_305" //Sudan X
replace cj_q20e_norm=. if id_alex=="cj_Arabic_0_309_2022" //Sudan X
replace cj_q7a_norm=. if id_alex=="cj_English_0_830" //Sudan X
replace cj_q7b_norm=. if id_alex=="cj_English_0_1042_2022" //Sudan X
replace cj_q28_norm=0 if id_alex=="cj_English_0_72" //Sudan X
replace cj_q40b_norm=. if id_alex=="cj_English_0_830" //Sudan X
replace cj_q40c_norm=. if id_alex=="cj_English_0_830" //Sudan X
replace cj_q20m_norm=. if id_alex=="cj_English_0_971_2021_2022" //Sudan X
replace cj_q27b_norm=. if country=="Sudan" //Sudan X
replace cj_q31f_norm=. if country=="Suriname" /* Suriname */
drop if id_alex=="cj_English_0_620" //Suriname
drop if id_alex=="lb_English_1_306_2022" //Suriname
replace cc_q13_norm=. if id_alex=="cc_English_1_423" //Suriname
replace all_q88_norm=. if id_alex=="lb_English_0_219" //Suriname
replace cc_q26a_norm=. if id_alex=="cc_English_1_423" //Suriname
drop if id_alex=="cc_English_0_930" //Suriname X
drop if id_alex=="cj_English_0_804" //Suriname X
drop if id_alex=="cc_English_0_322" //Suriname X
replace lb_q6c_norm=. if id_alex=="lb_English_0_157_2016_2017_2018_2019_2021_2022" //Suriname X
replace all_q57_norm=. if id_alex=="lb_English_0_153" //Suriname X
replace all_q58_norm=. if id_alex=="lb_English_0_153" //Suriname X
replace all_q94_norm=. if id_alex=="cc_English_1_1139_2022" //Suriname X
replace all_q18_norm=. if id_alex=="cj_English_0_814_2018_2019_2021_2022" //Suriname X
replace all_q21_norm=. if id_alex=="cc_English_1_563" //Suriname X
replace all_q32_norm=. if id_alex=="cc_English_1_1053_2018_2019_2021_2022" //Suriname X
replace lb_q23c_norm=. if id_alex=="lb_English_0_153" //Suriname X
replace lb_q23f_norm=. if id_alex=="lb_English_0_153" //Suriname X
replace all_q84_norm=. if id_alex=="lb_English_0_153" //Suriname X
replace all_q85_norm=. if id_alex=="lb_English_0_153" //Suriname X
replace all_q84_norm=. if id_alex=="cc_English_1_583" //Suriname X
replace all_q85_norm=. if id_alex=="cc_English_1_583" //Suriname X
replace all_q88_norm=. if id_alex=="lb_English_0_153" //Suriname X
replace all_q29_norm=. if id_alex=="cc_English_1_1476_2022" //Suriname X
replace cj_q42d_norm=. if id_alex=="cj_English_0_814_2018_2019_2021_2022" //Suriname X
replace lb_q23f_norm=. if id_alex=="lb_English_0_659" //Suriname X
replace all_q41_norm=1 if id_alex=="cc_English_1_1099" //Sweden X
replace all_q42_norm=1 if id_alex=="cc_English_1_1099" //Sweden X
replace all_q43_norm=1 if id_alex=="cc_English_1_1099" //Sweden X
drop if id_alex=="cc_English_0_1045" //Tanzania
drop if id_alex=="lb_English_0_43" //Tanzania
replace cc_q25_norm=. if id_alex=="cc_English_0_1231_2016_2017_2018_2019_2021_2022" //Tanzania X
replace all_q3_norm=. if id_alex=="cj_English_0_948_2019_2021_2022" //Tanzania X
replace all_q96_norm=. if id_alex=="cc_English_0_819_2019_2021_2022" //Tanzania X
replace all_q96_norm=. if id_alex=="cc_English_0_794_2019_2021_2022" //Tanzania X
replace cj_q40b_norm=. if id_alex=="cj_English_0_469_2013_2014_2016_2017_2018_2019_2021_2022" //Tanzania X
replace cj_q40c_norm=. if id_alex=="cj_English_0_469_2013_2014_2016_2017_2018_2019_2021_2022" //Tanzania X
drop if id_alex=="cj_English_0_209_2021_2022" //Tanzania
replace all_q59_norm=. if country=="Thailand" //Thailand
replace all_q89_norm=. if country=="Thailand" //Thailand
replace all_q90_norm=. if country=="Thailand" //Thailand
replace cj_q21a_norm=. if country=="Thailand" //Thailand
replace cj_q21h_norm=. if country=="Thailand" //Thailand
replace all_q85_norm=. if country=="Thailand" //Thailand
replace all_q29_norm=. if country=="Thailand" //Thailand
drop if id_alex=="cc_English_1_435" //Thailand
drop if id_alex=="cc_English_1_113" //Thailand
drop if id_alex=="cj_English_0_755" //Thailand
drop if id_alex=="lb_English_0_686" //Thailand
drop if id_alex=="ph_English_0_667_2021_2022" //Thailand
drop if id_alex=="ph_English_1_427_2022" //Thailand
replace lb_q16e_norm=. if id_alex=="lb_English_1_606" //Thailand
replace lb_q16f_norm=. if id_alex=="lb_English_1_606" //Thailand
replace lb_q23d_norm=. if id_alex=="lb_English_0_660" //Thailand
replace lb_q23e_norm=. if id_alex=="lb_English_0_660" //Thailand
replace lb_q23g_norm=. if id_alex=="lb_English_0_660" //Thailand
replace cj_q31g_norm=. if id_alex=="cj_English_0_988" //Thailand
replace cj_q42d_norm=. if id_alex=="cj_English_0_988" //Thailand
drop if id_alex=="cc_English_0_1231_2021_2022" //Thailand
replace all_q91_norm=. if id_alex=="cc_English_1_931" //Thailand
replace cc_q14a_norm=. if id_alex=="cc_English_1_931" //Thailand
replace cc_q14b_norm=. if id_alex=="cc_English_1_931" //Thailand
replace all_q2_norm=. if id_alex=="lb_English_0_660" //Thailand
replace all_q20_norm=. if id_alex=="lb_English_0_660" //Thailand
replace all_q21_norm=. if id_alex=="lb_English_0_660" //Thailand
replace all_q10_norm=. if id_alex=="lb_English_0_660" //Thailand
replace all_q11_norm=. if id_alex=="lb_English_0_660" //Thailand
replace all_q12_norm=. if id_alex=="lb_English_0_660" //Thailand
drop if id_alex=="lb_English_0_660" //Thailand X
replace cj_q20o_norm=. if id_alex=="cj_English_0_1049_2017_2018_2019_2021_2022" //Thailand X
replace cj_q12b_norm=. if id_alex=="cj_English_0_1010_2021_2022" //Thailand X
replace cj_q12d_norm=. if id_alex=="cj_English_0_256_2021_2022" //Thailand X
replace cj_q40c_norm=. if id_alex=="cj_English_0_1010_2021_2022" //Thailand X
replace cj_q31f_norm=. if id_alex=="cj_English_0_1049_2017_2018_2019_2021_2022" //Thailand X
replace cj_q31g_norm=. if id_alex=="cj_English_0_914_2022" //Thailand X
replace lb_q16a_norm=. if id_alex=="lb_English_0_518_2013_2014_2016_2017_2018_2019_2021_2022" //Thailand X
replace lb_q16b_norm=. if id_alex=="lb_English_0_518_2013_2014_2016_2017_2018_2019_2021_2022" //Thailand X
replace lb_q16c_norm=. if id_alex=="lb_English_0_518_2013_2014_2016_2017_2018_2019_2021_2022" //Thailand X
replace lb_q16d_norm=. if id_alex=="lb_English_0_518_2013_2014_2016_2017_2018_2019_2021_2022" //Thailand X
replace cj_q31g_norm=. if id_alex=="lb_English_0_518_2013_2014_2016_2017_2018_2019_2021_2022" //Thailand X
replace lb_q23f_norm=. if id_alex=="lb_English_1_606" //Thailand X
replace lb_q23g_norm=. if id_alex=="lb_English_1_606" //Thailand X
replace all_q30_norm=. if id_alex=="cc_English_0_1433_2018_2019_2021_2022" //Thailand X
replace all_q48_norm=. if id_alex=="cc_English_0_625_2016_2017_2018_2019_2021_2022" //Thailand X
replace all_q48_norm=. if id_alex=="cc_English_0_1433_2018_2019_2021_2022" //Thailand X
replace all_q50_norm=. if id_alex=="cc_English_0_625_2016_2017_2018_2019_2021_2022" //Thailand X
replace all_q50_norm=. if id_alex=="cc_English_0_842_2018_2019_2021_2022" //Thailand X
replace cc_q16b_norm=. if id_alex=="cc_English_0_1433_2018_2019_2021_2022" //Thailand X
replace cc_q16d_norm=. if id_alex=="cc_English_0_1433_2018_2019_2021_2022" //Thailand X
replace cj_q20m_norm=. if id_alex=="cj_English_0_1049_2017_2018_2019_2021_2022" //Thailand X
replace all_q22_norm=. if country=="Togo" //Togo
replace all_q24_norm=. if country=="Togo" //Togo
replace all_q2_norm=. if country=="Togo" //Togo
replace all_q33_norm=. if country=="Togo" //Togo
replace all_q47_norm=. if country=="Togo" //Togo
drop if id_alex=="cc_French_0_665" //Togo
drop if id_alex=="ph_English_1_801_2021_2022" //Togo
drop if id_alex=="cc_French_0_599" //Togo
drop if id_alex=="lb_English_0_256_2022" //Togo
replace all_q62_norm=. if id_alex=="cc_French_0_796_2018_2019_2021_2022" //Togo X
replace all_q63_norm=. if id_alex=="cc_French_0_796_2018_2019_2021_2022" //Togo X
replace all_q62_norm=. if id_alex=="lb_French_0_509" //Togo X
replace all_q63_norm=. if id_alex=="lb_French_0_509" //Togo X
replace lb_q6c_norm=. if id_alex=="lb_French_0_508_2018_2019_2021_2022" //Togo X
replace all_q50_norm=. if id_alex=="lb_French_0_508_2018_2019_2021_2022" //Togo X
replace lb_q19a_norm=. if id_alex=="lb_French_0_508_2018_2019_2021_2022" //Togo X
replace all_q86_norm=. if id_alex=="cc_English_0_1644_2021_2022" //Trinidad and Tobago X
replace all_q87_norm=. if id_alex=="cc_English_0_1644_2021_2022" //Trinidad and Tobago X
replace all_q80_norm=. if id_alex=="cc_English_1_1196_2021_2022" //Trinidad and Tobago X
replace all_q81_norm=. if id_alex=="cc_English_0_70_2016_2017_2018_2019_2021_2022" //Trinidad and Tobago X
drop if id_alex=="cj_French_0_986" //Tunisia
drop if id_alex=="lb_French_0_380" //Tunisia
drop if id_alex=="ph_French_0_500_2021_2022" //Tunisia
drop if id_alex=="cj_French_1_726_2018_2019_2021_2022" //Tunisia
replace cj_q31e_norm=. if id_alex=="cj_French_0_901" //Tunisia X
replace cj_q42c_norm=. if id_alex=="cj_French_0_901" //Tunisia X
replace lb_q16a_norm=. if id_alex=="lb_French_0_173" //Tunisia X
replace lb_q16f_norm=. if id_alex=="lb_French_0_173" //Tunisia X
replace all_q96_norm=. if id_alex=="cc_French_0_933_2016_2017_2018_2019_2021_2022" //Tunisia X
replace all_q96_norm=. if id_alex=="cc_French_0_713" //Tunisia X
replace all_q30_norm=. if id_alex=="cc_French_1_135_2017_2018_2019_2021_2022" //Tunisia X
replace all_q30_norm=. if id_alex=="cc_French_0_1483_2018_2019_2021_2022" //Tunisia X
replace all_q29_norm=. if id_alex=="cc_French_1_135_2017_2018_2019_2021_2022" //Tunisia X
replace lb_q6c_norm=. if id_alex=="lb_French_0_36_2019_2021_2022" //Tunisia X
replace all_q59_norm=. if id_alex=="cc_French_1_1053_2022" //Tunisia X
replace all_q89_norm=. if id_alex=="cc_French_1_1053_2022" //Tunisia X
replace all_q87_norm=. if id_alex=="cc_French_0_1616_2021_2022" //Tunisia X
replace all_q86_norm=. if id_alex=="cc_French_0_933_2016_2017_2018_2019_2021_2022" //Tunisia X
replace all_q90_norm=. if id_alex=="cc_French_0_941" //Tunisia X
replace all_q28_norm=. if id_alex=="cc_French_0_347" //Tunisia X
replace lb_q6c_norm=. if id_alex=="lb_French_0_100" //Tunisia X
replace all_q89_norm=. if id_alex=="lb_French_1_326_2022" //Tunisia X
replace all_q83_norm=. if id_alex=="lb_French_1_61_2014_2016_2017_2018_2019_2021_2022" //Tunisia X
replace all_q59_norm=. if id_alex=="lb_French_1_61_2014_2016_2017_2018_2019_2021_2022" //Tunisia X
replace cj_q8_norm=. if country=="Turkiye" //Turkey
drop if id_alex=="cj_English_0_445" //Turkiye
replace cj_q42c_norm=. if id_alex=="cj_English_0_270_2016_2017_2018_2019_2021_2022" //Turkiye
replace cj_q42d_norm=. if cj_q42d_norm==. & country=="Turkiye" //Turkiye
replace lb_q16b_norm=. if id_alex=="lb_English_0_67" //Turkiye
replace lb_q16d_norm=. if id_alex=="lb_English_0_793_2021_2022" //Turkiye
replace lb_q16f_norm=. if id_alex=="lb_English_0_793_2021_2022" //Turkiye
replace lb_q23b_norm=. if lb_q23b_norm==1 & country=="Turkiye" //Turkiye
replace lb_q23d_norm=. if lb_q23d_norm==1 & country=="Turkiye" //Turkiye
replace lb_q23e_norm=. if lb_q23e_norm==1 & country=="Turkiye" //Turkiye
replace lb_q23g_norm=. if lb_q23g_norm==1 & country=="Turkiye" //Turkiye
replace lb_q23f_norm=. if id_alex=="lb_English_0_463_2022" //Turkiye
replace lb_q2d_norm=. if lb_q2d_norm==1 & country=="Turkiye" //Turkiye
replace lb_q19a_norm=. if id_alex=="lb_English_0_67" //Turkiye
drop if id_alex=="cj_English_1_927_2017_2018_2019_2021_2022" //Turkiye
replace all_q96_norm=. if id_alex=="cc_English_0_987_2018_2019_2021_2022" //Turkiye X
replace all_q96_norm=. if id_alex=="lb_English_1_585_2019_2021_2022" //Turkiye X
replace lb_q2d_norm=.5 if id_alex=="lb_English_1_291_2018_2019_2021_2022" //Turkiye X
replace all_q49_norm=. if id_alex=="lb_English_0_67" //Turkiye X
replace all_q50_norm=. if id_alex=="lb_English_0_67" //Turkiye X
replace cj_q12a_norm=. if id_alex=="cj_English_0_1010" //Turkiye X
replace cj_q12b_norm=. if id_alex=="cj_English_0_1010" //Turkiye X
replace cj_q12d_norm=. if id_alex=="cj_English_0_1010" //Turkiye X
replace cj_q12e_norm=. if id_alex=="cj_English_0_1010" //Turkiye X
replace cj_q12f_norm=. if id_alex=="cj_English_0_1010" //Turkiye X
replace all_q85_norm=. if country=="Uganda" /* Uganda */
drop if id_alex=="cc_English_1_1156" //Uganda
drop if id_alex=="cc_English_1_1244" //Uganda
drop if id_alex=="cj_English_0_24_2022" //Uganda
replace all_q77_norm=. if id_alex=="cc_English_0_1128_2019_2021_2022" //Uganda X
replace all_q78_norm=. if id_alex=="cc_English_0_1128_2019_2021_2022" //Uganda X
replace all_q79_norm=. if id_alex=="cc_English_0_1128_2019_2021_2022" //Uganda X
replace all_q80_norm=. if id_alex=="cc_English_0_1128_2019_2021_2022" //Uganda X
replace all_q81_norm=. if id_alex=="cc_English_0_1128_2019_2021_2022" //Uganda X
replace all_q77_norm=. if id_alex=="cc_English_0_932_2021_2022" //Uganda X
replace all_q78_norm=. if id_alex=="cc_English_0_932_2021_2022" //Uganda X
replace all_q79_norm=. if id_alex=="cc_English_0_932_2021_2022" //Uganda X
replace all_q80_norm=. if id_alex=="cc_English_1_159_2021_2022" //Uganda X
replace all_q81_norm=. if id_alex=="cc_English_0_932_2021_2022" //Uganda X
replace all_q13_norm=. if id_alex=="cj_English_0_73_2018_2019_2021_2022" //Uganda X
replace all_q14_norm=. if id_alex=="cj_English_0_73_2018_2019_2021_2022" //Uganda X
replace all_q15_norm=. if id_alex=="cj_English_0_73_2018_2019_2021_2022" //Uganda X
replace all_q16_norm=. if id_alex=="cj_English_0_73_2018_2019_2021_2022" //Uganda X
replace all_q17_norm=. if id_alex=="cj_English_0_73_2018_2019_2021_2022" //Uganda X
replace all_q13_norm=. if id_alex=="cj_English_1_971" //Uganda X
replace all_q14_norm=. if id_alex=="cj_English_1_971" //Uganda X
replace all_q15_norm=. if id_alex=="cj_English_1_971" //Uganda X
replace all_q16_norm=. if id_alex=="cj_English_1_971" //Uganda X
replace all_q17_norm=. if id_alex=="cj_English_1_971" //Uganda X
replace all_q19_norm=. if id_alex=="cj_English_0_787_2022" //Uganda X
replace all_q20_norm=. if id_alex=="cj_English_0_787_2022" //Uganda X
replace all_q21_norm=. if id_alex=="cj_English_0_787_2022" //Uganda X
replace all_q13_norm=. if id_alex=="cj_English_0_341_2017_2018_2019_2021_2022" //Uganda X
replace all_q14_norm=. if id_alex=="cj_English_0_341_2017_2018_2019_2021_2022" //Uganda X
replace all_q15_norm=. if id_alex=="cj_English_0_341_2017_2018_2019_2021_2022" //Uganda X
replace all_q16_norm=. if id_alex=="cj_English_0_341_2017_2018_2019_2021_2022" //Uganda X
replace all_q17_norm=. if id_alex=="cj_English_0_341_2017_2018_2019_2021_2022" //Uganda X
replace all_q13_norm=. if id_alex=="cj_English_0_259_2017_2018_2019_2021_2022" //Uganda X
replace all_q14_norm=. if id_alex=="cj_English_0_259_2017_2018_2019_2021_2022" //Uganda X
drop if id_alex=="cc_Russian_0_891" //Ukraine
drop if id_alex=="cc_Russian_0_637_2019_2021_2022" //Ukraine
drop if id_alex=="ph_Russian_0_398" //Ukraine
replace all_q49_norm=. if all_q49_norm==0 & country=="Ukraine" //Ukraine
drop if id_alex=="cc_English_1_1586_2019_2021_2022" //Ukraine X
drop if id_alex=="cj_English_1_390_2016_2017_2018_2019_2021_2022" //Ukraine X
replace cj_q31e_norm=. if id_alex=="cj_Russian_1_324_2022" //Ukraine X
replace cj_q42c_norm=. if id_alex=="cj_Russian_1_324_2022" //Ukraine X
replace all_q88_norm=. if id_alex=="cc_Russian_0_501_2019_2021_2022" //Ukraine X
replace cc_q26a_norm=. if id_alex=="cc_Russian_0_501_2019_2021_2022" //Ukraine X
replace all_q88_norm=. if id_alex=="cc_Russian_0_255_2019_2021_2022" //Ukraine X
replace cj_q12c_norm=. if id_alex=="cj_English_1_303_2021_2022" //Ukraine X
replace cj_q12d_norm=. if id_alex=="cj_English_1_303_2021_2022" //Ukraine X
replace cj_q12e_norm=. if id_alex=="cj_English_1_303_2021_2022" //Ukraine X
replace cj_q12f_norm=. if id_alex=="cj_English_1_303_2021_2022" //Ukraine X
replace cj_q25c_norm=. if id_alex=="cj_English_0_1006_2021_2022" //Ukraine X
replace cj_q1_norm=. if id_alex=="cj_Russian_1_144" //Ukraine X
replace cj_q2_norm=. if id_alex=="cj_Russian_1_144" //Ukraine X
replace cj_q6d_norm=. if id_alex=="cj_English_0_714_2017_2018_2019_2021_2022" //Ukraine X
  replace lb_q23a_norm=. if id_alex=="lb_English_0_152_2016_2017_2018_2019_2021_2022" //Ukraine X
replace lb_q23b_norm=. if id_alex=="lb_English_0_152_2016_2017_2018_2019_2021_2022" //Ukraine X
replace lb_q23c_norm=. if id_alex=="lb_English_0_152_2016_2017_2018_2019_2021_2022" //Ukraine X
replace lb_q23d_norm=. if id_alex=="lb_English_0_152_2016_2017_2018_2019_2021_2022" //Ukraine X
replace lb_q23e_norm=. if id_alex=="lb_English_0_152_2016_2017_2018_2019_2021_2022" //Ukraine X
replace lb_q23a_norm=. if id_alex=="lb_Russian_1_607_2018_2019_2021_2022" //Ukraine X
replace lb_q23b_norm=. if id_alex=="lb_Russian_1_607_2018_2019_2021_2022" //Ukraine X
replace lb_q23c_norm=. if id_alex=="lb_Russian_1_607_2018_2019_2021_2022" //Ukraine X
replace lb_q23d_norm=. if id_alex=="lb_Russian_1_607_2018_2019_2021_2022" //Ukraine X
replace lb_q23e_norm=. if id_alex=="lb_Russian_1_607_2018_2019_2021_2022" //Ukraine X
replace lb_q23f_norm=. if id_alex=="lb_English_0_152_2016_2017_2018_2019_2021_2022" //Ukraine X
replace lb_q23g_norm=. if id_alex=="lb_English_0_152_2016_2017_2018_2019_2021_2022" //Ukraine X
replace lb_q23f_norm=. if id_alex=="lb_Russian_1_441_2018_2019_2021_2022" //Ukraine X
replace lb_q23g_norm=. if id_alex=="lb_Russian_1_441_2018_2019_2021_2022" //Ukraine X
replace all_q15_norm=. if id_alex=="cj_Russian_1_324_2022" //Ukraine X
replace all_q16_norm=. if id_alex=="cj_Russian_1_324_2022" //Ukraine X
replace all_q17_norm=. if id_alex=="cj_Russian_1_324_2022" //Ukraine X
replace all_q15_norm=. if id_alex=="cc_English_1_926_2017_2018_2019_2021_2022" //Ukraine X
replace all_q16_norm=. if id_alex=="cc_English_1_926_2017_2018_2019_2021_2022" //Ukraine X
replace all_q15_norm=. if id_alex=="cc_Russian_0_719_2019_2021_2022" //Ukraine X
replace all_q16_norm=. if id_alex=="cc_Russian_0_719_2019_2021_2022" //Ukraine X
replace all_q13_norm=. if id_alex=="cj_Russian_0_413_2019_2021_2022" //Ukraine X
replace all_q13_norm=. if id_alex=="lb_Russian_1_441_2018_2019_2021_2022" //Ukraine X
replace all_q14_norm=. if id_alex=="cc_English_0_834_2019_2021_2022" //Ukraine X
replace all_q14_norm=. if id_alex=="cc_Russian_1_1323_2019_2021_2022" //Ukraine X
replace cj_q22e_norm=. if id_alex=="cj_Russian_1_1086_2021_2022" //Ukraine X
replace cj_q6a_norm=. if id_alex=="cj_Russian_1_1086_2021_2022" //Ukraine X
replace cj_q6b_norm=. if id_alex=="cj_Russian_1_1086_2021_2022" //Ukraine X
replace cj_q6c_norm=. if id_alex=="cj_Russian_1_1086_2021_2022" //Ukraine X
replace cj_q6d_norm=. if id_alex=="cj_Russian_1_1086_2021_2022" //Ukraine X
replace cj_q22d_norm=. if id_alex=="cj_English_0_1006_2021_2022" //Ukraine X
replace cj_q25b_norm=. if id_alex=="cj_English_0_1006_2021_2022" //Ukraine X
replace cj_q12a_norm=. if id_alex=="cj_Russian_0_413_2019_2021_2022" //Ukraine X
replace cj_q12c_norm=. if id_alex=="cj_Russian_0_413_2019_2021_2022" //Ukraine X
replace cj_q12c_norm=. if id_alex=="cj_English_1_884_2017_2018_2019_2021_2022" //Ukraine X
replace cj_q20o_norm=. if id_alex=="cj_Russian_0_413_2019_2021_2022" //Ukraine X
replace cj_q20o_norm=. if id_alex=="cj_English_1_303_2021_2022" //Ukraine X
replace cj_q21h_norm=. if id_alex=="cj_English_1_303_2021_2022" //Ukraine X
replace all_q15_norm=. if id_alex=="cc_Russian_1_399_2021_2022" //Ukraine X
replace all_q16_norm=. if id_alex=="cc_Russian_1_399_2021_2022" //Ukraine X
replace all_q18_norm=. if id_alex=="cc_Russian_1_399_2021_2022" //Ukraine X
replace all_q94_norm=. if id_alex=="cc_Russian_1_399_2021_2022" //Ukraine X
replace all_q15_norm=. if id_alex=="cj_English_1_285_2022" //Ukraine X
replace all_q18_norm=. if id_alex=="cj_English_1_285_2022" //Ukraine X
replace all_q94_norm=. if id_alex=="cj_English_1_285_2022" //Ukraine X
replace all_q17_norm=. if id_alex=="cj_Russian_1_993_2021_2022" //Ukraine X
replace cj_q10_norm=. if id_alex=="cj_Russian_1_854_2019_2021_2022" //Ukraine X
replace all_q13_norm=. if id_alex=="cj_Russian_1_993_2021_2022" //Ukraine X
replace all_q13_norm=. if id_alex=="lb_Russian_0_236" //Ukraine X
*replace cc_q9c_norm=. if id_alex=="cc_Russian_0_1046_2019_2021_2022" //Ukraine X /*Fixed by Natalia to match Map 5*/
replace cc_q26b_norm=. if id_alex=="cc_English_1_860" //USA X
replace all_q86_norm=. if id_alex=="cc_English_1_860" //USA X
replace cj_q7a_norm=. if id_alex=="cj_English_1_641" //USA X
replace cj_q7b_norm=. if id_alex=="cj_English_1_641" //USA X
replace cj_q7c_norm=. if id_alex=="cj_English_1_641" //USA X
replace cj_q20a_norm=. if id_alex=="cj_English_1_641" //USA X
replace cj_q20b_norm=. if id_alex=="cj_English_1_641" //USA X
drop if id_alex=="cc_Spanish_1_176" //Uruguay X
replace ph_q5a_norm=. if id_alex=="ph_Spanish_1_263" //Uruguay X
replace ph_q5b_norm=. if id_alex=="ph_Spanish_1_263" //Uruguay X
replace cj_q24b_norm=. if id_alex=="cj_Spanish_0_266_2016_2017_2018_2019_2021_2022" //Uruguay X
replace cj_q34d_norm=. if id_alex=="cj_Spanish_0_130_2013_2014_2016_2017_2018_2019_2021_2022" //Uruguay X
replace all_q96_norm=. if id_alex=="cc_Spanish_0_1665_2021_2022" //Uruguay X
replace all_q96_norm=. if id_alex=="cj_Spanish_0_130_2013_2014_2016_2017_2018_2019_2021_2022" //Uruguay X
drop if id_alex=="lb_Spanish_0_372_2019_2021_2022" //Uruguay X
replace lb_q2d_norm=. if id_alex=="lb_Spanish_0_451" //Uruguay X
replace lb_q2d_norm=. if id_alex=="lb_Spanish_0_254" //Uruguay X
replace all_q62_norm=. if id_alex=="lb_Spanish_0_99_2022" //Uruguay X
replace cc_q26a_norm=. if country=="United Arab Emirates" /*UAE*/
replace cc_q33_norm=. if country=="United Arab Emirates" //UAE
replace cj_q11a_norm=. if country=="United Arab Emirates" //UAE
replace cj_q11b_norm=. if country=="United Arab Emirates" //UAE
replace cj_q31e_norm=. if country=="United Arab Emirates" //UAE
replace cj_q27a_norm=. if country=="United Arab Emirates" //UAE
replace cj_q27b_norm=. if country=="United Arab Emirates" //UAE
replace cj_q7c_norm=. if country=="United Arab Emirates" //UAE
replace cj_q24c_norm=. if country=="United Arab Emirates" //UAE
replace all_q13_norm=. if country=="United Arab Emirates" //UAE
replace cj_q2_norm=. if country=="United Arab Emirates" //UAE
replace cj_q31d_norm=. if country=="United Arab Emirates" //UAE
drop if id_alex=="cc_Arabic_0_245" //UAE
drop if id_alex=="cc_English_0_1024" //UAE
drop if id_alex=="cc_English_1_1411" //UAE
drop if id_alex=="cj_English_0_161" //UAE
drop if id_alex=="cj_Arabic_0_211" //UAE
drop if id_alex=="ph_English_1_365" //UAE
drop if id_alex=="ph_English_0_178" //UAE
replace cj_q31f_norm=. if id_alex=="cj_Arabic_1_482" //UAE
replace cj_q31g_norm=. if id_alex=="cj_Arabic_1_482" //UAE
replace cj_q20m_norm=. if id_alex=="cj_Arabic_1_482" //UAE
replace cj_q12b_norm=. if id_alex=="cj_English_0_745_2022" //UAE
replace cj_q12b_norm=. if id_alex=="cj_English_0_1089_2022" //UAE
drop if id_alex=="cj_Arabic_0_402_2022" //UAE
replace cc_q40a_norm=. if id_alex=="cc_English_1_788_2016_2017_2018_2019_2021_2022" //UAE X
replace cc_q40a_norm=. if id_alex=="cc_English_0_1345_2018_2019_2021_2022" //UAE X
replace cc_q22b_norm=. if id_alex=="cc_English_0_1422_2019_2021_2022" //UAE X
replace cc_q22c_norm=. if id_alex=="cc_English_0_1422_2019_2021_2022" //UAE X
replace cc_q22c_norm=. if id_alex=="cc_English_0_1477_2021_2022" //UAE X
replace cj_q26_norm=. if id_alex=="cj_English_0_832" //UAE X
replace all_q28_norm=. if id_alex=="cc_English_0_1153" //UAE X
replace cj_q34a_norm=. if id_alex=="cj_French_0_805_2022" //UAE X
replace cj_q33b_norm=. if id_alex=="cj_French_0_805_2022" //UAE X
drop if id_alex=="ph_English_1_395" //UK
drop if id_alex=="ph_English_1_207_2017_2018_2019_2021_2022" //UK
drop if id_alex=="cc_English_0_1416_2022" //USA
drop if id_alex=="cj_English_1_302" //USA
drop if id_alex=="ph_English_1_202_2021_2022" //USA
replace all_q21_norm=. if country=="United States" /* USA */
replace all_q1_norm=. if all_q1_norm==0 & country=="United States" //USA
drop if id_alex=="cc_Russian_1_339" //Uzbekistan
drop if id_alex=="cc_Russian_1_1463_2019_2021_2022" //
replace all_q1_norm=. if all_q1_norm==1 & country=="Uzbekistan" //Uzbekistan
replace cj_q32b_norm=. if country=="Uzbekistan" /* Uzbekistan */
drop if id_alex=="ph_Russian_0_79" /* Uzbekistan */

drop if id_alex=="cc_Russian_0_588_2022" //Uzbekistan X
replace cj_q42d_norm=. if id_alex=="cj_Russian_1_213_2021_2022" //Uzbekistan X
replace cj_q31e_norm=. if id_alex=="cj_Russian_0_305_2018_2019_2021_2022" //Uzbekistan X
replace cj_q42d_norm=. if id_alex=="cj_Russian_1_586" //Uzbekistan X
replace all_q87_norm=.5 if id_alex=="cc_English_0_1582_2022" //Uzbekistan X
replace all_q87_norm=.5 if id_alex=="cc_English_0_232_2022" //Uzbekistan X
replace all_q87_norm=. if id_alex=="cc_English_0_1644_2017_2018_2019_2021_2022" //Uzbekistan X
replace all_q87_norm=. if id_alex=="cc_Russian_0_1458_2017_2018_2019_2021_2022" //Uzbekistan X
replace all_q48_norm=. if id_alex=="cc_Russian_0_845" //Uzbekistan X
replace all_q48_norm=. if id_alex=="lb_English_0_737_2018_2019_2021_2022" //Uzbekistan X
replace ph_q3_norm=. if id_alex=="ph_English_0_312_2018_2019_2021_2022" //Uzbekistan X
drop if id_alex=="cc_Spanish_0_50" //Venezuela
drop if id_alex=="lb_Spanish_0_239" //Venezuela
drop if id_alex=="cj_English_1_215" //Venezuela
drop if id_alex=="cc_Spanish_0_787" //Venezuela X
replace cj_q8_norm=0 if id_alex=="cj_Spanish_1_1013" //Venezuela X
replace cj_q11a_norm=. if id_alex=="cj_Spanish_0_629_2018_2019_2021_2022" //Venezuela X
replace cj_q11b_norm=. if id_alex=="cj_Spanish_0_629_2018_2019_2021_2022" //Venezuela X
replace cj_q11a_norm=. if id_alex=="cj_Spanish_0_299" //Venezuela X
replace cj_q11b_norm=. if id_alex=="cj_Spanish_0_299" //Venezuela X
replace cj_q20o_norm=. if id_alex=="cj_Spanish_1_994" //Venezuela X
replace cj_q20o_norm=. if id_alex=="cj_Spanish_0_570" //Venezuela X
replace cj_q28_norm=. if country=="Vietnam" /* Vietnam */
replace ph_q9a_norm=. if country=="Vietnam" /* Vietnam */
drop if id_alex=="ph_English_1_358" /* Vietnam */
drop if id_alex=="lb_English_0_104_2019_2021_2022" /* Vietnam */
drop if id_alex=="cj_English_0_604" /* Vietnam */
drop if id_alex=="cj_English_0_937" /* Vietnam */
foreach v in cj_q31f_norm cj_q31g_norm cj_q42c_norm cj_q42d_norm {
replace `v'=. if id_alex=="cj_English_0_857_2014_2016_2017_2018_2019_2021_2022" /* Vietnam */
}
replace cj_q31f_norm=. if id_alex=="cj_English_0_604" /* Vietnam */
replace cj_q31g_norm=. if id_alex=="cj_English_0_604" /* Vietnam */
drop if id_alex=="cc_English_1_219_2022" /* Vietnam */
replace all_q59_norm=. if all_q59_norm==0 & country=="Vietnam" /* Vietnam */
replace cj_q15_norm=. if id_alex=="cj_English_1_685_2017_2018_2019_2021_2022" //Vietnam X
replace all_q30_norm=. if id_alex=="cc_English_0_781" //Vietnam X
replace all_q30_norm=. if id_alex=="cc_English_1_586" //Vietnam X
replace all_q30_norm=. if id_alex=="cc_English_0_1342_2022" //Vietnam X
replace all_q30_norm=. if id_alex=="cc_English_1_90_2016_2017_2018_2019_2021_2022" //Vietnam X
replace all_q89_norm=. if id_alex=="cc_English_0_146" //Vietnam X
replace all_q59_norm=. if id_alex=="cc_English_0_146" //Vietnam X
replace all_q89_norm=. if id_alex=="cc_English_0_675_2016_2017_2018_2019_2021_2022" //Vietnam X
replace all_q59_norm=. if id_alex=="cc_English_0_675_2016_2017_2018_2019_2021_2022" //Vietnam X
replace cj_q34a_norm=. if id_alex=="cj_English_0_1027_2022" //Vietnam X
replace cj_q34b_norm=. if id_alex=="cj_English_0_1027_2022" //Vietnam X
replace cj_q34c_norm=. if id_alex=="cj_English_0_1027_2022" //Vietnam X
replace cj_q34d_norm=. if id_alex=="cj_English_0_1027_2022" //Vietnam X
replace cj_q34e_norm=. if id_alex=="cj_English_0_1027_2022" //Vietnam X
replace cj_q33a_norm=. if id_alex=="cj_English_0_1027_2022" //Vietnam X
replace cj_q33b_norm=. if id_alex=="cj_English_0_1027_2022" //Vietnam X
replace cj_q33c_norm=. if id_alex=="cj_English_0_1027_2022" //Vietnam X
replace cj_q33d_norm=. if id_alex=="cj_English_0_1027_2022" //Vietnam X
replace cj_q33e_norm=. if id_alex=="cj_English_0_1027_2022" //Vietnam X
replace cj_q34a_norm=. if id_alex=="cj_English_0_639_2022" //Vietnam X
replace cj_q34c_norm=. if id_alex=="cj_English_0_639_2022" //Vietnam X
replace all_q30_norm=. if id_alex=="cc_English_1_1163" //Vietnam X
replace all_q29_norm=. if id_alex=="cc_English_1_1333_2019_2021_2022" //Vietnam X
replace all_q30_norm=. if id_alex=="cc_English_1_1333_2019_2021_2022" //Vietnam X
replace all_q29_norm=. if id_alex=="cj_English_0_943" //Vietnam X
replace all_q30_norm=0 if id_alex=="cc_English_1_490" //Vietnam X
replace all_q29_norm=0 if id_alex=="cc_English_1_490" //Vietnam X
replace all_q54_norm=. if id_alex=="cc_English_0_675_2016_2017_2018_2019_2021_2022" //Vietnam X
replace all_q54_norm=. if id_alex=="cc_English_1_184_2017_2018_2019_2021_2022" //Vietnam X
replace lb_q6c_norm=. if id_alex=="lb_English_1_83_2017_2018_2019_2021_2022" //Vietnam X
replace all_q90_norm=. if country=="Zambia" /* Zambia */
replace all_q91_norm=. if country=="Zambia" /* Zambia */
replace lb_q19a_norm=. if country=="Zambia" /* Zambia */
replace cc_q12_norm=. if country=="Zambia" /* Zambia */
replace all_q24_norm=. if country=="Zambia" /* Zambia */
drop if id_alex=="cj_English_0_1151_2022" //Zambia
foreach v in all_q22_norm all_q23_norm all_q24_norm all_q25_norm all_q26_norm all_q27_norm all_q8_norm {
replace `v'=. if id_alex=="cj_English_0_461" //Zambia
replace `v'=. if id_alex=="lb_English_1_479" //Zambia
}
replace all_q27_norm=. if all_q27_norm==1 & country=="Zambia" //Zambia
replace cj_q15_norm=. if id_alex=="cj_English_0_461" //Zambia
replace cj_q21h_norm=. if id_alex=="cj_English_0_461"  //Zambia
replace all_q48_norm=. if id_alex=="cc_English_0_128_2013_2014_2016_2017_2018_2019_2021_2022" //Zambia
replace all_q48_norm=. if id_alex=="lb_English_0_396" //Zambia
replace all_q49_norm=. if id_alex=="lb_English_0_396" //Zambia
drop if id_alex=="cj_English_0_461" //Zambia X
drop if id_alex=="cc_English_1_796_2022" //Zambia X
replace cj_q42c_norm=. if id_alex=="cj_English_1_583_2018_2019_2021_2022" //Zambia X
replace cj_q42c_norm=. if id_alex=="cj_English_0_669_2019_2021_2022" //Zambia X
replace cj_q15_norm=. if id_alex=="cj_English_0_342_2017_2018_2019_2021_2022" //Zambia X
replace cj_q15_norm=. if id_alex=="cj_English_1_583_2018_2019_2021_2022" //Zambia X
replace cc_q40a_norm=. if id_alex=="cc_English_0_821" //Zambia X
replace all_q22_norm=. if id_alex=="cc_English_1_1425_2022" //Zambia X
replace all_q22_norm=. if id_alex=="cc_English_0_1611_2022" //Zambia X
replace all_q22_norm=. if id_alex=="cc_English_0_465_2022" //Zambia X
replace all_q23_norm=. if id_alex=="lb_English_0_396" //Zambia X
replace all_q27_norm=. if id_alex=="cc_English_0_1186_2014_2016_2017_2018_2019_2021_2022" //Zambia X
drop if id_alex=="cc_English_0_721" //Zimbabwe
replace cc_q40a_norm=. if country=="Zimbabwe" /* Zimbabwe */
drop if id_alex=="cj_English_0_285_2016_2017_2018_2019_2021_2022" //Zimbabwe X
replace cc_q39e_norm=. if id_alex=="cc_English_0_1299_2016_2017_2018_2019_2021_2022" //Zimbabwe X
replace all_q47_norm=. if id_alex=="cc_English_0_1299_2016_2017_2018_2019_2021_2022" //Zimbabwe X
replace cc_q9c_norm=. if id_alex=="cc_English_0_1299_2016_2017_2018_2019_2021_2022" //Zimbabwe X
replace cc_q40b_norm=. if id_alex=="cc_English_0_1299_2016_2017_2018_2019_2021_2022" //Zimbabwe X



/* Edits made by Alicia and Natalia */

foreach v in cj_q12a_norm cj_q12b_norm cj_q12c_norm cj_q12d_norm cj_q12e_norm cj_q12f_norm cj_q20o_norm {
replace `v'=. if id_alex=="cj_English_1_895" //Malta
}

replace cj_q10_norm=. if id_alex=="cj_Arabic_0_1018" //Mauritania
replace all_q32_norm=. if id_alex=="cj_Arabic_0_1018" //Mauritania
replace all_q14_norm=. if id_alex=="cj_Arabic_0_1018" //Mauritania
replace cj_q20o_norm=. if id_alex=="cj_French_1_1261_2019_2021_2022" //Mauritania








br question year country longitudinal id_alex total_score f_1 f_2 f_3 f_4 f_6 f_7 f_8 if country=="Mauritania"


*drop if year<2019 & country~="Antigua and Barbuda" & country~="Dominica" & country~="St. Lucia"

drop total_score_mean
bysort country: egen total_score_mean=mean(total_score)

save "$path2data/2. Final/qrq.dta", replace


/*-----------------------------------------------------*/
/* Number of surveys per discipline, year, and country */
/*-----------------------------------------------------*/
gen aux_cc=1 if question=="cc"
gen aux_cj=1 if question=="cj"
gen aux_lb=1 if question=="lb"
gen aux_ph=1 if question=="ph"

local i=2013
	while `i'<=2023 {
		gen aux_cc_`i'=1 if question=="cc" & year==`i'
		gen aux_cj_`i'=1 if question=="cj" & year==`i'
		gen aux_lb_`i'=1 if question=="lb" & year==`i'
		gen aux_ph_`i'=1 if question=="ph" & year==`i'
	local i=`i'+1 
}	

gen aux_cc_23_long=1 if question=="cc" & year==2023 & longitudinal==1
gen aux_cj_23_long=1 if question=="cj" & year==2023 & longitudinal==1
gen aux_lb_23_long=1 if question=="lb" & year==2023 & longitudinal==1
gen aux_ph_23_long=1 if question=="ph" & year==2023 & longitudinal==1

bysort country: egen cc_total=total(aux_cc)
bysort country: egen cj_total=total(aux_cj)
bysort country: egen lb_total=total(aux_lb)
bysort country: egen ph_total=total(aux_ph)

local i=2013
	while `i'<=2023 {
		bysort country: egen cc_total_`i'=total(aux_cc_`i')
		bysort country: egen cj_total_`i'=total(aux_cj_`i')
		bysort country: egen lb_total_`i'=total(aux_lb_`i')
		bysort country: egen ph_total_`i'=total(aux_ph_`i')
	local i=`i'+1 
}	

bysort country: egen cc_total_2023_long=total(aux_cc_23_long)
bysort country: egen cj_total_2023_long=total(aux_cj_23_long)
bysort country: egen lb_total_2023_long=total(aux_lb_23_long)
bysort country: egen ph_total_2023_long=total(aux_ph_23_long)

egen tag = tag(country)
br country cc_total-ph_total_2023_long if tag==1

drop  aux_cc-tag

*----- Saving original dataset AFTER adjustments

save "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Data Analytics\8. Data\QRQ\QRQ_2023_clean.dta", replace

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------*/
/* Country Averages */
/*------------------*/
foreach var of varlist cc_q1_norm- all_q105_norm /*cc_q6a_usd cc_q6a_gni*/ {
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

order WJP_password, last //cc_q6a_usd cc_q6a_gni
drop WJP_password
save "$path2data/2. Final/qrq_country_averages_2023.dta", replace


br


*Create scores
do "C:\Users\nrodriguez\OneDrive - World Justice Project\Natalia\GitHub\ROLI_2024\1. Cleaning\QRQ\2. Code\Routines\scores.do"


*Saving scores in 2024 folder for analysis
save "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Data Analytics\7. WJP ROLI\ROLI_2024\1. Cleaning\QRQ\1. Data\3. Final\qrq_country_averages_2023.dta", replace



/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/










