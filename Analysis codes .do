

use "/Users/briankipkoech/Desktop/Articles /food Diversity chapter 1.dta"
drop if food_group == "Spices and condiments"
replace food_group = "Animal-source foods" if inlist(item,"Milk - Excluding Butter")
drop if missing(area)
drop if missing(consumed)


drop if food_group == "Spices and condiments"
gen id = _n
reshape long y, i(id) j(year)
rename y kcal
gen consumed = kcal > 0 if !missing(kcal)
bysort area year food_group item: egen item_consumed = max(consumed)
bysort area year food_group item: keep if _n == 1

// Diet diversity calculations

bys area year food_group: egen fg_total = total(kcal)
gen p = kcal/fg_total if fg_total>0
gen p2 = p^2
bys area year food_group: egen simpson_sum = total(p2)
gen simpson_fg = 1 - simpson_sum
gen plnp = p*ln(p) if p>0
bys area year food_group: egen shannon_sum = total(plnp)
gen shannon_fg = -shannon_sum
bys area year food_group: egen FQS_fg = total(consumed)
bys area year: egen total_kcal = total(kcal)
drop p2 p
gen P = kcal/total_kcal
gen P2 = P^2
bys area year: egen simpson_total = total(P2)
gen simpson_overall = 1-simpson_total
drop plnp
bys area year: egen FQS_overall = count(item)
gen PlnP = P*ln(P) if P>0
bys area year: egen shannon_total = total(PlnP)
gen shannon_overall = -shannon_total
collapse (first) simpson_fg shannon_fg FQS_fg (first) simpson_overall shannon_overall FQS_overall, by(area year food_group)

