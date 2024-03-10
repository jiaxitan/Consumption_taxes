// This file combines the tax rates of the cleaned folder with the CEX-files, and creates one dta.file with sales taxes on goods paid by income category and state.

clear all
//global Path "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\GitHub\Broad-and-Narrow"
global Salestax "$Path/Sales taxes on goods" // "$Path\Consumption taxes\Sales taxes on goods"

local years "05 06 10 11 15 16"

local svars "Foodawayfromhome Housekeepingsupplies Householdfurnishingsandequi Vehiclepurchasesnetoutlay Maintenanceandrepairs Feesandadmissions Petstoyshobbiesandplayg Otherlodging" // Sales taxable
// local xvars "Utilitiesfuelsandpublics Gasolineandmotoroil Tobaccoproductsandsmokingsu Alcoholicbeverages" // Excise taxable

foreach year of local years {
use "$Path/CEX-tables/CEX_clean_20`year'.dta", clear // "$Path\Consumption taxes\CEX-tables\CEX_clean_20`year'.dta", clear // Categories, 14 columns
cross using "$Salestax/Clean/salestaxrates_goods`year'" // "$Salestax\Clean\salestaxrates_goods`year'" // Tax rates by state, 50 columns 

capture drop Ageofreferenceperson Averagenumberinconsumerunit Persons Childrenunder18 Persons65andover Earners Vehicles Percentdistribution Sexofreferenceperson Male Female Housingtenure Homeowner Withmortgage Withoutmortgage Renter Raceofreferenceperson BlackorAfricanAmerican WhiteAsianandallotherra HispanicorLatinooriginofre HispanicorLatino NotHispanicorLatino Educationofreferenceperson Elementary18 Highschool912 College Neverattendedandother Atleastonevehicleownedorl

sort jurisdiction category
gen averageexpenditure=Averageannualexpenditures[_N]*Averageannualexpenditures/100*10^6/consumers/1000

foreach v of varlist `svars' {
	local w = substr("`v'", 1, 15) // This is just to get a shorter variable name
	capture gen share_`w'=.
	by jurisdiction: replace share_`w'=`v'[_N]*10^6/consumers/1000*`v'/100/averageexpenditure 
}

*Consumers are given in thousands
*Aggregate numbers are given in $ mill.
*Share_variables are given in $. // NO! NOT dollars but % -> that's why they get multiplied with averageexpenditure below

egen share_salestaxable=rowtotal(share_Foodawayfromhom share_Housekeepingsup share_Householdfurnis share_Vehiclepurchase share_Maintenanceandr share_Feesandadmissio share_Petstoyshobbies share_Otherlodging)

gen after_sales_rate=.
replace after_sales_rate=salestax_sl/(1+salestax_sl)

gen salestaxpaid=after_sales_rate*share_salestaxable*averageexpenditure

sort jurisdiction category
order category jurisdiction year salestaxpaid

save "$Path/Sales taxes on goods/salestax_goods`year'.dta", replace // "$Path\Consumption taxes\Sales taxes on goods\salestax_goods`year'.dta", replace
}

// 10.02.2022 - Here we append the files together. Note that the income categories 
// are not harmonized over the different years.

order after_sales_rate share_salestaxable Averageannualexpenditures

use "$Path/Sales taxes on goods/salestax_goods05.dta", clear  // "$Path\Consumption taxes\Sales taxes on goods\salestax_goods05.dta", clear 
keep category jurisdiction year salestaxpaid averageexpenditure

local years "06 10 11 15 16"
foreach year of local years {
    append using "$Path/Sales taxes on goods/salestax_goods`year'.dta", keep (category jurisdiction year salestaxpaid averageexpenditure) // "$Path\Consumption taxes\Sales taxes on goods\salestax_goods`year'.dta", keep (category jurisdiction year salestaxpaid averageexpenditure)
}
drop if category=="All"

rename salestaxpaid sales_goods_taxes_paid
rename jurisdiction statename
drop averageexpenditure

save "$Path/ASEC_MERGE_sales_goods_taxes_paid.dta", replace // "$Path\Consumption taxes\Sales taxes on goods\salestax_goods.dta", replace
