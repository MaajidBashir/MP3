************************************
* Import and merge data
************************************	

*Import Volunteer Data*
import delimited "/Users/maajid/Documents/Duke/Fall 2021/807. Master's Project/808/nahno data december 2021.csv", varnames(1) clear
drop disabilities hasdisability graduationyear major university universityconfirm universityname lastlogin 
destring ïid, gen(ID) force
compress
save "/Users/maajid/Documents/Duke/Fall 2021/807. Master's Project/808/Volunteers Data.dta", replace

*Import Opportunities Data*

import delimited "/Users/maajid/Documents/Duke/Fall 2021/807. Master's Project/808/projects_1635687419.csv", clear
rename ïïid opportunity_id
drop ngoid ngoname category subcategory sdgs volunteersrestrictedgovernorates volunteersrestrictedareas
compress
save "/Users/maajid/Documents/Duke/Fall 2021/807. Master's Project/808/Opportunities data.dta", replace


*Import Applications Data*

import delimited using "/Users/maajid/Documents/Duke/Fall 2021/807. Master's Project/808/all_applied.csv", clear
duplicates drop opportunity_id user_id, force
rename user_id ID
save "/Users/maajid/Documents/Duke/Fall 2021/807. Master's Project/808/Applications.dta", replace


*Cross and Merge* 

use "/Users/maajid/Documents/Duke/Fall 2021/807. Master's Project/808/Volunteers Data.dta", clear

set seed 12345 

keep if runiform() < .01

compress

cross using "/Users/maajid/Documents/Duke/Fall 2021/807. Master's Project/808/Opportunities data.dta"

merge 1:1 opportunity_id ID using "/Users/maajid/Documents/Duke/Fall 2021/807. Master's Project/808/Applications.dta"

drop if _merge == 2

rename confirmedhours hrs_confirmed

rename opportunitiesapplied opp_appfor

rename yearsofexperience year_exp

rename totalhours tot_hrs

rename malesattended male_att

rename femalesattended

*Generate new variable*

gen Apply=.

replace Apply=1 if (_merge == 3)

replace Apply=0 if (_merge == 1)

*Descriptive Statistics*

asdoc sum opp_appfor hrs_confirmed vol_applied vol_atten tot_hrs days male_att fem_att age

asdoc tab Gender_R

asdoc tab Nationality_N

asdoc tab COVID

asdoc WorkStatus_R

*Pre-Regression*

gen age = date("2022-4-20", "YMD") - date(birthday, "YMD")
 
replace age = age/365.25
 
replace age = floor(age)

recode age (0/20=0 from_0_to_20) (21/30=1 from_21_to_30) (31/max=2 from_31_to_max), gen(agegrp)
 
encode gender, generate(Gender_R)

encode(nationality3), gen(Nationality_N)

gen date2 = date(creationdate,"YMD")

format date2 %td

gen COVID = date2 > td(11mar2020) if date2 < .

encode workstatus, generate(WorkStatus_R)

*Estimations*

eststo: ivreg2 Apply i.Gender_R, cluster(ID opportunity_id)

eststo: ivreg2 Apply i.agegrp, cluster(ID opportunity_id)

eststo: ivreg2 Apply i.Nationality_N, cluster(ID opportunity_id)

eststo: ivreg2 Apply COVID, cluster(ID opportunity_id)

eststo: ivreg2 Apply i.WorkStatus_R, cluster(ID opportunity_id)

esttab

