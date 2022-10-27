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
* Missings 0  
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


* regressions 
keep if fourweeks==1

loc i = 1
loc j = 1
reg deaths_day cases_day vacc_day `indicator'  `covarsHRR' `covars2' i.statefips if day == 531 , cluster(countyfips)
eststo reg`i'_`j' 
loc j = `j'  + 1

reghdfe deaths_day i.day c.`indicator'#i.day ///
	c.`indwgt'_hhi_beds#i.day c.`indwgt'_nrhosphrr#i.day ///
	c.voteshare_rep2020#i.day ///
	c.pop_acs_share_hisp#i.day c.pop_acs_share_nh_black#i.day c.pop_acs_share_nh_other#i.day ///
	c.popdensity2010#i.day i.urban#i.day c.longcommutedrivingalonerawvalue#i.day ///
	c.age65andolderpct2010#i.day c.foreignbornpct#i.day ///
	c.ed1lessthanhspct#i.day c.ed2hsdiplomaonlypct#i.day c.ed3somecollegepct#i.day c.ed4assocdegreepct#i.day ///
	c.avghhsize#i.day c.hh65plusalonepct#i.day   ///
	c.airpollutionparticulatematterraw#i.day c.fluvaccinationsrawvalue#i.day c.preventablehospitalstaysrawvalue#i.day c.adultsmokingrawvalue#i.day c.drinkingwaterviolationsrawvalue#i.day c.drivingalonetoworkrawvalue#i.day ///
	c.PovertyPercentAllAges#i.day c.MedianHouseholdIncome#i.day c.uninsuredrawvalue#i.day ///
	c.prematuredeathrawvalue#i.day c.poororfairhealthrawvalue#i.day c.poorphysicalhealthdaysrawvalue#i.day c.poormentalhealthdaysrawvalue#i.day c.physicalinactivityrawvalue#i.day c.lifeexpectancyrawvalue#i.day ///
	c.CountyLevelIndex#i.day  c.CommunityHealth#i.day  c.InstitutionalHealth#i.day  ///
	c.residentialsegregationblackwhite#i.day i.statefips#i.day  ///
		, a(c.cases_day#i.day c.vacc_day#i.day ///
			c.miss_m#i.day c.miss1_m#i.day c.miss2_m#i.day c.miss3_m#i.day c.miss4_m#i.day c.miss5_m#i.day c.miss6_m#i.day c.miss7_m#i.day c.miss8_m#i.day c.miss9_m#i.day c.miss10_m#i.day c.miss11_m#i.day c.miss12_m#i.day c.miss13_m#i.day c.miss14_m#i.day c.miss15_m#i.day c.miss16_m#i.day c.miss17_m#i.day c.miss18_m#i.day c.miss19_m#i.day c.miss20_m#i.day c.miss21_m#i.day c.miss22_m#i.day c.miss23_m#i.day c.miss24_m#i.day c.miss25_m#i.day c.miss26_m#i.day c.miss27_m#i.day c.miss28_m#i.day c.miss29_m#i.day c.miss30_m#i.day) ///
		  cluster(countyfips)

	
eststo reg`i'_`j' 

* Verify they are identical: 
esttab reg1_1 reg1_2, keep(*brglmpenalty3*) b(3) se

* Figure
coefplot reg1_2, keep(*brglmpenalty3*)  ///
			msymbol(D) mcolor(gs20) msize(vsmall) ///
			ciopts(lwidth(.4 .4) lcolor(*0.8 *.4)) ci(95 90) ///
			vert ///
			xline(11.8, lc(gs10) lp(dash)) ///
			ylab(, labs(small))  /// 
			title ("Monthly COVID-19 deaths per 10,000 capita", size(medsmall)) ///
			xlab(0 "27" 1 "55" 2 "83" 3 "111" 4 "139" 5 "167" 6 "195" 7 "223" 8 "251" 9 "279" 10 "307" 11 "335" 12 "363" 13 "391" 14 "419" 15 "447" 16 "475" 17 "503" 18 "531" , angle(45) labs(medsmall)) ///
			xtitle("Days after the first COIVD-19 death in the US"  , s(medsmall)) ///
			yline(0, lc(red) lp(dash))  ///
			ytitle("Association: hopsital quality and deaths from Covid-19" "Regression coefficients (90, 95 pct confidence intervals)" , s(medsmall)) ///
			fxsize(100)   ///
			scheme(s2mono) graphregion(color(white)) bgcolor(white) ///
			legend(off) 
			
	graph export `path'/_figures/e2_fig_main.png , replace 				
	graph export `path'/_figures/e2_fig_main.tif , replace 				

