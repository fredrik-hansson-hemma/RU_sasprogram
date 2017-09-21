%macro disablelisting;
   /* Disable listing file output */
   filename nulpath dummy;
   proc printto print = nulpath;
   run;
%mend;

%disablelisting;
/** QUERY **/ 

%LET VDB_GRIDHOST=bs-ap-04.lul.se;
%LET VDB_GRIDINSTALLLOC=/opt/TKGrid;
options set=GRIDHOST="bs-ap-04.lul.se";
options set=GRIDINSTALLLOC="/opt/TKGrid";
options validvarname=any validmemname=extend;

%let VATABLE = OPPLAN_DAG_SAL;
%statusdatalager(statustable=VW_SYSTEMLOAD, vatable=&vatable); * Ser om datalagret är klart att läsa från.;

/* Register Table Macro */
%macro registertable( REPOSITORY=Foundation, REPOSID=, LIBRARY=, TABLE=, FOLDER=, TABLEID=, PREFIX= );

/* Mask special characters */

   %let REPOSITORY=%superq(REPOSITORY);
   %let LIBRARY   =%superq(LIBRARY);
   %let FOLDER    =%superq(FOLDER);
   %let TABLE     =%superq(TABLE);

   %let REPOSARG=%str(REPNAME="&REPOSITORY.");
   %if ("&REPOSID." ne "") %THEN %LET REPOSARG=%str(REPID="&REPOSID.");

   %if ("&TABLEID." ne "") %THEN %LET SELECTOBJ=%str(&TABLEID.);
   %else                         %LET SELECTOBJ=&TABLE.;

   %if ("&FOLDER." ne "") %THEN
      %PUT INFO: Registering &FOLDER./&SELECTOBJ. to &LIBRARY. library.;
   %else
      %PUT INFO: Registering &SELECTOBJ. to &LIBRARY. library.;

   proc metalib;
      omr (
         library="&LIBRARY." 
         %str(&REPOSARG.) 
          ); 
      %if ("&TABLEID." eq "") %THEN %DO;
         %if ("&FOLDER." ne "") %THEN %DO;
            folder="&FOLDER.";
         %end;
      %end;
      %if ("&PREFIX." ne "") %THEN %DO;
         prefix="&PREFIX.";
      %end;
      select ("&SELECTOBJ."); 
   run; 
   quit;

%mend;

LIBNAME HPS SASHDAT  PATH="/hps"  SERVER="bs-ap-04.lul.se"  INSTALL="/opt/TKGrid" ;

LIBNAME VALIBLA SASIOLA  TAG=HPS  PORT=10010 HOST="bs-ap-04.lul.se"  SIGNER="https://rapport.lul.se:443/SASLASRAuthorization" ;

LIBNAME LULDW SQLSVR  READ_LOCK_TYPE=NOLOCK  Datasrc=LULDW  SCHEMA=va  USER=sasVA  PASSWORD="{SAS002}6DC8FE512E0DA8B60937A18B0A83601F416F94B329D1D979384EC89E5268A2B3" ;

option DBIDIRECTEXEC;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_OPPLAN_0006 AS 
   SELECT t1.M_OpanPla_OpSal, 
          t1.OpMedAnsvEnh2_UnitName, 
          t1.OpMedAnsvEnh2_FunctionName, 
          t1.OpOmvansvEnh3_FunctionName, 
          t1.OpOmvansvEnh3_UnitName, 
          t1.M__JourTid, 
          t1.M_Opan_Acute, 
          t1.Operation_Counter, 
          t1.M__AnestesiStartTid, 
          t1.M__AnestesiSlutTid, 
          t1.OpDebDurStartKlo_Timedescriptio, 
          t1.M__BytesTid, 
          t1.M__Knivbytestid, 
          t1.OpDebDurStartDat_Year, 
          t1.OpDebDurStartDat_ISOWeek, 
          /* OpDebDurStartDat_FullDate */
            (datepart(t1.OpDebDurStartDat_FullDate)) FORMAT=YYMMDD. AS OpDebDurStartDat_FullDate, 
          /* astarttid */
            ((input(t1.M__AnestesiStartTid,time.))) FORMAT=time. AS astarttid, 
          /* aslutttid */
            ((input(t1.M__AnestesiSlutTid,time.))) FORMAT=time. AS aslutttid, 
          /* opstarttid */
            ((input(t1.OpDebDurStartKlo_Timedescriptio,time.))) FORMAT=time. AS opstarttid, 
          t1.OpDebDurStartDat_FullDate AS OpDebDurStartDat_FullDate1, 
          t1.OpDebDurStartDat_DayNameShort, 
          /* varavM_Opan_Acuteop */
            (CASE 
               WHEN t1.M_Opan_Acute = 'Ja' THEN 1
               ELSE 0
            END) FORMAT=8. LABEL="Varav M_Opan_Acutea op" AS varavM_Opan_Acuteop
      FROM LULDW.OPPlan t1
      ORDER BY t1.M_OpanPla_OpSal,
               OpDebDurStartDat_FullDate;
