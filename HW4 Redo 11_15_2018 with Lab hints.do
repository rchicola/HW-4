

*********START Todd's UBER-ULTIMATE LAB HINTS 11.10.2018****************

*use "\\files\users\rchicola\Desktop\HW4.dta", clear
********PROBLEM 1 Immigration and Employment**************
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
*********END Todd's UBER-ULTIMATE LAB HINTS 11.10.2018****************

********Part (a)*********************
use ind.dta, clear
****Create Employed Indicator Variable
tab empstat
tab empstat, nolabel
gen Employed=1 if empstat==1
replace Employed=0 if empstat==2 | empstat==3
tab Employed

*(a.i)
reg Employed fb
*(a.ii)
reg Employed fb i.year
*(a.iii)

xtreg Employed fb , fe i(statefip)
*(a.iv)
xtreg Employed fb i.year, fe i(statefip)


********Part (b)*********************
*(b.i) Interpretation
*(b.ii) Interpretation
*(b.iii) Interpretation
*(b.iv) Interpretation


********Part (c)*********************

*(c.i)
reg Employed fb if age<30
*(c.ii)
reg Employed fb i.year if age<30
*(c.iii)

xtreg Employed fb if age<30, fe i(statefip) 
*(c.iv)
xtreg Employed fb i.year if age<30, fe i(statefip)

********Part (d)*********************

*(d.i) Interpretation
*(d.ii) Interpretation
*(d.iii) Interpretation
*(d.iv) Interpretation

********Part (e)*********************

*(e.i)
reg Employed fb if age>=30
*(e.ii)
reg Employed fb i.year if age>=30
*(e.iii)

xtreg Employed fb if age>=30, fe i(statefip)
*(e.iv)
xtreg Employed fb i.year if age>=30, fe i(statefip)

********Part (f)*********************

*(f.i) Interpretation
*(f.ii) Interpretation
*(f.iii) Interpretation
*(f.iv) Interpretation






*********START Todd's UBER-ULTIMATE LAB HINTS 11.15.2018****************
cd ../Desktop

**1 Create dataset on share foreign born (X)
use HW4.dta if year!=1980, clear
gen fb=(bpld>=15000)
gen nat=(bpld<15000)*perwt
collapse (rawsum) nat (mean) fb_share=fb [aw=perwt], by(statefip year)
save shares.dta, replace

**2 Lambda
use HW4.dta if year==1980 & bpld>=15000, clear
collapse (sum) imm=perwt, by(statefip)
sum imm
return list
gen lambda=imm/r(sum)
keep statefip lambda
**Checking
sum lambda
return list
save lambda.dta, replace

**3 
use HW4.dta if year!=1980 & bpld>=15000, clear
collapse (sum) Imm=perwt, by(year)
format %12.0fc Imm
list
save Year_counts.dta, replace

**4 Create a cleaned dataset of our individuals to run regressions (Y)
** AND MERGE with X
** and stuff for Z
use HW4.dta if year!=1980 & bpld<15000, clear

**merges with shares
merge m:1 statefip year using shares.dta
drop _merge

**merges with lambda
merge m:1 statefip using lambda.dta
drop _merge

**merges with total immigrants per year
merge m:1 year using Year_counts.dta
drop _merge

gen imm_hat=Imm *lambda
gen fb_share_hat=imm_hat/(imm_hat+nat)

*********END Todd's UBER-ULTIMATE LAB HINTS 11.15.2018****************

*****Things we did in lab directly in Stata Command line
/*

reg fb_share imm_hat, cluster(statefip)
reg fb_share imm_hat, cluster(year)
egen todd_obs=group(statefip year)
reg fb_share imm_hat, cluster(todd_obs)


collapse (mean) fb_share imm_hat, by(statefip year)
reg fb_share imm_hat, r

bysort statefip year: egen nat_will=sum(perwt)
count
corr nat*

reg nat nat_will

reg fb_share fb_share_hat
reg fb_share fb_share_hat, cluster(cluster_var)

*/
****************************************************************


********Part (g)*********************
*Repeat Table 1, this time using IV


****Create Employed Indicator Variable
tab empstat
tab empstat, nolabel
gen Employed=1 if empstat==1
replace Employed=0 if empstat==2 | empstat==3
tab Employed


