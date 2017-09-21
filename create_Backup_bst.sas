/*********************************************
* Macro: create_Backup_bst.sas
* Skapar backup av SAS Metatdata genom att göra .spk paket.
* .Spk paket skapas av foldrarna User folders, Generella rapporter, LUL, Shared data.
*
* Av: Mattias Moliis
*********************************************/

%macro create_Backup_bst();
%put ENTER: create_Backup_bst;

%let filepath=/SASWORK/scripts/; * Sökväg till katalog på server där skript lagras.;
%let backuppath=/opt/sas/backup/; * Sökväg till katalog på server där backuperna lagras.;
%let datum = %sysfunc(putn(%sysfunc(today()), yymmdd6.)); * Datum som används i namnet på .spk paketen.;

*filename textfile "&filepath.backup.sh"; * En skriptfil skapas med samma namn som tabellen som ska behörighetstyras.; 

data _null_;
  * length commando $300.; 
  file "&filepath.backup.sh";
  * Sökväg där Export Package tool finns.;
  put "cd /opt/sas/sashome/SASPlatformObjectFramework/9.4"; 
  * Anropar Export Package Tool. - Allt under folder User Folders. Exkluderar tomma kataloger;
  put "./ExportPackage -host bst-apx-02.lul.se -port 8561 -user sasadm@saspw -password adm4SAS -package '&backuppath.UserFolders_&datum..spk' -objects '/User Folders' -types 'Folder,Report.BI' -includeDep -disableX11";
  * Folder Utveckling.;	
  put "./ExportPackage -host bst-apx-02.lul.se -port 8561 -user sasadm@saspw -password adm4SAS -package '&backuppath.Utveckling_&datum..spk' -objects '/Utveckling' -types 'Folder,Report.BI' -includeDep -disableX11";
  
	* Folder Acceptanstest.;	
  put "./ExportPackage -host bst-apx-02.lul.se -port 8561 -user sasadm@saspw -password adm4SAS -package '&backuppath.Acceptanstest_&datum..spk' -objects '/Acceptanstest' -types 'Folder,Report.BI' -includeDep -disableX11";
	
	* Folder Shared Data.;
	/*
  put "./ExportPackage -host bst-apx-02.lul.se -port 8561 -user sasadm@saspw -password adm4SAS  -disableX11 -package '&backuppath.SharedData_&datum..spk' -objects '/Shared Data' -types 'Folder,Report.BI' -includeDep";
	*/
run;

* Sätter rättigheter på skriptet.;
filename chmod pipe "chmod 777 &filepath.backup.sh";

data _null_;
  infile chmod;
run;

* Exekverar skriptet och skriver standard output till logfil.;
filename exec pipe ". &filepath.backup.sh >& &filepath.backup.log";

data _null_;
  infile exec;
run;

%put EXIT: create_Backup_bst;

%mend;

* Exempel på anrop;
%create_Backup_bst();

