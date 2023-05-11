/* Applied Labor Economics */
clear all 
set more off 

global input "C:\Users\Public\Documents\Darricau_Blanco\Data\input"
global intermediate "C:\Users\Public\Documents\Darricau_Blanco\Data\intermediate"
global final "C:\Users\Public\Documents\Darricau_Blanco\Data\final"
global code "C:\Users\Public\Documents\Darricau_Blanco\Code\Code_Stata\scripts"
global temp "C:\Users\Public\Documents\Darricau_Blanco\Code\Code_Stata\temp"
global out "C:\Users\Public\Documents\Darricau_Blanco\Output"

********************************************************************************
****		Création, nettoyage, fusion des bases 							****
********************************************************************************

*** Récupération des individus d'intérêt ***
do "$code\1_recup_individus.do"

*** Création de la base pour les regressions ***
do "$code\2_creation_base.do"

*** Statistiques descriptives *** 
do "$code\3_stats_desc.do"