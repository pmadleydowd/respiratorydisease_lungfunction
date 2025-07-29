********************************************************************************
* Author: 		Paul Madley-Dowd 
* Date: 		15 May 2025
* Description: 	Run ordinal regression analyses on categorical outcome using complete records analyses and using multiple imputation 
********************************************************************************
* Contents
********************************************************************************
* 1 - Create environment and load data
* 2 - Create imputed data
* 3 - Run regression analyses and output results

********************************************************************************
* 1 -  Create environment 
********************************************************************************
* Define global variables
	* outcome variable
global outvar prfev1pred_class4

	* exposure variables 
global expvars asthma8_total_dx bronchiec8_total_dx drv_lrti_tertile tb_dx NRD_dx diaphragm_total_dx ICS8_dx preterm
 
********************************************************************************
* 2 - Create imputed data
********************************************************************************
* 2.1 - asthma analysis
********************************************************************************
	* Load derived data
use "$Datadir/Derived_data_PMD.dta", clear
	* apply eligibility criteria 
keep if eligible == 1

	* apply restriction to observed values for IMD, ethnicity, smoking 
drop if drv_ethnic_bin == . | geo_lc_5209 == . | pre_smk123 == . | matpatsmok == .

	* set up stata for imputation
mi set flong 

mi register regular /// complete variables
	asthma8_total_dx drv_lrti_tertile /// exposure variables - removed bronchiectasis due to low counts
	sex drv_ethnic_bin geo_lc_5209 pre_smk123 matpatsmok // confounder variables
	
mi register imputed /// incomplete vars
	prfev1pred_class4 /// outcome variable 
	NRD_dx diaphragm_total_dx ICS8_dx /// exposure variables - removed tb due to very small number of cases
	pm10_tot_avg_t3 pm10_tot_avg_y8 prenat_NO2 infant_NO2 bmi8  /// confounder variables
	BMI_age7 // auxiliary variables

mi impute chained ///
	(ologit) prfev1pred_class4 /// 
	(logit, omit(i.diaphragm_total_dx)) NRD_dx ///
	(logit, omit(i.NRD_dx)) diaphragm_total_dx ///
	(logit) ICS8_dx /// 
	(pmm, knn(10)) pm10_tot_avg_t3 ///
	(pmm, knn(10)) pm10_tot_avg_y8 ///
	(pmm, knn(10)) prenat_NO2 /// 
	(pmm, knn(10)) infant_NO2 ///
	(pmm, knn(10)) bmi8 ///
	(pmm, knn(10)) BMI_age7 ///
	= i.asthma8_total_dx i.drv_lrti_tertile ///
	  i.sex i.drv_ethnic_bin i.geo_lc_5209 i.pre_smk123 i.matpatsmok ///
	, add(100) burnin(25) rseed(1234) dots

save "$Datadir/Imputed_data_ologit_asthma.dta", replace 

********************************************************************************
* 2.2 - Bronchiectasis
********************************************************************************
* NOTE not run due to low counts of the outcome at specific values

********************************************************************************
* 2.3 - Lower Respiratory Tract Infections
********************************************************************************
	* Load derived data
use "$Datadir/Derived_data_PMD.dta", clear
	* apply eligibility criteria 
keep if eligible == 1

	* apply restriction to observed values for IMD, ethnicity, smoking 
drop if drv_ethnic_bin == . | geo_lc_5209 == . | matpatsmok == .

	* set up stata for imputation
mi set flong 

mi register regular /// complete variables
	asthma8_total_dx drv_lrti_tertile bronchiec8_total_dx /// exposure variables 
	sex drv_ethnic_bin geo_lc_5209 matpatsmok scoliosis8_total_dx neurodis8_total_dx preterm // confounder variables
	
mi register imputed /// incomplete vars
	prfev1pred_class4 /// outcome variable 
	NRD_dx diaphragm_total_dx ICS8_dx /// exposure variables - removed tb due to very small number of cases
	bmi8  /// confounder variables
	BMI_age7 // auxiliary variables
	
	

