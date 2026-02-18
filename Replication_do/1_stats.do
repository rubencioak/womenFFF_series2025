

** Stata 18
*  Descriptives
* set scheme stcolor


use "${path}\Dta\sample.dta", clear

** Distribution of women at the bargaining table
tw (hist sumcnfemales, frac w(1) bcolor(stred%21) lwidth(medium) lcolor(stred%%100) ) , xtitle("Women at the bargaining table") ytitle("Proportion of firm-level agreements")
graph export "${path}/Results/fig_dist_wrep_NB.pdf", replace

** Distribution of share of women among representatives 
tw (hist WRep_linear, frac w(0.05) bcolor(stred%21) lwidth(medium) lcolor(stred%%100) ) , xtitle("Share of women among representatives") ytitle("Proportion of firm-level agreements")
graph export "${path}/Results/fig_dist_wrep.pdf", replace

** Distribution of share of women in the workforce 
tw (hist Fsexratio_linear, frac w(0.05) bcolor(stred%21) lwidth(medium) lcolor(stred%%100) ) , xtitle("Share of women in the firm") ytitle("Proportion of firm-level agreements")
graph export "${path}/Results/fig_dist_fwomen.pdf", replace

** Distribution of share of women representatives among women in the firm
gen Wratio = sumcnfemales/sizew
replace Wratio = 0 if Wratio==.

tw (hist Wratio, frac w(0.05) bcolor(stred%21) lwidth(medium) lcolor(stred%%100) ) , xtitle("Women representatives over women in the firm") ytitle("Proportion of firm-level agreements")
graph export "${path}/Results/fig_dist_WrepFwomen.pdf", replace 

** Correlation between sex ratios
* unconditional
binscatterhist WRep_linear Fsexratio_linear, xtitle("Share of women in the firm") ytitle("Share of women among representatives") ylabel(0(0.2)1) xlabel(0(0.2)1) n(50) coefficient(0.001) mcolor(stred%34) lcolor(stblue) 
graph export "${path}/Results/fig_corr_sexratio.pdf", replace

* conditional on firm observables 
binscatterhist WRep_linear Fsexratio_linear, controls(i.firmprovince i.firmown size) absorb(cnae4) xtitle("Share of women in the firm") ytitle("Share of women among representatives") ylabel(0(0.2)1) xlabel(0(0.2)1) n(50) coefficient(0.001) mcolor(stred%34) lcolor(stblue) 
graph export "${path}/Results/fig_corr_sexratio_cond.pdf", replace



** Sample stats by group
gen madrid = firmprovince == 31
label var madrid "Madrid"
gen services = cnae4>=332
label var services "Service sector"
gen allsign = neg_sign == 2
label var allsign "Consensus among representatives"
gen private = firmown==2
label var private "Private firm"
gen sizetable = sumcnmales + sumcnfemales


estpost summarize size Fsexratio_linear private madrid services sizetable WRep_linear allsign  family female neutral
est store desc0

estpost summarize size Fsexratio_linear private madrid services sizetable WRep_linear allsign  family female neutral if WRep==0
est store desc1

estpost summarize size Fsexratio_linear private madrid services sizetable WRep_linear allsign family female neutral if WRep==1
est store desc2

esttab desc0 desc1 desc2 using "${path}/Results/tab_desc.tex", replace cells("mean(fmt(a3))") label nonum gaps f compress






estpost summarize size Fsexratio_linear private madrid services sizetable WRep_linear allsign family female neutral [aw=ipw] if WRep==0
est store desc1_w

estpost summarize size Fsexratio_linear private madrid services sizetable WRep_linear allsign family female neutral [aw=ipw] if WRep==1
est store desc2_w

esttab desc1_w desc2_w using "${path}/Results/tab_desc_IPW.tex", replace cells("mean(fmt(a3))") label nonum gaps f compress



local vars size Fsexratio_linear private madrid services sizetable WRep_linear allsign family female neutral

