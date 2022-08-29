



************************************ 
** Initialisization
************************************ 

		set type double
		capture log close
		
		

************************************ 
** Setting Globals
************************************ 
		
		
    
*Please change root as required		
global root 		"C:\Users\abrah\Dropbox\Thesis_2022\Code Base"		
global clean_data 	"$root\cleaned_data"
global raw_data 		"$root\raw_data"
global tables 	"$root\tables"
global figures 	"$root\figures"
global liss_clean "$root\liss_cleaned_data"





***************************************************************
*Predicted Alcohol for smoking from 18-25 (for studying vs non)
*************************************************************

use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear

gen age_range = ""

replace age_range = "40+" if age>40
replace age_range = "25-40" if age<=40 & age>25
replace age_range = "16-25" if age<=25 & age>=18
encode age_range ,gen(age_range_dummy)

keep if age_range == "16-25"

gen college_educated=0
replace college_educated=1 if inlist(education_cbs,4,5)


gen studying=0
replace studying=1 if occupation==6
keep if inlist(occupation,0,6,3)

keep if date!=tm(2018m11)
set scheme s2color
preserve
regress smoker_num_cigs_day i.date  i.occupation i.college_educated net_income_imputed i.dom_situation i.gender i.civil_status i.age gross_income_hh hh_children hh_members i.location_urban ///

margins date,over(occupation)
marginsplot,ytitle("Cigarettes smoked per day") ylabel(0(2)12)  xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(neast))  ///
     scale(*.7)  graphregion(color(white) lwidth(large)) yscale(titlegap(*10))

graph export "$figures/fig_smoking_study_vs_non.png", replace

restore
preserve
regress ethanol_amount  i.date  i.occupation i.college_educated net_income_imputed i.dom_situation i.gender i.civil_status i.age gross_income_hh hh_children hh_members i.location_urban ///

margins date,over(occupation)
marginsplot,ytitle("Ethanol Consumed (ml.)") ylabel(0(100)400) xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(neast))  ///
     scale(*.7)   graphregion(color(white) lwidth(large)) yscale(titlegap(*10))

graph export "$figures/fig_alcohol_study_vs_non.png", replace

restore



***************************************************************
*Predicted Smoking for Sex
*************************************************************

use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear

gen age_range = ""

replace age_range = "40+" if age>40
replace age_range = "25-40" if age<=40 & age>25
replace age_range = "16-25" if age<=25 & age>=18
encode age_range ,gen(age_range_dummy)


keep if date!=tm(2018m11)
set scheme s2color

regress smoker_num_cigs_day i.date  i.education_cbs   i.occupation ethanol_amount  net_income_imputed i.dom_situation i.gender i.civil_status i.age gross_income_hh hh_children hh_members i.location_urban ///

margins date,over(gender)
marginsplot,ytitle("Cigarettes smoked per day") ylabel(0(2)10) xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(seast))  ///
     scale(*.7)   graphregion(color(white) lwidth(large))   yscale(titlegap(*10))



graph export "$figures/fig_smoking_sex.png", replace






***************************************************************
*Predicted Alcohol for Sex
*************************************************************

use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear

gen age_range = ""

replace age_range = "40+" if age>40
replace age_range = "25-40" if age<=40 & age>25
replace age_range = "16-25" if age<=25 & age>=18
encode age_range ,gen(age_range_dummy)




keep if date!=tm(2018m11)
set scheme s2color

regress ethanol_amount i.date  i.education_cbs smoker_num_cigs_day i.occupation  net_income_imputed i.dom_situation i.gender i.civil_status i.age gross_income_hh hh_children hh_members i.location_urban ///

margins date,over(gender)
marginsplot,ytitle("Ethanol Consumed (ml.)") xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(seast))  ///
     scale(*.7)   graphregion(color(white) lwidth(large))  yscale(titlegap(*10))






graph export "$figures/fig_alcohol_sex.png", replace





***************************************************************
*Predicted Smoking for Income Tranches
*************************************************************

use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear

gen age_range = ""

