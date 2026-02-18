*** Stata 18
**  Program sequence to replicate results of "Women's Representation, Bargaining, and Family-Friendly Firms"
*   Jose Garcia-Louzao and Ruben Perez-Sanz


clear all
capture log close
capture program drop _all
macro drop _all
set more 1
set seed 13
set cformat %5.4f
*set max_memory 32g
pause on

/*
* programs needed
ssc install ftools, replace
ssc install reghdfe, replace
ssc install outreg2, replace
ssc install outtable, replace
ssc install grstyle, replace
ssc install palettes, replace
ssc install colrspace, replace
ssc install addplot, replace
ssc install binscatterhist, replace
ssc install rf, replace
ssc install cem, replace
ssc install psacalc, replace
*/


** Set main directory
global path /*"{Replication_files}"*/ "C:\Users\\`c(username)'\Dropbox\Projects_Gender\06.CAandfirms\Work" // main directory here but recall one needs to have the sub-folders within the diretory, i.e., do_files, dta_files, cohorts_2018, tables, figures
global path "C:\Users\lenovo\Dropbox\PROJECTS\06.women_FFF\Work" // Uncomment to work in Ruben's computer

*global path "C:\Users\ruben.perezs\Dropbox\PROJECTS\06.women_FFF\Work" // Uncomment to work in Ruben's computer
cd "${path}"


** Routine
do "${path}\Do\0_sample.do"
do "${path}\Do\1_stats.do"	
do "${path}\Do\2_regression.do"
do "${path}\Do\2_regression_oster.do"
do "${path}\Do\2_regression_oster_het.do"
