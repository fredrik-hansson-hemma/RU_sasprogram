
%mdsecds(folder="\Acceptanstest\LUL", membertypes="Table", includesubfolders=no);
 Proc sort data=work.mdsecds_objs (where=(not index(upcase(objname), "_STG"))) out=_tables(keep=objname);
  by location objname;
  where publicType = 'Table';
 run; 

 %macro test;
 %let dsid = %sysfunc(open(_TABLES));
 %let nobs = %sysfunc(attrn(&dsid, NOBS));
 
 %do %while (%sysfunc(fetch(&dsid)) = 0);

 	%let memname = %sysfunc(getvarc(&dsid, 1));
	%put MEMNAME= &memname;

	proc sql noprint;
		create table columnlist as
		select memname 
		from dictionary.columns
		where libname = 'VALIBLA' and memname = "&memname" and upcase(name) = "VERKS_NAME";
	quit;

	proc append base=TABLES new=columnlist force;
	run;

	%let c_dsid = %sysfunc(open(columnlist));
	%let c_nobs = %sysfunc(attrn(&c_dsid, NOBS));
	%let c_dsid = %sysfunc(close(&c_dsid));
	%put C_NOBS=&c_nobs;
 
%end;
 
%let dsid = %sysfunc(close(&dsid));
%mend;

%test;


	
		




 
