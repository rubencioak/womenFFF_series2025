
clear all
capture log close
capture program drop _all



** Benchmark: OLS, IPW, FFE
global aggpolicies    "family female neutral"

foreach y in $aggpolicies {

foreach i in `y' {
log using "${path}/Results/OLS_IPW_FFE_items_`i'.log", text replace

use "${path}\Dta\sample.dta", clear

global controls "year_sign#cnae4#firmprovince Fsexratio_cat firm_size_cat firmown proctype"


qui {
	reghdfe `y' WRep , absorb($controls)  keepsing  cluster(cnae4#firmprovince)   //
	outreg2  using "${path}/Results/reg_policy_`y'.tex" , replace keep(WRep) ctitle(OLS) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
	estimates store OLS
	
	reghdfe `y' WRep  [aw=ipw], absorb($controls)  keepsing  cluster(cnae4#firmprovince)   //
	outreg2  using "${path}/Results/reg_policy_`y'.tex" , append keep(WRep) ctitle(IPW) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
	estimates store IPW
	
// 	cem  sizew Fsexratio_cat firm_size_cat cnae4 firmprovince year_start, treatment(WRep)
// 	reghdfe `y' WRep  if cem_matched==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   //
// 	outreg2  using "${path}/Results/reg_FAMpolicies_`y'.tex" , append keep(WRep) ctitle(Coarse) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
// 	estimates store CEM
	
	reghdfe `y' WRep , absorb($controls firmid)  keepsing  cluster(cnae4#firmprovince)   //
	outreg2  using "${path}/Results/reg_policy_`y'.tex" , append keep(WRep) ctitle(FFE) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
	estimates store FFE
	

}
disp in red "Policy: `y'"

esttab OLS IPW /*CEM*/ FFE, se parentheses
log close
}

}


/////////////////////////////////// ROBUSTNESS ////////////////////////////////
** Exact matching

use "${path}\Dta\sample.dta", clear


global controls "year_sign#cnae4#firmprovince Fsexratio_cat firm_size_cat firmown proctype"

cem   sizew Fsexratio_cat firm_size_cat  , treatment(WRep)

*Family friendly
	reghdfe family WRep if cem_matched==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   
outreg2  using "${path}/Results/reg_policies_exact_1.tex" , replace keep(WRep) ctitle(Family-friendly)  tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
*Female friendly 
	reghdfe female WRep  if cem_matched==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   //
outreg2 using "${path}/Results/reg_policies_exact_1.tex" , append keep(WRep ) ctitle(Gender-equality) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
*Neutral
	reghdfe neutral WRep  if cem_matched==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   //
outreg2  using "${path}/Results/reg_policies_exact_1.tex" , append keep(WRep ) ctitle(Gender-neutral) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)

drop cem_matched

cem  sizew Fsexratio_cat firm_size_cat cnae4, treatment(WRep)

*Family friendly
	reghdfe family WRep if cem_matched==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   
outreg2  using "${path}/Results/reg_policies_exact_2.tex" , replace keep(WRep) ctitle(Family-friendly)  tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
*Female friendly 
	reghdfe female WRep  if cem_matched==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   //
outreg2 using "${path}/Results/reg_policies_exact_2.tex" , append keep(WRep) ctitle(Gender-equality) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
*Neutral
	reghdfe neutral WRep  if cem_matched==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   //
outreg2  using "${path}/Results/reg_policies_exact_2.tex" , append keep(WRep) ctitle(Gender-neutral) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)

drop cem_matched
cem  sizew Fsexratio_cat firm_size_cat cnae4 firmprovince, treatment(WRep)

*Family friendly
	reghdfe family WRep if cem_matched==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   
outreg2  using "${path}/Results/reg_policies_exact_3.tex" , replace keep(WRep) ctitle(Family-friendly)  tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
*Female friendly 
	reghdfe female WRep  if cem_matched==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   //
outreg2 using "${path}/Results/reg_policies_exact_3.tex" , append keep(WRep) ctitle(Gender-equality) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
*Neutral
	reghdfe neutral WRep  if cem_matched==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   //
outreg2  using "${path}/Results/reg_policies_exact_3.tex" , append keep(WRep) ctitle(Gender-neutral) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)

drop cem_matched
cem  sizew Fsexratio_cat firm_size_cat cnae4 firmprovince year_start, treatment(WRep)

*Family friendly
	reghdfe family WRep if cem_matched==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   
