

%let tabell=flyplatser demo;
%let _ENCODING=UTF-8;
         options VALIDVARNAME=ANY VALIDMEMNAME=EXTEND;
         /* Status Checkpoint Macro */
         %macro statuscheckpoint(maxokstatus=4, varstocheck=SYSERR SYSLIBRC SYSDBRC );
         
        %GLOBAL LASTSTEPRC;
          %LET pos=1;
          %let var=notset;
          %let var=%SCAN(&varstocheck.,&pos.);
          %DO %WHILE ("&VAR." ne "");
             /* Retrieve the next return code to check */
       	  %if (%symexist(&VAR.)) %then %do;
       	     %let val=&&&VAR..;
       	     %if (("&VAL." ne "") and %eval(&VAL. > &maxokstatus.)) %then %do;
       		    %put FAIL = &VAR.=&VAL. / SYSCC=&SYSCC.;
                  %let LASTSTEPRC=&VAL.;
       		 %end;
       	  %end;
       	  %let pos = %eval(&pos.+1);
             %let var=%SCAN(&varstocheck.,&pos.);
          %END;
       %mend;



      %statuscheckpoint;
        /* Skip Next Step If We Have a Bad Status Code */
       %macro codeBody;
          %GLOBAL LASTSTEPRC;
          %if %symexist(LASTSTEPRC) %then %do;
             %if %eval(&LASTSTEPRC. <= 4) %then %do;
       
                /* Status Checkpoint Macro */
                %macro statuscheckpoint(maxokstatus=4, varstocheck=SYSERR SYSLIBRC SYSDBRC );
       
                   %GLOBAL LASTSTEPRC;
                   %LET pos=1;
                   %let var=notset;
                   %let var=%SCAN(&varstocheck.,&pos.);
                   %DO %WHILE ("&VAR." ne "");
                      /* Retrieve the next return code to check */
                	  %if (%symexist(&VAR.)) %then %do;
                	     %let val=&&&VAR..;
                	     %if (("&VAL." ne "") and %eval(&VAL. > &maxokstatus.)) %then %do;
                		    %put FAIL = &VAR.=&VAL. / SYSCC=&SYSCC.;
                           %let LASTSTEPRC=&VAL.;
                		 %end;
                	  %end;
                	  %let pos = %eval(&pos.+1);
                      %let var=%SCAN(&varstocheck.,&pos.);
                   %END;
                %mend;
                %macro deletedsifexists(lib,name);
                   %if %sysfunc(exist(&lib..&name.)) %then %do;
                         proc datasets library=&lib. nolist;
                         delete &name.;
                   quit;
                %end;
                %mend deletedsifexists;
       
                /* Reset SYSCC to SUCCESS to start */
                %LET SYSCC=0;
       
                /* Define the library containing the table to delete */
                libname hdat sashdat
                   host="bst-apx-04.lul.se"
                   install="/opt/TKGrid"
                   path="/hps"
                   ;
                %statuscheckpoint;
                /* Remove data table from Library */
                %deletedsifexists(hdat, &tabell);
                %statuscheckpoint;
             %end;
          %end;
       %mend;
       %codeBody;

%let _ENCODING=UTF-8;
options VALIDVARNAME=ANY VALIDMEMNAME=EXTEND;
/* Status Checkpoint Macro */
%macro statuscheckpoint(maxokstatus=4, varstocheck=SYSERR SYSLIBRC SYSDBRC );

   %GLOBAL LASTSTEPRC;
   %LET pos=1;
   %let var=notset;
   %let var=%SCAN(&varstocheck.,&pos.);
   %DO %WHILE ("&VAR." ne ""); 
      /* Retrieve the next return code to check */
	  %if (%symexist(&VAR.)) %then %do;
	     %let val=&&&VAR..;
	     %if (("&VAL." ne "") and %eval(&VAL. > &maxokstatus.)) %then %do;
		    %put FAIL = &VAR.=&VAL. / SYSCC=&SYSCC.;
           %let LASTSTEPRC=&VAL.;
		 %end;
	  %end;
	  %let pos = %eval(&pos.+1);
      %let var=%SCAN(&varstocheck.,&pos.);
   %END;
%mend;
%statuscheckpoint;
/* Skip Next Step If We Have a Bad Status Code */
%macro codeBody;
   %GLOBAL LASTSTEPRC;
   %if %symexist(LASTSTEPRC) %then %do;
      %if %eval(&LASTSTEPRC. <= 4) %then %do;
      
         /* Status Checkpoint Macro */
         %macro statuscheckpoint(maxokstatus=4, varstocheck=SYSERR SYSLIBRC SYSDBRC );
         
            %GLOBAL LASTSTEPRC;
            %LET pos=1;
            %let var=notset;
            %let var=%SCAN(&varstocheck.,&pos.);
            %DO %WHILE ("&VAR." ne ""); 
               /* Retrieve the next return code to check */
         	  %if (%symexist(&VAR.)) %then %do;
         	     %let val=&&&VAR..;
         	     %if (("&VAL." ne "") and %eval(&VAL. > &maxokstatus.)) %then %do;
         		    %put FAIL = &VAR.=&VAL. / SYSCC=&SYSCC.;
                    %let LASTSTEPRC=&VAL.;
         		 %end;
         	  %end;
         	  %let pos = %eval(&pos.+1);
               %let var=%SCAN(&varstocheck.,&pos.);
            %END;
         %mend;
         %macro deletedsifexists(lib,name);
            %if %sysfunc(exist("&lib..&name.")) %then %do;
                  proc datasets library=&lib. nolist;
                  delete "&name.";
            quit;
         %end;
         %mend deletedsifexists;
         
         /* Reset SYSCC to SUCCESS to start */
         %LET SYSCC=0;
         
         /* Define the library containing the table to delete */
         libname hdat sashdat
            host="bst-apx-04.lul.se"
            install="/opt/TKGrid"
            path="/hps"
            ;
         %statuscheckpoint;
         /* Remove data table from Library */
         %deletedsifexists(hdat, &tabell);
         %statuscheckpoint;
      %end;
   %end;
%mend;
%codeBody;

