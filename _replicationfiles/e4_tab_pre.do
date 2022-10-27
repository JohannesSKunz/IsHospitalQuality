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
	
 esttab reg1_*   using `path'/_tables/e4_tab_pre.tex , replace b(2)  se keep(quality) rename(`indicator' quality) nostar stats(N me sd)
 esttab reg2_*   using `path'/_tables/e4_tab_pre.tex , append  b(2)  se keep(quality) rename(`indicator' quality) nostar stats(N)
 esttab reg3_*   using `path'/_tables/e4_tab_pre.tex , append  b(2)  se keep(quality) rename(`indicator' quality) nostar stats(N me sd)
 esttab reg4_*   using `path'/_tables/e4_tab_pre.tex , append  b(2)  se keep(quality) rename(`indicator' quality) nostar stats(N)
