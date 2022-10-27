* Kunz & Propper 
clear all 
set more off 
tempfile temp temp1 temp2 
loc estdate   "22_06_10"
loc datedata  "21_11_20"
loc path "/Users/jkun0001/Dropbox/publications/2022_KunzPropper/_estimation/`estdate'_estimation_fin/"
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/hopsital_quanity_covid/data_final/sourcefiles/"
set matsize 10000

* --------------------------------------------------
* Prepare 
use US_County_LowRes_2013data_Stata11.dta , clear 
	g countyfips = statefp*1000 + countyfp
save `temp', replace 

use US_States_LowRes_2015coord_Stata11.dta , clear
merge m:1 _ID using US_States_LowRes_2015data_Stata11.dta , keepusing(continental territories)
keep if continental == 1 & territories == 0
drop continental territories _merge
save US_States_LowRes_2015coord_Stata11_noterr.dta, replace 

* --------------------------------------------------
* Main 
use ../mainfiles/`datedata'_maindata_adj

loc coviddatenr "531" //

loc indwgt		 "zipwgt" 
loc indicator 	 "`indwgt'_phi_brglmpenalty3" 
loc outcome 	 "deaths" 
loc ses 		 "robust" 
loc covarsHRR 	 "`indwgt'_hhi_beds `indwgt'_nrhosphrr " 
loc covarsECON	 "PovertyPercentAllAges MedianHouseholdIncome uninsuredrawvalue"
loc covarsHeal 	 "prematuredeathrawvalue poororfairhealthrawvalue poorphysicalhealthdaysrawvalue poormentalhealthdaysrawvalue physicalinactivityrawvalue lifeexpectancyrawvalue"
loc covarsQual 	 "longcommutedrivingalonerawvalue airpollutionparticulatematterraw fluvaccinationsrawvalue preventablehospitalstaysrawvalue adultsmokingrawvalue drinkingwaterviolationsrawvalue drivingalonetoworkrawvalue"
loc covarsCom 	 "CountyLevelIndex CommunityHealth InstitutionalHealth voteshare_rep2020" //
loc covarsPoP 	 "pop_acs_share_hisp pop_acs_share_nh_black pop_acs_share_nh_other urban popdensity2010 age65andolderpct2010 foreignbornpct ed1lessthanhspct ed2hsdiplomaonlypct ed3somecollegepct ed4assocdegreepct avghhsize hh65plusalonepct"
loc covars      "`covarsECON' `covarsCom' `covarsPoP' `covarsHeal' `covarsQual' residentialsegregationblackwhite "

* -----------------------------------------------------------------------------
* Prep
keep if day == `coviddatenr'
* Missings 0  
foreach var of local covars {
	qui g miss`la'_m = `var' ==. 
	qui replace `var' = 0 if `var' ==. 
	loc la = `la'+1 
	}
loc covars " `covars'  *_m"
loc covariates " `covarsHRR' `covars'  i.statefips"

* Need to reverse as in main application higher quality is larger values
* In figure darker areas are worse quality, to see correlation better
replace `indicator' = 1 - `indicator'

* -----------------------------------------------------------------------------
* Generate FWL residual 
reg `indicator' `covariates' 
	predict `indicator'_res , res

* Generate FWL residual 
reg `outcome'_day `covariates' 
	predict `outcome'_day_res , res	
	
* -----------------------------------------------------------------------------	
* Map 
merge 1:1  countyfips using `temp' , keepusing(_ID continental territories) keep(3) nogen
keep if continental == 1 & territories == 0

* Gen maps 
loc i 1 
//*
format `indicator' %12.2f
spmap `indicator' using US_County_LowRes_2013coord_Stata11.dta, ///
		polygon(data("US_States_LowRes_2015coord_Stata11_noterr.dta") osize(0.5) ocolor(black)) ///
		id(_ID) name(gr`i', replace) ///
		title("A. County-level hospital quality exposure" "(darker worse quality)" , s(medsmall)) ///
		fcolor(Reds2) cln(9) 
		loc i = `i' + 1 

format `indicator'_res %12.2f
spmap `indicator'_res using US_County_LowRes_2013coord_Stata11.dta, ///
		polygon(data("US_States_LowRes_2015coord_Stata11_noterr.dta") osize(0.5) ocolor(black)) ///
		id(_ID) name(gr`i', replace) ///
		title("B. Residual county-level hospital quality exposure" "(darker worse quality)" , s(medsmall)) ///
		fcolor(Reds2) cln(9)
		loc i = `i' + 1 		
graph combine  gr1 gr2 , scheme(s2mono) graphregion(color(white)) ysize(6) xsize(10)
	graph export `path'/_figures/e1_fig_map.png , replace 	
	graph export `path'/_figures/e1_fig_map.tif , replace 	
