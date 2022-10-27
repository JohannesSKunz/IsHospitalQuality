clear all 
set more off 
tempfile temp temp1 temp2 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/hopsital_quanity_covid/data_final/mainfiles/"
set matsize 10000

* -----------------------------------------------------------------------------
* path
loc estdate   "21_11_19"
loc datedata  "21_11_20"
loc path "/Users/jkun0001/Dropbox/workingpapers/KunzPropper/_estimation/`estdate'_estimation/"
loc coviddatenr3 "531" //

* -----------------------------------------------------------------------------
* add weekly&monthly indicators
import delimited /Users/jkun0001/Desktop/_data/Hospitalcompare/hopsital_quanity_covid/data_final/processedfiles/weeklymerge.csv, clear 
rename ïdays day
save `temp1'

* -----------------------------------------------------------------------------
* Data
use `datedata'_maindata.dta


* --------------------------------------------
* Quality 
* Reverse quality: do all
loc indwgt		 "zipwgt" // "afact" // "zipwgt" // "equwgt" //
loc indicator 	 "`indwgt'_phi_brglmpenalty3" // "`indwgt'_phi_brglmpenalty_pool" // "`indwgt'_exreadmisratio3" // "`indwgt'_mort_rate3" // "`indwgt'_all_readm_rate" // "`indwgt'_phi_brglmpenalty3" // "`indwgt'_exreadmisratio3" //   "zipwgt_phi_brglmpenalty3" // "zipwgt_phi_brglmpenalty3" // "zippopwgt_phi_brglmpenalty_pool" // "equwgt_phi_brglmpenalty1" // zipwgt_phi_brglmpenalty1

replace `indicator' = 1- `indicator'
su `indicator'
sca stad = r(sd) 

* -----------------------------------------------------------------------------
* Analysis 
loc i = 1

forval i = 5/`coviddatenr3' {
		qui replace deaths_day`i'=(deaths_day`i'/population)*10000
		qui replace cases_day`i'=cases_day`i'/10000
		cap gen vacc_day`i' = 0
		cap replace vacc_day`i'=vacc_nrall_day`i'/10000
		}

	su 	deaths_day62
	
* -----------------------
* Joint model, stacked 
loc indwgt		 "zipwgt" // "afact" // "zipwgt" // "equwgt" //
loc indicator 	 "`indwgt'_phi_brglmpenalty3" // "`indwgt'_phi_brglmpenalty_pool" // "`indwgt'_exreadmisratio3" // "`indwgt'_mort_rate3" // "`indwgt'_all_readm_rate" // "`indwgt'_phi_brglmpenalty3" // "`indwgt'_exreadmisratio3" //   "zipwgt_phi_brglmpenalty3" // "zipwgt_phi_brglmpenalty3" // "zippopwgt_phi_brglmpenalty_pool" // "equwgt_phi_brglmpenalty1" // zipwgt_phi_brglmpenalty1
loc outcome 	 "deaths" // cases
loc ses 		 "robust" // "cluster(state)" // "robust"
loc covarsHRR 	 "`indwgt'_hhi_beds `indwgt'_nrhosphrr " // "zipwgt_hhi_beds zipwgt_nrhosphrr zipwgt_Disc_ACSC"
loc covarsECON	 "PovertyPercentAllAges MedianHouseholdIncome uninsuredrawvalue"
loc covarsHeal 	 "prematuredeathrawvalue poororfairhealthrawvalue poorphysicalhealthdaysrawvalue poormentalhealthdaysrawvalue physicalinactivityrawvalue lifeexpectancyrawvalue"
loc covarsQual 	 "airpollutionparticulatematterraw fluvaccinationsrawvalue preventablehospitalstaysrawvalue adultsmokingrawvalue drinkingwaterviolationsrawvalue drivingalonetoworkrawvalue"
loc covarsCom 	 "CountyLevelIndex CommunityHealth InstitutionalHealth voteshare_rep2020" //
loc covarsPoP 	 "pop_acs_share_hisp pop_acs_share_nh_black pop_acs_share_nh_other popdensity2010 age65andolderpct2010 foreignbornpct ed1lessthanhspct ed2hsdiplomaonlypct ed3somecollegepct ed4assocdegreepct avghhsize hh65plusalonepct"
loc covars       "`covarsECON' `covarsCom' `covarsPoP' `covarsHeal' `covarsQual' residentialsegregationblackwhite "

*loc othervarsused "vaccall_day"
loc othervarsused "longcommutedrivingalonerawvalue zipwgt_ResidentPopulation2010 zipwgt_TotPhysper100000 zipwgt_HospBasedPhysper10 zipwgt_CritCarePhysper100 zipwgt_InfecDisSpecper100 zipwgt_AcCareHospBedsper10 zipwgt_HospbasedRegNurper1 zipwgt_FTEHospEmpper1000        zippopwgt_ResidentPopulation2010 zippopwgt_TotPhysper100000 zippopwgt_HospBasedPhysper10 zippopwgt_CritCarePhysper100 zippopwgt_InfecDisSpecper100 zippopwgt_AcCareHospBedsper10 zippopwgt_HospbasedRegNurper1 zippopwgt_FTEHospEmpper1000 zipwgt_popinhrr zipwgt_teach zipwgt_hospperhead zipwgt_nrhospitalshrr zipwgt_nrbedshrr zippopwgt_nrhosphrr zippopwgt_hhi_beds primarycarephysiciansrawvalue preventablehospitalstaysrawvalue zipwgt_Disc_ACSC urban metrourban voteshare_rep2020 voteshare_rep2016 voteshare_rep2012 repubican_majority2012 repubican_majority2016 repubican_majority2020 zipwgt_phi_brglmpenalty1 prematureageadjustedmortalityraw whitenonhispanicpct2010 zipwgt_all_readm_rate zipwgt_mort_rate3 zipwgt_exreadmisratio3 zipwgt_phi_brglmpenalty_pool equwgt_phi_brglmpenalty3 zippopwgt_phi_brglmpenalty3 afact_phi_brglmpenalty3"

keep population `othervarsused' countyfips deaths_day* cases_day* vacc_day* `indicator' `indwgt'_hhi_beds `indwgt'_nrhosphrr `covarsHRR' `covars' statefips state
reshape long deaths_day  cases_day vacc_day, i(countyfips) j(day) 

drop if deaths_day<0
g logdeaths_day_1  = log(deaths_day+1)
g logdeaths_day    = log(deaths_day)
g arcsindeaths_day = log(deaths_day + sqrt(deaths_day^2+1))

replace cases_day = 0 if cases_day ==. | cases_day < 0
replace vacc_day  = 0 if vacc_day ==.   | vacc_day < 0 
replace deaths_day  = 0 if deaths_day ==.   | deaths_day < 0 

* --------------------------------------------
* Merge in weekly 
merge m:1 day using `temp1' , nogen
* Merge in state-day level policies 
merge m:1 state day using ../processedfiles/statedaylevel_covidpolicy , keep(1 3) nogen 

compress 
save ../mainfiles/`datedata'_maindata_adj, replace 





	
