* Reshape to long if still wide

rename y2010 kcal2010
rename y2011 kcal2011
rename y2012 kcal2012
rename y2013 kcal2013
rename y2014 kcal2014
rename y2015 kcal2015
rename y2016 kcal2016
rename y2017 kcal2017
rename y2018 kcal2018
rename y2019 kcal2019
rename y2020 kcal2020
rename y2021 kcal2021
rename y2022 kcal2022
rename y2023 kcal2023

reshape long kcal, i(area item itemcodefbs food_group element elementcode) j(year)

drop if missing(kcal)
drop if kcal < 0

* Overall diversity across individual food items

preserve

bysort area year: egen total_kcal = total(kcal)
gen share_item = kcal / total_kcal

gen nddi_part = share_item * (1 - share_item)
gen shannon_part = -share_item * ln(share_item) if share_item > 0
gen dds_item = kcal > 0 if !missing(kcal)

collapse (sum) NDDI_overall=nddi_part Shannon_overall=shannon_part DDS_overall=dds_item total_kcal, by(area year)

save overall_indices.dta, replace

restore
* Between-food-group diversity

preserve

collapse (sum) kcal, by(area year food_group)

bysort area year: egen total_kcal = total(kcal)
gen share_group = kcal / total_kcal

gen nddi_part = share_group * (1 - share_group)
gen shannon_part = -share_group * ln(share_group) if share_group > 0
gen dds_group = kcal > 0 if !missing(kcal)

collapse (sum) NDDI_between=nddi_part Shannon_between=shannon_part DDS_between=dds_group, by(area year)

save between_group_indices.dta, replace

restore
* Within-food-group diversity

preserve

bysort area year food_group: egen group_kcal = total(kcal)
gen share_within = kcal / group_kcal if group_kcal > 0

gen nddi_part = share_within * (1 - share_within)
gen shannon_part = -share_within * ln(share_within) if share_within > 0
gen dds_within_item = kcal > 0 if !missing(kcal)

collapse (sum) NDDI_within=nddi_part Shannon_within=shannon_part DDS_within=dds_within_item group_kcal, by(area year food_group)

save within_group_indices.dta, replace

restore
* Merge overall and between-group indices

use overall_indices.dta, clear
merge 1:1 area year using between_group_indices.dta
drop _merge

save country_year_indices.dta, replace

use country_year_indices.dta, clear

summarize NDDI_overall Shannon_overall DDS_overall NDDI_between Shannon_between DDS_between

corr NDDI_overall Shannon_overall DDS_overall

corr NDDI_between Shannon_between DDS_between

use within_group_indices.dta, clear

tab food_group

summarize NDDI_within Shannon_within DDS_within

sort area year food_group
list area year food_group NDDI_within Shannon_within DDS_within group_kcal in 1/30
