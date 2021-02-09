# =====================================================================================================================
# User Options - edit the options below before running the script
# =====================================================================================================================

# 1. Select which instances (timepoints) you want to import by altering the RHS of the relevant object below

# INSTANCE       /     INCLUDE: (TRUE / FALSE)
Select_Inst_0   <-     TRUE
Select_Inst_1   <-     FALSE
Select_Inst_2   <-     TRUE
Select_Inst_3   <-     FALSE
Select_Inst_4   <-     FALSE

# 2. Enter the suffix (not full name or path) of your data dictionary file 
#     e.g. entering 'Ross' below will use the file UK_BB_DD_Input_Ross.csv in selecting the variables
dd_file_suff <- 'Test'

# 3. Enter the suffix (not full name or path) that you would like to append to your output files
#     e.g. entering 'Ross' below will output the file: working_dataset_Ross
output_file_suff <- 'Test'

# 4. Update the path below with your hpc details - ensure it ends in Group9/General/Data
setwd("/rds/general/user/rcw20/projects/hda_students_data/live/Group9/General/Data")

# 5. Install any of these packages that you haven't already installed on your hpc environment 
#install.packages('tidyverse')
#install.packages('data.table')
#install.packages("readxl")
#install.packages('roperators')


# =====================================================================================================================

library('roperators')
library('tidyverse')
library('data.table')
library('readxl')
library('bit64') 


# IMPORT DATA REQUIRED AS OBJECTS
main_data_temp = data.frame(fread("InputDataFiles/ukb26390.csv", nrows=5)) 
dim(main_data_temp)
data_dict = data.frame(fread('InputDataFiles/UK_BB_DD_Input.csv')) 
withdrawn_eids = read_csv("InputDataFiles/w19266_20200204.csv", col_names = 'eid')
cat_var_codings = read_csv('InputDataFiles/Codings_Showcase.csv') 
# biomkr_data = read_csv("../ukb27725.csv") 
# biomkr_annotations = as_tibble(read_excel("../Biomarker_annotation.xlsx"))


# 1. Use '...DD_Input.csv' to select variables for working data

# Create object with field_ids selected in dd_input
dd = filter(data_dict, Selection_Flag != '') #filter to just non-blank rows in the 'Selection_Flag' col
myfields = unname(unlist(dd$Field_ID))

# Extracting the column ids 
column_id = grep("eid", colnames(main_data_temp))
found_fieldids = NULL
for (k in 1:length(myfields)){
  mygrep = grep(paste0("X",myfields[k],"."), fixed=TRUE, colnames(main_data_temp))
  if (length(mygrep)>0){
    found_fieldids = c(found_fieldids, myfields[k])
    }
  column_id = c(column_id, mygrep)
}

# Import main_data based on 
main_data = data.frame(fread("InputDataFiles/ukb26390.csv", select=column_id))


# Remove non-consenting participants
main_data = filter(main_data, !(eid %in% withdrawn$eid))

# OUTPUT MILESTONE -----------------------------------------------------------------------------------------

# write.csv(main_data, 'OutputDataFiles/intermediate_output_data.csv')
# Can run entire script to this point to procuce unlabelled data with fields selected in the data dictionary

# ----------------------------------------------------------------------------------------------------------


# TIDYING DATA
# %%%%%%%%%%%%

# Selection of instances -----------------------------------------------------------------------------------

SelectInstances = c(Select_Inst_0, Select_Inst_1, Select_Inst_2, Select_Inst_3, Select_Inst_4)
InstanceStrings = c("\\.0\\.", "\\.1\\.", "\\.2\\.", "\\.3\\.", "\\.4\\.") # N.B. '\\.' is a regex expression which will be read as '.'
SelectedStrings = InstanceStrings[SelectInstances]
main_data = select(main_data, matches(paste(SelectedStrings, collapse = "|")))

# write.csv(main_data, 'OutputDataFiles/instance_test_data.csv')


# COMMENT ON 2021 02 06: code works up to this point *********************************************************************************************************


# Applying column names ------------------------------------------------------------------------------------

# Process largely complete below, just need integrating after instances layer added

# 1. Create lookup table which breaks down the main_data column names into constituent parts
# 2. Merge lookup table with Description from DD and coding array to create
# 3. Create final column name


# IMPORT 

main_data_temp = read_csv('OutputDataFiles/instance_test_data.csv')

# AUTOMATE PROCESS OF ADDING USEFUL COLUMN NAMES

# Create a tibble of extracted col names with each component broken out: field_id, instance_id, coding_id
d_colNames = tibble('extracted_col_names' = colnames(main_data_temp)) # RUNNING OF MAIN DATA TEMP  ***********************************
str(d_colNames)

temp = separate(d_colNames, extracted_col_names, into = c('field_id', 'instance_id', 'coding_id'), sep = "\\.") 
d_colNames = as_tibble(cbind(d_colNames, temp)) 
d_colNames = mutate(d_colNames, field_id = field_id %-% 'X') 
d_colNames$field_id = as.integer(d_colNames$field_id)
d_colNames$coding_id = as.integer(d_colNames$coding_id)


# Add descriptions from data dictionary to d_colNames
d_colNames = d_colNames %>%
  left_join(data_dict, c('field_id' = 'Field_ID'))

str(d_colNames)
head(d_colNames)
str(cat_var_codings)


# Add codings from cat_var_codings
d_colNames = d_colNames %>%
  left_join(cat_var_codings, c('coding_id' = 'Coding'))

left_join(help)

str(d_colNames)
str(cat_var_codings)
# 'Coding' 'Meaning'


# Create final column name
# d_colNames$main_data_col_names < remove spaces
# If there are multiple instances (TRUE, FALSE, etc.) then append Instance
#   Else append coding ID
# Manually bodge the entry for 'eid'


# Create final column name starting with description
d_colNames$main_data_col_names = gsub(" ", "_", d_colNames$Description)
if(SelectInstances has more than 1 TRUE) {paste instance and coding ID on to main_data_col_names} else {paste coding on to main_data_col_names}

# Create column for final column names 
d_colNames = mutate(d_colNames, colNames = paste(Description,"_",instance_id, "_", coding_id))

# Manually bodge the entry for 'eid'
d_colNames$colNames[1] = 'eid'

# Rename data columns
colnames(data) = d_colNames$colNames

# Is it possible to check for 1 hot coding across a range of colummns that have the same field ID
# If the check shows that each entry only has one coding then we can combine into non-1 hot columns
# Perhaps write two outputs: 1) 1_hot 2) not_hot

# EXPORT DATA
# %%%%%%%%%%%

write.csv(data, 'pipeline_test.csv')