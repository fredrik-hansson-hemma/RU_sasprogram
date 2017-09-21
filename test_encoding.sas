  * Test_encoding: Testar att skriva en fil med svenska tecken i namnet samt i innehållet;


 %macro test_encoding(path=,table=);
    %put Enter Test_encoding Path: &path Table: &table;

    %let filepath=/tmp/; * Sökväg till katalog på server där skript lagras.;


    filename textfile "&filepath.&table..sh"; * En skriptfil skapas med samma namn som tabellen som ska behörighetstyras.;

    data _null_;
      length commando $300.;
      file textfile encoding=utf8;
      put "åäö";
    run;

    * Sätter rättigheter på skriptet.;
    filename chmod pipe "chmod 777 &filepath.&table..sh";

    data _null_;
      infile chmod;
    run;

    %put Exit Test_encoding;
  %mend;

  * Exempel på anrop;
  %test_encoding(PATH=/LUL/Data/Personal/,TABLE=LUL_Medellön_PNR);