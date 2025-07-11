library(readr)
library(dplyr)

setwd("C:/Users/lifyeo/gwas/MR")
options <- list(
  optparse::make_option(c("--input"),
                        default = "C:/Users/lifyeo/gwas/MR/lonely_clump/taxa_postclump2.txt",
                        help = "A list of taxa names for clumps with > 2 SNP variants \"%default\"]"),
  optparse::make_option(c("--outcome"),
                        default = "C:/Users/lifyeo/GWAS/älätouch/finngen_BMI",
                        help = "File containing Finngen summary statistics with renamed columns [default \"%default\"]"),
  optparse::make_option(c("--input_dir"),
                        default = "C:/Users/lifyeo/gwas/results/modified",
                        help = "input directory [default \"%default\"]"),
  optparse::make_option(c("--clumps"),
                        default = "C:/Users/lifyeo/gwas/MR/lonely_clump",
                        help = "input directory containing SNP ID of clumps [default \"%default\"]"),
  optparse::make_option(c("--output_dir"),
                        default = "C:/Users/lifyeo/gwas/MR/harmonised2",
                        help = "Output directory [default \"%default\"]"))

args <- optparse::parse_args(optparse::OptionParser(option_list = options))

#Outcome summary statistics
finngen_bmi <- read.table(args$outcome, header = TRUE)

#select wanted columns
outcome_FG <- finngen_bmi %>%
  dplyr::select(ID, ref, alt, rsids, nearest_genes, pval, beta, sebeta, af_alt) %>%
  dplyr::rename(ref_out = ref,
                alt_out = alt,
                pval_out = pval,
                beta_out = beta,
                sebeta_out = sebeta,
                af_alt_out = af_alt)


#My beautiful loop
#a list of taxa that has more than 1 SNP after clumping 
taxa <- readLines(args$input)

for (list in taxa) {
  print(paste("Processing file:", list)) # Debugging: Print the current file being processed
  
  #set file path and append clumps.txt
  exposure_clump <- file.path(args$clumps, paste0(list, ".clumps.txt"))
  print(paste("Processing exposure clump:", exposure_clump)) # Debugging: Print the current exposure file being processed
  
  exposure_file <- file.path(args$input_dir, paste0(list, ".regenie.gz"))
  print(paste("Processing exposure file:", exposure_file))
  
  #Generate the output file name (bacteria_hm.txt)
  output_file <- file.path(args$output_dir, paste0(list, "_hm.txt"))
  print(paste("Processing output file:", output_file))
  
  #Check if the output file already exists (useful for when run stops prematurely)
  if (file.exists(output_file)) {
    print(paste("Output file already exists, skipping:", output_file)) # Debugging: Print the message if file exists
    next # Skip to the next iteration
  }
  
  #Read file bacteria.regenie.gz
  finrisk_bmi <- read.table(gzfile(exposure_file), header = TRUE)
  print(paste("Processing exposure file:", exposure_file))
  
  #Read clumps
  clump <- read.table(exposure_clump, header = FALSE)
  
  #Extract SNPid
  exposure_FR <- finrisk_bmi %>%
    dplyr::right_join(clump, join_by(ID == V1))
  print(paste("Processing exposure_FR:", exposure_clump))
  
  #Extract and rename columns
  exposure_FR <- exposure_FR %>%
    dplyr::select(ID, ALLELE1, ALLELE0, P, BETA_flip, SE, A0FREQ) %>%
    dplyr::rename(ref_exp = ALLELE1,
                  alt_exp = ALLELE0,
                  pval_exp = P,
                  beta_exp = BETA_flip,
                  sebeta_exp = SE,
                  af_alt_exp = A0FREQ)
  
  #join into harmonised dataset
  hm <- outcome_FG %>%
    dplyr::right_join(exposure_FR, join_by(ID == ID))

  print(paste("Writing output to:", output_file)) # Debugging: Print the output file name
  
  #Write the output to a gzipped file
  write.table(hm, file = output_file, row.names = FALSE, sep = "\t", quote = FALSE)
  
}
