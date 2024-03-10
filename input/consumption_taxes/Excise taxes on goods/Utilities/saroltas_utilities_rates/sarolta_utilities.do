
local years "06 10 11 15 16 05"

foreach year of local years{
// local year "11"
use "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\GitHub\Broad-and-Narrow\Input\task4_20`year'.dta", clear

keep jurisdiction category utilities_aftertax_
tempfile temp`year'
save "`temp`year''"
}


local years "06 10 11 15 16"

foreach year of local years{
	merge 1:1 category jurisdiction using "`temp`year''", nogenerate
}

save "$Path\Consumption taxes\Excise taxes on goods\Utillities\saroltas_utilities_rates\rates.dta", replace