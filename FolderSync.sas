/* Hämta beskrivning på alla foldrar. */
%mdsecgo(folder="/Acceptanstest/",
 includesubfolders=YES,
 memberfilter="",
 objdata=my_objects);


/* Tilldela ACT till folder. */
 sas-set-metadata-access -profile Admin /DemoBranch/DemoFolder
  -addACT testACT