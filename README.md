# Microbiome and obesity
Cross sectional, association analysis between obesity indicators (BMI, waist circumferenec, and waist-hip ratio) and gut microbiome in FINRISK 2002.

Part 1: Using eastern finland as discovery cohort, validating significant taxa in western finland.

Part 2: Using two-sample Mendelian randomization to find causal taxa for obesity indicators

Codes: eastwest.Rmd, beta.Rmd, functional.Rmd (main analysis, the rest are to generate figures or sanity checks)

## Getting started
Cohort: FINRISK 2002 cohort were split into east (discovery) and west (validation) cohorts. 

Exposure variable: gut microbiota abundances

Outcome variable: Obesity indicators (namely BMI, waist cm, WHR)

Covariate: diabetes, cardiovascular disease, smoking, alcohol consumption per week, healthy food choices, exercise

Exclusion criteria: antibiotics use 1 month prior to stool collection, pregnant, metagenomic reads < 50,000

### Discovery cohort
Eastern finland cohort, n = 3906

Alpha diversity using shannon index (measures evenness) and observed species (measures richness), with rarefaction of 10 iterations (niter = 10). Obesity indicators and alpha metric were scaled so that the BMI, WC and WHR are comparable.

Differential abundance analysis was done using linear models, corrected for covariates. Taxa were filtered to be at the species level, at detection level of 0.1% and prevalence of 5%, and centre-log transformed.

Significance level was at FDR corrected p-value < 0.05.

### Validation cohort
Western finland cohort, n = 1940

Microbiota data was filtered to only keep significant taxa found in the discovery cohort. And the same linear models, corrected for covariates, were used to validate association signals. 

No. of significant taxa after FDR correction:
| Indicator | Discovery | Validation |
| --------- | --------- | ---------- |
| BMI       | 164       | 132        |
| Waist cm  | 159       | 120        |
| WHR       | 149       | 105        |


# Mendelian randomization between gut microbiome and BMI
Exposure dataset = FINRISK 2002 GWAS between genotype and microbial taxa (https://gitlab.com/turku-hypertension-center/bmi.git)

Outcome dataset = FINNGEN_R12_BMI_IRN summary statistic (downloaded from https://r12.finngen.fi/pheno/BMI_IRN)

Two-sample MR is used to estimate the causal effect (effect size) of exposure (microbiome) on outcome (BMI) using two summary-level statistics (i) SNP-exposure (microbiome) associateion, (ii) SNP-outcome (BMI) association. This method is advantageous because one, weak instrument bias (prevalent in one-sample MR, IV [instrument variable, genotype data] is weakly associated with exposure [microbiome]) is assumed to be null, and, two, minimise the risk of overfitting (model fits the data too well, or perhaps it only fits the data, that it performs poorly with new data).

Microbial taxa is a list of bacteria species that were found significantly associated with outcome (obesity indicators) in linear models, adjusted for covariates, and further validated in western finland cohort. This list of bacteria were further filtered for taxa with a prevalence of 25%, 10 reads detection level and centre log ratio (clr) transformed to exclude taxa that albeit significant, but had low prevalence rate. This prevalence filtering was chosen to match the prefiltering for GWAS in Qin, Y., Havulinna, A.S., Liu, Y. et al. Combined effects of host genetics and diet on human gut microbiota and incident disease in a single population cohort. Nat Genet 54, 134–142 (2022). https://doi.org/10.1038/s41588-021-00991-z.
***
## Description
Steps to run after differential abundance analysis and obtaining significant taxa associated with the gut microbiome (FINRISK 2002).

### Post imputation QC step of genotype data
Post imputation genotype data were in bfile format (.bed, .bim, .fam).
Step 1 (step1.sh) is a pre-processing step of post-imputed genotype data using plink2. Genotype data are filtered by (--geno 0.1, --hwe 1e-6, --maf 0.01). After QC, the SNPs from each chromosome are merged. This forms the "filtered" genotype dataset used for GWAS. The number of SNP variants in this dataset is 7,833,213. 

Using the "filtered" genotype dataset, LD was removed using --indep-pairwise 500 0.2 and SNP positions with known LD (LongRangeLDRegions.txt - this can be found in code(list in gitlab, along with the other lists I used for the loops to work). After the pruned SNPs are extracted, SNPs from each chromosome are merged into one file. PCA is calculated using this datase on a total of 145,914 SNP variants. PCs are used as covariates in GWAS to correct for population structure.

### Genome-wide association analysis
Step 2 (step2.sh) uses regenie to run GWAS, looking for associations between SNPs and microbial abudances. Microbial taxa abundance count table was filtered for taxa prevalence of 25%, detection level of at least 10 reads and clr-transformed. The input file for regenie-step1 to generate prediction models is the genotype data after LD-pruning (the set of SNPs used to generate PCA, no. of SNPs = 145,914). These predction models will help to speed up the GWAS of regenie-step2. The input file for regenie-step2 is the "filtered" genotype data (the set of SNPs that only went through QC filtering, ie --geno, --hwe, --maf, no of SNPs = 7,833,213). 

After that, you will have your GWAS results, or summary statistics. Good job! With that I used step3.0_addingP.sh (you will also need step3.1_p.R file to make the script run) to change log10P values into P values. There is also a code in there to flip the allele from A1 to A0 in order to match the outcome dataset (FINNGEN summary statistics. Microbiome dataset is exposure dataset). This step is using a bash script to run an R command.

### Clumping
Next, I kept SNPs that were significantly associated with microbial taxa at p-value < 5e-6 (step4.clump.sh). Then, I did LD-based clumping which is to find SNPs that are independently associated, at r2 < 0.001. SNPs are sorted by most significant p-value and any SNPs correlated to the significant SNP were removed, hence retaining independently associated SNPs. By skipping this step, you risk overinflatting your final results were significance may be coming from linkage disequilibrium, instead of the actual SNP of interest. Then I further filtered to only keep clumps with p-value < 1e-6 (step5.lonely_clump.sh). 

### Harmonising data between exposure and outcome dataset
I downloaded summary statistics from FINNGEN_R12 inverse-rank normalized BMI. I added a new column called ID which has chr_genepos_ref_alt to match the regenie output, using dplyr::mutate in R. They need to match for MR analysis (Use the first half of step6.0_harmonise.sh in R to get the ID columns, then use the bottom half in Unix to generate a list of taxa where there are at least 2 SNP variants per taxa, called taxa_postclump.txt). I had to filter for taxa with > 1 SNP variants because IVW method in MR requires so. Then I harmonised the data, that is making sure the ref allele and alt allele of both exposure and outcome summary statistics match, and have them in one dataframe per taxa (using step6.1_MR2_harmonise.R). This is a loop that takes in a list of taxa (taxa_postclump.txt), adds the .regenie.gz to the end(because that's how my summary statistic files are named, bacteria.regenie.gz) and pull the columns I need from both exposure and outcome summary statistics, namely beta, se and alternate allele frequency(af_alt should be < 0.5).

### Mendelian randomization
Congratulations on reaching this step. This is the easiest step of all. Just take the harmonised data and put it in as a MR object and run using the methods of your choice. I ran each taxa manually because I was lazy to write a script. I used simple median, weighted median, IVW, and Lasso.

