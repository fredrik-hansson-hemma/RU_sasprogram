/*****************************************************************************
* Macro: StatusDatalager                     
* Kontrollerar om datalagret är klart för läsning. 
*
* Av: Mattias Moliis, Infotrek
* Datum: 2014-02-26
* Parametrar: 
* STATUSTABLE: Loggtabell för datalagret.
* VATABLE: VA tabell som ska laddas.
*
* Ändringar:
******************************************************************************/


%macro statusDatalager(statustable=, vatable=);
%put Enter statusDatalager Statustable: &statustable Antal läsningar: &nroftries;

%let laddflagga = 0; * LADDFLAGGA: Anger om datalagret är klart för att läsa;

%let dw = %get_dwlib(); 
%put MILJÖ FÖR DATALAGRET: &dw;

%if not %sysfunc(exist(&dw..&statustable)) %then %do;
%put &dw..&statustable finns inte eller är inte åtkomlig. Programmet avbryts.;
%abort abend;
%end;

%do i = 1 %to &nroftries;
%put ENTER DO_LOOP;

%let dsid = %sysfunc(open(&dw..&statustable));
%let rc=%sysfunc(fetchobs(&dsid,1));
%let loadstatus=%sysfunc(getvarn(&dsid,%sysfunc(varnum(&dsid,loadstatus))));
%put LOADSTATUS=&loadstatus;
%let dsid = %sysfunc(close(&dsid));
* Datalagret är inte klart att läsa ännu.;

%if &loadstatus = 0 %then %do;
 %let i = %eval(&i + 1);
 %put I = &i;
 %let rc = %sysfunc(sleep(40, 1));
%end;

%if &loadstatus = 1 %then %goto exit;
%end; * end: do-loop; 

* Max antal kontroller av datalagret har utförts.;
%if &i = &nroftries %then %do;
%put &nroftries kontroller av flagga för datalagret har utförts. Loadstatus är &loadstatus.. Programmet avbryts.;
%abort abend;
%end;
%EXIT:
%put Datalagret är klart att läsa. Loadstatus är &loadstatus..;
%mend;

* Exempel på anrop;
%*statusDatalager(statustable=VW_SYSTEMLOAD, nroftries=3);


