print('Start')
print(Sys.time())

# =====================================================================================================================================================
# Set up 
# =====================================================================================================================================================

if (!require("plyr")) install.packages("plyr", repos = "http://cran.us.r-project.org")
if (!require("tidyverse")) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if (!require("data.table")) install.packages("data.table", repos = "http://cran.us.r-project.org")
if (!require("readxl")) install.packages("readxl", repos = "http://cran.us.r-project.org")
if (!require("bit64")) install.packages("bit64", repos = "http://cran.us.r-project.org")
if (!require("roperators")) install.packages("roperators", repos = "http://cran.us.r-project.org")
if (!require("binaryLogic")) install.packages("binaryLogic", repos = "https://www.rdocumentation.org/packages/binaryLogic")

setwd('/rds/general/project/hda_students_data/live/Group9/General')

# Inputs
source('Ross/Scripts/Table2_0_Inputs.R')
source('Ross/Scripts/wrangling_functions.R') 

# Data
cases_controls_eids <- read_csv('Data/cases_controls_ID.csv') #Cols: X1, eid, casecont
ukbb <- as_tibble(fread('Data/InputDataFiles/ukb26390.csv'))
codings <- read_csv('Data/InputDataFiles/Codings_Showcase.csv') #Cols: 'Coding', 'Value', 'Meaning'
data_dict <- read_excel('Ross/Data/UK_BB_DataDict_working.xlsx') 


# =====================================================================================================================================================
# Data Prep
# =====================================================================================================================================================

# Set up working dataset and extract specific fields --------------------------------------------------------------------------------------------
working <- cases_controls_eids %>% 
    select(eid, casecont) %>%
    inner_join(ukbb, by = 'eid') # N.B. field_id has no X at the start and case_control status is included via inner join

working_subset <- import_data_using_fields(field_ids_to_extract, working)

recoded_subset <- recode_values(working_subset, codings, data_dict)


# Create a non-duplicated list of all comorbidities and remove NAs --------------------------------------------------------------------------------------------
comorbs_list <- recoded_subset %>% 
    select(-eid, -casecont) %>% 
    unlist() %>% 
    unique()

comorbs_list <- comorbs_list[!is.na(comorbs_list)]


# Create comorbs_1hot tibble of binary yes/no presence of comorbidity by eid --------------------------------------------------------------------------------------------
comorbs_1hot <- recoded_subset %>% select(eid, casecont)

for (i in comorbs_list){
    new_col <- apply(recoded_subset, 1, function(r) any(r == i))
    new_col <- as_tibble(as.integer(new_col, logic = TRUE))
    colnames(new_col) <- i
    comorbs_1hot <- cbind(comorbs_1hot, new_col)
}

comorbs_1hot <- as_tibble(comorbs_1hot)

print('Data prep complete')
print(Sys.time())

# =====================================================================================================================================================
# Write intermediate output to csv
# =====================================================================================================================================================

write.csv(recoded_subset, paste0(output_folder,job_ID,'1_recoded_subset.csv'))
write.csv(comorbs_list, paste0(output_folder,job_ID,'2_comorbs_list.csv'))
write.csv(comorbs_1hot, paste0(output_folder,job_ID,'3_comorbs_1hot.csv'))