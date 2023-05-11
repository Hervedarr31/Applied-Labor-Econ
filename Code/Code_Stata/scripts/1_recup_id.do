********************************************************************************
*****				1 Récupération des individus d'intérêt                 *****
********************************************************************************

clear all
set more off

/* 0. Individus effectivemnt passés par PE */

/* On ne veut que des individus ayant effectué au moins un rdv à PE */

use "$intermediate\e1ent.dta", clear
rename *, lower
bys idfhda: gen n_row = _n
keep if n_row == 1
drop n_row

save "$intermediate\e1ent.dta", replace

use "$intermediate\e1entpp.dta", clear
rename *, lower

merge m:1 idfhda using "$intermediate\e1ent.dta"
 
keep idfhda
duplicates drop

save "$intermediate\idfhda_ent.dta", replace

/*1. Nettoyage base parcours   */

use "$intermediate\parcours.dta", clear

rename *, lower

/*On ne veut conserver que les individus ayant réalisé un seul parcours pour
pouvoir considérer le passage au bureau d'emploi comme un traitement définitif. 
On crée une base dans laquelle on associe à chaque individu la date de son
premier parcours et la date de son dernier parcours. On considèrera par la suite
que, si l'on observe un emploi entre ces dates, alors l'individu a effectué
plusieurs passages au bureau d'emploi et on ne le conservera pas dans la base. */
egen date_debut = min(jourdv), by(idfhda)
egen date_fin = max(jourfv), by(idfhda)
bysort idfhda : gen n_row = _n
keep if n_row == 1
keep idfhda date_debut date_fin

save "$temp\parcours_restrict.dta", replace


/*2. Nettoyage base de   */
use "$intermediate/de.dta", clear

rename *, lower

/*On se restreint aux individus inscrits au bureau d'emploi après le 1er janvier 
2006 pour avoir une homogénéité dans les parcours proposés.*/
drop if datins > td(01jan2006)

keep idfhda
bysort idfhda: gen rank = _n
keep if rank == 1
drop rank
save "$temp/de_restrict_id", replace

/*3. Nettoyage dads_sup2002_0 */
use "$intermediate\dads_sup2002_0.dta", clear

rename *, lower

/*On transforme les dates de début et fin de rémunération pour qu'elles ne 
soient plus relatives à une année mais absolues*/
tostring an, gen(an_str)
gen deb_an = "01jan"+an_str
gen deb_remu_an = date(deb_an,"DMY")

if finremu == 360 {
	replace finremu = 365
}

gen deb_remu = deb_remu_an + debremu - 1
gen fin_remu = deb_remu_an + finremu - 1

keep idfhda an deb_remu fin_remu 
save "$temp\dads_sup2002_restrict", replace

/* Merge avec parcours */
use "$temp\dads_sup2002_restrict", clear

merge m:1 idfhda using "$temp\de_restrict_id"

keep if _merge == 1
drop _merge

merge m:1 idfhda using "$temp\parcours_restrict"  

 /*
 Result                      Number of obs
    -----------------------------------------
    Not matched                    21,237,465
        from master                21,005,226  (_merge==1)
        from using                    232,239  (_merge==2)

    Matched                        11,547,203  (_merge==3)
    ----------------------------------------- */

keep if _merge == 3

/*On génère la variable qui indique si un emploi a eu lieu entre la date du
premier parcours et la date du dernier parcours*/
gen intermittence = deb_remu >= date_debut & deb_remu <= date_fin
bysort idfhda : egen intermittence_1 = max(intermittence) /*indicatrice : 
l'individu a eu plusieurs périodes d'inactivité*/

table intermittence_1 
drop if intermittence_1 == 1  

keep idfhda

/* On ne conserve que les individus passés au moins une fois par PE en
utilisant la liste d'identifiants de la partie 0*/

merge m:1 idfhda using "$intermediate\idfhda_ent.dta"

bysort idfhda: gen rank = _n
keep if rank == 1 & _merge == 3
drop rank _merge

save "$temp\id_to_keep", replace