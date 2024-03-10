
** Created by Knut. Revised and inspected by Johannes Fleck, October 2022
** I think the codes below do some plausibility and robustness tests on the linearized alcohol tax rates

*  1. generates bar charts showing the linearized alcohol excise tax rates by state for license and control states
*  2. computes share of spirit consumption for license and control states (not 100% sure)
*  3. computes tax rates based on consumption (INCOMPLETE)

* 1. 

local years "05 06 10 11 15 16"
// local years "10"
foreach y of local years {
use "$Path/Consumption taxes/Excise taxes on goods/Alcohol/Clean/alcohol_taxrates`y'.dta", clear // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Clean\alcohol_taxrates`y'.dta", clear

// merge 1:1 jurisdiction using "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\Broad and narrow\ToKnut\task 1-4\task2\2010 2011\alcohol\alcohol_2010.dta", keepusing(alcohol_lintax_2010 alcohol_aftertax_2010) 

replace state_lintaxrate`y' = state_lintaxrate`y'*100
// replace aftertaxrate`y'= aftertaxrate`y'*100

// replace alcohol_lintax_2010 = alcohol_lintax_2010*100



// graph bar (asis) lintaxrate10 alcohol_lintax_2010, over(jurisdiction, sort(order) label(angle(vertical))) legend(label(1 "linearized 2010") label(2 "Sarolta") position(0) bplacement(2)) ylabel(0(5)25) bar(1, fcolor(navy)) bar(2, fcolor(red)) ti("State and local taxrates for alcohol (in %)") name(pretax1, replace) 


preserve
keep if Control=="Yes"
graph bar (asis) state_lintaxrate`y', over(jurisdiction, sort(order) label(angle(vertical))) legend(label(1 "linearized 20`y'") position(0) bplacement(2)) ylabel(0(5)25) bar(1, fcolor(navy)) bar(2, fcolor(red)) ti("Control states: taxrates for alcohol (in %)") name(pretax1, replace) 
graph export "$Path/Consumption taxes/Excise taxes on goods/Alcohol/Clean/control_states`y'.png", replace // graph export control_states`y'.png, replace
restore

preserve
keep if Control!="Yes"
graph bar (asis) state_lintaxrate`y', over(jurisdiction, sort(order) label(angle(vertical))) legend(label(1 "linearized 20`y'") position(0) bplacement(2)) ylabel(0(5)25) bar(1, fcolor(navy)) bar(2, fcolor(red)) ti("License states: taxrates for alcohol (in %)") name(pretax1, replace) 
graph export "$Path/Consumption taxes/Excise taxes on goods/Alcohol/Clean/licence_states`y'.png", replace // graph export licence_states`y'.png, replace
restore
}


local y "10"
use "$Path/Consumption taxes/Excise taxes on goods/Alcohol/Clean/alcohol_decomposition`y'.dta", clear // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Clean\alcohol_decomposition`y'.dta", clear

br if inlist(jurisdiction, "Tennessee", "North Carolina", "Utah")


* 2. 

// TAXES
local y "11"
use "$Path/Consumption taxes/Excise taxes on goods/Tax revenue/clean_20`y'.dta", clear // "$Path\Consumption taxes\Excise taxes on goods\Tax revenue\clean_20`y'.dta", clear

drop taxes_Motorfuel taxes_Publicutilities taxes_Tobaccoproducts Abbreviation_01
rename taxes_Liquorstorerevenue Liquorstorerevenue
rename taxes_Liquorstoreexpenditure Liquorstoreexpenditure
drop if jurisdiction=="United States"

gen netrevenue= Liquorstorerevenue-Liquorstoreexpenditure+taxes_Alcoholicbeverage

tempfile tax
save "`tax'"


//  Check alcohol consumption

import excel "$Path/Consumption taxes/Excise taxes on goods/Alcohol/Raw/nominal excise taxes for noncontrol states/spirits`y'.xlsx", sheet("Worksheet 1") firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Raw\nominal excise taxes for noncontrol states\spirits`y'.xlsx", sheet("Worksheet 1") firstrow clear
replace Jurisdiction= usubstr(Jurisdiction, 1, strpos(Jurisdiction, "(" )-2) 

rename Jurisdiction jurisdiction

tempfile s
save "`s'"