save "/Users/briankipkoech/Desktop/Articles /Results within and overall.dta"
merge m:1 year area using  "/Users/briankipkoech/Desktop/Articles /Wide data for the outcome and controls .dta"
sort _merge
drop if inlist(_merge,1)
sort area
drop if  missing(simpson_fg )
sort food_insecurity
keep if missing(food_insecurity)
drop food_insecurity
sort _merge
ds
sort year area
sort  area year
gen ID=_n
xtset ID year
xtreg stunting simpson_fg irrigation gdp_pc if food_group=="Fruits", fe
encode area, gen(country_id)
save "/Users/briankipkoech/Desktop/Articles /All results merged and produced ready for reshaping and analysis .dta", replace 
gen fg = lower(food_group)
replace fg = subinstr(fg, " ", "_", .)
replace fg = subinstr(fg, "-", "_", .)
replace fg = subinstr(fg, "/", "_", .)
tab fg
ds
duplicates report area year fg
drop _merge
drop country_id
keep area year fg simpson_fg shannon_fg FQS_fg simpson_overall shannon_overall FQS_overall stunting irrigation drinking_water political_stability food_import_dependence obesity gdp_pc
reshape wide simpson_fg shannon_fg FQS_fg, i(area year) j(fg) string
*===============================
* IDENTIFIERS
*===============================
label variable area                 "Country"
label variable year                 "Year"
*===============================
* DIET DIVERSITY INDICES
*===============================
label variable simpson_overall      "Overall Simpson diversity index"
label variable shannon_overall      "Overall Shannon diversity index"
label variable FQS_overall          "Overall food quality score"
*===============================
* NUTRITION OUTCOMES
*===============================
label variable stunting             "Prevalence of child stunting (%)"
label variable obesity              "Prevalence of obesity (%)"
*===============================
* FOOD SYSTEM VARIABLES
*===============================
label variable irrigation           "Agricultural land equipped for irrigation (%)"
label variable drinking_water       "Population with access to basic drinking water (%)"
*===============================
* ECONOMIC VARIABLES
*===============================
label variable gdp_pc               "GDP per capita (constant US$)"
*===============================
* GOVERNANCE
*===============================
label variable political_stability  "Political stability index"
*===============================
* MERGE VARIABLE
*===============================
preserve
keep if area=="Kenya"
graph bar simpson_fganimal_source_foods simpson_fgcereals_and_grains simpson_fgdairy_products simpson_fgfruits simpson_fglegumes simpson_fgnuts_and_seeds simpson_fgoils_and_fats simpson_fgroots_and_tubers simpson_fgvegetables, over(year) legend(position(6))
restore
ssc install spmap
ssc install shp2dta
ssc install mif2dta
preserve
keep if year==2023
keep area year simpson_overall shannon_overall FQS_overall
duplicates drop area year, force
rename area ADMIN
save diversity_2023.dta, replace
restore
encode area, generate(id)
xtset id year
reg stunting simpson_fganimal_source_foods
encode area, generate(ID)
xtreg stunting simpson_fganimal_source_foods i.year, fe
xtline simpson_fganimal_source_foods
xtline simpson_fganimal_source_foods if inlist(area, "Kenya")
xtline simpson_fganimal_source_foods if inlist(area, "Kenya", "Uganda")
xtline simpson_fganimal_source_foods if inlist(area, "Kenya", "Uganda"), overlay
xtline simpson_fganimal_source_foods if inlist(area, "Kenya", "Italy"), overlay
ds simpson*
foreach v of varlist simpson* shannon* FQS* {
    display "`v'"
}
tabstat simpson_overall shannon_overall simpson_fganimal_source_foods simpson_fgcereals_and_grains simpson_fgdairy_products simpson_fgfruits simpson_fglegumes simpson_fgnuts_and_seeds simpson_fgoils_and_fats simpson_fgroots_and_tubers simpson_fgvegetables, stat(n mean sd min p25 p50 p75 max)
rename simpson_fganimal_source_foods sim_animal
rename simpson_fgcereals_and_grains sim_cereal
rename simpson_fgdairy_products sim_dairy
rename simpson_fgfruits sim_fruit
rename simpson_fglegumes sim_legume
rename simpson_fgnuts_and_seeds sim_nuts
rename simpson_fgoils_and_fats sim_oils
rename simpson_fgroots_and_tubers sim_roots
rename simpson_fgvegetables sim_veg
rename shannon_fganimal_source_foods sha_animal
rename shannon_fgcereals_and_grains sha_cereal
rename shannon_fgdairy_products sha_dairy
rename shannon_fgfruits sha_fruit
rename shannon_fglegumes sha_legume
rename shannon_fgnuts_and_seeds sha_nuts
rename shannon_fgoils_and_fats sha_oils
rename shannon_fgroots_and_tubers sha_roots
rename shannon_fgvegetables sha_veg
rename FQS_fganimal_source_foods fqs_animal
rename FQS_fgcereals_and_grains fqs_cereal
rename FQS_fgdairy_products fqs_dairy
rename FQS_fgfruits fqs_fruit
rename FQS_fglegumes fqs_legume
rename FQS_fgnuts_and_seeds fqs_nuts
rename FQS_fgoils_and_fats fqs_oils
rename FQS_fgroots_and_tubers fqs_roots
rename FQS_fgvegetables fqs_veg
rename simpson_overall sim_total
rename shannon_overall sha_total
rename FQS_overall fqs_total
label variable area "Country"
label variable year "Year"
label variable sim_total "Overall Simpson dietary diversity"
label variable sha_total "Overall Shannon dietary diversity"
label variable fqs_total "Overall food quality score"
label variable sim_animal "Simpson diversity: animal-source foods"
label variable sim_cereal "Simpson diversity: cereals and grains"
label variable sim_dairy "Simpson diversity: dairy products"
label variable sim_fruit "Simpson diversity: fruits"
label variable sim_legume "Simpson diversity: legumes"
label variable sim_nuts "Simpson diversity: nuts and seeds"
label variable sim_oils "Simpson diversity: oils and fats"
label variable sim_roots "Simpson diversity: roots and tubers"
label variable sim_veg "Simpson diversity: vegetables"
label variable sha_animal "Shannon diversity: animal-source foods"
label variable sha_cereal "Shannon diversity: cereals and grains"
label variable sha_dairy "Shannon diversity: dairy products"
label variable sha_fruit "Shannon diversity: fruits"
label variable sha_legume "Shannon diversity: legumes"
label variable sha_nuts "Shannon diversity: nuts and seeds"
label variable sha_oils "Shannon diversity: oils and fats"
label variable sha_roots "Shannon diversity: roots and tubers"
label variable sha_veg "Shannon diversity: vegetables"
label variable fqs_animal "FQS: animal-source foods"
label variable fqs_cereal "FQS: cereals and grains"
label variable fqs_dairy "FQS: dairy products"
label variable fqs_fruit "FQS: fruits"
label variable fqs_legume "FQS: legumes"
label variable fqs_nuts "FQS: nuts and seeds"
label variable fqs_oils "FQS: oils and fats"
label variable fqs_roots "FQS: roots and tubers"
label variable fqs_veg "FQS: vegetables"
label variable stunting "Child stunting prevalence"
label variable obesity "Obesity prevalence"
label variable gdp_pc "GDP per capita"
label variable irrigation "Irrigation"
label variable drinking_water "Access to drinking water"
label variable political_stability "Political stability"
label variable food_import_dependence "Food import dependency"
capture drop country_id
encode area, gen(country_id)
xtset country_id year
xtdescribe

//Descriptive statistics
tabstat sim_total sha_total fqs_total stunting obesity gdp_pc irrigation drinking_water political_stability food_import_dependence, stat(n mean sd min p25 p50 p75 max)

