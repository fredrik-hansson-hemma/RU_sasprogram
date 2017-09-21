  /* Stoppa LASR-servrar. */

  %macro stoppaLASR(port=port);

	proc printto print='/tmp/procoutputLASR.lst';

  proc lasr stop PORT=&port
    signer="https://bst-apx-04.lul.se:8343/SASLASRAuthorization";
    performance host="bst-apx-04.lul.se";
  run;

	%mend;

  %stoppaLASR(port=10010); * LASR Acceptans;
	%stoppaLASR(port=10031); * Public LASR;
	%stoppaLASR(port=10011); * LASR Utveckling;
	%stoppaLASR(port=10012); * EPJ;
	%stoppaLASR(port=10029); * Admin LASR;
