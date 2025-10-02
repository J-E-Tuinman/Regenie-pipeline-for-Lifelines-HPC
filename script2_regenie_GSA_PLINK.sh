#!/bin/bash
#SBATCH --time=00:55:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=regular
#SBATCH --mem=64GB
#SBATCH --tmp=30GB
#SBATCH --job-name=GSAprep
#SBATCH --output=log2_regenie_GSA_PLINK.txt
#SBATCH --error=log2_regenie_GSA_PLINK.err

cd /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/
# Preparing genotype file for regenie step1
# Note for next time: running time is somewhat unpredictable: I've seen both 15+ mins and < 5
cp mergelist_GSA.txt $TMPDIR

cd /groups/umcg-lifelines/rsc02/releases/gsa_genotypes/v2/Data/UGLI_QCed_genotypes/
cp chr_*.bed $TMPDIR
cp chr_*.bim $TMPDIR
cp chr_*.fam $TMPDIR

cd $TMPDIR
rm chr_X*  # removes chr X & XY


# merge chromosomes
# using PLINK 1.9 instead of 2, because the --pmerge command is not recognized (I guess our PLINK2 is old?)
module load PLINK/1.9-beta6-20190617
plink --bfile chr_1 --merge-list mergelist_GSA.txt --make-bed --out dataG_GSA_v1

module purge
# loading PLINK2 because the no-id-header command is not recognized by PLINK 1
module load PLINK/2.0-alpha6.20-20250707

plink2 \
  --bfile dataG_GSA_v1 \
  --geno 0.1 \
  --hwe 1e-15 \
  --mac 100 \
  --maf 0.01 \
  --mind 0.1 \
  --indep-pairwise 1000 100 0.9 \
  --out dataG_GSA_v2 \
  --no-id-header \
  --write-samples \
  --write-snplist


mv *.log /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/GSA-PLINK/
gzip dataG_GSA_v1.b*
mv dataG_GSA_* /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/GSA-PLINK/

#ls > /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/log2_regenie_GSA_PLINK_LoF.txt
cd /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/

