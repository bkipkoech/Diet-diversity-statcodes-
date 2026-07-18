clear
set mem 125m
set seed 12345

capture program drop gendata
program define gendata, rclass
	version 8
	syntax , case(integer) re(integer) het(integer)

	if `re' != 0 & `re' != 1 {
		di as err "re must be 0 or 1"
		exit 498
	}	
	
	if `het' != 0 & `het' != 1 {
		di as err "het must be 0 or 1"
		exit 498
	}	
	
	if `case' == 1 {
		genardta 0 `re' `het'
		ret scalar model = 0
		ret scalar corr  = 0
		exit
	}	

	if `case' > 1 & `case' < 5 {
		local rho = .1*(`case'-1)

		genardta `rho' `re' `het'
		ret scalar model = 1
		ret scalar corr  = `rho'
		exit
	}	
	
	if `case' >= 5 {
		local rho = .1*(`case'-4)

		genmadta `rho' `re' `het'
		ret scalar model = 2
		ret scalar corr  = `rho'
		exit
	}	
end

capture program drop genardta
program define genardta 
	version 8

	local ar `1'
di "ar is `ar'"	
	local re `2'
	local het `3'

	if `re' == 1 {
		local fe
	}
	else if `re' == 0 {
		local fe " +.5*u "
	}
	else {
		di as err "re = `re'"
		exit 498
	}	

	if `het' == 1 {
		local hetterm "*(abs(x1)+abs(x2))*.8" 
	}
	else if `het' == 0 {
		local hetterm
	}
	else {
		di as err "het = `het'"
		exit 498
	}	

	drop _all

	local obs = $obs 
	set obs `obs'
	gen id = _n

	gen u = invnorm(uniform())*2.5
	expand 300
	sort id
	by id: gen t = _n

	tsset id t
	gen x1 = invnorm(uniform())*1.5 `fe'
	gen x2 = invnorm(uniform())*1.8 `fe'
	
	by id: gen e1 = invnorm(uniform()) if _n == 1
	gen e2 = invnorm(uniform()) `hetterm'
	by id: replace e1 = `ar'*e1[_n-1] + e2 if _n > 1

	drop if t<291
	replace t = t-290
	tsset id t

	gen y = 1 + x1 + x2 + u + e1

local tmp = 10*`ar'
// save ar`tmp', replace
end

capture program drop genmadta
program define genmadta 
	version 8

	local ma `1'
	local re `2'
	local het `3'
di "ma is `ma'"	

	if `re' == 1 {
		local fe
	}
	else if `re' == 0 {
		local fe " +.5*u "
	}
	else {
		di as err "re = `re'"
		exit 498
	}	

	if `het' == 1 {
		local hetterm "*(abs(x1)+abs(x2))*.8" 
	}
	else if `het' == 0 {
		local hetterm
	}
	else {
		di as err "het = `het'"
		exit 498
	}	


	drop _all

	local obs = $obs 
	set obs `obs'
	gen id = _n

	gen u = invnorm(uniform())*2.5
	expand 300
	sort id
	by id: gen t = _n

	tsset id t
	gen x1 = invnorm(uniform())*1.5 `fe'
	gen x2 = invnorm(uniform())*1.8 `fe'
	
	by id: gen e1 = invnorm(uniform()) if _n == 1
	gen e2 = invnorm(uniform()) `hetterm'
	by id: replace e1 =  e2 + `ma'*e2[_n-1] if _n > 1

	drop if t<291
	replace t = t-290
	tsset id t

	gen y = 1 + x1 + x2 + u + e1

local tmp = 10*`ma'
// save ma`tmp', replace
end

capture program drop mkub_ng 
program define mkub_ng 
	version 8
	sort id t
	gen pub = uniform()
	by id: replace pub = pub[1] if _n > 1
	gen t0 =$t0*uniform() + 1
	by id: replace t0 = t0[1] if _n > 1
	drop if pub <=$pub & t < t0
end

capture program drop mkub_wg 
program define mkub_wg 
	version 8
	sort id t
	gen pub = uniform()
	by id: replace pub = pub[1] if _n > 1
	gen drop = 1
	replace drop = uniform() if t==3 | t==6 | t==7
	drop if pub <=$pub &  drop < $drop
end


local runs  2000
global obs  1000
global T    10
global pub  .4
global t0   6
global drop .6


