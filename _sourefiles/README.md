# IsHospitalQuality
 
- Current version: `1.0.0 22oct2022`

-----------

## Overview 

Here we present the publicly available data sources used in our analyses. Please reach out if you have any issues accessing any of these. 

---
### Crosswalks

Zip codes:  [ZipHsaHrr17.xls](https://data.dartmouthatlas.org/downloads/geography/ZipHsaHrr17.xls) (Accessed: 16 Apr 2020)

Zip code population (2010): [2010CensusPopulationByZipcodeZCTA.csv](https://www.census.gov/programs-surveys/geography/guidance/geo-areas/zctas.html)
 (Accessed: 2 Jul 2021)	
	
Zip code to county FIPS crosswalk: [ZIP-COUNTY-FIPS_2018-03.csv](https://www.census.gov/programs-surveys/geography/guidance/geo-areas/zctas.html) (Accessed: 16 Apr 2020)

Alternative crosswalk: concurrently developed Dartmouth [crosswalk](https://github.com/Dartmouth-DAC/covid-19-hrr-mapping/blob/master/HRR-mapping/cumulativecountytohrr.R)  (Accessed: 5 Jul 202)

County and States map files: [US_County_LowRes (several)](https://spot.colorado.edu/~jonathug/Jonathan_E._Hughes/Map_Files.html) (Accessed: 3 Jun 2020)


---
### Time constant county-characteristics

County-level population (2020): [covid_county_population_usafacts.csv](https://usafacts.org/visualizations/coronavirus-covid-19-spread-map/) (Accessed: 16 May 2020)

County-level poverty, income, … (2018): [est18all.xls](https://www2.census.gov/programs-surveys/saipe/datasets/2018/2018-state-and-county/est18all.xls) (Accessed: 14 May 2020)

County-level population metrics, rural/urban, race… (2021): [Rural-Atlas-Update2021-People.csv (raw file only called People, in folder Rural-Atlas)](https://www.ers.usda.gov/data-products/atlas-of-rural-and-small-town-america/) (Accessed: 2 Apr 2020)

County-level social capital: [social-capital-project-social-capital-index-data.xlsx](https://www.jec.senate.gov/public/index.cfm/republicans/2018/4/the-geography-of-social-capital-in-america) (Accessed: 30 Jun 2020)

County-level community health rankings (2019): [community-health-analytic_data2019.csv (raw file only called analytic_data2019, in folder community-health)](https://www.countyhealthrankings.org/explore-health-rankings/rankings-data-documentation) (Accessed: 2 Jun 2020)	

Republican vote share: [countypres_2000-2020.csv](https://dataverse.harvard.edu/file.xhtml?fileId=4819117&version=9.0) (Accessed: 4 Nov 2021)

Rural/Urbanity: [ruralurbancodes2013.xls](https://www.ers.usda.gov/webdocs/DataFiles/53251/ruralurbancodes2013.xls) (Accessed: 29 Aug 2021)
	
ACS race checks: [ACSDP1Y2018.DP05_data_with_overlays_2020-06-23T204445.csv](https://data.census.gov/cedsci/table?q=Race\%20County&g=0100000US.050000&hidePreview=true&tid=ACSDT1Y2018.C02003&vintage=2018&y=2018&moe=false) (Accessed: 23 Jun 2020)

---
### Time constant HRR-characteristics

Quality data: [KPSW_20_01_08_data_alphas_export.dta], Source Kunz, Propper, Staub, Winkelmann (2021), Derived: 01 08 2020, Includes HRR variables from Dartmouth and other sources described therein. 

Hospital Capacity: [2011_phys_hrr.xls and 2012_hosp_resource_hrr.xls](https://data.dartmouthatlas.org/capacity/) (Accessed: 08.12.2021)

---
### Daily Covid county data

Covid deaths and cases data: [21_07_07_covid_confirmed_usafacts.csv and 21_07_07_covid_deaths_usafacts.csv](https://usafacts.org/visualizations/coronavirus-covid-19-spread-map/) (Accessed: 7 Jul 2021)
	
Covid Vaccinations: [21_07_07_COVID-19_Vaccinations_in_the_United_States_County.csv](https://healthdata.gov/dataset/COVID-19-Vaccinations-in-the-United-States-County/ipdn-uaih) (Accessed: 7 Jul 2021)

Covid Policies: [OxCGRT_US_latest.csv](https://github.com/OxCGRT/covid-policy-tracker) (Accessed:07.12.2021)

---
### Pre-covid yearly data 

CDC all cause: [CDC_mortality2000_2019.txt](https://wonder.cdc.gov/controller/datarequest/D76;jsessionid=52BBF1CA975B694EB9FBD9CFDC30) (Accessed: 15 Jun 2021)
	
CDC excess deaths: [AH_County_of_Residence_COVID-19_Deaths_Counts__2020_Provisional.csv](https://data.cdc.gov/NCHS/Provisional-COVID-19-Death-Counts-in-the-United-St/kn79-hsxy) (Accessed: 11 Nov 2021)

CDC AMI deaths: Underlying Cause of Death, [1999-2019.txt](https://wonder.cdc.gov/controller/datarequest/D76) (Accessed: 4 Nov 2021)

CDC Influenza & Pneumonia deaths, county, yearly 2016-2019, ICD10 - J09-18:Underlying Cause of Death, [1999-2019.txt](https://wonder.cdc.gov/controller/datarequest/D76) (Accessed: 15 Jun 2021)