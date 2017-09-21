/*********************************************
* Macro: Load_LASRfromHadoop
* Laddar tabeller från Hadoop in i LASR servern.
* Skriver ut de tabeller som ska laddas till Hadoop i tabell
* LOG
* VATABLE: Tabell som ska laddas in i LASR-server. 
* Om blankt laddas alla tabeller som finns i Hadoop.
*********************************************/

%macro load_lasrfromhadoop(VATABLE=);
%put ENTER: load_lasrfromhadoop;
%if "VATABLE" = "" %then %do;
  %put Alla tabeller från Hadoop kommer att laddas in i LASR-minnet.;
%end;
%if "VATABLE" ne "" %then %do;
  %put Tabell &vatable från Hadoop kommer att laddas in i LASR-minnet.;
%end;

%let env = %get_env();

%LET VDB_GRIDHOST=rapport.lul.se;
%LET VDB_GRIDINSTALLLOC=/opt/TKGrid;
options set=GRIDHOST="rapport.lul.se";
options set=GRIDINSTALLLOC="/opt/TKGrid";
options validvarname=any validmemname=extend;

/*
LIBNAME VALIBLA SASIOLA  TAG=hps  PORT=10010 HOST="&env-apx-04.lul.se"  SIGNER="http://&env-apx-04.lul.se:7980/SASLASRAuthorization" ;
LIBNAME HPS SASHDAT  PATH="/hps"  SERVER="&env-apx-04.lul.se"  INSTALL="/opt/TKGrid" ;
*/

LIBNAME VAPUBLIC BASE "/opt/sas/config/Lev1/AppData/SASVisualAnalytics/VisualAnalyticsAdministrator/PublicDataProvider";
LIBNAME LASRLIB SASIOLA  TAG=VAPUBLIC  PORT=10031 HOST="rapport.lul.se"  SIGNER="https://rapport.lul.se:443/SASLASRAuthorization" ;

* Hämtar alla tabeller som finns i Public Data Provider.;
proc sql noprint;
create table pdptables as
select memname from dictionary.tables
where upcase(libname) = "VAPUBLIC"
/*%if "&vatable" ne "" %then %do;
and upcase(memname) = "&vatable"
%end;*/
;
quit;


%let dsid = %sysfunc(open(pdptables));
%do %while ((%sysfunc(fetch(&dsid))) = 0);

%let loadtable=%upcase(%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,memname)))));
%put LOADTABLE= &loadtable;

filename apa "/tmp/tmp.txt" ;
%let oo= %str(data=VAPUBLIC.%'&loadtable%'n);
data _null_;
file apa mod;
put 'proc lasr port=10031';
put "&oo";
put     'signer="https://rapport.lul.se:443/SASLASRAuthorization"';
put     'add noclass;';
put 	  'performance host="rapport.lul.se";';
put  'run;';

%end;
%let dsid = %sysfunc(close(&dsid));
%put EXIT: load_lasrfromhadoop;

%mend;

* Anrop;
%load_lasrfromhadoop(VATABLE=);
