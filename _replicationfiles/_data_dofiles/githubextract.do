*Prep for Github 
* Github file limit prevents us from posting the complete data, so we extract only relevant components for the main analyses

clear all 
set more off
cd "/Users/jkun0001/Desktop/_replicationfiles/_data/"

* --------------------------------------------------
* Prepare 
use US_County_LowRes_2013data_Stata11.dta , clear 
	g countyfips = statefp*1000 + countyfp
save map1.dta, replace 

use US_States_LowRes_2015coord_Stata11.dta , clear
merge m:1 _ID using US_States_LowRes_2015data_Stata11.dta , keepusing(continental territories)
keep if continental == 1 & territories == 0
drop continental territories _merge
*save US_States_LowRes_2015coord_Stata11_noterr.dta, replace 
save ../aux_map_a.dta, replace 

use US_County_LowRes_2013coord_Stata11.dta, clear 
save ../aux_map_b.dta, replace 

* --------------------------------------------------
clear all 
* Main for Map 
loc estdate   "22_06_10"
loc datedata  "21_11_20"
use `datedata'_maindata_adj
loc coviddatenr "531" //

* Define variables 
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
merge 1:1  countyfips using map1 , keepusing(_ID continental territories) keep(3) nogen
keep if continental == 1 & territories == 0

keep _ID territories continental  zipwgt_phi_brglmpenalty3 equwgt_phi_brglmpenalty3 zippopwgt_phi_brglmpenalty3 afact_phi_brglmpenalty3 zipwgt_phi_brglmpenalty3_res 
save ../maindata_fig1_maps, replace 

* -----------------------------------------------------------------------------	
* -----------------------------------------------------------------------------	
* -----------------------------------------------------------------------------	
* --------------------------------------------------
clear all 

* Main for Figure 
loc estdate   "22_06_10"
loc datedata  "21_11_20"
use `datedata'_maindata_adj
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
* Missings 0  
loc la = ""
foreach var of local covars {
	qui g miss`la'_m = `var' ==. 
	qui replace `var' = 0 if `var' ==. 
	loc la = `la'+1 
	}
loc covars " `covars'  *_m"

// For heterogeneity
g minorty = 100 -  whitenonhispanicpct2010 
g StateMajorFinHealthSupport = sum_invest > 0 
g TeachHospExposed  = zipwgt_teach == 3 

corr zipwgt_AcCareHospBedsper10 zipwgt_HospbasedRegNurper1 zipwgt_HospBasedPhysper10 metrourban

pca zipwgt_TotPhysper100000 zipwgt_HospBasedPhysper10 zipwgt_CritCarePhysper100 zipwgt_InfecDisSpecper100 zipwgt_AcCareHospBedsper10 zipwgt_FTEHospEmpper1000 zipwgt_HospbasedRegNurper1 TeachHospExposed metrourban urban longcommutedrivingalonerawvalue popdensity2010
predict princ_1 


* regressions 
keep if fourweeks==1
keep deaths_day cases_day vacc_day `indicator'  `covarsHRR' `covars' `covars2' *statefips day countyfips  population zippopwgt_phi_brglmpenalty3 afact_phi_brglmpenalty3 equwgt_phi_brglmpenalty3 zipwgt_phi_brglmpenalty_pool zipwgt_exreadmisratio3 zipwgt_mort_rate3 primarycarephysiciansrawvalue minorty metro  zippopwgt_nrhosphrr zippopwgt_nrhosphrr zipwgt_teach sum_invest princ_1 zipwgt_AcCareHospBedsper10 zipwgt_TotPhysper100000 zipwgt_HospBasedPhysper10 zipwgt_CritCarePhysper100 zipwgt_FTEHospEmpper1000 zipwgt_HospbasedRegNurper1 TeachHospExposed StateMajorFinHealthSupport

save ../maindata_fig2_3_tab1.dta , replace 

* -----------------------------------------------------------------------------

* -----------------------------------------------------------------------------
* Tab 2
loc estdate   "22_06_10"
loc datedata  "21_11_20"
use `datedata'_yearlydata_adj
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
* Missings 0  indicators
loc la ""
foreach var of local covars {
	qui g miss`la'_m = `var' ==. 
	qui replace `var' = 0 if `var' ==. 
	loc la = `la'+1 
	}
loc covars " `covars'  *_m"
loc covariates " `covarsHRR' `covars'  i.statefips"


* For pre-2020
replace covid19deaths          = (covid19deaths / population) *10000
replace deaths_exce  		   = ((deaths)/population - (p_deaths)/population) *10000
replace deaths     			   = (deaths / population) *10000
replace p_deaths  			   = (p_deaths / population) *10000

replace covid19deaths9         = (covid19deaths9 / population) *10000
replace deaths_exce9  		   = ((deaths9)/population - (p_deaths9)/population) *10000
replace deaths9     		   = (deaths9 / population) *10000
replace p_deaths9  			   = (p_deaths9 / population) *10000

g  check_AMIdeaths9_pop = (9/population)*10000 if AMIdeaths9 ==.
su check_AMIdeaths9_pop
drop check_*

g AMIdeaths_pop = (AMIdeaths/population)*10000
replace  AMIdeaths_pop = (0/population)*10000 if AMIdeaths_pop ==. //of course its just 0
g AMIdeaths9_pop = (AMIdeaths9/population)*10000
replace AMIdeaths9_pop = (9/population)*10000 if AMIdeaths9_pop ==.

g allcausedeaths_pop = (deaths/population)*10000
g allcausedeaths9_pop = (deaths9/population)*10000

keep deaths  `indicator'  `covarsHRR' `covars' `covars2' *statefips  countyfips  population year AMIdeaths_pop

save ../maindata_tab2.dta , replace 
