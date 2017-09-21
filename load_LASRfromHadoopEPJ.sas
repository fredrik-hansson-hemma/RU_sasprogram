/*********************************************
* Macro: Load_LASRfromHadoopEPJ
* Laddar tabeller från HadoopEPJ in i EPJ LASR server.
* Skriver ut de tabeller som ska laddas till Hadoop i tabell
* LOG
* VATABLE: Tabell som ska laddas in i LASR-server. 
* Om blankt laddas alla tabeller som finns i Hadoop.
*********************************************/

%macro load_lasrfromhadoopEPJ(VATABLE=);
%put ENTER: load_lasrfromhadoopEPJ;
%if "VATABLE" = "" %then %do;
  %put Alla tabeller från Hadoop kommer att laddas in i LASR-minnet.;
%end;
%if "VATABLE" ne "" %then %do;
  %put Tabell &vatable från Hadoop kommer att laddas in i LASR-minnet.;
%end;

%let env = %get_env();

%LET VDB_GRIDHOST=&env.-apx-04.lul.se;
%LET VDB_GRIDINSTALLLOC=/opt/TKGrid;
options set=GRIDHOST="&env-apx-04.lul.se";
options set=GRIDINSTALLLOC="/opt/TKGrid";
options validvarname=any validmemname=extend;

LIBNAME EPJ SASHDAT  PATH="/epj"  SERVER="bst-apx-04.lul.se"  INSTALL="/opt/TKGrid" ;
LIBNAME VALIBLA SASIOLA  TAG=epj  PORT=10012 SIGNER="https://bst-apx-04.lul.se:8343/SASLASRAuthorization"  HOST="bst-apx-04.lul.se" ;

* Hämtar alla tabeller som finns i Hadoop.;
proc sql noprint;
create table hadooptables as
select memname from dictionary.tables
where upcase(libname) = "EPJ"
%if "&vatable" ne "" %then %do;
and upcase(memname) = "&vatable"
%end;
;
quit;

* Hämtar alla tabeller som finns i LASR servern.;
proc sql noprint;
create table lasrtables as
select memname from dictionary.tables
where upcase(libname) = "VALIBLA"
%if "&vatable" ne "" %then %do;
and upcase(memname) = "&vatable"
%end;
;
quit;

* Sparar de tabeller som finns i Hadoop och som inte finns i LASR servern.;
proc sql noprint;

create table loadtablesfromhadoop as
select hadoop.memname
from hadooptables as hadoop
where hadoop.memname not in (select memname from lasrtables);
quit;

%let dsid = %sysfunc(open(loadtablesfromhadoop));
%do %while ((%sysfunc(fetch(&dsid))) = 0);

%let loadtable=%upcase(%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,memname)))));
%put LOADTABLE= &loadtable;

proc lasr port=10012
    data=EPJ.&loadtable
    signer="https://bst-apx-04.lul.se:8343/SASLASRAuthorization"
    add noclass;
    performance host="bst-apx-04.lul.se";
run;

%end;
%let dsid = %sysfunc(close(&dsid));
%put EXIT: load_lasrfromhadoop;

%mend;

* Anrop;
%load_lasrfromhadoopEPJ(VATABLE=);