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

keep if day == `coviddatenr'
su `indicator'
sca stad = r(sd) 

* Analysis 
loc i = 1
loc title ""
g minorty = 100 -  whitenonhispanicpct2010

* continuous 
loc variables1 "primarycarephysiciansrawvalue preventablehospitalstaysrawvalue PovertyPercentAllAges  uninsuredrawvalue  age65andolderpct2010 popdensity2010 longcommutedrivingalonerawvalue residentialsegregationblackwhite minorty CommunityHealth InstitutionalHealth voteshare_rep2020"
* dummies
loc variables2 "metro"

loc count: word count `variables1' `variables2'
        matrix A = J(5,`count',.)
        matrix rownames A = coef ll95 ul95 ll90 ul90
        matrix colnames A = `vars'
        matrix B = J(5,`count',.)
        matrix rownames B = coef ll95 ul95 ll90 ul90
        matrix colnames B = `vars'
        matrix C = J(5,`count',.)

foreach var of local variables1  {
	su `var' , d
	g med = `var' >=r(p50)
	g d_`indicator' = `indicator'*med
	g d1_`indicator' = `indicator'*(1-med)
	reg deaths_day 				d_`indicator' d1_`indicator' med cases_day  vacc_day `var'  `covariates' , `ses'
	est sto reg1_`i' 
		qui su `e(depvar)' if e(sample) == 1 & med == 1 
		estadd sca me1 = r(mean) , :reg1_`i'
		estadd sca sd = r(sd)   , :reg1_`i'
		estadd sca mf1 = (_b[d_`indicator']*stad)/r(mean)   , :reg1_`i'	

			sca lb=  _b[d_`indicator']-1.96*_se[d_`indicator']
			sca lb1= _b[d_`indicator']-1.645*_se[d_`indicator']    
			sca ub=  _b[d_`indicator']+1.96*_se[d_`indicator']
			sca ub1= _b[d_`indicator']+1.645*_se[d_`indicator']
            matrix A[1,`i'] = _b[d_`indicator'] \ lb \ ub \ lb1 \ ub1		
		
		qui su `e(depvar)' if e(sample) == 1 & med == 0 
		estadd sca me2 = r(mean) , :reg1_`i'
		estadd sca mf2 = (_b[d1_`indicator']*stad)/r(mean)   , :reg1_`i'	

			sca lb=  _b[d1_`indicator']-1.96*_se[d1_`indicator']
			sca lb1= _b[d1_`indicator']-1.645*_se[d1_`indicator']    
			sca ub=  _b[d1_`indicator']+1.96*_se[d1_`indicator']
			sca ub1= _b[d1_`indicator']+1.645*_se[d1_`indicator']
            matrix B[1,`i'] = _b[d1_`indicator'] \ lb \ ub \ lb1 \ ub1			
		
		test d_`indicator' = d1_`indicator'
		local pF`i' : di %3.2fc r(p) 
		estadd sca pF = r(p)   , :reg1_`i'

		loc i = `i' + 1
		drop med d_`indicator'  d1_`indicator'
		loc title " `title' `"`var'"'"
		}
		
* For dummies		
foreach var of local variables2  {
	*	su `var' , d
	g med = `var' == 1 
	g d_`indicator' = `indicator'*med
	g d1_`indicator' = `indicator'*(1-med)
	reg deaths_day 				d_`indicator' d1_`indicator' med cases_day  vacc_day `var'  `covariates' , `ses'
	est sto reg1_`i' 
		qui su `e(depvar)' if e(sample) == 1 & med == 1 
		estadd sca me1 = r(mean) , :reg1_`i'
		estadd sca sd = r(sd)   , :reg1_`i'
		estadd sca mf1 = (_b[d_`indicator']*stad)/r(mean)   , :reg1_`i'	

			sca lb=  _b[d_`indicator']-1.96*_se[d_`indicator']
			sca lb1= _b[d_`indicator']-1.645*_se[d_`indicator']    
			sca ub=  _b[d_`indicator']+1.96*_se[d_`indicator']
			sca ub1= _b[d_`indicator']+1.645*_se[d_`indicator']
            matrix A[1,`i'] = _b[d_`indicator'] \ lb \ ub \ lb1 \ ub1		
		
		qui su `e(depvar)' if e(sample) == 1 & med == 0 
		estadd sca me2 = r(mean) , :reg1_`i'
		estadd sca mf2 = (_b[d1_`indicator']*stad)/r(mean)   , :reg1_`i'	

			sca lb=  _b[d1_`indicator']-1.96*_se[d1_`indicator']
			sca lb1= _b[d1_`indicator']-1.645*_se[d1_`indicator']    
			sca ub=  _b[d1_`indicator']+1.96*_se[d1_`indicator']
			sca ub1= _b[d1_`indicator']+1.645*_se[d1_`indicator']
            matrix B[1,`i'] = _b[d1_`indicator'] \ lb \ ub \ lb1 \ ub1			
		
		test d_`indicator' = d1_`indicator'
		local pF`i' : di %3.2fc r(p) 
		estadd sca pF = r(p)   , :reg1_`i'

		loc i = `i' + 1
		drop med d_`indicator'  d1_`indicator'
		loc title " `title' `"`var'"'"
		}		

* Make figure		
        coefplot matrix(A) matrix(B), ///
			ylab(, labs(small)) xlab(, labs(small))  /// 
			xline(0, lc(red) lp(dash)) ///
			ciopts(lwidth(.35 .35) lcolor(*1 *.6)) ci((2 3) (4 5) ) ///
			fxsize(125) fysize(100) ///
			scheme(s2mono) graphregion(color(white) margin(0 0 0 0)) bgcolor(white) ///
			order(c1 c2 c3 c4 c5 c6 c7 c13 c8 c9 c10 c11 c12) ///
			headings(c1 = "Local area demographics" ///
					 c10 = "Social Capital") ///
			legend(order(1 "Yes/above med" 4 "No/below med") row(2) size(small) region(lcolor(white))) ///
				coeflab( ///
				c1		=       `"# of prim. care phys. (p-val=`pF1')"' ///
				c2		= 	    `"Preventable hospital stays (p-val=`pF2')"' ///
				c3		= 	    `"Percent in poverty (p-val=`pF3')"' ///
				c4      =		`"Share uninsured (p-val=`pF4')"' ///
				c5      = 		`"Share Age > 65 (p-val=`pF5')"' ///
				c6      = 		`"Population Denisty (p-val=`pF6')"' ///
				c7     =	    `"Long distance commute (p-val=`pF7')"' ///
				c8     =	    `"Residential segregation (p-val=`pF8')"' ///
 				c9     = 		`"Share minorities (p-val=`pF9')"' ///
 				c10     = 		`"Community (p-val=`pF10')"' ///
 				c11     = 		`"Institutional (p-val=`pF11')"' ///
 				c12     = 		`"Rep. vote share 2020 (p-val=`pF12')"' ///
				c13		= 		`"Metro (p-val=`pF13')"' ///
				) name(gr1, replace)	
	esttab reg1_* using `path'/_tables/e5_tab_het.tex, replace  keep(*`indicator') b(3) se stats(N me mf1 mf2 sd r2 pF  , fmt(%9.0f %9.2fc )) mtitle(`title') nostar

	
* ------------------------------------------------------------	
* Analysis part two capacity
loc i = 1
loc title ""
g StateMajorFinHealthSupport = sum_invest > 0 
g TeachHospExposed  = zipwgt_teach == 3 

corr zipwgt_AcCareHospBedsper10 zipwgt_HospbasedRegNurper1 zipwgt_HospBasedPhysper10 metrourban

pca zipwgt_TotPhysper100000 zipwgt_HospBasedPhysper10 zipwgt_CritCarePhysper100 zipwgt_InfecDisSpecper100 zipwgt_AcCareHospBedsper10 zipwgt_FTEHospEmpper1000 zipwgt_HospbasedRegNurper1 TeachHospExposed metrourban urban longcommutedrivingalonerawvalue popdensity2010
predict princ_1 

* continuous 
*loc variables1 "zipwgt_TotPhysper100000 zipwgt_HospBasedPhysper10 zipwgt_HospbasedRegNurper1" 
loc variables1 " zippopwgt_nrhosphrr zipwgt_AcCareHospBedsper10 zipwgt_TotPhysper100000 zipwgt_HospBasedPhysper10 zipwgt_CritCarePhysper100  zipwgt_FTEHospEmpper1000 zipwgt_HospbasedRegNurper1 vacc_day"
* dummies
*loc variables2 ""
loc variables2 "TeachHospExposed StateMajorFinHealthSupport"

loc count: word count `variables1' `variables2'
        *sysuse auto, clear
        matrix A = J(5,`count',.)
        matrix rownames A = coef ll95 ul95 ll90 ul90
        matrix colnames A = `vars'
        matrix B = J(5,`count',.)
        matrix rownames B = coef ll95 ul95 ll90 ul90
        matrix colnames B = `vars'
        matrix C = J(5,`count',.)

foreach var of local variables1  {
	su `var' , d
	g med = `var' >=r(p50)
	g d_`indicator' = `indicator'*med
	g d1_`indicator' = `indicator'*(1-med)
	reg deaths_day 				d_`indicator' d1_`indicator' cases_day  vacc_day  med `var' `covariates' , `ses'
	est sto reg1_`i' 
		qui su `e(depvar)' if e(sample) == 1 & med == 1 
		estadd sca me1 = r(mean) , :reg1_`i'
		estadd sca sd = r(sd)   , :reg1_`i'
		estadd sca mf1 = (_b[d_`indicator']*stad)/r(mean)   , :reg1_`i'	

			sca lb=  _b[d_`indicator']-1.96*_se[d_`indicator']
			sca lb1= _b[d_`indicator']-1.645*_se[d_`indicator']    
			sca ub=  _b[d_`indicator']+1.96*_se[d_`indicator']
			sca ub1= _b[d_`indicator']+1.645*_se[d_`indicator']
            matrix A[1,`i'] = _b[d_`indicator'] \ lb \ ub \ lb1 \ ub1		
		
		qui su `e(depvar)' if e(sample) == 1 & med == 0 
		estadd sca me2 = r(mean) , :reg1_`i'
		estadd sca mf2 = (_b[d1_`indicator']*stad)/r(mean)   , :reg1_`i'	

			sca lb=  _b[d1_`indicator']-1.96*_se[d1_`indicator']
			sca lb1= _b[d1_`indicator']-1.645*_se[d1_`indicator']    
			sca ub=  _b[d1_`indicator']+1.96*_se[d1_`indicator']
			sca ub1= _b[d1_`indicator']+1.645*_se[d1_`indicator']
            matrix B[1,`i'] = _b[d1_`indicator'] \ lb \ ub \ lb1 \ ub1			
		
		test d_`indicator' = d1_`indicator'
		local pF`i' : di %3.2fc r(p) 
		estadd sca pF = r(p)   , :reg1_`i'
		local name`i' "`var'"

		loc i = `i' + 1
		drop med d_`indicator'  d1_`indicator'
		loc title " `title' `"`var'"'"
		}
		
* For indicators 		
foreach var of local variables2  {
	g med = `var' == 1 
	g d_`indicator' = `indicator'*med
	g d1_`indicator' = `indicator'*(1-med)
	reg deaths_day 				d_`indicator' d1_`indicator' cases_day  vacc_day med `var' `covariates' , `ses'
	est sto reg1_`i' 
		qui su `e(depvar)' if e(sample) == 1 & med == 1 
		estadd sca me1 = r(mean) , :reg1_`i'
		estadd sca sd = r(sd)   , :reg1_`i'
		estadd sca mf1 = (_b[d_`indicator']*stad)/r(mean)   , :reg1_`i'	

			sca lb=  _b[d_`indicator']-1.96*_se[d_`indicator']
			sca lb1= _b[d_`indicator']-1.645*_se[d_`indicator']    
			sca ub=  _b[d_`indicator']+1.96*_se[d_`indicator']
			sca ub1= _b[d_`indicator']+1.645*_se[d_`indicator']
            matrix A[1,`i'] = _b[d_`indicator'] \ lb \ ub \ lb1 \ ub1		
		
		qui su `e(depvar)' if e(sample) == 1 & med == 0 
		estadd sca me2 = r(mean) , :reg1_`i'
		estadd sca mf2 = (_b[d1_`indicator']*stad)/r(mean)   , :reg1_`i'	

			sca lb=  _b[d1_`indicator']-1.96*_se[d1_`indicator']
			sca lb1= _b[d1_`indicator']-1.645*_se[d1_`indicator']    
			sca ub=  _b[d1_`indicator']+1.96*_se[d1_`indicator']
			sca ub1= _b[d1_`indicator']+1.645*_se[d1_`indicator']
            matrix B[1,`i'] = _b[d1_`indicator'] \ lb \ ub \ lb1 \ ub1			
		
		test d_`indicator' = d1_`indicator'
		local pF`i' : di %3.2fc r(p) 
		estadd sca pF = r(p)   , :reg1_`i'
		local name`i' "`var'"

		loc i = `i' + 1
		drop med d_`indicator'  d1_`indicator'
		loc title " `title' `"`var'"'"
		}		
		
        coefplot matrix(A) matrix(B), ///
			ylab(, labs(small)) xlab(, labs(small))  /// 
			xline(0, lc(red) lp(dash)) ///
			fxsize(150) fysize(100) ///
			ciopts(lwidth(.35 .35) lcolor(*1 *.6)) ci((2 3) (4 5) ) ///
			scheme(s2mono) graphregion(color(white) margin(0 0 0 0)) bgcolor(white) ///
			order(c1 c2 c3 c4 c5 c6 c7 c9 c10 c8) ///
			headings(c1 = "Hospital capacity" ///
					 c10 = "Vaccination & Financing") ///
			legend(order(1 "Yes/above med" 4 "No/below med") row(2) size(small) region(lcolor(white))) ///
				coeflab( ///
				c1		=       `"# of hospitals (p-val=`pF1')"' ///
				c2		=       `"Accute care beds per 10T (p-val=`pF2')"' ///
				c3		=       `"Physicians per 100T (p-val=`pF3')"' ///
				c4		= 	    `"Hospital-based physicians per 10T (p-val=`pF4')"' ///
				c5		= 	    `"Critical care physicians per 100T (p-val=`pF5')"' ///
				c6      =		`"FTE hospital staff per 1T (p-val=`pF6')"' ///
				c7      = 		`"Hospital-based reg. nurses p 1T (p-val=`pF7')"' ///
				c9      = 		`"A teaching hospital in catchment (p-val=`pF9')"' ///
				c10      = 		`"State financial health support (p-val=`pF10')"' ///
				c8      = 		`"Vaccinations (p-val=`pF8')"' ///
				) name(gr2, replace)	
		
grc1leg  gr1 gr2 , ysize(15) xsize(18)  xcommon legendfrom(gr1) scheme(s2mono) graphregion(color(white)) title("Heterogenity by median split" "Dark above median", size(small)) 
		graph export `path'/_figures/e5_fig_het.png , replace 				
		graph export `path'/_figures/e5_fig_het.tif , replace 				
		
esttab reg1_* using `path'/_tables/e5_tab_het.tex, append  keep(*`indicator') b(3) se stats(N me mf1 mf2 sd r2 pF  , fmt(%9.0f %9.2fc )) mtitle(`title') nostar

