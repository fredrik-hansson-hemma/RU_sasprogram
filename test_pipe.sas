
filename listjob pipe "ls /opt/sas/config/Lev1/SASAppVA/SASEnvironment/SASCode/Jobs/";

data listjob;
length txt $256;
infile listjob;
input txt;
run;