import excel "$Path/Consumption taxes/Excise taxes on goods/Alcohol/Raw/alcohol_consumption.xlsx", sheet("Sheet1") firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Raw\alcohol_consumption.xlsx", sheet("Sheet1") firstrow clear

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
// by year jurisdiction: replace beverage[4]= beverage[3]+beverage[2]+beverage[1]
destring gallons, replace
replace gallons=gallons[_n-3]+gallons[_n-2]+gallons[_n-1] if beverage==4

tostring beverage, replace
replace beverage = "Spirits" if beverage=="1"
replace beverage = "Wine" if beverage=="2"
replace beverage = "Beer" if beverage=="3"
replace beverage = "All" if beverage=="4"

keep if year==20`y'

replace gallons = gallons/1000000

gen spiritsshare=.
bysort jurisdiction: replace spiritsshare=gallons[1]/gallons[4]

keep if beverage=="All"

merge 1:1 jurisdiction using `tax'

merge 1:1 jurisdiction using `s', keepusing(Control) nogen

preserve
keep if Control=="Yes"
graph bar (asis) spiritsshare, over(jurisdiction, sort(order) label(angle(vertical))) legend(label(1 "gallons")  position(0) bplacement(2)) ylabel(0(0.05)0.15) bar(1, fcolor(navy)) bar(2, fcolor(red)) ti("State and local taxrates for alcohol (in %)") name(pretax1, replace) 
graph export "$Path/Consumption taxes/Excise taxes on goods/Alcohol/Clean/spiritsshare_control_states10.png", replace // graph export spiritsshare_control_states10.png, replace
restore

preserve
keep if Control!="Yes"
graph bar (asis) spiritsshare, over(jurisdiction, sort(order) label(angle(vertical))) legend(label(1 "gallons")  position(0) bplacement(2)) ylabel(0(0.05)0.15) bar(1, fcolor(navy)) bar(2, fcolor(red)) ti("State and local taxrates for alcohol (in %)") name(pretax1, replace) 
graph export "$Path/Consumption taxes/Excise taxes on goods/Alcohol/Clean/spiritsshare_licence_states10.png", replace // graph export spiritsshare_licence_states10.png, replace
restore

	// graph bar (asis) gallons, over(beverage, sort(order) label(angle(vertical))) legend(label(1 "gallons")  position(0) bplacement(2)) ylabel(0(20)100) bar(1, fcolor(navy)) bar(2, fcolor(red)) ti("State and local taxrates for alcohol (in %)") name(pretax1, replace) CAUSES ERROR





* 3.

// line
local y "10"
import excel "$Path/Consumption taxes/Excise taxes on goods/Alcohol/Raw/alcohol_consumption.xlsx", sheet("Sheet1") firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Alcohol\Raw\alcohol_consumption.xlsx", sheet("Sheet1") firstrow clear

drop gallons_ethanol
drop if stateid>57 & stateid!=99
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
replace stateid = "United States" if stateid=="99"

rename stateid jurisdiction

sort year jurisdiction beverage
// by year jurisdiction: replace beverage[4]= beverage[3]+beverage[2]+beverage[1]
destring gallons, replace
replace gallons=gallons[_n-3]+gallons[_n-2]+gallons[_n-1] if beverage==4

tostring beverage, replace
replace beverage = "Spirits" if beverage=="1"
replace beverage = "Wine" if beverage=="2"
replace beverage = "Beer" if beverage=="3"
replace beverage = "All" if beverage=="4"

tempfile consumption
save "`consumption'"



use "$Path/Consumption taxes/Excise taxes on goods/Tax revenue/clean_20`y'.dta", clear // "$Path\Consumption taxes\Excise taxes on goods\Tax revenue\clean_20`y'.dta", clear

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
// keep jurisdiction alcohol_tax_ctrl 
tempfile controlstates
save "`controlstates'"

