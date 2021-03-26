print("Start")
print(Sys.time())

# =====================================================================================================================================================
# Set up 
# =====================================================================================================================================================

if (!require("plyr")) install.packages("plyr", repos = "http://cran.us.r-project.org")
if (!require("tidyverse")) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if (!require("data.table")) install.packages("data.table", repos = "http://cran.us.r-project.org")

setwd('/rds/general/project/hda_students_data/live/Group9/General')

# Define  
output_folder <- 'Ross/Data/hesin_wrangling/' # MUST INCLUDE '/' AT THE END N.B. this is the path from the working directory set in each script, typically set to default
job_ID <- '18_Mar_0.01_' # Identifies the job and forms the start of the filename therefore ends with '_'
diagnosis_inclusion_threshold <- 0.01  # Inclusion threshold as decimal
size_of_steps_for_iterative_not_hot_loop <- 211 # Define the number of eids included in each loop of creating dataset, smaller = more frequent updating during processing

# Import  
hesin <- as_tibble(fread('Data/InputDataFiles/hesin.txt'))
hesin_diag <- as_tibble(fread('Data/InputDataFiles/hesin_diag.txt'))
cases_controls_eids <- read_csv('Data/cases_controls_ID.csv') #Cols: X1, eid, casecont

print("Import complete")
print(Sys.time())


# =====================================================================================================================================================
# Data Prep
# =====================================================================================================================================================

# 1. Create joined object by adding epistart to hesin_diag ------------------------------------------------------------------------------------------------------------
hesin_joined <- left_join(hesin_diag, select(hesin, eid, ins_index, epistart), by = c('eid', 'ins_index'))
hesin_joined$epistart <- as.Date(hesin_joined$epistart, format="%d/%m/%Y")


# 2. Create single 'diagnosis' col w/ prefix for later identification ------------------------------------------------------------------------------------------------------------
hesin_joined <- hesin_joined %>%
  mutate(diagnosis = ifelse(str_detect(diag_icd10,"."), paste0("10_",diag_icd10), paste0("9_",diag_icd9)))


# 3. Create working hesin_final dataset ------------------------------------------------------------------------------------------------------------
hesin_final <- hesin_joined %>% 
  select(eid, ins_index, arr_index, diagnosis, epistart) %>%
  filter(eid %in% cases_controls_eids$eid) # Filter is to reduce size of dataset by removing unnecessary rows

print(colnames(hesin_final))
print("Mid-data-prep milestone complete")
print(Sys.time())


# 4. Apply threshold set in inputs to diagnoses ------------------------------------------------------------------------------------------------------------




# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# DIAGNOSIS TABLE IS THE ISSUE << CURRENTLY NOT as_tibble() wrapped 

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


freq_table = as_tibble(as.data.frame(table(unlist(data))))

# Create table with penetration rate
diagnosis_table <- as_tibble(as.data.frame(table(unlist(hesin_final$diagnosis))))
print(paste("Diagnosis table complete, colnames:", colnames(diagnosis_table)))

total_N_all <- dim(cases_controls_eids)[1]
diagnosis_table$penetration <- round(diagnosis_table[2] / total_N_all, 4) * 100
print(paste("Penetration added, colnames:", colnames(diagnosis_table)))

colnames(diagnosis_table) <- c('diagnosis', 'frequency', 'penetration')
print(paste("Diagnosis table complete, colnames:", colnames(diagnosis_table)))




# Extract list of diagnoses exeeding threshold
diag_above_threshold <- diagnosis_table %>% 
  filter(penetration >= diagnosis_inclusion_threshold) %>%
  select(diagnosis) %>%
  unlist()

print("Extract list of diagnoses exeeding threshold")

# Filter hesin_final to only include diagnoses above threshold (making dataset smaller)
hesin_final <- hesin_final %>%
    filter(diagnosis %in% diag_above_threshold)

print("Filter hesin_final to only include diagnoses above threshold (making dataset smaller)")

print("Data prep complete")
print(Sys.time())


# =====================================================================================================================================================
# Iteratively create 1hot encoded summary by eid
# =====================================================================================================================================================

# 1. Create an empty dataset ------------------------------------------------------------------------------------------------------------

# Max N# ICD diagnoses per person
hesin_diag_eid_table <- as_tibble(as.data.table(table(hesin_diag$eid)))
max_icds_per_person <- max(hesin_diag_eid_table$N) 

# Create empty output
hesin_not_hot <- vector(mode = "character", length = max_icds_per_person * 2 + 1)

# 2. Create eid list to iterate over ------------------------------------------------------------------------------------------------------------
eid_list <- cases_controls_eids$eid %>%
  unlist() %>%
  unique() %>%
  as.character()

# 3. Write function to iteratively (by eid) create the final output ------------------------------------------------------------------------------------------------------------

not_hot_by_eid <- function(eid_range) {
  for (i in eid_range){ 
    # Create a subset of the hesin_final data
    eid_ordered <- hesin_final %>%
      filter(eid == eid_list[i]) %>%
      select(epistart, diagnosis) %>% 
      arrange(epistart)
  
    # Interleave the subset
    vec1 <- as.vector(as.character(eid_ordered$diagnosis))
    vec2 <- as.vector(as.character(eid_ordered$epistart))
    output <- c(vec1, vec2)
    nrows <- dim(eid_ordered)[1]
    interleave_index <- order(c(1:nrows, 1:nrows))
    output <- output[interleave_index]
    
    # Bind to out final output
    output <- c(eid_list[i], output)
    NA_tail_length <- length(output_colnames) - length(output) 
    output <- c(output, replicate(NA_tail_length, NA))
    hesin_not_hot <- rbind(hesin_not_hot, output)
  }
  return(hesin_not_hot)
}


# 4. Apply function to chunks of the dataset to print status ------------------------------------------------------------------------------------------------------------
Y = 0
while(Y < dim(cases_controls_eids)[1]){
  X = Y + 1
  Y = X + size_of_steps_for_iterative_not_hot_loop
  not_hot_temp <- not_hot_by_eid(X:Y)
  hesin_not_hot <- rbind(hesin_not_hot, not_hot_temp)
  print(paste0(round(Y/dim(cases_controls_eids)[1],2),"% complete"))
  print(Sys.time())
  }


# 5. Reassign top row to colnames ------------------------------------------------------------------------------------------------------------

# Create output columns
output_colnames <- 'eid'
for (i in 1:max_icds_per_person) {
  output_colnames <- c(output_colnames, paste0('diagnosis ', i), paste0('epistart ', i))
}

colnames(hesin_not_hot) <- as_tibble(t(output_colnames))


print("not_hot complete")
print(Sys.time())


# =====================================================================================================================================================
# Write output to csv
# =====================================================================================================================================================

write.csv(diagnosis_table, paste0(output_folder,job_ID,'0_hesin_diagnosis_freq_table.csv'))
write.csv(hesin_not_hot, paste0(output_folder,job_ID,'1_hesin_not_hot.csv'))

print("Script complete")
print(Sys.time())
