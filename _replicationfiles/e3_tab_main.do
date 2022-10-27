* Kunz & Propper 
clear all 
set more off 
tempfile temp temp1 temp2 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/hopsital_quanity_covid/data_final/mainfiles/"
set matsize 10000

* -----------------------------------------------------------------------------
* path
loc estdate   "22_06_10"
loc datedata  "21_11_20"
loc path "/Users/jkun0001/Dropbox/publications/2022_KunzPropper/_estimation/`estdate'_estimation_fin/"
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
* Missings 0 indicators 
foreach var of local covars {
	qui g miss`la'_m = `var' ==. 
	qui replace `var' = 0 if `var' ==. 
	loc la = `la'+1 
	}
loc covars " `covars'  *_m"
loc covariates " `covarsHRR' `covars'  i.statefips"

* -----------------------------------------------------------------------------
* Pooled 
loc i = 1 
loc j = 1

keep if day == `coviddatenr'


* -----------------------------------------------------------------------------
* Analysis 
su `indicator'
sca stad = r(sd) 

loc i = 1
loc keepv ""

* ---------------------
* Base 
reg deaths_day 				`indicator' cases_day i.statefips  , `ses'
est sto er1`i' 	
reg deaths_day 				`indicator' cases_day  vacc_day   `covariates' , `ses'
est sto reg`i' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'
	estadd sca sd = r(sd)   , :reg`i'
	estadd sca mf = (_b[`indicator']*stad)/r(mean)   , :reg`i'	
	estadd sca stad = stad   , :reg`i'
	reg cases_day 				`indicator' population  vacc_day   `covariates' , `ses'
	est sto er2`i' 
	reg vacc_day 				`indicator' population  cases_day   `covariates' , `ses'
	est sto er3`i' 
	loc i = `i' + 1
	loc keepv "`indicator' quality `keepv'"

* ---------------------
* Popweightes 
loc indwgt		 "zippopwgt" 
	loc indicator 	 "`indwgt'_phi_brglmpenalty3" 
	replace `indicator' = 1- `indicator'
	su `indicator'	
	sca stad = r(sd) 
reg deaths_day 				`indicator' cases_day i.statefips  , `ses'
est sto er1`i' 	
reg deaths_day 				`indicator' cases_day  vacc_day   `covariates' , `ses'
est sto reg`i' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'
	estadd sca sd = r(sd)   , :reg`i'
	estadd sca mf = (_b[`indicator']*stad)/r(mean)   , :reg`i'	
	estadd sca stad = stad   , :reg`i'
	reg cases_day 				`indicator' population  vacc_day   `covariates' , `ses'
	est sto er2`i' 
	reg vacc_day 				`indicator' population  cases_day   `covariates' , `ses'
	est sto er3`i' 
	loc i = `i' + 1	
	loc keepv "`indicator' quality `keepv'"

* ---------------------
* Dartmouth weightes 
loc indwgt		 "afact" 
	loc indicator 	 "`indwgt'_phi_brglmpenalty3" 
	replace `indicator' = 1- `indicator'
	su `indicator'
	sca stad = r(sd) 
reg deaths_day 				`indicator' cases_day i.statefips  , `ses'
	est sto er1`i' 	
reg deaths_day 				`indicator' cases_day  vacc_day   `covariates' , `ses'
	est sto reg`i' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'
	estadd sca sd = r(sd)   , :reg`i'
	estadd sca mf = (_b[`indicator']*stad)/r(mean)   , :reg`i'	
	estadd sca stad = stad   , :reg`i'
reg cases_day 				`indicator' population  vacc_day   `covariates' , `ses'
	est sto er2`i' 
reg vacc_day 				`indicator' population  cases_day   `covariates' , `ses'
	est sto er3`i' 
	loc i = `i' + 1	
	loc keepv "`indicator' quality `keepv'"
	
* ---------------------
* Equal weightes
loc indwgt		 "equwgt" 
	loc indicator 	 "`indwgt'_phi_brglmpenalty3" 
	replace `indicator' = 1- `indicator'
	su `indicator'
	sca stad = r(sd) 
reg deaths_day 				`indicator' cases_day i.statefips  , `ses'
	est sto er1`i' 	
reg deaths_day 				`indicator' cases_day  vacc_day   `covariates' , `ses'
est sto reg`i' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'
	estadd sca sd = r(sd)   , :reg`i'
	estadd sca mf = (_b[`indicator']*stad)/r(mean)   , :reg`i'	
	estadd sca stad = stad   , :reg`i'
reg cases_day 				`indicator' population  vacc_day   `covariates' , `ses'
	est sto er2`i' 
reg vacc_day 				`indicator' population  cases_day   `covariates' , `ses'
	est sto er3`i' 
	loc i = `i' + 1		
	loc keepv "`indicator' quality `keepv'"

* ---------------------
* Pooled quali
loc indwgt		 "zipwgt" 
	loc indicator 	 "`indwgt'_phi_brglmpenalty_pool" 
	replace `indicator' = 1- `indicator'
	su `indicator'
	sca stad = r(sd) 
reg deaths_day 				`indicator' cases_day i.statefips  , `ses'
	est sto er1`i' 	
reg deaths_day 				`indicator' cases_day  vacc_day   `covariates' , `ses'
	est sto reg`i' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'
	estadd sca sd = r(sd)   , :reg`i'
	estadd sca mf = (_b[`indicator']*stad)/r(mean)   , :reg`i'	
	estadd sca stad = stad   , :reg`i'
reg cases_day 				`indicator' population  vacc_day   `covariates' , `ses'
	est sto er2`i' 
reg vacc_day 				`indicator' population  cases_day   `covariates' , `ses'
	est sto er3`i' 
	loc i = `i' + 1		
	loc keepv "`indicator' quality `keepv'"	

* ---------------------
* Excess read quali 
loc indwgt		 "zipwgt" 
loc indicator 	 "`indwgt'_exreadmisratio3" 
replace `indicator' = -1 * `indicator'
	su `indicator'
	sca stad = r(sd) 
reg deaths_day 				`indicator' cases_day i.statefips  , `ses'
	est sto er1`i' 	
reg deaths_day 				`indicator' cases_day  vacc_day   `covariates' , `ses'
	est sto reg`i' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'
	estadd sca sd = r(sd)   , :reg`i'
	estadd sca mf = (_b[`indicator']*stad)/r(mean)   , :reg`i'	
	estadd sca stad = stad   , :reg`i'
	reg cases_day 				`indicator' population  vacc_day   `covariates' , `ses'
	est sto er2`i' 
	reg vacc_day 				`indicator' population  cases_day   `covariates' , `ses'
	est sto er3`i' 
loc i = `i' + 1		
	loc keepv "`indicator' quality `keepv'"		

* ---------------------
* Mortality quali  
loc indwgt		 "zipwgt" 
loc indicator 	 "`indwgt'_mort_rate3" 
replace `indicator' = -1 * `indicator'
	su `indicator'
	sca stad = r(sd) 
reg deaths_day 				`indicator' cases_day i.statefips  , `ses'
	est sto er1`i' 		
reg deaths_day 				`indicator' cases_day  vacc_day   `covariates' , `ses'
est sto reg`i' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'
	estadd sca sd = r(sd)   , :reg`i'
	estadd sca mf = (_b[`indicator']*stad)/r(mean)   , :reg`i'	
	estadd sca stad = stad   , :reg`i'
	reg cases_day 				`indicator' population  vacc_day   `covariates' , `ses'
	est sto er2`i' 
	reg vacc_day 				`indicator' population  cases_day   `covariates' , `ses'
	est sto er3`i' 
	loc i = `i' + 1		
	loc keepv "`indicator' quality `keepv'"		
		
	
* Gen tables
		
esttab er1* using `path'/_tables/e3_tab_main.tex, replace  ///
	keep(*quality* ) ///
	rename(`keepv')  ///
	stat(r2 )  b(3) se nostar		
esttab reg* using `path'/_tables/e3_tab_main.tex, append order(quality cases vaccall_day  population `indwgt'_hhi_beds `indwgt'_nrhosphrr `indwgt'_Disc_ACSC ) ///
	keep(*quality* ) ///
	rename(`keepv')  ///
	mtitle("Base" "Zip Pop" "Skinner" "Equal" "Pooled Q" "ExcessRR" "Mortrate PN" "All readrate") ///
	stat(N me sd mf stad r2 , fmt(%9.0fc %9.2fc %9.2fc %9.2fc %9.3fc))  b(3) se  nostar 
esttab er2* using `path'/_tables/e3_tab_main.tex, append  ///
	keep(*quality* ) ///
	rename(`keepv')  ///
	stat(r2 )  b(3) se nostar
esttab er3* using `path'/_tables/e3_tab_main.tex, append  ///
	keep(*quality* ) ///
	rename(`keepv')  ///
	stat(r2 )  b(3) se nostar	
