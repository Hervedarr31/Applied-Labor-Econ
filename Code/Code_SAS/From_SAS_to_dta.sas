/* File to extract the data from SASS to .dta format */
%let tempdir = C:\temp;
filename tempdir "&tempdir.";
data _null_;
	rc=fdelete('tempdir\*');
run;

/* dads_sup2002 full*/
proc contents data = '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\dads_sup2002';
run;

/* Select variables */
%let keepvars = IDFHDA AN NETNET AGE DEBREMU FINREMU SX SB SN A38 APE40 CONTRAT_TRAVAIL CS1 CS2 NBHEUR NETNETR SBR SNR DIP_TOT;

/* */
data temp_sup_2002_0;
set '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\dads_sup2002';
/**/
keep &keepvars;

run;

proc export
	data = temp_sup_2002_0
	outfile = 'C:\Users\Public\Documents\Darricau_Blanco\Data\intermediate\dads_sup2002_0.dta'
	dbms = dta
	replace;
run;


/* dads_sup2002 frac*/
proc contents data = '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\dads_sup2002';
run;

/* Select variables */
%let keepvars = IDFHDA AN NETNET AGE DEBREMU FINREMU SX SB SN;

/* */
data temp_sup_2002_1;
set '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\dads_sup2002';
/**/
keep &keepvars;

run;

proc export
	data = temp_sup_2002_1
	outfile = 'C:\Users\Public\Documents\Darricau_Blanco\Data\intermediate\dads_sup2002_1.dta'
	dbms = dta
	replace;
run;


proc contents data = '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\dads_sup2002';
run;

/* Select variables */
%let keepvars = IDFHDA AN DEBREMU A38 APE40 CONTRAT_TRAVAIL CS2 NBHEUR NETNETR SBR SNR DIP_TOT;

/* */
data temp_sup_2002_2;
set '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\dads_sup2002';
/**/
keep &keepvars;

run;

proc export
	data = temp_sup_2002_2
	outfile = 'C:\Users\Public\Documents\Darricau_Blanco\Data\intermediate\dads_sup2002_2.dta'
	dbms = dta
	replace;
run;

/*------------------------------------------------------------------------------------------------------*/


/* de */
proc contents data = '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\de';
run;

/* Select variables */
%let keepvars = IDFHDA DATSINS DATINS SITPAR SALMT SALUNIT RSQTATT NDEM CONTRAT TEMPS NENF NIVFOR SITMAT ;

/* */
data temp_de;
set '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\de';
/**/
keep &keepvars;

run;

proc export
	data = temp_de
	outfile = 'C:\Users\Public\Documents\Darricau_Blanco\Data\intermediate\de.dta'
	dbms = dta
	replace;
run;

/*------------------------------------------------------------------------------------------------------*/

/* PARCOURS */

proc contents data = '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\parcours';
run;
/* Select variables */
%let keepvars = IDFHDA NPAR NDEM NOUVPAR PREMPAR PARCOURS JOURDV JOURFV MOTCHGT;

/**/
data temp_parcours;
set '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\parcours';
/**/
keep &keepvars;
run;

proc export
	data = temp_parcours
	outfile = 'C:\Users\Public\Documents\Darricau_Blanco\Data\intermediate\parcours.dta'
	dbms = dta
	replace;
run;

/*------------------------------------------------------------------------------------------------------*/

/* E1ent */
proc contents data = '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\e1ent';
run;

/* Select variables */
%let keepvars = IDFHDA DATSENT DATENT OFSVCE; 

/* */
data temp_e1ent;
set '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\e1ent';
/**/
keep &keepvars;

run;


proc export
	data = temp_e1ent
	outfile = 'C:\Users\Public\Documents\Darricau_Blanco\Data\intermediate\e1ent.dta'
	dbms = dta
	replace;

run;


/*------------------------------------------------------------------------------------------------------*/

/* E1entpp */
proc contents data = '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\e1entpp';
run;

/* Select variables */
%let keepvars = IDFHDA DATSENT DATENT OFSVCE; 

/* */
data temp_e1entpp;
set '\\casd.fr\casdfs\Projets\ENSAE04\Data\FH-DADS_FH-DADS_2012\e1entpp';
/**/
keep &keepvars;

run;


proc export
	data = temp_e1entpp
	outfile = 'C:\Users\Public\Documents\Darricau_Blanco\Data\intermediate\e1entpp.dta'
	dbms = dta
	replace;

run;
