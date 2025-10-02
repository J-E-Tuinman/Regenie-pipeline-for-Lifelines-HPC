#!/bin/bash
#SBATCH --time=00:55:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=regular
#SBATCH --mem=64GB
#SBATCH --tmp=30GB
#SBATCH --job-name=AFFYprep
#SBATCH --output=log2_regenie_AFFY_PLINK.txt
#SBATCH --error=log2_regenie_AFFY_PLINK.err

cd /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/
# Preparing genotype file for regenie step1.
# Note for next time: running time is somewhat unpredictable: I've seen both 12 mins and < 5
# using PLINK 1.9 instead of 2, because the --pmerge command is not recognized (I guess our PLINK2 is old?)
module load PLINK/1.9-beta6-20190617
cp mergelist_GSA.txt $TMPDIR

cd /groups/umcg-lifelines/rsc02/releases/affymetrix_genotypes/v2/Data/
cp chr_*.bed $TMPDIR
cp chr_*.bim $TMPDIR
cp chr_*.fam $TMPDIR

cd $TMPDIR
rm chr_X*  # removes chr X & XY


# merge chromosomes
plink --bfile chr_1 --merge-list mergelist_GSA.txt --make-bed --out dataG_AFFY_v1

module purge
# loading PLINK2 because the no-id-header command is not recognized by PLINK 1
module load PLINK/2.0-alpha6.20-20250707

plink2 \
  --bfile dataG_AFFY_v1 \
  --geno 0.1 \
  --hwe 1e-15 \
  --mac 100 \
  --maf 0.01 \
  --mind 0.1 \
  --indep-pairwise 1000 100 0.9 \
  --out dataG_AFFY_v2 \
  --no-id-header \
  --write-samples \
  --write-snplist


mv *.log /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/AFFY-PLINK/
gzip dataG_AFFY_v1.b*
mv dataG_AFFY_* /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/AFFY-PLINK/

#ls > /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/log2_regenie_AFFY_PLINK_LoF.txt
cd /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/
