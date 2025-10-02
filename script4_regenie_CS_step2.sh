#!/bin/bash
#SBATCH --job-name=CSstep2
#SBATCH --nodes=1
#SBATCH -n 1
#SBATCH --mem=10G
#SBATCH --tmp=30GB
#SBATCH --cpus-per-task=4
#SBATCH --output=log4_regenie_CS_step2.txt
#SBATCH --error=log4_regenie_CS_step2.err
#SBATCH -t 5:00:00

cd /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/
module load regenie
# Note: for binary phenotypes, add argument --bt to below command. Binary uses 0/1 coding (with NA for missing)
# Note: the sample file in v5 folder is NOT useable (Regenie expects the 4th column to be gender; and gives an error over the high values)
# Use script0_regenie_CS_samplefile.R to generate the below sample file

for CHR in `seq 21 22` 
do
	BGEN_FILE=/groups/umcg-lifelines/rsc02/releases/cytosnp_imputed/v5/imputed_bgen/${CHR}.pbwt_reference_impute_qctools.bgen
	SAMPLE_FILE=CytoSNP_BGEN_sample.txt

	regenie \
	  --step 2 \
	  --bgen $BGEN_FILE \
	  --sample $SAMPLE_FILE \
	  --phenoFile dataF_CS.txt \
	  --phenoCol BMI \
	  --covarFile dataF_CS.txt \
	  --covarColList age,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
	  --catCovarList sex,CURSMK \
	  --pred CS-regenie1/BMI_pred.list \
	  --bsize 400 \
	  --minINFO 0.3 \
	  --minMAC 2 \
	  --threads 4 \
	  --maxCatLevels 99 \
	  --write-samples \
	  --print-pheno \
	  --gz \
	  --out CS-regenie2/CS-BMI-chr${CHR}
done