*(g.i) Instead of (a.i) reg Employed fb
ivreg Employed (fb_share = fb_share_hat)
*(g.ii) Instead of (a.ii)reg Employed fb i.year
xi: ivreg Employed i.year (fb_share = fb_share_hat)
*(g.iii)Instead of (a.iii)xtset statefip  ; xtreg fb i.year , fe 
xtivreg Employed  (fb_share = fb_share_hat), fe i(statefip) 
*(g.iv) Instead of *(a.iv)reg Employed fb i.year i.state
xi: xtivreg Employed i.year (fb_share = fb_share_hat), fe i(statefip)


********Part (h)**********************
* Interpret regression. (relevancy, validity,and a local average treatment effects interpretation of your model. Also discuss
*bounding your estimates if the IV is not valid. 


**************PROBLEM 2**********************


**********Part 2.A*******************
*clear
*only individuals in 2016 in Nevada
*tab statefip
*tab statefip, nolabel
****statefip code is 32 for Nevada 63,363 obs
/*
use HW4.dta if year==2016 & statefip==32

**8Use probit command to see what we should get then build ML version

****Create Employed Indicator Variable
tab empstat
tab empstat, nolabel
gen Employed=1 if empstat==1
replace Employed=0 if empstat==2 | empstat==3
tab Employed

probit Employed age 

**Now ML Version using as a basis:


*********START Todd's UBER-ULTIMATE LAB HINTS 11.10.2018****************
********
/*
*********************
**Basic programs
*********************
capture program drop hello_there
program define hello_there
  args name

  if `2'==1 {
    dis "Hello `name'!"
  }

end

hello_there Todd 1

*********************
**Maximum likelihood
*********************

**Canned stuff
  sysuse auto.dta, clear
  reg price mpg
  
**A program to calculate the likelihood for a given beta vector
  capture program drop todds_reg_d0
  program define todds_reg_d0
    **Required arguments
   args todo b lnf
 **Variables that are created then deleted in the program
   tempvar xb sigma y l_i
 **Coding up your specific variables to calc the likelihood function
      mleval `xb'=`b', eq(1)
   mleval `sigma'=`b', eq(2)
   

  gen `y'=$ML_y1
  //dis `y'
  **Finding the likelihood at i
   gen `l_i'=(1/`sigma')*normalden((`y'-`xb')/`sigma')
 **Finding the sum of the log likelihood
   mlsum `lnf'=log(`l_i')
  
  end
  
  ml model d0 todds_reg_d0 (price=mpg weight trunk turn) /sigma
  ml max

*/
  
*********END Todd's UBER-ULTIMATE LAB HINTS 11.10.2018****************  
 /*
 **Now to create a program version for our ML
 **A program to calculate the likelihood for our AGE beta vector
capture program drop Randy_Reg_d0
program define Randy_Reg_d0
**Required arguments
args todo Beta lnF
**Variables that are created then deleted in the program
   tempvar XBeta Sigma y l_i
***Code specific variables  for liklihood Func.
	mleval `XBeta'=`Beta', eq(1)
  mleval `Sigma'=`Beta', 
  */
  /*
 **A program to calculate the likelihood for a given beta vector
  capture program drop todds_reg_d0
  program define todds_reg_d0
    **Required arguments
   args todo b lnf
 **Variables that are created then deleted in the program
   tempvar xb sigma y l_i
 **Coding up your specific variables to calc the likelihood function
      mleval `xb'=`b', eq(1)
   mleval `sigma'=`b', eq(2)
   

  gen `y'=$ML_y1
  //dis `y'
  **Finding the likelihood at i
   gen `l_i'=(1/`sigma')*normalden((`y'-`xb')/`sigma')
 **Finding the sum of the log likelihood
   mlsum `lnf'=log(`l_i')
  
  end 
  
    ml model d0 todds_reg_d0 (Employed= age ) /sigma
  ml max

  */
  */
  *********MLE

  drop if year!=2016
  drop if statefip!=32
  
  ***Program in ML
  capture program drop lfprobit
  
  program lfprobit
  args lnf xb
  local y "$ML_y1"
  quietly replace `lnf'=ln(normal(`xb')) if `y'==1
  quietly replace `lnf'=ln(1-normal(`xb')) if `y'==0
  end
  ml model lf lfprobit (Employed=age)
  ml maximize
  
  
  probit Employed age
  ***Part B
  
  
  
  
  
  ********Part C
  
  logit Employed age
  
  
  regress Employed age, robust
  
  predict Employed_hat, xb
  twoway scatter Employed_hat age
  