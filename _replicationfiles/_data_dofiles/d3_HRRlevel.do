*******************************
* 19.11.21 Kunz and Propper
* Generates a HRR level file
*******************************

clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/hopsital_quanity_covid/data_final/sourcefiles/"
tempfile temp 

* ------------------------------------------------------------------------------
* Load in Dartmouth: Capacity data
import excel 2012_hosp_resource_hrr.xls, sheet("2012_hosp_resource_hrr") firstrow clear
save `temp' , replace 

import excel 2011_phys_hrr.xls, sheet("2011_phys_hrr") firstrow clear
merge 1:1 HRR using `temp', nogen
keep HRR ResidentPopulation2010 TotalPhysiciansper100000Res HospitalBasedPhysiciansper10 CriticalCarePhysiciansper100 InfectiousDiseaseSpecialistsp AcuteCareHospitalBedsper10 HospitalbasedRegisteredNurses FTEHospitalEmployeesper1000
rename HRR hrrnum
save `temp' , replace 


* ------------------------------------------------------------------------------
* HRR-leveldata
use KPSW_20_01_08_data_alphas.dta, clear 

* Prepare data used: 
keep beds teach nrbedshrr popinhrr hospperhead numberofdischarges hrrnum year measure providerid DischargesforAmbulatoryCareS nrhosphrr hhi_beds  totnumdicarges_other mort_rate all_readm_rate phi_alpha_brglm_penalty_pooled phi_alpha_brglm_penalty excessreadmissionratio
order providerid measure year hrrnum
sort providerid measure year 

* Reshape to get at measure specific quality 
egen prodiveridyear=group(providerid year)

reshape wide numberofdischarges excessreadmissionratio totnumdicarges_other mort_rate phi_alpha_brglm_penalty, i(prodiveridyear) j(measure)
* 1 AMI, 2 HF, 3 PN
order providerid year hrrnum

* Quality measures: mean/medi/last 
* for now mean across 2011-2016

bys providerid (year): g nrhospitalshrr = _n
replace nrhospitalshrr = . if nrhospitalshrr>1

collapse (max) teach (sum) nrhospitalshrr (mean) numberofdischarges3 excessreadmissionratio1 totnumdicarges_other1 mort_rate1  phi_alpha_brglm_penalty1 excessreadmissionratio2 totnumdicarges_other2 mort_rate2  phi_alpha_brglm_penalty2 excessreadmissionratio3 totnumdicarges_other3 mort_rate3  phi_alpha_brglm_penalty3 phi_alpha_brglm_penalty_pooled all_readm_rate (first)  DischargesforAmbulatoryCareS nrhosphrr hhi_beds nrbedshrr popinhrr hospperhead, by(hrrnum)
drop if hrrnum=="."
sort hrrnum

rename phi_alpha_brglm_penalty1 phi_brglmpenalty1
rename phi_alpha_brglm_penalty2 phi_brglmpenalty2
rename phi_alpha_brglm_penalty3 phi_brglmpenalty3
rename phi_alpha_brglm_penalty_pooled phi_brglmpenalty_pool
rename DischargesforAmbulatoryCareS Disc_ACSC

lab var excessreadmissionratio1 "KPSW Averge2012-2016: ERR AMI"
lab var excessreadmissionratio2 "KPSW Averge2012-2016: ERR HF"
lab var excessreadmissionratio3 "KPSW Averge2012-2016: ERR PN"

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

destring hrrnum, force replace 
merge m:1 hrrnum using `temp', keep(1 3) nogen
tostring hrrnum, replace 

compress 
save ../processedfiles/hhrvariables, replace 

