// Cigarette sales
import excel "$Path/Excise taxes on goods/Tobacco/Raw/table10.xlsx", sheet("Sheet1") firstrow clear // "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\GitHub\Broad-and-Narrow\Consumption taxes\Excise taxes on goods\Tobacco\Raw\table10.xlsx", sheet("Sheet1") firstrow clear

foreach var of varlist year*{
	replace `var'=regexr(`var', ",", "")
}

destring year*, replace
rename A State
drop if State=="Total"

reshape long year, i(State)

rename year cig_sales
replace cig_sales=cig_sales*10^6
rename _j year

replace State="MI" if State=="Ml"

tempfile cigsales
save "`cigsales'"

//Estimated State General Sales Tax Collections on the Sale of Cigarettes
import excel "$Path/Excise taxes on goods/Tobacco/Raw/table16_jf.xlsx", sheet("Sheet1") firstrow clear // "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\GitHub\Broad-and-Narrow\Consumption taxes\Excise taxes on goods\Tobacco\Raw\table16.xlsx", sheet("Sheet1") firstrow clear
rename state State
foreach var of varlist year*{
	replace `var'=regexr(`var', ",", "")
	replace `var'=regexr(`var', ",", "")
}

foreach var of varlist year*{
	replace `var'="0" if regexm(`var', "–")
}

destring year*, replace

foreach var of varlist year*{ 				// throws type mismatch error -> handchanged table16.xlsx -> table16_jf.xlsx
	replace `var'=0 if `var'==.
}

drop if State=="Total"

replace State=regexr(State, "(\*)+", "")

reshape long year, i(State)

rename year cig_salestax_revenue
replace cig_salestax_revenue=cig_sales*10^3
rename _j year

merge 1:1 State year using "`cigsales'", nogenerate

replace State="HI" if State=="Hl"
replace State="RI" if State=="Rl"
replace State="WI" if State=="Wl"

merge m:1 State using "$Path/Excise taxes on goods/Codes.dta", keepusing(jurisdiction) nogenerate // "$Path\Consumption taxes\Excise taxes on goods\Codes.dta", keepusing(jurisdiction) nogenerate

drop State
order year jurisdiction

gen cig_salestax_pp= cig_salestax_revenue/cig_sales

tempfile cigsalestax
save "`cigsalestax'"

// Import dataset, including

// 1. Annual Gross Tax Revenue from Cigarettes (expressed as a dollar amount $)**
// 2. Average Cost Per Pack (expressed as a dollar amount $)
// 3. Cigarette Consumption (Pack Sales Per Capita)
// 4. Federal and State Tax as a Percentage of Retail Price (expressed as a percentage %)
// 5. Federal and State Tax Per Pack (expressed as a dollar amount $)
// 6. State Tax Per Pack (expressed as a dollar amount $)
 
* We will use 2, 4 and 5.

import delimited "$Path/Excise taxes on goods/Tobacco/Raw/The_Tax_Burden_on_Tobacco__1970-2019.csv", encoding(UTF-8) clear  // "$Path\Consumption taxes\Excise taxes on goods\Tobacco\Raw\The_Tax_Burden_on_Tobacco__1970-2019.csv", encoding(UTF-8) clear 

tab submeasuredesc

keep if inlist(year, 2005, 2006, 2010, 2011, 2015, 2016)
drop if submeasuredesc=="Federal and State tax as a Percentage of Retail Price"

replace submeasuredesc="v1" if submeasuredesc=="Average Cost per pack"
replace submeasuredesc="v2" if submeasuredesc=="Cigarette Consumption (Pack Sales Per Capita)"
replace submeasuredesc="v3" if submeasuredesc=="Federal and State Tax per pack"
replace submeasuredesc="v4" if submeasuredesc=="Gross Cigarette Tax Revenue"
replace submeasuredesc="v5" if submeasuredesc=="State Tax per pack"

