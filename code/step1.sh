#!/bin/bash
#16042025
##Step 1 - PLINK2
mkdir -p scratch

mkdir -p scratch/clean

mkdir -p scratch/clean/prune

while read old new; do
plink2 \
    --bfile /home/lifangyeo/lifyeo/data/genotype/bed/${old} \
    --out /home/lifangyeo/lifyeo/GWAS/scratch/${new} \
    --snps-only \
    --geno 0.1 \
    --hwe 1e-6 \
    --maf 0.01 \
    --make-bed \
                            	
done < /home/lifangyeo/lifyeo/GWAS/code/list/1.0_bfile.list

#Merge filtered set
plink2 --pmerge-list /home/lifangyeo/lifyeo/GWAS/code/list/1.1_list.txt --make-bed --pheno /home/lifangyeo/lifyeo/bmi/bacteria_table.tsv --out allchr

#Step 2 - PLINK2 to remove LD and make PCA
while read list; do		
plink2 \
	-bfile /home/lifangyeo/lifyeo/GWAS/scratch/${list} \
	--out /home/lifangyeo/lifyeo/GWAS/scratch/clean/${list} \
    --indep-pairwise 500 0.2 \
	--make-bed \
    --exclude range /home/lifangyeo/lifyeo/GWAS/code/list/LongRangeLDRegions.txt
                            		        	    
done < /home/lifangyeo/lifyeo/GWAS/code/list/2.0_pca_list.txt

while read list; do
plink2 \
    --bfile /home/lifangyeo/lifyeo/GWAS/scratch/clean/${list}  \
    --extract /home/lifangyeo/lifyeo/GWAS/scratch/clean/${list}.prune.in \
    --out /home/lifangyeo/lifyeo/GWAS/scratch/clean/prune/${list} \
    --make-bed

done < /home/lifangyeo/lifyeo/GWAS/code/list/2.0_pca_list.txt

cd /home/lifangyeo/lifyeo/GWAS/scratch/clean/prune/

plink2 --pmerge-list /home/lifangyeo/lifyeo/GWAS/code/list/1.1_list.txt --make-bed --pheno /home/lifangyeo/lifyeo/bmi/bacteria_table.tsv --out allchr_LDpruned

##Make pca
mkdir /home/lifangyeo/lifyeo/GWAS/scratch/clean/prune/pca

##PCA after pruning
genotypeFile="allchr_LDpruned"
outPrefix="allchr_LDpruned_pca"

plink2 --bfile /home/lifangyeo/lifyeo/GWAS/scratch/clean/prune/${genotypeFile} --out /home/lifangyeo/lifyeo/GWAS/scratch/clean/prune/pca/${outPrefix} --pca approx allele-wts --freq counts --pheno /home/lifangyeo/lifyeo/bmi/bacteria_table.tsv --no-input-missing-phenotype
