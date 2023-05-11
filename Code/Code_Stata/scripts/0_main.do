/* Applied Labor Economics - Project */
clear all 
set more off 

global input "C:\Users\Public\Documents\Darricau_Blanco\Data\input"
global intermediate "C:\Users\Public\Documents\Darricau_Blanco\Data\intermediate"
global final "C:\Users\Public\Documents\Darricau_Blanco\Data\final"
global code "C:\Users\Public\Documents\Darricau_Blanco\Code\Code_Stata\scripts"
global temp "C:\Users\Public\Documents\Darricau_Blanco\Code\Code_Stata\temp"
global out "C:\Users\Public\Documents\Darricau_Blanco\Output"

********************************************************************************
****		Cleaning, creating and describing the data	    	          ****
********************************************************************************

*** Get id of all individuals to keep for regression ***
do "$code\1_recup_id.do"

*** Create the final dataset for regression ***
do "$code\2_dataset_creation.do"

*** Descriptive statistics *** 
do "$code\3_desc_stats.do"