QUIT;

proc sort data=QUERY_FOR_OPPLAN_0006(keep=M_OpanPla_OpSal OpDebDurStartDat_FullDate M__AnestesiStartTid astarttid M__JourTid) out=astarttid;
  where compress(M__JourTid) eq 'Ja';
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate astarttid;
run;

data work.astarttid(keep=M_OpanPla_OpSal OpDebDurStartDat_FullDate M__AnestesiStartTid astarttid);
  set WORK.astarttid;
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate ;
  if first.OpDebDurStartDat_FullDate then do;
    output;
  end;
run;

proc sort data=QUERY_FOR_OPPLAN_0006(keep=M_OpanPla_OpSal OpDebDurStartDat_FullDate M__AnestesiSlutTid aslutttid M__JourTid) out=aslutttid;
  where compress(M__JourTid) eq 'Ja';
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate aslutttid;
run;

data work.aslutttid(keep=M_OpanPla_OpSal OpDebDurStartDat_FullDate M__AnestesiSlutTid aslutttid);
  set WORK.aslutttid;
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate ;
  if last.OpDebDurStartDat_FullDate then do;
    output;
  end;
run;

proc sort data=QUERY_FOR_OPPLAN_0006(keep=M_OpanPla_OpSal OpDebDurStartDat_FullDate OpDebDurStartKlo_Timedescriptio opstarttid M__JourTid) out=opstarttid;
  where compress(M__JourTid) eq 'Ja';
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate opstarttid;
run;

data work.opstarttid(keep=M_OpanPla_OpSal OpDebDurStartDat_FullDate OpDebDurStartKlo_Timedescriptio opstarttid M__JourTid);
  set WORK.opstarttid;
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate ;
  if first.OpDebDurStartDat_FullDate then do;
    output;
  end;
run;

data work.time_ja;
  merge work.astarttid work.aslutttid work.opstarttid;
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate;
run;

proc sort data=QUERY_FOR_OPPLAN_0006(keep=M_OpanPla_OpSal OpDebDurStartDat_FullDate M__AnestesiStartTid astarttid M__JourTid) out=astarttid;
  where compress(M__JourTid) eq 'Nej';
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate astarttid;
run;

data work.astarttid(keep=M_OpanPla_OpSal OpDebDurStartDat_FullDate M__AnestesiStartTid astarttid);
  set WORK.astarttid;
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate ;
  if first.OpDebDurStartDat_FullDate then do;
    output;
  end;
run;

proc sort data=QUERY_FOR_OPPLAN_0006(keep=M_OpanPla_OpSal OpDebDurStartDat_FullDate M__AnestesiSlutTid aslutttid M__JourTid) out=aslutttid;
  where compress(M__JourTid) eq 'Nej';
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate aslutttid;
run;

data work.aslutttid(keep=M_OpanPla_OpSal OpDebDurStartDat_FullDate M__AnestesiSlutTid aslutttid);
  set WORK.aslutttid;
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate ;
  if last.OpDebDurStartDat_FullDate then do;
    output;
  end;
run;

proc sort data=QUERY_FOR_OPPLAN_0006(keep=M_OpanPla_OpSal OpDebDurStartDat_FullDate OpDebDurStartKlo_Timedescriptio opstarttid M__JourTid) out=opstarttid;
  where compress(M__JourTid) eq 'Nej';
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate opstarttid;
run;

data work.opstarttid(keep=M_OpanPla_OpSal OpDebDurStartDat_FullDate OpDebDurStartKlo_Timedescriptio opstarttid M__JourTid);
  set WORK.opstarttid;
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate ;
  if first.OpDebDurStartDat_FullDate then do;
    output;
  end;
run;

data work.time_nej;
  merge work.astarttid work.aslutttid work.opstarttid;
  by M_OpanPla_OpSal OpDebDurStartDat_FullDate;
run;

data work.time;
  set time_ja time_nej;
