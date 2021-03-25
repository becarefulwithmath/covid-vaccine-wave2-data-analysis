// ideas:
// robustness check: to compare distrubution of answers for Ariadna data
// robustness check: to drop out 5% of the fastest subjects

clear all
// install package to import spss file
// net from http://radyakin.org/transfer/usespss/beta
//usespss "WNE_Pilotaz_N166.sav"
//usespss "WNE2_N3000.sav"
//saveold "G:\Shared drives\Koronawirus\studies\3 szczepionka\20210310 data analysis (Arianda data ver 2)\WNE2_N3000_stata_format.dta", version(13)

//INTSALATION:
//capture ssc install tabstatmat

//WORKING FOLDER AND DATA
capture cd "G:\Shared drives\Koronawirus\studies\3 szczepionka\20210310 data analysis (Arianda data ver 2)"
capture cd "G:\Dyski współdzielone\Koronawirus\studies\3 szczepionka\20210310 data analysis (Arianda data ver 2)"
capture cd "/Volumes/GoogleDrive/Shared drives/Koronawirus/studies/3 szczepionka/20210310 data analysis (Arianda data ver 2)"
use WNE2_N3000_stata_format.dta, clear

//comments review, count, %
gen n_count=_N
rename p29 comment_29
global comments "comment_29"
foreach comment in $comments {
list `comment' if `comment'!=""
egen `comment'_count = count(`comment')
gen `comment'_count_percent = `comment'_count/n_count
display "number of comments: "  `comment'_count
display "% of records with comments: " `comment'_count_percent
}

//VACCINE PART DATA CLEANING
rename (p37_1_r1	p37_1_r2	p37_1_r3		p37_1_r5	p37_1_r6	p37_1_r7 p37_1_r8_r8	p37_8_r1	p37_8_r2	p37_8_r3	p37_8_r4	p37) (v_producer_reputation	v_efficiency	v_safety		v_other_want_it	v_scientific_authority	v_ease_personal_restrictions v_tested	v_p_pay0	v_p_gets70	v_p_pays10	v_p_pays70	v_decision) 
global vaccine_vars "v_producer_reputation	v_efficiency	v_safety		v_other_want_it	v_scientific_authority	v_ease_personal_restrictions v_tested	v_p_gets70	v_p_pays10	v_p_pays70" // this refers to the previous wave: i leave out scarcity -- sth that supposedly everybody knows. we can't estimate all because of ariadna's error anyway
global vaccine_short "v_producer_reputation	v_efficiency	v_safety		v_other_want_it	v_scientific_authority	v_ease_personal_restrictions v_tested"
global prices "v_p_gets70	v_p_pays10	v_p_pays70"

gen vaxx_cert_yes =v_dec==4
gen vaxx_rather_yes =v_dec==3
gen vaxx_rather_no =v_dec==2
gen vaxx_cert_no =v_dec==1

gen vaxx_yes=vaxx_certainly_yes+vaxx_rather_yes


sum vaxx_cert_yes [weight=waga]
sum vaxx_rather_yes [weight=waga]
sum vaxx_rather_no [weight=waga]
sum vaxx_cert_no [weight=waga]


sum vaxx_yes [weight=waga]
sum vaxx_yes [weight=waga] if male==1 & age>60

pwcorr $vaccine_vars, sig
egen sum_vaxx=rsum($vaccine_short)
sum $vaccine_vars
hist sum_vaxx, disc
tab sum_vaxx // seems ok

capture drop no_manip
gen no_manips=v_p_gets70==0 & v_p_pays10==0 & v_p_pays70==0 & v_p_pay0==0
sum sum_vaxx if no_manips
tab v_dec no_manips, col chi

tab no_manips v_p_gets70 

tab no_manips v_p_pays70 

tab v_dec no_manips if v_p_gets70==0& v_p_pays70==0 & v_p_pays10==0, col chi

ologit v_dec no_manips if no_manips | v_p_pay0==1

ologit v_dec no_manips $vaccine_vars if no_manips | v_p_pay0==1

//DEMOGRAPHICS DATA CLEANING
//wojewodstwo is ommited, because of no theoretical reason to include it
gen male=sex==2
rename (age year) (age_category age)
replace age=2021-age
gen age2=age^2 
//later check consistency of answers

rename (miasta wyksztalcenie) (city_population edu)
gen elementary_edu=edu==1|edu==2
gen secondary_edu=edu==3|edu==4
gen higher_edu=edu==5|edu==6|edu==7

