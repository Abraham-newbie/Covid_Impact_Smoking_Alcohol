


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




***************************************************************************
*Initial Data Cleaning for Regression
***********************************************************************


use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear


xtset personal_id date

la var smoker_num_cigs_day "Cigaretter Consumption"
la var alcohol_howoften7days "Alcohol Consumption"

gen ln_smoker_num_cigs_day= log(smoker_num_cigs_day)
la var ln_smoker_num_cigs_day  "Log Cigarettes per day"
la var smoker_num_cigs_day  "Cigarettes per day"

gen ln_alcohol_howoften7days= log(alcohol_howoften7days)
la var ln_alcohol_howoften7days  "Alcohol how often 7 days"
la var health_self_assessment


levelsof date, local(data)
capture label drop date
foreach d of local data {
     label define date `d' `"`:display %tm `d''"',  modify
}
label values date date

gen anxious_often=0

replace anxious_often =1 if inlist(anxious,4,5,6)


gen depressed_often=0

replace depressed_often =1 if inlist(depressed,4,5,6)

gen good_health=0

replace good_health=1 if inlist(health_self_assessment,3,4,5)


gen married_yes_no=0
replace married_yes_no=1 if civil_status==0

gen college_educated=0
replace college_educated=1 if inlist(education_cbs,4,5)


gen happy_often=0
replace happy_often=1 if inlist(happy_how_often,4,5,6)


la var anxious_often "Anxious often"

la var depressed_often "Depressed Often"

la var happy_often "Happy Often"


gen income_tranch = "Less than EUR 500" if inlist(gross_income_cat,0,1)
replace income_tranch ="EUR 500- EUR 1500" if inlist(gross_income_cat,2,3)
replace income_tranch ="EUR 1500- EUR 3000" if inlist(gross_income_cat,4,5,6)
replace income_tranch ="More than EUR 3000" if !inlist(gross_income_cat,0,1,2,3,4,5,6)
encode income_tranch,gen(income_tranch_s)


save  "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG_clean.dta",replace






****************************************************************************
global controls " i.income_tranch_s  i.dom_situation i.dwelling_type  hh_children hh_members i.location_urban i.occupation i.origin i.edu_4 "
*************************************************************************



***************************************************************************
*Mental Health Smoking and Alcohol reg predictive
***********************************************************************
use  "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG_clean.dta",clear





preserve
eststo clear
eststo: poisson smoker_num_cigs_day i.date age i.good_health  depressed_often#i.date anxious_often#i.date happy_often#i.date $controls if gender==0,cluster(hh_id) coefl


eststo: poisson smoker_num_cigs_day i.date age i.good_health  depressed_often#i.date anxious_often#i.date happy_often#i.date $controls if gender==1,cluster(hh_id) coefl


eststo: reg ethanol_amount i.date age i.good_health  depressed_often#i.date anxious_often#i.date happy_often#i.date $controls if gender==0,cluster(hh_id) coefl


eststo: reg  ethanol_amount  i.date age i.good_health  depressed_often#i.date anxious_often#i.date happy_often#i.date $controls if gender==1,cluster(hh_id) coefl




restore

esttab using "$tables\alcohol_smoking_reg_mental.tex", nobaselevels noconstant label b(3)  //////  mtitles("Male" "Female" "Male" "Female")
se stats(N r2 , labels( \hspace{2mm} "Observations" "$ R^2$")) booktabs title("Predictors of Smoking") nogap drop(*.income_tranch_s *.dom_situation *.dwelling_type   ///
             hh_children hh_members *.location_urban *.occupation *.origin *.edu_4 )  nogap ///
  noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) replace 
esttab




**********************************
* Predictors of Smoking Consumption Controls
********************************


use  "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG_clean.dta",clear
preserve


eststo clear


eststo: poisson smoker_num_cigs_day i.date age i.gender $controls ,cluster(hh_id) 

eststo: poisson smoker_num_cigs_day i.date age  $controls if gender==0 ,cluster(hh_id) 

eststo: poisson smoker_num_cigs_day i.date age   $controls if gender==1 ,cluster(hh_id) 

/*set scheme s2color
lasso2 smoker_num_cigs_day i.date age i.gender $controls, alpha(1)
lasso2, lic(ebic) 

*/

eststo: poisson smoker_num_cigs_day i.date age i.gender  2.income_tranch_s 2.dom_situation 1.dwelling_type hh_children 1.location_urban  ///
             1.location_urban i.occupation 2.origin 4.origin  3.edu_4,cluster(hh_id) 


restore


