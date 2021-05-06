//KAPPA calculation
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////

use "3 szczepionka\20210310 data analysis (Arianda wave2)\WNE2_N3000_covid_stats_who_why_refto.dta", clear

keep if manuallychecked==1

global why_vars "safety_general safety_concerns belief_science doubts others_safety not_afraid_virus poorly_tested contraindications antibodies convenience normality just_no no_alternatives just_yes conspiracy efficacy_concerns morbidity_factors vaccine_too_costly"

foreach i in $why_vars{
gen r1why_`i' = strpos(Ola_why,"`i'")
replace r1why_`i'=1 if r1why_`i'>0
}

sum r1why_*

foreach i in $why_vars{
gen r2why_`i' = strpos(Roma_why,"`i'")
replace r2why_`i'=1 if r2why_`i'>0
}

sum r2why_*



global who_vars " side_effects  nothing  doctor  dont_know  more_evidence_inefficacy  else  forced  more_evidence_efficacy  more_evidence_safety  money  time  family "

foreach i in $who_vars{
gen r1who_`i' = strpos(Ola_who,"`i'")
replace r1who_`i'=1 if r1who_`i'>0
}

sum r1who_*

foreach i in $who_vars{
gen r2who_`i' = strpos(Roma_who,"`i'")
replace r2who_`i'=1 if r2who_`i'>0
}

sum r2who_*

///////////////////////////////////////////////////////////////////

//add variables to store kappa
foreach var in $why_vars $who_vars {
	gen k_`var'=0
}

capture gen avg_kpp=0
replace avg_kpp=0
capture gen counter=0
replace counter=0

//calculate kappa
foreach x in $why_vars {   
//display  "`x'"
//display  "x"
display  ``line''
display  ``line''
display  ``line''
display  "`x'"
//capture noisily kap r1why_`x' r2why_`x'
//capture noisily replace k_`x'=r(kappa)
kap r1why_`x' r2why_`x'
replace k_`x'=r(kappa)
display k_`x'
replace avg_kpp = avg_kpp + r(kappa)
display avg_kpp
}

foreach x in $who_vars {   
//display  "`x'"
//display  "x"
display  ``line''
display  ``line''
display  ``line''
display  "`x'"
//capture noisily kap r1why_`x' r2why_`x'
//capture noisily replace k_`x'=r(kappa)
kap r1who_`x' r2who_`x'
replace k_`x'=r(kappa)
display k_`x'
replace avg_kpp = avg_kpp + r(kappa)
display avg_kpp
}

//all kappas at one place:
/*
Agreement:
below  0.0 Poor
0.00 – 0.20 Slight
0.21 – 0.40 Fair
0.41 – 0.60 Moderate
0.61 – 0.80 Substantial
0.81 – 1.00 Almost  perfect
*/



//ssc install fsum
fsum k_*
gen avg_kpp2=avg_kpp/counter
tab avg_kpp2 

