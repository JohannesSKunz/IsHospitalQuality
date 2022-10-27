******************************
* 19.11.21 Kunz and Propper
* Generates a crosswalk from 
* counties to HRR via zipcodes
******************************

clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/hopsital_quanity_covid/data_final/sourcefiles/"
tempfile temp temp1


* ------------------------------------------------------------------------------
* Zip code crosswalk: HRR 2017
import excel ZipHsaHrr17.xls, sheet("Sheet1") firstrow allstring clear
rename zipcode2017 zip 
rename hsastate state
replace zip = "0"  + zip if length(zip)==4
replace zip = "00" + zip if length(zip)==3
save `temp', replace

* ------------------------------------------------------------------------------
* Zip code population ZCTA
import delimited 2010CensusPopulationByZipcodeZCTA.csv, clear  stringc(1)
rename zipcodezcta zip
duplicates tag zip, gen(_dup)
collapse (sum) censuspopulation, by(zip)
rename censuspopulation zipcensus2010pop
merge 1:1 zip using `temp' , keep(2 3)
rename _merge zipop_hrr_merge
save `temp', replace

* ------------------------------------------------------------------------------
* Start with county by zipcode 2018
import delimited ZIP-COUNTY-FIPS_2018-03.csv, clear  stringcols(_all)

rename stcountyfp countyfips
destring countyfips , replace force 

* check duplicates 
duplicates tag zip countyfips , gen(_dup)
sort zip countyfips

* merge via zipcode to HRR 
merge m:1 zip using `temp'
replace  zipcensus2010pop = 0 if zipcensus2010pop==. 

* Some can not be merged 
* 340 not in HRR regist: Puerto Rico (329), Virgin Islands (5), Guam (4), 2 in Minnesota.
drop if _merge==1
* 1,613 not in county register
bys hrrnum: egen mean_merge = mean(_merge==3) 
su mean_merge // All merge in at least one
drop if _merge==2 
drop _merge mean_merge _dup classfp zipop_hrr_merge _dup

* compress to only one county-Hrr observation to be mergable
bro zip countyfips city hrrnum hrrcity

* two apporaches: 
* 1 weighted by how many zipcodes 
bys countyfips : g Total = _N
bys countyfips hrrnum : g inHRR = _N
g   zip_count_weight_in_HRR = inHRR/Total

* 2 weight by zipcode population
bro zip countyfips hrrnum  zipcensus2010pop zip_count_weight_in_HRR
bys countyfips hrrnum: egen popziphrr = total(zipcensus2010pop)
bys countyfips : egen popzipcounty = total(zipcensus2010pop)
g   zippop_count_weight_in_HRR = popziphrr/popzipcounty

compress 
save ../processedfiles/crosswalk_county_hrr_map.dta , replace 

* Reduce to one observation of county and HRR 
collapse  (first)  city  hrrcity Total inHRR zippop_count_weight_in_HRR zip_count_weight_in_HRR , by(countyfips hrrnum)

* 2 Equal weighting 
bys countyfips : g Total1 = _N
bys countyfips hrrnum : g inHRR1 = _N
g equal_weight_inHRR = inHRR1/Total1
drop Total1 Total inHRR1 inHRR

* Labels 
lab var countyfips 						"County fips nr"
lab var hrrnum 							"HRR nr"
lab var city   							"City-county"
lab var hrrcity  						"City-hrr"
lab var zip_count_weight_in_HRR 		"Give more weight to HRR that have more zipcodes in county"
lab var zippop_count_weight_in_HRR		"Zipcode population all HRRs a county has access to"
lab var equal_weight_inHRR				"Equal weight to all HRRs a county has access to"

compress
save ../processedfiles/crosswalk_county_hrr.dta , replace 

* ------------------------------------------------------------------------------
