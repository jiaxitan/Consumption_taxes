*CPI for gas price 2011-2016
// global Path "C:\Users\knutwhe\OneDrive - Universitetet i Oslo\Documents\GitHub\Broad-and-Narrow"
import excel "$Path/Excise taxes on goods/Gasoline/Raw/Gasoline_cpi.xls", sheet("FRED Graph") cellrange(A11:B118) firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Gasoline\Raw\Gasoline_cpi.xls", sheet("FRED Graph") cellrange(A11:B118) firstrow clear

replace observation_date=year(observation_date)
format observation_date %ty
rename observation_date year
rename CUSR0000SETB01 cpi_gasoline

collapse (mean) cpi_gasoline, by(year)
gen cpi_gas_growth=cpi_gasoline[_n]/cpi_gasoline[_n-1]

tempfile gasprice
save "`gasprice'"

*Gas prices up to and including 2010. All prices are excluding taxes.

import excel "$Path/Excise taxes on goods/Gasoline/Raw/PET_SUM_MKT_A_EPM0_PTC_DPGAL_A.xlsx", sheet("Data 1") cellrange(A3:BI41) firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Gasoline\Raw\PET_SUM_MKT_A_EPM0_PTC_DPGAL_A.xlsx", sheet("Data 1") cellrange(A3:BI41) firstrow clear

replace Date=year(Date)
format Date %ty
rename Date year

* Replace missing values for DC with average of Maryland and Virginia
replace DistrictofColumbiaTotalGasol= (VirginiaTotalGasolineThrough+MarylandTotalGasolineThrough)/2 if DistrictofColumbiaTotalGasol==.

local varnames "USTotalGasolineThroughComp EastCoastPADD1TotalGasoli NewEnglandPADD1ATotalGaso ConnecticutTotalGasolineThrou MaineTotalGasolineThroughCom MassachusettsTotalGasolineThr NewHampshireTotalGasolineThr RhodeIslandTotalGasolineThro VermontTotalGasolineThroughC CentralAtlanticPADD1BTotal DelawareTotalGasolineThrough DistrictofColumbiaTotalGasol MarylandTotalGasolineThrough NewJerseyTotalGasolineThroug NewYorkTotalGasolineThrough PennsylvaniaTotalGasolineThro LowerAtlanticPADD1CTotalG FloridaTotalGasolineThroughC GeorgiaTotalGasolineThroughC NorthCarolinaTotalGasolineTh SouthCarolinaTotalGasolineTh VirginiaTotalGasolineThrough WestVirginiaTotalGasolineThr MidwestPADD2TotalGasoline IllinoisTotalGasolineThrough IndianaTotalGasolineThroughC IowaTotalGasolineThroughComp KansasTotalGasolineThroughCo KentuckyTotalGasolineThrough MichiganTotalGasolineThrough MinnesotaTotalGasolineThrough MissouriTotalGasolineThrough NebraskaTotalGasolineThrough NorthDakotaTotalGasolineThro OhioTotalGasolineThroughComp OklahomaTotalGasolineThrough SouthDakotaTotalGasolineThro TennesseeTotalGasolineThrough WisconsinTotalGasolineThrough GulfCoastPADD3TotalGasoli AlabamaTotalGasolineThroughC ArkansasTotalGasolineThrough LouisianaTotalGasolineThrough MississippiTotalGasolineThrou NewMexicoTotalGasolineThroug TexasTotalGasolineThroughCom RockyMountainPADD4TotalGa ColoradoTotalGasolineThrough IdahoTotalGasolineThroughCom MontanaTotalGasolineThroughC UtahTotalGasolineThroughComp WyomingTotalGasolineThroughC WestCoastPADD5TotalGasoli AlaskaTotalGasolineThroughCo ArizonaTotalGasolineThroughC CaliforniaTotalGasolineThroug HawaiiTotalGasolineThroughCo NevadaTotalGasolineThroughCo OregonTotalGasolineThroughCo WashingtonTotalGasolineThroug"

local x=0
foreach var of local varnames{
	if regexm("`var'","PADD"){
	    drop `var'
	}
    else {
	    local varname=substr("`var'",1,(strpos("`var'", "Total")-1))
		local varnamelist "`varnamelist' `varname'"
		rename `var' v`x'
		local x=`x'+1
	}
}

di "`varnamelist'"

reshape long v, i(year) j(jurisdiction_01)

tostring jurisdiction_01, replace
sort year
local x=0
foreach varname of local varnamelist{
    replace jurisdiction_01= "`varname'" if jurisdiction_01=="`x'"
	local x=`x'+1
}

merge m:1 jurisdiction_01 using "$Path/Excise taxes on goods/Codes.dta", keepusing(jurisdiction State) // "$Path\Consumption taxes\Excise taxes on goods\Codes.dta", keepusing(jurisdiction State)
drop if _m==1
drop _m jurisdiction_01

order jurisdiction State year
sort year State
rename v gasoline_price
drop if year==.

*merging all gas prices to one file
merge m:1 year using "`gasprice'", nogenerate keepusing(cpi_gas_growth)

sort State year
drop if year>2017


*Calculating prices for years after 2010 by cpi for gasoline
sort jurisdiction year
by jurisdiction: replace gasoline_price=cpi_gas_growth*gasoline_price[_n-1] if year>2010

drop cpi_gas_growth

reshape wide gasoline_price, i(jurisdiction) j(year)

save "$Path/Excise taxes on goods/Gasoline/Clean/gasprices.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Gasoline\Clean\gasprices.dta", replace

* Import gasoline excise tax rates. These are cents per unit sold.
import excel "$Path/Excise taxes on goods/Gasoline/Raw/gasoline_taxes.xlsx", sheet("Sheet1") firstrow clear // "$Path\Consumption taxes\Excise taxes on goods\Gasoline\Raw\gasoline_taxes.xlsx", sheet("Sheet1") firstrow clear
save "$Path/Excise taxes on goods/Gasoline/Clean/gasoline_taxes.dta", replace // "$Path\Consumption taxes\Excise taxes on goods\Gasoline\Clean\gasoline_taxes.dta", replace