rename m8 income
gen wealth_low=income==1|income==2
gen wealth_high=income==4|income==5
global wealth "wealth_low wealth_high"

//HEALTH
rename m9 health_state

gen health_poor=health_state==1|health_state==2
gen health_good=health_state==4|health_state==5

gen had_covid=(5-p31)
rename p31 had_covid_initial

rename p32 covid_hospitalized
tab covid_hospitalized

gen covid_friends=p33==1
rename p33 covid_friends_initial
//to create 3 variables know+hospitalizaed, know+not hospitalized
gen no_covid_friends=covid_friends==0
gen covid_friends_hospital=p34==1
rename p34 covid_friends_hospital_initial
gen covid_friends_nohospital=covid_friends==1&covid_friends_hospital==0

//RELIGION
gen religious=m10==2|m10==3
rename m10 religious_initial

rename m11 religious_freq
gen religious_often=religious_freq==4|religious_freq==5|religious_freq==6 //often = more than once a month

//Employment
gen status_unemployed=m12==5
gen status_pension=m12==6
gen status_student=m12==7
rename m12 empl_status

//COVID attitudes
rename p26 mask_wearing
rename p30_r1 distancing

//EMOTIONS
ren (p17_r1 p17_r2 p17_r3 p17_r4 p17_r5 p17_r6) (e_happiness e_fear e_anger e_disgust e_sadness e_surprise)
global emotions "e_happiness e_fear e_anger e_disgust e_sadness e_surprise"
foreach i in $emotions{
tab `i'
}
//RISK ATTITUDES
ren (p18_r1 p19_r1 p19_r2) (risk_overall risk_work risk_health)
global risk "risk_overall risk_work risk_health"
foreach i in $risk{
tab `i'
}
//WORRY
ren (p20_r1 p20_r2 p20_r3) (worry_covid worry_cold worry_unempl)
global worry "worry_covid worry_cold worry_unempl"
foreach i in $worry{
tab `i'
}
//SUBJECTIVE CONTROL
rename (p22_r1 p22_r2 p22_r3) (control_covid control_cold control_unempl)
global control "control_covid control_cold control_unempl"
foreach i in $control{
tab `i'
}
//INFORMED ABOUT:
rename (p23_r1 p23_r2 p23_r3) (informed_covid informed_cold informed_unempl)
global informed "informed_covid informed_cold informed_unempl"
foreach i in $informed{
tab `i'
}
//CONSPIRACY
rename (p30cd_r1 p30cd_r2 p30cd_r3) (conspiracy_general_info conspiracy_stats conspiracy_excuse)
global conspiracy "conspiracy_general_info conspiracy_stats conspiracy_excuse"
foreach i in $conspiracy{
tab `i'
}
egen conspiracy_score=rowmean($conspiracy)

gen consp_stats_high=conspiracy_sta==6|conspiracy_st==7
sum consp_stats_high [weight=waga]
//lets do general conspiracy score?

//VOTING
rename m20 voting
replace voting=0 if voting==.a
replace voting=8 if voting==5|voting==6
global voting "i.voting"


//covid impact estimations
rename (p24 p25) (subj_est_cases subj_est_death)
destring subj_est_cases subj_est_death, replace
replace subj_est_cases=. if subj_est_death>subj_est_cases*100
gen subj_est_cases_ln=ln(subj_est_cases+1)
replace subj_est_cases_ln=0 if subj_est_cases_ln==.
gen subj_est_death_l=ln(subj_est_death+1)
replace subj_est_death_l=0 if subj_est_death_l==.
//kind of check should be added here, some people did not get that deaths were in thouthands and cases in millions
global covid_impact "subj_est_cases_ln subj_est_death_l"


//[P40] Gdyby po pierwszych miesiącach szczepień potwierdziło się, że szczepionka jest skuteczna i bezpieczna, to byłbyś skłonny się zaszczepić? Zaznacz.
rename p40 decision_change
tab decision_change
//this variable will be included into analysis to see which factors (e.g. emotions) are assotiated with vaccination decision change
gen change_yes=decision_change==3|decision_change==4
replace change_yes=. if decision_change==.a

sum change_yes [weight=waga]
sum change_yes 

