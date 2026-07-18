tab year if missing(value)
gen year_mid = .
replace year_mid = 2012 if year == "2011-2013"
replace year_mid = 2013 if year == "2012-2014"
replace year_mid = 2014 if year == "2013-2015"
replace year_mid = 2015 if year == "2014-2016"
replace year_mid = 2016 if year == "2015-2017"
replace year_mid = 2017 if year == "2016-2018"
replace year_mid = 2018 if year == "2017-2019"
replace year_mid = 2019 if year == "2018-2020"
replace year_mid = 2020 if year == "2019-2021"
replace year_mid = 2021 if year == "2020-2022"
replace year_mid = 2022 if year == "2021-2023"
drop year
rename year_mid year
drop note
drop flag
sort year
tab year
tab yearcode
sort yearcode
keep if yearcode >= 2011
drop if yearcode >= 20002002 & yearcode <= 20092010
replace year = 2010 if yearcode == 20092011
replace year = 2011 if yearcode == 20102012
replace year = 2012 if yearcode == 20112013
replace year = 2013 if yearcode == 20122014
replace year = 2014 if yearcode == 20132015
replace year = 2015 if yearcode == 20142016
replace year = 2016 if yearcode == 20152017
replace year = 2017 if yearcode == 20162018
replace year = 2018 if yearcode == 20172019
replace year = 2019 if yearcode == 20182020
replace year = 2020 if yearcode == 20192021
replace year = 2021 if yearcode == 20202022
replace year = 2022 if yearcode == 20212023
replace year = yearcode if missing(year)
save "/Users/briankipkoech/Desktop/Articles /Long outcone and controls for dd.dta"
keep area year itemcode value
destring value, replace force
keep area year itemcode value
collapse (mean) value, by(area year itemcode)
reshape wide value, i(area year) j(itemcode) string
rename value210090 food_insecurity
rename value21025 stunting
rename value21042 obesity
rename value22013 gdp_pc
rename value21032 political_stability
rename value21047 drinking_water
ds
rename value21034 irrigation
rename value21033 food_import_dependence