esttab using "$tables\smoking_consumption_controls.tex", nobaselevels noconstant label b(3) drop( hh_children hh_members *.location_urban *.occupation *.origin ) /// 
refcat(1.gender "Sex" 1.location_urban "Location" 1.edu_4 "Education" 1.dwelling "Dwelling Type", nolabel) ///
se stats(N r2 , labels( \hspace{2mm} "Observations " "$ R^2$")) booktabs title("") nogap   nogap ///
  noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) replace 


esttab , nobaselevels noconstant label b(3) /// 
refcat(1.gender "Female" 1.location_urban "Location" 1.edu_4 "Education", nolabel) ///
se stats(N r2 , labels( \hspace{2mm} "Observations" "$ R^2$")) nogap drop()  nogap  ///
  noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) replace 



**********************************
* Predictors of Alcohol Consumption Controls
********************************



use  "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG_clean.dta",clear
preserve


eststo clear



eststo: poisson ethanol_amount i.date age i.gender $controls ,cluster(hh_id) 

eststo: poisson ethanol_amount i.date age  $controls if gender==0 ,cluster(hh_id) 

eststo: poisson ethanol_amount i.date age   $controls if gender==1 ,cluster(hh_id) 


/*set scheme s2color
lasso2 smoker_num_cigs_day i.date age i.gender net_income_imputed  i.dom_situation i.dwelling_type   gross_income_hh ///
             hh_children hh_members i.location_urban i.occupation i.origin  i.edu_4 alcohol_howoften7days, alpha(1)
lasso2, lic(ebic) 

*/


eststo: poisson ethanol_amount i.date age i.gender  2.income_tranch_s 2.dom_situation 1.dwelling_type hh_children 1.location_urban  ///
             1.location_urban i.occupation 2.origin 4.origin  3.edu_4,cluster(hh_id) 


restore


esttab using "$tables\alcohol_consumption_controls.tex", nobaselevels noconstant label b(3) drop( hh_children hh_members *.location_urban *.occupation *.origin ) /// 
refcat(1.gender "Sex" 1.location_urban "Location" 1.edu_4 "Education" 1.dwelling "Dwelling Type", nolabel) ///
se stats(N r2 , labels( \hspace{2mm} "Observations " "$ R^2$")) booktabs title("Predictors of Smoking")nogap   nogap ///
  noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) replace 


esttab , nobaselevels noconstant label b(3) /// 
refcat(1.gender "Female" 1.location_urban "Location" 1.edu_4 "Education", nolabel) drop( hh_children hh_members *.location_urban *.occupation *.origin ) /// 
se stats(N r2 , labels( \hspace{2mm} "Observations" "$ R^2$")) nogap   nogap ///
  noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) replace 


set scheme plotplainblind

la var net_income_imputed "Net Income"
la var hh_members "Household Members"





eststo: poisson smoker_num_cigs_day i.date age i.gender hh_members  i.income_tranch_s i.dom_situation i.dwelling_type  ///
             hh_children i.location_urban i.occupation i.origin alcohol_howoften7days  i.edu_4  ,cluster(hh_id) 
estimates store Smoking

eststo: poisson ethanol_amount i.date age i.gender hh_members  i.income_tranch_s i.dom_situation i.dwelling_type  ///
             hh_children i.location_urban i.occupation i.origin   i.edu_4  ,cluster(hh_id) 
estimates store Alcohol



coefplot  Smoking || Alcohol , omitted baselevels drop(_cons)  keep(*.gender *net_income_imputed *.location_urban  *.income_tranch_s *.hh_children *hh_members 0.occupation 3.occupation *dom_situation *.edu_4 ) levels(90)  ///
   byopts(title(""  )  xrescale)  xline(0)  legend(off)  coeflabels(0.edu_4 = "Primary" 1.edu_4 = "Lower Secondary"  2.edu_4 = "Upper Secondary"  3.edu_4= "Tertiary" _cons = "Constant" 0.location_urban = "Location") ///
   headings(0.dom_situation = "{bf:Co-Habitation}"                     ///
             0.occupation = "{bf:Occupation}"                        ///
             0.edu_4 = "{bf:Education}"  ///
              1.income_tranch_s = "{bf:Income}"  ///
               0.location_urban = "{bf:Location}")  ///

graph export "$figures/coef_plot.png", replace



***************************************************************
*Predicted Smoking and Alcohol for Care-Givers
*************************************************************


use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINEBG_TIME.dta",clear

xtset personal_id date

la var smoker_num_cigs_day "Cigaretter Consumption"
la var alcohol_howoften7days "Alcohol Consumption"

gen ln_smoker_num_cigs_day= log(smoker_num_cigs_day)
la var ln_smoker_num_cigs_day  "Log Cigarettes per day"
la var smoker_num_cigs_day  "Cigarettes per day"

gen ln_alcohol_howoften7days= log(alcohol_howoften7days)
la var ln_alcohol_howoften7days  "Alcohol how often 7 days"
la var health_self_assessment


