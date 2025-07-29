********************************************************************************
* Author: 		Paul Madley-Dowd 
* Date: 		14 Feb 2025
* Description: 	Apply any further derivations to the data
********************************************************************************
* Contents
********************************************************************************
* 1 - Create environment and load data
* 2 - Derive further variables needed for analysis
* 3 - Derive eligibility criteria 
* 4 - Save dataset
********************************************************************************
* 1 -  Create environment and load data
********************************************************************************
use "$Datadir/PM dataset.dta", clear
mi unset, asis // data has been mi set previously!

* merge on additional BMI information 
merge 1:1 sid4486 using "$Rawdatdir/20250409_b4486_pheno_BMI7", keepusing(sid4486 f7ms026a f7ms102) 
keep if _merge == 1 | _merge ==3 
drop _merge

********************************************************************************
* 2 - Derive further variables needed for analysis
********************************************************************************
* Outcome derivations
	* binary outcome variable 
recode prfev1pred_class4 (1/2 = 0) (3/4 = 1) , gen(prfev1pred_bin)
label define lb_binprfev 0 "High or Average" 1 "Below average or persistently low"
label values prfev1pred_bin lb_binprfev

* Exposure variables
	* LRTI tertiles
gen drv_lrti_tertile = 0 if lrti_total_dx == 0 
replace drv_lrti_tertile = lrti_tertile if lrti_total_dx == 1 

* Confounder variables 
	* Ethnicity 
encode ethnic , gen(drv_ethnic_fct)
recode drv_ethnic_fct (1/3 = 1) (4 = 0), gen(drv_ethnic_bin)
label define lb_ethbin 0 "White" 1 "All other ethnicities combined"
label values drv_ethnic_bin lb_ethbin

* auxiliary variables 
destring f7ms026a, gen(BMI_age7)
destring f7ms102, gen(SDscoreBMI_age7)
replace BMI_age7 = . if BMI_age7 <=0 | missing(BMI_age7) == 1
replace SDscoreBMI_age7 = . if SDscoreBMI_age7 <=-100 | missing(SDscoreBMI_age7) == 1


********************************************************************************
* 3 - Derive eligibility criteria 
********************************************************************************
egen misscount_exp = rowmiss(asthma8_total_dx bronchiec8_total_dx drv_lrti_tertile ICS8_dx hosp_admit_dx tb_dx icu_dx NRD_dx diaphragm_total_dx nicu_dx)
sum misscount_exp
gen nohealth_link = misscount_exp == r(max)	

gen eligible = 1 if ///
	kz011b == 1 & /// restricting to those alive at age 1
	kz030 != -10 & /// restricting to core sample due 
	nohealth_link == 0 // restricting to those with available health linkage data
	
	
********************************************************************************
* 4 - Save dataset
********************************************************************************
save "$Datadir/Derived_data_PMD.dta", replace
