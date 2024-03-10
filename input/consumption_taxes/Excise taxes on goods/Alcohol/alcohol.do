*ALCOHOL TAXES PAID

*Calculate personal HH expenditures on alcohol (millions of dollars)

**CEX to get alcohol consumption
local years "05 06 10 11 15 16"
foreach y of local years {
use "$Path/CEX-tables/CEX_clean_20`y'.dta", clear // "$Path\Consumption taxes\CEX-tables\CEX_clean_20`y'.dta", clear
keep category consumers Alcoholicbeverages
cross using "$Path/Excise taxes on goods/Alcohol/Clean/alcohol_taxrates`y'.dta" // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Clean\alcohol_taxrates`y'.dta"
drop salestax_sl-fed_aftertaxrate_beer`y'
order jurisdiction category
sort jurisdiction category
gen state_alc_taxes_paid=.
tempvar alcspendingpercapita
gen alcspendingpercapita=.
by jurisdiction: replace alcspendingpercapita=Alcoholicbeverages[_N]*10^6*Alcoholicbeverages/100/(consumers*1000) if _n!=_N
by jurisdiction: replace alcspendingpercapita=Alcoholicbeverages[_N]*10^6/(consumers*1000) if _n==_N
sum alcspendingpercapita

by jurisdiction: replace state_alc_taxes_paid=alcspendingpercapita*state_aftertaxrate`y'

gen fed_alc_taxes_paid=.
by jurisdiction: replace fed_alc_taxes_paid=alcspendingpercapita*fed_aftertaxrate`y'
drop Alcoholicbeverages alcspendingpercapita
drop if category=="All"
gen year = 20`y'
save "$Path/Excise taxes on goods/Alcohol/alcohol_taxes_paid`y'.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\alcohol_taxes_paid`y'.dta", replace
}
*

local years "05 06 10 11 15 16"
foreach y of local years {

	if `y' == 05 {
		use "$Path/Excise taxes on goods/Alcohol/alcohol_taxes_paid`y'.dta", clear
	}
	else {
		append using "$Path/Excise taxes on goods/Alcohol/alcohol_taxes_paid`y'.dta"
	}
		
}
*

rename jurisdiction statename
keep statename year category state_alc_taxes_paid fed_alc_taxes_paid
save "$Path/ASEC_MERGE_alcohol_taxes_paid.dta", replace


