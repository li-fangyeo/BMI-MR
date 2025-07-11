out <- read_table("C:/Users/lifyeo/GWAS/scratch2/clean/results/BMI_out_rint_BMI.regenie")

class(out)

sigsnps <- out %>% arrange(desc(LOG10P)) %>%
  dplyr::slice_head(n = 10)

write.table(sigsnps, file = 'snps_list.tsv', row.names = FALSE, col.names = FALSE,quote = FALSE )

## qqplot
library(qqman)
library(readr)
library(dplyr)
out <- read_table("C:/Users/lifyeo/GWAS/results/out_Blautia_A_141780_hansenii_Blautia_A_141780_hansenii.regenie.gz")
#as.data.frame(table(out$CHROM))
#out <- out %>% dplyr::rename(CHR = CHROM) 
#Antilog P value
out$P <- 10^(-out$LOG10P)
manhattan(out, chr = "CHROM", bp = "GENPOS", snp = "ID", p = "P", annotatePval = 0.05)
qq(out$P)
#Genomic inflation factor (should be close to 1)
median(qchisq(out$P, df=1, lower.tail=FALSE)) / qchisq(0.5, 1)

## COJO
cojo <- read_table("C:/Users/lifyeo/GWAS/scratch2/clean/cojo/chr2_cojo.output.jma.cojo")
cojo <- read_table("C:/Users/lifyeo/GWAS/scratch2/clean/cojo/chr2_cojo.output.ldr.cojo")

chr2 <- subset(out, CHROM == 2)

snp.list <- chr2 %>% arrange(desc(LOG10P)) %>%
  dplyr::slice_head(n = 10) %>%
  select(ID)

write_delim(snp.list, "snp.list.tsv")

G   <- obj.bigSNP$genotypes
CHR <- obj.bigSNP$map$chromosome
POS <- obj.bigSNP$map$physical.pos

plink_genotype_dt<-  obj.bigSNP$genotypes  ## extract genotype value

plink_genotype_dt <- plink_genotype_dt[]

##SAIGE
#09042025
sai <- read_table("genotype_100markers_marker_bgen_fullGRMforNull_with_vr.txt")
manhattan(out, chr = "CHROM", bp = "GENPOS", snp = "ID", p = "P", annotatePval = 0.05)
qq(sai$p.value)

##15042025
out %>% dplyr::filter(CHROM == 2) %>%
  arrange(P)

#29042025
#import FINNGEN 
library(readr)
finngen_R12_BMI_IRN <- read_delim("C:/Users/lifyeo/GWAS/finngen_R12_BMI_IRN.gz", 
                                    delim = "\t", escape_double = FALSE, 
                                    trim_ws = TRUE)

finngen_R12_BMI_IRN <- finngen_R12_BMI_IRN %>% 
  rename(chrom = "#chrom") %>%
  mutate(ID = paste0("chr", chrom, "_", pos, "_", ref, "_", alt)) %>%
  select(chrom, ID, everything())


write.table(finngen_R12_BMI_IRN, file = gzfile("finngen_BMI.gz"), row.names = FALSE, quote = FALSE, sep = "\t")

#using ready finngen sum stats, slice 100 random rows to use as test
finngen_BMI <- finngen_BMI %>% slice_sample(n=100)
write.table(finngen_BMI, "test.tsv", sep = "\t", quote = FALSE, row.names = FALSE )