levelsof date, local(data)
capture label drop date
foreach d of local data {
     label define date `d' `"`:display %tm `d''"',  modify
}
label values date date

gen anxious_often=0

replace anxious_often =1 if inlist(anxious,4,5,6)


gen depressed_often=0

replace depressed_often =1 if inlist(depressed,4,5,6)

gen good_health=0

replace good_health=1 if inlist(health_self_assessment,3,4,5)


gen married_yes_no=0
replace married_yes_no=1 if civil_status==0

gen college_educated=0
replace college_educated=1 if inlist(education_cbs,4,5)


gen happy_often=0
replace happy_often=1 if inlist(happy_how_often,4,5,6)


la var anxious_often "Anxious often"

la var depressed_often "Depressed Often"

la var happy_often "Happy Often"


gen income_tranch = "Less than EUR 500" if inlist(gross_income_cat,0,1)
replace income_tranch ="EUR 500- EUR 1500" if inlist(gross_income_cat,2,3)
replace income_tranch ="EUR 1500- EUR 3000" if inlist(gross_income_cat,4,5,6)
replace income_tranch ="More than EUR 3000" if !inlist(gross_income_cat,0,1,2,3,4,5,6)
encode income_tranch,gen(income_tranch_s)



sort personal_id year



*by personal_id  : replace extra_child_care_self_dummy = extra_child_care_self_dummy[_n-1] if extra_child_care_self_dummy == .
*replace extra_child_care_self_dummy= 0 if date==tm(2019m11)


*by personal_id  : replace extra_child_care_partner_dummy = extra_child_care_partner_dummy[_n-1] if extra_child_care_partner_dummy == .
*replace extra_child_care_partner_dummy= 0 if date==tm(2019m11)


*by personal_id  : replace extra_child_care_otherarr_dummy = extra_child_care_otherarr_dummy[_n-1] if extra_child_care_otherarr_dummy == .
*replace extra_child_care_otherarr_dummy= 0 if date==tm(2019m11)



foreach var in extra_child_care_self_dummy extra_child_care_partner_dummy extra_child_care_otherarr_dummy{
replace `var' = 0 if `var'==.
tab  `var' date
bysort personal_id : egen sum =  total(`var')
replace `var'= 1 if sum==1
drop sum
tab  `var' date
}




preserve


eststo clear




eststo: reg smoker_num_cigs_day i.extra_child_care_self_dummy#i.date i.extra_child_care_partner_dummy#i.date  i.extra_child_care_otherarr_dummy#i.date  i.date age  $controls if gender==0, coeflegend cluster(hh_id) 
 

eststo: reg smoker_num_cigs_day i.extra_child_care_self_dummy#i.date i.extra_child_care_partner_dummy#i.date i.extra_child_care_otherarr_dummy#i.date  i.date age  $controls if gender==1 , coeflegend cluster(hh_id) 


eststo: reg ethanol_amount   i.extra_child_care_self_dummy#i.date i.extra_child_care_partner_dummy#i.date i.extra_child_care_otherarr_dummy#i.date i.date age  $controls  if gender==0, cluster(hh_id) 


eststo: reg ethanol_amount i.extra_child_care_self_dummy#i.date i.extra_child_care_partner_dummy#i.date i.extra_child_care_otherarr_dummy#i.date  i.date age $controls if gender==1, coeflegend  cluster(hh_id) 


/*set scheme s2color
lasso2 alcohol_howoften7days i.date age i.gender net_income_imputed  i.dom_situation i.dwelling_type  i.education_cbs gross_income_hh ///
             hh_children hh_members i.location_urban i.occupation i.origin  i.edu_4 smoker_num_cigs_day, alpha(1)
lasso2, lic(ebic) 

*/



restore

esttab using "$clean_data\caregiver_regression.tex", nobaselevels noconstant label b(3) /// 
se stats(N r2 , labels( \hspace{2mm} "Observations" "$ R^2$"))  drop(*.income_tranch_s *.dom_situation *.dwelling_type   ///
             hh_children hh_members *.location_urban *.occupation *.origin *.edu_4 ) booktabs title("Predictors of Smoking")nogap nogap ///
  noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) interaction(" $\times$ ")style(tex) replace

esttab,nobaselevels noconstant label b(3) /// 
se stats(N r2 , labels( \hspace{2mm} "Observations" "$ R^2$"))  drop(*.income_tranch_s *.dom_situation *.dwelling_type   ///
             hh_children hh_members *.location_urban *.occupation *.origin *.edu_4 )  title("Predictors of Smoking")nogap ///
  noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) interaction(" $\times$ ") replace





***************************************************************
*Predicted Smoking and Alcohol for Extra Home Office Hours
*************************************************************


use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINEBG_TIME.dta",clear

