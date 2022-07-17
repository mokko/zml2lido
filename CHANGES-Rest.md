# UTILITY CHANGES
This file documents changes to the utilities surrounding the main mapping 

7/17/22  clean up: better documentation, remove unused files etc.
7/3/22   include a saxon command line frontend
1/9/22   chunk mode (to process multiple chunks)
1/6/22   transition to flit packaging
10/28/21 move installation specific config to a separate file in sdata
10/26/21 outdir simplified; it's always relative to pwd now. One  command line param less.
10/21/21 new output dir
10/20/21 only checkLinks if output file doesn't exist yet (as usual) 
10/20/21 change java max memory
10/20/21 zml2lido: usual additions to objectMeasurements
9/25/21 introduce different chains: local and for SMB-Digital
9/24/21 linkchecker guesses URL for image on recherche.smb 
9/11/21 -f force should overwrite existing data in all steps, not just in zml2lido
9/11/21 implement simple filter that filters out zml records of type object that have no sachbegriff
