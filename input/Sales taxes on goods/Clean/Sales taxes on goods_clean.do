* Creates the "salestaxrates_goods`year'.dta", which include state and local sales tax rates.

// For years 2009-16
local years "09 10 11 15 16"

foreach year of local years{
import excel "$Path/Sales taxes on goods/Raw/salestaxstatelocal`year'.xlsx", sheet("Sheet1") firstrow clear // "$Path\Consumption taxes\Sales taxes on goods\Raw\salestaxstatelocal`year'.xlsx", sheet("Sheet1") firstrow clear

if `year'==09 |`year'==10 {
	rename A jurisdiction 
}
capture rename AvgLocalTaxRatea salestax_l
capture rename StateRate salestax_s
capture rename StateTaxRate salestax_s
capture rename State jurisdiction
capture rename AverageLocalRate1 salestax_l
capture rename Local salestax_l
capture rename Combined salestax_sl
capture rename CombinedRate salestax_sl
capture rename Total salestax_sl


if `year'==11 {
	rename jurisdiction Abbreviation_01
	merge 1:1 Abbreviation_01 using "$Path/Excise taxes on goods/Codes.dta", nogenerate keepusing(jurisdiction) // "$Path\Consumption taxes\Excise taxes on goods\Codes.dta", nogenerate keepusing(jurisdiction)
	drop Abbreviation_01
}

if `year'==09 {
	replace jurisdiction=regexr(jurisdiction, "[0-9]+", "")
}

capture replace jurisdiction="District of Columbia" if jurisdiction=="D.C." 
replace jurisdiction=substr(jurisdiction, 1, strlen(jurisdiction)-4) if regexm(jurisdiction, "\(")

keep jurisdiction salestax_s salestax_l salestax_sl

foreach var of varlist salestax_s salestax_l salestax_sl {
	replace `var' = "0" if inlist(`var', "none", "None") 
	replace `var' ="0" if regexm(`var',"n/a") // n/a only applies to local rate in D.C.
	destring `var', replace percent
}

gen year=20`year'

order jurisdiction year

save "$Path/Sales taxes on goods/Clean/salestaxrates_goods`year'.dta", replace // "$Path\Consumption taxes\Sales taxes on goods\Clean\salestaxrates_goods`year'.dta", replace
}

// for years 2005/06
local years "05 06"
foreach year of local years {
import excel "$Path/Sales taxes on goods/Raw/salestaxstate`year'.xlsx", sheet("Sheet1") firstrow clear // "$Path\Consumption taxes\Sales taxes on goods\Raw\salestaxstate`year'.xlsx", sheet("Sheet1") firstrow clear

// Using local sales tax rates from 2009, since this is the best publicly availiable information
merge 1:1 jurisdiction using "$Path/Sales taxes on goods/Clean/salestaxrates_goods09.dta", nogenerate keepusing(salestax_l) // "$Path\Consumption taxes\Sales taxes on goods\Clean\salestaxrates_goods09.dta", nogenerate keepusing(salestax_l)
rename generalsalestax salestax_s
replace salestax_s=salestax_s/100
gen year=20`year'

*Do we have to account for mandatory local tax rate addons?
// if `year'==05{
// 	replace salestax_s=salestax_s-0.0125 if jurisdiction=="California"
// 	replace salestax_s=salestax_s-0.01 if jurisdiction=="Virginia"
// }
//
// if `year'==06{
// 	replace salestax_s=salestax_s-0.01 if inlist(jurisdiction, "California"," Virginia")
// }

gen salestax_sl=salestax_s+salestax_l
save "$Path/Sales taxes on goods/Clean/salestaxrates_goods`year'.dta", replace // "$Path\Consumption taxes\Sales taxes on goods\Clean\salestaxrates_goods`year'.dta", replace
}
