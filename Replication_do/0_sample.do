

** Stata 18
*  Analysis sample

use "${path}\R\build_firm\tufwfsal.dta", clear


** Generate useful variables 
* Set of dependent variables 0-1 whenever needed
foreach y in familybalance caring breastfeeding paidallow_family equality equal_opor_measures pref_sex antiharass overtime parttime training retire illness protect_gender_victims {

	replace `y' = 0 if `y' == 1 | `y'==.
	replace `y' = 1 if `y' == 2
}

* Unique item for harrasment/protection of gender victims
replace antiharass = 1 if protect_gender_victims == 1

estpost summarize familybalance caring breastfeeding paidallow_family equality equal_opor_measures pref_sex antiharass wvar working_yearlyhours overtime parttime holiday training retire illness
est store desc_all
esttab desc_all using "${path}/Results/tab_desc_items.tex", replace cells("mean(fmt(a3))") label nonum gaps f compress

* Aggregated policies
gen family = (familybalance == 1 | caring == 1 | breastfeeding == 1 | paidallow_family == 1)
gen female = (equality 	== 1 | equal_opor_measures 	== 1 | pref_sex == 1 | antiharass 		== 1)
gen neutral = (wvar 	== 1 | working_yearlyhours 	== 1 | overtime == 1 | holiday 			== 1 | ///
			   training	== 1 | retire				== 1 | illness 	== 1 | parttime	== 1)

* Key independent variable
gen WRep_linear= sumcnfemales/(sumcnfemales+sumcnmales) 

gen WRep = WRep_linear > 0 
label var WRep "WRep"

gen WRep_gr = WRep_linear == 1
replace WRep_gr = 2 if WRep_linear>0 & WRep_linear<=0.5
replace WRep_gr = 3 if WRep_linear>0 & WRep_linear>0.5
label var WRep_gr "WRep groups"
label define types_1  1 "No women" 2 "WRep $\in$ (0,0.5]" 3 "WRep $\in$ (0.5,1]" 
label values WRep_gr types_1


* Controls
gen bigfirm = size>50

gen firm_size_category = .
replace firm_size_category = 1 if size <= 25             
replace firm_size_category = 2 if size >  25  & size < 50 
replace firm_size_category = 3 if size >= 50  & size < 100
replace firm_size_category = 4 if size >= 100 & size < 250
replace firm_size_category = 5 if size >= 250

* Sex ratio in the firm 
gen Fsexratio_linear = sizew/(sizew+sizem)
gen women_majority = Fsexratio_linear>=0.5
gen Fsexratio_cat  = 0 if Fsexratio_linear ==0 
replace Fsexratio_cat = 1 if Fsexratio_linear>0 & Fsexratio_linear<0.5
replace Fsexratio_cat  = 2 if Fsexratio_linear>=0.5


* Who negotatiated the agreement 
gen neg_by = 0 if neg_other == 2
replace neg_by = 1 if neg_tu == 2
replace neg_by = 2 if neg_com == 2
replace neg_by = 0 if neg_by==.
drop neg_other neg_tu neg_com
label var neg_by "Who negotiated the agreement"
label define types_2  0 "Unidentified" 1 "Trade union" 2 "Working council"
label values neg_by types_2

* Private/Public ownership
replace firmown = 1 if firmown==3

* Adjust variables that need to be time-invariance
foreach y in firmprovince cnae4 firmown {
	bys firmid: egen mode=mode(`y'), maxmode
	replace `y'=mode
	drop mode
}

* Agreement date in year
gen year_sign  = yofd(dtsingca)
gen year_start  = yofd(dtstrval)
replace year_start = 2019 if year_start>2018

* Analysis sample 
keep if cnae4!=.
keep if year_sign!=. 
keep if year_start!=.
keep if year_sign>=2010 & year_sign<=2018
drop if year_start<2000
keep if firmprovince!=.
keep if firmid!=""
bys codca year_sign (dtsingca): keep if _n == 1
keep if size>=5
keep if sumcnfemales+sumcnmales>0
drop if sumcnmales>sizem
drop if sumcnfemales>sizew

* Numeric id for firms, allows interactions
egen group = group(firmid)
drop firmid 
gen firmid = group

*drop dt* group
drop group

qui logit WRep UGT CCOO OtherTU LAB ELA GTI CGT USO CIG i.Fsexratio_cat i.firm_size_cat firmown i.cnae4 i.firmprovince
predict phat, pr
replace phat = 1 if WRep==1 & phat==.
replace phat = 0 if WRep==0 & phat==.

gen ipw = cond(WRep==1,1/phat,1/(1-phat))
drop phat


gen cnace = "B0" if inrange(cnae4, 1, 53)
replace cnace = "C1" if inrange(cnae4, 55,111)
replace cnace = "C2" if inrange(cnae4, 112,124)
replace cnace = "C3" if inrange(cnae4, 125,128)
replace cnace = "C4" if inrange(cnae4, 130,178)
replace cnace = "C5" if inrange(cnae4, 179,179)
replace cnace = "C6" if inrange(cnae4, 180,212) 
replace cnace = "C7" if inrange(cnae4, 213,253)
replace cnace = "C8" if inrange(cnae4, 254,287)
replace cnace = "D0" if inrange(cnae4, 288,297)
replace cnace = "E0" if inrange(cnae4, 300,308)
replace cnace = "F0" if inrange(cnae4, 309,331)
replace cnace = "G1" if inrange(cnae4, 332,385)
replace cnace = "G2" if inrange(cnae4, 386,422)
replace cnace = "H1" if inrange(cnae4, 423,436)
replace cnace = "H2" if inrange(cnae4, 438,445)
replace cnace = "I0" if inrange(cnae4, 446,453)
replace cnace = "J0" if inrange(cnae4, 454,481)
replace cnace = "K0" if inrange(cnae4, 482,497)
replace cnace = "L0" if inrange(cnae4, 500,503)
replace cnace = "M0" if inrange(cnae4, 504,522)
replace cnace = "N0" if inrange(cnae4, 523,555)
replace cnace = "O0" if inrange(cnae4, 556,564)
replace cnace = "P0" if inrange(cnae4, 565,576)
replace cnace = "Q0" if inrange(cnae4, 577,590)
replace cnace = "R0" if inrange(cnae4, 591,606)
replace cnace = "S0" if inrange(cnae4, 607,629)

merge m:1 cnace using "${path}/Data\ESS.dta", nogen keepusing(hrscon)


save "${path}\Dta\sample.dta", replace



