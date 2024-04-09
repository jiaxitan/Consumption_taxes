*ALCOHOL PRICES

// Beer 2.25 gallons per case
* CPI alcoholic beverages
import excel "$Path/Excise taxes on goods/Alcohol/Raw/cpi_annual_alcoholic_beverages.xlsx", sheet("BLS Data Series") cellrange(A12:F30) firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Raw\cpi_annual_alcoholic_beverages.xlsx", sheet("BLS Data Series") cellrange(A12:F30) firstrow clear

drop C-F

tempfile cpi
save "`cpi'"

import excel "$Path/Excise taxes on goods/Alcohol/Raw/prices beer.xlsx", sheet("Sheet1") firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Raw\prices beer.xlsx", sheet("Sheet1") firstrow clear
tempfile alcohol
save "`alcohol'", replace

local years "05 06 10 11 15 16"
foreach y of local years{
	use `cpi', clear
	local t= 17 - `y'

	local p = Annual[14]/Annual[14-`t']
	use `alcohol', clear

	gen price_beergallon20`y'=price_beercase2017/`p'/2.25 // 2.25 gallons per case

	tempfile alcohol
	save "`alcohol'", replace
}
drop price_beercase2017
rename STATENAME jurisdiction

save "$Path/Excise taxes on goods/Alcohol/Clean/prices_beer.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Clean\prices_beer.dta", replace

set obs 52
replace jurisdiction="United States" if [_n]==52

foreach var of varlist price_beergallon2005-price_beergallon2016 {
	summarize `var'
	replace `var' = r(mean) if [_n]==52
}
keep if jurisdiction=="United States" 

tempfile fedbeerprices
save "`fedbeerprices'", replace


// Wine: 750 ml is equal to 0.198129 gallons
import excel "$Path/Excise taxes on goods/Alcohol/Raw/cpi_annual_alcoholic_beverages.xlsx", sheet("BLS Data Series") cellrange(A12:F30) firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Raw\cpi_annual_alcoholic_beverages.xlsx", sheet("BLS Data Series") cellrange(A12:F30) firstrow clear

drop C-F

tempfile cpi
save "`cpi'"

import excel "$Path/Excise taxes on goods/Alcohol/Raw/prices wine.xlsx", sheet("Sheet1") firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Raw\prices wine.xlsx", sheet("Sheet1") firstrow clear

rename B price_winebottle2020

tempfile alcohol
save "`alcohol'", replace

local years "05 06 10 11 15 16"
foreach y of local years{
	use `cpi', clear
	local t= 20 - `y'

	local p = Annual[17]/Annual[17-`t']
	use `alcohol', clear

	gen price_winegallon20`y'=price_winebottle2020/`p'/0.198129 // 0.198129 gallons per case

	tempfile alcohol
	save "`alcohol'", replace
}
drop price_winebottle2020
rename STATENAME jurisdiction

save "$Path/Excise taxes on goods/Alcohol/Clean/prices_wine.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Clean\prices_wine.dta", replace

set obs 52
replace jurisdiction="United States" if [_n]==52

foreach var of varlist price_winegallon2005-price_winegallon2016 {
	summarize `var'
	replace `var' = r(mean) if [_n]==52
}
keep if jurisdiction=="United States"
 
tempfile fedwineprices
save "`fedwineprices'", replace

// Spirits: 750 ml is equal to 0.198129 gallons

import excel "$Path/Excise taxes on goods/Alcohol/Raw/cpi_annual_alcoholic_beverages.xlsx", sheet("BLS Data Series") cellrange(A12:F30) firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Raw\cpi_annual_alcoholic_beverages.xlsx", sheet("BLS Data Series") cellrange(A12:F30) firstrow clear

drop C-F

tempfile cpi
save "`cpi'"

local p = Annual[15]/Annual[11]

import excel "$Path/Excise taxes on goods/Alcohol/Raw/prices spirits.xlsx", sheet("Sheet1") firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Raw\prices spirits.xlsx", sheet("Sheet1") firstrow clear

label var price_JD2014 "Jack Daniels"
label var price_S2018 "Smirnoff"
label var price_GG2018 "Grey Goose"

replace price_JD2014=price_JD2014*`p'
rename price_JD2014 price_JD2018

egen price_spiritsbottle2018=rowmean(price_S2018 price_GG2018)
replace price_spiritsbottle2018= price_JD2018 if price_spiritsbottle==.

drop price_JD2018 price_S2018 price_GG2018

tempfile alcohol
save "`alcohol'", replace


local years "05 06 10 11 15 16"
foreach y of local years{
	use `cpi', clear
	local t= 18 - `y'

	local p = Annual[15]/Annual[15-`t']
	use `alcohol', clear

	gen price_spiritsgallon20`y'=price_spiritsbottle2018/`p'/0.198129 // 0.198129 gallons per case

	tempfile alcohol
	save "`alcohol'", replace
}
drop price_spiritsbottle2018
rename STATENAME jurisdiction

save "$Path/Excise taxes on goods/Alcohol/Clean/prices_spirits.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Clean\prices_spirits.dta", replace

set obs 52
replace jurisdiction="United States" if [_n]==52

foreach var of varlist price_spiritsgallon2005-price_spiritsgallon2016 {
	summarize `var'
	replace `var' = r(mean) if [_n]==52
}
keep if jurisdiction=="United States" 

tempfile fedspiritsprices
save "`fedspiritsprices'", replace


*ALCOHOL CONSUMPTION
import excel "$Path/Excise taxes on goods/Alcohol/Raw/alcohol_consumption.xlsx", sheet("Sheet1") firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Raw\alcohol_consumption.xlsx", sheet("Sheet1") firstrow clear

drop gallons_ethanol
drop if stateid>57
tostring stateid, replace

replace stateid = "Alabama" if stateid=="1"
replace stateid = "Alabama" if stateid=="1"
replace stateid = "Alaska" if stateid=="2"
replace stateid = "Arizona" if stateid=="4"
replace stateid = "Arkansas" if stateid=="5"
replace stateid = "California" if stateid=="6"
replace stateid = "Colorado" if stateid=="8"
replace stateid = "Connecticut" if stateid=="9"
replace stateid = "Delaware" if stateid=="10"
replace stateid = "District of Columbia" if stateid=="11"
replace stateid = "Florida" if stateid=="12"
replace stateid = "Georgia" if stateid=="13"
replace stateid = "Hawaii" if stateid=="15"
replace stateid = "Idaho" if stateid=="16"
replace stateid = "Illinois" if stateid=="17"
replace stateid = "Indiana" if stateid=="18"
replace stateid = "Iowa" if stateid=="19"
replace stateid = "Kansas" if stateid=="20"
replace stateid = "Kentucky" if stateid=="21"
replace stateid = "Louisiana" if stateid=="22"
replace stateid = "Maine" if stateid=="23"
replace stateid = "Maryland" if stateid=="24"
replace stateid = "Massachusetts" if stateid=="25"
replace stateid = "Michigan" if stateid=="26"
replace stateid = "Minnesota" if stateid=="27"
replace stateid = "Mississippi" if stateid=="28"
replace stateid = "Missouri" if stateid=="29"
replace stateid = "Montana" if stateid=="30"
replace stateid = "Nebraska" if stateid=="31"
replace stateid = "Nevada" if stateid=="32"
replace stateid = "New Hampshire" if stateid=="33"
replace stateid = "New Jersey" if stateid=="34"
replace stateid = "New Mexico" if stateid=="35"
replace stateid = "New York" if stateid=="36"
replace stateid = "North Carolina" if stateid=="37"
replace stateid = "North Dakota" if stateid=="38"
replace stateid = "Ohio" if stateid=="39"
replace stateid = "Oklahoma" if stateid=="40"
replace stateid = "Oregon" if stateid=="41"
replace stateid = "Pennsylvania" if stateid=="42"
replace stateid = "Rhode Island" if stateid=="44"
replace stateid = "South Carolina" if stateid=="45"
replace stateid = "South Dakota" if stateid=="46"
replace stateid = "Tennessee" if stateid=="47"
replace stateid = "Texas" if stateid=="48"
replace stateid = "Utah" if stateid=="49"
replace stateid = "Vermont" if stateid=="50"
replace stateid = "Virginia" if stateid=="51"
replace stateid = "Washington" if stateid=="53"
replace stateid = "West Virginia" if stateid=="54"
replace stateid = "Wisconsin" if stateid=="55"
replace stateid = "Wyoming" if stateid=="56"

rename stateid jurisdiction

sort year jurisdiction beverage
destring gallons, replace
replace gallons=gallons[_n-3]+gallons[_n-2]+gallons[_n-1] if beverage==4

tostring beverage, replace
replace beverage = "Spirits" if beverage=="1"
replace beverage = "Wine" if beverage=="2"
replace beverage = "Beer" if beverage=="3"
replace beverage = "All" if beverage=="4"

tempfile consumption
save "`consumption'"

*EXCISE TAXES
local years "05 06 10 11 15 16"
foreach y of local years {

**EXCISE TAXES FOR CONTROL STATES
***State excise tax revenue(used for control states)

use "$Path/Excise taxes on goods/Tax revenue/clean_20`y'.dta", clear // "$Path\Consumption taxes\Excise taxes on goods\Tax revenue\clean_20`y'.dta", clear

drop taxes_Motorfuel taxes_Publicutilities taxes_Tobaccoproducts Abbreviation_01
rename taxes_Liquorstorerevenue Liquorstorerevenue
rename taxes_Liquorstoreexpenditure Liquorstoreexpenditure
drop if jurisdiction=="United States"

tempfile tax
save "`tax'"

use `consumption', clear
keep if year==20`y' & beverage=="All"
merge 1:1 jurisdiction using `tax', nogen

gen alcohol_tax_ctrl=(taxes_Alcoholicbeverage -Liquorstoreexpenditure + Liquorstorerevenue)/gallons*1000
keep jurisdiction alcohol_tax_ctrl 
tempfile controlstates
save "`controlstates'"

*EXCISE TAX FOR LICENCE STATES (used for non-control states)
**tax amount, by type of alcohol and year 
local alcohols "beer wine spirits"
foreach alc of local alcohols{
import excel "$Path/Excise taxes on goods/Alcohol/Raw/nominal excise taxes for noncontrol states/`alc'`y'.xlsx", sheet("Worksheet 1") firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Raw\nominal excise taxes for noncontrol states\\`alc'`y'.xlsx", sheet("Worksheet 1") firstrow clear

replace Jurisdiction = usubstr(Jurisdiction, 1, strpos(Jurisdiction, "(" )-2) 

drop I N 

rename AdValoremExciseTaxOnPremise on_whole_rate
rename F on_retail_rate
rename G on_no_salestax
rename H on_sales_rate
rename AdValoremExciseTaxOffPremis off_whole_rate
rename K off_retail_rate
rename L off_no_salestax
rename M off_sales_rate

local strvars "on_whole_rate on_retail_rate on_sales_rate off_whole_rate off_retail_rate off_sales_rate"

foreach var of local strvars {
	replace `var'= subinstr(`var', "$", "",2)
	replace `var'= subinstr(`var', "%", "",2)
	destring `var', replace
	replace `var'=`var'/100
}

local var "SpecificExciseTaxPerGallonf"
replace `var'= subinstr(`var', "$", "",2)
destring `var', replace


drop AdditionalTaxesfor CitationsCount Citations JurisNote RowNote
if "`alc'"!="spirits"{
		drop Control
	}
rename Jurisdiction jurisdiction

tempfile `alc'
save ``alc''
}

// FEDERAL EXCISE AMOUNT
preserve
use `beer', clear
keep if jurisdiction=="United States"
rename SpecificExciseTaxPerGallonf fedexbeer`y'

keep jurisdiction fedex
merge 1:1 jurisdiction using `wine', nogen keepusing(SpecificExciseTax) keep(match)
rename SpecificExciseTaxPerGallonf fedexwine`y'

merge 1:1 jurisdiction using `spirits', nogen keepusing(SpecificExciseTax) keep(match)
rename SpecificExciseTaxPerGallonf fedexspirits`y'
drop jurisdiction
tempfile fedex`y'
save `fedex`y''
restore

//Sales taxes on alcohol
merge 1:1 jurisdiction using "$Path/Sales taxes on goods/Clean/salestaxrates_goods`y'.dta", keepusing(salestax_sl) // "$Path\Consumption taxes\Sales taxes on goods\Clean\salestaxrates_goods`y'.dta", keepusing(salestax_sl)
drop if _m==1
drop _m

** Starting with the spirits, and treating states with controlled spirits sales as control states for all types of alcohol.
local alcohols "spirits wine beer"
foreach alc of local alcohols {
	if "`alc'"!="spirits"{ 
		merge 1:1 jurisdiction using "``alc''"
		drop if _m!=3
		drop _m
	}
local onoffvars "on_whole_rate off_whole_rate on_retail_rate off_retail_rate"
foreach var of local onoffvars {
	replace `var' = 0 if `var'==.
}

egen salestax`alc'`y'=rowmean(on_sales_rate off_sales_rate)
replace salestax`alc'`y'=0 if Control=="Yes" | on_no_salestax=="Yes" | off_no_salestax== "Yes"
replace salestax`alc'`y'=salestax_sl if salestax`alc'`y'==.

// Adv. excise tax 
egen advtaxrate`alc'`y'=rowmean(on_retail_rate off_retail_rate)

// Adv. excise tax 
egen advtaxrate_whole`alc'`y'=rowmean(on_whole_rate off_whole_rate)
replace advtaxrate_whole`alc'`y'=advtaxrate_whole`alc'`y'*0.6 // 40 pst. is a rough estimate of the markup.

// Excise taxes per gallon of alcohol
gen taxpergallon_`alc'`y'=SpecificExciseTaxPerGallonf
merge 1:1 jurisdiction using "`controlstates'", nogen
replace taxpergallon_`alc'`y'=alcohol_tax_ctrl if Control=="Yes"
	
//Total state adv. tax rate
gen totaladvrate_`alc'`y'=advtaxrate_whole`alc'`y' + advtaxrate`alc'`y' + salestax`alc'`y'
replace totaladvrate_`alc'`y'=0 if Control=="Yes"

*Add in the prices for the different kinds of alcohol
merge 1:1 jurisdiction using "$Path/Excise taxes on goods/Alcohol/Clean/prices_`alc'.dta", keepusing(price_`alc'gallon20`y') nogen // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Clean\prices_`alc'.dta", keepusing(price_`alc'gallon20`y') nogen

// Add the Federal excise tax rate
cross using `fedex`y''

*Creating the linearized rates
gen pretaxprice_`alc'`y'=.
replace pretaxprice_`alc'`y'=(price_`alc'gallon20`y'-taxpergallon_`alc'`y'-fedex`alc'`y')/(1+totaladvrate_`alc'`y')

gen state_lintaxrate_`alc'`y'=.
replace state_lintaxrate_`alc'`y'=taxpergallon_`alc'`y'/pretaxprice_`alc'`y'+totaladvrate_`alc'`y'

gen fed_lintaxrate_`alc'`y'=.
replace fed_lintaxrate_`alc'`y'=fedex`alc'`y'/pretaxprice_`alc'`y'

*Creating the aftertax rates
gen aftertaxrate_`alc'`y'=.
replace aftertaxrate_`alc'`y'=(state_lintaxrate_`alc'`y'+fed_lintaxrate_`alc'`y')/(1+(state_lintaxrate_`alc'`y'+fed_lintaxrate_`alc'`y'))

* The state share of the lintax rate should be the state share of the aftertax rate
gen state_aftertaxrate_`alc'`y'=state_lintaxrate_`alc'`y'/(state_lintaxrate_`alc'`y'+fed_lintaxrate_`alc'`y')*aftertaxrate_`alc'`y'

gen fed_aftertaxrate_`alc'`y'=fed_lintaxrate_`alc'`y'/(state_lintaxrate_`alc'`y'+fed_lintaxrate_`alc'`y')*aftertaxrate_`alc'`y'

save "$Path/Excise taxes on goods/Alcohol/Clean/alcohol_decomposition`y'.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Clean\alcohol_decomposition`y'.dta", replace
keep jurisdiction Control salestax_sl taxpergallon_* totaladvrate_* price_* fed_lintaxrate_* state_lintaxrate_* aftertaxrate_* state_aftertaxrate_* fed_aftertaxrate_*
}

egen state_lintaxrate`y'=rowmean(state_lintaxrate_beer`y' state_lintaxrate_wine`y' state_lintaxrate_spirits`y' )
egen state_aftertaxrate`y'=rowmean(state_aftertaxrate_beer`y' state_aftertaxrate_wine`y' state_aftertaxrate_spirits`y')
egen fed_aftertaxrate`y'=rowmean(fed_aftertaxrate_beer`y' fed_aftertaxrate_wine`y' fed_aftertaxrate_spirits`y')
save "$Path/Excise taxes on goods/Alcohol/Clean/alcohol_taxrates`y'.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Clean\alcohol_taxrates`y'.dta", replace
}
