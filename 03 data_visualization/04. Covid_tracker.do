



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
		
global covidtracker	"$root\oxford index\covid-policy-tracker"



***********************************
* Load Raw Data
************************************

import delimited using "$covidtracker\data.csv", ///
   clear 


*keep countryname  date stringencyindex confirmedcases
keep if countryname=="Netherlands"
gen date2 = date(date, "YMD")

tsset date2, daily	
format date2 %td
generate newcases = D.confirmedcases

save  "$covidtracker\clean_covid_tracker",replace





***********************************
* Plot Covid Tracker Data
************************************

use  "$covidtracker\clean_covid_tracker",clear

*gen confirmedcases_million=log(confirmedcases/17)
gen confirmedcases_million=newcases/1000

set scheme plotplainblind
la var confirmedcases_million "Daily new cases"
la var stringencyindex "Stringency Index"
gen date3 = date(date, "YMD")
keep if inrange(date3,21915,22614)
format date2 %td





twoway  ///
		(line	stringencyindex date3, c(l) yaxis(1) ) ///
		(line	confirmedcases_million date3, c(l) yaxis(2)  lstyle(color(ltblue)) ), ///
		xtitle("",size(small)) ytitle("Stringency Index",size(small) axis(1))    xlabel(21854 22020 22234 22599,format("%tdMon_YY")) ytitle("Daily new cases (thousands)",size(small) axis(2)) ///
	  legend(position(1) bplacement(seast))  ylabel(0(20)100,axis(1) nogrid)  tline(15apr2020) tline(15nov2020)  tline(15nov2021)  tline(15nov2021) tline(01nov2019)


graph export "$figures/stringency_index.png", replace


***********************************
* Additional Graphs
************************************

/*
use  "$covidtracker\clean_covid_tracker",clear

*gen confirmedcases_million=log(confirmedcases/17)
gen confirmedcases_million=newcases/1000

set scheme plotplainblind
la var confirmedcases_million "Daily new cases"
la var stringencyindex "Stringency Index"
gen date3 = date(date, "YMD")
keep if inrange(date3,21915,22614)
format date2 %td





twoway  ///
		(line	c6_stayathomerequirements date3, c(l) yaxis(1) ) ///
		(line	c4_restrictionsongatherings date3, c(l) yaxis(2)  lstyle(color(ltblue)) lpattern(solid) ), ///
		xtitle("",size(small)) ytitle("Stringency Index",size(small) axis(1))    xlabel(21854 22020 22234 22599,format("%tdMon_YY")) ytitle("Daily new cases (thousands)",size(small) axis(2)) ///
	  legend(position(1) bplacement(seast))  ylabel(,axis(1) nogrid)  tline(15apr2020) tline(15nov2020)  tline(15nov2021)  tline(15nov2021) tline(01nov2019)


graph export "$figures/stringency_index.png", replace

*/
ax
