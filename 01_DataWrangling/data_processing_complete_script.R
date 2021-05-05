############################## DATA PROCESSING SCRIPT - COMPLETE #####################################
#Clear environment
rm(list=ls())

#Read Datasets
cases_controls = read.csv("/rds/general/project/hda_students_data/live/Group9/General/Data/cases_controls_ID.csv")

UKB_26 =data.frame(fread("/rds/general/project/hda_students_data/live/Group9/General/Data/InputDataFiles/ukb26390.csv"))

UKB_27 =data.frame(fread("/rds/general/project/hda_students_data/live/Group9/General/Data/InputDataFiles/ukb27725.csv"))

non_consent = data.frame(fread("/rds/general/project/hda_students_data/live/Group9/General/Data/InputDataFiles/w19266_20200204.csv"))

cleaned_dictionary = data.frame(fread("/rds/general/project/hda_students_data/live/Group9/General/david/Output/cleaned_dictionary.csv"))

hesin = read.table("/rds/general/project/hda_students_data/live/Group9/General/Data/InputDataFiles/hesin.txt",fill = TRUE)

hesin_diag = read.table("/rds/general/project/hda_students_data/live/Group9/General/Data/InputDataFiles/hesin_diag.txt",fill=TRUE)

#Rename hesin columns
names(hesin_diag)[names(hesin_diag) == "V1"] <- "eid"
names(hesin_diag)[names(hesin_diag) == "V2"] <- "ins_index"
names(hesin_diag)[names(hesin_diag) == "V3"] <- "arr_index"
names(hesin_diag)[names(hesin_diag) == "V4"] <- "level"
names(hesin_diag)[names(hesin_diag) == "V5"] <- "diag_icd9"
names(hesin_diag)[names(hesin_diag) == "V6"] <- "diag_icd9_nb"
names(hesin_diag)[names(hesin_diag) == "V7"] <- "diag_icd10"
names(hesin_diag)[names(hesin_diag) == "V8"] <- "diag_icd10_nb"
View(hesin_diag)

#Delete first row of hesin_diag
hesin_diag = hesin_diag[-1,]
View(hesin_diag)

#transform diag_icd9 to rows
hesin_diag = as.data.frame(t(hesin_diag))

library(dplyr)
library(tidyr)

hesin_diag %>%
  gather(key, value, ins_index:level) %>%
  spread(diag_icd9, value)

#Merge cases and controls with UKB_26
out = merge(cases_controls,UKB_26, by = "eid")

#Merge the output with UKB_27
out_2 = merge(out, UKB_27, by ="eid")

#Merge the output with hesin_diag
out_3 = merge(out_2, hesin_diag, by ="eid")

#Merge the output with hesin
out_4 = merge(out_3,hesin, by="eid")

#Filter out non-consenting observations
data = filter(out_4, !(eid %in% non_consent$eid))
#There is no withdrawal in the observations we selected.

#Write csv file - This file contains all 15825 observations with all Field IDs in UKBB
setwd("/rds/general/project/hda_students_data/live/Group9/General/Malo")
write.csv(data,'data_to_be_cleaned.csv')

#Clear environment
rm(list=ls())

#Loading csv file with variables of interest in UKB
cleaned_dictionary = data.frame(fread("/rds/general/project/hda_students_data/live/Group9/General/david/Output/cleaned_dictionary.csv"))

#Create a vector to only select fields ID column from David's csv file.
#Field_IDs_list <- cleaned_dictionary$Field.ID

#Transform the vector into a text file to have your list available in a text file.
#write.table(Field_IDs_list,file = "/rds/general/project/hda_students_data/live/Group9/General/Malo/List_Field_IDs_cleaned.txt",col.names = F,row.names = F)

#Loading dataset with all 15000 rows and complete set of columns in UKB: 6590 variables. 
data_to_be_cleaned = data.frame(fread("/rds/general/project/hda_students_data/live/Group9/General/Malo/data_to_be_cleaned.csv"))

#Load complete set of Field IDs of interest in UKBB 
myfields = unname(unlist(read.table("/rds/general/project/hda_students_data/live/Group9/General/Malo/List_Field_IDs_cleaned.txt", header=FALSE)))


#####
#Create a vector to list of Field IDs as characters.
vars <- as.character(myfields)

#Keep only columns of interest in data_to_be_cleaned
library(dplyr)
working_dataset = select(data_to_be_cleaned,"eid",starts_with(vars))


#Write a csv file of your final working dataset
setwd("/rds/general/project/hda_students_data/live/Group9/General/Malo")
write.csv(working_dataset,'working_dataset_notext.csv')


#Load files to recode values of all variables in your working dataset
covars = read.csv("/rds/general/project/hda_students_data/live/Group9/General/Malo/covars.csv")
mycoding=read.csv("/rds/general/project/hda_students_data/live/Group9/General/Data/InputDataFiles/Codings_Showcase.csv")
colnames(mycoding)

data = read.csv("/rds/general/project/hda_students_data/live/Group9/General/Malo/working_dataset_notext.csv")

#Make a copy of data
recoded_covar = data

