********************************************************************************
* Author: 		Paul Madley-Dowd 
* Date: 		14 Feb 2025
* Description: 	Explore the data
********************************************************************************
* Contents
********************************************************************************
* 1 - Create environment and load data
* 2 - Create table of descriptive statistics for exposure variables 


********************************************************************************
* 1 -  Create environment and load data
********************************************************************************
use "$Datadir/Derived_data_PMD.dta", clear

* apply eligibility criteria 
keep if eligible == 1

* outcome variable
global outvar prfev1pred_bin

* exposure variables (separated into <age 9 and neonatal)
global expvars_age9 asthma8_total_dx bronchiec8_total_dx drv_lrti_tertile ICS8_dx hosp_admit_dx tb_dx icu_dx 
global expvars_neonat NRD_dx diaphragm_total_dx nicu_dx
 
* confounder variables (separated into <age 9 and neonatal)
global confvars_age9 pre_smk123 matpatsmok preterm  lowbw bmi8 pm10_tot_avg_t3 pm10_tot_avg_y8 prenat_NO2 infant_NO2 mould2 scoliosis8_total_dx neurodis8_total_dx congcardiac_total_dx 
global confvars_neonat pre_smk123 preterm lowbw pm10_tot_avg_t3 prenat_NO2 mould2 scoliosis8_total_dx neurodis8_total_dx congcardiac_total_dx 

* auxiliary variables 
global auxvars geo_lc_5209 cig100_15 cig100_24

********************************************************************************
* 2 - Explore missing data patterns in analysis model variables
********************************************************************************
table1_mc,   ///
			vars( /// 
				asthma8_total_dx cat %5.1f \ ///
				bronchiec8_total_dx cat %5.1f \ ///
				drv_lrti_tertile cat %5.1f \ ///
				ICS8_dx cat %5.1f \ ///
				hosp_admit_dx cat %5.1f \ ///
				tb_dx cat %5.1f \ ///
				icu_dx cat %5.1f \ ///
				NRD_dx cat %5.1f \ ///
				diaphragm_total_dx cat %5.1f \ /// 
				nicu_dx cat %5.1f \ ///
				) ///
			nospace onecol missing test ///
			saving("$Outdir/descriptives_exposurevars.xlsx", replace)


