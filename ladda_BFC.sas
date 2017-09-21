/* --------------------------------------------------------------------
   Kod genererad av en SAS-uppgift
   
   Genererad den 31 augusti 2015 19:34:29
   Av uppgift:     guiden Importera data
   
   K�llfil: C:\Mattias\VA-rapporter\UAS_R�ntgen\Testfil till
   produktionsstatistik BFC_avidentifierad.csv
   Server:      Lokalt filsystem
   
   Output-data: WORK.'Testfil till produktionsstatisti'n
   Server:      SASAppVA
   
   Obs! Som f�reberedelse inf�r k�rning av nedanst�ende kod har guiden
   Importera data anv�nt interna rutiner f�r att �verf�ra
   k�lldatafilen fr�n det lokala filsystemet till SASAppVA. Det finns
   ingen SAS-kod tillg�nglig f�r att representera den h�r �tg�rden.
   -------------------------------------------------------------------- */
%macro ladda_BFC();

%let FIL=BFC_test.txt;
%let rc=;

/* FTP listning */
filename xpt ftp '' ls 
user='ASBFC' pass='iP6o0mi' host='infr-ftp-01.lul.se';

/* FTP mot fil */
filename xpt ftp "&fil"
user='ASBFC' pass='iP6o0mi' host='infr-ftp-01.lul.se';

/* Tar bort en fil p� FTP-servern. */
filename tabort ftp "&fil" 
user='ASBFC' pass='iP6o0mi' host='infr-ftp-01.lul.se'
RCMD="DELE &fil";

data _null_;
  rc = fileref("tabort");
run; 
/* Slut: Tar bort en fil p� FTP-servern. */  

data _null_;
    infile xpt;
    input;	
    if _infile_="&FIL" then do; 
		call symput('RC',"FILE FOUND");
    end;
run;

%put RC=&rc;

/* Om det inte finns n�gon fil att l�sa in p� FTP-servern avbryts programmet. */
data _null_;
  if symget("RC") ne "FILE FOUND" then do;
	  abort return 0;
	end;
run;

/* L�s in data om fil finns. */
DATA WORK._BFC;
    LENGTH
        BOOKRESP_DESC    $ 41
        USPRIO           $ 18
        RREQNR             8
        VISITREQGR       $ 23
        METHODS_DESC     $ 42
        DID              $ 12
        DBOOKNR            8
        SIGNDOC1_NAME    $ 66
        DLOCATION_DESC   $ 23
        BOOKDATE           8
        ADM_CODE         $ 22
        SIGNDOC2_NAME    $ 67
        BOOKTIME           8
        STATUS           $ 9
        REQGR_ANSVAR       8
        DOCTOR_NAME      $ 67
        RDSTUDYNR          8
        RDRESCODE        $ 5
        RESCODE_DESC     $ 63 ;
    FORMAT
        BOOKRESP_DESC    $CHAR41.
        USPRIO           $CHAR18.
        RREQNR           BEST8.
        VISITREQGR       $CHAR23.
        METHODS_DESC     $CHAR42.
        DID              $CHAR12.
        DBOOKNR          BEST8.
        SIGNDOC1_NAME    $CHAR66.
        DLOCATION_DESC   $CHAR23.
        BOOKDATE         YYMMDD10.
        ADM_CODE         $CHAR22.
        SIGNDOC2_NAME    $CHAR67.
        BOOKTIME         TIME8.
        STATUS           $CHAR9.
        REQGR_ANSVAR     BEST5.
        DOCTOR_NAME      $CHAR67.
        RDSTUDYNR        BEST2.
        RDRESCODE        $CHAR5.
        RESCODE_DESC     $CHAR63. ;
    INFORMAT
        BOOKRESP_DESC    $CHAR41.
        USPRIO           $CHAR18.
        RREQNR           BEST8.
        VISITREQGR       $CHAR23.
        METHODS_DESC     $CHAR42.
        DID              $CHAR12.
        DBOOKNR          BEST8.
        SIGNDOC1_NAME    $CHAR66.
        DLOCATION_DESC   $CHAR23.
        BOOKDATE         YYMMDD10.
        ADM_CODE         $CHAR22.
        SIGNDOC2_NAME    $CHAR67.
        BOOKTIME         TIME11.
        STATUS           $CHAR9.
        REQGR_ANSVAR     BEST5.
        DOCTOR_NAME      $CHAR67.
        RDSTUDYNR        BEST2.
        RDRESCODE        $CHAR5.
        RESCODE_DESC     $CHAR63. ;
    INFILE xpt
        LRECL=504
        ENCODING="LATIN9"
        TERMSTR=CRLF
        DLM='09'x
        MISSOVER
        DSD FIRSTOBS=2;
    INPUT
        BOOKRESP_DESC    : $CHAR41.
        USPRIO           : $CHAR18.
        RREQNR           : ?? BEST8.
        VISITREQGR       : $CHAR23.
        METHODS_DESC     : $CHAR42.
        DID              : $CHAR12.
        DBOOKNR          : ?? BEST8.
        SIGNDOC1_NAME    : $CHAR66.
        DLOCATION_DESC   : $CHAR23.
        BOOKDATE         : ?? YYMMDD10.
        ADM_CODE         : $CHAR22.
        SIGNDOC2_NAME    : $CHAR67.
        BOOKTIME         : ?? TIME5.
        STATUS           : $CHAR9.
        REQGR_ANSVAR     : ?? BEST5.
        DOCTOR_NAME      : $CHAR67.
        RDSTUDYNR        : ?? BEST2.
        RDRESCODE        : $CHAR5.
        RESCODE_DESC     : $CHAR63. ;

		 period = put(bookdate, yymmn6.);
