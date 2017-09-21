  /* Starta LASR-servrar. */

  %macro startaLASR(port=port);

	  proc printto print='/tmp/procoutputLASR.lst';

    proc lasr create PORT=&port
      path="/SASWORK/signaturefiles"
      signer="https://bst-apx-04.lul.se:8343/SASLASRAuthorization"
      tablemem=80
    ;
      performance host="bst-apx-04.lul.se"
      install="/opt/TKGrid"
      nodes=ALL
    ;
    run;

	%mend;

  %startaLASR(port=10010); * LASR Acceptans;
	%startaLASR(port=10031); * Public LASR;
	%startaLASR(port=10011); * LASR Utveckling;
	%startaLASR(port=10012); * EPJ;
	%startaLASR(port=10029); * Admin LASR;
