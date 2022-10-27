*******************************
* 19.11.21 Kunz and Propper
* Generates a HRR-quality level 
*******************************

clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/hopsital_quanity_covid/data_final/sourcefiles/"
tempfile temp temp1 temp2 temp3 temp4 

loc var_hrr "ResidentPopulation2010 TotPhysper100000 HospBasedPhysper10 CritCarePhysper100 InfecDisSpecper100 AcCareHospBedsper10 HospbasedRegNurper1 FTEHospEmpper1000 nrbedshrr popinhrr hospperhead teach nrhospitalshrr numberofdischarges3 excessreadmissionratio1 totnumdicarges_other1 mort_rate1 phi_brglmpenalty1 excessreadmissionratio2 totnumdicarges_other2 mort_rate2 phi_brglmpenalty2 excessreadmissionratio3 totnumdicarges_other3 mort_rate3 phi_brglmpenalty3 phi_brglmpenalty_pool all_readm_rate Disc_ACSC nrhosphrr hhi_beds"
loc var_hrr2 "ResidentPopulation2010 TotPhysper100000 HospBasedPhysper10 CritCarePhysper100 InfecDisSpecper100 AcCareHospBedsper10 HospbasedRegNurper1 FTEHospEmpper1000 nrbedshrr popinhrr hospperhead teach nrhospitalshrr numberofdischarges3 exreadmisratio1 totnumdicarges_other1 mort_rate1 phi_brglmpenalty1 exreadmisratio2 totnumdicarges_other2 mort_rate2 phi_brglmpenalty2 exreadmisratio3 totnumdicarges_other3 mort_rate3 phi_brglmpenalty3 phi_brglmpenalty_pool all_readm_rate Disc_ACSC nrhosphrr hhi_beds"

* ------------------
* Prep new crosswalk 
import delimited geocorr2014.csv, varnames(1)  clear 
drop if county == "County code"
destring afact pop10 county , force replace 
rename hrr hrrnum 
rename county countyfips 
save `temp' , replace 

* ------------------------------------------------------------------------------
* Start with county 
use ../processedfiles/countyvariables , clear 

* Crosswalk
merge 1:m countyfips using ../processedfiles/crosswalk_county_hrr.dta, nogen
sort countyfips hrrnum
order countyfips hrrnum zip_count_weight_in_HRR equal_weight_inHRR

* Geocodes - Dartmouth
merge 1:m countyfips hrrnum using `temp' , nogen keepusing(afact) 

* HRR level data
merge m:1 hrrnum using ../processedfiles/hhrvariables , nogen
save `temp1', replace 
 
* ------------------------------------------------------------------------------
* Can either collapse based on weighting zip-count or equal 
rename TotalPhysiciansper100000Res TotPhysper100000 //names too long
rename HospitalBasedPhysiciansper10 HospBasedPhysper10
rename CriticalCarePhysiciansper100 CritCarePhysper100
rename InfectiousDiseaseSpecialistsp InfecDisSpecper100
rename AcuteCareHospitalBedsper10 AcCareHospBedsper10
rename HospitalbasedRegisteredNurses HospbasedRegNurper1
rename FTEHospitalEmployeesper1000 FTEHospEmpper1000

keep countyfips zippop*  afact zip_count_weight_in_HRR equal_weight_inHRR `var_hrr'

bys countyfips: egen max_teach = max(teach)
replace teach = max_teach