run;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_OPPLAN1 AS 
   SELECT t1.M_OpanPla_OpSal, 
          t1.OpMedAnsvEnh2_UnitName, 
          t1.OpMedAnsvEnh2_FunctionName, 
          t1.OpOmvansvEnh3_FunctionName, 
          t1.OpOmvansvEnh3_UnitName, 
          t1.M__JourTid, 
          t1.M_Opan_Acute, 
          t1.OpDebDurStartDat_FullDate, 
          t1.OpDebDurStartDat_FullDate1, 
          t1.OpDebDurStartDat_Year, 
          t1.OpDebDurStartDat_ISOWeek, 
          /* Operation_Counter */
            (SUM(t1.Operation_Counter)) FORMAT=11. AS Operation_Counter, 
          /* M__BytesTid */
            (SUM(t1.M__BytesTid)) FORMAT=11. AS M__BytesTid, 
          /* M__Knivbytestid */
            (SUM(t1.M__Knivbytestid)) FORMAT=11. AS M__Knivbytestid, 
          /* varavM_Opan_Acuteop */
            (SUM(t1.varavM_Opan_Acuteop)) FORMAT=8. LABEL="Varav M_Opan_Acute op" AS varavM_Opan_Acuteop, 
          t1.OpDebDurStartDat_DayNameShort
      FROM WORK.QUERY_FOR_OPPLAN_0006 t1
      GROUP BY t1.M_OpanPla_OpSal,
               t1.OpMedAnsvEnh2_UnitName,
               t1.OpMedAnsvEnh2_FunctionName,
               t1.OpOmvansvEnh3_FunctionName,
               t1.OpOmvansvEnh3_UnitName,
               t1.M__JourTid,
               t1.M_Opan_Acute,
               t1.OpDebDurStartDat_FullDate,
               t1.OpDebDurStartDat_FullDate1,
               t1.OpDebDurStartDat_Year,
               t1.OpDebDurStartDat_ISOWeek,
               t1.OpDebDurStartDat_DayNameShort;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_OPPLAN1_0000 AS 
   SELECT t1.M_OpanPla_OpSal, 
          t1.OpMedAnsvEnh2_UnitName, 
          t1.OpMedAnsvEnh2_FunctionName, 
          t1.OpOmvansvEnh3_FunctionName, 
          t1.OpOmvansvEnh3_UnitName, 
          t1.M__JourTid, 
          t1.M_Opan_Acute, 
          t1.OpDebDurStartDat_FullDate, 
          t1.OpDebDurStartDat_FullDate1, 
          t1.OpDebDurStartDat_Year, 
          t1.OpDebDurStartDat_ISOWeek, 
          t1.Operation_Counter, 
          t1.M__BytesTid, 
          t1.M__Knivbytestid, 
          t2.astarttid FORMAT=TIME5., 
          t2.opstarttid, 
          t2.aslutttid, 
          t2.M__AnestesiSlutTid, 
          t2.OpDebDurStartKlo_Timedescriptio, 
          /* week */
            (substr(compress(put(t1.OpDebDurStartDat_ISOWeek,8.)),5)) AS week, 
          t1.OpDebDurStartDat_DayNameShort, 
          t1.varavM_Opan_Acuteop
      FROM WORK.QUERY_FOR_OPPLAN1 t1
           INNER JOIN WORK.TIME t2 ON (t1.M_OpanPla_OpSal = t2.M_OpanPla_OpSal AND (t1.OpDebDurStartDat_FullDate = t2.OpDebDurStartDat_FullDate AND t1.M__JourTid = t2.M__JourTid));
QUIT;


PROC SQL;
   CREATE TABLE WORK.OPPLAN_DAG_SAL(label="OPPLAN_DAG_SAL") AS 
   SELECT t1.M_OpanPla_OpSal, 
          t1.OpMedAnsvEnh2_UnitName, 
          t1.OpMedAnsvEnh2_FunctionName, 
          t1.OpOmvansvEnh3_FunctionName, 
          t1.OpOmvansvEnh3_UnitName, 
          t1.M__JourTid, 
          t1.M_Opan_Acute, 
          t1.OpDebDurStartDat_FullDate, 
          t1.OpDebDurStartDat_FullDate1, 
          t1.OpDebDurStartDat_Year, 
          t1.OpDebDurStartDat_ISOWeek, 
          t1.Operation_Counter, 
          t1.M__BytesTid, 
          t1.M__Knivbytestid, 
          t1.astarttid, 
          t1.opstarttid, 
          t1.aslutttid, 
          t1.M__AnestesiSlutTid, 
          t1.OpDebDurStartKlo_Timedescriptio, 
          t1.week, 
          t1.OpDebDurStartDat_DayNameShort, 
          t1.varavM_Opan_Acuteop
      FROM WORK.QUERY_FOR_OPPLAN1_0000 t1;
QUIT;


data HPS.Opplan_Dag_Sal (  replace=yes logupdate blocksize=32m  );
	set OPPLAN_DAG_SAL (  );
run;

/* Synchronize table registration */
%registerTable(
     LIBRARY=%nrstr(/Shared Data/Hadoop/Visual Analytics HDFS)
   , REPOSID=%str(A5WAGCCG)
   , TABLEID=%str(A5WAGCCG.BF000LQS)
   );
/* Drop existing table */
%vdb_dt(VALIBLA.Opplan_Dag_Sal);
libname VALIBLA CLEAR;
/* Optimize Load with PROC LASR */
proc lasr port=10010
    data=HPS.Opplan_Dag_Sal 
    signer="https://rapport.lul.se:443/SASLASRAuthorization"
    add noclass;
    performance host="bs-ap-04.lul.se" ;
run;

/* Synchronize table registration */
%registerTable(
     LIBRARY=%nrstr(/Shared Data/SAS Visual Analytics/Visual Analytics LASR)
   , REPOSID=%str(A5WAGCCG)
   , TABLEID=%str(A5WAGCCG.BF000LQR)
   );

%set_labels(VATABLE=&vatable);
