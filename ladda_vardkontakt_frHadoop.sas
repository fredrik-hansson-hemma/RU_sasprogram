/** QUERY **/ 

%LET VDB_GRIDHOST=bst-apx-04.lul.se;
%LET VDB_GRIDINSTALLLOC=/opt/TKGrid;
options set=GRIDHOST="bst-apx-04.lul.se";
options set=GRIDINSTALLLOC="/opt/TKGrid";
options validvarname=any validmemname=extend;

LIBNAME HPS SASHDAT  PATH="/hps"  SERVER="bst-apx-04.lul.se"  INSTALL="/opt/TKGrid" ;

proc lasr port=10010
    data=HPS.VARDKONTAKT
    signer="http://bst-apx-04.lul.se:7980/SASLASRAuthorization"
    add noclass;
    performance host="bst-apx-04.lul.se";
run;
