*******************************
* 19.11.21 Kunz and Propper
* Generates a HRR-quality level 
* Merged to Covid deaths 
*******************************

clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/hopsital_quanity_covid/data_final/sourcefiles/"
tempfile temp1 temp2 temp3
set maxvar 11000

loc coviddate 21_07_07
loc datedata  21_11_20
loc coviddatenr "531" // 

* ------------------------------------------------------------------------------
* policy 
import delimited OxCGRT_US_latest.csv, clear 
bro regionname regioncode date h4_emergencyinvestmentinhealthca
bys regionname (date) : g sum_invest = sum(h4_emergencyinvestmentinhealthca)
*rename regioncode statefips
g state = usubinstr(regioncode, "US_", "", 1) 
keep regionname state date sum_invest
drop if state == ""
drop if date <= 20200110
bys state (date) : g day = 4 + _n
save ../processedfiles/statedaylevel_covidpolicy, replace 


* ---------------------
* Load: Vaccination data
import delimited `coviddate'_COVID-19_Vaccinations_in_the_United_States_County.csv, clear
g statadate = date(date,"MDY")
format statadate %td
* need to drop unknown county, could allocate by population?
drop if fips=="UNK"
sort recip_county statadate 
gen countyfips  = string(real(fips),"%05.0f")
bys countyfips (statadate): g day = 330+_n
su day
drop if day>`coviddatenr'
keep countyfips recip_county day series_complete_yes series_complete_pop_pct series_complete_65plus series_complete_65pluspop_pct
rename series_complete_yes 				vacc_nrall_day
rename series_complete_pop_pct 			vacc_pctall_day
rename series_complete_65plus 			vacc_nr65_day
rename series_complete_65pluspop_pct 	vacc_pct65_day
reshape wide vacc* , i(countyfips) j(day)
destring countyfips , force replace
compress 
replace countyfips = 2158 if countyfips == 2270 // somehow different fips coding, only Kusilvak Census Area 2270 to 2158 in death data 
save `temp3' , replace 

* ---------------------
* Load data: Cases
import delimited `coviddate'_covid_confirmed_usafacts.csv, encoding(macroman) clear 

cap rename ôªøcountyfips countyfips
drop if countyfips == 0

forval i=5/`coviddatenr' { 
	rename v`i' cases_day`i' 
	}
save `temp1', replace  

* ---------------------
* Load data: Deaths
import delimited `coviddate'_covid_deaths_usafacts.csv, encoding(macroman) clear 
cap rename ôªøcountyfips countyfips
drop if countyfips == 0

forval i=5/`coviddatenr' { 
	rename v`i' deaths_day`i' 
	}
merge 1:1 countyfips using `temp1' , nogen
merge 1:1 countyfips using `temp3' , nogen
* Just one unknown (Kusilvak see above) and puerto rico ... bro if _merge!=3 
 
* ------------------------------------------------------------------------------
* Merge to other data
merge 1:1 countyfips using ../processedfiles/county_aveHRR , nogen keep(3)

* 5 death counties can not be merged:
*  Grand Princess Cruise Ship
*  Kusilvak Census Area
*  New York City Unallocated/Probable
*  Oglala Lakota County
*  Wade Hampton Census Area

compress 
save ../mainfiles/`datedata'_maindata, replace 