matrix gtype = [0 \\ 1 \\ 2 \\ 3 \\ 4 ]
matrix ctype = [4 \\ 5 \\ 6 \\ 7 \\ 8 \\ 9 \\ 10 ]


postfile results model corr N T re het p bal 			///
	ti4 ti5 ti6 ti7 ti8 ti9 ti10				/// 
	g0 g1 g2 g3 g4 using serial_sim_all, replace

/* re = 1 if random-effect 
   re = 0 if fixed-effect
*/

/* het = 1 if e2 is conditionally heteroskedastic function of x1 x2
   het = 0 if e2 is not conditionally heteroskedastic 
*/

/* g0 indicates no gaps
   g1 indicates 1 gap of length 1
   g2 indicates 2 gaps of length 1
   g3 indicates 1 gap of length 2
   g4 indicates 1 gap of length 1 and 1 gap of length 2
*/
   
/* model = 1  ar correlation
   model = 2  ma correlation
*/   

label define model_lab  1 "ar correlation" 2 "ma correlation"

	
/* bal = 0 Balanced data
   bal = 1 unbalanced, no gaps
   bal = 3 unblanced with gaps
*/   

label define bal_lab 0 "balanced data" 1 "unbalanced, no gaps"		///
	2 "unbalanced with gaps"

forvalues i = 1/`runs' {

	di "working on run `i'"
	forvalues re = 0/1 {
		forvalues het = 0/1 {
			forvalues case = 1/7 {

				quietly {
					gendata, case(`case')		///
						re(`re') het(`het')
					local model = r(model)
					local corr  = r(corr)

// di "case `case': balanced data N =obs and T = 10"
// reg e1 l.e1
					xtserial y x1 x2

post results (`model') (`corr') (1000) (10) (`re') (`het')		///
(r(p)) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0)  
 
// di "case `case': balanced data N =1000 and T = 5"
					preserve
					drop if t > 5

					xtserial y x1 x2
post results (`model') (`corr') (1000) (5) (`re') (`het')		///
(r(p)) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0)  
 
					restore 

// di "case `case': balanced data N=500 and T= 10"
					preserve
					drop if id > 500

					xtserial y x1 x2
post results (`model') (`corr') (500) (10) (`re') (`het')  		///
(r(p)) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0)  
 
					restore 

// di "case `case': balanced data N=500 and T= 5"
					preserve
					drop if id > 500 | t > 5

					xtserial y x1 x2
post results (`model') (`corr') (500) (5) (`re') (`het')		///
(r(p)) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0) (0)  
 
					restore 

// di "case `case': unbalanced data, no gaps"
					preserve 
					mkub_ng

// reg e1 l.e1
// xtdes , patterns(5)
					by id: gen ti = _N if _n==1
					tab ti, matcell(counts) matrow(vals)
					forvalues val=4/10 {
						if vals[`val'-3,1] == ///
							ctype[`val'-3,1] {
local g`val' = counts[`val'-3,1]
						}
						else {
							local g`val' =  0
						}
					}
// save ubng`case', replace		
					xtserial y x1 x2
post results (`model') (`corr') (1000) (10) (`re') (`het')		///
(r(p)) (1) (`g4') (`g5') (`g6') (`g7') (`g8') (`g9') (`g10') 	///
(0) (0) (0) (0) (0)  
		
					restore

					mkub_wg

// di "case `case': unbalanced data, with gaps"
// reg e1 l.e1
// xtdes , patterns(5)
					sort id t
					by id: gen gl = t-t[_n-1]-1  if _n >1
					replace gl = 3 if gl==2
					by id: replace gl=sum(gl)
					by id: gen gltype = gl[_N] if _n ==1
					tab gltype, matcell(counts) matrow(vals)
					forvalues val=0/4 {
						if vals[`val'+1,1] == 	///
							gtype[`val'+1,1] {
local g`val' = counts[`val'+1,1]
						}
						else {
							local g`val' =  0
						}
					}

// save ubwg`case', replace		
					xtserial y x1 x2
post results (`model') (`corr') (1000) (10) (`re') (`het') (r(p)) (2)	///
(0) (0) (0) (0) (0) (0) (0) (`g0') (`g1') (`g2') (`g3') (`g4')  
				}		
			}
		}	
	}
}

postclose results
use serial_sim_all, clear
label values model model_lab 
label values  bal bal_lab
gen reject = (p < .05)
sort re het model corr bal N T 
by re het model corr bal N T: sum p reject
save serial_sim_all, replace
