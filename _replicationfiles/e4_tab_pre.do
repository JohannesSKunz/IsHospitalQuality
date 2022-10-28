* Kunz & Propper 
clear all 
set more off 
tempfile temp temp1 temp2 
cd "/Users/jkun0001/Desktop/_replicationfiles/"
set matsize 10000

* -----------------------------------------------------------------------------
* path
loc estdate   "22_06_10"
loc datedata  "21_11_20"
use maindata_tab2


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
loc covars " `covars'  *_m"
loc covariates " `covarsHRR' `covars'  i.statefips"


* estimate 
loc i = 1
loc j = 1

reg deaths 			`indicator' if year == 2016	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 	

reg deaths 			`indicator' if year == 2017	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 	
	
reg deaths 			`indicator' if year == 2018	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 	
	g tempsample = e(sample) == 1 //pedictions later on unreliable if missings
	bys countyfips: egen sample = max(tempsample) //need to aggregate by county 
	
reg deaths 			`indicator' if year == 2019	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 		



* ----------------
* Conditional 
loc i = `i' + 1 	
loc j = 1 	
reg deaths 			`indicator' `covariates' if year == 2016	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 	

reg deaths 			`indicator' `covariates' if year == 2017	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 	
	
reg deaths 			`indicator' `covariates' if year == 2018	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 	

reg deaths 			`indicator' `covariates' if year == 2019	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 
	
	
* ----------------
* Conditional 
loc indicator 	"zipwgt_phi_brglmpenalty3"
loc outcome 	"AMIdeaths_pop"
loc weights 	"" 
loc meth 		"poisson" 

loc i = `i' + 1 	
loc j = 1 	
`meth' `outcome'  			`indicator'  `weights' if year == 2016	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 	

`meth' `outcome'  			`indicator'  `weights' if year == 2017	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 	
	
`meth' `outcome'  			`indicator'  `weights' if year == 2018	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 	

`meth' `outcome'  			`indicator'  `weights' if year == 2019	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'	

	
* Conditional	
loc indicator 	"zipwgt_phi_brglmpenalty3"
loc outcome 	"AMIdeaths_pop"
loc weights 	"" 
loc meth 		"poisson" 
loc i = `i' + 1 	
loc j = 1 	
`meth' `outcome'  			`indicator' `covariates' `weights' if year == 2016	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 	

`meth' `outcome'  			`indicator' `covariates' `weights' if year == 2017	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 	
	
`meth' `outcome'  			`indicator' `covariates' `weights' if year == 2018	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'
	loc j = `j' + 1 	

`meth' `outcome'  			`indicator' `covariates' `weights' if year == 2019	, `ses'
	est sto reg`i'_`j' 
	qui su `e(depvar)' if e(sample) == 1
	estadd sca me = r(mean) , :reg`i'_`j'
	estadd sca sd = r(sd)   , :reg`i'_`j'	

* Gen tables 	
	
 esttab reg1_*   using e4_tab_pre.tex , replace b(2)  se keep(quality) rename(`indicator' quality) nostar stats(N me sd)
 esttab reg2_*   using e4_tab_pre.tex , append  b(2)  se keep(quality) rename(`indicator' quality) nostar stats(N)
 
 esttab reg3_*   using e4_tab_pre.tex , append  b(2)  se keep(quality) rename(`indicator' quality) nostar stats(N me sd)
 esttab reg4_*   using e4_tab_pre.tex , append  b(2)  se keep(quality) rename(`indicator' quality) nostar stats(N)
