2021-09-24
* lido:objectPublishedID: publishing date now is actual publishing date (better mapping), 
  but only if it is filled in which is rarely. Background is that M+ only has a publishing 
  date since RIA. So only records that have been published since then have a publishing 
  date. The new date has the form 2020-09-24. I am not sure how to treat records without
  publishing date.
  
* zml2lido reverted to file name; extra script checks linkChecker fills in correct URLs for
  linkResource