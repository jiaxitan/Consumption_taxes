
*Importing and cleaning state tax revenue. Original dollar amounts are in thousands.
clear all
// global Path "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\GitHub\Broad-and-Narrow"


	*** Reduce "Motor fuel", "Alcoholic beverage", "Tobacco products", "Public utilities" by collections from businesses
	**  Modified by Johannes Fleck, February 2024

	* Compute share of excise taxes paid by households to be merged in year loop
	import delimited "$Path/Excise taxes on goods/Tax revenue/Raw/CSLG_tax_collections_hh_business_pc.csv"

	gen tax_consumption_hh_share = tax_consumption_hh / tax_consumption_total
	keep year statename tax_consumption_hh_share
	rename statename jurisdiction

	save "$Path/Excise taxes on goods/Tax revenue/Raw/excise_tax_hh_share.dta", replace


*** Old code begins here


local years "05 06 10 11 15 16"
foreach year of local years{
clear

if `year'==05{
	local cellrange "A6:EA190"
	local sheetb "20`year' State & Local MO-WY"
	local sheeta "20`year' State & Local US-MS"
}

if `year'==06{
	local cellrange "A10:EA190"
	local sheetb "20`year' State & Local MO-WY"
	local sheeta "20`year' State & Local US-MS"
}

if `year'==10 | `year'==11 {
	local cellrange "A9:EA187"
	local sheetb "20`year'_MO_WY"
	local sheeta "20`year'_US_MS"
}

local xls "xls"

if `year'==15 | `year'==16{
	local cellrange "A10:EA187"
	local sheetb "20`year'_MO_WY"
	local sheeta "20`year'_US_MS"
	local xls "xlsx"
}


import excel "$Path/Excise taxes on goods/Tax revenue/Raw/`year'slsstab1b.`xls'", sheet(`sheetb') cellrange(`cellrange') firstrow // "$Path\Consumption taxes\Excise taxes on goods\Tax revenue\Raw\\`year'slsstab1b.`xls'", sheet(`sheetb') cellrange(`cellrange') firstrow

drop ? ??

replace Description=strtrim(Description)

keep if inlist(Description, "Motor fuel", "Alcoholic beverage", "Tobacco products", "Public utilities", "Liquor store revenue", "Liquor store expenditure")

tempfile b
save "`b'"
clear

import excel "$Path/Excise taxes on goods/Tax revenue/Raw/`year'slsstab1a.`xls'", sheet(`sheeta') cellrange(`cellrange') firstrow // "$Path\Consumption taxes\Excise taxes on goods\Tax revenue\Raw\\`year'slsstab1a.`xls'", sheet(`sheeta') cellrange(`cellrange') firstrow

drop ? ??

replace Description=strtrim(Description)
keep if inlist(Description, "Motor fuel", "Alcoholic beverage", "Tobacco products", "Public utilities", "Liquor store revenue", "Liquor store expenditure")

* Some imported cells are read as - instead of 0
replace Alaska="0" if Alaska=="-"
replace Arizona="0" if Arizona=="-"
replace Arkansas="0" if Arkansas=="-"
replace California="0" if California=="-"

merge 1:1 Description using "`b'", nogenerate

destring UnitedStatesTotal-Wyoming, replace

local obs=_N
forvalues x= 1/`obs' {
	local label`x' = Description[`x']
}
drop Description

xpose, clear varname

forvalues x=1/`obs'{
	local varlabel "`label`x''"
	local varlabel=subinstr("`varlabel'"," ","",.)
	rename v`x' taxes_`varlabel'
}

rename _varname jurisdiction_01
gen year=20`year'
merge 1:1 jurisdiction_01 using "$Path/Excise taxes on goods/Codes.dta", nogenerate // "$Path\Consumption taxes\Excise taxes on goods\Codes.dta", nogenerate
drop jurisdiction_01 E Abbreviation Code
replace jurisdiction="United States" if jurisdiction==""
order jurisdiction State year

	* modified code begins
	merge 1:1 jurisdiction year using "$Path/Excise taxes on goods/Tax revenue/Raw/excise_tax_hh_share.dta"
	replace taxes_Alcoholicbeverage = tax_consumption_hh_share * taxes_Alcoholicbeverage 
	replace taxes_Publicutilities   = tax_consumption_hh_share * taxes_Publicutilities
	replace taxes_Tobaccoproducts   = tax_consumption_hh_share * taxes_Tobaccoproducts
	replace taxes_Motorfuel         = tax_consumption_hh_share * taxes_Motorfuel
	drop tax_consumption_hh_share
	drop if _merge == 2
	drop _merge
	* modified code ends
	
save "$Path/Excise taxes on goods/Tax revenue/clean_20`year'.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Tax revenue\clean_20`year'.dta", replace
}
*

