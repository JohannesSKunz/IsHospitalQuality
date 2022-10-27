*******************************
* 19.11.21 Kunz and Propper
* Generates a county level file
*******************************

clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/hopsital_quanity_covid/data_final/sourcefiles/"
tempfile temp 

* ------------------------------------------------------------------------
* Use zip code crosswalk, helps to see whether there are missings 
use ../processedfiles/crosswalk_county_hrr.dta
collapse (first) city , by(countyfips)
save `temp', replace 

* ------------------------------------------------------------------------
* Load data: Population USAfacts
import delimited covid_county_population_usafacts.csv, encoding(macroman) clear 
rename ôªøcountyfips countyfips
drop if countyfips == 0

* merge with crosswalk 
merge 1:1 countyfips using `temp', nogen keep(3)
* 4 can not be merged: 
* Grand Princess Cruise Ship
* Kusilvak Census Area
* Oglala Lakota County
* Wade Hampton Census Area
* 3140 counties merged 

* Labels 
lab var countyfips 				"County fips nr"
lab var city   					"City-county"
lab var population  			"USAfacts may2020: population"

compress 
save `temp', replace 


* ------------------------------------------------------------------------
* Load data: economic indicators poverty all ages, medican income: SAIPE Dec 2019
import excel est18all.xls, sheet("est18ALL") cellrange(A4:AE3198) firstrow clear

* County nr 
g countyfips = StateFIPSCode+CountyFIPSCode
keep countyfips  PovertyPercentAllAges MedianHouseholdIncome
destring countyfips PovertyPercentAllAges MedianHouseholdIncome, replace force

* merge with above 
merge m:1 countyfips using `temp', keep(3) nogen 
* 54  from SAIPE can not be merged, ony state aggregates 
* 3140 counties merged 

* Labels 
lab var countyfips 				"County fips nr"
lab var PovertyPercentAllAges   "SAIPE dec2019: percent poverty all ages"
lab var MedianHouseholdIncome  	"SAIPE dec2019: medican household income"

order countyfips countyname city state population PovertyPercentAllAges MedianHouseholdIncome 

compress 
save `temp', replace 

* ------------------------------------------------------------------------------
* Population metrics
import delimited Rural-Atlas-Update2021-People.csv, encoding(ISO-8859-1)clear
loc vars "popdensity2010 age65andolderpct2010 whitenonhispanicpct2010 blacknonhispanicpct2010 asiannonhispanicpct2010 nativeamericannonhispanicpct2010 hispanicpct2010 multipleracepct2010 foreignbornpct ed1lessthanhspct ed2hsdiplomaonlypct ed3somecollegepct ed4assocdegreepct ed5collegepluspct avghhsize hh65plusalonepct"
keep ïfips `vars'
rename ïfips countyfips

foreach var of local vars {
	lab var `var' "USDA ERS 2018: `var'" 
	}
	
merge m:1 countyfips using `temp', keep(3) nogen 
* 54  from USDA can not be merged, ony state aggregates 
* 3140 counties merged 

* Labels 
lab var countyfips 				"County fips nr"

order countyfips countyname city state population PovertyPercentAllAges MedianHouseholdIncome 

compress 
save `temp', replace 

* ------------------------------------------------------------------------------
* Social capital metrics, also 
* community health: Non-religious non-profit organizations p 1,000	Religious congregations p 1,000	Informal Civic Engagement Subindex
* institutional health: Presidential election voting rate, 2012 & 2016	Mail-back census response rate	Confidence in Institutions Subindex

import excel social-capital-project-social-capital-index-data.xlsx, sheet("County Index") cellrange(A3:P3145) firstrow clear
loc vars "CountyLevelIndex CommunityHealth InstitutionalHealth"
keep FIPSCode `vars' CountyState
destring FIPSCode, force replace
rename FIPSCode countyfips

foreach var of local vars {
	lab var `var' "SCI-Project apr2018: `var'" 
	}

merge m:1 countyfips using `temp',  keep(3) nogen 
* two counties can not be merged 	
* tab CountyState if _merge==1 
* Kusilvak Census Area, Alaska
* Oglala Lakota County, South Dakota
drop CountyState

order countyfips countyname city state population PovertyPercentAllAges MedianHouseholdIncome 

compress 
save `temp', replace 


* ------------------------------------------------------------------------------
* Community Health rankings: 2019 CHR CSV Analytic Data
import delimited community-health-analytic_data2019.csv, varnames(1) encoding(ISO-8859-1)clear
drop  if releaseyear=="year" // first row still description

loc vars "prematuredeathrawvalue poororfairhealthrawvalue poorphysicalhealthdaysrawvalue poormentalhealthdaysrawvalue adultsmokingrawvalue foodenvironmentindexrawvalue physicalinactivityrawvalue excessivedrinkingrawvalue alcoholimpaireddrivingdeathsrawv uninsuredrawvalue primarycarephysiciansrawvalue mentalhealthprovidersrawvalue preventablehospitalstaysrawvalue fluvaccinationsrawvalue airpollutionparticulatematterraw drinkingwaterviolationsrawvalue drivingalonetoworkrawvalue longcommutedrivingalonerawvalue lifeexpectancyrawvalue prematureageadjustedmortalityraw drugoverdosedeathsrawvalue residentialsegregationblackwhite nonhispanicafricanamericanrawval communicablediseaserawvalue opioidhospitalvisitsrawvalue olderadultslivingalonerawvalue"
keep digitfipscode `vars' name
destring digitfipscode `vars', force replace
rename digitfipscode countyfips

