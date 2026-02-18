


clear all
capture log close
capture program drop _all



global policies "family female neutral"
*"familybalance caring breastfeeding paidallow_family equality equal_opor_measures pref_sex antiharass wvar working_yearlyhours parttime overtime holiday training retire illness"
global het "WRep_gr==3 firm_size_cat==1 hrscon==1"



foreach y in $policies  {
	
	
	
foreach i in `y' {
log using "${path}/Results/Oster_items_`i'_het.log", text append
log close 
foreach h in $het {
use "${path}\Dta\sample.dta", clear

global controls "year_sign#cnae4#firmprovince Fsexratio_cat firm_size_cat firmown proctype"
global controls_nohdfe "i.Fsexratio_cat i.firm_size_cat firmown proctype"

	gen WRep_1 = WRep == 1 
	gen WRep_2 = WRep == 1 & `h'

qui reghdfe `y' WRep_1 WRep_2 , absorb($controls)  keepsing  cluster(cnae4#firmprovince)

local b1_ols = _b[WRep_1]
local se1_ols =_se[WRep_1] 

local b2_ols = _b[WRep_2]
local se2_ols =_se[WRep_2]
 
qui {
	
	
	
egen clus=group(cnae4 firmprovince)
egen cfe = group(year_sign cnae4 firmprovince)


reghdfe `y' WRep WRep_2 , absorb($controls firmid) 
local b_fe = _b[WRep]
local b_fe2 = _b[WRep_2]
local rsq_fe = `e(r2)'
areg `y' WRep WRep_2 $controls_nohdfe , absorb(cfe)
gen rsq = 1.3*`e(r2)'
replace rsq = 1 if rsq>1
sum rsq 
local rsq = `r(mean)'
drop rsq 
psacalc delta WRep, beta(`b_fe') rmax(`rsq') 
local delta1 = `r(delta)'

psacalc delta WRep_2, beta(`b_fe2') rmax(`rsq') 
local delta2 = `r(delta)'

reghdfe `y' WRep WRep_2, absorb($controls firmid) keepsing
local rsq  = `e(r2)'
areg `y' WRep_1 WRep_2 $controls_nohdfe , absorb(cfe)
psacalc beta WRep_1, delta(`delta1') rmax(`rsq') 
gen B_1 = `r(beta)'	
	
areg `y' WRep_1 WRep_2 $controls_nohdfe , absorb(cfe)
psacalc beta WRep_2, delta(`delta2') rmax(`rsq') 
gen B_2 = `r(beta)'	

gen B_total = B_1 + B_2

}


quietly{
*WILD-BOOTSTRAP STARTS HERE

	reghdfe `y' WRep_1 WRep_2, absorb($controls)  keepsing  resid
	predict XB, xbd
	predict u, residuals
	
forvalues s= 1(1)100 {

preserve

*Sample residuals with Clustered Rademacher draws  -- clustering the level of the regression!
bys cnae4 firmprovince: gen byte v = cond( runiform () <.5 ,1 , -1) if _n == 1
bys cnae4 firmprovince (v): replace v=v[1] if v==.

*CREATE SYNTHETIC DEPENDENT VARIABLE
gen ystar = XB + u*v
replace ystar = 1 if ystar > 1 & ystar<.
replace ystar = 0 if ystar < 0

reghdfe ystar WRep WRep_2, absorb($controls firmid) 
local b_fe = _b[WRep]
local b_fe2 = _b[WRep_2]
local rsq_fe = `e(r2)'
areg ystar WRep WRep_2 $controls_nohdfe , absorb(cfe)
gen rsq = 1.3*`e(r2)'
replace rsq = 1 if rsq>1
sum rsq 
local rsq = `r(mean)'
drop rsq 

psacalc delta WRep, beta(`b_fe') rmax(`rsq') 
local delta1 = `r(delta)'

psacalc delta WRep_2, beta(`b_fe2') rmax(`rsq') 
local delta2 = `r(delta)'

*CREATE SYNTHETIC DEPENDENT VARIABLE
reghdfe ystar WRep WRep_2, absorb($controls firmid) keepsing
local rsq  = `e(r2)'


areg ystar WRep_1 WRep_2 $controls_nohdfe , absorb(cfe)
psacalc beta WRep_1, delta(`delta1') rmax(`rsq')  
gen B_boot_1 = `r(beta)'	
	

areg ystar WRep_1 WRep_2 $controls_nohdfe , absorb(cfe)
psacalc beta WRep_2, delta(`delta2') rmax(`rsq')   
gen B_boot_2 = `r(beta)'	


keep B*
keep if _n==1

* STORE 
tempfile bsample`s'
save `bsample`s''
restore
}

*APPEND ACROSS BOOTSTRAPPED REPLICATIONS
use `bsample1', clear
forvalues s =2(1)100 {
append using `bsample`s''
}
}


log using "${path}/Results/Oster_items_`i'_het.log", text append

disp in red "OLS estimates of policy: `y'; Het: `h'"

disp `b1_ols'
disp `se1_ols'
****
disp `b2_ols'
disp `se2_ols'
****


disp in red "Oster Estimates Policy: `y'; H: `h'"
qui sum B_1
disp `r(mean)'
qui sum B_boot_1
disp `r(sd)'
****
qui sum B_2
disp `r(mean)'
qui sum B_boot_2
disp `r(sd)'
*****

****
log close 




}


}
}
