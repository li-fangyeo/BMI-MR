#!/bin/bash
#NOTE: running the code individually works, but not in script, unfortunately.
mkdir -p /home/lifangyeo/lifyeo/gwas-whr/MR/

mkdir -p /home/lifangyeo/lifyeo/gwas-whr/results/modified/clumped2/clumps/lonely_clump/

cd /home/lifangyeo/lifyeo/gwas-whr/results/modified/clumped2/clumps/

# Loop through all files ending with 'clumps' in the current directory
for file in *clumps; do
  # Use AWK to filter column 4 P value < 1e-6, and print the required columns and filename, then rename
  awk -v IFS='\t' -v OFS='\t' '$4 < 1E-6 {print $3, $4, FILENAME}' "$file" | sed 's/\.clumps//' >> ./clumps/lonely_clump/$file.txt; done

mv  ./lonely_clump/ /home/lifangyeo/lifyeo/gwas-whr/MR/