foreach var of local vars {
	lab var `var' "CHI-Project 2019: `var'" 
	}

merge m:1 countyfips using `temp', keep(3) nogen 
* 54  from USDA can not be merged, ony state aggregates 
* tab name if _merge==1 
* 3140 counties merged 
drop name 

save `temp', replace 

* ------------------------------------------------------------------------
* ACS 2018 %yr ave
import delimited "ACSDP5Y2018.DP05_data_with_overlays_2020-06-23T204445.csv", varnames(1) encoding(ISO-8859-1)clear
drop  if geo_id == "id"

bro geo_id
gen countyfips = substr(geo_id, -5, .)
destring countyfips , force replace 

rename dp05_0033e pop_acs 
rename dp05_0071e pop_acs_hisp 
rename dp05_0077e pop_acs_nonhisp_white
rename dp05_0078e pop_acs_nonhisp_black
rename dp05_0079e pop_acs_nonhisp_alaska
rename dp05_0080e pop_acs_nonhisp_asian 
rename dp05_0081e pop_acs_nonhisp_hawaii
rename dp05_0082e pop_acs_nonhisp_other 
rename dp05_0083e pop_acs_nonhisp_more

destring pop_acs pop_acs_hisp pop_acs_nonhisp_*  , force replace 

g pop_acs_other = pop_acs_nonhisp_alaska + pop_acs_nonhisp_asian + pop_acs_nonhisp_hawaii + pop_acs_nonhisp_other + pop_acs_nonhisp_more

* Check: 
g sum = pop_acs_hisp + pop_acs_nonhisp_white + pop_acs_nonhisp_black + pop_acs_nonhisp_alaska + pop_acs_nonhisp_asian + pop_acs_nonhisp_hawaii + pop_acs_nonhisp_other + pop_acs_nonhisp_more
order countyfips name  pop_acs_hisp pop_acs_nonhisp_* sum 
*bro countyfips name total pop_acs_hisp pop_acs_nonhisp_* sum

g pop_acs_share_hisp     = pop_acs_hisp/pop_acs
g pop_acs_share_nh_white = pop_acs_nonhisp_white/pop_acs
g pop_acs_share_nh_black = pop_acs_nonhisp_black/pop_acs
g pop_acs_share_nh_other = pop_acs_other/pop_acs

loc vars "pop_acs pop_acs_hisp pop_acs_nonhisp_white pop_acs_nonhisp_black pop_acs_other pop_acs_share_hisp pop_acs_share_nh_white pop_acs_share_nh_black pop_acs_share_nh_other"
foreach var of local vars {
	lab var `var' "ACS 2018 5yr ave: `var'" 
	}

keep countyfips name pop_acs_*
merge 1:1 countyfips using `temp' , keep(3) nogen
save `temp', replace

* ----------------------------------------------------------------------------
* Import election data 
import delimited "countypres_2000-2020.csv", clear 
destring county_fips , force gen(countyfips)
destring candidatevotes totalvotes , force replace 

order countyfips county_name year party candidatevotes totalvotes mode
sort countyfips year party

* In 2020 some report absentee, mail, thus need to collapse (check)
bys countyfips year party: egen totalparty = sum(candidatevotes)
bys countyfips year party: g t = _n
bys countyfips year : egen total_check = sum(candidatevotes)
g warning = total_check != totalvotes
sort warning
drop if warning == 1 

order countyfips county_name year party candidatevotes totalvotes totalparty total_check mode
bro countyfips county_name year party candidatevotes totalvotes totalparty total_check mode
keep if t==1 // keep only one per party x year x county
keep if year >= 2012 // last 3 elections 
* calculate republican vote share 
g temp = totalparty/totalvotes 

* republican winner 
bys countyfips year : egen majtemp=max(temp)
g winner = party if majtemp == temp
g repubican_majority_temp = winner == "REPUBLICAN"
bys countyfips year : egen repubican_majority = max(repubican_majority_temp)

* voteshare republican
g voteshare_rep_temp = temp if party == "REPUBLICAN"
bys countyfips year : egen voteshare_rep = max(voteshare_rep_temp)

bys countyfips year : g t2 = _n 
keep if t2==1 
keep countyfips year repubican_majority voteshare_rep
drop if countyfips ==. 

* reshape 
reshape wide repubican_majority voteshare_rep , i(countyfips) j(year)

merge 1:1 countyfips using `temp' , keep(2 3) nogen
* 3,114 matched
save `temp', replace


* ----------------------------------------------------------------------------
* Rural data 
import excel ruralurbancodes2013.xls, firstrow  sheet("Rural-urban Continuum Code 2013") clear
destring FIPS , force gen(countyfips)
g urban = RUCC_2013 < 3
g metrourban = RUCC_2013 < 2
keep countyfips urban metrourban 
lab var urban "Census: Larger than 20,000 inhab, 2013" 
lab var metrourban "Census: Larger than 20,0000 inhab, 2013" 
merge 1:1 countyfips using `temp' , keep(2 3) nogen

* ------------------------------------------------------------------------
* Save 
order countyfips countyname city state population PovertyPercentAllAges MedianHouseholdIncome 
compress 
save ../processedfiles/countyvariables, replace 
