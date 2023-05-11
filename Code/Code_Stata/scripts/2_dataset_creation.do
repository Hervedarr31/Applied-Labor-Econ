********************************************************************************
***                                                                          ***
***                        Création de la base                               ***
***                                                                          ***
********************************************************************************
clear all
set more off


********************************************************************************
***** 					Merge des BDD et formattage général 			   *****
********************************************************************************
use "$intermediate\dads_sup2002_0.dta", clear

rename *, lower
merge m:1 idfhda using "$temp\id_to_keep"

keep if _merge == 3
drop _merge

merge m:1 idfhda using "$temp\parcours_restrict"

keep if _merge == 3
drop _merge
save "$temp\merge_dads_parcours_restrict", replace

use "$temp\merge_dads_parcours_restrict", clear

/* On met au format numérique les variables de sexe, de cs et de diplome*/
drop if cs2 == "ZZ" | cs1 == "Z"
destring sx cs2 cs1 dip_tot, replace

/* On complète les cs1 manquantes si on l'information pour cs2*/
replace cs1 = floor(cs2/10) if cs2 != . & cs1 == .

/* On vérifie les missing values pour le sexe et on remplace quand on a
l'information à une autre ligne */

*ta sx, m 
bys idfhda: egen max_sx = max(sx)
replace sx = max_sx if sx == .
* ta sx, m
drop max_sx

*ta age,m 
/* On remplace les valeurs d'âge en calculant l'écart entre l'année et l'année
de naissance, calculée grâce à une autre ligne */
gen birth = an - age
bys idfhda: egen birth_max = max(birth) 
replace age = an - birth_max if age == .
drop birth birth_max 
/*On remarque qu'un individu a 9 ans dans la base --> On retire les âges
suspects */
drop if age < 16

/* On met au format numérique l'idfhda */
split idfhda, parse("F") gen(idfhda_)
gen idfhda_3 = "9" + idfhda_2
destring idfhda_3, replace
drop idfhda idfhda_1 idfhda_2
rename idfhda_3 idfhda

/* Dates au bon format*/
tostring an, gen(an_str)
gen deb_an = "01jan"+an_str
gen deb_remu_an = date(deb_an,"DMY")

if finremu == 360 {
	replace finremu = 365
}
gen deb_remu = deb_remu_an + debremu - 1
gen fin_remu = deb_remu_an + finremu - 1 // les dates de rémunération ne sont plus relatives à une année mais absolues
drop deb_remu_an deb_an an_str

/* On retire les individus qui ont conservé un emploi pendant leur parcours*/
gen rel_parcours = 0
replace rel_parcours = 1 if fin_remu <= date_debut /* l'emploi a fini avant le parcours */
replace rel_parcours = 2 if deb_remu >= date_fin /* l'emploi a commencé après la fin du parcours */

bys idfhda: egen min_rel_parcours = min(rel_parcours)
drop if min_rel_parcours == 0

/* On ne conserve que les individus qui ont eu un emploi avant et après leur parcours */ 
bys idfhda: egen max_rel_parcours = max(rel_parcours)
gen work_unemp_work = min_rel_parcours == 1 & max_rel_parcours == 2
drop if work_unemp_work == 0

drop min_rel_parcours max_rel_parcours


/* On crée une variable catégorielle prenant 8 valeurs différentes pour la durée
du parcours */
gen duree_parcours = date_fin - date_debut
gen cat_duree_parcours = .
replace cat_duree_parcours = 0 if duree_parcours <= 31 & cat_duree_parcours == .
replace cat_duree_parcours = 1 if duree_parcours <= 95 & cat_duree_parcours == .
replace cat_duree_parcours = 2 if duree_parcours <= 190 & cat_duree_parcours == .
replace cat_duree_parcours = 3 if duree_parcours <= 280 & cat_duree_parcours == .
replace cat_duree_parcours = 4 if duree_parcours <= 365 & cat_duree_parcours == .
replace cat_duree_parcours = 5 if duree_parcours <= 555 & cat_duree_parcours == .
replace cat_duree_parcours = 6 if duree_parcours <= 1095 & cat_duree_parcours == .
replace cat_duree_parcours = 7 if duree_parcours > 1095 & cat_duree_parcours == .

label define duree_label 0 "Less than 1 month" 1 "Less than 3 month" 2 "Less than 6 month" 3 "Less than 9 month" 4 "Less than 12 month" 5 "Less than 18 month" 6 "Less than 3 years" 7 "More than 3 years"
label values cat_duree_parcours duree_label

/* On crée une catégorie d'âge */
gen cat_age = floor((age-16)/5)
replace cat_age = 8 if age > 55

********************************************************************************
***** 					Trimestres (Salaire horaire)					   *****
********************************************************************************

/* Salaire horaire moyen sur la période */
gen missing_netnetr = .
replace missing_netnetr = 1 if netnetr == . | netnetr == 0
bys idfhda an: egen to_drop = sum(missing_netnetr)
keep if to_drop == 0 /*On retire les lignes pour lesquelles il manque le salaire*/

gen missing_nbheur = .
replace missing_nbheur = 1 if nbheur == . | nbheur == 0
keep if missing_nbheur == . /*On retire les lignes pour lesquelles il manque le nombre d'heures*/

drop missing_netnetr to_drop missing_nbheur

 /*On ne différenceie plus les périodes précédant le chômage et le chômage*/
replace rel_parcours = 0 if rel_parcours == 1
replace rel_parcours = 1 if rel_parcours == 2


