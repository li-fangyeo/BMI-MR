#!/bin/bash
#Step 2 - regenie

mkdir -p results/

while read list; do
echo $list

regenie \
	--step 1 \
	--bed /home/lifangyeo/lifyeo/GWAS/scratch/clean/prune/allchr_LDpruned \
	--phenoFile=/home/lifangyeo/lifyeo/bmi/bacteria_table_whr.tsv \
	--phenoCol=$list \
	--covarFile=/home/lifangyeo/lifyeo/bmi/pheno_pca.tsv \
	--covarColList=PC{1:10},BL_AGE,MEN \
	--out ./results/$list \
	--bsize 1000 \
	--apply-rint \
	--qt
	

regenie \
  --step 2 \
  --bed /home/lifangyeo/lifyeo/GWAS/scratch/allchr \
  --phenoFile /home/lifangyeo/lifyeo/bmi/bacteria_table_whr.tsv  \
  --phenoCol=$list  \
  --covarFile /home/lifangyeo/lifyeo/bmi/pheno_pca.tsv \
  --covarColList=PC{1:10},BL_AGE,MEN \
  --qt \
  --approx \
  --apply-rint \
  --pThresh 0.05 \
  --pred ./results/${list}_pred.list \
  --bsize 400 \
  --gz \
  --out ./results/out_$list
  
done < /home/lifangyeo/lifyeo/bmi/bacteria_list.csv 
