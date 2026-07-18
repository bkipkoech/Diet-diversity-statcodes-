clear
* Stimulants
replace food_group = "Stimulants" if inlist(item,"Coffee and products","Cocoa Beans and products","Tea (including mate)")
* Spices
replace food_group = "Spices" if inlist(item,"Pepper","Pimento","Cloves","Spices, Other")
* Alcoholic beverages
replace food_group = "Alcoholic Beverages" if inlist(item,"Wine","Beer","Beverages, Fermented","Beverages, Alcoholic","Alcohol, Non-Food")
* Meat
replace food_group = "Meat" if inlist(item,"Bovine Meat","Mutton & Goat Meat","Pigmeat","Poultry Meat","Meat, Other")
* Offals
replace food_group = "Offals" if item=="Offals, Edible"
* Animal fats
replace food_group = "Animal fats" if inlist(item,"Butter, Ghee","Cream","Fats, Animals, Raw","Fish, Body Oil","Fish, Liver Oil")
* Eggs
replace food_group = "Eggs" if item=="Eggs"
* Milk
replace food_group = "Milk - Excluding Butter" if item=="Milk - Excluding Butter"
* Fish and seafood
replace food_group = "Fish, Seafood" if inlist(item,"Freshwater Fish","Demersal Fish","Pelagic Fish","Marine Fish, Other","Crustaceans","Cephalopods","Molluscs, Other","Aquatic Animals, Others")
* Aquatic products
replace food_group = "Aquatic Products, Other" if inlist(item,"Meat, Aquatic Mammals","Aquatic Plants")
* Miscellaneous
replace food_group = "Miscellaneous" if inlist(item,"Infant food","Miscellaneous")
sort _merge
replace food_group = "Cereals - Excluding Beer" if item == "Cereals - Excluding Beer"
replace food_group = "Starchy Roots" if item == "Starchy Roots"
replace food_group = "Sugar Crops" if item == "Sugar Crops"
replace food_group = "Sugar & Sweeteners" if item == "Sugar & Sweeteners"
replace food_group = "Pulses" if item == "Pulses"
replace food_group = "Treenuts" if item == "Treenuts"
replace food_group = "Oilcrops" if item == "Oilcrops"
replace food_group = "Vegetable Oils" if item == "Vegetable Oils"
replace food_group = "Vegetables" if item == "Vegetables"
replace food_group = "Fruits - Excluding Wine" if item == "Fruits - Excluding Wine"
replace food_group = "Stimulants" if item == "Stimulants"
replace food_group = "Spices" if item == "Spices"
replace food_group = "Alcoholic Beverages" if item == "Alcoholic Beverages"
replace food_group = "Meat" if item == "Meat"
replace food_group = "Offals" if item == "Offals"
replace food_group = "Animal fats" if item == "Animal fats"
replace food_group = "Eggs" if item == "Eggs"
replace food_group = "Milk - Excluding Butter" if item == "Milk - Excluding Butter"
replace food_group = "Fish, Seafood" if item == "Fish, Seafood"
replace food_group = "Aquatic Products, Other" if item == "Aquatic Products, Other"
replace food_group = "Miscellaneous" if item == "Miscellaneous"
sort food_group
drop if inlist(item, "Vegetal Products", "Grand Total", "Animal Products")
sort itemgroupcode
ds food_group
tab food_group
gen broad_food_group = ""
replace broad_food_group = "Animal proteins" if item == "Meat"
replace broad_food_group = "Animal proteins" if item == "Offals"
replace broad_food_group = "Animal proteins" if item == "Eggs"
replace broad_food_group = "Animal proteins" if item == "Fish, Seafood"
replace broad_food_group = "Animal proteins" if item == "Aquatic Products, Other"
replace broad_food_group = "Dairy" if item == "Milk - Excluding Butter"
replace broad_food_group = "Dairy" if item == "Animal fats"
replace broad_food_group = "Plant proteins and legumes" if item == "Pulses"
replace broad_food_group = "Plant proteins and legumes" if item == "Treenuts"
replace broad_food_group = "Plant proteins and legumes" if item == "Oilcrops"
replace broad_food_group = "Cereals and grains" if item == "Cereals - Excluding Beer"
replace broad_food_group = "Roots and tubers" if item == "Starchy Roots"
replace broad_food_group = "Fruits" if item == "Fruits - Excluding Wine"
replace broad_food_group = "Vegetables" if item == "Vegetables"
replace broad_food_group = "Oils and fats" if item == "Vegetable Oils"
replace broad_food_group = "Sugars and sweeteners" if item == "Sugar & Sweeteners"
replace broad_food_group = "Sugars and sweeteners" if item == "Sugar Crops"
replace broad_food_group = "Beverages and stimulants" if item == "Alcoholic Beverages"
replace broad_food_group = "Beverages and stimulants" if item == "Stimulants"
replace broad_food_group = "Spices and condiments" if item == "Spices"
replace broad_food_group = "Miscellaneous" if item == "Miscellaneous"
tab food_group
sort food_group
tab food_group
replace food_group = "Animal-source foods" if inlist(food_group,"Meat","Offals","Eggs")
replace food_group = "Fish and seafood" if inlist(food_group,"Fish, Seafood","Aquatic Products, Other")
replace food_group = "Dairy products" if food_group == "Milk - Excluding Butter"
replace food_group = "Legumes" if food_group == "Pulses"
replace food_group = "Nuts and seeds" if inlist(food_group,"Treenuts","Oilcrops")
replace food_group = "Oils and fats" if inlist(food_group,"Vegetable Oils","Animal fats")
replace food_group = "Cereals and grains" if food_group == "Cereals - Excluding Beer"
replace food_group = "Roots and tubers" if food_group == "Starchy Roots"
replace food_group = "Fruits" if food_group == "Fruits - Excluding Wine"
replace food_group = "Vegetables" if food_group == "Vegetables"
replace food_group = "Sugars and sweeteners" if inlist(food_group,"Sugar Crops","Sugar & Sweeteners")
replace food_group = "Beverages" if inlist(food_group,"Alcoholic Beverages","Stimulants")
replace food_group = "Spices and condiments" if food_group == "Spices"
replace food_group = "Miscellaneous" if food_group == "Miscellaneous"
tab food_group
replace food_group = "Animal-source foods" if inlist(food_group,"Fish and seafood")
tab food_group
drop _merge broad_food_group unit areacodem49 areacode factor itemcode
ds
tab food_group
drop if inlist(food_group, "Miscellaneous", "Sugars and sweeteners", "Beverages")
save "/Users/briankipkoech/Desktop/Articles /food Diversity chapter 1.dta"
