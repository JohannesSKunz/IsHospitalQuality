*******************************
* 19.11.21 Kunz and Propper
* Generates a HRR-quality level 
* Merged to Pre-covid deaths 
*******************************

clear all 
set more off 
tempfile temp temp1 temp2 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/hopsital_quanity_covid/data_final/sourcefiles/"
set matsize 10000

* -----------------------------------------------------------------------------
* path
loc estdate   "22_05_12"
loc datedata  "22_05_12"
loc path "/Users/jkun0001/Dropbox/workingpapers/KunzPropper/_estimation/`estdate'_estimation/"
loc coviddatenr "531" //

* -----------------------------------------------------------------------------
* Load All cause mortality by county 
import delimited CDC_mortality2000_2019.txt, clear 
drop notes
drop if countycode == .
save `temp1', replace 

* -------------------
* Load main data: Prelim 2020
import delimited "AH_County_of_Residence_COVID-19_Deaths_Counts__2020_Provisional.csv", clear 
rename totaldeaths deaths 
rename fipscode countycode 
rename countyofresidence county 
g year = 2020
append using `temp1'
order county countycode year 
sort county year
drop dataasof startdate enddate state yearcode cruderate ageadjustedrate oftotaldeaths
save `temp1', replace 

* -------------------
* Add: AMI 
import delimited "Underlying Cause of Death, 1999-2019.txt", clear 
rename deaths AMIdeaths
keep AMIdeaths countycode year
drop if countycode == . 
merge 1:1 countycode year using `temp1' , nogen
order  countycode county year AMIdeaths deaths covid19deaths
sort countycode year
save `temp1', replace 


* -------------------
* Add: Pneumonia 
import delimited "Underlying Cause of Death, 1999-2020_pneumonia.txt", clear 
rename deaths PNdeaths
destring PNdeaths , force replace 
keep PNdeaths countycode year
drop if countycode == . 
merge 1:1 countycode year using `temp1' , nogen
order  countycode county year PNdeaths AMIdeaths deaths covid19deaths
sort countycode year

* -------------------
* -------------------
* Imputations for missings 
g AMIdeaths9 = AMIdeaths
replace AMIdeaths     = 0 if AMIdeaths == . & year > 2015 & year <= 2020
replace AMIdeaths9    = 9 if AMIdeaths == . & year > 2015 & year <= 2020

g PNdeaths9 = PNdeaths
replace PNdeaths     = 0 if PNdeaths == . & year > 2015 & year <= 2020
replace PNdeaths9    = 9 if PNdeaths9 == . & year > 2015 & year <= 2020

g covid19deaths9 = covid19deaths
replace covid19deaths  = 0 if covid19deaths == . & year == 2020
replace covid19deaths9 = 9 if covid19deaths == . & year == 2020

g deaths9 = deaths
replace deaths = 		0 if deaths == . 
replace deaths9 = 		9 if deaths == . 

* Predict deaths for each county, linear fit 
g p_deaths = .
g p_deaths9 = .
levelsof countycode , local(count)
foreach va of local count {
	cap reg deaths c.year 		  if year <  2020  & countycode == `va'
	cap predict temp  			  if year >= 2020  & countycode == `va'
	cap replace p_deaths = temp   if year >= 2020  & countycode == `va'
	
	cap reg deaths9 c.year 		  if year <  2020  & countycode == `va'
	cap predict temp9  			  if year >= 2020  & countycode == `va'
	cap replace p_deaths9 = temp9 if year >= 2020  & countycode == `va'
	cap drop temp*
	} 

g deaths_nocov = deaths - covid19deaths
g deaths_nocov9 = deaths9 - covid19deaths9
g deaths_exce  = deaths - p_deaths
g deaths_exce9  = deaths9 - p_deaths9


rename countycode countyfips
save `temp1', replace 


* -------------------
* -------------------
use ../mainfiles/21_11_20_maindata_adj

* drop daily data 
bys countyfips (day): g t = _n 
keep if day==`coviddatenr'

* drop unneessary info
drop day logdeaths_day_1 logdeaths_day arcsindeaths_day oneweek fourweeks t
rename population population2020
merge 1:m countyfips using `temp1' , nogen

order countyfips county statefips year AMIdeaths deaths covid19deaths footnote population p_deaths deaths_nocov deaths_exce AMIdeaths deaths
sort countyfips year

* Selet data 
keep if year>=2010
replace population = population2020 if year == 2020 



compress 
save ../mainfiles/`datedata'_yearlydata_adj, replace 