foreach var of local vars {
reg `var' WRep [aw=ipw]

}

** Descriptives variables by year
	
preserve
	use "${path}/Data/appendeddb.dta", replace
	
// 	drop if firmid==""
// 	keep if firmcity!="."
// 	keep if cnae4!=.
// 	keep if firmown!="." 
	drop if firmid=="" & level == "F"
	keep if (firmcity!="" & level == "F") | (level == "S")
	keep if cnae4!=.
	keep if (firmown!="" & level == "F") | (level == "S")
keep if size>=5
keep if sumcnfemales+sumcnmales>0
drop if sumcnmales>sizem
drop if sumcnfemales>sizew

	gen sumcn 	= sumcnmales + sumcnfemales
	gen wrep 	= sumcnfemales/sumcn
	gen wperc 	= sizew/size
	gen leveln = (level == "F")

	local varlist "familybalance caring breastfeeding  paidallow_family equality equal_opor_measures pref_sex antiharass overtime retire illness WC_participation training parttime"
	foreach y in `varlist'  {
		replace `y' = (`y' -1)*100
	}

	local varlist "wrep wperc wvar working_yearlyhours holiday"
	foreach y in `varlist'  {
		replace `y' = `y'*100
	}

	local varlist "wrep wperc familybalance caring breastfeeding  paidallow_family equality equal_opor_measures pref_sex antiharass wvar working_yearlyhours parttime overtime holiday training retire illness"

	* FIRM
	local numvars: word count `varlist'
	mat firm = J(9,`numvars',.)

	tabstat `varlist' if leveln == 1, by(year) format(%2.1f) save
	forvalues y =  1/9 {
		mat firm[`y',1] = r(Stat`y')
		local y2 = 2009 + `y'
		local rowyear = "`rowyear'" + "`y2' "
	}
	
	mat firm = firm\r(StatTotal)
	local rowyear = "`rowyear'" + "Total"
	mat colname firm = `varlist'
	mat rowname firm = `rowyear'
	mat list firm
	outtable using "${path}/Results/tab_yearvarfirm.tex", mat(firm) replace format(%9.1f)

	*SECTOR
	mat sector = J(9,`numvars',.)
	tabstat `varlist' if leveln == 0, by(year) format(%2.1f) save
	forvalues y =  1/9 {
		mat sector[`y',1] = r(Stat`y')
		local y2 = 2009 + `y'
		*local rowyear = "`rowyear'" + "`y2' "
	}
	mat sector = sector\r(StatTotal)
	*local rowyear = "`rowyear'" + "Total"
	mat colname sector = `varlist'
	mat rowname sector = `rowyear'
	mat list sector
	outtable using "${path}/Results/tab_yearvarsector.tex", mat(sector) replace format(%9.1f)
	
restore

** Graph of policies

preserve

	* Stack variables into long format
	gen varname = ""
	gen value = .

	tempfile base
	save `base', replace

	local varlist "family  familybalance caring breastfeeding paidallow_family"
	scalar counter = 1
	foreach v in `varlist' {
		use `base', clear
		keep idca `v'
		gen varname = "`v'"
		gen value = `v'
		keep idca varname value
		tempfile t_`v'
		save `t_`v'', replace
	}

	
	foreach v in `varlist' {
		if "`v'" == "WRep" {
			use `t_WRep', clear
		}
		else {
			append using `t_`v''
		}
		
	}
	*append using `t_var1' `t_var2' `t_var3'

	* Collapse
	collapse (mean) mean=value (semean) se=value, by(varname)
	gen ub = mean + invttail(_N-1, 0.025)*se
	gen lb = mean - invttail(_N-1, 0.025)*se
	
	* Encode the string variable 'varname' into a numeric variable with labels
	encode varname, gen(varnum)
	
	* CI
	twoway (bar mean varnum, barwidth(0.6) color(navy)) ///
       (rcap ub lb varnum, lcolor(black)), ///
       ytitle("Proportion") ///
       title("Proportion of 1s with 95% CI") ///
       xtitle("Variable") ///
       xlabel(1/14, valuelabel angle(45))
	graph export "${path}/Results/fig_policies_family.png", replace

restore

preserve

	* Stack variables into long format
	gen varname = ""
	gen value = .

	tempfile base
	save `base', replace

	local varlist "female equality equal_opor_measures pref_sex antiharass "
	scalar counter = 1
	foreach v in `varlist' {
		use `base', clear
		keep idca `v'
		gen varname = "`v'"
		gen value = `v'
		keep idca varname value
		tempfile t_`v'
		save `t_`v'', replace
	}

	
	foreach v in `varlist' {
		if "`v'" == "WRep" {
			use `t_WRep', clear
		}
		else {
			append using `t_`v''
		}
		
	}
	*append using `t_var1' `t_var2' `t_var3'

	* Collapse
	collapse (mean) mean=value (semean) se=value, by(varname)
	gen ub = mean + invttail(_N-1, 0.025)*se
	gen lb = mean - invttail(_N-1, 0.025)*se
	
	* Encode the string variable 'varname' into a numeric variable with labels
	encode varname, gen(varnum)
	
	* CI
	twoway (bar mean varnum, barwidth(0.6) color(navy)) ///
       (rcap ub lb varnum, lcolor(black)), ///
       ytitle("Proportion") ///
       title("Proportion of 1s with 95% CI") ///
       xtitle("Variable") ///
       xlabel(1/14, valuelabel angle(45))
	graph export "${path}/Results/fig_policies_female.png", replace

restore


preserve

	* Stack variables into long format
	gen varname = ""
	gen value = .

	tempfile base
	save `base', replace

	local varlist "neutral  wvar working_yearlyhours overtime holiday training retire illness WC_participation"
	scalar counter = 1
	foreach v in `varlist' {
		use `base', clear
		keep idca `v'
		gen varname = "`v'"
		gen value = `v'
		keep idca varname value
		tempfile t_`v'
		save `t_`v'', replace
	}

	
	foreach v in `varlist' {
		if "`v'" == "WRep" {
			use `t_WRep', clear
		}
		else {
			append using `t_`v''
		}
		
	}
	*append using `t_var1' `t_var2' `t_var3'

	* Collapse
	collapse (mean) mean=value (semean) se=value, by(varname)
	gen ub = mean + invttail(_N-1, 0.025)*se
	gen lb = mean - invttail(_N-1, 0.025)*se
	
	* Encode the string variable 'varname' into a numeric variable with labels
	encode varname, gen(varnum)
	
	* CI
	twoway (bar mean varnum, barwidth(0.6) color(navy)) ///
       (rcap ub lb varnum, lcolor(black)), ///
       ytitle("Proportion") ///
       title("Proportion of 1s with 95% CI") ///
       xtitle("Variable") ///
       xlabel(1/14, valuelabel angle(45))
	graph export "${path}/Results/fig_policies_other.png", replace

restore


** Duration of agreements
	gen dur = dtsingca - dtstrnego
	hist dur if inrange(dur,0,3652.5)
	graph export "${path}/Results/fig_hist_durca.png", replace
	


