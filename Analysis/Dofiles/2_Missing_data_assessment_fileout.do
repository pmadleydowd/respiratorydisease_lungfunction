********************************************************************************
* Author: 		Paul Madley-Dowd 
* Date: 		14 Feb 2025
* Description: 	Explore the missing data mechanisms
********************************************************************************
* Contents
********************************************************************************
* 1 - Create environment and load data
* 2 - Explore missing data patterns in analysis model variables
* 3 - Explore missing data patterns in auxiliary variables


********************************************************************************
* 1 -  Create environment and load data
********************************************************************************
use "$Datadir/Derived_data_PMD.dta", clear

* apply eligibility criteria 
keep if eligible == 1

* outcome variable
global outvar prfev1pred_bin

* exposure variables 
global expvars asthma8_total_dx bronchiec8_total_dx drv_lrti_tertile tb_dx  NRD_dx diaphragm_total_dx ICS8_dx 
 
* confounder variables (separated into <age 9 and neonatal)
global confvars_gen sex drv_ethnic_bin geo_lc_5209


* analysis model variables 
	* asthma
global asthma_vars $outvar asthma8_total_dx $confvars_gen pre_smk123 matpatsmok pm10_tot_avg_t3 pm10_tot_avg_y8 prenat_NO2 infant_NO2 bmi8
	* bronchiectasis
global brochiectasis_vars $outvar bronchiec8_total_dx $confvars_gen tb_dx
	* lrti 
global lrti_vars $outvar drv_lrti_tertile $confvars_gen scoliosis8_total_dx neurodis8_total_dx preterm bmi8 matpatsmok bronchiec8_total_dx
	* nrd
global nrd_vars $outvar NRD_dx $confvars_gen preterm lowbw
	* diaphragmatic hernia 
global diaprhragm_vars $outvar diaphragm_total_dx $confvars_gen pre_smk123
	* ICS use 
global ICS_vars $outvar ICS8_dx $confvars_gen asthma8_total_dx
	* preterm 
global preterm_vars $outvar preterm $confvars_gen pre_smk123

********************************************************************************
* 2 - Explore missing data patterns in analysis model variables
********************************************************************************
* missing data counts for each variable
/*misstable summarize $outvar 
misstable summarize $expvars
misstable summarize $confvars_gen

* patterns of missing data by variable type
misstable patterns $expvars
misstable patterns $confvars_gen

* patterns of missing data for analysis model 
	* Asthma 
misstable summarize $outvar asthma8_total_dx $confvars_gen pre_smk123 matpatsmok pm10_tot_avg_t3 pm10_tot_avg_y8 prenat_NO2 infant_NO2 bmi8
misstable patterns  $outvar asthma8_total_dx $confvars_gen pre_smk123 matpatsmok pm10_tot_avg_t3 pm10_tot_avg_y8 prenat_NO2 infant_NO2 bmi8
*/


* asthma 
misstable summarize $asthma_vars

preserve 
	count
	drop if drv_ethnic_fct == . | geo_lc_5209 == . | pre_smk123 == . | matpatsmok == .
	count
	misstable summarize $asthma_vars
	misstable patterns $asthma_vars
	
	misstable summarize $expvars
	misstable patterns $expvars
	
	misstable patterns bmi8 BMI_age7
	
	egen miss_asthma = rowmiss($asthma_vars)
	gen cca_asthma = miss_asthma == 0
	tab cca_asthma
	
	logistic cca_asthma asthma8_total_dx $confvars_gen pre_smk123 matpatsmok pm10_tot_avg_t3 pm10_tot_avg_y8 prenat_NO2 infant_NO2 bmi8
	
restore


* LRTIs 
misstable summarize $lrti_vars

preserve 
	count
	drop if drv_ethnic_fct == . | geo_lc_5209 == . | matpatsmok == .
	count
	misstable summarize $lrti_vars
	misstable patterns $lrti_vars
	
	misstable summarize $expvars
	misstable patterns $expvars
	
	misstable patterns bmi8 BMI_age7
	
	egen miss_lrti = rowmiss($lrti_vars)
	gen cca_lrti = miss_lrti == 0
	tab cca_lrti
	
	logistic cca_lrti drv_lrti_tertile $confvars_gen scoliosis8_total_dx neurodis8_total_dx preterm bmi8 matpatsmok bronchiec8_total_dx
	
restore


* NRD
misstable summarize $nrd_vars

preserve 
	count
	drop if drv_ethnic_fct == . | geo_lc_5209 == . 
	count
	misstable summarize $nrd_vars
	misstable patterns $nrd_vars
	
	misstable summarize $expvars
	misstable patterns $expvars
	
	egen miss_nrd = rowmiss($nrd_vars)
	gen cca_nrd = miss_nrd == 0
	tab cca_nrd
	
	logistic cca_nrd NRD_dx $confvars_gen preterm lowbw
	
restore

* diaphragmatic hernia
misstable summarize $diaprhragm_vars

preserve 
	count
	drop if drv_ethnic_fct == . | geo_lc_5209 == .  | pre_smk123 == .
	count
	misstable summarize $diaprhragm_vars
	misstable patterns $diaprhragm_vars
	
	misstable summarize $expvars
	misstable patterns $expvars
	misstable patterns tb_dx  NRD_dx diaphragm_total_dx ICS8_dx
	
	egen miss_diaphragm = rowmiss($diaprhragm_vars)
	gen cca_diaphragm = miss_diaphragm == 0
	tab cca_diaphragm
	
	logistic cca_diaphragm diaphragm_total_dx $confvars_gen i.pre_smk123
	
restore

* ICS use
misstable summarize $ICS_vars

preserve 
	count
	drop if drv_ethnic_fct == . | geo_lc_5209 == .  
	count
	misstable summarize $ICS_vars
	misstable patterns $ICS_vars
	
	misstable summarize $expvars
	misstable patterns $expvars
	misstable patterns tb_dx  NRD_dx diaphragm_total_dx ICS8_dx
	
	egen miss_ICS = rowmiss($ICS_vars)
	gen cca_ICS = miss_ICS == 0
	tab cca_ICS
	
	logistic cca_ICS ICS8_dx $confvars_gen i.asthma8_total_dx	
	
restore

* preterm
misstable summarize $preterm_vars

preserve 
	count
	drop if drv_ethnic_fct == . | geo_lc_5209 == .  | pre_smk123 == .
	count
	misstable summarize $preterm_vars
	misstable patterns $preterm_vars
	
	misstable summarize $expvars
	misstable patterns $expvars
	misstable patterns tb_dx  NRD_dx diaphragm_total_dx ICS8_dx
	
	egen miss_preterm = rowmiss($preterm_vars)
	gen cca_preterm = miss_preterm == 0
	tab cca_preterm
	
	logistic cca_preterm preter $confvars_gen i.pre_smk123
	
restore

********************************************************************************
* 3 - Explore missing data patterns for analysis model variables and specific auxiliary variables
********************************************************************************
* BMI - age 8 used, age 7 auxiliary 
misstable summarize bmi8 BMI_age7
misstable patterns bmi8 BMI_age7


********************************************************************************
* 4 - Explore imputation models 
********************************************************************************
regress bmi8 geo_lc_5209 $outvar $expvars_age9 $expvars_age9 pre_smk123 matpatsmok preterm  lowbw pm10_tot_avg_t3 pm10_tot_avg_y8 prenat_NO2 infant_NO2 mould2 scoliosis8_total_dx neurodis8_total_dx congcardiac_total_dx kz030