run;


proc format lib=work;
value $sektion
'Skelett' = 'Muskuloskeletal och barn '
'Barn' = 'Muskuloskeletal och barn '
'Gastro' = 'Buk'
'Perifer intervention' = 'Buk'
'Ultraljud' = 'Buk'
'Ultraljud Tierp' = 'Buk'
'Uro / Gyn' = 'Buk'
'Vaskul�ra anomalier' = 'Buk'
'Neuro'	= 'Neuro'
'Neurointervention' = 'Neuro'
'Hj�rta' = 'Molekul�r bilddiagnostik och thorax'
'Lunga' = 'Molekul�r bilddiagnostik och thorax' 
'Nukle�rmedicin' = 'Molekul�r bilddiagnostik och thorax'
'Onkologi' = 'Molekul�r bilddiagnostik och thorax'
'PET-Centrum' = 'Molekul�r bilddiagnostik och thorax'
other = 'BORT'
;

value $metod
'DT' = 'KVAR'
'INTERVENTION' = 'KVAR'
'KONV RTG' = 'KVAR' 
'MR' = 'KVAR'
'NM' = 'KVAR'
'PET' = 'KVAR' 
'SKYLT' = 'KVAR' 
'ULJ' = 'KVAR'
other = 'BORT'
;

value $rum
'- AS UTEBLIVNA' = 'BORT'
'AS AVBOKAS' = 'BORT'
'AS Extern enhet' = 'BORT'
'AS OMBOKAS' = 'BORT'
'AS LAGRA' = 'BORT'
'AS V�ntelista MR' = 'BORT'
'Diverse PET-C'	= 'BORT'									
'K�K CBDT' = 'BORT'
'K�K DIVERSE' = 'BORT'
'K�K L01' = 'BORT'
'K�K L01-IO' = 'BORT'
'K�K L02' = 'BORT'
'K�K L03' = 'BORT'
'K�K SKYLTN' = 'BORT'
'NM Avbokas' = 'BORT'
'SAKNAS' = 'BORT'
other = 'KVAR'
run;

* Kollar m�nad i filen;
proc sort data=_bfc (keep=period) out=datum nodupkey;
by period;
run;

%let dsid = %sysfunc(open(datum));
%let nobs = %sysfunc(attrn(&dsid, NOBS));

%do %while(%sysfunc(fetch(&dsid)) = 0);
	%let period = %sysfunc(getvarc(&dsid, %sysfunc(varnum(&dsid, PERIOD))));
	%put DATUM I FILEN: &period;

	* Rensa om redan inl�st;
	proc sql noprint;
		delete from sasdata.bfc
		where put(bookdate, yymmn6.) = "&period";
	quit;

%end;

%let dsid = %sysfunc(close(&dsid));

data bfc;
set _bfc (drop=period);
label USPRIO  = '�nskad prio'	
RREQNR = 'Remissnr'	
METHODS_DESC = 'Metod'	
BOOKRESP_DESC = 'Bokn.ansvar'	
VISITREQGR = 'Rem.grupp'
DBOOKNR	= 'Bokn.nr'
BOOKTIME = 'Tid'	
BOOKDATE = 'Datum'	
ADM_CODE = 'Admin.typ'	
DID	= 'Personnr'
STATUS	= 'Status'
SIGNDOC2_NAME = 'Sign2.l�k'	
DLOCATION_DESC = 'Rum / Labb'	
DOCTOR_NAME = 'Dikt.l�k'	
REQGR_ANSVAR = 'Ansvar Rem.grp'	
SIGNDOC1_NAME = 'Sign1.l�k' 	
RDSTUDYNR = 'L�pnr'
RDRESCODE = 'Kod'
RESCODE_DESC = 'Unders�kningskod';

attrib sektion length=$35 label="Sektion";
attrib metodgrupp length=$10 label="Unders�kn./Skylt";

if upcase(methods_desc) = 'SKYLT' then metodgrupp = 'Skylt'; 
if upcase(methods_desc) ne 'SKYLT' then metodgrupp = 'Unders�kn.';

* GML har ersatts med KONV RTG sedan 2015;
if upcase(methods_desc) in ('GML', 'UTG�TT GML') then methods_desc = 'KONV RTG';


sektion = put(visitreqgr,$sektion.);
 
* Ta bort v�rden som inte har giltig Sektion;
if upcase(sektion) = 'BORT' then delete;
* Ta bort testpatienter;
if compress(did) in ('10101910','121212121212','12345','1234567890','124','189905149804','189910209817','191010101010','191212121121','191212121212',												
 '192233442233','192406259255','192901209151','193409037003','194308117094','194310127479','194508084755','194605076894','19500101025D','19641112003K','196603143428','197609112388',												
 '199504242398','200101012383','20050223501C','TT100223510G','28012009','33333333','M03820070221','M0512000408','TT100223510G')	then delete;
* Ta bort avbokningar;
if not missing(adm_code) then delete;
* Ta bort avvikande v�rden f�r Methods_desc;
if put(upcase(methods_desc), $metod.) = 'BORT' then delete;	
* Ta bort avvikande rader f�r RDRESCODE (Kod);				
if upcase(rdrescode) in ("00000","BOKNT","LAGRA") then delete;
* Ta bort avvikelser f�r Dlocation_desc (Rum / Labb);
if upcase(put(dlocation_desc, $rum.)) = 'BORT' then delete;												
	

run;	

proc append base=sasdata.bfc data=bfc force;
run;

%mend;

%ladda_BFC;