//health status details:
rename m9_1 health_vaccine_side_effects
gen vaccine_extra_risky=health_vaccine_side_effects==1
rename m9_2 health_covid_serious
gen covid_extra_risky=health_covid_serious==1
//"smoking categories consisted of “very light” (1–4 CPD), “light” (5–9 CPD), “moderate” (10–19 CPD), and “heavy” (20+ CPD) Rostron, Brian L., et al. "Changes in Cigarettes per Day and Biomarkers of Exposure Among US Adult Smokers in the Population Assessment of Tobacco and Health Study Waves 1 and 2 (2013–2015)." Nicotine and Tobacco Research 22.10 (2020): 1780-1787."
rename m9_3 health_smoking_yesno
rename m9_3a health_smoking_howmany
rename m9_3b health_smoking_atleast_once
//no smoking is a base level, ommited
gen health_smoking_vlight=health_smoking_howmany>0&health_smoking_howmany<5
gen health_smoking_light=health_smoking_howmany>4&health_smoking_howmany<10
gen health_smoking_moderate=health_smoking_howmany>9&health_smoking_howmany<20
gen health_smoking_heavy=health_smoking_howmany>19
global health_details "vaccine_extra_risky covid_extra_risky health_smoking_light health_smoking_moderate health_smoking_heavy"
//above global will be included into global demogr

foreach i in $health_details{
tab `i'
}

//trust
rename (trust_r1	trust_r2	trust_r3	trust_r4	trust_r5	trust_r6	trust_r7) (trust_EU	trust_gov	trust_neigh	trust_doctors	trust_media	trust_family	trust_science)
global trust "trust_EU	trust_gov	trust_neigh	trust_doctors	trust_media	trust_family	trust_science" //included into demogr
foreach i in $trust{
tab `i'
}

capture drop trust_*_Y trust_*_N

global trust_dummies ""
foreach var in $trust{
gen `var'_Y=`var'==1
gen `var'_N=`var'==3
global trust_dummies "$trust_dummies `var'_Y `var'_N"
}

sum $trust_dummies

//order
// robustness check: to add order effects for emotions
//[P17] Jak silnie odczuwasz w tej chwili (obecnie) poniższe emocje?
rename p17_order order_emotions
replace order_emotions=subinstr(order_emotions,"r","",.)
split order_emotions, p(",")
global g_order_emotions "order_emotions1 order_emotions2 order_emotions3 order_emotions4 order_emotions5 order_emotions6"

destring $g_order_emotions, replace
// robustness check: to add order effects for trust questions
//[trust_gov, trust_neighbours, trust_doctors, trust_media, trust_family, trust_scientists] Czy ma Pan zaufanie do?: 
rename trust_order order_trust
replace order_trust=subinstr(order_trust,"r","",.)
split order_trust, p(",")
global g_order_trust "order_trust1 order_trust2 order_trust3 order_trust4 order_trust5 order_trust6 order_trust7"
destring $g_order_trust, replace
// robustness check: to add order effects for risk questions
rename p19_order order_risk
replace order_risk=subinstr(order_risk,"r","",.)
split order_risk, p(",")
global g_order_risk "order_risk1 order_risk2"
destring $g_order_risk, replace
// robustness check: to add order effects for worry questions
rename p20_order order_worry
replace order_worry=subinstr(order_worry,"r","",.)
split order_worry, p(",")
global g_order_worry "order_worry1 order_worry2 order_worry3"
destring $g_order_worry, replace
// robustness check: to add order effects for control questions
rename p22_order order_control
replace order_control=subinstr(order_control,"r","",.)
split order_control, p(",")
global g_order_control "order_control1 order_control2 order_control3"
destring $g_order_control, replace
// robustness check: to add order effects for informed questions
rename p23_order order_informed
replace order_informed=subinstr(order_informed,"r","",.)
split order_informed, p(",")
global g_order_informed "order_informed1 order_informed2 order_informed3"
destring $g_order_informed, replace
// robustness check: to add order effects for estimations questions
rename p24p25_order order_estimations
replace order_estimations=subinstr(order_estimations,"p","",.)
split order_estimations, p(",")
global g_order_estimations "order_estimations1 order_estimations2"
destring $g_order_estimations, replace
// robustness check: to add order effects for conspiracy questions
rename p30cd_order order_conspiracy
replace order_conspiracy=subinstr(order_conspiracy,"r","",.)
split order_conspiracy, p(",")
global g_order_conspiracy "order_conspiracy1 order_conspiracy2 order_conspiracy3"
destring $g_order_conspiracy, replace
// robustness check: to add order effects for vaccine persuasive messages
rename p37_order order_vaccine_persuasion
replace order_vaccine_persuasion=subinstr(order_vaccine_persuasion,"r","",.)
replace order_vaccine_persuasion=subinstr(order_vaccine_persuasion,",","",.)
destring order_vaccine_persuasion, replace //RK:do we need destring? only 3 records have missing values = no message except price was shown
replace order_vaccine_persuasion=0 if order_vaccine_persuasio==. //RK:to not drop no message subjects
tab order_vaccine_persuasion //added into next global 