drop geolocation source topictypeid topicid measureid submeasureid submeasureiddisplayorder data_value_type data_value_unit datasource topicdesc measuredesc

reshape wide data_value, i(locationabbr locationdesc year) j(submeasuredesc) string

rename locationdesc jurisdiction
rename data_valuev1 avg_cost_pp
rename data_valuev2 cig_pack_consumption_percapita
rename data_valuev3 fed_state_tax_pp
rename data_valuev4 gross_cig_tax_revenue
rename data_valuev5 state_tax_pp

merge 1:1 jurisdiction year using `cigsalestax', keepusing(cig_salestax_pp)

gen pretax_price_pp=avg_cost_pp-fed_state_tax_pp-cig_salestax_pp // avg. cost does not include sales tax

gen cig_pretax_staterate=(state_tax_pp+cig_salestax_pp)/pretax_price_pp
gen cig_pretax_fedrate=(fed_state_tax_pp-state_tax_pp)/pretax_price_pp
gen cigtax_stateshare=cig_pretax_staterate/(cig_pretax_staterate+cig_pretax_fedrate)

gen cig_aftertax_rate=(fed_state_tax_pp+cig_salestax_pp)/avg_cost_pp
gen cig_aftertax_staterate=cig_aftertax_rate*cigtax_stateshare
gen cig_aftertax_fedrate=cig_aftertax_rate*(1-cigtax_stateshare)

keep jurisdiction year cig_pretax_staterate cig_pretax_fedrate cigtax_stateshare cig_aftertax_rate cig_aftertax_staterate cig_aftertax_fedrate


*Set rates in 2015/16 = those in 2011 
sort jurisdiction year
foreach var of varlist cig_pretax_staterate-cig_aftertax_fedrate {
	replace `var'=`var'[_n-2] if year==2015
	replace `var'=`var'[_n-3] if year==2016
}

save "$Path/Excise taxes on goods/Tobacco/cig_taxrates.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Tobacco\cig_taxrates.dta", replace


local years "05 06 10 11 15 16"
foreach year of local years {
use "$Path/CEX-tables/CEX_clean_20`year'.dta", clear // "$Path\Consumption taxes\CEX-tables\CEX_clean_20`year'.dta", clear
keep category consumers Tobaccoproductsandsmokingsu
cross using "$Path/Excise taxes on goods/Tobacco/cig_taxrates.dta" // "$Path\Consumption taxes\Excise taxes on goods\Tobacco\cig_taxrates.dta"
keep if year==20`year'

order jurisdiction category
sort jurisdiction category
gen state_cig_taxes_paid=.
by jurisdiction: replace state_cig_taxes_paid=Tobaccoproductsandsmokingsu[_N]*10^6/consumers/1000*Tobaccoproductsandsmokingsu/100*cig_aftertax_staterate
gen fed_cig_taxes_paid=.
by jurisdiction: replace fed_cig_taxes_paid=Tobaccoproductsandsmokingsu[_N]*10^6/consumers/1000*Tobaccoproductsandsmokingsu/100*cig_aftertax_fedrate

keep year jurisdiction category consumers cig_aftertax_staterate cig_aftertax_fedrate cig_pretax_staterate cig_pretax_fedrate state_cig_taxes_paid fed_cig_taxes_paid
drop if category=="All"
save "$Path/Excise taxes on goods/Tobacco/cig_taxes_paid`year'.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Tobacco\cig_taxes_paid`year'.dta", replace
}
*

local years "05 06 10 11 15 16"
foreach y of local years {

	if `y' == 05 {
		use "$Path/Excise taxes on goods/Tobacco/cig_taxes_paid`y'.dta", clear
	}
	else {
		append using "$Path/Excise taxes on goods/Tobacco/cig_taxes_paid`y'.dta"
	}
		
}
*

rename jurisdiction statename
keep statename year category state_cig_taxes_paid fed_cig_taxes_paid
save "$Path/ASEC_MERGE_cig_taxes_paid.dta", replace
