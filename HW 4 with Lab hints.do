use "\\files\users\rchicola\Desktop\HW4.dta", clear

*********LAB HINTS****************
**Setup 
  cd ..\Desktop

**Raw data saved as individual natives
  use HW4.dta if year!=1980, clear
  save ind.dta, replace
  
**Data on share foriegn born
  use HW4.dta, clear  
  gen fb=(bpld>=15000)
  collapse (mean) fb, by(statefip year)
  save shares.dta, replace
   
**Merge
  use ind.dta, clear
  sort statefip year
  merge m:1 statefip year using shares.dta
  drop if _merge!=3
  drop _merge
  save ind.dta, replace
************************************

*****Construct Instrument: 
  
 use HW4.dta if year==1980,clear
 gen Lambda=(bpld>=15000)
 sort statefip
 save Lambbda.dta
 
 ****Find Total Number of Immigrants and Natives in each State and Year.
 use HW4.dta
 ****Immigrants
 gen ImmShare=(bpld>=15000)
 gen Native=(bpld<15000)
 collapse (rawsum) Native ImmShare, by(statefip year)
 list
 tab ImmShare
 
 
 egen TotImmShare=sum(ImmShare), by (year)
 tab TotImmShare
 
 ****Do not need this for Native, only ImmShare (above)
 egen TotNative=sum(Native), by (year)
 tab TotNative
 ***For both egen gettin Freq. 51 (50 states and Puerto Rico?)
 tab year
 
 ***Merge with the Lambda Data
 use HW4.dta, clear
 sort statefip 
 merge m:1 statefip using Lambbda.dta
 *sort statefip year
 *merge m:1 statefip using Lambbda.dta
 *ERROR variable statefip does not uniquely identify observations in the using data
 drop if _merge!=3
 drop _merge
 save HW4.dta, replace
 
 
 
 
 
 
 
 
 
 
