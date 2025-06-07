#Preparing phenotype data for GWAS
#02042025
library(mia)
library(dplyr)
library(readr)
tse <- readRDS("./data/tse_mgs-20241118_104759.rds") %>%
  tse_mutate(dplyr::across(c(MEN,
                             CURR_SMOKE,
                             EAST,
                             Q57,
                             dplyr::contains("INCIDENT"),
                             dplyr::contains("PREVAL")), as.factor))

pheno <- colData(tse) %>% as.data.frame() %>%
  select("BL_AGE", "MEN", "BMI",  "FID")
dim(pheno)

# Reorder the columns to move the last two to the front
pheno1 <- pheno %>% 
  #tibble::rownames_to_column("SampleID") %>%
  dplyr::rename(IID = FID) %>%
  dplyr::mutate(FID = 0) %>%
  select(FID, IID, everything())


write_delim(pheno1, file = 'pheno.tsv')

#26032025
#Katso tänne!!! I am here!!
#Adding age and sex to covariate PC file
#read PCa file in and merge with pheno.tsv
plink2_pca <- read_table("C:/Users/lifyeo/GWAS/scratch/clean/prune/pca/allchr_LDpruned_pca.eigenvec")

pheno_pca <- pheno1 %>% 
  #dplyr::select("FID","IID","MEN", "BL_AGE") %>%
  dplyr::right_join(plink2_pca, join_by(IID == IID)) %>%
  dplyr::select(-c("#FID")) %>%
  filter(!is.na(BMI))
  
pheno_pca[!complete.cases(pheno_pca), ]

write_delim(pheno_pca, file = 'pheno_pca.tsv')

#preparing all validated (east and west) bacteria associated with BMI
df_lm_whr_results <- df_lm_whr_results %>%
  dplyr::filter(qval_fdr < 0.05)
sig.list <- df_lm_whr_results %>%
  dplyr::mutate(across(everything(),~ gsub("GUT_","",.))) %>%
  as.data.frame()
list <- sig.list$taxa
list
#subset tse by sig list
selected_rows <- rowData(tse)$Species %in% list & 
  !is.na(rowData(tse)$Species)
tse_val <- tse[selected_rows, ]
tse_val <- agglomerateByPrevalence(tse_val,
                                    rank = "Species",
                                    assy.type = "relabundance",
                                    prevalence = 25 / 100,
                                    detection = 10)
tse_val <- mia::transformAssay(tse_val, method = "clr", pseudocount = 1)
bacteria_tab <-tse_val %>% assay("clr") %>%
  t() %>%
  as.data.frame() %>%
  dplyr::rename_with(~ gsub(" ", "_", .)) %>%
  #dplyr::select(starts_with("Bifidobacterium"))
  tibble::rownames_to_column("SampleID")

comma_list <-tse_val %>% assay("clr") %>%
  as.data.frame() %>%
  tibble::rownames_to_column("taxa") %>%
  dplyr::select(taxa) %>%
  dplyr::mutate(across(everything(),~ gsub(" ","_",.)))
  
 
write_csv(comma_list, "bacteria_list.csv", col_names = FALSE)

bac_list <- pheno %>% 
  tibble::rownames_to_column("SampleID") %>%
  dplyr::right_join(bacteria_tab, join_by(SampleID == SampleID)) %>%
  dplyr::rename(IID = FID) %>%
  dplyr::mutate(FID = 0) %>%
  dplyr::select(FID, IID, everything()) %>%
  dplyr::select(-c(SampleID))

write_delim(bac_list, file = 'bacteria_table_whr.tsv')

#####COJO#######
#extra analysis that wasn't inserted into main results

#COJO
#Select chr1
chr1 <- subset(out, CHROM == 1)
chr1  <- chr1 %>% dplyr::select(ID, ALLELE0, ALLELE1, A1FREQ, BETA, SE, P, N)

write_delim(chr1, "chr1.tsv")

#Loop
for (i in 1:22) {
  chr <- subset(out, CHROM == i)
  chr <- chr %>% dplyr::select(ID, ALLELE0, ALLELE1, A1FREQ, BETA, SE, P, N)
  write_delim(chr, paste0("chr", i, ".tsv"))
}