replace age_range = "40+" if age>40
replace age_range = "25-40" if age<=40 & age>25
replace age_range = "16-25" if age<=25 & age>=18
encode age_range ,gen(age_range_dummy)


decode gross_income_cat,gen(gross_income_cat_string)

gen income_tranch = "Less than EUR 500" if inlist(gross_income_cat,0,1)
replace income_tranch ="EUR 500- EUR 1500" if inlist(gross_income_cat,2,3)
replace income_tranch ="EUR 1500- EUR 3000" if inlist(gross_income_cat,4,5,6)
replace income_tranch ="More than EUR 3000" if !inlist(gross_income_cat,0,1,2,3,4,5,6)

encode income_tranch,gen(income_tranch_s)

keep if date!=tm(2018m11)
set scheme s2color

regress smoker_num_cigs_day i.date i.income_tranch_s i.education_cbs i.occupation   i.dom_situation i.gender i.civil_status i.age  hh_children hh_members i.location_urban ///

margins date,over(income_tranch_s)
marginsplot,ytitle("Cigarettes smoked per day") ylabel(0(2)6) xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(seast))  ///
     scale(*.7)   graphregion(color(white) lwidth(large))  yscale(titlegap(*10))




graph export "$figures/fig_smoking_income.png", replace


***************************************************************
*Predicted Alcohol for Income Tranches
*************************************************************

use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear

gen age_range = ""

replace age_range = "40+" if age>40
replace age_range = "25-40" if age<=40 & age>25
replace age_range = "16-25" if age<=25 & age>=18
encode age_range ,gen(age_range_dummy)


decode gross_income_cat,gen(gross_income_cat_string)

gen income_tranch = "Less than EUR 500" if inlist(gross_income_cat,0,1)
replace income_tranch ="EUR 500- EUR 1500" if inlist(gross_income_cat,2,3)
replace income_tranch ="EUR 1500- EUR 3000" if inlist(gross_income_cat,4,5,6)
replace income_tranch ="More than EUR 3000" if !inlist(gross_income_cat,0,1,2,3,4,5,6)

encode income_tranch,gen(income_tranch_s)

keep if date!=tm(2018m11)
set scheme s2color

regress ethanol_amount i.date i.income_tranch_s i.education_cbs i.occupation   i.dom_situation i.gender i.civil_status i.age  hh_children hh_members i.location_urban ///

margins date,over(income_tranch_s)
marginsplot,ytitle("Ethanol Consumed (ml.)") xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(seast))  ///
     scale(*.7)  graphregion(color(white) lwidth(large))   yscale(titlegap(*10))




graph export "$figures/fig_alcohol_income.png", replace


regress   smoker_num_cigs_day i.date i.income_tranch_s i.education_cbs  i.occupation   i.dom_situation i.gender i.civil_status i.age  hh_children hh_members i.location_urban ///

margins date,over(income_tranch_s)
marginsplot,ytitle("Ethanol Consumed (ml.)") xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(seast))  ///
     scale(*.7)  graphregion(fcolor(white))  yscale(titlegap(*10))  graphregion(color(white) lwidth(large)) 




graph export "$figures/fig_smoking_income.png", replace


*************************
* Whisker Plot (Smoking)
*************************


use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear

gen age_range = ""

replace age_range = "40+" if age>40
replace age_range = "25-40" if age<=40 & age>25
replace age_range = "16-25" if age<=25 & age>=18
encode age_range ,gen(age_range_dummy)


decode gross_income_cat,gen(gross_income_cat_string)

gen income_tranch = "Less than EUR 500" if inlist(gross_income_cat,0,1)
replace income_tranch ="EUR 500- EUR 1500" if inlist(gross_income_cat,2,3)
replace income_tranch ="EUR 1500- EUR 3000" if inlist(gross_income_cat,4,5,6)
replace income_tranch ="More than EUR 3000" if !inlist(gross_income_cat,0,1,2,3,4,5,6)

encode income_tranch,gen(income_tranch_s)

keep smoker_num_cigs_day date income_tranch_s personal_id

reshape wide smoker_num_cigs_day, i(personal_id income_tranch_s) j(date)  

