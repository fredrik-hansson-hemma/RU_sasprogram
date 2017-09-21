/** QUERY **/ 
%macro disablelisting;
   /* Disable listing file output */
   filename nulpath dummy;
   proc printto print = nulpath;
   run;
%mend;
%disablelisting;
/** PREPROCESSING CODE **/ 
%let VATABLE = OPPLAN_DAG_SAL;

%LET VDB_GRIDHOST=bs-ap-04.lul.se;
%LET VDB_GRIDINSTALLLOC=/opt/TKGrid;
options set=GRIDHOST="bs-ap-04.lul.se";
options set=GRIDINSTALLLOC="/opt/TKGrid";
options validvarname=any validmemname=extend;
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

LIBNAME LULDW SQLSVR  READ_LOCK_TYPE=NOLOCK  Datasrc=LULDW  SCHEMA=va  USER=sasVA  PASSWORD="{SAS002}6DC8FE512E0DA8B60937A18B0A83601F416F94B329D1D979384EC89E5268A2B3" ;

LIBNAME VALIBLA SASIOLA  TAG=HPS  PORT=10010 HOST="bs-ap-04.lul.se"  SIGNER="http://bs-ap-04.lul.se:7980/SASLASRAuthorization" ;

option DBIDIRECTEXEC;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_OPPLAN_0006 AS 
   SELECT t1.OP_Sal, 
          t1.OPResponsibleUnit, 
          t1.OPResponsibleVO, 
          t1.OPPerformingVO, 
          t1.OPPerformingUnit, 
          t1.JourTid, 
          t1.Akut, 
          t1.OPQuantity, 
          t1.AnestesiStartTid, 
          t1.AnestesiSlutTid, 
          t1.OperationStartTid, 
          t1.BytesTid, 
          t1.KnivBytesTid, 
          t1.OPStartYear, 
          t1.OpStartWeek, 
          /* DATUM */
            (datepart(t1.Datum)) FORMAT=YYMMDD. AS DATUM, 
          /* astarttid */
            ((input(t1.AnestesiStartTid,time.))) FORMAT=time. AS astarttid, 
          /* aslutttid */
            ((input(t1.AnestesiSlutTid,time.))) FORMAT=time. AS aslutttid, 
          /* opstarttid */
            ((input(t1.OperationStartTid,time.))) FORMAT=time. AS opstarttid, 
          t1.Datum AS Datum1, 
          t1.Dag, 
          /* varavakutop */
            (CASE 
               WHEN t1.Akut = 'Ja' THEN 1
               ELSE 0
            END) FORMAT=8. LABEL="Varav akuta op" AS varavakutop
      FROM LULDW.OPPlan t1
      ORDER BY t1.OP_Sal,
               DATUM;
QUIT;

proc sort data=QUERY_FOR_OPPLAN_0006(keep=op_sal datum AnestesiStartTid astarttid jourtid) out=astarttid;
  where compress(JourTid) eq 'Ja';
  by op_sal datum astarttid;
run;

data work.astarttid(keep=op_sal datum AnestesiStartTid astarttid);
  set WORK.astarttid;
  by op_sal datum ;
  if first.datum then do;
    output;
  end;
run;

proc sort data=QUERY_FOR_OPPLAN_0006(keep=op_sal datum AnestesiSlutTid aslutttid jourtid) out=aslutttid;
  where compress(JourTid) eq 'Ja';
  by op_sal datum aslutttid;
run;

data work.aslutttid(keep=op_sal datum AnestesiSlutTid aslutttid);
  set WORK.aslutttid;
  by op_sal datum ;
  if last.datum then do;
    output;
  end;
run;

proc sort data=QUERY_FOR_OPPLAN_0006(keep=op_sal datum OperationStartTid opstarttid jourtid) out=opstarttid;
  where compress(JourTid) eq 'Ja';
  by op_sal datum opstarttid;
run;

data work.opstarttid(keep=op_sal datum OperationStartTid opstarttid jourtid);
  set WORK.opstarttid;
  by op_sal datum ;
  if first.datum then do;
    output;
  end;
run;

data work.time_ja;
  merge work.astarttid work.aslutttid work.opstarttid;
  by op_sal datum;
run;

proc sort data=QUERY_FOR_OPPLAN_0006(keep=op_sal datum AnestesiStartTid astarttid jourtid) out=astarttid;
  where compress(JourTid) eq 'Nej';
  by op_sal datum astarttid;
run;

data work.astarttid(keep=op_sal datum AnestesiStartTid astarttid);
  set WORK.astarttid;
  by op_sal datum ;
  if first.datum then do;
    output;
  end;
run;

proc sort data=QUERY_FOR_OPPLAN_0006(keep=op_sal datum AnestesiSlutTid aslutttid jourtid) out=aslutttid;
  where compress(JourTid) eq 'Nej';
  by op_sal datum aslutttid;
run;

data work.aslutttid(keep=op_sal datum AnestesiSlutTid aslutttid);
  set WORK.aslutttid;
  by op_sal datum ;
  if last.datum then do;
    output;
  end;
run;