replace covid_hosp=0 if covid_hosp==.a


global order_effects "$g_order_emotions $order_trust $g_order_risk $g_order_worry $g_order_control $g_order_informed $g_order_estimations $g_order_conspiracy order_vaccine_persuasion"

//TIME
// define variable that slows percentile, by time 
rename survey_finish_time time
sort time
gen time_perc = _n/_N
//use it later during the robustness check, when results will be ready (add/remove 5% fastest participants)
rename (p19_time p20_time p22_time p23_time p24_time p25_time p30cd_time p37_time) (time_risk time_worry time_control time_informed time_estimationscases time_estimationsdeath time_conspiracy time_v_persuasion)
//do drop too quick subjects later

//open ended question:
// [P38] Opisz poniżej główne powody swojej decyzji odnośnie zaszczepienia się na koronawirusa. 
// [P39] Kto lub co mogłoby zmienić Twoją decyzję odnośnie zaszczepienia się na koronawirusa? Opisz poniżej.
// [optional] [P21] Jakie czynniki mają główny wpływ na to, w jakiej mierze jesteś zaniepokojony/a pandemią koronawirusa? 
//will be classified and set of explanations will be produced.
capture export excel respondent_id v_decision open_ended_v_reasoning P380 open_ended_v_influencer P390 using "C:\Users\johns_000\Desktop\openendedquestionsforclassification.xls", firstrow(variables) replace
//every explanation will be assosiated with a dummy variable
rename p38 open_ended_v_reasoning
rename p39 open_ended_v_influencer
rename p21 open_ended_fear_why
capture global explanations "..."//will be included into "contol" global


//////////////////*************GLOBALS***************////////////
global wealth "wealth_low wealth_high" //included into demogr
global demogr "male age age2 i.city_population secondary_edu higher_edu $wealth health_poor health_good $health_details had_covid covid_hospitalized covid_friends religious i.religious_freq status_unemployed status_pension status_student" 
global demogr_int "male age higher_edu"
global emotions "e_happiness e_fear e_anger e_disgust e_sadness e_surprise"
global risk "risk_overall risk_work risk_health"
global worry "worry_covid worry_cold worry_unempl"
global control "control_covid control_cold control_unempl $explanations"
global informed "informed_covid informed_cold informed_unempl"
global conspiracy "conspiracy_general_info conspiracy_stats conspiracy_excuse" //we also have conspiracy_score
global voting "i.voting"
global health_advice "mask_wearing distancing"
foreach i in $health_advice{
tab `i'
}
global covid_impact "subj_est_cases_ln subj_est_death_l"
global order_effects ""
// DEFINED (UND UPDATED TO NEW VERSION) BEFORE! global vaccine_vars "v_producer_reputation	v_efficiency	v_safety		v_other_want_it	v_scientific_authority	v_ease_personal_restrictions	v_p_gets70	v_p_pays10	v_p_pays70" // i leave out scarcity -- sth that supposedly everybody knows. we can't estimate all because of ariadna's error anyway
// global vaccine_short "v_producer_reputation	v_efficiency	v_safety	v_scarcity	v_other_want_it	v_scientific_authority	v_ease_personal_restrictions"
global prices "v_p_gets70	v_p_pays10	v_p_pays70"

//////////****ORDERED LOGITS**********/////
quietly ologit v_decision $vaccine_vars $demogr [pweight=waga]
est store m_1

quietly ologit v_decision $vaccine_vars $demogr $voting [pweight=waga] 
est store m_21

quietly ologit v_decision $vaccine_vars $demogr $voting $emotions $risk $worry  $trust_dummies  [pweight=waga]
est store m_22
test $emotions $risk $worry $trust_dummies 

quietly ologit v_decision $vaccine_vars $demogr $voting $emotions $risk $worry $trust_dummies $control $informed conspiracy_score $covid_impact $health_advice [pweight=waga]
est store m_23
test $control $informed conspiracy_score $covid_impact $health_advice

ologit v_decision no_manips $vaccine_vars $demogr $voting $emotions $risk $worry $trust_dummies $control $informed conspiracy_score $covid_impact $health_advice


// XXXXXXXXXXXXXXXXXXXXXXX add order effects

//check for interactions: vaccine persuasive messages set 1 + demographics
global interactions ""
foreach manipulation in $vaccine_vars {
	foreach demogr in $demogr_int {
	local abb=substr("`manipulation'",1,14)
	gen i_`abb'_`demogr'=`abb'*`demogr'	
	global interactions "$interactions i_`abb'_`demogr'" 	
}
}
dis "$interactions"
quietly ologit v_decision $vaccine_vars $demogr $voting $emotions $risk $worry $trust_dummies $control $informed conspiracy_score $covid_impact $health_advice $interactions
est store m_3
test $interactions

