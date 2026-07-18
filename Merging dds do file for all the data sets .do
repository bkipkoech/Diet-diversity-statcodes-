save "/Users/briankipkoech/Desktop/Articles /Wide data for the outcome and controls .dta"
use "/Users/briankipkoech/Desktop/Articles /Country results dietary diversities .dta", clear
merge 1:1 year area using  "/Users/briankipkoech/Desktop/Articles /Wide data for the outcome and controls .dta"
merge 1:1 year area using  "/Users/briankipkoech/Desktop/Articles /Wide data for the outcome and controls .dta"
sort _merge
sort political_stability
sort _merge
drop if _merge == 1
egen nmiss = rowmiss(NDDI_overall Shannon_overall DDS_overall total_kcal)
drop if nmiss == 4
drop nmiss
sum
sort food_insecurity
tostring country_id, generate(cdr)
drop if area == "Southern Africa"
drop if area == "Southern Asia"
drop if area == "Central America"
drop if area == "Northern Africa"
drop if area == "Western Asia"
drop if area == "Western Africa"
drop if area == "Eastern Africa"
drop if area == "Middle Africa"
drop if area == "Caribbean"
drop if area == "Melanesia"
drop if area == "Least Developed Countries (LDCs)"
drop if area == "Land Locked Developing Countries (LLDCs)"
drop if area == "Low Income Food Deficit Countries (LIFDCs)"
drop if area == "Small Island Developing States (SIDS)"
drop if area == "Western Europe"
drop if area == "Northern Europe"
drop if area == "Eastern Asia"
drop if area == "Southern Europe"
drop if area == "Eastern Europe"
drop if area == "Central Asia"
drop if area == "Australia and New Zealand"
drop if area == "South-eastern Asia"
drop if area == "South America"
drop food_insecurity
sort cdr
tab area
encode area, gen(country)
xtset country year
xtdescribe
drop if inlist(year, 2010)
