********************************************************************************
* Author: 		Paul Madley-Dowd 
* Date: 		14 Feb 2025
* Description: 	Run regression analyses on binary outcome using complete records analyses and using multiple imputation 
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
global outvar prfev1pred_bin

	* exposure variables 
global expvars asthma8_total_dx bronchiec8_total_dx drv_lrti_tertile tb_dx NRD_dx diaphragm_total_dx ICS8_dx preterm
 
* Create commands to run margins as part of MI 
capture program drop emargins_rd
program emargins_rd, eclass properties(mi)
	args outvar expvar covars
	
	logistic `outvar' i.`expvar' `covars'
	margins, dydx(`expvar') post 
end


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
	prfev1pred_bin /// outcome variable 
	NRD_dx diaphragm_total_dx ICS8_dx /// exposure variables - removed tb due to very small number of cases
	pm10_tot_avg_t3 pm10_tot_avg_y8 prenat_NO2 infant_NO2 bmi8  /// confounder variables
	BMI_age7 // auxiliary variables

mi impute chained ///
	(logit) prfev1pred_bin /// 
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

save "$Datadir/Imputed_data_asthma.dta", replace 

********************************************************************************
* 2.2 - Bronchiectasis
********************************************************************************
* NOTE not run due to low counts of the outcome

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
	prfev1pred_bin /// outcome variable 
	NRD_dx diaphragm_total_dx ICS8_dx /// exposure variables - removed tb due to very small number of cases
	bmi8  /// confounder variables
	BMI_age7 // auxiliary variables
	
	

mi impute chained ///
	(logit) prfev1pred_bin /// 
	(logit, omit(i.diaphragm_total_dx)) NRD_dx ///
	(logit, omit(i.NRD_dx i.bronchiec8_total_dx i.scoliosis8_total_dx)) diaphragm_total_dx ///
	(logit) ICS8_dx /// 
	(pmm, knn(10)) bmi8 ///
	(pmm, knn(10)) BMI_age7 ///
	= i.asthma8_total_dx i.drv_lrti_tertile i.bronchiec8_total_dx ///
	  i.sex i.drv_ethnic_bin i.geo_lc_5209 i.matpatsmok i.scoliosis8_total_dx i.neurodis8_total_dx i.preterm ///
	, add(100) burnin(25) rseed(1234) dots 

save "$Datadir/Imputed_data_lrti.dta", replace 


********************************************************************************
* 2.4 - TB
********************************************************************************
* NOTE not run due to low counts of the outcome


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
	prfev1pred_bin /// outcome variable 
	NRD_dx /// exposure variables - removed tb and diaphragm_total_dx due to very small number of cases and ICS8_dx as always missing when NRD_dx missing
	

mi impute chained ///
	(logit) prfev1pred_bin /// 
	(logit) NRD_dx ///
	= i.asthma8_total_dx i.drv_lrti_tertile i.bronchiec8_total_dx ///
	  i.sex i.drv_ethnic_bin i.geo_lc_5209 i.preterm i.lowbw ///
	, add(100) burnin(25) rseed(1234) dots 

save "$Datadir/Imputed_data_NRD.dta", replace 

********************************************************************************
* 2.6 - Diaphragmatic hernia
********************************************************************************
	* Load derived data
use "$Datadir/Derived_data_PMD.dta", clear
	* apply eligibility criteria 
keep if eligible == 1

	* apply restriction to observed values for IMD, ethnicity
drop if drv_ethnic_bin == . | geo_lc_5209 == . | pre_smk123 == .

	* set up stata for imputation
mi set flong 

mi register regular /// complete variables
	asthma8_total_dx drv_lrti_tertile /// exposure variables removed bronchiec8_total_dx due to perfect prediction for diaphragm_total_dx
	sex drv_ethnic_bin geo_lc_5209 pre_smk123  // confounder variables
	
mi register imputed /// incomplete vars
	prfev1pred_bin /// outcome variable 
	diaphragm_total_dx /// exposure variables - removed tb, NRD_dx and ICS8_dx as always missing when diaphragm_total_dx missing
	

mi impute chained ///
	(logit) prfev1pred_bin /// 
	(logit) diaphragm_total_dx ///
	= i.asthma8_total_dx i.drv_lrti_tertile  ///
	  i.sex i.drv_ethnic_bin i.geo_lc_5209 i.pre_smk123 ///
	, add(100) burnin(25) rseed(1234) dots 

save "$Datadir/Imputed_data_diaphragm.dta", replace 


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
	prfev1pred_bin /// outcome variable 
	diaphragm_total_dx ICS8_dx /// removed tb and NRD_dx as always missing when ICS8_dx missing

mi impute chained ///
	(logit) prfev1pred_bin /// 
	(logit) diaphragm_total_dx ///
	(logit) ICS8_dx /// 
	= i.asthma8_total_dx i.drv_lrti_tertile ///
	  i.sex i.drv_ethnic_bin i.geo_lc_5209 ///
	, add(100) burnin(25) rseed(1234) dots 

save "$Datadir/Imputed_data_ICSuse.dta", replace 


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
	prfev1pred_bin /// outcome variable 
	ICS8_dx // auxiliaries - removed others due to low counts 

mi impute chained ///
	(logit) prfev1pred_bin /// 
	(logit) ICS8_dx ///
	= i.preterm i.asthma8_total_dx i.drv_lrti_tertile ///
	  i.sex i.drv_ethnic_bin i.geo_lc_5209 i.pre_smk123 ///
	, add(100) burnin(25) rseed(1234) dots 

save "$Datadir/Imputed_data_preterm.dta", replace 
	
********************************************************************************
* 3 - Run regression analyses and output results
********************************************************************************

capture postutil close 
tempname memhold 

postfile `memhold' _expord _modelord str20 outcome ///
	str20 exposure exposure_level str50 model ///
	modeln modeln_with_exposure modeln_with_outcome modeln_with_expandout ///
	OR ORlci ORuci str30 ORCI_str or_pvalue ///
	RD RDlci RDuci str30 RDCI_str rd_pvalue ///
	str200 confounders str200 auxiliaries str200 restricted_complete /// 
	nimps niter /// 
	using "$Outdir\Regression_output.dta", replace

* set output count initial parameters	
local i = 0 // counter for exposure variables

foreach exposure in $expvars { 
	
	* define confounder variables for each exposure variable 
	if "`exposure'" == "asthma8_total_dx"{ 		
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 i.pre_smk123 i.matpatsmok pm10_tot_avg_t3 pm10_tot_avg_y8 prenat_NO2 infant_NO2 bmi8
		local impdataset "$Datadir/Imputed_data_asthma.dta"
		local restriction "drv_ethnic_bin == . | geo_lc_5209 == . | pre_smk123 == . | matpatsmok == ."
		local auxvars drv_lrti_tertile NRD_dx diaphragm_total_dx ICS8_dx BMI_age7 
	}
	else if "`exposure'" == "bronchiec8_total_dx" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 /*tb_dx*/ // removed tb due to perfect prediction 
		local impdataset "EMPTY"	// not run due to low counts of outcome	
		local restriction "EMPTY"
		local auxvars
	}
	else if "`exposure'" == "drv_lrti_tertile" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 i.scoliosis8_total_dx i.neurodis8_total_dx i.preterm bmi8 i.matpatsmok i.bronchiec8_total_dx
		local impdataset "$Datadir/Imputed_data_lrti.dta" 
		local restriction "drv_ethnic_bin == . | geo_lc_5209 == . | matpatsmok == ."
		local auxvars asthma8_total_dx bronchiec8_total_dx NRD_dx diaphragm_total_dx ICS8_dx  BMI_age7

	}
	else if "`exposure'" == "tb_dx" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 
		local impdataset "EMPTY"	// not run due to low counts of outcome	
		local restriction "EMPTY"
		local auxvars
	}
	else if "`exposure'" == "NRD_dx" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 i.preterm i.lowbw
		local impdataset "$Datadir/Imputed_data_NRD.dta" 
		local restriction "drv_ethnic_bin == . | geo_lc_5209 == ."
		local auxvars asthma8_total_dx drv_lrti_tertile bronchiec8_total_dx 
	}
	else if "`exposure'" == "diaphragm_total_dx" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 i.pre_smk123
		local impdataset "$Datadir/Imputed_data_diaphragm.dta" 
		local restriction "drv_ethnic_bin == . | geo_lc_5209 == . | pre_smk123 == ."
		local auxvars asthma8_total_dx drv_lrti_tertile
	}	
	else if "`exposure'" == "ICS8_dx" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 i.asthma8_total_dx 
		local impdataset "$Datadir/Imputed_data_ICSuse.dta" 
		local restriction "drv_ethnic_bin == . | geo_lc_5209 == . "
		local auxvars asthma8_total_dx drv_lrti_tertile diaphragm_total_dx
	}	
	else if "`exposure'" == "preterm" { 
		local confounders i.sex i.drv_ethnic_bin i.geo_lc_5209 i.pre_smk123
		local impdataset "$Datadir/Imputed_data_preterm.dta" 
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
	logistic $outvar ib0.`exposure' // logistic regression model
		matrix unadj_or = r(table)
		estimates store unadj
	margins, dydx(`exposure') // creates estimates of risk difference
		matrix unadj_marg_rd = r(table)
	
	disp "test4"

	
	forvalues explev = 2(1)`num_levels'{ // for loop required as not all exposures are binary
		estimates restore unadj 
		local modn = e(N) // model n
		count if e(sample) & $outvar == 1 // number with outcome
		local modn_wout = r(N) 
		count if e(sample) & `exposure' == `explev'-1 // number with exposure (note explev will be 1 higher than the level of the exposure in the data)
		local modn_wexp = r(N)
		count if e(sample) & `exposure' == `explev'-1 & $outvar == 1 // number with exposure and outcome
		local modn_wexp_wout = r(N)
	
		local or    =  unadj_or[1,`explev']  
		local orlci =  unadj_or[5,`explev']
		local oruci =  unadj_or[6,`explev']
		local orpval = unadj_or[4,`explev']
		local orci_str = strofreal(`or', "%5.2f") + " (" + strofreal(`orlci',"%5.2f") + ", " + strofreal(`oruci',"%5.2f") + ")"
		
		local rd     = unadj_marg_rd[1,`explev']  
		local rdlci  = unadj_marg_rd[5,`explev']
		local rduci  = unadj_marg_rd[6,`explev']
		local rdpval = unadj_marg_rd[4,`explev']		
		local rdci_str = strofreal(100*`rd', "%5.2f") + "% (" + strofreal(100*`rdlci',"%5.2f") + ", " + strofreal(100*`rduci',"%5.2f") + ")"	
		
		post `memhold' (`i') (`j') ("$outvar") ///
			("`exposure'") (`explev'-1) ///
			("Unadjusted logistic regression") ///
			(`modn') (`modn_wexp') (`modn_wout') (`modn_wexp_wout') ///
			(`or') (`orlci') (`oruci') ("`orci_str'") (`orpval') ///
			(`rd') (`rdlci') (`rduci') ("`rdci_str'") (`rdpval') ///
			("Unadjusted model - no confounders used") ("Not imputed model - no auxiliaries used") ("Restriction to complete records") /// 
			(.) (.)  
	}
	
	disp "test5"
	
	
	* adjusted complete records analysis 
	local j = `j' + 1 // model counter
	logistic $outvar ib0.`exposure' `confounders' // logistic regression model
		matrix adj_or = r(table)
		estimates store adj
	margins, dydx(`exposure') // creates estimates of risk difference
		matrix adj_marg_rd = r(table)

	disp "test6"
		
		
	forvalues explev = 2(1)`num_levels'{ // for loop required as not all exposures are binary
		estimates restore adj
		local modn = e(N) // model n
		count if e(sample) & $outvar == 1 // number with outcome
		local modn_wout = r(N) 
		count if e(sample) & `exposure' == `explev'-1 // number with exposure
		local modn_wexp = r(N)
		count if e(sample) & `exposure' == `explev'-1 & $outvar == 1 // number with exposure and outcome
		local modn_wexp_wout = r(N)
	
		local or    =  adj_or[1,`explev']  
		local orlci =  adj_or[5,`explev']
		local oruci =  adj_or[6,`explev']
		local orpval = adj_or[4,`explev']
		local orci_str = strofreal(`or', "%5.2f") + " (" + strofreal(`orlci',"%5.2f") + ", " + strofreal(`oruci',"%5.2f") + ")"
		
		local rd     = adj_marg_rd[1,`explev']  
		local rdlci  = adj_marg_rd[5,`explev']
		local rduci  = adj_marg_rd[6,`explev']
		local rdpval = adj_marg_rd[4,`explev']		
		local rdci_str = strofreal(100*`rd', "%5.2f") + "% (" + strofreal(100*`rdlci',"%5.2f") + ", " + strofreal(100*`rduci',"%5.2f") + ")"	
		
		post `memhold' (`i') (`j') ("$outvar") ///
			("`exposure'") (`explev'-1) ///
			("Adjusted logistic regression") ///
			(`modn') (`modn_wexp') (`modn_wout') (`modn_wexp_wout') ///
			(`or') (`orlci') (`oruci') ("`orci_str'") (`orpval') ///
			(`rd') (`rdlci') (`rduci') ("`rdci_str'") (`rdpval') ///
			("`confounders'") ("Not imputed model - no auxiliaries used") ("Restriction to complete records") /// 
			(.) (.)  
	}
	
	disp "test7"
	
	* adjusted multiple imputation analysis 
		* break if no information available to do MI with 
	local j = `j' + 1 // model counter
	if `modn_wout' <= 1 | `modn_wexp' <= 1 | `modn_wexp_wout' <= 1 {

		post `memhold' (`i') (`j') ("$outvar") ///
			("`exposure'") (.) ///
			("Multiple imputation adjusted logistic regression") ///
			(.) (.) (.) (.) ///
			(.) (.) (.) ("MI not run - counts too low") (.) ///
			(.) (.) (.) ("MI not run - counts too low") (.) ///
			("") ("") ("") /// 
			(.) (.)  
			
		continue	
	} 
	else {

		* load imputed dataset
		use "`impdataset'", clear 
				
		mi estimate, eform: logistic $outvar ib0.`exposure' `confounders' // logistic regression model
			matrix mi_adj_or = r(table)
			local nimps = e(M_mi)
			local niter = 25 // cannot obtain this from e(), setting manually
			estimates store mi_adj
			
		disp "Running emargins_rd: "
			disp "Outcome =  $outvar"
			disp "Exposure = `exposure'"
			disp "Confounders = `confounders'"	
		mi estimate, cmdok: emargins_rd $outvar `exposure' `confounders' // creates estimates of risk difference
			matrix mi_adj_marg_rd = r(table)
			
		disp "test8"

		forvalues explev = 2(1)`num_levels'{ // for loop required as not all exposures are binary
			estimates restore mi_adj
			local modn = e(N) // model n
				
			local or    =  mi_adj_or[1,`explev']  
			local orlci =  mi_adj_or[5,`explev']
			local oruci =  mi_adj_or[6,`explev']
			local orpval = mi_adj_or[4,`explev']
			local orci_str = strofreal(`or', "%5.2f") + " (" + strofreal(`orlci',"%5.2f") + ", " + strofreal(`oruci',"%5.2f") + ")"
			
			local rd     = mi_adj_marg_rd[1,`explev']  
			local rdlci  = mi_adj_marg_rd[5,`explev']
			local rduci  = mi_adj_marg_rd[6,`explev']
			local rdpval = mi_adj_marg_rd[4,`explev']		
			local rdci_str = strofreal(100*`rd', "%5.2f") + "% (" + strofreal(100*`rdlci',"%5.2f") + ", " + strofreal(100*`rduci',"%5.2f") + ")"	
			
			post `memhold' (`i') (`j') ("$outvar") ///
				("`exposure'") (`explev'-1) ///
				("Multiple imputation adjusted logistic regression") ///
				(`modn') (.) (.) (.) ///
				(`or') (`orlci') (`oruci') ("`orci_str'") (`orpval') ///
				(`rd') (`rdlci') (`rduci') ("`rdci_str'") (`rdpval') ///
				("`confounders'") ("`auxvars'") ("`restriction'") /// 
				(`nimps') (`niter')  
		}
	} 
}
postclose `memhold'



use "$Outdir\Regression_output.dta", clear