//check for interactions: vaccine persuasive messages set 1 + vaccine persuasive messages set 2
global int_manips ""
foreach manipulation in $vaccine_short {
	foreach man2 in $vaccine_vars {
	local abb=substr("`manipulation'",1,14)
	local abb2=substr("`man2'",1,14)
	 gen vi_`abb'_`abb2'=`abb'*`abb2'	
	global int_manips "$int_manips vi_`abb'_`abb2'" 	
}
}
dis "$int_manips"
quietly ologit v_decision $vaccine_vars $demogr $voting $emotions $risk $worry $trust_dummies $control $informed conspiracy_score $covid_impact $health_advice $int_manips
est store m_4
test $int_manips

//check for interactions: vaccine price + income
global price_wealth ""
foreach price in $prices {
	foreach level in $wealth {
	gen wp_`price'_`level'=`price'*`level'
	global price_wealth "$price_wealth wp_`price'_`level'" 	
}
}
dis "$price_wealth"
quietly ologit v_decision $vaccine_vars $demogr $voting $emotions $risk $worry $trust_dummies $control $informed conspiracy_score $covid_impact $health_advice $price_wealth
est store m_5
test $price_wealth

//check for interactions: vaccine persuasive messages (producer from EU; vaccine safety + voting)
//gen int_voting_prod=voting*v_producer_reputation
//gen int_voting_safety=voting*v_safety
xi: quietly ologit v_decision $vaccine_vars $demogr $voting $emotions $risk $worry $trust_dummies $control $informed conspiracy_score $covid_impact $health_advice  i.voting*v_producer_reputation i.voting*v_safety
est store m_6
test _IvotXv_pro_1 _IvotXv_pro_2 _IvotXv_pro_3 _IvotXv_pro_4 _IvotXv_pro_7 _IvotXv_pro_8 _IvotXv_pro_9 _IvotXv_saf_1 _IvotXv_saf_2 _IvotXv_saf_3 _IvotXv_saf_4 _IvotXv_saf_7 _IvotXv_saf_8 _IvotXv_saf_9

/*
//check for interactions: vaccine persuasive messages set 1 + conspiracy score
global int_consp_manip ""
foreach manipulation in $vaccine_vars {
	local abb=substr("`manipulation'",1,14)
	gen `abb'_conspiracy=`abb'*conspiracy_score	
	global int_consp_manip "$int_consp_manip `abb'_conspiracy" 	
}
dis "$int_consp_manip"
quietly ologit v_decision $vaccine_vars $demogr $voting $emotions $risk $worry $trust_dummies $control $informed conspiracy_score $covid_impact $health_advice $int_consp_manip
est store m_7
test $int_consp_manip
*/


capture drop i_v*trust_*
global int_trust_manip ""
foreach manipulation in $vaccine_vars {
	foreach trust in $trust_dummies {
	local abb=substr("`manipulation'",1,14)
	gen i_`abb'_`trust'=`abb'*`trust'	
	global int_trust_manip "$int_trust_manip i_`abb'_`trust'" 	
}
}

dis "$int_trust_manip"
quietly ologit v_decision $vaccine_vars $demogr $voting $emotions $risk $worry $trust_dummies $control $informed conspiracy_score $covid_impact $health_advice $int_trust_manip
est store m_8
test $int_trust_manip

// XXXXXXXXXXXXXX maybe only gov, scientists?


est table m_1 m_21 m_22 m_23, b(%12.3f) var(20) star(.01 .05 .10) stats(N)
// m_3 m_4 m_5 m_6 m_7, b(%12.3f) var(20) star(.01 .05 .10) stats(N)
//result:yes/no interactions detected
//result:yes/no order effects detected 
/////****END********************************/////////

est table m_2 m_1 m_0, b(%12.3f) var(20) star(.01 .05 .10) stats(N)

ologit decision_change $demogr $voting $emotions

// FIGURES
tab v_decision, generate(dec)
/////////**********************************************////////////////
/////////**********************************************////////////////
/////////**********************************************////////////////