tabstat sim_animal sim_cereal sim_dairy sim_fruit sim_legume sim_nuts sim_oils sim_roots sim_veg, stat(n mean sd min max)

tabstat sha_animal sha_cereal sha_dairy sha_fruit sha_legume sha_nuts sha_oils sha_roots sha_veg, stat(n mean sd min max)

tabstat fqs_animal fqs_cereal fqs_dairy fqs_fruit fqs_legume fqs_nuts fqs_oils fqs_roots fqs_veg, stat(n mean sd min max)

//Graph diversity patterns
preserve
collapse (mean) sim_total sha_total fqs_total, by(year)
twoway (line sim_total year) (line sha_total year), title("Global trend in dietary diversity") ytitle("Diversity index") xtitle("Year") legend(order(1 "Simpson" 2 "Shannon"))
restore

//Food group simposn. comparison 
graph bar (mean) sim_animal sim_cereal sim_dairy sim_fruit sim_legume sim_nuts sim_oils sim_roots sim_veg, title("Mean Simpson diversity by food group") ytitle("Mean Simpson index") legend(position(6))
//Food group Shannon Comparison
graph bar (mean) sha_animal sha_cereal sha_dairy sha_fruit sha_legume sha_nuts sha_oils sha_roots sha_veg, title("Mean Shannon diversity by food group") ytitle("Mean Shannon index") legend(position(6))
//Correlation analysis 
pwcorr sim_total sha_total fqs_total stunting obesity gdp_pc irrigation drinking_water political_stability food_import_dependence, sig

pwcorr sim_animal sim_cereal sim_dairy sim_fruit sim_legume sim_nuts sim_oils sim_roots sim_veg, sig

// Main panel regression Stunting 
///Overall simpson 

xtreg stunting sim_total irrigation drinking_water gdp_pc political_stability food_import_dependence i.year, fe vce(cluster country_id)

///Overall Shannon
xtreg stunting sha_total irrigation drinking_water gdp_pc political_stability food_import_dependence i.year, fe vce(cluster country_id)
///Overall FQS

xtreg stunting fqs_total irrigation drinking_water gdp_pc political_stability food_import_dependence i.year, fe vce(cluster country_id)
/// FOOD groups Simpson model 
xtreg stunting sim_animal sim_cereal sim_dairy sim_fruit sim_legume sim_nuts sim_oils sim_roots sim_veg irrigation drinking_water gdp_pc political_stability food_import_dependence i.year, fe vce(cluster country_id)
xtreg stunting sha_animal sha_cereal sha_dairy sha_fruit sha_legume sha_nuts sha_oils sha_roots sha_veg irrigation drinking_water gdp_pc political_stability food_import_dependence i.year, fe vce(cluster country_id)
xtreg stunting sha_animal sha_cereal sha_dairy sha_fruit sha_legume sha_nuts sha_oils sha_roots sha_veg irrigation drinking_water gdp_pc political_stability food_import_dependence i.year, fe vce(cluster country_id)

///Obesity Models
xtreg obesity sim_total irrigation drinking_water gdp_pc political_stability food_import_dependence i.year, fe vce(cluster country_id)

xtreg obesity sha_total irrigation drinking_water gdp_pc political_stability food_import_dependence i.year, fe vce(cluster country_id)

xtreg obesity fqs_total irrigation drinking_water gdp_pc political_stability food_import_dependence .year, fe vce(cluster country_id)

xtreg obesity sim_animal sim_cereal sim_dairy sim_fruit sim_legume sim_nuts sim_oils sim_roots sim_veg irrigation drinking_water gdp_pc political_stability food_import_dependence i.year, fe vce(cluster country_id)

///Determinats of dietarry diversty 
xtreg sim_total irrigation drinking_water gdp_pc political_stability food_import_dependence i.year, fe vce(cluster country_id)

xtreg sha_total irrigation drinking_water gdp_pc political_stability food_import_dependence i.year, fe vce(cluster country_id)

xtreg fqs_total irrigation drinking_water gdp_pc political_stability food_import_dependence i.year, fe vce(cluster country_id)

//income groupd analysis 
xtile income_group = gdp_pc, nq(3)

label define incomegrp 1 "Low GDP per capita" 2 "Middle GDP per capita" 3 "High GDP per capita"
label values income_group incomegrp

xtreg stunting sim_total irrigation drinking_water gdp_pc political_stability food_import_dependence if income_group==1, fe vce(cluster country_id)

xtreg stunting sim_total irrigation drinking_water gdp_pc political_stability food_import_dependence if income_group==2, fe vce(cluster country_id)

xtreg stunting sim_total irrigation drinking_water gdp_pc political_stability food_import_dependence if income_group==3, fe vce(cluster country_id)
