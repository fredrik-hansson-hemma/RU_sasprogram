/** QUERY **/ 
/*********************************************
* Macro: Load_LASRfromHadoop_bst
* Laddar tabeller fr�n Hadoop in i LASR servern.
* Skriver ut de tabeller som ska laddas till Hadoop i tabell
* LOG
* VATABLE: Tabell som ska laddas in i LASR-server. 
* Om blankt laddas alla tabeller som finns i Hadoop.
*********************************************/

%macro load_lasrfromhadoop_bst(VATABLE=, TAG=, PATH=, PORT=, SIGNER=);
%put ENTER: load_lasrfromhadoop_bst;
%if "VATABLE" = "" %then %do;
  %put Alla tabeller fr�n Hadoop kommer att laddas in i LASR-minnet.;
%end;
%if "VATABLE" ne "" %then %do;
  %put Tabell &vatable fr�n Hadoop kommer att laddas in i LASR-minnet.;
%end;

%let env = %get_env();

%LET VDB_GRIDHOST=&env.-apx-04.lul.se;
%LET VDB_GRIDINSTALLLOC=/opt/TKGrid;
options set=GRIDHOST="&env-apx-04.lul.se";
options set=GRIDINSTALLLOC="/opt/TKGrid";
options validvarname=any validmemname=extend;

proc printto print='/tmp/procoutput.lst';

LIBNAME LASR SASIOLA  TAG=&tag  PORT=&port HOST="&env-apx-04.lul.se"  SIGNER="&signer" ;
LIBNAME HADOOP SASHDAT  PATH="&path"  SERVER="&env-apx-04.lul.se"  INSTALL="/opt/TKGrid" ;

* H�mtar alla tabeller som finns i Hadoop.;
proc sql noprint;
create table hadooptables as
select memname from dictionary.tables
where upcase(libname) = "HADOOP"
%if "&vatable" ne "" %then %do;
and upcase(memname) = "&vatable"
%end;
;
quit;

* H�mtar alla tabeller som finns i LASR servern.;
proc sql noprint;
create table lasrtables as
select memname from dictionary.tables
where upcase(libname) = "LASR"
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

proc lasr port=&port.
    data=HADOOP.&loadtable
    signer="&signer"
    add noclass;
    performance host="bst-apx-04.lul.se";
run;

%end;
%let dsid = %sysfunc(close(&dsid));




LIBNAME LASR clear;
LIBNAME HADOOP clear ;

%put EXIT: load_lasrfromhadoop_bst;

%mend;


* Anrop;
%load_lasrfromhadoop_bst(VATABLE=, TAG=hps, PATH=/hps, PORT=10010, SIGNER=https://bst-apx-04.lul.se:8343/SASLASRAuthorization); 
%load_lasrfromhadoop_bst(VATABLE=, TAG=epj, PATH=/epj, PORT=10012, SIGNER=https://bst-apx-04.lul.se:8343/SASLASRAuthorization);
