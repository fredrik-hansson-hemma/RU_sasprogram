%macro column_definitions();
libname LULDW odbc dsn=LULDW schema=va user="test" password="TeaterApa00";
data meta_info;
	Length uri c_uri l_uri t_uri lib_uri sch_uri publicType $50
 	TableID $20
	LibraryID $20
	DatabaseSchemaID $20
	TableName $50
	TableDesc $100
	SASTableName $50
	ColumnID $20
	ColumnName $32
	ColumnDesc $100
	SASColumnLength $5
	SASColumnType $1
	SASFormat $20
	SASInformat $20
	;
	Keep
	TableID
	LibraryID
	DatabaseSchemaID
	TableName
	TableDesc
	SASTableName
	ColumnID
	ColumnName
	ColumnDesc
	SASColumnLength
	SASColumnType
	SASFormat
	SASInformat

	;
	NOBJ=1;
	N=1;
do while(nobj >= 0);
*LibraryID='';DatabaseSchemaID='';
nobj=metadata_getnobj("omsobj:PhysicalTable?@Id contains '.'",n,uri);
n=n+1;
index = metadata_getnasn(uri,"TablePackage",1,t_uri);
if nobj>0 and index>0 then do;
rc = metadata_getattr(uri, "ID", TableID);
rc = metadata_getattr(uri, "TableName", TableName);
rc = metadata_getattr(uri, "Desc", TableDesc);
rc = metadata_getattr(uri, "SASTableName", SASTableName);
rc = metadata_getattr(t_uri, "PublicType", PublicType);
if PublicType eq 'Library' then rc = metadata_getattr(t_uri, "ID", LibraryID);
else rc = metadata_getattr(t_uri, "ID", DatabaseSchemaID);
m=1;
mrc=1;
do while(mrc>0);
mrc = metadata_getnasn(uri,"Columns",m,c_uri);
rc = metadata_getattr(c_uri, "ID", ColumnID);
rc = metadata_getattr(c_uri, "Name", ColumnName);
rc = metadata_getattr(c_uri, "Desc", ColumnDesc);
rc = metadata_getattr(c_uri, "SASColumnLength", SASColumnLength);
rc = metadata_getattr(c_uri, "SASColumnType", SASColumnType);
rc = metadata_getattr(c_uri, "SASFormat", SASFormat);
rc = metadata_getattr(c_uri, "SASInformat", SASInformat);
m=m+1;
if mrc>0 then output;
end;
end;
end;
run;

proc sort data=meta_info;
	by ColumnName;
run;

*hämtar kolumndefinitionerna från look-up-tabell i datalagret;
data viewdef;
	set luldw.vw_viewlabels;
proc sort;
	by columnname;
run;

*mergar ihop båda dataseten på columnname, så att columnlabel läggs till på alla rader där columname finns i båda dataseten.
 ett Check-dataset skapas och dit sätts alla observationer som enligt viewlabels borde finnas i metadata, men som inte finns där;
data metainfo_new check;
	merge meta_info (in=a) viewdef (in=b);
	by columnname;
	if b and not a then output check;
	else output metainfo_new;
run;

*uppdaterar metadata med de kolumnetiketter (columnlabel) som hämtas från datalagret, om det är 
så att en kolumn inte har fått någon label på sig läggs kolumnnamnet som label;
data _null_;
	set metainfo_new;
	if missing(columnlabel) then do;
	RC=METADATA_SETATTR("omsobj:Column?@Id='"||COLUMNID||"'","Desc",columndesc);
	end;
	else do;
	RC=METADATA_SETATTR("omsobj:Column?@Id='"||COLUMNID||"'","Desc",columnlabel);
	end;
run;

%mend column_definitions;


%column_definitions;
