global Path "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\GitHub\Broad-and-Narrow"
// use "$Path\Consumption taxes\Excise taxes on goods\Utilities\hh_utilities_bystate.dta", clear

use "$Path\Consumption taxes\Excise taxes on goods\Utilities\taxrates_utilities_05.dta", clear

use "$Path\Consumption taxes\Excise taxes on goods\Utilities\saroltas_utilities_rates\rates.dta", clear
sort  category jurisdiction


*utilities
clear all
// global Path "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\GitHub\Broad-and-Narrow"

local years "05 06 10 11 15 16"
// foreach year of local years{
*Calculate the share of utilities consumed by households
local year "05"
use "$Path\Consumption taxes\Excise taxes on goods\Utilities\agg_prod_cons_utilities.dta", clear
gen hh_share_utilities = hhcons_utilities/prod_utilities // This is the h^utilities in the appendix
keep if year==20`year'
keep year hh_share_utilities

*State and local tax revenue (thousands of dollars)
merge 1:m year using "$Path\Consumption taxes\Excise taxes on goods\Tax revenue\clean_20`year'.dta", nogenerate keepusing(jurisdiction State taxes_Publicutilities)

gen hh_taxes_utilities=hh_share_utilities*taxes_Publicutilities

tempfile utilities_taxes
save "`utilities_taxes'"

*Calculate personal HH expenditures on utilities (millions of dollars)

local year "05"
**CEX used to isolate the utilities component
keep if category=="All"
gen utilities_to_shelter= (Utilitiesfuelsandpublics-Telephoneservices)/(Shelter+Utilitiesfuelsandpublics-Telephoneservices)
use "$Path\Consumption taxes\CEX-tables\CEX_clean_20`year'.dta", clear
// gen utilities_to_shelter= (Utilitiesfuelsandpublics-Telephoneservices)/(Shelter)
keep utilities_to_shelter
gen year=20`year'

cross using "$Path\Consumption taxes\Excise taxes on goods\Utilities\hh_utilities_bystate.dta"

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
save "$Path\Consumption taxes\Excise taxes on goods\Utilities\taxrates_utilities_`year'.dta", replace

}



