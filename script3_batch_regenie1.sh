#!/bin/bash
#SBATCH --time=00:02:00
#SBATCH --nodes=1
#SBATCH --partition=short
#SBATCH --job-name=batch

cd /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/
cat script3_template_regenie1.sh | sed "s/DATA/GSA/g;s/PHENO/BMI/g"  > tempL3_GSA_BMI.sh
cat script3_template_regenie1.sh | sed "s/DATA/AFFY/g;s/PHENO/BMI/g"  > tempL3_AFFY_BMI.sh
cat script3_template_regenie1.sh | sed "s/DATA/CS/g;s/PHENO/BMI/g"  > tempL3_CS_BMI.sh

sbatch tempL3_GSA_BMI.sh
sbatch tempL3_AFFY_BMI.sh
sbatch tempL3_CS_BMI.sh
