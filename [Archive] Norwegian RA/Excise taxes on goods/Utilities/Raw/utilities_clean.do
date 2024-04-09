*

*Import gross production of utilities companies (millions of dollars)
clear all
// global Path "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\GitHub\Broad-and-Narrow"
import excel "$Path/Excise taxes on goods/Utilities/Raw/BEA-BLS-industry-level-production-account-1987-2019_gross_output.xlsx", sheet("Sheet1") cellrange(A2:AH65) firstrow // "$Path\Consumption taxes\Excise taxes on goods\Utilities\Raw\BEA-BLS-industry-level-production-account-1987-2019.xlsx", sheet("Gross Output") cellrange(A2:BQ68) firstrow

keep if IndustryDescription=="Utilities"

// drop AI-BQ

drop IndustryDescription

xpose, clear varname

rename v1 prod_utilities

gen year=.
replace year=1986+_n

drop _varname

order year

tempfile aggregate
save "`aggregate'"

*OECD NIPA: Needed to calculate the share of production that was for household consumption (millions of dollars)
clear

import excel "$Path/Excise taxes on goods/Utilities/Raw/OECD NIPA.xlsx", sheet("OECD.Stat export") cellrange(A6:U72) firstrow // "$Path\Consumption taxes\Excise taxes on goods\Utilities\Raw\OECD NIPA.xlsx", sheet("OECD.Stat export") cellrange(A6:U72) firstrow

replace D=strtrim(D)

keep if inlist(D,"P31CP044: Water supply and miscellaneous services relating to the dwelling", "P31CP045: Electricity, gas and other fuels")

drop Year-E

xpose, clear varname

gen year=.
replace year=2004+_n

gen hhcons_utilities=v1+v2

drop v1-_varname

merge 1:1 year using "`aggregate'", nogenerate

save "$Path/Excise taxes on goods/Utilities/agg_prod_cons_utilities.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Utilities\agg_prod_cons_utilities.dta", replace


*Import housing and utilities expenditures for households, by state. 
clear
import excel  "$Path/Excise taxes on goods/Utilities/Raw/BEA_SAEXP1_Housing_utilities.xls", sheet("Sheet0") cellrange(A6:Z69) firstrow // "$Path\Consumption taxes\Excise taxes on goods\Utilities\Raw\BEA_SAEXP1_Housing_utilities.xls", sheet("Sheet0") cellrange(A6:Z69) firstrow

drop GeoFips

local x=0
local vars "C D E F G H I J K L M N O P Q R S T U V W X Y Z"
foreach var of local vars {
    local x=`x'+1
	local year=1996+`x'
    rename `var' PCE_`year'
}

rename GeoName jurisdiction
drop if jurisdiction==""
merge 1:1 jurisdiction using "$Path/Excise taxes on goods/Codes.dta", keepusing(State) // "$Path\Consumption taxes\Excise taxes on goods\Codes.dta", keepusing(State)
drop if _m==1
drop _m
order jurisdiction State

save "$Path/Excise taxes on goods/Utilities/hh_utilities_bystate.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Utilities\hh_utilities_bystate.dta", replace


