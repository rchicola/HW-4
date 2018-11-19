
*Create ind.dta
use http://sorensen.coba.unr.edu/741/HW4.dta if year!=1980,clear

save ind.dta, replace

use http://sorensen.coba.unr.edu/741/HW4.dta if year!=1980,clear

*1 Create dataset on share foreign born (x)
gen fb=(bpld>=15000)
gen nat=(bpld<15000)*perwt
collapse (rawsum) nat (mean) fb_share=fb [aw=perwt], by (statefip year)
save shares.dta,replace



**2 Lambda
use http://sorensen.coba.unr.edu/741/HW4.dta if year==1980 & bpld>=15000,clear
collapse (sum) imm=perwt, by(statefip)

sum imm
return list
gen lambda =imm/r(sum)
keep statefip lambda
**Checking r(sum) close to 1
sum lambda
return list
save lambda.dta, replace


**3

use http://sorensen.coba.unr.edu/741/HW4.dta if year!=1980 & bpld>=15000,clear
collapse (sum) Imm=perwt, by (year)
format %12.0fc Imm
list
save Year_counts.dta, replace


** 4 Create a cleaned dataset of our individuals to run regressions (y)
** And merge with x
**and stuff for z

use http://sorensen.coba.unr.edu/741/HW4.dta if year!=1980 & bpld<15000,clear
**merges with shares
merge m:1 statefip year using shares.dta
drop _merge

**merges with lamba

merge m:1 statefip using lambda.dta
drop _merge

**merges with total immigrants per year
merge m:1 year using Year_counts.dta

gen imm_hat=Imm*lambda

gen fb_share_hat=imm_hat/(imm_hat+nat)


**create alternative share.dta
collapse (rawsum) nat (mean) fb_share_hat= fb_share [aw=perwt], by (statefip year)

save share.dta, replace

**merge with main data set ind

use ind.dta,clear

merge m:1 statefip year using shares.dta
drop _merge

**1.a generating dummy for an native born worker and being employed on the FB
gen natemp= 1 if empstat==1 & bpld < 15000
replace natemp=0 if natemp!=1
*a. OLS of natborn (natemp created above) and fb_share (shares.dta)
reg natemp fb_share
*OLS natemp and fb_share with time dummies
reg natemp fb_share i.year
*Using fixed effects with xtreg HELP!!!
xtreg natemp fb_share, fe i(statefip)
*Using fixed effects and time dummies
xtreg natemp fb_share i.year, fe i(statefip)

*b. ASK FOR INTERPRETATION HELP

*c. same analysis  using data only on native workers younger than 30
*Doing all regressions from above again but with condition

*OLS natemp and fb_share
reg natemp fb_share if age <30

*OLS natemp and fb_share with time dummies age <30
reg natemp fb_share i.year if age <30

*OLS natemp and fb_share statefip fe 
*Using if did not work will create new dataset for people under 30 HELP!!
gen natempU30=1 if natemp==1 & age <30
gen fb_share2=fb_share if age<30
xtreg natempU30 fb_share2, fe i(statefip)

*OLS natemp and fb_share statefip fe and time dummies WILL COME BACK TO PART C/E
xtreg natempU30 fb_share i.year, fe i(statefip)


*g. using IV merged with share.dta b/c has x_hat (fb_share_hat)
merge m:1 statefip year using share.dta
drop _merge

*natemp and fb_share_hat
reg natemp fb_share_hat

*natemp and fb_share_hat w/ time dummies
reg natemp fb_share_hat i.year

*natemp and fb_share_hat with fe
xtreg natemp fb_share_hat, fe i(statefip)

*natemp and fb_share_hat with fe and time dummies
xtreg natemp fb_share_hat i.year, fe i(statefip)

**2. Probits and Logits
use http://sorensen.coba.unr.edu/741/HW4.dta if year!=1980,clear

*a. 2016 Nevadans probit model in ML how age effects employment
gen employed=1 if empstat==1
replace employed=0 if employed!=1

*setting up regression
reg employed age if bpld==3200

*Using Todd's Stata_MLE_PDF program is created
capture program drop mylogit
program mylogit
args todo b lnf
tempvar xb lj
mleval ‘xb’ =‘b’, eq(1)
gen ‘lj’= exp(‘xb’)/(1+exp(‘xb’)) if $MLy1==0
replace ‘lj’=1/(1+exp(‘xb’)) if $MLy1==1
mlsum ‘lnf’=ln(‘lj’)
end





