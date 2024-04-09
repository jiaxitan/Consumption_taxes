*utilities
clear all
// global Path "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\GitHub\Broad-and-Narrow"

local years "05 06 10 11 15 16"
foreach year of local years{
*Calculate the share of utilities consumed by households
**Import national aggregate production and HH consumption data
use "$Path/Excise taxes on goods/Utilities/agg_prod_cons_utilities.dta", clear // "$Path\Consumption taxes\Excise taxes on goods\Utilities\agg_prod_cons_utilities.dta", clear
gen hh_share_utilities = hhcons_utilities/prod_utilities // This is the h^utilities in the appendix
keep if year==20`year'
keep year hh_share_utilities

*State and local tax revenue by state (thousands of dollars)
merge 1:m year using "$Path/Excise taxes on goods/Tax revenue/clean_20`year'.dta", nogenerate keepusing(jurisdiction State taxes_Publicutilities) // "$Path\Consumption taxes\Excise taxes on goods\Tax revenue\clean_20`year'.dta", nogenerate keepusing(jurisdiction State taxes_Publicutilities)

gen hh_taxes_utilities=hh_share_utilities*taxes_Publicutilities

tempfile utilities_taxes
save "`utilities_taxes'"

*Calculate personal HH expenditures on utilities (millions of dollars)

**CEX used to isolate the utilities component
use "$Path/CEX-tables/CEX_clean_20`year'.dta", clear // "$Path\Consumption taxes\CEX-tables\CEX_clean_20`year'.dta", clear
keep if category=="All"
gen utilities_to_shelter= (Utilitiesfuelsandpublics-Telephoneservices)/(Shelter+Utilitiesfuelsandpublics-Telephoneservices)
// gen utilities_to_shelter= (Utilitiesfuelsandpublics-Telephoneservices)/(Shelter)
keep utilities_to_shelter
gen year=20`year'

cross using "$Path/Excise taxes on goods/Utilities/hh_utilities_bystate.dta" // "$Path\Consumption taxes\Excise taxes on goods\Utilities\hh_utilities_bystate.dta"

keep utilities_to_shelter jurisdiction State PCE_20`year' year
order jurisdiction State year PCE_20`year' utilities_to_shelter

rename PCE_ PCE

*Now thousands of dollars
gen PCE_utilities= PCE*utilities_to_shelter*1000

merge 1:1 State using "`utilities_taxes'"

drop if _m==2
drop _m

gen aftertax_t_utilities=hh_taxes_utilities/PCE_utilities
gen pretax_t_utilities=hh_taxes_utilities/(PCE_utilities-hh_taxes_utilities)
save "$Path/Excise taxes on goods/Utilities/taxrates_utilities_`year'.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Utilities\taxrates_utilities_`year'.dta", replace
}

*UTILITIES TAXES PAID

*Calculate personal HH expenditures on utilities (millions of dollars)

**CEX to get utilities consumption
local years "05 06 10 11 15 16"
foreach y of local years {
// local y "10"
use "$Path/CEX-tables/CEX_clean_20`y'.dta", clear // "$Path\Consumption taxes\CEX-tables\CEX_clean_20`y'.dta", clear
keep category consumers Utilitiesfuelsandpublics Telephoneservices
cross using "$Path/Excise taxes on goods/Utilities/taxrates_utilities_`y'.dta" // "$Path\Consumption taxes\Excise taxes on goods\Utilities\taxrates_utilities_`y'.dta"

drop State PCE utilities_to_shelter PCE_utilities hh_share_utilities taxes_Publicutilities hh_taxes_utilities

order jurisdiction category year
sort jurisdiction category
gen utilitiesspendingpercapita=.
by jurisdiction: replace utilitiesspendingpercapita=Utilitiesfuelsandpublics[_N]*10^6*Utilitiesfuelsandpublics/100/(consumers*1000) if _n!=_N
by jurisdiction: replace utilitiesspendingpercapita=Utilitiesfuelsandpublics[_N]*10^6/(consumers*1000) if _n==_N

gen telephonespendingpercapita=.
by jurisdiction: replace telephonespendingpercapita=Telephoneservices[_N]*10^6*Telephoneservices/100/(consumers*1000) if _n!=_N
by jurisdiction: replace telephonespendingpercapita=Telephoneservices[_N]*10^6/(consumers*1000) if _n==_N

sum utilitiesspendingpercapita

replace utilitiesspendingpercapita=utilitiesspendingpercapita-telephonespendingpercapita

gen utilities_taxes_paid=.
by jurisdiction: replace utilities_taxes_paid=utilitiesspendingpercapita*aftertax_t_utilities

// gen fed_alc_taxes_paid`y'=.
// by jurisdiction: replace fed_alc_taxes_paid`y'=utilitiesspendingpercapita*fed_aftertaxrate`y'
drop Utilitiesfuelsandpublics Telephoneservices utilitiesspendingpercapita telephonespendingpercapita
drop if category=="All"
save "$Path/Excise taxes on goods/Utilities/utilities_taxes_paid`y'.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Utilities\utilities_taxes_paid`y'.dta", replace
}
*

local years "05 06 10 11 15 16"
foreach y of local years {

	if `y' == 05 {
		use "$Path/Excise taxes on goods/Utilities/utilities_taxes_paid`y'.dta", clear
	}
	else {
		append using "$Path/Excise taxes on goods/Utilities/utilities_taxes_paid`y'.dta"
	}
		
}
*

rename jurisdiction statename
keep statename year category utilities_taxes_paid
save "$Path/ASEC_MERGE_utilities_taxes_paid.dta", replace

