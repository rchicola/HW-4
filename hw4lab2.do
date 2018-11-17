
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



merge m:1 statefip year using share.dta
drop _merge

**2. a 


