option set=GRIDHOST="bs-ap-04.lul.se";
option set=GRIDINSTALLLOC="/opt/TKGrid";
ods listing close;

* LASR server prod;
proc lasr create PORT=10010
            path="/tmp"
            signer="http://bs-ap-04.lul.se:7980/SASLASRAuthorization"
            tablemem=80
            ;
            performance host="bs-ap-04.lul.se"
            install="/opt/TKGrid"
            nodes=all
            ;
run;

data _null_;
x=sleep(10000);
run;

%load_lasrfromhadoop(VATABLE=);



