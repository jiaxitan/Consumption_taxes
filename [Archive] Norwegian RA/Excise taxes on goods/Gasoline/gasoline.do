* This script combines excise taxes, gas prices and sales tax rates to estimate linearized tax rates per state. 
* It then uses the CE-tables to calculate the estimated gasoline taxes paid per household, by state and income category.
// global Path "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\GitHub\Broad-and-Narrow"
local years "05 06 10 11 15 16"
foreach year of local years {
use "$Path/Excise taxes on goods/Gasoline/Clean/gasprices.dta", clear // "$Path\Consumption taxes\Excise taxes on goods\Gasoline\Clean\gasprices.dta", clear

keep jurisdiction gasoline_price20`year'

merge 1:1 jurisdiction using "$Path/Excise taxes on goods/Gasoline/Clean/gasoline_taxes.dta", nogenerate keepusing(gasolineexcisetax20`year') // "$Path\Consumption taxes\Excise taxes on goods\Gasoline\Clean\gasoline_taxes.dta", nogenerate keepusing(gasolineexcisetax20`year')

merge 1:1 jurisdiction using "$Path/Sales taxes on goods/Clean/salestaxrates_goods`year'.dta", nogenerate keepusing(salestax_sl) // "$Path\Consumption taxes\Sales taxes on goods\Clean\salestaxrates_goods`year'.dta", nogenerate keepusing(salestax_sl)
rename salestax_sl salestax_sl`year'
*Convert from cent to dollar amount
replace gasolineexcisetax20`year'=gasolineexcisetax20`year'/100

gen gasoline_salestaxable=0
replace gasoline_salestaxable =1 if inlist(jurisdiction, "California", "Hawaii", "Illinois", "Indiana", "Michigan", "New York", "Florida", "Georgia", "West Virginia")

gen gasoline_pretaxrate`year'=.

* For non-salestaxable states
replace gasoline_pretaxrate`year'=(gasolineexcisetax20`year')/(gasoline_price20`year') if gasoline_salestaxable==0

* For salestaxable states
replace gasoline_pretaxrate`year'=salestax_sl+(1+salestax_sl`year')*gasolineexcisetax20`year'/ gasoline_price20`year' if gasoline_salestaxable==1

gen gasoline_aftertaxrate`year' = gasoline_pretaxrate`year'*(gasoline_price20`year'/(gasoline_price20`year'+gasolineexcisetax20`year'))

tempfile gasoline`year'
save "`gasoline`year''"
}


use "`gasoline05'", clear

local years "06 10 11 15 16"
foreach year of local years {
	merge 1:1 jurisdiction using "`gasoline`year''", nogenerate
}

save "$Path/Excise taxes on goods/Gasoline/gas_taxrates.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Gasoline\gas_taxrates.dta", replace

*Calculate personal HH expenditures on gasoline (millions of dollars)

**CEX to get gasoline consumption
local years "05 06 10 11 15 16"
foreach year of local years {
use "$Path/CEX-tables/CEX_clean_20`year'.dta", clear // "$Path\Consumption taxes\CEX-tables\CEX_clean_20`year'.dta", clear
keep category consumers Gasolineandmotoroil
cross using "$Path/Excise taxes on goods/Gasoline/gas_taxrates.dta" // "$Path\Consumption taxes\Excise taxes on goods\Gasoline\gas_taxrates.dta"

order jurisdiction category
sort jurisdiction category
capture gen gas_taxes_paid=.
by jurisdiction: replace gas_taxes_paid=Gasolineandmotoroil[_N]*10^6/consumers/1000*Gasolineandmotoroil/100*gasoline_aftertaxrate`year'
drop Gasolineandmotoroil
drop if category=="All"
gen year = 20`year'
save "$Path/Excise taxes on goods/Gasoline/gas_taxes_paid`year'.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Gasoline\gas_taxes_paid`year'.dta", replace
}
*

local years "05 06 10 11 15 16"
foreach y of local years {

	if `y' == 05 {
		use "$Path/Excise taxes on goods/Gasoline/gas_taxes_paid`y'.dta", clear
	}
	else {
		append using "$Path/Excise taxes on goods/Gasoline/gas_taxes_paid`y'.dta"
	}
		
}
*

rename jurisdiction statename
keep statename year category gas_taxes_paid
save "$Path/ASEC_MERGE_gas_taxes_paid.dta", replace
