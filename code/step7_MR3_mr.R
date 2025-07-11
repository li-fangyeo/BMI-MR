library(readr)
library(MendelianRandomization)
setwd("C:/Users/lifyeo/gwas/MR/harmonised2")
options <- list(
  optparse::make_option(c("--input"),
                        default = "C:/Users/lifyeo/gwas/MR/harmonised2/Eubacterium_I_ramulus_hm.txt",
                        help = "File containing independent SNPs after clumping [default \"%default\"]"))

args <- optparse::parse_args(optparse::OptionParser(option_list = options))


hm <- read.table(args$input, sep = "\t", header = TRUE)


#i flipped the effect_allele from ref to alt_out
MRInputObject <- mr_input(bx = hm$beta_exp,
                          bxse = hm$sebeta_exp,
                          by = hm$beta_out,
                          byse = hm$sebeta_out,
                          exposure = "microbiome",
                          outcome = "BMI",
                          effect_allele = hm$alt_out,
                          other_allele = hm$ref_out,
                          snps = hm$rsids)

#Prints results for main analysis, including Medians, IVW, Egger
mr_allmethods(MRInputObject, method = "ivw", iterations = 10000)

#Mendelian randomization using Lasso method
mr_lasso(MRInputObject, distribution = "normal", alpha = 0.05, lambda = numeric(0))

mr_plot(MRInputObject, interactive = FALSE)




