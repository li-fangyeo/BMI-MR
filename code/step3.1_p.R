library(readr)
library(dplyr)

options <- list(
  optparse::make_option(c("--input"),
                        default = "C:/Users/lifyeo/gwas-whr/results/out_Blautia_A_141780_hansenii_Blautia_A_141780_hansenii.regenie.gz",
                        help = "File containing GWAS results one line per SNP [default \"%default\"]"),
  optparse::make_option(c("--output"),
                        default = "temp.gz",
                        help = "Output filename [default \"%default\"]"))

args <- optparse::parse_args(optparse::OptionParser(option_list = options))

out <- read_table(args$input)
#
#Antilog P value
out$P <- 10^(-out$LOG10P)

#flip beta and A1 to A0 frequency
out$BETA_flip <- out$BETA * -1

out$A0FREQ <- 1 - out$A1FREQ

write_delim(out, args$output)