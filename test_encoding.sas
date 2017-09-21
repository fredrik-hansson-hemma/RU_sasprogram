  * Test_encoding: Testar att skriva en fil med svenska tecken i namnet samt i inneh�llet;


 %macro test_encoding(path=,table=);
    %put Enter Test_encoding Path: &path Table: &table;

    %let filepath=/tmp/; * S�kv�g till katalog p� server d�r skript lagras.;


    filename textfile "&filepath.&table..sh"; * En skriptfil skapas med samma namn som tabellen som ska beh�righetstyras.;

    data _null_;
      length commando $300.;
      file textfile encoding=utf8;
      put "���";
    run;

    * S�tter r�ttigheter p� skriptet.;
    filename chmod pipe "chmod 777 &filepath.&table..sh";

    data _null_;
      infile chmod;
    run;

    %put Exit Test_encoding;
  %mend;

  * Exempel p� anrop;
  %test_encoding(PATH=/LUL/Data/Personal/,TABLE=LUL_Medell�n_PNR);