* ---------------
preserve
collapse (mean) `var_hrr' [aw=equal_weight_inHRR] , by(countyfips)

rename excessreadmissionratio1 exreadmisratio1
lab var exreadmisratio1 "KPSW Averge2012-2016: ERR AMI"
rename excessreadmissionratio2 exreadmisratio2
lab var exreadmisratio2 "KPSW Averge2012-2016: ERR HF"
rename excessreadmissionratio3 exreadmisratio3
lab var exreadmisratio3 "KPSW Averge2012-2016: ERR PN"

lab var totnumdicarges_other1 "KPSW Averge2012-2016: Total Discarges AMI"
lab var totnumdicarges_other2 "KPSW Averge2012-2016: Total Discarges HF"
lab var totnumdicarges_other3 "KPSW Averge2012-2016: Total Discarges PN"

lab var mort_rate1 "KPSW Averge2012-2016: Sacarny Mortality AMI"
lab var mort_rate2 "KPSW Averge2012-2016: Sacarny Mortality HF"
lab var mort_rate3 "KPSW Averge2012-2016: Sacarny Mortality PN"

lab var phi_brglmpenalty1 "KPSW Averge2012-2016: BRGLMpenalty AMI"
lab var phi_brglmpenalty2 "KPSW Averge2012-2016: BRGLMpenalty HF"
lab var phi_brglmpenalty3 "KPSW Averge2012-2016: BRGLMpenalty PN"

lab var phi_brglmpenalty_pool "KPSW Averge2012-2016: BRGLMpenalty Pooled"
lab var all_readm_rate "KPSW Averge2012-2016: Sacarny RRall Pooled"

lab var Disc_ACSC "KPSW Averge2012-2016: Dischagres ACSC in HRR"
lab var nrhosphrr  "KPSW Averge2012-2016: Number hosptials in HRR"
lab var nrhospitalshrr "KPSW Averge2012-2016: Number hosptials with ECR in HRR"
lab var hhi_beds  "KPSW Averge2012-2016: HHI beds in HRR"

foreach var of local var_hrr2 {
	rename `var' equwgt_`var'
	}
	
save `temp2', replace 
	
* ---------------
restore 
preserve
collapse (mean) `var_hrr' [aw=zippop_count_weight_in_HRR] , by(countyfips)

rename excessreadmissionratio1 exreadmisratio1
lab var exreadmisratio1 "KPSW Averge2012-2016: ERR AMI"
rename excessreadmissionratio2 exreadmisratio2
lab var exreadmisratio2 "KPSW Averge2012-2016: ERR HF"
rename excessreadmissionratio3 exreadmisratio3
lab var exreadmisratio3 "KPSW Averge2012-2016: ERR PN"

lab var totnumdicarges_other1 "KPSW Averge2012-2016: Total Discarges AMI"
lab var totnumdicarges_other2 "KPSW Averge2012-2016: Total Discarges HF"
lab var totnumdicarges_other3 "KPSW Averge2012-2016: Total Discarges PN"

lab var mort_rate1 "KPSW Averge2012-2016: Sacarny Mortality AMI"
lab var mort_rate2 "KPSW Averge2012-2016: Sacarny Mortality HF"
lab var mort_rate3 "KPSW Averge2012-2016: Sacarny Mortality PN"

lab var phi_brglmpenalty1 "KPSW Averge2012-2016: BRGLMpenalty AMI"
lab var phi_brglmpenalty2 "KPSW Averge2012-2016: BRGLMpenalty HF"
lab var phi_brglmpenalty3 "KPSW Averge2012-2016: BRGLMpenalty PN"

lab var phi_brglmpenalty_pool "KPSW Averge2012-2016: BRGLMpenalty Pooled"
lab var all_readm_rate "KPSW Averge2012-2016: Sacarny RRall Pooled"

lab var Disc_ACSC "KPSW Averge2012-2016: Dischagres ACSC in HRR"
lab var nrhosphrr  "KPSW Averge2012-2016: Number hosptials in HRR"
lab var nrhospitalshrr "KPSW Averge2012-2016: Number hosptials with ECR in HRR"
lab var hhi_beds  "KPSW Averge2012-2016: HHI beds in HRR"

foreach var of local var_hrr2 {
	rename `var' zippopwgt_`var'
	}
	
	
save `temp3', replace 
	
* ---------------
restore 
preserve
collapse (mean) `var_hrr' [aw=afact] , by(countyfips)

rename excessreadmissionratio1 exreadmisratio1
lab var exreadmisratio1 "KPSW Averge2012-2016: ERR AMI"
rename excessreadmissionratio2 exreadmisratio2
lab var exreadmisratio2 "KPSW Averge2012-2016: ERR HF"
rename excessreadmissionratio3 exreadmisratio3
lab var exreadmisratio3 "KPSW Averge2012-2016: ERR PN"

