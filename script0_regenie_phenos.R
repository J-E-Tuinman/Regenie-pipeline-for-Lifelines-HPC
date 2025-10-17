# Script for creating fake phenotypes for testing REGENIE
# Based on P79e8 Lifelines, written by Peter van der Most, June 2023
# Updated October 2025 for Nibbler cluster & v2 GSA data
# Still need to incorporate Affy v2, but unfortunately the relevant files are not updated yet

# UPDATE: CytoSNP v5 linkage files are now available;
# below code still has to be changed to allow this



# In UNIX
if(F){
  cd /groups/umcg-lifelines/tmp02/projects/ov21_0338/Regenie_test/
    module load R
  R
}

#### Collect smoking data ####
DSMOK <- read.table("/groups/umcg-lifelines/prm03/releases/pheno_lifelines_restructured/v1/smoking/data/values/baselinesmoking_v2.txt",
                    header = T, sep = "\t")[, c("PSEUDOIDEXT", "AGE_1B", "GESLACHT", "currentsmoker")]
colnames(DSMOK)[2:4] <- c("age", "sex", "CURSMK")
DSMOK$age2 <- DSMOK$age^2
gc()


# Merge with smoke
LinkSMK <- read.table("/groups/umcg-lifelines/prm03/releases/pheno_lifelines_restructured/v1/phenotype_linkage_file_project_pseudo_id.txt",
                      header = T, sep = "\t")

DSMOK <- merge(DSMOK, LinkSMK, all.x = T, all.y = F, sort = F)


#### Collect anthropometic data ####
# For some reason, reading in this file takes forever, so I added the colClasses argument!
DANT <- read.csv("/groups/umcg-lifelines/rsc02/releases/pheno_lifelines/v2/results/1a_v_1_results.csv",
                 header = T, stringsAsFactors = F, nrow = 100)
DANT <- read.csv("/groups/umcg-lifelines/rsc02/releases/pheno_lifelines/v2/results/1a_v_1_results.csv",
                 header = T,
                 colClasses = ifelse(colnames(DANT) %in% c('project_pseudo_id', 'variant_id',
                                                           'date', 'age', 'gender',
                                                           'circumference_waist_all_m_1',
                                                           'circumference_hip_all_m_1',
                                                           'bodylength_cm_all_m_1',
                                                           'bodyweight_kg_all_m_1'), NA, "NULL"))
DANT <- DANT[DANT$variant_id=="1a_v_1_anthro_8plus_v1",
             c('project_pseudo_id',
               #         'variant_id',
               'date',
               'age',
               'gender',
               'circumference_waist_all_m_1',
               'circumference_hip_all_m_1',
               'bodylength_cm_all_m_1',
               'bodyweight_kg_all_m_1')]
names(DANT) = c("project_pseudo_id","date","age","gender","waist","hip","height","weight")


# There are a number of $5 entries
DANT$height <- as.numeric(DANT$height)
DANT$weight <- as.numeric(DANT$weight)
DANT$waist <- as.numeric(DANT$waist)
DANT$hip <- as.numeric(DANT$hip)


# removing unrealistic values (note: these are only for visit 1)
# skipped, as I no longer have these

DANT$BMI <- DANT$weight / ((DANT$height/100)^2)


DALL <- merge(DANT[,c("project_pseudo_id", "BMI")], DSMOK[,-1], all.x = F, all.y = F, sort = F,
              by.x = "project_pseudo_id", by.y = "PROJECT_PSEUDO_ID")
rm(DANT, DSMOK, LinkSMK)#, list_unrealID, list_unreal)
gc()


#### CytoSNP prep ####
DCYTO <- read.table("/groups/umcg-lifelines/rsc02/releases/cytosnp_linkage_files/v4/cytosnp_linkage_file_project_pseudo_id.txt",
                    header = T, stringsAsFactors = F)
DCYTO <- merge(DCYTO, DALL, all.x = T, all.y = F, by.x = "PROJECT_PSEUDO_ID", by.y = "project_pseudo_id")


# removing related samples 
listCS_GSA <- read.table("/groups/umcg-lifelines/rsc02/releases/affymetrix_imputed/v1/Relatives_between_chips/CytoSNP_duplicates+1stdgr_in_UGLI.txt", header = F)
listCS_Affy <- read.table("/groups/umcg-lifelines/rsc02/releases/affymetrix_imputed/v1/Relatives_between_chips/CytoSNP_duplicates+1stdgr_in_UGLI2.txt", header = F)

