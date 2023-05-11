/* Descriptive statistics on the final regression dataset*/
clear all
set more off

use "$final\database_did_trim_dummies", clear

label define sx_label 0 "Women" 1 "Men" 
label values sx sx_label

label define age_label  0 "16-20 years old" 1 "21-25 years old" 2 "26-30 years old" 3 "31-35 years old" 4 "36-40 years old" 5 "41-45 years old"  6 "46-50" 7 "51-55" 8 "56+ years old"
label values cat_age age_label

label var cat_duree_parcours "Pôle Emploi program duration"
label var sx "Gender"

label var cs1 "INSEE CS1"

duplicates drop idfhda, force

* Different program duration categories and gender

estpost ta cat_duree_parcours sx
eststo table_1
esttab table_1 using "$out/1_Tables/twoway_cat_sex.tex", replace ///
cells("b(fmt(0))") unstack noobs  label collabels(none) /// 
title("Different duration categories and gender \label{twoway_cat_sex}")

* Different age category and gender
estpost ta cat_age sx
eststo table_2
esttab table_2 using "$out/1_Tables/twoway_age_sex.tex", replace ///
cells("b(fmt(0))")  unstack noobs  label collabels(none) /// 
title("Age categories and gender \label{twoway_age_sex}")


* Duration, gender and socio-professional category 
* Female
preserve
	keep if sx == 0
	eststo clear
	estpost ta cat_duree_parcours cs1
	eststo table_3
	esttab table_3 using "$out/1_Tables/threeway_cat_cs1_F.tex", replace ///
	cells("b(fmt(0))") unstack noobs  label collabels(none) /// 
	title("Duration, gender and socio-professional category \label{threeway_cat_cs1_F}")
restore

*Male
preserve
	keep if sx == 1
	eststo clear
	estpost ta cat_duree_parcours cs1
	eststo table_4
	esttab table_4 using "$out/1_Tables/threeway_cat_cs1_M.tex", replace ///
	cells("b(fmt(0))") mtitles("INSEE CS1") unstack noobs  label collabels(none) /// 
	title("Duration, gender and socio-professional category \label{threeway_cat_cs1_M}")
restore

* Wage hour and gender
estpost tabstat wage_hour, by(sx) stat(mean)
eststo table_5
esttab table_5 using "$out/1_Tables/twoway_hwage_sex.tex", replace ///
cells("mean(fmt(2))") label collabels(none) /// 
title("Hourly wage and gender \label{twoway_hwage_sex}")


ta group cs1, m
ta group cat_age, m
