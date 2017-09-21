/*****************************************************************************
* Macro: StatusDatalager                     
* Kontrollerar om datalagret �r klart f�r l�sning. 
*
* Av: Mattias Moliis, Infotrek
* Datum: 2014-02-26
* Parametrar: 
* STATUSTABLE: Loggtabell f�r datalagret.
* VATABLE: VA tabell som ska laddas.
*
* �ndringar:
******************************************************************************/


%macro statusDatalager(statustable=, vatable=);
%put Enter statusDatalager Statustable: &statustable Antal l�sningar: &nroftries;

%let laddflagga = 0; * LADDFLAGGA: Anger om datalagret �r klart f�r att l�sa;

%let dw = %get_dwlib(); 
%put MILJ� F�R DATALAGRET: &dw;

%if not %sysfunc(exist(&dw..&statustable)) %then %do;
%put &dw..&statustable finns inte eller �r inte �tkomlig. Programmet avbryts.;
%abort abend;
%end;

%do i = 1 %to &nroftries;
%put ENTER DO_LOOP;

%let dsid = %sysfunc(open(&dw..&statustable));
%let rc=%sysfunc(fetchobs(&dsid,1));
%let loadstatus=%sysfunc(getvarn(&dsid,%sysfunc(varnum(&dsid,loadstatus))));
%put LOADSTATUS=&loadstatus;
%let dsid = %sysfunc(close(&dsid));
* Datalagret �r inte klart att l�sa �nnu.;

%if &loadstatus = 0 %then %do;
 %let i = %eval(&i + 1);
 %put I = &i;
 %let rc = %sysfunc(sleep(40, 1));
%end;

%if &loadstatus = 1 %then %goto exit;
%end; * end: do-loop; 

* Max antal kontroller av datalagret har utf�rts.;
%if &i = &nroftries %then %do;
%put &nroftries kontroller av flagga f�r datalagret har utf�rts. Loadstatus �r &loadstatus.. Programmet avbryts.;
%abort abend;
%end;
%EXIT:
%put Datalagret �r klart att l�sa. Loadstatus �r &loadstatus..;
%mend;

* Exempel p� anrop;
%*statusDatalager(statustable=VW_SYSTEMLOAD, nroftries=3);


