option set=GRIDHOST="bs-ap-04.lul.se";
option set=GRIDINSTALLLOC="/opt/TKGrid";

* LASR server prod;
proc lasr create PORT=10010
            path="/tmp"
            signer="https://bs-ap-04.lul.se:8343/SASLASRAuthorization"
            tablemem=80
            ;
            performance host="bs-ap-04.lul.se"
            install="/opt/TKGrid"
            nodes=all
            ;
run;

* Public;
proc lasr create PORT=10031
            path="/tmp"
            signer="https://bs-ap-04.lul.se:8343/SASLASRAuthorization"
            tablemem=80
            ;
            performance host="bs-ap-04.lul.se"
            install="/opt/TKGrid"
            nodes=all
            ;
run;


option set=GRIDHOST="bs-ap-04.lul.se";
option set=GRIDINSTALLLOC="/opt/TKGrid";

* LASR server prod;
proc lasr term port=10010;
run;

* Public;
proc lasr term port=10031;
run;

libname LULDW odbc dsn=LULDW schema=va user="test" password="TeaterApa00";