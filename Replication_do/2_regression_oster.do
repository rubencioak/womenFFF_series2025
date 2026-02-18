

clear all
capture log close
capture program drop _all


global policies "family female neutral familybalance caring breastfeeding paidallow_family equality equal_opor_measures pref_sex antiharass wvar working_yearlyhours parttime overtime holiday training retire illness"

foreach y in $policies {

foreach i in `y' {
	
set seed 13
	
	
qui{
		
use "${path}\Dta\sample.dta", clear

global controls "year_sign#cnae4#firmprovince Fsexratio_cat firm_size_cat firmown proctype"
global controls_nohdfe "i.Fsexratio_cat i.firm_size_cat firmown proctype"


qui reghdfe `y' WRep , absorb($controls)  keepsing  cluster(cnae4#firmprovince)

local bols = _b[WRep]
local seols =_se[WRep] 


egen clus=group(cnae4 firmprovince)
egen cfe = group(year_sign cnae4 firmprovince)

** Degree of selection	
reghdfe `y' WRep , absorb($controls firmid) 
local b_fe = _b[WRep]
areg `y' WRep $controls_nohdfe , absorb(cfe)
gen rsq = 1.3*`e(r2)'
replace rsq = 1 if rsq>1
sum rsq 
local rsq = `r(mean)'
drop rsq 
psacalc delta WRep, beta(`b_fe') rmax(`rsq') 
local delta = `r(delta)'

reghdfe `y' WRep , absorb($controls firmid) keepsing
local rsq  = `e(r2)'
areg `y' WRep $controls_nohdfe , absorb(cfe)
psacalc beta WRep, delta(`delta') rmax(`rsq') 
  
gen B = `r(beta)'


qui {	
*WILD-BOOTSTRAP STARTS HERE

	reghdfe `y' WRep , absorb($controls)  keepsing  resid
	predict XB, xbd
	predict u, residuals
	
forvalues s= 1(1)100 {

preserve

*Sample residuals with Clustered Rademacher draws -- clustering the level of the regression!
bys cnae4 firmprovince: gen byte v = cond( runiform () <.5 ,1 , -1) if _n == 1
bys cnae4 firmprovince (v): replace v=v[1] if v==.

*CREATE SYNTHETIC DEPENDENT VARIABLE
gen ystar = XB + u*v
replace ystar = 1 if ystar > 1 & ystar<.
replace ystar = 0 if ystar < 0

** Degree of selection	
reghdfe ystar WRep , absorb($controls firmid) 
local b_fe = _b[WRep]
areg ystar WRep $controls_nohdfe , absorb(cfe)
gen rsq = 1.3*`e(r2)'
replace rsq = 1 if rsq>1
sum rsq 
local rsq = `r(mean)'
drop rsq 
psacalc delta WRep, beta(`b_fe') rmax(`rsq') 
local delta = `r(delta)'

reghdfe ystar WRep , absorb($controls firmid) keepsing
local rsq  = `e(r2)'
areg ystar WRep $controls_nohdfe , absorb(cfe)
psacalc beta WRep, delta(`delta') rmax(`rsq') 
  
gen B_boot = `r(beta)'

keep B*
keep if _n==1

* STORE 
tempfile bsample`s'
save `bsample`s''
restore
}
}

*APPEND ACROSS BOOTSTRAPPED REPLICATIONS
use `bsample1', clear
forvalues s =2(1)100 {
append using `bsample`s''
}

}

log using "${path}/Results/Oster_items_`i'.log", text replace

disp in red "OLS estimates Policy: `y'"

disp `bols'
disp `seols'
disp in red "Oster estimates Policy: `y'"
qui sum B
disp `r(mean)'
qui sum B_boot
disp `r(sd)'

log close 
}
}






