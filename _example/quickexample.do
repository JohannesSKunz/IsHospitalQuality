* Example to use crosswalk: Kunz Propper 2022

clear all 
set more off 

* change path 
cd "˜/Hospitalcompare/_raw/"

* 1. Load any type of HRR data, ie. Dartmouth (our exampe individual hospital quality aggregated to the HRR-level)
* Here just count number of beds in HRR from AHA (see _sourcefiles for source of data)
use Dartmouth_HOSPITALRESEARCHDATA/hosp16_atlas.dta
collapse (sum) AHAbeds , by(hrr)

* 2. Adjust format and merge with crosswalk 
tostring hrr, gen(hrrnum)
merge 1:m hrrnum using ˜/crosswalk/crosswalk_county_hrr.dta, nogen

* 3. Collapse on county-level for further analysis, using our prefered weights, others are provided
collapse (mean) AHAbeds [aw=zip_count_weight_in_HRR] , by(countyfips)