drop if smoker_num_cigs_day718  ==. 
drop if smoker_num_cigs_day723 ==. 
drop if smoker_num_cigs_day730==.



gen pre_post_covid1 = smoker_num_cigs_day723- smoker_num_cigs_day718 
gen pre_post_covid2 = smoker_num_cigs_day730- smoker_num_cigs_day718 

la var pre_post_covid1 "Pre-covid vs. April 2020"
la var pre_post_covid2 "Pre-covid vs. Nov. 2021"
drop if pre_post_covid1==0
drop if pre_post_covid2==0

set scheme plotplain 


graph hbox pre_post_covid1 pre_post_covid2  , over(income_tranch_s) box(1,color(dkgreen)) box(2,color(navy))  asyvars ytitle("Cigarettes smoked per day") graphregion(color(white) lwidth(large)) scale(*.7)  nooutsides   note("")





use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear





keep smoker_num_cigs_day date occupation  personal_id

reshape wide smoker_num_cigs_day, i(personal_id occupation ) j(date)  
drop if smoker_num_cigs_day718  ==. 
drop if smoker_num_cigs_day723 ==. 
drop if smoker_num_cigs_day730==.



gen pre_post_covid1 = smoker_num_cigs_day723- smoker_num_cigs_day718 
gen pre_post_covid2 = smoker_num_cigs_day730- smoker_num_cigs_day718 

la var pre_post_covid1 "Pre-covid vs. April 2020"
la var pre_post_covid2 "Pre-covid vs. Nov. 2021"
drop if inlist(occupation,8,9)
set scheme plotplain 
drop if pre_post_covid1==0 | pre_post_covid2==0 

graph hbox pre_post_covid1 pre_post_covid2  , over(occupation ) box(1,color(dkgreen)) box(2,color(navy))  asyvars ytitle("Cigarettes smoked per day") graphregion(color(white) lwidth(large)) scale(*.7)  nooutsides  note("")

*************************
* Whisker Plot (alcohol)
*************************

use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear

gen age_range = ""

replace age_range = "40+" if age>40
replace age_range = "25-40" if age<=40 & age>25
replace age_range = "16-25" if age<=25 & age>=18
encode age_range ,gen(age_range_dummy)


decode gross_income_cat,gen(gross_income_cat_string)

gen income_tranch = "Less than EUR 500" if inlist(gross_income_cat,0,1)
replace income_tranch ="EUR 500- EUR 1500" if inlist(gross_income_cat,2,3)
replace income_tranch ="EUR 1500- EUR 3000" if inlist(gross_income_cat,4,5,6)
replace income_tranch ="More than EUR 3000" if !inlist(gross_income_cat,0,1,2,3,4,5,6)

encode income_tranch,gen(income_tranch_s)

keep ethanol_amount date income_tranch_s personal_id

reshape wide ethanol_amount, i(personal_id income_tranch_s) j(date)  

drop if ethanol_amount718  ==. 
drop if ethanol_amount723 ==. 
drop if ethanol_amount730==.



gen pre_post_covid1 = ethanol_amount723- ethanol_amount718 
gen pre_post_covid2 = ethanol_amount730- ethanol_amount718 

la var pre_post_covid1 "Pre-covid vs. April 2020"
la var pre_post_covid2 "Pre-covid vs. Nov. 2021"
drop if pre_post_covid1==0
drop if pre_post_covid2==0

set scheme plotplain 


graph hbox pre_post_covid1 pre_post_covid2  , over(income_tranch_s) box(1,color(dkgreen)) box(2,color(navy))  asyvars ytitle("Ethanl amount (ml.)") graphregion(color(white) lwidth(large)) scale(*.7)  nooutsides   note("")





use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear





keep ethanol_amount date occupation  personal_id

reshape wide ethanol_amount, i(personal_id occupation ) j(date)  
drop if ethanol_amount718  ==. 
drop if ethanol_amount723 ==. 
drop if ethanol_amount730==.



gen pre_post_covid1 = ethanol_amount723- ethanol_amount718 
gen pre_post_covid2 = ethanol_amount730- ethanol_amount718 

