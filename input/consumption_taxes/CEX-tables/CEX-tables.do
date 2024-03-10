*This do-file generates imports and cleans the CEX-tables into stata. The files that this do-file creates, is compatible with dofiles that create the taxes paid. 
* The income categories here need to be harmonized across years.

// clear all
// global Path "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\GitHub\Broad-and-Narrow"

//CEX tables 2005-2016
local years "05 06 10 11 15 16"
foreach year of local years {
clear

*Import, clean the CEX table and merge if there are higher income tables (years before 2015)

import excel "$Path/CEX-tables/Clean/CE20`year'_clean.xlsx", sheet("Sheet1") firstrow // "$Path\Consumption taxes\CEX-tables\Clean\CE20`year'_clean.xlsx", sheet("Sheet1") firstrow
rename Item category

capture drop if category=="$70,000 and more"

if `year' < 15 {
	
	save "$Path/CEX-tables/CEX_clean_20`year'_temp.dta", replace

	*Import and merge CEX table for higher income consumers (>$70,000)
	import excel "$Path/CEX-tables/Clean/CE20`year'hi_clean.xlsx", sheet("Sheet1") firstrow clear // "$Path\Consumption taxes\CEX-tables\Clean\CE20`year'hi_clean.xlsx", sheet("Sheet1") firstrow

	rename Item category
	drop if category=="Less than $70,000"
	drop if category=="Aggregate"
	drop if category=="$100,000 and more"
	
	append using "$Path/CEX-tables/CEX_clean_20`year'_temp.dta"
	erase "$Path/CEX-tables/CEX_clean_20`year'_temp.dta"
		
}	

replace category="All" if category=="Aggregate"
replace category="0-5" if category=="Less than $5,000"
replace category="5-10" if category=="$5,000 to $9,999"
replace category="10-15" if category=="$10,000 to $14,999 "
replace category="15-20" if category=="$15,000 to 19,999"
replace category="20-30" if category=="$20,000 to $29,999"
replace category="30-40" if category=="$30,000 to $39,999"
replace category="40-50" if category=="$40,000 to $49,999"
replace category="50-70" if category=="$50,000 to $69,999"
replace category="70-80" if category=="$70,000 to $79,999"
replace category="80-100" if category=="$80,000 to $99,999 "
replace category="100-120" if category=="$100,000 to $119,999"
replace category="100-150" if category=="$100,000 to $149,999"
replace category="120-150" if category=="$120,000 to $149,000"
replace category=">150" if category=="$150,000 and more"

capture gen order =.
replace order = 0 if category== "All"
replace order = 1 if category== "0-5"
replace order = 2 if category== "5-10"
replace order = 3  if category=="10-15"
replace order = 4 if category=="15-20"
replace order = 5 if category=="20-30"
replace order = 6  if category=="30-40"
replace order = 7 if category=="40-50"
replace order = 8 if category=="50-70"
replace order = 9  if category=="70-80"
replace order = 10 if category=="80-100"
replace order = 11 if category=="100-120"
replace order = 12 if category=="120-150"
replace order = 13 if category==">150"

if `year'==15 | `year'==16 {
replace category="0-15" if category =="Lessthan$15,000"
replace category="15-30" if category =="$15,000to$29,999"
replace category="30-40" if category =="$30,000to$39,999"
replace category="40-50" if category =="$40,000to$49,999"
replace category="50-70" if category =="$50,000to$69,999"
replace category="70-100" if category =="$70,000to$99,999"
replace category="100-150" if category =="$100,000to$149,999"
replace category="150-200" if category =="$150,000to$199,999"
replace category=">200" if category =="$200,000andmore"

replace order=1 if category =="0-15"
replace order=2 if category =="15-30"
replace order=3 if category =="30-40"
replace order=4 if category =="40-50"
replace order=5 if category =="50-70"
replace order=6 if category =="70-100"
replace order=7 if category =="100-150"
replace order=8 if category =="150-200"
replace order=9 if category ==">200"
}


rename Numberofconsumerunitsintho consumers
sort order

if `year'==05 | `year'==06 {
	rename GE aggregateincomeaftertaxes
}
if `year'==10 {
	rename GF aggregateincomeaftertaxes
}
if `year'==11 {
	rename GD aggregateincomeaftertaxes
}
if `year'==15 | `year'==16	 {
	rename FX aggregateincomeaftertaxes
}

*Removing empty columns
if `year' <15 {
	drop D F J Q S W AC AG AK AQ AS AU BH BV BY CA CG CK CU DG DR EC EF EL EQ ES EU EW EY FA FC FE FI FK FO FQ FS FU FY  
	if `year'==05 | `year'==06{
		drop GD
	}
	if `year'==10{
		drop GE
	}
}

if `year'==15 | `year'==16 {
	drop D F I K R T X AD AH AL AR AT AV BX BZ DE DP EC EI EQ ES EU EW EY FA FC FG FI FR FW
	rename Annualaggregateexpenditures Averageannualexpenditures
}

if `year'==10 | `year'==05 | `year'==06 {
	rename Publictransportation Publicandothertransportation // Fixing the name of one variable, for a correct match
}

save "$Path/CEX-tables/CEX_clean_20`year'.dta", replace // "$Path\Consumption taxes\CEX-tables\CEX_clean_20`year'.dta", replace
}
