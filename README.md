# womenFFF_series2025

Replication files - R

This is what each file does:

	- Analysis - Rmarkdown: Prior analysis to clean the CBA db at a firm level
	- Append: it appends the firm and sector databases for descriptive purposes
	- build_firm: it builds the main file that we work with
	- build_sector: it builds a db with two purposes
		- to be appended for descriptive purposes
		- to be merged with the priority db
	- build_sector_prior: 
		- it creates a db with sectoral agreements that should apply for each province-sector-date
		- it merges the db created with the one generated in sector_build to retrieve the share of women in negotiations at a sectoral level for IV.

Replication files - STATA

The full set of results can be obtained by running the masterfile.do program. This program includes the following sub-programs:
Results

    0_sample.do - create the analysis sample
    1_stats.do     - produces descriptive statistics included in the main text (Tables 1 and 2) as well as the online appendix
    2_regression.do               - estimates linear probability models by OLS, PSM, and FFE included in the main text (Table 3, Columns 1-3), as well as the robustness tests in the online appendix
    3_regression_oster.do     - estimates Oster approach (Table 3, Column 4)
    4_regression_oster_het.do - implements Oster approach for different levels of heterogeneity (Tables 4 and 5), and supplementary material in the online appendix.

Data access

The dataset has been provided by the Director of the Subdirección General de Estadística y Análisis Sociolaboral, Aránzazu González Rubio, in 2019. This dataset encompasses the digitized records of the "Registro y Deposito de Convenios Collectivos" extracted in 2019 (https://expinterweb.mites.gob.es/regcon/pub/consultaPublicaEstatal). Our dataset cannot be shared, but we welcome any attempt at replication. If you are interested, please contact us
