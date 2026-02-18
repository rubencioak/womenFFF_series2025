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