lab var totnumdicarges_other1 "KPSW Averge2012-2016: Total Discarges AMI"
lab var totnumdicarges_other2 "KPSW Averge2012-2016: Total Discarges HF"
lab var totnumdicarges_other3 "KPSW Averge2012-2016: Total Discarges PN"

lab var mort_rate1 "KPSW Averge2012-2016: Sacarny Mortality AMI"
lab var mort_rate2 "KPSW Averge2012-2016: Sacarny Mortality HF"
lab var mort_rate3 "KPSW Averge2012-2016: Sacarny Mortality PN"

lab var phi_brglmpenalty1 "KPSW Averge2012-2016: BRGLMpenalty AMI"
lab var phi_brglmpenalty2 "KPSW Averge2012-2016: BRGLMpenalty HF"
lab var phi_brglmpenalty3 "KPSW Averge2012-2016: BRGLMpenalty PN"

lab var phi_brglmpenalty_pool "KPSW Averge2012-2016: BRGLMpenalty Pooled"
lab var all_readm_rate "KPSW Averge2012-2016: Sacarny RRall Pooled"

lab var Disc_ACSC "KPSW Averge2012-2016: Dischagres ACSC in HRR"
lab var nrhosphrr  "KPSW Averge2012-2016: Number hosptials in HRR"
lab var nrhospitalshrr "KPSW Averge2012-2016: Number hosptials with ECR in HRR"
lab var hhi_beds  "KPSW Averge2012-2016: HHI beds in HRR"

foreach var of local var_hrr2 {
	rename `var' afact_`var'
	}
	
	
save `temp4', replace 	
	
	
* ---------------
restore
collapse (mean) `var_hrr' [aw=zip_count_weight_in_HRR] , by(countyfips)

rename excessreadmissionratio1 exreadmisratio1
lab var exreadmisratio1 "KPSW Averge2012-2016: ERR AMI"
rename excessreadmissionratio2 exreadmisratio2
lab var exreadmisratio2 "KPSW Averge2012-2016: ERR HF"
rename excessreadmissionratio3 exreadmisratio3
lab var exreadmisratio3 "KPSW Averge2012-2016: ERR PN"

lab var totnumdicarges_other1 "KPSW Averge2012-2016: Total Discarges AMI"
lab var totnumdicarges_other2 "KPSW Averge2012-2016: Total Discarges HF"
lab var totnumdicarges_other3 "KPSW Averge2012-2016: Total Discarges PN"

lab var mort_rate1 "KPSW Averge2012-2016: Sacarny Mortality AMI"
lab var mort_rate2 "KPSW Averge2012-2016: Sacarny Mortality HF"
lab var mort_rate3 "KPSW Averge2012-2016: Sacarny Mortality PN"

lab var phi_brglmpenalty1 "KPSW Averge2012-2016: BRGLMpenalty AMI"
lab var phi_brglmpenalty2 "KPSW Averge2012-2016: BRGLMpenalty HF"
lab var phi_brglmpenalty3 "KPSW Averge2012-2016: BRGLMpenalty PN"

lab var phi_brglmpenalty_pool "KPSW Averge2012-2016: BRGLMpenalty Pooled"
lab var all_readm_rate "KPSW Averge2012-2016: Sacarny RRall Pooled"

lab var Disc_ACSC "KPSW Averge2012-2016: Dischagres ACSC in HRR"
lab var nrhosphrr  "KPSW Averge2012-2016: Number hosptials in HRR"
lab var nrhospitalshrr "KPSW Averge2012-2016: Number hosptials with ECR in HRR"
lab var hhi_beds  "KPSW Averge2012-2016: HHI beds in HRR"

foreach var of local var_hrr2 {
	rename `var' zipwgt_`var'
	}	
	
	
* ---------------
* ---------------
* ---------------
	
merge 1:1 countyfips using `temp2', nogen 
merge 1:1 countyfips using `temp3', nogen 
merge 1:1 countyfips using `temp4', nogen 
merge 1:1 countyfips using ../processedfiles/countyvariables.dta, nogen 

* Not used:
drop communicablediseaserawvalue opioidhospitalvisitsrawvalue olderadultslivingalonerawvalue
compress 	
save ../processedfiles/county_aveHRR , replace 
	
	
exit 