mi impute chained ///
	(ologit) prfev1pred_class4 /// 
	(logit, omit(i.diaphragm_total_dx)) NRD_dx ///
	(logit, omit(i.NRD_dx i.bronchiec8_total_dx i.scoliosis8_total_dx)) diaphragm_total_dx ///
	(logit) ICS8_dx /// 
	(pmm, knn(10)) bmi8 ///
	(pmm, knn(10)) BMI_age7 ///
	= i.asthma8_total_dx i.drv_lrti_tertile i.bronchiec8_total_dx ///
	  i.sex i.drv_ethnic_bin i.geo_lc_5209 i.matpatsmok i.scoliosis8_total_dx i.neurodis8_total_dx i.preterm ///
	, add(100) burnin(25) rseed(1234) dots 

save "$Datadir/Imputed_data_ologit_lrti.dta", replace 


********************************************************************************
* 2.4 - TB
********************************************************************************
* NOTE not run due to low counts of the outcome at specific values


********************************************************************************
* 2.5 - Neonatal respiratory disease
********************************************************************************
	* Load derived data
use "$Datadir/Derived_data_PMD.dta", clear
	* apply eligibility criteria 
keep if eligible == 1

	* apply restriction to observed values for IMD, ethnicity
drop if drv_ethnic_bin == . | geo_lc_5209 == . 

	* set up stata for imputation
mi set flong 

mi register regular /// complete variables
	asthma8_total_dx drv_lrti_tertile bronchiec8_total_dx /// exposure variables 
	sex drv_ethnic_bin geo_lc_5209 preterm lowbw // confounder variables
	
mi register imputed /// incomplete vars
	prfev1pred_class4 /// outcome variable 
	NRD_dx /// exposure variables - removed tb and diaphragm_total_dx due to very small number of cases and ICS8_dx as always missing when NRD_dx missing
	

mi impute chained ///
	(ologit) prfev1pred_class4 /// 
	(logit) NRD_dx ///
	= i.asthma8_total_dx i.drv_lrti_tertile i.bronchiec8_total_dx ///
	  i.sex i.drv_ethnic_bin i.geo_lc_5209 i.preterm i.lowbw ///
	, add(100) burnin(25) rseed(1234) dots 

save "$Datadir/Imputed_data_ologit_NRD.dta", replace 

********************************************************************************
* 2.6 - Diaphragmatic hernia
********************************************************************************
* NOTE not run due to low counts of the outcome at specific values

********************************************************************************
* 2.6 - ISC use 
********************************************************************************
	* Load derived data
use "$Datadir/Derived_data_PMD.dta", clear
	* apply eligibility criteria 
keep if eligible == 1

	* apply restriction to observed values for IMD, ethnicity, smoking 
drop if drv_ethnic_bin == . | geo_lc_5209 == . 

	* set up stata for imputation
mi set flong 

mi register regular /// complete variables
	asthma8_total_dx drv_lrti_tertile /// exposure variables - removed bronchiectasis due to low counts
	sex drv_ethnic_bin geo_lc_5209 // confounder variables
	
mi register imputed /// incomplete vars
	prfev1pred_class4 /// outcome variable 
	diaphragm_total_dx ICS8_dx /// removed tb and NRD_dx as always missing when ICS8_dx missing

mi impute chained ///
	(ologit) prfev1pred_class4 /// 
	(logit) diaphragm_total_dx ///
	(logit) ICS8_dx /// 
	= i.asthma8_total_dx i.drv_lrti_tertile ///
	  i.sex i.drv_ethnic_bin i.geo_lc_5209 ///
	, add(100) burnin(25) rseed(1234) dots 

save "$Datadir/Imputed_data_ologit_ICSuse.dta", replace 


********************************************************************************
* 2.7 - preterm 
********************************************************************************
	* Load derived data
use "$Datadir/Derived_data_PMD.dta", clear
	* apply eligibility criteria 
keep if eligible == 1

	* apply restriction to observed values for IMD, ethnicity, smoking 
drop if drv_ethnic_bin == . | geo_lc_5209 == . | pre_smk123 == . 

	* set up stata for imputation
mi set flong 

mi register regular /// complete variables
	preterm asthma8_total_dx drv_lrti_tertile  /// exposure variables - removed bronchiectasis due to low counts
	sex drv_ethnic_bin geo_lc_5209 pre_smk123  // confounder variables
	
mi register imputed /// incomplete vars
	prfev1pred_class4 /// outcome variable 
	ICS8_dx // auxiliaries - removed others due to low counts 