xtset personal_id date

la var smoker_num_cigs_day "Cigaretter Consumption"
la var alcohol_howoften7days "Alcohol Consumption"

gen ln_smoker_num_cigs_day= log(smoker_num_cigs_day)
la var ln_smoker_num_cigs_day  "Log Cigarettes per day"
la var smoker_num_cigs_day  "Cigarettes per day"

gen ln_alcohol_howoften7days= log(alcohol_howoften7days)
la var ln_alcohol_howoften7days  "Alcohol how often 7 days"
la var health_self_assessment


levelsof date, local(data)
capture label drop date
foreach d of local data {
     label define date `d' `"`:display %tm `d''"',  modify
}
label values date date

gen anxious_often=0

replace anxious_often =1 if inlist(anxious,4,5,6)


gen depressed_often=0

replace depressed_often =1 if inlist(depressed,4,5,6)

gen good_health=0

replace good_health=1 if inlist(health_self_assessment,3,4,5)


gen married_yes_no=0
replace married_yes_no=1 if civil_status==0

gen college_educated=0
replace college_educated=1 if inlist(education_cbs,4,5)


gen happy_often=0
replace happy_often=1 if inlist(happy_how_often,4,5,6)


la var anxious_often "Anxious often"

la var depressed_often "Depressed Often"

la var happy_often "Happy Often"


gen income_tranch = "Less than EUR 500" if inlist(gross_income_cat,0,1)
replace income_tranch ="EUR 500- EUR 1500" if inlist(gross_income_cat,2,3)
replace income_tranch ="EUR 1500- EUR 3000" if inlist(gross_income_cat,4,5,6)
replace income_tranch ="More than EUR 3000" if !inlist(gross_income_cat,0,1,2,3,4,5,6)
encode income_tranch,gen(income_tranch_s)



sort personal_id year


replace hours_home_office_no_kids= 0 if hours_home_office_no_kids==.
replace hours_home_office_kids_care=0 if hours_home_office_kids_care==.


gen hours_home_office_nokids_dummy=0
replace hours_home_office_nokids_dummy=1 if  hours_home_office_no_kids>=20

gen hours_home_office_kidscare_dummy=0
replace hours_home_office_kidscare_dummy=1 if  hours_home_office_kids_care>=20



sort personal_id year


bysort personal_id : egen sum =  total(hours_home_office_nokids_dummy)
replace hours_home_office_nokids_dummy = 1 if sum==1
drop sum

bysort personal_id : egen sum =  total(hours_home_office_kidscare_dummy)
replace hours_home_office_kidscare_dummy = 1 if sum==1

preserve


eststo clear




eststo: reg smoker_num_cigs_day i.hours_home_office_nokids_dummy#i.date i.hours_home_office_kidscare_dummy#i.date i.date age  $controls if gender==0, coeflegend cluster(hh_id) 
 

eststo: reg smoker_num_cigs_day i.hours_home_office_nokids_dummy#i.date i.hours_home_office_kidscare_dummy#i.date  i.date age  $controls if gender==1 , coeflegend cluster(hh_id) 


eststo: reg ethanol_amount   i.hours_home_office_nokids_dummy#i.date i.hours_home_office_kidscare_dummy#i.date i.date age  $controls  if gender==0,  coeflegend cluster(hh_id)


eststo: reg ethanol_amount i.hours_home_office_nokids_dummy#i.date i.hours_home_office_kidscare_dummy#i.date i.date age $controls if gender==1, coeflegend  cluster(hh_id) 


/*set scheme s2color
lasso2 alcohol_howoften7days i.date age i.gender net_income_imputed  i.dom_situation i.dwelling_type  i.education_cbs gross_income_hh ///
             hh_children hh_members i.location_urban i.occupation i.origin  i.edu_4 smoker_num_cigs_day, alpha(1)
lasso2, lic(ebic) 

*/



restore

esttab using "$clean_data\homeofficeworker_regression.tex", nobaselevels noconstant label b(3) /// 
se stats(N r2 , labels( \hspace{2mm} "Observations" "$ R^2$"))  drop(*.income_tranch_s *.dom_situation *.dwelling_type   ///
             hh_children hh_members *.location_urban *.occupation *.origin *.edu_4 ) booktabs title("Predictors of Smoking")nogap nogap ///
  noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) interaction(" $\times$ ")style(tex) replace

esttab,nobaselevels noconstant label b(3) /// 
se stats(N r2 , labels( \hspace{2mm} "Observations" "$ R^2$"))  drop(*.income_tranch_s *.dom_situation *.dwelling_type   ///
             hh_children hh_members *.location_urban *.occupation *.origin *.edu_4 )  title("Predictors of Smoking")nogap ///
  noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) interaction(" $\times$ ") replace
