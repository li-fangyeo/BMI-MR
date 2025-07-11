#R script
library(readr)
finngen_R12_BMI_IRN <- read_delim("C:/Users/lifyeo/GWAS/finngen_R12_BMI_IRN.gz", 
                                    delim = "\t", escape_double = FALSE, 
                                    trim_ws = TRUE)

finngen_R12_BMI_IRN <- finngen_R12_BMI_IRN %>% 
  rename(chrom = "#chrom") %>%
  mutate(ID = paste0("chr", chrom, "_", pos, "_", ref, "_", alt)) %>%
  select(chrom, ID, everything())


write.table(finngen_R12_BMI_IRN, file = gzfile("finngen_BMI.gz"), row.names = FALSE, quote = FALSE, sep = "\t")


#!/bin/bash
###harmonising data in UNIX

#generate a list of taxa that has more than 1 clump
#removing taxa with less than 1 clump
# Loop through each .txt file
for file in *.txt; do
# Check if there is more than one row in the file
	if [ $(grep -c '^' "$file") -gt 2 ]; then
	echo "$file" >> taxa_postclump2.txt
	fi
done

#rename file.txt for neater list
sed -i 's/\.clumps\.txt$//' taxa_postclump2.txt

#take only taxa with more than 1 SNP post clumping and extract column for MR

mkdir -p /home/lifangyeo/lifyeo/GWAS/MR/harmonised2