mi impute chained ///
	(ologit) prfev1pred_class4 /// 
	(logit) ICS8_dx ///
	= i.preterm i.asthma8_total_dx i.drv_lrti_tertile ///
	  i.sex i.drv_ethnic_bin i.geo_lc_5209 i.pre_smk123 ///
	, add(100) burnin(25) rseed(1234) dots 

save "$Datadir/Imputed_data_ologit_preterm.dta", replace 
	
********************************************************************************
* 3 - Run regression analyses and output results
********************************************************************************

capture postutil close 
tempname memhold 

postfile `memhold' _expord _modelord str20 outcome ///
	str20 exposure exposure_level str75 model ///
	modeln modeln_with_exposure ///
	modeln_with_outcome1 modeln_with_expandout1 ///
	modeln_with_outcome2 modeln_with_expandout2 ///
	modeln_with_outcome3 modeln_with_expandout3 ///
	modeln_with_outcome4 modeln_with_expandout4 ///	
	OR ORlci ORuci str30 ORCI_str or_pvalue ///
	str200 confounders str200 auxiliaries str200 restricted_complete /// 
	nimps niter /// 
	using "$Outdir\Ologit_regression_output.dta", replace

* set output count initial parameters	
local i = 0 // counter for exposure variables

foreach exposure in $expvars { 
	
	* define confounder variables for each exposure variable 
	if "`exposure'" == "asthma8_total_dx"{ 		
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 i.pre_smk123 i.matpatsmok pm10_tot_avg_t3 pm10_tot_avg_y8 prenat_NO2 infant_NO2 bmi8
		local impdataset "$Datadir/Imputed_data_ologit_asthma.dta"
		local restriction "drv_ethnic_bin == . | geo_lc_5209 == . | pre_smk123 == . | matpatsmok == ."
		local auxvars drv_lrti_tertile NRD_dx diaphragm_total_dx ICS8_dx BMI_age7 
	}
	else if "`exposure'" == "bronchiec8_total_dx" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 /*tb_dx*/ // removed tb due to perfect prediction 
		local impdataset "EMPTY"	// not run due to low counts of outcome at specific values	
		local restriction "EMPTY"
		local auxvars
	}
	else if "`exposure'" == "drv_lrti_tertile" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 i.scoliosis8_total_dx i.neurodis8_total_dx i.preterm bmi8 i.matpatsmok i.bronchiec8_total_dx
		local impdataset "$Datadir/Imputed_data_ologit_lrti.dta" 
		local restriction "drv_ethnic_bin == . | geo_lc_5209 == . | matpatsmok == ."
		local auxvars asthma8_total_dx bronchiec8_total_dx NRD_dx diaphragm_total_dx ICS8_dx  BMI_age7

	}
	else if "`exposure'" == "tb_dx" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 
		local impdataset "EMPTY"	// not run due to low counts of outcome at specific values	
		local restriction "EMPTY"
		local auxvars
	}
	else if "`exposure'" == "NRD_dx" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 i.preterm i.lowbw
		local impdataset "$Datadir/Imputed_data_ologit_NRD.dta" 
		local restriction "drv_ethnic_bin == . | geo_lc_5209 == ."
		local auxvars asthma8_total_dx drv_lrti_tertile bronchiec8_total_dx 
	}
	else if "`exposure'" == "diaphragm_total_dx" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 i.pre_smk123
		local impdataset "EMPTY"	// not run due to low counts of outcome at specific values	
		local restriction "EMPTY"
		local auxvars
	}	
	else if "`exposure'" == "ICS8_dx" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 i.asthma8_total_dx 
		local impdataset "$Datadir/Imputed_data_ologit_ICSuse.dta" 
		local restriction "drv_ethnic_bin == . | geo_lc_5209 == . "
		local auxvars asthma8_total_dx drv_lrti_tertile diaphragm_total_dx
	}
	else if "`exposure'" == "preterm" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 i.pre_smk123
		local impdataset "$Datadir/Imputed_data_ologit_preterm.dta" 
		local restriction "drv_ethnic_bin == . | geo_lc_5209 == . | pre_smk123 == ."
		local auxvars asthma8_total_dx drv_lrti_tertile ICS8_dx
	}
	else {
		disp "Error: Exposure not in list - confounders not defined"
		continue, break
    }  
	
	
	
	* load data
	use "$Datadir/Derived_data_PMD.dta", clear
	
	* apply eligibility criteria 
	keep if eligible == 1
	
	disp "test1"
	
	* set parameters for counts
	local j = 0 // counter for models
	local i = `i' + 1 // exposure counter
	
	disp "test2"
	
	* check the number of levels for the exposure variable 
	quietly levelsof `exposure', local(levels)
	local num_levels: word count `levels'
	display "Exposure variable: `exposure'"
	display "Number of levels: `num_levels'"
	

	disp "test3"

	
	* unadjusted complete records analysis 
	local j = `j' + 1 // model counter
	ologit $outvar ib0.`exposure' , or // logistic regression model
		matrix unadj_or = r(table)
		estimates store unadj
	disp "test4"

	
	forvalues explev = 2(1)`num_levels'{ // for loop required as not all exposures are binary
		estimates restore unadj 
		local modn = e(N) // model n
		
		count if e(sample) & $outvar == 1 // number with outcome == 1
		local modn_wout1 = r(N)
		count if e(sample) & $outvar == 2 // number with outcome == 2
		local modn_wout2 = r(N)		
		count if e(sample) & $outvar == 3 // number with outcome == 3
		local modn_wout3 = r(N)
		count if e(sample) & $outvar == 4 // number with outcome == 4
		local modn_wout4 = r(N)		
		
		count if e(sample) & `exposure' == `explev'-1 // number with exposure (note explev will be 1 higher than the level of the exposure in the data)
		local modn_wexp = r(N)
		
		count if e(sample) & `exposure' == `explev'-1 & $outvar == 1 // number with exposure and outcome == 1
		local modn_wexp_wout1 = r(N)
		count if e(sample) & `exposure' == `explev'-1 & $outvar == 2 // number with exposure and outcome == 2
		local modn_wexp_wout2 = r(N)
		count if e(sample) & `exposure' == `explev'-1 & $outvar == 3 // number with exposure and outcome == 3
		local modn_wexp_wout3 = r(N)	
		count if e(sample) & `exposure' == `explev'-1 & $outvar == 4 // number with exposure and outcome == 4
		local modn_wexp_wout4 = r(N)		
	
		local or    =  unadj_or[1,`explev']  
		local orlci =  unadj_or[5,`explev']
		local oruci =  unadj_or[6,`explev']
		local orpval = unadj_or[4,`explev']
		local orci_str = strofreal(`or', "%5.2f") + " (" + strofreal(`orlci',"%5.2f") + ", " + strofreal(`oruci',"%5.2f") + ")"
		
	
		post `memhold' (`i') (`j') ("$outvar") ///
			("`exposure'") (`explev'-1) ///
			("Unadjusted ordinal logistic regression") ///
			(`modn') (`modn_wexp') ///
			(`modn_wout1') (`modn_wexp_wout1') ///
			(`modn_wout2') (`modn_wexp_wout2') ///
			(`modn_wout3') (`modn_wexp_wout3') ///
			(`modn_wout4') (`modn_wexp_wout4') ///			
			(`or') (`orlci') (`oruci') ("`orci_str'") (`orpval') ///
			("Unadjusted model - no confounders used") ("Not imputed model - no auxiliaries used") ("Restriction to complete records") /// 
			(.) (.)  
	}
	
	disp "test5"
	
	
	* adjusted complete records analysis 
	local j = `j' + 1 // model counter
	ologit $outvar ib0.`exposure' `confounders', or // logistic regression model
		matrix adj_or = r(table)
		estimates store adj
	disp "test6"
		
		
	forvalues explev = 2(1)`num_levels'{ // for loop required as not all exposures are binary
		estimates restore adj
		local modn = e(N) // model n
		
		count if e(sample) & $outvar == 1 // number with outcome == 1
		local modn_wout1 = r(N) 
		count if e(sample) & $outvar == 2 // number with outcome == 2
		local modn_wout2 = r(N) 		
		count if e(sample) & $outvar == 3 // number with outcome == 3
		local modn_wout3 = r(N) 	
		count if e(sample) & $outvar == 4 // number with outcome == 4
		local modn_wout4 = r(N) 		
		
		count if e(sample) & `exposure' == `explev'-1 // number with exposure
		local modn_wexp = r(N)
		
		count if e(sample) & `exposure' == `explev'-1 & $outvar == 1 // number with exposure and outcome == 1
		local modn_wexp_wout1 = r(N)
		count if e(sample) & `exposure' == `explev'-1 & $outvar == 2 // number with exposure and outcome == 2
		local modn_wexp_wout2 = r(N)
		count if e(sample) & `exposure' == `explev'-1 & $outvar == 3 // number with exposure and outcome == 3
		local modn_wexp_wout3 = r(N)
		count if e(sample) & `exposure' == `explev'-1 & $outvar == 4 // number with exposure and outcome == 4
		local modn_wexp_wout4 = r(N)		
	
		local or    =  adj_or[1,`explev']  
		local orlci =  adj_or[5,`explev']
		local oruci =  adj_or[6,`explev']
		local orpval = adj_or[4,`explev']
		local orci_str = strofreal(`or', "%5.2f") + " (" + strofreal(`orlci',"%5.2f") + ", " + strofreal(`oruci',"%5.2f") + ")"
			
		post `memhold' (`i') (`j') ("$outvar") ///
			("`exposure'") (`explev'-1) ///
			("Adjusted ordinal logistic regression") ///
			(`modn') (`modn_wexp') ///
			(`modn_wout1') (`modn_wexp_wout1') ///
			(`modn_wout2') (`modn_wexp_wout2') ///
			(`modn_wout3') (`modn_wexp_wout3') ///
			(`modn_wout4') (`modn_wexp_wout4') ///			
			(`or') (`orlci') (`oruci') ("`orci_str'") (`orpval') ///
			("`confounders'") ("Not imputed model - no auxiliaries used") ("Restriction to complete records") /// 
			(.) (.)  
	}
	
	disp "test7"
	
	* adjusted multiple imputation analysis 
		* break if no information available to do MI with 
	local j = `j' + 1 // model counter
	if `modn_wexp' <= 1 | ///
	   `modn_wout1' <= 1 | `modn_wexp_wout1' <= 1 | ///
	   `modn_wout2' <= 1 | `modn_wexp_wout2' <= 1 | ///
	   `modn_wout3' <= 1 | `modn_wexp_wout3' <= 1 | ///
	   `modn_wout4' <= 1 | `modn_wexp_wout4' <= 1  ///
	{

		post `memhold' (`i') (`j') ("$outvar") ///
			("`exposure'") (.) ///
			("Multiple imputation adjusted ordinal logistic regression") ///
			(.) (.) /// 
			(.) (.) ///
			(.) (.) ///
			(.) (.) ///
			(.) (.) ///			
			(.) (.) (.) ("MI not run - counts too low") (.) ///
			("") ("") ("") /// 
			(.) (.)  
			
		continue	
	} 
	else {

		* load imputed dataset
		use "`impdataset'", clear 
				
		mi estimate, eform: ologit $outvar ib0.`exposure' `confounders' // logistic regression model
			matrix mi_adj_or = r(table)
			local nimps = e(M_mi)
			local niter = 25 // cannot obtain this from e(), setting manually
			estimates store mi_adj
			
		disp "Running emargins_rd: "
			disp "Outcome =  $outvar"
			disp "Exposure = `exposure'"
			disp "Confounders = `confounders'"	
			
		disp "test8"

		forvalues explev = 2(1)`num_levels'{ // for loop required as not all exposures are binary
			estimates restore mi_adj
			local modn = e(N) // model n
				
			local or    =  mi_adj_or[1,`explev']  
			local orlci =  mi_adj_or[5,`explev']
			local oruci =  mi_adj_or[6,`explev']
			local orpval = mi_adj_or[4,`explev']
			local orci_str = strofreal(`or', "%5.2f") + " (" + strofreal(`orlci',"%5.2f") + ", " + strofreal(`oruci',"%5.2f") + ")"
			
			post `memhold' (`i') (`j') ("$outvar") ///
				("`exposure'") (`explev'-1) ///
				("Multiple imputation adjusted ordinal logistic regression") ///
				(`modn') (.) ///
				(.) (.) ///
				(.) (.) ///
				(.) (.) ///
				(.) (.) ///				
				(`or') (`orlci') (`oruci') ("`orci_str'") (`orpval') ///
				("`confounders'") ("`auxvars'") ("`restriction'") /// 
				(`nimps') (`niter')  
		}
	} 
}
postclose `memhold'


use "$Outdir\Ologit_regression_output.dta", clear


