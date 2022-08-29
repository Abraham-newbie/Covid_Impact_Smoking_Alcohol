



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







***********************************
* Making Unconditional Means Plots (Smoking)
************************************


use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear


keep if date!=tm(2018m11)

set scheme s2color

regress smoker_num_cigs_day i.date  i.gender
margins date,over(gender)

marginsplot,ytitle("Cigarettes smoked per day") ylabel(0(2)10) xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(seast))  ///
     scale(*.7)  graphregion(color(white) lwidth(large)) yscale(titlegap(*10)) 
graph export "$figures/fig1_cig_smoked_sex.png", replace




***********************************
* Making Unconditional Means Plots (Alcohol)
************************************





use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear


keep if date!=tm(2018m11)

set scheme s2color

regress ethanol_amount i.date  i.gender
margins date,over(gender)

marginsplot,ytitle("Ethanol Consumed (ml.)")  xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(seast))  ///
     scale(*.7)  graphregion(color(white) lwidth(large)) yscale(titlegap(*10)) 

graph export "$figures/fig1_alcohol_consumed_sex.png", replace





graph combine "$figures/fig1_cig_smoked_sex.png" "$figures/fig1_alcohol_consumed_sex.png"





***********************************
* Making Unconditional Means Plots (Alcohol)
************************************




use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear


gen age_range = ""

replace age_range = "40+" if age>40
replace age_range = "25-40" if age<=40 & age>25
replace age_range = "18-25" if age<=25 & age>=18
encode age_range ,gen(age_range_dummy)



keep if date!=tm(2018m11)

set scheme s2color

regress smoker_num_cigs_day i.date  i.age_range_dummy
margins date,over(age_range_dummy)

marginsplot,ytitle("Ethanol Consumed (ml.)",size(small)) ylabel(0(1)5) xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(seast))  ///
     scale(*.7)  graphregion(fcolor(white))  yscale(titlegap(*10))

graph export "$figures/fig2_cig_smoked_age.png", replace



***********************************
* Making Unconditional Means Plots (Alcohol)
************************************




use "$clean_data\income_survey\COVID_LAB_HEALTH_COMBINE_BG.dta",clear


gen age_range = ""

replace age_range = "40+" if age>40
replace age_range = "25-40" if age<=40 & age>25
replace age_range = "18-25" if age<=25 & age>=18
encode age_range ,gen(age_range_dummy)



keep if date!=tm(2018m11)

set scheme s2color

regress ethanol_amount  i.date  i.age_range_dummy
margins date,over(age_range_dummy)

marginsplot,ytitle("Ethanol Consumed (ml.)",size(small)) xla(, format(%tmm-Y)) xtitle("",size(small)) title("",size(small)) name(fig1,replace) legend( position(0) bplacement(seast))  ///
     scale(*.7)  graphregion(fcolor(white))  yscale(titlegap(*10))

graph export "$figures/fig2_alcohol_consumed_age.png", replace




  
