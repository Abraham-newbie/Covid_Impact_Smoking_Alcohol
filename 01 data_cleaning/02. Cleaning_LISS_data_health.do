
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




************************************ 
** Cleaning Health Data
************************************ 



use "$clean_data\health_survey\health19l.dta",clear
append using "$clean_data\health_survey\health20m.dta" ,force
append using "$clean_data\health_survey\health21n.dta" ,force				
				
				
*keep var125 var126 var132 var266 var133 var135 var136 var137 var138 var139 var139 var140 var141 var142 var269 var020

*use "$clean_data\health_survey\health20m.dta",clear



*******************************
*Background variables
*******************************

ren var003 employed
ren var011 anxious
ren var014 depressed
ren var020 daily_act_affected
ren var100 work_dummy_selfass

ren var004 health_self_assessment
ren var005 health_self_assess_prior_year


ren var015 happy_how_often
ren var104 health_condition
ren var269 had_corona

gen corona_self_reported= 0
replace corona_self_reported=1 if had_corona==1


************************************
* Preparing Smoking Variables               *
*************************************

ren var125 ever_smoked_dummy 
ren var126 smoker_dummy 
ren var130 smoker_num_cigs_day

replace smoker_num_cigs_day=0 if smoker_num_cigs_day==.
replace ever_smoked_dummy=0 if ever_smoked_dummy==2 /*recoding no to 0 and yes to 1 */
replace smoker_dummy=0 if smoker_dummy==2 /*recoding no to 0 and yes to 1 */



************************************
* Preparing Alcohol Variables               *
*************************************

*alcohol
ren var133 alcohol_howoften12months  /*needs recoding as the variable is encoded in non-ordinal direction*/


gen alcohol_numoften12months= 7 if   alcohol_howoften12months== 1
replace alcohol_numoften12months= 6 if   alcohol_howoften12months== 2
replace alcohol_numoften12months= 5 if   alcohol_howoften12months== 3
replace alcohol_numoften12months= 4 if  alcohol_howoften12months== 4
replace alcohol_numoften12months= 3 if    alcohol_howoften12months== 5
replace alcohol_numoften12months= 2 if    alcohol_howoften12months== 6
replace alcohol_numoften12months= 1 if    alcohol_howoften12months== 7
replace alcohol_numoften12months= 0 if    alcohol_howoften12months== 8
label define alcohol_numoften12months_label 0 "Not at all" 1 "Once or twice a year" 2 "Once every two months" 3 "Once or twice a month" ///
                                      4 "once or twice a week" 5 "three of four days per week" 6 "five or six days per week" 7 "almost every day"                
label values alcohol_numoften12months alcohol_numoften12months_label
				 

foreach var in var135{
replace `var' = 0 if `var'==.

}
		*/		 

gen alcohol_howoften7days = var135 /*how many of past 7 days did you drink containing alcohol*/
/*n153 - n155 hard alcohol (for later use)*/

/*source: https://www.frontiersin.org/articles/10.3389/fpsyt.2021.622917/full*/




/*alcohol amounts to pure alcohol
1 standard drink (NIAA) definition is 14 grams of pure alcohol or 29.5 ml of alcohol (ethanol)*/



gen glass= 350
gen half_litre_glass= 500
gen half_litre_cans_bottle= 500
gen small_cans_bottles= 350









gen beer_ml= (var145*glass+ var146* half_litre_glass + var147*half_litre_cans_bottle+var148*small_cans_bottles)*0.05

gen strong_beer_ml=  (var149*glass+ var150* half_litre_glass + var151*half_litre_cans_bottle+var158*small_cans_bottles)*0.07

gen strong_spirits_ml= (var153*glass)*0.40

gen light_spirits_ml= (var154*glass)*0.15

gen wine_ml = (var155*glass)*0.11

gen premix_ml= (var156*glass)*0.05

foreach var in beer_ml strong_beer_ml strong_spirits_ml light_spirits_ml wine_ml premix_ml{
replace `var' = 0 if `var'==.
winsor2 `var', replace cuts(0 99)
	
}

gen ethanol_amount= beer_ml+strong_beer_ml+strong_spirits_ml+light_spirits_ml+wine_ml+premix_ml
winsor2 ethanol_amount, replace cuts(0 99)





************************************
* Preparing Drug Variables           *
************************************


foreach var in var159 var160 var161 var162 var163 var270{
replace `var' = 0 if `var'==.

}



/*1- never 2-sometimes 3- regularly*/
gen temp_drugs= var159+var160+var161+var162+var163+var270 /*if greater than 6 it means at least one type of drug was taken*/
replace temp_drugs=0 if temp_drugs==.

gen drug_any_taken = 0
replace drug_any_taken=1 if temp_drugs>6
drop temp_drugs




/*missing imply respondents answer they have taken no drugs*/

foreach var in var164 var165 var166 var167 var168 var271{
replace `var' = 0 if `var'==.

}
 
gen alldrugs_num_lastmonth=  var164 + var165 + var166 + var167 + var168 + var271
/*distinction based on https://www.government.nl/topics/drugs/difference-between-hard-and-soft-drugs */
gen softdrugs_num_lastmonth =   var164+var165
gen harddrugs_num_lastmonth =  var166+var167+var168+var271

foreach var in alldrugs_num_lastmonth softdrugs_num_lastmonth harddrugs_num_lastmonth {
replace `var' = 0 if `var'==.


}
drop var*
save "$clean_data\health1_18_21.dta",replace






***************************************
* Appending covid-impact lab data 
************************************

use  "$clean_data\health1_18_21.dta",clear

append using "$clean_data\covid_impact_clean.dta"




format year %d
*outlier cleaning

gen date = mofd(year)
format date %tm


summarize smoker_num_cigs_day, detail
winsor2 smoker_num_cigs_day, replace cuts(0 99)





save "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE.dta",replace





************************************
* Preparing Back ground variables         *
************************************


use "$liss_clean\background_full_2019.dta",clear
append using "$liss_clean\background_full_2020.dta",force
append using "$liss_clean\Background_full_2021.dta" ,force	

drop year
gen year = mdy(mod(date_fieldwork, 100),1,floor(date_fieldwork/100))
format year %d
gen date = mofd(year)
format date %tm


merge 1:1  personal_id year using "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE.dta"
keep if _merge==3
sort personal_id year
order personal_id year

save "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",replace



***************************************
* Appending time-use data
************************************

use  "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear
drop _merge

merge 1:1  personal_id year using "$clean_data\time_use_consumption_clean.dta"

keep if _merge==1 | _merge==3
save "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINEBG_TIME.dta",replace
