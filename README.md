# Regenie-pipeline-for-Lifelines-HPC
Scripts for running regenie GWAS on the Lifelines HPC
Created by Peter van der Most, version October 2025

Because Lifelines is split into 3 separate subcohorts (with overlapping and closely-related samples), running a GWAS can be a convoluted business. This repository contains a series of sample scripts outlining the basis steps you need to take to run a GWAS.

The current version was created in October 2025 for the new Nibbler cluster. It makes use of CytoSNP (CS) release 5; GSA release 2; and Affymetrix (Affy) release 2.

Notes:
1) The phenotype scripts uses the release 1 Affymetrix overlap & PC files; as there are no release 2 files (as of 1/10/2025). The impact of this ought to be limited. Note, however, that the family ID (FID) values did change from 1 to 0 for all samples. Hence you cannot use the FID values from the r1 PC files for a GWAS of r2 Affymetrix.
2) Script 2 (regenie 1) for GSA gives a warning about HWE threshold. Weirdly, it does NOT do so for CS or Affy.
3) Optionally, a sample filter can be added to script 2 in case of small sample sizes (as the MAF filter may malfunction in those cases)

To change:
1) The CS r5 linkage files are now available. Script0 needs to edited to incorporate this.
2) Affymetrix step 2 failed for unclear reasons. Update 17/10/25: the phenotype script did not update the FID correctly. Joël Tuinman discovered and fixed this problem, which hopefully also resolves the Affymetrix step 2 problems.
