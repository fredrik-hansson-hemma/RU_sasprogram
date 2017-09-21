/****************************************************
* Program: list_VATables
*
* Listar alla tabeller som är registrerade i metadata på LASR-servrarna.
* Varje LASR-server anropas genom macrot get_metadata_library_tables.
* Vid ny server, ska nytt anrop läggas in i programmet.
* 
* Skapat av Mattias M.
*****************************************************/

%macro get_metadata_library_tables(
    libref= 
    ,outds= metadata_tables
  );

%local nobj_statement;
%if %length(&libref)=0 %then %let nobj_statement=
  %str( metadata_getnobj("omsobj:SASLibrary?@Id contains '.'",n,uri) );
%else %let nobj_statement=
  %str( metadata_getnobj("omsobj:SASLibrary?@Libref='&libref'",n,uri) );

data &outds;
  length uri serveruri conn_uri domainuri libname ServerContext AuthDomain 
    path_schema usingpkguri type tableuri coluri $256 id $17
    desc $200 libref engine $8 isDBMS $1 
    table $50 /* metadata table names can be longer than $32 */
    ;
  keep libname desc libref engine ServerContext path_schema AuthDomain tableuri 
    table IsPreassigned IsDBMSLibname id;
  nobj=.;
  n=1;
  uri='';
  serveruri='';
  conn_uri='';
  domainuri='';

  /***Determine if library/ies exist ***/
  nobj=&nobj_statement;

  /***Retrieve the attributes for all libraries, if there are any***/
  if n>0 then do n=1 to nobj;
    libname='';
    ServerContext='';
    AuthDomain='';
    desc='';
    libref='';
    engine='';
    isDBMS='';
    IsPreassigned='';
    IsDBMSLibname='';
    path_schema='';
    usingpkguri='';
    type='';
    id='';
    nobj=&nobj_statement;
    rc= metadata_getattr(uri, "Name", libname);
    rc= metadata_getattr(uri, "Desc", desc);
    rc= metadata_getattr(uri, "Libref", libref);
    rc= metadata_getattr(uri, "Engine", engine);
    rc= metadata_getattr(uri, "IsDBMSLibname", isDBMS);
    rc= metadata_getattr(uri, "IsDBMSLibname", IsDBMSLibname); 
    rc= metadata_getattr(uri, "IsPreassigned", IsPreassigned); 
    rc= metadata_getattr(uri, "Id", Id);

    /*** Get associated ServerContext ***/
    i=1;
    rc= metadata_getnasn(uri, "DeployedComponents", i, serveruri);
    if rc > 0 then rc2= metadata_getattr(serveruri, "Name", ServerContext);
    else ServerContext='';

    /*** If the library is a DBMS library, get the Authentication Domain
         associated with the DBMS connection credentials ***/
    if isDBMS="1" then do;
      i=1; 
      rc= metadata_getnasn(uri, "LibraryConnection", i, conn_uri);
      if rc > 0 then do;
        rc2= metadata_getnasn(conn_uri, "Domain", i, domainuri);
        if rc2 > 0 then rc3= metadata_getattr(domainuri, "Name", AuthDomain);
      end;
    end;

    /*** Get the path/database schema for this library ***/
    rc=metadata_getnasn(uri, "UsingPackages", 1, usingpkguri);
    if rc>0 then do;
      rc=metadata_resolve(usingpkguri,type,id);  
      if type='Directory' then 
        rc=metadata_getattr(usingpkguri, "DirectoryName", path_schema);
      else if type='DatabaseSchema' then 
        rc=metadata_getattr(usingpkguri, "Name", path_schema);
      else path_schema="unknown";
    end;

    /*** Get the tables associated with this library ***/
    /*** If DBMS, tables are associated with DatabaseSchema ***/
    if type='DatabaseSchema' then do;
      t=1;
      ntab=metadata_getnasn(usingpkguri, "Tables", t, tableuri);

      if ntab>0 then do t=1 to ntab;
        tableuri='';
        table='';
        ntab=metadata_getnasn(usingpkguri, "Tables", t, tableuri);
        tabrc= metadata_getattr(tableuri, "Name", table);
				table=upcase(table);
        output;
      end;
      else put 'Library ' libname ' has no tables registered';
    end;
    else if type in ('Directory','SASLibrary') then do;
      t=1;
      ntab=metadata_getnasn(uri, "Tables", t, tableuri);
      if ntab>0 then do t=1 to ntab;
        tableuri='';
        table='';
        ntab=metadata_getnasn(uri, "Tables", t, tableuri);
        tabrc= metadata_getattr(tableuri, "Name", table);
				table = upcase(table);
        output;  
      end;
      else put 'Library ' libname ' has no tables registered'; 
    end;
  end;
  /***If there aren't any libraries, write a message to the log***/
  else put 'There are no libraries defined in this metadata repository.'; 
 run;

 /*Find full metadata paths for input objects*/
