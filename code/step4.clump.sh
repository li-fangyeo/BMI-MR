#!/bin/bash
#use plink2 to clump for independent associated SNPs
mkdir -p /home/lifangyeo/lifyeo/gwas-whr/results/modified/clumped2

while read list; do
	echo $list
	
	plink2 \
	--bfile /home/lifangyeo/lifyeo/GWAS/scratch/allchr \
	--clump /home/lifangyeo/lifyeo/gwas-whr/results/modified/${list}.regenie.gz  \
	--clump-id-field ID \
	--clump-p-field P \
	--clump-p1 5e-6 \
	--clump-kb 10000 \
	--clump-r2 0.001 \
	--out /home/lifangyeo/lifyeo/gwas-whr/results/modified/clumped2/${list} 
	

done < /home/lifangyeo/lifyeo/bmi/bacteria_list.csv