proc sort data=QUERY_FOR_OPPLAN_0006(keep=op_sal datum OperationStartTid opstarttid jourtid) out=opstarttid;
  where compress(JourTid) eq 'Nej';
  by op_sal datum opstarttid;
run;

data work.opstarttid(keep=op_sal datum OperationStartTid opstarttid jourtid);
  set WORK.opstarttid;
  by op_sal datum ;
  if first.datum then do;
    output;
  end;
run;

data work.time_nej;
  merge work.astarttid work.aslutttid work.opstarttid;
  by op_sal datum;
run;

data work.time;
  set time_ja time_nej;
run;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_OPPLAN1 AS 
   SELECT t1.OP_Sal, 
          t1.OPResponsibleUnit, 
          t1.OPResponsibleVO, 
          t1.OPPerformingVO, 
          t1.OPPerformingUnit, 
          t1.JourTid, 
          t1.Akut, 
          t1.DATUM, 
          t1.Datum1, 
          t1.OPStartYear, 
          t1.OpStartWeek, 
          /* OPQuantity */
            (SUM(t1.OPQuantity)) FORMAT=11. AS OPQuantity, 
          /* BytesTid */
            (SUM(t1.BytesTid)) FORMAT=11. AS BytesTid, 
          /* KnivBytesTid */
            (SUM(t1.KnivBytesTid)) FORMAT=11. AS KnivBytesTid, 
          /* varavakutop */
            (SUM(t1.varavakutop)) FORMAT=8. LABEL="Varav akut op" AS varavakutop, 
          t1.Dag
      FROM WORK.QUERY_FOR_OPPLAN_0006 t1
      GROUP BY t1.OP_Sal,
               t1.OPResponsibleUnit,
               t1.OPResponsibleVO,
               t1.OPPerformingVO,
               t1.OPPerformingUnit,
               t1.JourTid,
               t1.Akut,
               t1.DATUM,
               t1.Datum1,
               t1.OPStartYear,
               t1.OpStartWeek,
               t1.Dag;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_OPPLAN1_0000 AS 
   SELECT t1.OP_Sal, 
          t1.OPResponsibleUnit, 
          t1.OPResponsibleVO, 
          t1.OPPerformingVO, 
          t1.OPPerformingUnit, 
          t1.JourTid, 
          t1.Akut, 
          t1.DATUM, 
          t1.Datum1, 
          t1.OPStartYear, 
          t1.OpStartWeek, 
          t1.OPQuantity, 
          t1.BytesTid, 
          t1.KnivBytesTid, 
          t2.astarttid FORMAT=TIME5., 
          t2.opstarttid, 
          t2.aslutttid, 
          t2.AnestesiSlutTid, 
          t2.OperationStartTid, 
          /* week */
            (substr(compress(put(t1.OpStartWeek,8.)),5)) AS week, 
          t1.Dag, 
          t1.varavakutop
      FROM WORK.QUERY_FOR_OPPLAN1 t1
           INNER JOIN WORK.TIME t2 ON (t1.OP_Sal = t2.OP_Sal AND (t1.DATUM = t2.DATUM AND t1.JourTid = t2.JourTid));
QUIT;


PROC SQL;
   CREATE TABLE WORK.OPPLAN_DAG_SAL(label="OPPLAN_DAG_SAL") AS 
   SELECT t1.OP_Sal, 
          t1.OPResponsibleUnit, 
          t1.OPResponsibleVO, 
          t1.OPPerformingVO, 
          t1.OPPerformingUnit, 
          t1.JourTid, 
          t1.Akut, 
          t1.DATUM, 
          t1.Datum1, 
          t1.OPStartYear, 
          t1.OpStartWeek, 
          t1.OPQuantity, 
          t1.BytesTid, 
          t1.KnivBytesTid, 
          t1.astarttid, 
          t1.opstarttid, 
          t1.aslutttid, 
          t1.AnestesiSlutTid, 
          t1.OperationStartTid, 
          t1.week, 
          t1.Dag, 
          t1.varavakutop
      FROM WORK.QUERY_FOR_OPPLAN1_0000 t1;
QUIT;

data HPS.OPPLAN_DAG_SAL ( replace=yes logupdate blocksize=32m  );
	set WORK.OPPLAN_DAG_SAL (  );
run;
/* Synchronize table registration */
%registerTable(
     LIBRARY=%nrstr(/Shared Data/Hadoop/Visual Analytics HDFS)
   , REPOSID=%str(A5WAGCCG)
   , TABLEID=%str(A5WAGCCG.BF000342)
   );
/* Drop existing table */
%vdb_dt(VALIBLA.OPPLAN_DAG_SAL);
proc lasr port=10010
    data=HPS.OPPLAN_DAG_SAL
    signer="http://bs-ap-04.lul.se:7980/SASLASRAuthorization"
    add noclass;
    performance host="bs-ap-04.lul.se";
run;
/* Synchronize table registration */
%registerTable(
     LIBRARY=%nrstr(/Shared Data/SAS Visual Analytics/Visual Analytics LASR)
   , REPOSID=%str(A5WAGCCG)
   , TABLEID=%str(A5WAGCCG.BF000341)
   );
/** POSTPROCESSING CODE **/ 
%set_labels(VATABLE=&vatable);  
   