#Loop to get the meaning of cell value (for any variable in your dataset and for all observations).
### Iterate ----
for (i in 1:nrow(covars)){
  if (!is.na(covars$coding_id[i])){
    myid=covars$coding_id[i]
    
    mycoding_field=mycoding[which(mycoding[,1]==myid),]
    mycoding_field=mycoding_field[,-1]
    rownames(mycoding_field) <- mycoding_field[,1]
    
    # Recoding categories
    mygrep=grep(paste0("X",covars$field_id[i],"."), fixed=TRUE, colnames(recoded_covar))
    for (g in 1:length(mygrep)){
      recoded_covar[,mygrep[g]]=as.character(mycoding_field[as.character(data[,mygrep[g]]),"Meaning"])
    }
  }
}

#Test if it worked properly
print(recoded_covar$X1050.0.0)
print(recoded_covar$X10877.0.0)

#Write final dataset
setwd("/rds/general/project/hda_students_data/live/Group9/General/Data")
write.csv(recoded_covar,'working_dataset_2.csv')


##Merging Hesin with UKB and create final dataset.

hesin = read.table("/rds/general/project/hda_students_data/live/Group9/General/Data/InputDataFiles/hesin.txt",fill = TRUE)

hesin_diag = read.table("/rds/general/project/hda_students_data/live/Group9/General/Data/InputDataFiles/hesin_diag.txt",fill=TRUE)

#Work around hesin_diag to have only 1 row per eid


#Merge hesin and hesin_diag
hesin_merged = merge(hesin,hesin_diag, by = c("V1","V2"))

#Create dataset with only columns of interest
hesin_merged_2 = hesin_merged[,c("V1","V2","V5.x","V3.y","V4.y","V5.y")]

#Renaming of hesin_merged_2 colnames
names(hesin_merged_2)[names(hesin_merged_2) == "V1"] <- "eid"
names(hesin_merged_2)[names(hesin_merged_2) == "V2"] <- "ins_index"
names(hesin_merged_2)[names(hesin_merged_2) == "V5.x"] <- "epistart"
names(hesin_merged_2)[names(hesin_merged_2) == "V3.y"] <- "arr_index"
names(hesin_merged_2)[names(hesin_merged_2) == "V4.y"] <- "level"
names(hesin_merged_2)[names(hesin_merged_2) == "V5.y"] <- "X40006."
View(hesin_merged_2)

#Create a first dataset of hesin whose ICD10 values need recoding
setwd("/rds/general/project/hda_students_data/live/Group9/General/Malo")
write.csv(hesin_merged_2,'hesin_merged_1st_step.csv')


data = read.csv("/rds/general/project/hda_students_data/live/Group9/General/Malo/data_to_be_cleaned.csv")

#Recode X40006.0.0 to have name of disease
names(data)[names(data) == "X40006."] <- "X40006.0.0"

coding_id="19"
#mycoding=read.csv("Codings_Showcase.csv")
print(head(mycoding))
mycoding_field=mycoding[which(mycoding[,1]==coding_id),]
mycoding_field=mycoding_field[,-1]
rownames(mycoding_field)=mycoding_field[,1]
print(mycoding_field)

# As it is in raw data:
print(data$X40006.0.0)

# Recoded categories:
data$X40006.0.0=as.character(mycoding_field[as.character(data$X40006.0.0),"Meaning"])

#Write csv with recoded values
setwd("/rds/general/project/hda_students_data/live/Group9/General/Malo")
write.csv(data,'hesin_merged_1st_step.csv')


#Clear environment
rm(list=ls())

data = read.csv("/rds/general/project/hda_students_data/live/Group9/General/Malo/hesin_merged_1st_step.csv")
#Remove two useless columns X and X.1
data = subset(data,select = -c(X.1,X))

#Keep 1 row per EID
library(data.table)
data = as.data.table(data)
data$date_ins_index_icd10_hosp = paste(data$epistart,"-",data$ins_index,"-",data$X40006.0.0)

#Load case_controls dataset
IDs_of_interest = read.csv("/rds/general/project/hda_students_data/live/Group9/General/Data/cases_controls_ID.csv")
IDs_of_interest$eid <- as.factor(IDs_of_interest$eid)
#Merge data and cases_controls datasets
data = merge(data,IDs_of_interest,by="eid")

#Keep only eids and date_ins_index_icd_hosp variables
data = data[,c("eid","date_ins_index_icd10_hosp")]

hesin_final = dcast(data,eid~paste0("date_ins_index_icd10_hosp",rowid(eid)),value.var=c("date_ins_index_icd10_hosp"))

#Write csv file hesin_cleaned in Data folder - 14493 matching eids with our cases_controls.
setwd("/rds/general/project/hda_students_data/live/Group9/General/Data")
write.csv(hesin_final,"hesin_cleaned.csv")

#Clear environment
rm(list=ls())

#Load hesin_cleaned and working_datasets and merge them
hesin_cleaned = read.csv("/rds/general/project/hda_students_data/live/Group9/General/Data/hesin_cleaned.csv")
working_dataset = read.csv("/rds/general/project/hda_students_data/live/Group9/General/Data/working_dataset_2.csv")

library(dplyr)
working_dataset_final = full_join(hesin_cleaned,working_dataset, by = "eid")
setwd("/rds/general/project/hda_students_data/live/Group9/General/Data")
write.csv(working_dataset_final,"working_dataset_final.csv")


############################## END DATA PROCESSING SCRIPT #####################################