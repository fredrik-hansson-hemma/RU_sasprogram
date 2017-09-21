/************************************************************
	Author  Adam Bullock
  13Dec2013
************************************************************/

options 
metaserver="bst-apx-20.lul.se" 
metaport=8561 
metauser="sasadm@saspw" 
metapass="gMu5eGrxR7ji";

data tcpip;
	keep name port host protocol service;

	length port host protocol objid service uri name $255;
  	nobj=0;
  	n=1;
    do while (nobj >= 0);
  		*nobj=metadata_getnobj("omsobj:TCPIPConnection?@Name='Connection URI' or @Name='External URI'",n,uri);
        nobj=metadata_getnobj("omsobj:TCPIPConnection?@Name='Connection URI'",n,uri);

		if (nobj >= 0) then do;
			rc=metadata_getattr(uri,"Name",name);
			if trim(name)='Connection URI' then name="Internal URI";

			rc=metadata_getattr(uri,"CommunicationProtocol",protocol);
			rc=metadata_getattr(uri,"HostName",host);
			rc=metadata_getattr(uri,"Port",port);
			rc=metadata_getattr(uri,"Service",service);
			put name protocol"://"host":"port service;
			output;
		end ;
		n = n + 1;
	end;	
run;

proc sort data=tcpip out=sorted;
	by service;
run;

proc print data=sorted;
	var service name port host protocol ;
	title  'Internal and External Connections (except SASThemes)';
	title2 'Listed by Service';
run;
