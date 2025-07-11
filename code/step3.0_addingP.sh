#!/bin/bash
###adding P from logP

mkdir -p /home/lifangyeo/lifyeo/gwas-whr/results/modified

while read list; do
	echo $list

	Rscript /home/lifangyeo/lifyeo/GWAS/code/step3.1_p.R \
	--input /home/lifangyeo/lifyeo/gwas-whr/results/out_${list}_${list}.regenie.gz \
	--output /home/lifangyeo/lifyeo/gwas-whr/results/modified/${list}.regenie.gz 
	
done < /home/lifangyeo/lifyeo/bmi/bacteria_list.csv 
