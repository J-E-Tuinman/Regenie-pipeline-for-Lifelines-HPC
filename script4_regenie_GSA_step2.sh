#!/bin/bash
#SBATCH --job-name=GSAstep2
#SBATCH --nodes=1
#SBATCH -n 1
#SBATCH --mem=10G
#SBATCH --tmp=30GB
#SBATCH --cpus-per-task=4
#SBATCH --output=log4_regenie_GSA_step2.txt
#SBATCH --error=log4_regenie_GSA_step2.err
#SBATCH -t 5:00:00

cd /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/
module load regenie
# Note: for binary phenotypes, add argument --bt to below command. Binary uses 0/1 coding (with NA for missing)

for CHR in `seq 21 22` 
do
	BGEN_FILE=/groups/umcg-lifelines/rsc02/releases/gsa_imputed/v2/BGEN/chr_${CHR}.GSAr2.bgen
	SAMPLE_FILE=/groups/umcg-lifelines/rsc02/releases/gsa_imputed/v2/BGEN/chr_${CHR}.GSAr2.sample

	regenie \
	  --step 2 \
	  --bgen $BGEN_FILE \
	  --sample $SAMPLE_FILE \
	  --phenoFile dataF_GSA.txt \
	  --phenoCol BMI \
	  --covarFile dataF_GSA.txt \
	  --covarColList age,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
	  --catCovarList sex,CURSMK \
	  --pred GSA-regenie1/BMI_pred.list \
	  --bsize 400 \
	  --minINFO 0.3 \
	  --minMAC 2 \
	  --threads 4 \
	  --maxCatLevels 99 \
	  --write-samples \
	  --print-pheno \
	  --gz \
	  --out GSA-regenie2/GSA-BMI-chr${CHR}
done
