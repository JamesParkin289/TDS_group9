# Set Up ------------------------------------------------------------------------------------------------------------

if (!require("plyr")) install.packages("plyr", repos = "http://cran.us.r-project.org")
if (!require("tidyverse")) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if (!require("data.table")) install.packages("data.table", repos = "http://cran.us.r-project.org")

setwd('/rds/general/project/hda_students_data/live/Group9/General')

# Inputs
source('Ross/Scripts/Table2_0_Inputs.R')

# Data
Table2 <- read_csv('Ross/Data/Table2/25_Mar_2000X_7_table2.csv')


# Transform ------------------------------------------------------------------------------------------------------------

Table2 <- Table2 %>%
    arrange(desc(all)) %>%
    filter(Comorbs != 'Total_n_of_comorbidities', Comorbs != 'casecont') %>%
    filter(all_N_percent > (0.01*15825)) %>%
    select(-X1, -control, -case, -all)

colnames(Table2)[colnames(Table2) %in% c("Comorbs", "control_N_percent", "case_N_percent", "all_N_percent")] <- 
    c("Comorbidities", "Controls | N (%)", "Cases | N (%)", "All participants | N (%)")

# Write output ------------------------------------------------------------------------------------------------------------

write.csv(Table2, paste0(output_folder,job_ID,'8_table2_finaloutput.csv'))