data &outds;
  set &syslast;
  length tree_path $500 tree_uri parent_uri parent_name $200;
  call missing(tree_path,tree_uri,parent_uri,parent_name);
  drop tree_uri parent_uri parent_name rc rc_tree;

  rc=metadata_getnasn(tableuri,"Trees",1,tree_uri);
  rc=metadata_getattr(tree_uri,"Name",tree_path);

  rc_tree=1;
  do while (rc_tree>0);
    rc_tree=metadata_getnasn(tree_uri,"ParentTree",1,parent_uri);
    if rc_tree>0 then do;
      rc=metadata_getattr(parent_uri,"Name",parent_name);
      tree_path=strip(parent_name)||'/'||strip(tree_path);
      tree_uri=parent_uri;
    end;
  end;
  tree_path='/'||strip(tree_path);
run;

%mend;

* Lägg in anrop till ny LASR-server här;
%get_metadata_library_tables(libref=VALIBLA ,outds=lasr);         * VA LASR Analytical Server;
%get_metadata_library_tables(libref=EPJLA ,outds=epj);            * EPJ LASR;
%get_metadata_library_tables(libref=FTVLA ,outds=ftv);            * FTV LASR;
%get_metadata_library_tables(libref=LRCLA ,outds=lrc);            * LRC LASR;
%get_metadata_library_tables(libref=LASRLIB ,outds=public);       * Public LASR;

* Hämtar alla LASR-tabeller som är inlästa i RAM-minnet.;
%macro get_RAMTables(lib=, lasr_ram=, lasr=, outds=);
proc contents data=&lib.._all_ out=&lasr_ram. (rename=(memname=table) keep=memname nobs) noprint;
run; 
proc sort data=&lasr_ram. nodupkey;
by table;
run;
proc sort data=&lasr. (keep=libname table tree_path);
by table;
run;
data &outds.;
label
  tree_path = "Katalog"  
  table = "Tabellnamn"
	Id = "Metadata-Id"
	libname = "LASR server"
	nobs = "Antal inlästa rader i RAM";

 merge 
	&lasr. (in=lasr)
	&lasr_ram. (in=lasr_ram);
 by table;
 if lasr;
run;
proc sort data=&outds.; by tree_path; run;


%mend;

%get_RAMTables(lib=VALIBLA,lasr_ram=lasr_ram, lasr=lasr, outds=ihop_lasr);
%get_RAMTables(lib=EPJLA,lasr_ram=epj_ram, lasr=epj, outds=ihop_epj);
%get_RAMTables(lib=FTVLA,lasr_ram=ftv_ram, lasr=ftv, outds=ihop_ftv);
%get_RAMTables(lib=LRCLA,lasr_ram=lrc_ram, lasr=lrc, outds=ihop_lrc);
%get_RAMTables(lib=LASRLIB,lasr_ram=public_ram, lasr=public, outds=ihop_public);


ods listing close;
ods tagsets.excelxp path="/tmp" file="tables.xls" style=styles.Plateau;
ods tagsets.ExcelXP options(sheet_name="Beslutsstöd LASR" autofit_height="yes" absolute_column_width="50,35,35");
proc print data = ihop_lasr label noobs;
variables tree_path table nobs;
run;
ods tagsets.ExcelXP options(sheet_name="FTV LASR" autofit_height="yes" absolute_column_width="50,35,35");
proc print data = ihop_ftv label noobs;
variables tree_path table nobs;
run;
ods tagsets.ExcelXP options(sheet_name="EPJ LASR" autofit_height="yes" absolute_column_width="50,35,35");
proc print data = ihop_epj label noobs;
variables tree_path table nobs;
run;
ods tagsets.ExcelXP options(sheet_name="LRC LASR" autofit_height="yes" absolute_column_width="50,35,35");
proc print data = ihop_lrc label noobs;
variables tree_path table nobs;
run;
ods tagsets.ExcelXP options(sheet_name="Public LASR" autofit_height="yes" absolute_column_width="50,35,35");
proc print data = ihop_public label noobs;
variables tree_path table nobs;
run;


ods tagsets.ExcelXP close; 
ods listing;

