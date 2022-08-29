
************************************ 
** Initialisization
************************************ 

		set type double
		capture log close
		
		

************************************ 
** Setting Globals
************************************ 
		
		
		
	
		
		
global root 		"C:\Users\abrah\Dropbox\Thesis_2022\Code Base"
global clean_data 	"$root\cleaned_data"
global raw_data 		"$root\raw_data"
global tables 	"$root\tables"
global figures 	"$root\figures"





************************************ 
** Loading Data
************************************ 
				
************************************ 
** Loading Health
************************************ 
				
	
foreach year in  19l 20m 21n{

	
use "$raw_data\health_surveys\ch`year'_EN_1.0p.dta",clear



foreach var of varlist _all {

   	local newname = substr("`var'", 6, .)
	local newname = "var" + "`newname'"
   	rename `var' `newname'
}
rename var_encr personal_id



gen year = .


replace year = mdy(11,1,2018) if "`year'" == "18k"
replace year = mdy(11,1,2019) if "`year'" == "19l"
replace year = mdy(11,1,2020) if "`year'" == "20m"
replace year = mdy(11,1,2021) if "`year'" == "21n"

save "$clean_data\health_survey\health`year'.dta",replace
}  


use  "$clean_data\health_survey\health19l.dta", clear
append using "$clean_data\health_survey\health20m.dta" ,force
append using "$clean_data\health_survey\health21n.dta" ,force




************************************ 
** Loading Covid Impact Data
************************************ 



use "$raw_data\covid_impact\covid_data_2020_04.dta",clear	

foreach var in hours_home hours_workplace {
replace `var' = 0 if `var'==.

}
gen employed=0
replace employed =1 if hours_home>0 | hours_workplace>0 



gen dailydate = dofc(month)
format month %tcM_CY
tab month

gen corona_self_reported=0
replace corona_self_reported=1 if infection_diagnosed ==0


foreach var in freq_soothing freq_soft_drugs freq_xtc freq_psychodelic freq_hard_drugs nr_cigarettes_day{
replace `var' = 0 if `var'==.

}

gen softdrugs_num_lastmonth=  freq_soothing + freq_soft_drugs 
gen  harddrugs_num_lastmonth = freq_xtc + freq_psychodelic + freq_hard_drugs
gen alldrugs_num_lastmonth= softdrugs_num_lastmonth+harddrugs_num_lastmonth
ren nr_cigarettes_day smoker_num_cigs_day
ren alcohol_amount alcohol_howoften7days


gen glass= 350
gen half_litre_glass= 500
gen half_litre_cans_bottle= 500
gen small_cans_bottles= 350




gen beer_ml= (beer_glasses*glass+ half_litre_glass*beer_hliter_glasses+ half_litre_cans_bottle*beer_hliter_bottles+small_cans_bottles*beer_bottles)*0.05

gen strong_beer_ml=  (strong_beer_glasses*glass+ strong_beer_hliter_glasses* half_litre_glass + strong_beer_hliter_bottles*half_litre_cans_bottle+strong_beer_bottles*small_cans_bottles)*0.07

gen strong_spirits_ml= (liquor_sort*glass)*0.40

gen light_spirits_ml= (sherry_sort*glass)*0.15

gen wine_ml = (wine_sort*glass)*0.11

gen premix_ml= (alcopops_bottles*glass)*0.05

foreach var in beer_ml strong_beer_ml strong_spirits_ml light_spirits_ml wine_ml premix_ml{
replace `var' = 0 if `var'==.
winsor2 `var', replace cuts(0 99)
	
}

gen ethanol_amount= beer_ml+strong_beer_ml+strong_spirits_ml+light_spirits_ml+wine_ml+premix_ml
winsor2 ethanol_amount, replace cuts(0 99)









keep employed personal_id softdrugs_num_lastmonth  harddrugs_num_lastmonth alldrugs_num_lastmonth smoker_num_cigs_day alcohol_howoften7days ethanol_amount *_ml
gen year = mdy(4,1,2020)


save "$clean_data\covid_impact_clean.dta",replace




***************************************
* Cleaning Time Use Consumption Data
************************************

use  "$liss_clean\time_use_consumption.dta",clear




gen hours_cc_young_otherarr =  hours_cc_young_total - (hours_cc_young_partner +hours_cc_young_self)
gen hours_cc_young_otherarr_202002 =  hours_cc_young_total_202002 - (hours_cc_young_partner_202002 +hours_cc_young_self_202002)



gen extra_child_care_self = hours_cc_young_self - hours_cc_young_self_202002
gen extra_child_care_partner = hours_cc_young_partner - hours_cc_young_partner_202002
gen extra_child_care_otherarr= hours_cc_young_otherarr - hours_cc_young_otherarr_202002
gen extra_child_care_daycare= hours_cc_young_daycare - hours_cc_young_daycare_202002

gen extra_child_care_self_percent = (hours_cc_young_self - hours_cc_young_self_202002)/hours_cc_young_self*100
gen extra_child_care_partner_percent  = (hours_cc_young_partner - hours_cc_young_partner_202002)/hours_cc_young_partner*100
gen extra_child_otherarr_percent = (hours_cc_young_otherarr-hours_cc_young_otherarr_202002)/hours_cc_young_otherarr*100
gen extra_child_care_daycare_percent= ((hours_cc_young_daycare - hours_cc_young_daycare_202002)/hours_cc_young_daycare)*100

gen extra_child_care_self_dummy=0
replace extra_child_care_self_dummy=1 if extra_child_care_self_percent>10  & extra_child_care_self_percent!=.


gen extra_child_care_partner_dummy=0
replace extra_child_care_partner_dummy=1 if extra_child_care_partner_percent>10 & extra_child_care_partner_percent!=.



gen extra_child_care_otherarr_dummy=0
replace extra_child_care_otherarr_dummy=1 if extra_child_otherarr_percent >10 & extra_child_otherarr_percent !=.


gen extra_child_care_daycare_dummy=0
replace extra_child_care_daycare_dummy=1 if extra_child_care_daycare_percent>10 & extra_child_care_daycare_percent !=.

keep if inlist(date_fieldwork,6)

gen date = 202004

drop year
gen year = mdy(mod(date, 100),1,floor(date/100))
format year %d

keep year personal_id extra* hours_work hours_home_office_no_kids hours_home_office_kids_care hours_homeschooling




save  "$clean_data\time_use_consumption_clean.dta", replace
