proc contents data= VALIBLA._all_ noprint out= VALASR (keep=libname memname); run;

proc sort data=VALASR nodupkey; by libname memname; run;

proc contents data= EPJLA._all_ noprint out= EPJLASR (keep=libname memname); run;

proc sort data=EPJLASR nodupkey; by libname memname; run;

proc contents data= FTVLA._all_ noprint out= FTVLASR (keep=libname memname); run;

proc sort data=FTVLASR nodupkey; by libname memname; run;

proc contents data= LRCLA._all_ noprint out= LRCLASR (keep=libname memname); run;

proc sort data=LRCLASR nodupkey; by libname memname; run;

proc contents data= LASRLIB._all_ noprint out= PUBLASR (keep=libname memname); run;

proc sort data=PUBLASR nodupkey; by libname memname; run;

data alla_tabeller;
set valasr epjlasr ftvlasr lrclasr publasr;
run;