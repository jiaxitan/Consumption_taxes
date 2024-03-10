// global Path "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\GitHub\Broad-and-Narrow"
use "$Path\Consumption taxes\Excise taxes on goods\Gasoline\gasoline_taxes.dta", clear

use "$Path\Consumption taxes\Excise taxes on goods\Gasoline\gasprices.dta", clear


local year "10"
use "$Path\Consumption taxes\Sales taxes on goods\Clean\salestaxrates_goods`year'.dta", clear
sort jurisdiction

local year "10"
use "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\Broad and narrow\Workspace\Input\task4_20`year'.dta", clear
sort category

keep jurisdiction category gas_aftertax_20`year' Statepluslocalgeneralsalest after_sales_rate


collapse gas_aftertax_20`year', by(jurisdiction)
drop if gas_aftertax_20`year'==.

* HOW to calculate after- and pretax-rates
* aftertaxrate=pretaxrate * pretax price / (pretax price + excise tax)
* pretaxrate=aftertaxrate * (pretax price + excise tax) / pretax price 

// And then, the pretax rate is calculated as follows

gen gaspretaxrate=gas_aftertax_2010*()

tempfile sarolta
save "`sarolta'"

* So the difference is only for sales taxable states. Lets make sure I am using the same rates for all states.


// use "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\Broad and narrow\Workspace\Input\task4_2010.dta", clear
// sort category
//
// use "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\Broad and narrow\ToKnut\task 1-4\task2\2010 2011\gasoline\merged_new.dta", clear
// keep if jurisdiction=="Michigan"
//

// gas_linexc_2010 gas_aftertax_2010

// gen t= gas_linexc_2010*(gasprice_2010_cents/(gasprice_2010_cents+gasolineexcisetax2010))

//
// use "$Path\Consumption taxes\Excise taxes on goods\Gasoline\gas_pretaxrates.dta", clear
// keep if gasoline_salestaxable==1
//
// foreach var of varlist gasoline_pretaxrate05 gasoline_pretaxrate06 gasoline_pretaxrate10 gasoline_pretaxrate11 gasoline_pretaxrate15 gasoline_pretaxrate16{
// 	replace `var'=`var'*100
// }
//
// graph bar (asis) gasoline_pretaxrate05 gasoline_pretaxrate06 gasoline_pretaxrate10 gasoline_pretaxrate11 gasoline_pretaxrate15 gasoline_pretaxrate16, over(jurisdiction, sort(order) label(angle(vertical))) legend(/*label(1 "20`year'") label(2 "20`year2'")*/ position(1) bplacement(11)) ylabel(0(5)25) /*bar(1, fcolor(navy)) bar(2, fcolor(red))*/ ti("gasoline pretax rates (in %)") 
//


keep jurisdiction gasoline_salestaxable gasoline_pretaxrate`year' gasoline_price20`year' gasolineexcisetax20`year'

gen gas_aftertax_`year' = gasoline_pretaxrate`year'*(gasoline_price20`year'/(gasoline_price20`year'+gasolineexcisetax20`year'))

merge 1:1 jurisdiction using "`sarolta'", nogenerate

gen t=gas_aftertax_`year'-gas_aftertax_20`year'


merge 1:1 jurisdiction using "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\Broad and narrow\ToKnut\task 1-4\task2\2010 2011\gasoline\merged_new.dta", keepusing(gas_linexc_2010 gas_linexc_2011 gas_linexc_2015 gas_linexc_2016)

gen t=gasoline_pretaxrate10-gas_linexc_2010



gen gas_linexc_2011 = (gasolineexcisetax2011/gasprice_2011_cents) if gasoline_salestaxable==0

replace gas_linexc_2011=(salestax_2011+ (((1+salestax_2011)*salestax_2011)/gasprice_2011_cents)) if gasoline_salestaxable==1

gen gas_aftertax_2011 = gas_linexc_2011*(gasprice_2011_cents/(gasprice_2011_cents+gasolineexcisetax2011))



replace gasoline_pretaxrate`year'=salestax_sl+(1+salestax_sl`year')*gasolineexcisetax20`year'/ gasoline_price20`year' if gasoline_salestaxable==1