outreg2  using "${path}/Results/reg_policies_exact_4.tex" , replace keep(WRep) ctitle(Family-friendly)  tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
*Female friendly 
	reghdfe female WRep  if cem_matched==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   //
outreg2 using "${path}/Results/reg_policies_exact_4.tex" , append keep(WRep) ctitle(Gender-equality) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
*Neutral
	reghdfe neutral WRep  if cem_matched==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   //
outreg2  using "${path}/Results/reg_policies_exact_4.tex" , append keep(WRep) ctitle(Gender-neutral) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)

drop cem_matched

gen topSR = Fsexratio_linear>0.5

cem sizew firm_size_cat cnae4 firmprovince year_start, treatment(WRep)

*Family friendly
	reghdfe family WRep if cem_matched==1 & topSR==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   
outreg2  using "${path}/Results/reg_policies_exact_5.tex" , replace keep(WRep) ctitle(Family-friendly)  tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
*Female friendly 
	reghdfe female WRep  if cem_matched==1 & topSR==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   //
outreg2 using "${path}/Results/reg_policies_exact_5.tex" , append keep(WRep) ctitle(Gender-equality) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
*Neutral
	reghdfe neutral WRep if cem_matched==1 & topSR==1, absorb($controls)  keepsing  cluster(cnae4#firmprovince)   //
outreg2  using "${path}/Results/reg_policies_exact_5.tex" , append keep(WRep) ctitle(Gender-neutral) tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)





use "${path}\Dta\sample.dta", clear

log using "${path}/Results/OLS_IPW_FFE_robust.log", text replace


global aggpolicies    "family female neutral"
global familypolicies "familybalance caring breastfeeding paidallow_family"
global genderpolicies "equality equal_opor_measures pref_sex antiharass"
global otherpolicies  "wvar working_yearlyhours parttime overtime holiday training retire illness"

foreach y in $aggpolicies $familypolicies $genderpolicies $otherpolicies {


use "${path}\Dta\sample.dta", clear


qui {

************************************ 
* Using year of start

reghdfe `y' WRep , absorb(year_start#cnae4#firmprovince Fsexratio_cat firm_size_cat firmown proctype)  keepsing  cluster(cnae4#firmprovince)

	estimates store START


* Using scope of the agreement but different agreements within

reghdfe `y' WRep , absorb(year_sign cnae4#firmprovince Fsexratio_cat firm_size_cat firmown proctype)  keepsing  cluster(cnae4#firmprovince) 

	estimates store CBA


* Using just three fixed effects for year sector province

reghdfe `y' WRep , absorb(year_sign cnae4 firmprovince Fsexratio_cat firm_size_cat firmown proctype)  keepsing  cluster(cnae4#firmprovince)   //

	estimates store THREE
}

disp in red "Policy: `y'"

esttab START CBA THREE, se parentheses
	
	
}

log close


////////////////////////////////////////////////////////////////////////////////




////////////////////////////////// individual items, OLS ///////////////////////



use "${path}\Dta\sample.dta", clear

global controls "year_sign#cnae4#firmprovince Fsexratio_cat firm_size_cat firmown proctype"

* Family-friendly items 

foreach y in familybalance caring breastfeeding paidallow_family {
	reghdfe `y' WRep , absorb($controls)  keepsing  cluster(cnae4#firmprovince) res(fam_`y'res)   //
	est store fam_`y' 
}
outreg2 [*] using "${path}/Results/reg_family.tex" , replace keep(WRep) ctitle(`y') tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
estimates clear

* Female-friendly items 
foreach y in equality equal_opor_measures pref_sex antiharass  {
	reghdfe `y' WRep , absorb($controls)  keepsing  cluster(cnae4#firmprovince) res(fem_`y'res)  //
	est store fem_`y' 
}
outreg2 [*] using "${path}/Results/reg_gender.tex" , replace keep(WRep) ctitle(`y') tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
estimates clear

* Gender-neutral items 
foreach y in  wvar working_yearlyhours parttime overtime holiday training retire illness  {
	reghdfe `y' WRep , absorb($controls)  keepsing  cluster(cnae4#firmprovince) res(neu_`y'res)  //
	est store neu_`y' 
}
outreg2 [*] using "${path}/Results/reg_other.tex" , replace keep(WRep) ctitle(`y') tex(frag) nocons dec(4)  nonotes label noaster //alpha(0.01, 0.05) symbol(***,**)
estimates clear


////////////////////////////////////////////////////////////////////////////////