la var pre_post_covid1 "Pre-covid vs. April 2020"
la var pre_post_covid2 "Pre-covid vs. Nov. 2021"
drop if inlist(occupation,8,9)
set scheme plotplain 
drop if pre_post_covid1==0 | pre_post_covid2==0 

graph hbox pre_post_covid1 pre_post_covid2  , over(occupation ) box(1,color(dkgreen)) box(2,color(navy))  asyvars ytitle("Ethanol amount (ml.)") graphregion(color(white) lwidth(large)) scale(*.7)  nooutsides  note("")





***************************************************************
*Predicted Alcohol for Childcare givers
*************************************************************
use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINEBG_TIME.dta", clear






foreach var in extra_child_care_self_dummy{
replace `var' = 0 if `var'==.
tab  `var' date
bysort personal_id : egen sum =  total(`var')
replace `var'= 1 if sum==1
drop sum
tab  `var' date
}

label define la 0 "Low or no extra child care" 1 "Extra child care"              
label values extra_child_care_self_dummy la
				 



regress ethanol_amount i.extra_child_care_self_dummy i.date i.gender age  net_income_imputed  i.dom_situation i.dwelling_type  gross_income_hh ///
             hh_children hh_members i.location_urban i.occupation i.origin i.edu_4, robust baselevels

margins date,over(extra_child_care_self_dummy gender)
marginsplot,ytitle("Ethanol Consumed (ml.)") xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(seast))  ///
     scale(*.7)  graphregion(color(white) lwidth(large))  yscale(titlegap(*10))



graph export "$figures/fig_alcohol_childcare.png", replace


***************************************************************
*Predicted Smoking  for Childcare givers
*************************************************************
use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINEBG_TIME.dta", clear

sort personal_id year


by personal_id  : replace extra_child_care_self_dummy = extra_child_care_self_dummy[_n-1] if extra_child_care_self_dummy == .
replace extra_child_care_self_dummy= 0 if date==tm(2019m11)



replace extra_child_care_self_dummy =  0 if extra_child_care_self_dummy ==.



label define la 0 "Low or no extra child care" 1 "Extra child care"              
label values extra_child_care_self_dummy la
				 


set scheme s2color
regress smoker_num_cigs_day i.extra_child_care_self_dummy i.date  i.occupation i.edu_4 net_income_imputed i.dom_situation i.gender i.civil_status i.age gross_income_hh hh_children hh_members i.location_urban 

margins date,over(extra_child_care_self_dummy gender)
marginsplot,ytitle("Cigarettes Smoked Per Day") xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(seast))  ///
     scale(*.7)  graphregion(color(white) lwidth(large))  yscale(titlegap(*10))


graph export "$figures/fig_smoking_childcare.png", replace





***************************************************************
*Predicted Smoking  for Childcare givers
*************************************************************


use "$clean_data\clean_time_use.dta", clear



sort personal_id year

label define lav 0 "Mostly working at workplace" 1 "Mostly working from home"            
label values hours_home_office_nokids_dummy lav

set scheme s2color
regress smoker_num_cigs_day i.hours_home_office_nokids_dummy i.date  i.occupation i.edu_4 net_income_imputed i.dom_situation i.gender i.civil_status i.age gross_income_hh hh_children hh_members i.location_urban 

margins date,over(hours_home_office_nokids_dummy)
marginsplot,ytitle("Cigarettes Smoked Per Day",size(small)) xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(seast))  ///
     scale(*.7)  graphregion(color(white) lwidth(large))  yscale(titlegap(*10))



graph export "$figures/working_from_home_cig.png", replace




regress ethanol_amount  i.hours_home_office_nokids_dummy i.date  i.occupation i.edu_4 net_income_imputed i.dom_situation i.gender i.civil_status i.age gross_income_hh hh_children hh_members i.location_urban 

margins date,over(hours_home_office_nokids_dummy)
marginsplot,ytitle("Ethanol Consumed (ml.)",size(small)) xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(seast))  ///
     scale(*.7) graphregion(color(white) lwidth(large))  yscale(titlegap(*10))




graph export "$figures/working_from_home_alcohol.png", replace