summary(DCYTO$BMI)
DCYTO$BMI[DCYTO$cytosnp_ID %in% c(listCS_GSA$V1, listCS_Affy$V1)] <- NA
summary(DCYTO$BMI)

rm(listCS_GSA, listCS_Affy)

# add PCs
PCcyto <- read.table("/groups/umcg-lifelines/rsc02/releases/cytosnp_genotypes/v4/PC/LL_CytoSNP_PCs.txt",
                     header = T, stringsAsFactors = F)
DCYTO <- merge(DCYTO, PCcyto, by.x = "cytosnp_ID", by.y = "IID", all.x =T, all.y = F, sort = F)
rm(PCcyto)

colnames(DCYTO)[1] <- "IID"
DCYTO <- DCYTO[,c("FID", "IID", "BMI", "age", "age2", "sex", "CURSMK", paste0("PC", 1:10))]
write.table(DCYTO, "dataF_CS.txt", sep = "\t", quote = F, row.names = F)



#### GSA prep ####
DGSA <- read.csv("/groups/umcg-lifelines/rsc02/releases/gsa_linkage_files/v2/gsa_linkage_file_v2.csv",
                   header = T, stringsAsFactors = F)
DGSA <- merge(DGSA, DALL, all.x = T, all.y = F, by.x = "PROJECT_PSEUDO_ID", by.y = "project_pseudo_id")

# PCs
PCGSA <- read.table("/groups/umcg-lifelines/rsc02/releases/gsa_genotypes/v2/Data/PC/PCA_eur.UGLI.eigenvec",
                    header = F, stringsAsFactors = F)
colnames(PCGSA)[3:22] <- paste0("PC", 1:20)
colnames(PCGSA)[1:2] <- c("FID", "IID")
# FID == IID in fam file; and also in PC file (except there are 1001 samples that miss both FID and IID)


# note that PCGSA has missing IDs!
DGSA <- merge(DGSA, PCGSA, by.x = "UGLI_ID", by.y = "IID", all.x =T, all.y = F, sort = F)
rm(PCGSA)
colnames(DGSA)[1] <- "IID"

DGSA <- DGSA[,c("FID", "IID", "BMI", "age", "age2", "sex", "CURSMK", paste0("PC", 1:20))]
write.table(DGSA, "dataF_GSA.txt", sep = "\t", quote = F, row.names = F)



### Affy prep ####
DAFFY <- read.csv("/groups/umcg-lifelines/rsc02/releases/affymetrix_linkage_files/v2/affymetrix_linkage_file_v2.csv",
                   header = T, stringsAsFactors = F)
DAFFY <- merge(DAFFY[,-3], DALL, all.x = T, all.y = F, by.x = "PROJECT_PSEUDO_ID", by.y = "project_pseudo_id")

# NOTE: uses Affy v1 because there are no v2 files available yet (1/10/2025). This should not make a huge difference according to Ilja (e-mail 30/9)
listAffy_GSA <- read.table("/groups/umcg-lifelines/rsc02/releases/affymetrix_imputed/v1/Relatives_between_chips/UGLI2_duplicates+1stdgr_in_UGLI.txt", header = F)
summary(DAFFY$BMI)
DAFFY$BMI[DAFFY$Barcode %in% listAffy_GSA$V1] <- NA
summary(DAFFY$BMI)

# PCs
# Again, v2 is not available yet, so we stick to v1
# Note that FID have changed to 0 in v2, so we need to do that manually
PCAFFY <- read.table("/groups/umcg-lifelines/rsc02/releases/affymetrix_genotypes/v1/PCs/UGLI2_PCs.txt",
                    header = T, stringsAsFactors = F)
PCAFFY$FID <- 0L
DAFFY <- merge(DAFFY, PCAFFY, by.x = "Barcode", by.y = "IID", all.x =T, all.y = F, sort = F)
rm(PCAFFY)
colnames(DAFFY)[1] <- "IID"

DAFFY <- DAFFY[,c("FID", "IID", "BMI", "age", "age2", "sex", "CURSMK", paste0("PC", 1:20))]

write.table(DAFFY, "dataF_AFFY.txt", sep = "\t", quote = F, row.names = F)