bys idfhda an rel_parcours: egen tot_netnetr = sum(netnetr)
bys idfhda an rel_parcours: egen tot_nbheur = sum(nbheur)

/*On calcule les salaires horaires moyens éventuellement séparément si un
parcours est intercalé entre deux périodes d'activité au cours d'une même
année*/ 
gen netnetr_heur = tot_netnetr / tot_nbheur

save "$intermediate/data_clean", replace

/* Même chose avec des trimestres plutôt que des mois pour avoir des groupes
plus gros*/

use "$intermediate/data_clean", clear

/* Salaire horaire trimestriel */
forvalues trim = 1/4 {
	gen netnetr_heur_`trim' = netnetr_heur
}

*gen deb_parcours_year = year(date_debut) == an
gen fin_parcours_year = year(date_fin) == an

*gen deb_parcours_trim = floor(month(date_debut)/4) + 1
gen fin_parcours_trim = floor(month(date_fin)/4) + 1

/*Si au cours d'une année il y a une période d'activité, suivie d'une période
d'inactivité, suivie d'une période d'activité, on ne conserve que les salaires
horaires trimestriels correspondant à la période concernée (et on considère que le
salaire horaire trimestriels est nul lors de périodes d'inactivité)*/
forvalues trim = 1/4 {
	replace netnetr_heur_`trim' = 0 if fin_parcours_year ==1 & `trim' > fin_parcours_trim & rel_parcours == 0
	replace netnetr_heur_`trim' = 0 if fin_parcours_year ==1 & `trim' <= fin_parcours_trim & rel_parcours == 1
}

/*On agrège les résultats pour avoir l'ensemble des salaires horaires trimestriels
à chaque ligne*/ 
forvalues trim = 1/4 {
	bys idfhda an: egen wage_hour_`trim' = max(netnetr_heur_`trim')
}

save "$intermediate\dads_parcours_int_t", replace 

/* On considère que l'emploi qui a le plus grand nombre d'heures sur une période
est le principal et on ne conserve qu'une ligne par année (uniquement celle de
l'emploi principal)*/

use "$intermediate\dads_parcours_int_t", clear

bys idfhda an: egen max_nbheur = max(nbheur)
bys idfhda an nbheur: gen n_row = _n
keep if max_nbheur == nbheur & n_row == 1

/* On conserve les variables d'intérêt */
keep idfhda an age sx cs1 cs2 cat_duree_parcours cat_age wage_hour_* date_fin fin_parcours_trim

/* On conserve les individus pour lesquels on peut compléter les salaires 
manquants en utilisant les salaires précédents/suivants */

gen no_wage_before =  wage_hour_1 == 0 & an[_n-1] != an - 1
gen no_wage_after = wage_hour_4 == 0 & an[_n+1] != an + 1
bys idfhda: egen nb_before_pb = sum(no_wage_before)
bys idfhda: egen nb_after_pb = sum(no_wage_after)
gen nb_pb = nb_before_pb + nb_after_pb

drop if nb_pb > 0 /* on retire les individus pour lesquels on observe un saut d'années entre deux lignes*/
drop no_wage_after no_wage_before nb_after_pb nb_before_pb nb_pb

/* On complète les salaires manquants avec le salaire de l'année précédente 
ou suivante*/

reshape long wage_hour_, i(idfhda an age sx cs1 cs2 cat_duree_parcours cat_age date_fin fin_parcours_trim) j(trim)

gsort idfhda an
*gen zero = wage_hour_ == 0
replace wage_hour_ = wage_hour_[_n-1] if wage_hour == 0 & trim <= fin_parcours_trim
replace wage_hour_ = wage_hour_[_n+1] if wage_hour == 0 & trim > fin_parcours_trim

/* On retire les salaires qui semblent anormalement faibles ou élevés*/
gsort wage_hour_
gen pct = 100 * (_n / _N)
drop if pct <= 5 | pct >= 95
drop pct

********************************************************************************
***** 		   Format DID (Période, Traitement, Groupe, Dummies) 	   	   *****
********************************************************************************

/* On génère deux des trois variables nécessaires : la période et une indicatrice 
de traitement*/

gen period = (an - 2002) * 4 + trim
gen treated = an * 100 + trim > year(date_fin) * 100 + fin_parcours_trim

/*On génère la troisième variable nécessaire : le groupe. Un groupe est défini 
par deux choses : la date de la première période du traitement  */
preserve
tempfile temp 
bys idfhda treated: gen n_row = _n
keep if n_row == 1 & treated == 1 /*on ne conserve que la ligne de la première
période du traitement*/
gen group = period
keep idfhda group
save `temp', replace
restore
merge m:1 idfhda using `temp'

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         7,368
        from master                     7,368  (_merge==1)
        from using                          0  (_merge==2)

    Matched                         1,519,524  (_merge==3)
    -------------------------------------
	
 Les 7,368 observations non matchées correspondent à 186 individus pour lesquels*
 on n'a que des données antérieures au traitement*/

keep if _merge == 3
drop _merge date_fin fin_parcours_trim

/* La base finale contient 1,519,524 observations correspondant à 22,598 individus,
et 14 variables */

/* On sélectionnes les catégories d'inétêt : celles qui contiennent suffisamment
d'individus différents pour une comparaison*/
ta cs1
keep if cs1 > 2 & cs1 < 7

/*On transforme les variables catégorielles en dummies*/
ta cs1, gen(cs1_)
ta cat_age, gen(cat_age_)

save "$final\database_did_trim_dummies", replace
export delimited "$final\database_did_trim_dummies", replace

