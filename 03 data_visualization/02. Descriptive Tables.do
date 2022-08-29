
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

 
 

set scheme plotplainblind




************************************
* Make Balance Table        *
************************************
use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear



preserve
iebaltab   gender education_cbs employed, grpvar(date) control(718) rowvarlabels browse
restore

preserve

iebaltab  gender age, grpvar(date) rowvarlabels control(718) savetex("$tables\table1_balancetable.tex")  replace

restore



/*
iebaltab smoker_num_cigs_day alcohol_howoften7days  ///
                  alldrugs_num_lastmonth  softdrugs_num_lastmonth harddrugs_num_lastmonth  ///, grpvar(date) rowvarlabels control(2020) order(2021 2020 2019 2018)  ///
 savetex("$tables\balancetable.tex")  replace

iebaltab ever_smoked_dummy smoker_dummy smoker_num_cigs_day smoker_ml_vapors_day alcohol_howoften12months alcohol_howoften7days drug_any_taken  health_self_assessment   ///
                  alldrugs_num_lastmonth  softdrugs_num_lastmonth harddrugs_num_lastmonth  ///
                   health_self_assess_prior_year education_cbs corona_self_reported , grpvar(year) rowvarlabels  control(2020) order(2021 2020 2019 2018)  ///
browse 

*/



************************************
use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear




la var smoker_dummy "Smoker"

la var smoker_num_cigs_day "Cigarettes smoked average per day"

la var alcohol_howoften7days "Alcohol how often last 7 days"

la var ethanol_amount "Ethanol Consumed (ml.)"

eststo clear
gen date_s = date
sort date_s
preserve
keep if inlist(edu,0,1)

by date_s: eststo: estpost summarize  smoker_num_cigs_day ethanol_amount, listwise
restore

esttab , cells(mean(fmt(%5.2f))  sd(fmt(%5.2f)) )  label nodepvar unstack   gaps fragment ///
   noobs nonote nonumber collabels(none)  replace



************************************
* Make Balance Table  based on education and employment level     *
************************************
use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear




la var smoker_dummy "Smoker"

la var smoker_num_cigs_day "Cigarettes smoked average per day"

la var alcohol_howoften7days "Alcohol how often last 7 days"

la var ethanol_amount "Ethanol Consumed (ml.)"

eststo clear
gen date_s = date
sort date_s
preserve
keep if inlist(edu,0,1)

by date_s: eststo: estpost summarize  smoker_num_cigs_day ethanol_amount, listwise
restore

esttab using "$tables\table.tex", cells(mean(fmt(%5.2f)) ) label nodepvar unstack   gaps fragment ///
   noobs nonote nonumber collabels(none)  replace

/*

esttab , cells(mean(fmt(%5.2f)) ) label nodepvar unstack   gaps fragment ///
   noobs nonote nonumber collabels(none)  replace
esttab ,cells(mean(fmt(%5.2f)) count(par fmt(%9.0g)) ) label nodepvar unstack refcat("Main effects:") fragment ///
  noobs nonote nonumber nomtitle collabels(none)    gaps   replace  
  esttab using "$tables\table.tex", cells(mean(fmt(%5.2f)) count(par fmt(%9.0g)) ) label nodepvar unstack   fragment ///
   noobs nonote nonumber collabels(none)  replace
  */
eststo clear

preserve
keep if inlist(edu,2)


by date_s: eststo: quietly estpost summarize smoker_num_cigs_day ethanol_amount , listwise
restore

 
esttab using "$tables\table.tex", append cells(mean(fmt(%5.2f))) label nodepvar unstack  gaps fragment ///
   noobs nonote nonumber nomtitle collabels(none)
   

eststo clear
preserve
keep if gender==1

by date_s: eststo: quietly estpost summarize smoker_num_cigs_day ethanol_amount , listwise

esttab , cells(mean(fmt(%5.2f)) ) label nodepvar unstack   gaps fragment ///
   noobs nonote nonumber collabels(none)  replace
restore

 
esttab using "$tables\table.tex", append cells(mean(fmt(%5.2f)))  label nodepvar unstack  gaps fragment ///
   noobs nonote nonumber nomtitle collabels(none)
     
 
eststo clear

preserve
keep if gender==0

by date_s: eststo: quietly estpost summarize  smoker_num_cigs_day ethanol_amount, listwise
restore

 
esttab using "$tables\table.tex", append cells(mean(fmt(%5.2f))) label nodepvar unstack  gaps fragment ///
   noobs nonote nonumber nomtitle collabels(none)
   

eststo clear
preserve
keep if occupation==0

by date_s: eststo: quietly estpost summarize smoker_num_cigs_day ethanol_amount, listwise
restore

 
esttab using "$tables\table.tex", append cells(mean(fmt(%5.2f)))  label nodepvar unstack  gaps fragment ///
   noobs nonote nonumber nomtitle collabels(none)
     

eststo clear
preserve
keep if occupation==3

by date_s: eststo: quietly estpost summarize smoker_num_cigs_day ethanol_amount, listwise
restore

 
esttab using "$tables\table.tex", append cells(mean(fmt(%5.2f)) ) label nodepvar unstack  gaps booktabs fragment ///
   noobs nonote nonumber nomtitle collabels(none)
     

eststo clear





use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear




la var smoker_dummy "Smoker"

la var smoker_num_cigs_day "Cigarettes smoked average per day"

la var alcohol_howoften7days "Alcohol how often last 7 days"

la var alldrugs_num_lastmonth "Drugs consumed last month"


eststo clear
sort date

preserve
keep if smoker_num_cigs_day>0

by date: eststo: estpost summarize  smoker_num_cigs_day alcohol_howoften7days alldrugs_num_lastmonth, listwise
restore

esttab using "$tables\table_onlyconsumers.tex", cells(mean(fmt(%5.2f)) count(par fmt(%9.0g)) ) label nodepvar unstack   fragment ///
   noobs nonote nonumber collabels(none)  replace
/*
esttab ,cells(mean(fmt(%5.2f)) count(par fmt(%9.0g)) ) label nodepvar unstack refcat("Main effects:") fragment ///
  noobs nonote nonumber nomtitle collabels(none)      replace  
  */
eststo clear






eststo clear
sort date

preserve
keep if alldrugs_num_lastmonth>0

by date: eststo: estpost summarize  smoker_num_cigs_day alcohol_howoften7days alldrugs_num_lastmonth, listwise
restore

esttab using "$tables\table_onlyconsumers.tex",  append  cells(mean(fmt(%5.2f)) count(par fmt(%9.0g)) ) label nodepvar unstack   fragment ///
   noobs nonote nonumber collabels(none)  
/*
esttab ,cells(mean(fmt(%5.2f)) count(par fmt(%9.0g)) ) label nodepvar unstack refcat("Main effects:") fragment ///
  noobs nonote nonumber nomtitle collabels(none)      replace  
  */
eststo clear





eststo clear
preserve
keep if alcohol_howoften7days>0

by date: eststo: quietly estpost summarize smoker_num_cigs_day alcohol_howoften7days alldrugs_num_lastmonth, listwise
restore

 
esttab using "$tables\table_onlyconsumers.tex", append cells(mean(fmt(%5.2f)) count(par fmt(%9.0g))) label nodepvar unstack fragment ///
   noobs nonote nonumber nomtitle collabels(none)

eststo clear





/*
