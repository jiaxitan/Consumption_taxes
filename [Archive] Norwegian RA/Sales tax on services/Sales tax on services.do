*Import tax rates on services
clear
global Salestax "$Path/Sales tax on services" // "$Path\Consumption taxes\Sales tax on services"


*Importing tax rates for different services for different states.
import excel "$Salestax/Raw/2021.12.21 taxes by items.xlsx", sheet("Sheet2") firstrow // "$Salestax\Raw\2021.12.21 taxes by items.xlsx", sheet("Sheet2") firstrow

*Renaming the categories
* These categories are already taken care of: Naturalgas Electricity Fueloilandotherfuels Telephoneservices Waterandotherpublicservices
local var = "Foodathome Foodawayfromhome Maintenancerepairsinsurance Otherlodging Otherhouseholdexpenses Housekeepingsupplies Householdfurnishingsandequipm Apparelandservices Vehiclepurchasesnetoutlay Maintenanceandrepairs Vehiclerentalleaseslicenses Publicandothertransportation Feesandadmissions Audioandvisualequipmentands Petstoyshobbiesandplaygro Otherentertainmentsupplieseq Personalcareproductsandservi Reading Miscellaneous"

foreach v of varlist `var'{
	rename `v' t_`v'
}

save "$Salestax/tax_rates_services.dta", replace // "$Salestax\tax_rates_services.dta", replace


***Combining CEX with tax rates
local years "05 06 10 11 15 16"
foreach year of local years {
clear all
use "$Path/CEX-tables/CEX_clean_20`year'.dta", clear // "$Path\Consumption taxes\CEX-tables\CEX_clean_20`year'.dta", clear
cross using "$Salestax/tax_rates_services.dta" // "$Salestax\tax_rates_services.dta"

order category Item
rename Item state


*Generating variable equal to average annual expenditure per person, for point of reference
gen averagexpenditures=.
sort state categ
by state: replace averagexpenditures=Averageannualexpenditures[_N]*1000*Averageannualexpenditures/(100*consumers)

* These categories are already taken care of in the excise tax calculations: Naturalgas Electricity Fueloilandotherfuels Telephoneservices Waterandotherpublicservic 
local var "Foodathome Foodawayfromhome Maintenancerepairsinsura Otherlodging Otherhouseholdexpenses Housekeepingsupplies Householdfurnishingsandequi Apparelandservices Vehiclepurchasesnetoutlay Maintenanceandrepairs Vehiclerentalleaseslicen Publicandothertransportation Feesandadmissions Audioandvisualequipmentand Petstoyshobbiesandplayg Otherentertainmentsupplies Personalcareproductsandserv Reading Miscellaneous"

foreach v of varlist `var'{
	local w = substr("`v'", 1, 15) // This is just to get a shorter variable name
	capture gen taxes_`w'=.
	by state: replace taxes_`w'=`v'[_N]*10^6/consumers/1000*`v'/100*t_`v'/100
}
order averagexpenditures category state taxes_*

local var "taxes_Foodathome taxes_Foodawayfromhom taxes_Maintenancerepa taxes_Otherlodging taxes_Otherhouseholde taxes_Housekeepingsup taxes_Householdfurnis taxes_Apparelandservi taxes_Vehiclepurchase taxes_Maintenanceandr taxes_Vehiclerentalle taxes_Publicandothert taxes_Feesandadmissio taxes_Audioandvisuale taxes_Petstoyshobbies taxes_Otherentertainm taxes_Personalcarepro taxes_Reading taxes_Miscellaneous"

* Summing the taxes on services together
local w="0"
foreach v of varlist `var'{
	local w = "`w' + `v'"
}
capture gen taxes_paid_on_services=.
replace taxes_paid_on_services=`w'

gen year=20`year'

order category state year averagexpenditures taxes_paid_on_services taxes_*
rename state State
merge m:1 State using "$Path/Excise taxes on goods/Codes.dta", keepusing(jurisdiction) // "$Path\Consumption taxes\Excise taxes on goods\Codes.dta", keepusing(jurisdiction)
drop State
drop if category=="All"
order year jurisdiction category
save "$Salestax/taxes_services_20`year'.dta", replace // "$Salestax\taxes_services_20`year'.dta", replace
}
*

local years "05 06 10 11 15 16"
foreach y of local years {

	if `y' == 05 {
		use "$Salestax/taxes_services_20`y'.dta", clear
	}
	else {
		append using "$Salestax/taxes_services_20`y'.dta"
	}
		
}
*

rename jurisdiction statename
rename taxes_paid_on_services sales_services_taxes_paid
keep statename year category sales_services_taxes_paid
save "$Path/ASEC_MERGE_sales_services_taxes_paid.dta", replace

